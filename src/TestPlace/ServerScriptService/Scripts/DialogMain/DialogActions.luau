--!strict

-- Dialog Actions


---------- Services ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local DialogSystem = require(_Modules:WaitForChild("DialogSystem"))

local _DialogStorage = script.Parent.Parent.Parent:WaitForChild("DialogStorage")


---------- Local functions ----------

local setPlayerDialog
local setPlayerStoredDialog


----- Set dialog -----

setPlayerDialog = function(player: Player, dialogSequences: {DialogSystem.DialogSequence}, startId: string)
    DialogSystem.storeDialogSequencesForPlayer(player, dialogSequences)
    DialogSystem.setDialogSequenceIdForPlayer(player, startId)
end

setPlayerStoredDialog = function(player: Player, sequencesName: string, startId: string, willOverwriteExisting: boolean)
    -- If not overwriting, check if already in dialog
    if not willOverwriteExisting and DialogSystem.getIsPlayerInDialog(player) then
        return
    end

    -- Set dialog
    local _Sequences = _DialogStorage:FindFirstChild(sequencesName)
    if _Sequences then
        local Sequences = require(_Sequences) :: {DialogSystem.DialogSequence}
        setPlayerDialog(player, Sequences, startId)
    else
        warn(`[Dialog Actions]: No dialog sequences module found with name '{sequencesName}'.`)
    end
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.setPlayerStoredDialog = setPlayerStoredDialog


---------- Return module ----------

table.freeze(Module)
return Module
