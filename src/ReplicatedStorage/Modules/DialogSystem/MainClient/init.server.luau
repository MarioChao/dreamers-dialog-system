--!strict

-- Dialog Main Client


---------- Services ----------

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")


---------- Imports ----------

local DialogTypes = require(script.Parent:WaitForChild("DialogTypes"))
local DialogEvents = require(script.Parent:WaitForChild("DialogEvents"))

local UIUtil = require(script.Parent.Parent:WaitForChild("UIUtil"))


---------- Constants ----------

local Constants = {}

Constants.localPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
Constants.playerGui = Constants.localPlayer.PlayerGui

Constants.defaultCharSpeed = 48
Constants.fadeTweenInfo = TweenInfo.new(0.6)

Constants.defaultDialogScreenGui = script.Parent:WaitForChild("Dialog_ScreenGui")

do
    local screenUIs = {}
    screenUIs.screenGui = (function()
        local result
        local foundChild = Constants.playerGui:FindFirstChild("Dialog_ScreenGui")
        if foundChild then
            result = foundChild :: typeof(Constants.defaultDialogScreenGui)
        else
            result = Constants.defaultDialogScreenGui:Clone()
            result.Parent = Constants.playerGui
        end
        return result
    end)()
    screenUIs.screenGui.Enabled = false

    screenUIs.character_frame = screenUIs.screenGui:WaitForChild("Character_Frame")
    screenUIs.center_imageLabel = screenUIs.character_frame:WaitForChild("Center_ImageLabel")
    screenUIs.left_imageLabel = screenUIs.character_frame:WaitForChild("Left_ImageLabel")
    screenUIs.right_imageLabel = screenUIs.character_frame:WaitForChild("Right_ImageLabel")

    screenUIs.options_frame = screenUIs.screenGui:WaitForChild("Options_Frame")
    screenUIs.defaultOption_textButton = screenUIs.options_frame:WaitForChild("DefaultOption_TextButton")
    screenUIs.defaultOption_textButton.Visible = false
    screenUIs.defaultOption_textButton.Parent = nil
    screenUIs.optionText_textLabel = screenUIs.defaultOption_textButton:WaitForChild("Text_TextLabel")

    screenUIs.entryButton = screenUIs.screenGui:WaitForChild("Entry_Button")
    screenUIs.speaker_textLabel = screenUIs.entryButton:WaitForChild("Speaker_TextLabel")
    screenUIs.dialogText_textLabel = screenUIs.entryButton:WaitForChild("Text_TextLabel")
    screenUIs.nextIndicator_textLabel = screenUIs.entryButton:WaitForChild("NextIndicator_TextLabel")

    screenUIs.backgroundUIGradients = {
        screenUIs.defaultOption_textButton:WaitForChild("UIGradient"),
        screenUIs.entryButton:WaitForChild("UIGradient"),
    }
    screenUIs.containerUIStrokes = {
        screenUIs.defaultOption_textButton:WaitForChild("UIStroke"),
        screenUIs.entryButton:WaitForChild("UIStroke"),
    }
    screenUIs.textUIStrokes = {
        screenUIs.optionText_textLabel:WaitForChild("UIStroke"),
        screenUIs.speaker_textLabel:WaitForChild("UIStroke"),
        screenUIs.dialogText_textLabel:WaitForChild("UIStroke"),
        screenUIs.nextIndicator_textLabel:WaitForChild("UIStroke"),
    }
    screenUIs.textLabels = {
        screenUIs.optionText_textLabel,
        screenUIs.speaker_textLabel,
        screenUIs.dialogText_textLabel,
        screenUIs.nextIndicator_textLabel,
    }

    screenUIs.defaultGuiStyles = {
        backgroundColor = ColorSequence.new({
            ColorSequenceKeypoint.new(0, Color3.fromHex("#ffffff")),
            ColorSequenceKeypoint.new(1, Color3.fromHex("#e9eaec"))
        }),
        borderStrokeColor = Color3.new(0, 0, 0),
        textColor = Color3.new(0, 0, 0),
        textFont = Font.fromEnum(Enum.Font.Ubuntu),
        textStrokeColor = Color3.new(1, 1, 1),
    }

    Constants.dialogUIs = screenUIs
