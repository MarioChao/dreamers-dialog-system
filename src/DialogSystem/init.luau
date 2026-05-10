--!strict

-- Dialog System


---------- Services ----------

local RunService = game:GetService("RunService")


----- Check environment -----

if not RunService:IsServer() then
    warn("[Dialog System]: Module should only be required from the server!")
end


---------- Imports ----------

local DialogInfo = require(script:WaitForChild("DialogInfo"))
local MainServer = require(script:WaitForChild("MainServer"))


---------- Types ----------

export type DialogGuiStyle = DialogInfo.DialogGuiStyle
export type DialogEntry = DialogInfo.DialogEntry
export type DialogSequence = DialogInfo.DialogSequence


---------- Module ----------

local Module = {}


----- Module functions -----

function Module.storeDialogSequencesForPlayer(player: Player, dialogSequences: {[any]: DialogInfo.DialogSequence})
    MainServer.storeDialogSequencesForPlayer(player, dialogSequences)
end

function Module.setDialogSequenceIdForPlayer(player: Player, dialogSequenceId: string)
    MainServer.setDialogSequenceIdForPlayer(player, dialogSequenceId)
end

function Module.getIsPlayerInDialog(player: Player)
    return MainServer.getIsPlayerInDialog(player)
end


----- Module fields -----

Module.constants = DialogInfo.constants


---------- Return module ----------

table.freeze(Module)
return Module
