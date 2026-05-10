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
        dialogGuiStyle = {
            backgroundColor = ColorSequence.new(Color3.new(.75, 0, 0)),
            textColor = Color3.new(0, .75, 0),
            textStrokeColor = Color3.new(0, .25, 0),
            textFont = Font.fromEnum(Enum.Font.Merriweather),
        },
        imageData = {
            rightImage = {
                imageId = "rbxthumb://type=AvatarBust&id=417781436&w=352&h=352",
                size = UDim2.fromScale(0.3, 1),
            },
        },
        textData = {
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
            dialogText = "Have fun!",
        },
    },
    nextSequenceId = DialogInfo.constants.CLOSE_SEQUENCE_ID,
} :: DialogInfo.DialogSequence


---------- Return module ----------

table.freeze(Module)
return Module
