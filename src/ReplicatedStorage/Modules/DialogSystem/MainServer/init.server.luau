--!strict

-- Dialog Main Client


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DialogConstants = require(script.Parent.DialogConstants)
local DialogTypes = require(script.Parent.DialogTypes)
local DialogEvents = require(script.Parent:WaitForChild("DialogEvents"))

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))


---------- Globals ----------

local Globals = {}

Globals.player_connected = {} :: {[Player]: boolean}
Globals.player_dialogSequence = {} :: {[Player]: DialogTypes.DialogSequence}
Globals.player_sequenceId_sequence = {} :: {[Player]: {[string]: DialogTypes.DialogSequence}}


---------- Local functions ----------

local connectDialogEvents
local onStoreDialogSequencesForPlayer
local onSetDialogSequenceIdForPlayer
local getPlayerDialogSequence
local showDialogEntryForPlayer
local clearDialogForPlayer
local onPlayerChooseOption
local onPlayerNextDialog


----- Connect events -----

connectDialogEvents = function()
    -- Listen for client dialog events
    BelovedRemote.connect_toServer(DialogEvents.remoteActions.toServer.chooseOption, onPlayerChooseOption)
    BelovedRemote.connect_toServer(DialogEvents.remoteActions.toServer.nextDialog, onPlayerNextDialog)

    -- Listen for server dialog events
    DialogEvents.events.dialogBindableEvent.Event:Connect(function(mode: string, ...)
        if mode == DialogEvents.eventStrings.dialogBindable.storeDialogSequencesForPlayer then
            onStoreDialogSequencesForPlayer(...)
        elseif mode == DialogEvents.eventStrings.dialogBindable.setDialogSequenceIdForPlayer then
            onSetDialogSequenceIdForPlayer(...)
        end
    end)
end


----- Dialog -----

onStoreDialogSequencesForPlayer = function(player: Player, dialogSequences: {[any]: DialogTypes.DialogSequence})
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")
    for _, dialogSequence in dialogSequences do
        assert(dialogSequence.sequenceId, "[Dialog System]: Missing sequenceId.")
        if not (dialogSequence.nextSequenceId or dialogSequence.optionId_sequenceId) then
            warn(
                `[Dialog System]: Missing next sequence id or option sequence ids for ` ..
                `dialog sequence {dialogSequence.sequenceId}.`
            )
        end
        if not Globals.player_sequenceId_sequence[player] then
            Globals.player_sequenceId_sequence[player] = {}
        end
        Globals.player_sequenceId_sequence[player][dialogSequence.sequenceId] = dialogSequence
    end
end

getPlayerDialogSequence = function(player: Player, sequenceId: string)
    local result: DialogTypes.DialogSequence?
    if sequenceId == nil then
        result = nil
    elseif typeof(sequenceId) == "string" then
        if Globals.player_sequenceId_sequence[player] then
            result = Globals.player_sequenceId_sequence[player][sequenceId]
        end
    end
    return result
end

onSetDialogSequenceIdForPlayer = function(player: Player, dialogSequenceId: string, notNew: boolean?)
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")

    if dialogSequenceId == DialogConstants.CLOSE_SEQUENCE_ID then
        clearDialogForPlayer(player)
        return
    end

    local dialogSequence = getPlayerDialogSequence(player, dialogSequenceId)
    assert(dialogSequence, `[Dialog System]: No dialog sequence with id {dialogSequenceId} found for {player.Name}!`)

    Globals.player_dialogSequence[player] = dialogSequence
    showDialogEntryForPlayer(player, dialogSequence.entry)
end

showDialogEntryForPlayer = function(player: Player, dialogEntry: DialogTypes.DialogEntry)
    BelovedRemote.fire_toClient(DialogEvents.remoteActions.toClient.showDialogEntry, player, dialogEntry)
end

clearDialogForPlayer = function(player: Player)
    BelovedRemote.fire_toClient(DialogEvents.remoteActions.toClient.clearDialogEntry, player)
end

onPlayerChooseOption = function(player: Player, optionId: string)
    local dialogSequence = Globals.player_dialogSequence[player]
    assert(dialogSequence ~= nil, `[Dialog System]: No dialog sequence found for player {player.Name}!`)

    local callback = dialogSequence.optionId_callback and dialogSequence.optionId_callback[optionId]
    if callback and typeof(callback) == "function" then
        local success = pcall(callback)
        if not success then
            warn(
                `[Dialog System]: Callback errored for option {optionId} of dialog {dialogSequence.sequenceId} ` ..
                `for {player.Name}!`
            )
        end
    end

    local nextSequenceId = dialogSequence.optionId_sequenceId and dialogSequence.optionId_sequenceId[optionId]
    if nextSequenceId then
        onSetDialogSequenceIdForPlayer(player, nextSequenceId)
    end
end

onPlayerNextDialog = function(player: Player)
    local dialogSequence = Globals.player_dialogSequence[player]
    assert(dialogSequence ~= nil, `[Dialog System]: No dialog sequence found for player {player.Name}!`)

    local callback = dialogSequence.nextSequenceCallback
    if callback and typeof(callback) == "function" then
        local success = pcall(callback)
        if not success then
            warn(
                `[Dialog System]: Callback errored for next sequence of dialog {dialogSequence.sequenceId} ` ..
                `for {player.Name}!`
            )
        end
    end

    local nextSequenceId = dialogSequence.nextSequenceId or DialogConstants.CLOSE_SEQUENCE_ID
    onSetDialogSequenceIdForPlayer(player, nextSequenceId)
end


----- Main -----

local function main()
    connectDialogEvents()
    Players.PlayerRemoving:Connect(function(player: Player)
        Globals.player_connected[player] = nil
    end)
end


---------- Calling function ----------

main()
