--!strict

-- Stored Values


---------- Imports ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local Custom = require(script:WaitForChild("Custom"))
local GuiStyles = require(script:WaitForChild("GuiStyles"))
local Images = require(script:WaitForChild("Images"))
local Speakers = require(script:WaitForChild("Speakers"))

local _SoundEffects = ReplicatedStorage:WaitForChild("SoundEffects")
local DialogSounds = require(_SoundEffects:WaitForChild("DialogSounds"))


---------- Module ----------

local Module = {}


----- Module fields -----

Module.custom = Custom
Module.guiStyles = GuiStyles
Module.images = Images
Module.sounds = DialogSounds
Module.speakers = Speakers


---------- Return module ----------

table.freeze(Module)
return Module
