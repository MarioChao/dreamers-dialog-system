--!strict

-- Template Dialog


---------- Imports ----------

local _Assets = script.Parent:WaitForChild("_Assets")
local DialogInfo = require(_Assets:WaitForChild("DialogInfo"))
local StoredValues = require(_Assets:WaitForChild("StoredValues"))


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
                "Hello.\n" ..
                "Welcome to the game!"
            ),
        },
        optionsData = {
            options = {
                {
                    id = "next",
                    text = "Hi Panicks28. Filler, filler, filler text.",
                }
            }
        },
    },
    optionId_sequenceId = {
        next = "have_fun",
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
