--!strict

-- Dialog Sounds


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
    Constants.preset.ClickFast3,
}

Module.omoriText = {
    Constants.preset.OmoriText1,
    Constants.preset.OmoriText2,
}


---------- Return module ----------

table.freeze(Module)
return Module
