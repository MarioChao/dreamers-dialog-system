--!strict

-- Dialog Main Client


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local Types = require(script.Parent.Types)
local DialogEvents = require(script.Parent:WaitForChild("DialogEvents"))


---------- Globals ----------

local Globals = {}

Globals.player_connected = {} :: {[Player]: boolean}
Globals.player_dialogSequence = {} :: {[Player]: Types.DialogSequence}
Globals.player_sequenceId_sequence = {} :: {[Player]: {[string]: Types.DialogSequence}}


---------- Local functions ----------

local connectDialogEvents
local onSetDialogSequenceForPlayer
local waitForPlayerConnected
local showDialogEntryForPlayer
local clearDialogForPlayer
local getPlayerDialogSequence
local onPlayerChooseOption
local onPlayerNextDialog


----- Connect events -----

connectDialogEvents = function()
    -- Listen for client dialog events
    DialogEvents.events.dialogRemoteEvent.OnServerEvent:Connect(function(player: Player, mode: string, ...)
        if mode == DialogEvents.eventStrings.dialogRemote.toServer.connectPlayer then
            Globals.player_connected[player] = true
        elseif mode == DialogEvents.eventStrings.dialogRemote.toServer.chooseOption then
            onPlayerChooseOption(player, ...)
        elseif mode == DialogEvents.eventStrings.dialogRemote.toServer.nextDialog then
            onPlayerNextDialog(player, ...)
        end
    end)

    -- Listen for server dialog events
    DialogEvents.events.dialogBindableEvent.Event:Connect(function(mode: string, ...)
        if mode == DialogEvents.eventStrings.dialogBindable.setDialogSequenceForPlayer then
            onSetDialogSequenceForPlayer(...)
        end
    end)
end


----- Dialog -----

onSetDialogSequenceForPlayer = function(player: Player, dialogSequence: Types.DialogSequence, notNew: boolean?)
    assert(player and player:IsA("Player"), "[Dialog System]: setDialogForPlayer called with invalid player.")
    assert(dialogSequence, "[Dialog System]: Missing dialogSequence.")
    assert(dialogSequence.sequenceId, "[Dialog System]: Missing sequenceId.")

    Globals.player_dialogSequence[player] = dialogSequence
    if not notNew then
        Globals.player_sequenceId_sequence[player] = {}
    end
    Globals.player_sequenceId_sequence[player][dialogSequence.sequenceId] = dialogSequence
    showDialogEntryForPlayer(player, dialogSequence.entry)
end

waitForPlayerConnected = function(player: Player)
    local startTime = time()
    while not Globals.player_connected[player] do
        task.wait()
        if time() - startTime > 10 then
            break
        end
    end
end

showDialogEntryForPlayer = function(player: Player, dialogEntry: Types.DialogEntry)
    waitForPlayerConnected(player)
    if Globals.player_connected[player] then
        DialogEvents.events.dialogRemoteEvent:FireClient(
            player, DialogEvents.eventStrings.dialogRemote.toClient.showDialogEntry, dialogEntry
        )
    end
end

clearDialogForPlayer = function(player: Player)
    waitForPlayerConnected(player)
    if Globals.player_connected[player] then
        DialogEvents.events.dialogRemoteEvent:FireClient(
            player, DialogEvents.eventStrings.dialogRemote.toClient.clearDialogEntry
        )
    end
end

getPlayerDialogSequence = function(player: Player, sequenceRaw: (Types.DialogSequence | Types.PreviousDialogSequenceId)?)
    local result: Types.DialogSequence?
    if sequenceRaw == nil then
        result = nil
    elseif typeof(sequenceRaw) == "string" then
        result = Globals.player_sequenceId_sequence[player][sequenceRaw]
    else
        result = sequenceRaw
    end
    return result
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

    local newSequenceRaw = dialogSequence.optionId_sequence and dialogSequence.optionId_sequence[optionId]
    local newSequence = getPlayerDialogSequence(player, newSequenceRaw)
    if newSequence then
        onSetDialogSequenceForPlayer(player, newSequence, true)
    else
        clearDialogForPlayer(player)
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

    local newSequenceRaw = dialogSequence.nextSequence
    local newSequence = getPlayerDialogSequence(player, newSequenceRaw)
    if newSequence then
        onSetDialogSequenceForPlayer(player, newSequence, true)
    else
        clearDialogForPlayer(player)
    end
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
