--!strict

-- Dialog Main


---------- Services ----------

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local DialogSystem = require(_Modules:WaitForChild("DialogSystem"))

local TestDialogSequence = require(script:WaitForChild("TestDialogSequence"))


---------- Local functions ----------

local onPlayerAdded


----- Player added -----

onPlayerAdded = function(player: Player)
    DialogSystem.setDialogSequenceForPlayer(player, TestDialogSequence.default)
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
