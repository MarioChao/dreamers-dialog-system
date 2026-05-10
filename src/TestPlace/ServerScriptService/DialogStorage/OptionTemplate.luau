--!strict

-- Template Dialog


---------- Imports ----------

local DialogInfo = require(script.Parent:WaitForChild("_DialogInfo"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.start = {
    sequenceId = "start",
    entry = {
        imageData = {
            rightImage = {
                imageId = "rbxthumb://type=Avatar&id=417781436&w=352&h=352",
                size = UDim2.fromScale(0.3, 1),
            },
        },
        textData = {
            speakerName = "Panicks28 - Game Creator",
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
            dialogText = "Have fun!",
        },
    },
    nextSequenceId = DialogInfo.constants.CLOSE_SEQUENCE_ID,
} :: DialogInfo.DialogSequence


---------- Return module ----------

table.freeze(Module)
return Module
