--!strict

-- Dialog Source Set Up


---------- Services ----------

local CollectionService = game:GetService("CollectionService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")


---------- Imports ----------

local DialogActions = require(script.Parent:WaitForChild("DialogActions"))

local _Modules = ReplicatedStorage:WaitForChild("DevModules")
local ContainerEvent = require(_Modules:WaitForChild("ContainerEvent"))


---------- Types ----------

type DialogSourceConfig = {
    sequencesModule: string,
    startSequenceId: string,
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

local getConfigFromConfigInstance
local setUpDialogEvent
local onObjectTagged

local onObjectRemoved
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


----- Tagged objects -----

getConfigFromConfigInstance = function(configInstance: Instance): DialogSourceConfig
    local result = {
        sequencesModule = tostring(getAttributeAssertType(configInstance, "SequencesModule", "string")) or "",
        startSequenceId = tostring(getAttributeAssertType(configInstance, "StartSequenceId", "string")) or "",
    }
    return result
end

setUpDialogEvent = function(config: DialogSourceConfig, configContainer: Instance)
    local eventTable = ContainerEvent.getEventSignalTableFromContainer(configContainer, 5)
    if eventTable then
        if Globals.container_playerInteractedConnection[configContainer] then
            Globals.container_playerInteractedConnection[configContainer]:Disconnect()
        end
        Globals.container_playerInteractedConnection[configContainer] = (
            eventTable.playerInteracted:Connect(function(player: Player)
                DialogActions.setPlayerStoredDialog(player, config.sequencesModule, config.startSequenceId, false)
            end)
        )
    else
        warn(`[Dialog Main]: Signal table not found!`)
    end
end

onObjectTagged = function(object: Instance)
    -- Validate parent container
    local configContainer = object.Parent
    if not configContainer then
        warn(`[Dialog Main]: Unable to find parent container for config instance '{object}'.`)
        return
    end

    -- Clean up existing container
    if Globals.configInstance_container[object] then
        cleanUpContainer(Globals.configInstance_container[object])
    end
    Globals.configInstance_container[object] = configContainer

    -- Get config
    local config = getConfigFromConfigInstance(object)

    -- Dialog event
    task.defer(setUpDialogEvent, config, configContainer)

    -- Parent changed
    if Globals.configInstance_parentChangedConnection[object] then
        Globals.configInstance_parentChangedConnection[object]:Disconnect()
    end
    Globals.configInstance_parentChangedConnection[object] = (
        object:GetPropertyChangedSignal("Parent"):Connect(function()
            cleanUpContainer(configContainer)
            configContainer = object.Parent
            if configContainer then
                setUpDialogEvent(config, configContainer)
            end
        end)
    )
end


----- Removed objects -----

onObjectRemoved = function(object: Instance)
    local configContainer = Globals.configInstance_container[object]
    if configContainer then
        cleanUpContainer(configContainer)
    end
    Globals.configInstance_container[object] = nil
    if Globals.configInstance_parentChangedConnection[object] then
        Globals.configInstance_parentChangedConnection[object]:Disconnect()
    end
    Globals.configInstance_parentChangedConnection[object] = nil
end

cleanUpContainer = function(container: Instance)
    -- Disconnect player interaction
    if Globals.container_playerInteractedConnection[container] then
        Globals.container_playerInteractedConnection[container]:Disconnect()
    end
    Globals.container_playerInteractedConnection[container] = nil
end


----- Tagged -----

setUpTaggedObjects = function()
    local initialTagged = CollectionService:GetTagged(Constants.dialogSourceConfigTagName)
    task.defer(function()
        for _, object in initialTagged do
            task.defer(onObjectTagged, object)
        end
    end)
    CollectionService:GetInstanceAddedSignal(Constants.dialogSourceConfigTagName):Connect(onObjectTagged)
    CollectionService:GetInstanceRemovedSignal(Constants.dialogSourceConfigTagName):Connect(onObjectRemoved)
end


---------- Module ----------

local Module = {}


----- Module fields -----

Module.setUpTaggedObjects = setUpTaggedObjects


---------- Return module ----------

table.freeze(Module)
return Module