end

local function deepFreeze(t: {any}?)
    if type(t) == "table" then
        table.freeze(t)
        for _, v in t do
            deepFreeze(v :: {any}?)
        end
    end
end
deepFreeze(Constants)


---------- Globals ----------

local Globals = {}

Globals.optionTextButtons = {} :: {typeof(Constants.dialogUIs.defaultOption_textButton)}
Globals.isEntryButtonClicked = false
Globals.charSpeed = Constants.defaultCharSpeed

Globals.isPreviousFadeInProgress = false


---------- Local functions ----------

local connectDialogEvents
local connectButtonEvents

local onQueryNextSequence
local onClearDialogEntry
local onShowDialogEntry
local setEmptyDialog
local clearPreviousDialog
local waitSkippable
local applyDialogGuiStyle
local preloadDialogImageData
local applyDialogImageData
local applyDialogIndividualImageData
local applyDialogTextData
local applyUIFade
local applyDialogOptionsData

local writeText


----- Connect events -----

connectDialogEvents = function()
    -- Fire player connected event
    DialogEvents.events.dialogRemoteEvent:FireServer(DialogEvents.eventStrings.dialogRemote.toServer.connectPlayer)

    -- Listen for dialog events
    DialogEvents.events.dialogRemoteEvent.OnClientEvent:Connect(function(mode: string, ...)
        if mode == DialogEvents.eventStrings.dialogRemote.toClient.showDialogEntry then
            -- Show the dialog entry
            onShowDialogEntry(...)
        elseif mode == DialogEvents.eventStrings.dialogRemote.toClient.clearDialogEntry then
            -- Clear the dialog entry
            onClearDialogEntry()
        end
    end)
end

connectButtonEvents = function()
    Constants.dialogUIs.entryButton.MouseButton1Click:Connect(function()
        Globals.isEntryButtonClicked = true
    end)
end


----- Dialog -----

onQueryNextSequence = function()
    Globals.isPreviousFadeInProgress = true
    task.defer(function()
        applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, false, {useFade = true, willWait = false})
        applyUIFade(Constants.dialogUIs.options_frame, false, {useFade = true, willWait = false})
        applyUIFade(Constants.dialogUIs.dialogText_textLabel, false, {useFade = true, willWait = true})
        Globals.isPreviousFadeInProgress = false
    end)
end

onClearDialogEntry = function()
    clearPreviousDialog()
    applyUIFade(Constants.dialogUIs.screenGui, false, {useFade = true, willWait = true})
    Constants.dialogUIs.screenGui.Enabled = false
end

onShowDialogEntry = function(dialogEntry: DialogTypes.DialogEntry)
    -- Preload content
    preloadDialogImageData(dialogEntry.imageData or {})

    -- Wait for previous fade to finish
    while Globals.isPreviousFadeInProgress do
        task.wait()
    end

    -- Prepare for dialog entry
    clearPreviousDialog()
    if Constants.dialogUIs.screenGui.Enabled == false then
        applyUIFade(Constants.dialogUIs.screenGui, false, {useFade = false, willWait = false})
        setEmptyDialog()
        Constants.dialogUIs.screenGui.Enabled = true
        applyUIFade(Constants.dialogUIs.screenGui, true, {useFade = true, willWait = false})
    end

    -- Show dialog entry
    Globals.isEntryButtonClicked = false
    applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, false, {useFade = false, willWait = false})
    applyDialogGuiStyle(dialogEntry.dialogGuiStyle or {})
    applyDialogImageData(dialogEntry.imageData or {})
    applyDialogTextData(dialogEntry.textData)

    -- Check options
    if dialogEntry.options == nil or next(dialogEntry.options) == nil then
        --[[ Proceed to next sequence if no option ]]

        -- Wait for player click
        applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, true, {useFade = true, willWait = false})
        Globals.isEntryButtonClicked = false
        while not Globals.isEntryButtonClicked do
            task.wait()
        end

        -- Query next sequence
        onQueryNextSequence()
        DialogEvents.events.dialogRemoteEvent:FireServer(DialogEvents.eventStrings.dialogRemote.toServer.nextDialog)
    else
        -- Apply options
        applyUIFade(Constants.dialogUIs.options_frame, true, {useFade = false, willWait = false})
        applyDialogOptionsData(dialogEntry.options)
    end
