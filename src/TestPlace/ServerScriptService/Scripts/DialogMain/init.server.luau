--!strict

-- Dialog Main


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local DialogActions = require(script:WaitForChild("DialogActions"))
local DialogSourceSetUp = require(script:WaitForChild("DialogSourceSetUp"))


---------- Constants ----------

local Constants = {}

Constants.initialSequencesModule = script:GetAttribute("InitSequencesModule")
Constants.initialSequenceId = script:GetAttribute("InitSequenceId") or "start"

table.freeze(Constants)


---------- Local functions ----------

local onPlayerAdded
local setUpPlayerAdded


----- Player added -----

onPlayerAdded = function(player: Player)
    DialogActions.setPlayerStoredDialog(player, Constants.initialSequencesModule, Constants.initialSequenceId, true)
end

setUpPlayerAdded = function()
    local initialPlayers = Players:GetPlayers()
    task.defer(function()
        for _, player in initialPlayers do
            task.defer(onPlayerAdded, player)
        end
    end)
    Players.PlayerAdded:Connect(onPlayerAdded)
end


----- Main -----

local function main()
    setUpPlayerAdded()
    DialogSourceSetUp.setUpTaggedObjects()
end


---------- Calling function ----------

main()
