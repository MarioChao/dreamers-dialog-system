--!strict

-- Dialog System


---------- Services ----------

local RunService = game:GetService("RunService")
local DialogEvents = require(script:WaitForChild("DialogEvents"))
local DialogTypes = require(script:WaitForChild("DialogTypes"))


----- Check environment -----

if not RunService:IsServer() then
    warn("[Dialog System]: Module should only be required from the server!")
end


---------- Types ----------

export type DialogGuiStyle = DialogTypes.DialogGuiStyle
export type DialogEntry = DialogTypes.DialogEntry
export type DialogSequence = DialogTypes.DialogSequence


---------- Module ----------

local Module = {}


----- Module functions -----

function Module.storeDialogSequencesForPlayer(player: Player, dialogSequences: {[any]: DialogTypes.DialogSequence})
    DialogEvents.events.dialogBindableEvent:Fire(
        DialogEvents.eventStrings.dialogBindable.storeDialogSequencesForPlayer,
        player, dialogSequences
    )
end

function Module.setDialogSequenceIdForPlayer(player: Player, dialogSequenceId: string)
    DialogEvents.events.dialogBindableEvent:Fire(
        DialogEvents.eventStrings.dialogBindable.setDialogSequenceIdForPlayer,
        player, dialogSequenceId
    )
end


---------- Return module ----------

table.freeze(Module)
return Module