end

setEmptyDialog = function()
    clearPreviousDialog()
    Constants.dialogUIs.speaker_textLabel.Text = ""
    Constants.dialogUIs.dialogText_textLabel.Text = ""
    applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, false, {useFade = false, willWait = false})
end

clearPreviousDialog = function()
    for _, textButton in Globals.optionTextButtons do
        textButton:Destroy()
    end
    table.clear(Globals.optionTextButtons)
end

waitSkippable = function(waitTime: number)
    local startTime = time()
    while not Globals.isEntryButtonClicked do
        if time() - startTime > waitTime then
            break
        end
        task.wait()
    end
end

applyDialogGuiStyle = function(guiStyle: DialogTypes.DialogGuiStyle)
    for _, uiGradient in Constants.dialogUIs.backgroundUIGradients do
        uiGradient.Color = guiStyle.backgroundColor or Constants.dialogUIs.defaultGuiStyles.backgroundColor
    end

    for _, uiStroke in Constants.dialogUIs.containerUIStrokes do
        uiStroke.Color = guiStyle.borderStrokeColor or Constants.dialogUIs.defaultGuiStyles.borderStrokeColor
    end

    for _, uiStroke in Constants.dialogUIs.textUIStrokes do
        uiStroke.Color = guiStyle.textStrokeColor or Constants.dialogUIs.defaultGuiStyles.textStrokeColor
    end

    for _, textLabel in Constants.dialogUIs.textLabels do
        textLabel.TextColor3 = guiStyle.textColor or Constants.dialogUIs.defaultGuiStyles.textColor
        textLabel.FontFace = guiStyle.textFont or Constants.dialogUIs.defaultGuiStyles.textFont
    end
end

preloadDialogImageData = function(imageData: DialogTypes.DialogImageData)
    local imageLabels = {}

    -- Get images
    local function addImage(imageData: DialogTypes.DialogIndividualImageData)
        if imageData.imageId then
            local imageId = imageData.imageId
            local imageLabel = Instance.new("ImageLabel")
            imageLabel.Image = imageId
            table.insert(imageLabels, imageLabel)
        end
    end
    addImage(imageData.centerImage or {})
    addImage(imageData.leftImage or {})
    addImage(imageData.rightImage or {})

    -- Preload images
    task.defer(function()
        ContentProvider:PreloadAsync(imageLabels)
    end)
end

applyDialogImageData = function(imageData: DialogTypes.DialogImageData)
    applyDialogIndividualImageData(Constants.dialogUIs.center_imageLabel, imageData.centerImage or {})
    applyDialogIndividualImageData(Constants.dialogUIs.left_imageLabel, imageData.leftImage or {})
    applyDialogIndividualImageData(Constants.dialogUIs.right_imageLabel, imageData.rightImage or {})
end

applyDialogIndividualImageData = function(imageLabel: ImageLabel, imageData: DialogTypes.DialogIndividualImageData)
    imageLabel.Image = imageData.imageId or ""
    imageLabel.Size = imageData.size or UDim2.new(1, 0, 1, 0)
end

