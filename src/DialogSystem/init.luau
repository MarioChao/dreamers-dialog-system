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
export type DialogNode = DialogInfo.DialogNode


---------- Module ----------

local Module = {}


----- Module functions -----

function Module.storeDialogNodesForPlayer(player: Player, dialogNodes: {[any]: DialogInfo.DialogNode})
    MainServer.storeDialogNodesForPlayer(player, dialogNodes)
end

function Module.setDialogNodeIdForPlayer(player: Player, dialogNodeId: string)
    MainServer.setDialogNodeIdForPlayer(player, dialogNodeId)
end

function Module.getIsPlayerInDialog(player: Player)
    return MainServer.getIsPlayerInDialog(player)
end


----- Module fields -----

Module.constants = DialogInfo.constants


---------- Return module ----------

table.freeze(Module)
return Module
