--!strict

-- Custom


---------- Imports ----------

local _Assets = script.Parent.Parent
local DialogInfo = require(_Assets:WaitForChild("DialogInfo"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.template = "template value"


---------- Return module ----------

table.freeze(Module)
return Module
