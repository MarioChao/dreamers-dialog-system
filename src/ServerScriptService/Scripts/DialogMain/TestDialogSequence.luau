--!strict


---------- Services ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DialogConstants = require(ReplicatedStorage.Modules.DialogSystem.DialogConstants)
local DialogTypes = require(ReplicatedStorage.Modules.DialogSystem.DialogTypes)


---------- Module ----------

local Module = {}


----- Module fields -----

Module.default = {
    sequenceId = "default",
    entry = {
        imageData = {
            rightImage = {
                imageId = "rbxthumb://type=Avatar&id=417781436&w=352&h=352",
                size = UDim2.fromScale(0.3, 1),
            },
        },
        textData = {
            speakerName = "Panicks28 - Game Creator",
            dialogText = "Hello.\nWelcome to the game!",
        },
    },
    nextSequenceId = "default2",
} :: DialogTypes.DialogSequence

Module.default2 = {
    sequenceId = "default2",
    entry = {
        imageData = {
            rightImage = {
                imageId = "rbxthumb://type=AvatarBust&id=417781436&w=352&h=352",
                size = UDim2.fromOffset(0.3, 1),
            },
        },
        textData = {
            dialogText = "To start, vote for a puzzle by stepping on one of the plates with red outlines!",
        },
        options = {
            {
                id = "how_to_play",
                text = "How to play the game?",
            },
            {
                id = "i_got_it",
                text = "I got it!",
            },
        },
    },
    optionId_sequenceId = {
        how_to_play = "option1",
        i_got_it = "have_fun",
    },
} :: DialogTypes.DialogSequence

Module.option1 = {
    sequenceId = "option1",
    entry = {
        imageData = Module.default2.entry.imageData,
        textData = {
            dialogText = (
                "In a new server, each game will start at the easiest difficulty.\n" ..
                "You can learn more about the games by for searching the name of the games online!"
            ),
        },
    },
    nextSequenceId = "repeated",
} :: DialogTypes.DialogSequence

Module.repeated = {
    sequenceId = "repeated",
    entry = {
        imageData = Module.default2.entry.imageData,
        textData = {
            dialogText = "Any more questions?",
        },
        options = Module.default2.entry.options,
    },
    optionId_sequenceId = {
        how_to_play = "option1",
        i_got_it = "have_fun",
    },
} :: DialogTypes.DialogSequence

Module.have_fun = {
    sequenceId = "have_fun",
    entry = {
        imageData = Module.default.entry.imageData,
        textData = {
            dialogText = "Have fun!",
        },
    },
    nextSequenceId = DialogConstants.CLOSE_SEQUENCE_ID,
} :: DialogTypes.DialogSequence


---------- Return module ----------

table.freeze(Module)
return Module
