--!strict

-- Dialog Main


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local DialogSystem = require(_Modules:WaitForChild("DialogSystem"))

local _DialogStorage = script.Parent.Parent:WaitForChild("DialogStorage")


---------- Constants ----------

local Constants = {}

Constants.initialSequencesModule = script:GetAttribute("InitSequencesModule")
Constants.initialSequenceId = script:GetAttribute("InitSequenceId") or "start"

table.freeze(Constants)


---------- Local functions ----------

local setPlayerDialog
local onPlayerAdded


----- Set dialog -----

setPlayerDialog = function(player: Player, dialogSequences: {DialogSystem.DialogSequence}, startId: string)
    DialogSystem.storeDialogSequencesForPlayer(player, dialogSequences)
    DialogSystem.setDialogSequenceIdForPlayer(player, startId)
end


----- Player added -----

onPlayerAdded = function(player: Player)
    local _InitialSequences = _DialogStorage:FindFirstChild(Constants.initialSequencesModule)
    if _InitialSequences then
        local InitialSequences = require(_InitialSequences) :: {DialogSystem.DialogSequence}
        setPlayerDialog(player, InitialSequences, Constants.initialSequenceId)
    end
end


----- Main -----

local function main()
    local initialPlayers = Players:GetPlayers()
    task.defer(function()
        for _, player in initialPlayers do
            task.defer(onPlayerAdded, player)
        end
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
end


---------- Calling function ----------

main()
