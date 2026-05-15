--!strict

-- Dialog Source Set Up


---------- Services ----------

local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DialogActions = require(script.Parent:WaitForChild("DialogActions"))

local _Modules = ReplicatedStorage:WaitForChild("DevModules")
local ContainerEvent = require(_Modules:WaitForChild("ContainerEvent"))
local ContainerMechanic = require(_Modules:WaitForChild("ContainerMechanic"))


---------- Types ----------

type DialogSourceConfig = {
    getSequencesModule: () -> string,
    getStartSequenceId: () -> string,
}


---------- Constants ----------

local Constants = {}

Constants.dialogSourceConfigTagName = "DialogSourceConfig"

table.freeze(Constants)


---------- Globals ----------

local Globals = {}

Globals.configInstance_container = {} :: {[Instance]: Instance}
Globals.configInstance_parentChangedConnection = {} :: {[Instance]: RBXScriptConnection}

Globals.container_playerInteractedConnection = {} :: {[Instance]: RBXScriptConnection}


---------- Local functions ----------

local getAttributeAssertType

local getConfigFromInstance

local setUpContainer

local cleanUpContainer

local setUpTaggedObjects


----- Attributes -----

getAttributeAssertType = function(object: Instance, attributeName: string, expectedTypeOf: string)
    local attributeValue = object:GetAttribute(attributeName)
    local actualTypeOf = typeof(attributeValue)
    if actualTypeOf ~= expectedTypeOf then
        warn(
            `[Dialog Main]: Attribute '{attributeName}' of '{object}' is type '{actualTypeOf}', ` ..
            `but expected '{expectedTypeOf}'.`
        )
    end
    return attributeValue
end


----- Get config -----

getConfigFromInstance = function(configInstance: Instance): DialogSourceConfig
    local result = {
        getSequencesModule = function()
            return tostring(getAttributeAssertType(configInstance, "SequencesModule", "string")) or ""
        end,
        getStartSequenceId = function()
            return tostring(getAttributeAssertType(configInstance, "StartSequenceId", "string")) or ""
        end,
    }
    return result
end


----- Set up -----

setUpContainer = function(container: Instance, config: DialogSourceConfig)
    local eventSignals = ContainerEvent.getEventSignalTableFromContainer(container, 5)
    if eventSignals then
        if Globals.container_playerInteractedConnection[container] then
            Globals.container_playerInteractedConnection[container]:Disconnect()
        end
        Globals.container_playerInteractedConnection[container] = (
            eventSignals.playerInteracted:Connect(function(player: Player)
                local sequencesModule = config.getSequencesModule()
                local startSequenceId = config.getStartSequenceId()
                DialogActions.setPlayerStoredDialog(player, sequencesModule, startSequenceId, false)
            end)
        )
    else
        warn(`[Dialog Main]: Event signal table not found!`)
    end
end


----- Clean up -----

cleanUpContainer = function(container: Instance)
    -- Disconnect player interaction
    if Globals.container_playerInteractedConnection[container] then
        Globals.container_playerInteractedConnection[container]:Disconnect()
    end
    Globals.container_playerInteractedConnection[container] = nil
end


----- Tagged -----

setUpTaggedObjects = function()
    local mechanic = ContainerMechanic.new(Constants.dialogSourceConfigTagName)
    mechanic:setFunction_getConfigFromInstance(getConfigFromInstance)
    mechanic:setFunction_setUpContainer(setUpContainer)
    mechanic:setFunction_cleanUpContainer(cleanUpContainer)
    mechanic:run()
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.setUpTaggedObjects = setUpTaggedObjects


---------- Return module ----------

table.freeze(Module)
return Module
