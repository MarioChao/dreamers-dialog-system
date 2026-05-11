--!strict

-- Gui Styles


---------- Imports ----------

local _Assets = script.Parent.Parent
local DialogInfo = require(_Assets:WaitForChild("DialogInfo"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.default = {} :: DialogInfo.DialogGuiStyle

Module.christmas_like = {
    backgroundColor = ColorSequence.new(Color3.new(.75, 0, 0)),
    backgroundTransparency = 0.6,
    borderStrokeColor = Color3.new(0, 0, 0),
    textColor = Color3.new(0, .75, 0),
    textStrokeColor = Color3.new(0, .25, 0),
    textFont = Font.fromEnum(Enum.Font.Merriweather),
    textStrokeTransparency = 0.5,
} :: DialogInfo.DialogGuiStyle


---------- Return module ----------

table.freeze(Module)
return Module
