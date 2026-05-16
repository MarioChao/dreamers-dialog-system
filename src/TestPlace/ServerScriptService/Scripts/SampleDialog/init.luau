--!strict

-- Sample Dialog


---------- Imports ----------

local DialogInfo = require(script:WaitForChild("DialogInfo"))
local StoredValues = require(script:WaitForChild("StoredValues"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.start = {
    sequenceId = "start",
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
    nextSequenceId = "dreamer_dialog",
} :: DialogInfo.DialogSequence

Module.dreamer_dialog = {
    sequenceId = "dreamer_dialog",
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
    optionId_sequenceId = {
        rewind = "start",
        i_got_it = "have_fun",
    },
} :: DialogInfo.DialogSequence

Module.have_fun = {
    sequenceId = "have_fun",
    entry = {
        imageData = Module.start.entry.imageData,
        textData = {
            speakerName = StoredValues.speakers.gameCreator,
            dialogText = "Have fun!",
        },
    },
    nextSequenceId = DialogInfo.constants.CLOSE_SEQUENCE_ID,
} :: DialogInfo.DialogSequence


---------- Return module ----------

table.freeze(Module)
return Module
