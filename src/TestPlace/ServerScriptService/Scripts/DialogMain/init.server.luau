--!strict

-- Dialog Main


---------- Services ----------

local Players = game:GetService("Players")


---------- Imports ----------

local DialogActions = require(script:WaitForChild("DialogActions"))


---------- Constants ----------

local Constants = {}

Constants.initialSequencesModule = script:GetAttribute("InitSequencesModule")
Constants.initialSequenceId = script:GetAttribute("InitSequenceId") or "start"

table.freeze(Constants)


---------- Local functions ----------

local onPlayerAdded


----- Player added -----

onPlayerAdded = function(player: Player)
    DialogActions.setPlayerStoredDialog(player, Constants.initialSequencesModule, Constants.initialSequenceId, true)
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
