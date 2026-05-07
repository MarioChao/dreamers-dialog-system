--!strict

-- Dialog Events


---------- Constants ----------

local Constants = {}

Constants.eventsFolder = script:WaitForChild("Events")
Constants.events = {
    dialogBindableEvent = Constants.eventsFolder:WaitForChild("DialogBindableEvent"),
}
Constants.eventStrings = {
    dialogBindable = {
        storeDialogSequencesForPlayer = "Bindable Store Dialog Sequences For Player",
        setDialogSequenceIdForPlayer = "Bindable Set Dialog Sequence Id For Player",
    }
}
Constants.remoteActions = {
    toClient = {
        showDialogEntry = "DLG Show Dialog Entry",
        clearDialogEntry = "DLG Clear Dialog Entry",
    },
    toServer = {
        chooseOption = "DLG Choose Option",
        nextDialog = "DLG Next Dialog",
    },
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
Module.remoteActions = Constants.remoteActions


---------- Return module ----------

table.freeze(Module)
return Module
