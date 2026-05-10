--!strict

-- Dialog System


---------- Services ----------

local RunService = game:GetService("RunService")


----- Check environment -----

if not RunService:IsServer() then
    warn("[Dialog System]: Module should only be required from the server!")
end


---------- Imports ----------

local DialogEvents = require(script:WaitForChild("DialogEvents"))
local DialogInfo = require(script:WaitForChild("DialogInfo"))


---------- Types ----------

export type DialogGuiStyle = DialogInfo.DialogGuiStyle
export type DialogEntry = DialogInfo.DialogEntry
export type DialogSequence = DialogInfo.DialogSequence


---------- Module ----------

local Module = {}


----- Module functions -----

function Module.storeDialogSequencesForPlayer(player: Player, dialogSequences: {[any]: DialogInfo.DialogSequence})
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

function Module.getIsPlayerInDialog(player: Player)
    return DialogEvents.events.dialogBindableFunction:Invoke(
        DialogEvents.eventStrings.dialogBindableFunction.getIsPlayerInDialog, player
    )
end


----- Module fields -----

Module.constants = DialogInfo.constants


---------- Return module ----------

table.freeze(Module)
return Module
