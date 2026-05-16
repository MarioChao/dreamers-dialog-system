--!strict

-- Dialog Test


---------- Services ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")
local ServerScriptService = game:GetService("ServerScriptService")


---------- Imports ----------

local _Modules = ReplicatedStorage:WaitForChild("Modules")
local DialogSystem = require(_Modules:WaitForChild("DialogSystem"))


---------- Constants ----------

local Constants = {}

Constants.proximityPrompt = script.Parent:WaitForChild("ProximityPrompt")
Constants.dialog = require(ServerScriptService.Scripts.SampleDialog)

table.freeze(Constants)


---------- Local functions ----------

local onPromptTriggered


----- Proximity prompt -----

onPromptTriggered = function(player: Player)
    if not DialogSystem.getIsPlayerInDialog(player) then
        DialogSystem.storeDialogSequencesForPlayer(player, Constants.dialog)
        DialogSystem.setDialogSequenceIdForPlayer(player, Constants.dialog.start.sequenceId)
    end
end


----- Main -----

local function main()
    Constants.proximityPrompt.Triggered:Connect(onPromptTriggered)
end


---------- Calling function ----------

main()
