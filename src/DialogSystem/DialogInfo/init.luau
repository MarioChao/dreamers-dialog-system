--!strict

-- Dialog Info


---------- Imports ----------

local DialogConstants = require(script:WaitForChild("DialogConstants"))
local DialogTypes = require(script:WaitForChild("DialogTypes"))


---------- Types ----------

export type DialogGuiStyle = DialogTypes.DialogGuiStyle
export type DialogIndividualImageData = DialogTypes.DialogIndividualImageData
export type DialogImageData = DialogTypes.DialogImageData
export type DialogTextData = DialogTypes.DialogTextData
export type DialogOptionData = DialogTypes.DialogOptionData
export type DialogEntry = DialogTypes.DialogEntry
export type DialogSequence = DialogTypes.DialogSequence


---------- Module ----------

local Module = {}


----- Module fields -----

Module.constants = DialogConstants


---------- Return module ----------

table.freeze(Module)
return Module
