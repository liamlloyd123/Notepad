local isNotepadOpen = false
local notepadProp = nil

-- Utility: Notifications
RegisterNetEvent('rp_notepad:client:notify')
AddEventHandler('rp_notepad:client:notify', function(msg)
    SetNotificationTextEntry("STRING")
    AddTextComponentString(msg)
    DrawNotification(false, false)
end)

-- Utility: Load Animation Dictionary
local function loadAnimDict(dict)
    RequestAnimDict(dict)
    while not HasAnimDictLoaded(dict) do
        Wait(10)
    end
end

-- Utility: Animation Control
local function startNotepadAnim()
    local ped = PlayerPedId()
    loadAnimDict("missheistdockssetup1clipboard@base")
    TaskPlayAnim(ped, "missheistdockssetup1clipboard@base", "base", 8.0, -8.0, -1, 49, 0, false, false, false)
    
    local coords = GetEntityCoords(ped)
    local propModel = GetHashKey("prop_notepad_01")
    RequestModel(propModel)
    while not HasModelLoaded(propModel) do
        Wait(10)
    end
    
    notepadProp = CreateObject(propModel, coords.x, coords.y, coords.z, true, true, true)
    AttachEntityToEntity(notepadProp, ped, GetPedBoneIndex(ped, 18905), 0.1, 0.02, 0.05, 10.0, 0.0, 0.0, true, true, false, true, 1, true)
end

local function stopNotepadAnim()
    local ped = PlayerPedId()
    ClearPedTasks(ped)
    if notepadProp and DoesEntityExist(notepadProp) then
        DeleteEntity(notepadProp)
        notepadProp = nil
    end
end

-- Utility: Get Closest Player
local function getClosestPlayer()
    local closestPlayer = -1
    local closestDistance = -1
    local ped = PlayerPedId()
    local coords = GetEntityCoords(ped)
    
    for _, playerId in ipairs(GetActivePlayers()) do
        local targetPed = GetPlayerPed(playerId)
        if targetPed ~= ped then
            local distance = #(coords - GetEntityCoords(targetPed))
            if closestDistance == -1 or distance < closestDistance then
                closestPlayer = playerId
                closestDistance = distance
            end
        end
    end
    
    return closestPlayer, closestDistance
end

-- Command: Open Notepad (Write Mode)
RegisterCommand('notepad', function()
    if isNotepadOpen then return end
    isNotepadOpen = true
    
    startNotepadAnim()
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = "openmenu",
        mode = "write"
    })
end)

-- Event: Receive Note (Read Mode)
RegisterNetEvent('rp_notepad:client:receiveNote')
AddEventHandler('rp_notepad:client:receiveNote', function(noteData)
    if isNotepadOpen then return end
    isNotepadOpen = true
    
    startNotepadAnim()
    SetNuiFocus(true, true)
    
    SendNUIMessage({
        type = "openmenu",
        mode = "read",
        title = noteData.title,
        content = noteData.content
    })
end)

-- NUI Callbacks
RegisterNUICallback("close", function(data, cb)
    isNotepadOpen = false
    SetNuiFocus(false, false)
    stopNotepadAnim()
    
    SendNUIMessage({
        type = "closemenu"
    })
    
    cb("ok")
end)

RegisterNUICallback("giveNote", function(data, cb)
    local closestPlayer, closestDistance = getClosestPlayer()
    
    if closestPlayer ~= -1 and closestDistance <= 3.0 then
        local targetServerId = GetPlayerServerId(closestPlayer)
        TriggerServerEvent('rp_notepad:server:giveNote', targetServerId, data)
        
        isNotepadOpen = false
        SetNuiFocus(false, false)
        stopNotepadAnim()
        
        SendNUIMessage({
            type = "closemenu"
        })
    else
        TriggerEvent('rp_notepad:client:notify', "No one is close enough to hand the note to.")
    end
    
    cb("ok")
end)