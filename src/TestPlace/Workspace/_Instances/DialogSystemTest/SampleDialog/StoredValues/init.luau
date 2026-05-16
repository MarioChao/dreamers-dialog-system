--!strict

-- Stored Values


---------- Imports ----------

local Custom = require(script:WaitForChild("Custom"))
local GuiStyles = require(script:WaitForChild("GuiStyles"))
local Images = require(script:WaitForChild("Images"))
local Sounds = require(script:WaitForChild("Sounds"))
local Speakers = require(script:WaitForChild("Speakers"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.custom = Custom
Module.guiStyles = GuiStyles
Module.images = Images
Module.sounds = Sounds
Module.speakers = Speakers


---------- Return module ----------

table.freeze(Module)
return Module
