RegisterNetEvent('rp_notepad:server:giveNote')
AddEventHandler('rp_notepad:server:giveNote', function(targetId, noteData)
    local src = source
    if not targetId or not noteData then return end
    
    local targetSrc = tonumber(targetId)
    if targetSrc and GetPlayerPing(targetSrc) > 0 then
        -- Route the note to the targeted player
        TriggerClientEvent('rp_notepad:client:receiveNote', targetSrc, noteData)
        TriggerClientEvent('rp_notepad:client:notify', src, "Note handed over successfully.")
    else
        TriggerClientEvent('rp_notepad:client:notify', src, "Target player not found.")
    end
end)