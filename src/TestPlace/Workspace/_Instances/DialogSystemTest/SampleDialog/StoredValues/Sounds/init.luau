--!strict

-- Sounds


---------- Constants ----------

local Constants = {}

Constants.preset = script.Preset

table.freeze(Constants)


---------- Module ----------

local Module = {}


----- Module fields -----

Module.clickFast = {
    Constants.preset.ClickFast1,
    Constants.preset.ClickFast2,
}

Module.omoriText = {
    Constants.preset.OmoriText,
}


---------- Return module ----------

table.freeze(Module)
return Module
