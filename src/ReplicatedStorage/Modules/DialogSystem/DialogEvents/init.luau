--!strict

-- Dialog Events


---------- Constants ----------

local Constants = {}

Constants.eventsFolder = script:WaitForChild("Events")
Constants.events = {
    dialogRemoteEvent = Constants.eventsFolder:WaitForChild("DialogRemoteEvent"),
    dialogBindableEvent = Constants.eventsFolder:WaitForChild("DialogBindableEvent"),
}
Constants.eventStrings = {
    dialogRemote = {
        toServer = {
            connectPlayer = "Dialog Connect Player",
            chooseOption = "Dialog Choose Option",
            nextDialog = "Dialog Next Dialog",
        },
        toClient = {
            showDialogEntry = "Show Dialog Entry",
            clearDialogEntry = "Clear Dialog Entry",
        },
    },
    dialogBindable = {
        storeDialogSequencesForPlayer = "Bindable Store Dialog Sequences For Player",
        setDialogSequenceIdForPlayer = "Bindable Set Dialog Sequence Id For Player",
    }
}

local function deepFreeze(t: {any}?)
    if type(t) == "table" then
        table.freeze(t)
        for _, v in t do
            deepFreeze(v :: {any}?)
        end
    end
end
deepFreeze(Constants)


---------- Module ----------

local Module = {}


----- Module fields -----

Module.events = Constants.events
Module.eventStrings = Constants.eventStrings


---------- Return module ----------

table.freeze(Module)
return Module