applyDialogTextData = function(textData: DialogTypes.DialogTextData)
    -- Get info
    local lastSpeakerName = Constants.dialogUIs.speaker_textLabel.Text
    local targetSpeakerName = textData.speakerName or lastSpeakerName
    local targetDialogText = textData.dialogText
    Globals.charSpeed = textData.charSpeed or Constants.defaultCharSpeed

    -- Write speaker name if needed
    Constants.dialogUIs.dialogText_textLabel.Text = ""
    if lastSpeakerName ~= targetSpeakerName then
        if lastSpeakerName ~= "" then
            applyUIFade(Constants.dialogUIs.speaker_textLabel, false, {useFade = true, willWait = true, skippable = true})
            Constants.dialogUIs.speaker_textLabel.Text = ""
            task.wait()
            applyUIFade(Constants.dialogUIs.speaker_textLabel, true, {useFade = false, willWait = false})
        end
        writeText(Constants.dialogUIs.speaker_textLabel, targetSpeakerName, Globals.charSpeed, true)
        waitSkippable(0.5)
    end

    -- Write dialog text
    task.wait()
    applyUIFade(Constants.dialogUIs.dialogText_textLabel, true, {useFade = false, willWait = false})
    writeText(Constants.dialogUIs.dialogText_textLabel, targetDialogText, Globals.charSpeed, true)
    task.wait(0.5)
end

applyUIFade = function(container: Instance, isVisible: boolean, fadeData: {useFade: boolean?, willWait: boolean?, skippable: boolean?})
    if fadeData.useFade then
        if fadeData.willWait then
            if fadeData.skippable then
                UIUtil.fade(container, Constants.fadeTweenInfo, isVisible, false)
                waitSkippable(Constants.fadeTweenInfo.Time + Constants.fadeTweenInfo.DelayTime)
            else
                UIUtil.fade(container, Constants.fadeTweenInfo, isVisible, true)
            end
        else
            UIUtil.fade(container, Constants.fadeTweenInfo, isVisible, false)
        end
    else
        if isVisible then
            UIUtil.resetTransparency(container)
        else
            UIUtil.setTransparency(container, 1)
        end
    end
end

applyDialogOptionsData = function(optionsData: {DialogTypes.DialogOptionData})
    local optionCount = 0
    local optionId_info = {} :: {[string]: {
        textLabel: TextLabel,
        text: string,
    }}
    for _, option in optionsData do
        optionCount += 1
        local newOption_textButton = Constants.dialogUIs.defaultOption_textButton:Clone()
        newOption_textButton.LayoutOrder = optionCount
        newOption_textButton.Visible = true
        newOption_textButton.MouseButton1Click:Connect(function()
            onQueryNextSequence()
            DialogEvents.events.dialogRemoteEvent:FireServer(
                DialogEvents.eventStrings.dialogRemote.toServer.chooseOption, option.id
            )
        end)

        local optionText_textLabel = newOption_textButton:WaitForChild("Text_TextLabel")
        optionText_textLabel.Text = ""
        optionId_info[option.id] = {
            textLabel = optionText_textLabel,
            text = option.text
        }

        applyUIFade(newOption_textButton, false, {useFade = false, willWait = false})
        applyUIFade(newOption_textButton, true, {useFade = true, willWait = false})
        table.insert(Globals.optionTextButtons, newOption_textButton)
        newOption_textButton.Parent = Constants.dialogUIs.options_frame
    end

    for _, optionInfo in optionId_info do
        task.defer(function()
            writeText(optionInfo.textLabel, optionInfo.text, Globals.charSpeed, false)
        end)
    end
end


----- Transition -----

writeText = function(textInstance: Instance, text: string, charSpeed: number, skippable: boolean)
    if textInstance:IsA("TextBox") or textInstance:IsA("TextButton") or textInstance:IsA("TextLabel") then
        local tempInstance = textInstance :: TextLabel
        tempInstance.Text = ""

        local typedMessage = ""
        local typedCharCount = 0
        local messageLength = string.len(text)
        local startTime = time()
        while true do
            if skippable and Globals.isEntryButtonClicked then
                break
            end
            while typedCharCount >= (time() - startTime) * charSpeed do
                if skippable and Globals.isEntryButtonClicked then
                    break
                end
                task.wait()
            end
            typedCharCount += 1
            if typedCharCount >= messageLength then
                break
            end
            typedMessage ..= string.sub(text, typedCharCount, typedCharCount)
            tempInstance.Text = typedMessage
        end
        tempInstance.Text = text
    end
end


----- Main -----

local function main()
    connectDialogEvents()
    connectButtonEvents()
end


---------- Calling function ----------

main()
