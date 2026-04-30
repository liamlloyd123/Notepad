$(document).ready(function () {
    // Hide specific modes explicitly at start
    $('#write-mode').hide();
    $('#read-mode').hide();

    // STRICT JAVASCRIPT MESSAGE HANDLING
    window.addEventListener("message", (event) => {
        const data = event.data;

        if (data.type === "openmenu") {
            $('#notepad-container').fadeIn(200);

            if (data.mode === "write") {
                $('#read-mode').hide();
                $('#write-mode').show();
                $('#write-title').val('');
                $('#write-content').val('');
                setTimeout(() => { $('#write-title').focus(); }, 100);
            } 
            else if (data.mode === "read") {
                $('#write-mode').hide();
                $('#read-mode').show();
                
                // Assigning data sent from Lua
                $('#read-title').text(data.title || "Untitled");
                $('#read-content').text(data.content || "");
            }
        }

        if (data.type === "closemenu") {
            $('#notepad-container').fadeOut(200, function() {
                $('#write-mode').hide();
                $('#read-mode').hide();
            });
        }
    });

    // Close logic
    function closeUI() {
        $.post(`https://${GetParentResourceName()}/close`, JSON.stringify({}));
    }

    // Button Listeners
    $('#btn-close-write').click(function () {
        closeUI();
    });

    $('#btn-close-read').click(function () {
        closeUI();
    });

    $('#btn-give').click(function () {
        const noteTitle = $('#write-title').val().trim();
        const noteContent = $('#write-content').val().trim();

        if (noteContent === "") {
            return; // Don't send empty notes
        }

        // REQUIRED FORMAT for NUI -> Lua Communication
        $.post(`https://${GetParentResourceName()}/giveNote`, JSON.stringify({
            title: noteTitle,
            content: noteContent
        }));
    });

    // Escape key handling
    document.onkeyup = function (data) {
        if (data.key === "Escape") {
            closeUI();
        }
    };
});