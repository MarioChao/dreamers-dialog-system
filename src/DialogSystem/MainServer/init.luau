--!strict

-- Dialog Main Server


---------- Services ----------

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")


---------- Imports ----------

local _DialogSystem = script.Parent
local DialogEvents = require(_DialogSystem:WaitForChild("DialogEvents"))
local DialogInfo = require(_DialogSystem:WaitForChild("DialogInfo"))

local _Modules = _DialogSystem.Parent
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))


---------- Globals ----------

local Globals = {}

Globals.player_dialogNode = {} :: {[Player]: DialogInfo.DialogNode?}
Globals.player_nodeId_node = {} :: {[Player]: {[string]: DialogInfo.DialogNode?}?}
Globals.player_isInDialog = {} :: {[Player]: true?}


---------- Local functions ----------

local connectDialogEvents

local getOrCreatePlayerInfo_nodeId_node

local onStoreDialogNodesForPlayer
local onSetDialogNodeIdForPlayer
local getPlayerDialogNode
local showDialogEntryForPlayer
local clearDialogForPlayer
local onPlayerChooseOption
local onPlayerNextDialog

local getIsPlayerInDialog


----- Connect events -----

connectDialogEvents = function()
    -- Listen for client dialog events
    BelovedRemote.connect_toServer(DialogEvents.remoteActions.toServer.chooseOption, onPlayerChooseOption)
    BelovedRemote.connect_toServer(DialogEvents.remoteActions.toServer.nextDialog, onPlayerNextDialog)
end


----- Player info -----

getOrCreatePlayerInfo_nodeId_node = function(player: Player)
    local value = Globals.player_nodeId_node[player]
    local result
    if value then
        result = value
    else
        result = {}
        Globals.player_nodeId_node[player] = result
    end
    return result
end


----- Dialog -----

onStoreDialogNodesForPlayer = function(player: Player, dialogNodes: {[any]: DialogInfo.DialogNode})
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")
    local nodeId_node = getOrCreatePlayerInfo_nodeId_node(player)
    table.clear(nodeId_node)
    for _, dialogNode in dialogNodes do
        -- Check data
        assert(dialogNode.entry.textData.speakerName,
            `[Dialog System]: missing speaker name for dialog node '{dialogNode.nodeId}'.`)
        assert(dialogNode.entry.textData.dialogText,
            `[Dialog System]: missing dialog text for dialog node '{dialogNode.nodeId}'.`)

        -- Check & store node
        assert(dialogNode.nodeId, "[Dialog System]: Missing nodeId.")
        if not (dialogNode.nextNodeId or dialogNode.optionId_nodeId) then
            warn(
                `[Dialog System]: Missing next node id or option node ids for ` ..
                `dialog node '{dialogNode.nodeId}'.`
            )
        end
        nodeId_node[dialogNode.nodeId] = dialogNode
    end
end

getPlayerDialogNode = function(player: Player, nodeId: string)
    local result: DialogInfo.DialogNode?
    if nodeId == nil then
        result = nil
    elseif typeof(nodeId) == "string" then
        if Globals.player_nodeId_node[player] then
            local nodeId_node = getOrCreatePlayerInfo_nodeId_node(player)
            result = nodeId_node[nodeId]
        end
    end
    return result
end

onSetDialogNodeIdForPlayer = function(player: Player, dialogNodeId: string, notNew: boolean?)
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")

    if dialogNodeId == DialogInfo.constants.CLOSE_NODE_ID then
        clearDialogForPlayer(player)
        return
    end

    local dialogNode = getPlayerDialogNode(player, dialogNodeId)
    assert(dialogNode, `[Dialog System]: No dialog node with id '{dialogNodeId}' found for player '{player.Name}'!`)

    Globals.player_dialogNode[player] = dialogNode
    showDialogEntryForPlayer(player, dialogNode.entry)
end

showDialogEntryForPlayer = function(player: Player, dialogEntry: DialogInfo.DialogEntry)
    BelovedRemote.fire_toClient(DialogEvents.remoteActions.toClient.showDialogEntry, player, dialogEntry)
    Globals.player_isInDialog[player] = true
end

clearDialogForPlayer = function(player: Player)
    BelovedRemote.fire_toClient(DialogEvents.remoteActions.toClient.clearDialogEntry, player)
    Globals.player_isInDialog[player] = nil
end

onPlayerChooseOption = function(player: Player, optionId: string)
    local dialogNode = Globals.player_dialogNode[player]
    assert(dialogNode ~= nil, `[Dialog System]: No dialog node found for player '{player.Name}'!`)

    local callback = dialogNode.optionId_callback and dialogNode.optionId_callback[optionId]
    if callback and typeof(callback) == "function" then
        local success = pcall(callback)
        if not success then
            warn(
                `[Dialog System]: Callback errored for option '{optionId}' of dialog '{dialogNode.nodeId}' ` ..
                `for player '{player.Name}'!`
            )
        end
    end

    local nextNodeId = dialogNode.optionId_nodeId and dialogNode.optionId_nodeId[optionId]
    if nextNodeId then
        onSetDialogNodeIdForPlayer(player, nextNodeId)
    end
end

onPlayerNextDialog = function(player: Player)
    local dialogNode = Globals.player_dialogNode[player]
    assert(dialogNode ~= nil, `[Dialog System]: No dialog node found for player '{player.Name}'!`)

    local callback = dialogNode.nextNodeCallback
    if callback and typeof(callback) == "function" then
        local success = pcall(callback)
        if not success then
            warn(
                `[Dialog System]: Callback errored for next node of dialog '{dialogNode.nodeId}' ` ..
                `for '{player.Name}'!`
            )
        end
    end

    local nextNodeId = dialogNode.nextNodeId or DialogInfo.constants.CLOSE_NODE_ID
    onSetDialogNodeIdForPlayer(player, nextNodeId)
end


----- Dialog state -----

getIsPlayerInDialog = function(player: Player): boolean
    return Globals.player_isInDialog[player] == true
end


----- Main -----

local function main()
    if RunService:IsServer() then
        connectDialogEvents()
        Players.PlayerRemoving:Connect(function(player: Player)
            Globals.player_dialogNode[player] = nil
            Globals.player_nodeId_node[player] = nil
            Globals.player_isInDialog[player] = nil
        end)
    else
        warn("[Dialog System]: MainServer should only be required on the server!")
    end
end


---------- Calling function ----------

main()


---------- Module ----------

local Module = {}


----- Module fields -----

Module.storeDialogNodesForPlayer = onStoreDialogNodesForPlayer

Module.setDialogNodeIdForPlayer = onSetDialogNodeIdForPlayer

Module.getIsPlayerInDialog = getIsPlayerInDialog


---------- Return module ----------

table.freeze(Module)
return Module
