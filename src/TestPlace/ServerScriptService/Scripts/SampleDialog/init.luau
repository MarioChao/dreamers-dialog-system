--!strict

-- Sample Dialog


---------- Imports ----------

local DialogInfo = require(script:WaitForChild("DialogInfo"))
local StoredValues = require(script:WaitForChild("StoredValues"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.start = {
    nodeId = "start",
    entry = {
        imageData = {
            rightImage = StoredValues.images.getPresetScaledUserThumbnailImageData(417781436, "Avatar"),
        },
        textData = {
            speakerName = StoredValues.speakers.gameCreator,
            dialogText = (
                "Hello. 👋!\n" ..
                "Welcome to the game!"
            ),
        },
    },
    nextNodeId = "dreamer_dialog",
} :: DialogInfo.DialogNode

Module.dreamer_dialog = {
    nodeId = "dreamer_dialog",
    entry = {
        dialogGuiStyle = StoredValues.guiStyles.christmas_like,
        imageData = {
            rightImage = StoredValues.images.getPresetScaledUserThumbnailImageData(417781436, "AvatarBust"),
        },
        textData = {
            speakerName = StoredValues.speakers.gameCreator,
            dialogText = "This is dreamer's dialog system!",
            typewriterData = {
                charSpeed = 36,
            },
        },
        optionsData = {
            options = {
                {
                    id = "rewind",
                    text = "Can you go back to the previous prompt?",
                },
                {
                    id = "i_got_it",
                    text = "I got it!",
                },
            },
            typewriterData = {
                charSpeed = 32,
                charSounds = StoredValues.sounds.omoriText,
            },
        },
    },
    optionId_nodeId = {
        rewind = "start",
        i_got_it = "have_fun",
    },
} :: DialogInfo.DialogNode

Module.have_fun = {
    nodeId = "have_fun",
    entry = {
        imageData = Module.start.entry.imageData,
        textData = {
            speakerName = StoredValues.speakers.gameCreator,
            dialogText = "Have fun!",
        },
    },
    nextNodeId = DialogInfo.constants.CLOSE_NODE_ID,
} :: DialogInfo.DialogNode


---------- Return module ----------

table.freeze(Module)
return Module
