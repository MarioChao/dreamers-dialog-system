--!strict

-- Dialog Constants


---------- Module ----------

local Module = {
    CLOSE_SEQUENCE_ID = "CLOSE_DIALOG",
}


---------- Return module ----------

local function deepFreeze(t: {any}?)
    if type(t) == "table" then
        table.freeze(t)
        for _, v in t do
            deepFreeze(v :: {any}?)
        end
    end
end
deepFreeze(Module)
return Module
