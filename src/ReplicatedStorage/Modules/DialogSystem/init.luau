--!strict

-- Dialog System


---------- Services ----------

local RunService = game:GetService("RunService")
local DialogEvents = require(script:WaitForChild("DialogEvents"))
local Types = require(script:WaitForChild("Types"))


----- Check environment -----

if not RunService:IsServer() then
    warn("[Dialog System]: Module should only be required from the server!")
end


---------- Types ----------

export type DialogGuiStyle = Types.DialogGuiStyle
export type DialogEntry = Types.DialogEntry
export type DialogSequence = Types.DialogSequence


---------- Module ----------

local Module = {}


----- Module functions -----

function Module.setDialogSequenceForPlayer(player: Player, dialogSequence: Types.DialogSequence)
    DialogEvents.events.dialogBindableEvent:Fire(
        DialogEvents.eventStrings.dialogBindable.setDialogSequenceForPlayer,
        player, dialogSequence
    )
end


---------- Return module ----------

table.freeze(Module)
return Module
