--!strict

-- Puzzle Welcome Dialog


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
            speakerName = "???",
            dialogText = "Hello.\nWelcome to the game!",
        },
    },
    nextSequenceId = "default2",
} :: DialogInfo.DialogSequence

Module.default2 = {
    sequenceId = "default2",
    entry = {
        imageData = {
            rightImage = {
                imageId = "rbxthumb://type=AvatarBust&id=417781436&w=352&h=352",
                size = UDim2.fromScale(0.3, 1),
            },
        },
        textData = {
            speakerName = "Panicks28 - Game Creator",
            dialogText = "To start, vote for a puzzle by stepping on one of the plates with red outlines!",
        },
        optionsData = {
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
    },
    optionId_sequenceId = {
        how_to_play = "option1",
        i_got_it = "have_fun",
    },
} :: DialogInfo.DialogSequence

Module.option1 = {
    sequenceId = "option1",
    entry = {
        imageData = Module.default2.entry.imageData,
        textData = {
            dialogText = (
                "In a new server, each game will start at the easiest difficulty.\n" ..
                "You can learn more about the games by searching up the name of the games online!"
            ),
        },
    },
    nextSequenceId = "repeated",
} :: DialogInfo.DialogSequence

Module.repeated = {
    sequenceId = "repeated",
    entry = {
        imageData = Module.default2.entry.imageData,
        textData = {
            dialogText = "Any more questions?",
        },
        optionsData = Module.default2.entry.optionsData,
    },
    optionId_sequenceId = {
        how_to_play = "option1",
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
