--!strict

-- Dialog Main Client


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local _DialogSystem = script.Parent
local DialogEvents = require(_DialogSystem:WaitForChild("DialogEvents"))
local DialogInfo = require(_DialogSystem:WaitForChild("DialogInfo"))

local _Modules = _DialogSystem.Parent
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))


---------- Globals ----------

local Globals = {}

Globals.player_dialogSequence = {} :: {[Player]: DialogInfo.DialogSequence?}
Globals.player_sequenceId_sequence = {} :: {[Player]: {[string]: DialogInfo.DialogSequence?}?}
Globals.player_isInDialog = {} :: {[Player]: true?}


---------- Local functions ----------

local connectDialogEvents

local getOrCreatePlayerInfo_sequenceId_sequence

local onStoreDialogSequencesForPlayer
local onSetDialogSequenceIdForPlayer
local getPlayerDialogSequence
local showDialogEntryForPlayer
local clearDialogForPlayer
local onPlayerChooseOption
local onPlayerNextDialog

local onDialogBindableFunctionInvoke
local getIsPlayerInDialog


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

    -- Set server dialog invokes
    DialogEvents.events.dialogBindableFunction.OnInvoke = onDialogBindableFunctionInvoke
end


----- Player info -----

getOrCreatePlayerInfo_sequenceId_sequence = function(player: Player)
    local value = Globals.player_sequenceId_sequence[player]
    local result
    if value then
        result = value
    else
        result = {}
        Globals.player_sequenceId_sequence[player] = result
    end
    return result
end


----- Dialog -----

onStoreDialogSequencesForPlayer = function(player: Player, dialogSequences: {[any]: DialogInfo.DialogSequence})
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")
    local sequenceId_sequence = getOrCreatePlayerInfo_sequenceId_sequence(player)
    table.clear(sequenceId_sequence)
    for _, dialogSequence in dialogSequences do
        assert(dialogSequence.sequenceId, "[Dialog System]: Missing sequenceId.")
        if not (dialogSequence.nextSequenceId or dialogSequence.optionId_sequenceId) then
            warn(
                `[Dialog System]: Missing next sequence id or option sequence ids for ` ..
                `dialog sequence {dialogSequence.sequenceId}.`
            )
        end
        sequenceId_sequence[dialogSequence.sequenceId] = dialogSequence
    end
end

getPlayerDialogSequence = function(player: Player, sequenceId: string)
    local result: DialogInfo.DialogSequence?
    if sequenceId == nil then
        result = nil
    elseif typeof(sequenceId) == "string" then
        if Globals.player_sequenceId_sequence[player] then
            local sequenceId_sequence = getOrCreatePlayerInfo_sequenceId_sequence(player)
            result = sequenceId_sequence[sequenceId]
        end
    end
    return result
end

onSetDialogSequenceIdForPlayer = function(player: Player, dialogSequenceId: string, notNew: boolean?)
    assert(player and player:IsA("Player"), "[Dialog System]: invalid player.")

    if dialogSequenceId == DialogInfo.constants.CLOSE_SEQUENCE_ID then
        clearDialogForPlayer(player)
        return
    end

    local dialogSequence = getPlayerDialogSequence(player, dialogSequenceId)
    assert(dialogSequence, `[Dialog System]: No dialog sequence with id {dialogSequenceId} found for {player.Name}!`)

    Globals.player_dialogSequence[player] = dialogSequence
    showDialogEntryForPlayer(player, dialogSequence.entry)
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

    local nextSequenceId = dialogSequence.nextSequenceId or DialogInfo.constants.CLOSE_SEQUENCE_ID
    onSetDialogSequenceIdForPlayer(player, nextSequenceId)
end


----- Dialog invoke -----

onDialogBindableFunctionInvoke = function(mode: string, ...): any
    if mode == DialogEvents.eventStrings.dialogBindableFunction.getIsPlayerInDialog then
        return getIsPlayerInDialog(...)
    end
    return nil
end

getIsPlayerInDialog = function(player: Player): boolean
    return Globals.player_isInDialog[player] == true
end


----- Main -----

local function main()
    connectDialogEvents()
    Players.PlayerRemoving:Connect(function(player: Player)
        Globals.player_dialogSequence[player] = nil
        Globals.player_sequenceId_sequence[player] = nil
        Globals.player_isInDialog[player] = nil
    end)
end


---------- Calling function ----------

main()
