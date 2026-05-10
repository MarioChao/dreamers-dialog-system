--!strict

-- Dialog Events


---------- Constants ----------

local Constants = {}

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

Module.remoteActions = Constants.remoteActions


---------- Return module ----------

table.freeze(Module)
return Module
