--!strict

-- Dialog Main Client


---------- Services ----------

local ContentProvider = game:GetService("ContentProvider")
local Players = game:GetService("Players")


---------- Imports ----------

local _DialogSystem = script.Parent
local DialogEvents = require(_DialogSystem:WaitForChild("DialogEvents"))
local DialogInfo = require(_DialogSystem:WaitForChild("DialogInfo"))

local _Modules = _DialogSystem.Parent
local BelovedRemote = require(_Modules:WaitForChild("BelovedRemote"))
local TextTypewriter = require(_Modules:WaitForChild("TextTypewriter"))
local UIUtil = require(_Modules:WaitForChild("UIUtil"))


---------- Constants ----------

local Constants = {}

Constants.localPlayer = Players.LocalPlayer or Players:GetPropertyChangedSignal("LocalPlayer"):Wait()
Constants.playerGui = Constants.localPlayer.PlayerGui

Constants.typingSoundsFolder = script:WaitForChild("TypingSounds")

Constants.defaultCharSpeed = 48
Constants.defaultRegex_pauseDelay = {
    ["[,]%s"] = 0.1,
    ["[,]$"] = 0.1,

    ["[%.%?!]%s"] = 0.3,
    ["[%.%?!]$"] = 0.3,

    ["%.%.%.%s"] = 0.5,
    ["%.%.%.$"] = 0.5,
} :: {[string]: number?}
Constants.defaultCharSounds = Constants.typingSoundsFolder:GetChildren()
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

Globals.typewriter = TextTypewriter.new()

Globals.isPreviousFadeInProgress = false

Globals.showDialogEntryThread = nil :: thread?
Globals.clearDialogEntryThread = nil :: thread?
Globals.optionTextThreads = {} :: {thread}


---------- Local functions ----------

local connectDialogEvents
local connectButtonEvents

local setIsEntryButtonClicked

local onQueryNextSequence
local cancelThreads
local onClearDialogEntryProxy
local onClearDialogEntry
local onShowDialogEntryProxy
local onShowDialogEntry
local setEmptyDialog
local clearPreviousDialog
local waitSkippable

local applyDialogGuiStyle
local preloadDialogImageData
local applyDialogImageData
local applyDialogIndividualImageData
local applyTypewriterData
local applyDialogTextData
local applyUIFade
local applyDialogOptionsData


----- Connect events -----

connectDialogEvents = function()
    -- Listen for dialog events
    BelovedRemote.connect_toClient(DialogEvents.remoteActions.toClient.showDialogEntry, onShowDialogEntryProxy)
    BelovedRemote.connect_toClient(DialogEvents.remoteActions.toClient.clearDialogEntry, onClearDialogEntryProxy)

    -- Connect player
    BelovedRemote.belovePlayer_RE_toServer(DialogEvents.remoteActions.toClient.showDialogEntry)
    BelovedRemote.belovePlayer_RE_toServer(DialogEvents.remoteActions.toClient.clearDialogEntry)
end

connectButtonEvents = function()
    Constants.dialogUIs.entryButton.MouseButton1Click:Connect(function()
        setIsEntryButtonClicked(true)
    end)
end


----- Entry button clicked -----

setIsEntryButtonClicked = function(isEntryButtonClicked: boolean)
    Globals.isEntryButtonClicked = isEntryButtonClicked
    Globals.typewriter:setIsSkipping(isEntryButtonClicked)
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

cancelThreads = function()
    if Globals.showDialogEntryThread then
        task.cancel(Globals.showDialogEntryThread)
        Globals.showDialogEntryThread = nil
    end
    if Globals.clearDialogEntryThread then
        task.cancel(Globals.clearDialogEntryThread)
        Globals.clearDialogEntryThread = nil
    end
    for _, thread in Globals.optionTextThreads do
        task.cancel(thread)
    end
    table.clear(Globals.optionTextThreads)
end

onClearDialogEntryProxy = function()
    cancelThreads()
    Globals.clearDialogEntryThread = task.defer(onClearDialogEntry)
end

onClearDialogEntry = function()
    clearPreviousDialog()
    applyUIFade(Constants.dialogUIs.screenGui, false, {useFade = true, willWait = true})
    Constants.dialogUIs.screenGui.Enabled = false
end

onShowDialogEntryProxy = function(dialogEntry: DialogInfo.DialogEntry)
    cancelThreads()
    Globals.showDialogEntryThread = task.defer(onShowDialogEntry, dialogEntry)
end

onShowDialogEntry = function(dialogEntry: DialogInfo.DialogEntry)
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
    end
    applyUIFade(Constants.dialogUIs.screenGui, true, {useFade = true, willWait = false})

    -- Show dialog entry
    setIsEntryButtonClicked(false)
    applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, false, {useFade = false, willWait = false})
    applyDialogGuiStyle(dialogEntry.dialogGuiStyle or {})
    applyDialogImageData(dialogEntry.imageData or {})
    applyDialogTextData(dialogEntry.textData)

    -- Check options
    if dialogEntry.optionsData == nil or next(dialogEntry.optionsData.options or {}) == nil then
        --[[ Proceed to next sequence if no option ]]

        -- Wait for player click
        applyUIFade(Constants.dialogUIs.nextIndicator_textLabel, true, {useFade = true, willWait = false})
        setIsEntryButtonClicked(false)
        while not Globals.isEntryButtonClicked do
            task.wait()
        end

        -- Query next sequence
        onQueryNextSequence()
        BelovedRemote.fire_toServer(DialogEvents.remoteActions.toServer.nextDialog)
    else
        -- Apply options
        applyUIFade(Constants.dialogUIs.options_frame, true, {useFade = false, willWait = false})
        applyDialogOptionsData(dialogEntry.optionsData)
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


----- Dialog styles -----

applyDialogGuiStyle = function(guiStyle: DialogInfo.DialogGuiStyle)
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

preloadDialogImageData = function(imageData: DialogInfo.DialogImageData)
    local imageLabels = {}

    -- Get images
    local function addImage(imageData: DialogInfo.DialogIndividualImageData)
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

applyDialogImageData = function(imageData: DialogInfo.DialogImageData)
    applyDialogIndividualImageData(Constants.dialogUIs.center_imageLabel, imageData.centerImage or {})
    applyDialogIndividualImageData(Constants.dialogUIs.left_imageLabel, imageData.leftImage or {})
    applyDialogIndividualImageData(Constants.dialogUIs.right_imageLabel, imageData.rightImage or {})
end

applyDialogIndividualImageData = function(imageLabel: ImageLabel, imageData: DialogInfo.DialogIndividualImageData)
    imageLabel.Image = imageData.imageId or ""
    imageLabel.Size = imageData.size or UDim2.new(1, 0, 1, 0)
end

applyTypewriterData = function(typewriter: typeof(TextTypewriter.new()), typewriterData: DialogInfo.TypewriterData)
    local charSpeed = typewriterData.charSpeed or Constants.defaultCharSpeed
    local regex_pauseDelay = typewriterData.regex_pauseDelay or Constants.defaultRegex_pauseDelay
    local charSounds = typewriterData.charSounds or Constants.defaultCharSounds
    typewriter:setCharSpeed(charSpeed)
    typewriter:setRegexPauseDelay(regex_pauseDelay)
    typewriter:setSoundPerChar(charSounds, "[^%s]")
end

applyDialogTextData = function(textData: DialogInfo.DialogTextData)
    -- Get info
    local lastSpeakerName = Constants.dialogUIs.speaker_textLabel.Text
    local targetSpeakerName = textData.speakerName or lastSpeakerName
    local targetDialogText = textData.dialogText

    -- Config typewriter
    applyTypewriterData(Globals.typewriter, textData.typewriterData or {})

    -- Write speaker name if needed
    Constants.dialogUIs.dialogText_textLabel.Text = ""
    if lastSpeakerName ~= targetSpeakerName then
        if lastSpeakerName ~= "" then
            applyUIFade(Constants.dialogUIs.speaker_textLabel, false, {useFade = true, willWait = true, skippable = true})
            Constants.dialogUIs.speaker_textLabel.Text = ""
            task.wait()
            applyUIFade(Constants.dialogUIs.speaker_textLabel, true, {useFade = false, willWait = false})
        end
        Globals.typewriter:writeText(Constants.dialogUIs.speaker_textLabel, targetSpeakerName, true)
        waitSkippable(0.5)
    end

    -- Write dialog text
    task.wait()
    applyUIFade(Constants.dialogUIs.dialogText_textLabel, true, {useFade = false, willWait = false})
    Globals.typewriter:writeText(Constants.dialogUIs.dialogText_textLabel, targetDialogText, true)
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

applyDialogOptionsData = function(optionsData: DialogInfo.DialogOptionsData)
    local optionCount = 0
    local optionId_info = {} :: {[string]: {
        textLabel: TextLabel,
        text: string,
    }}

    -- Create options
    for _, option in optionsData.options do
        optionCount += 1
        local newOption_textButton = Constants.dialogUIs.defaultOption_textButton:Clone()
        newOption_textButton.LayoutOrder = optionCount
        newOption_textButton.Visible = true
        newOption_textButton.MouseButton1Click:Connect(function()
            if Globals.isPreviousFadeInProgress then
                return
            end
            onQueryNextSequence()
            BelovedRemote.fire_toServer(DialogEvents.remoteActions.toServer.chooseOption, option.id)
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

    -- Write texts
    applyTypewriterData(Globals.typewriter, optionsData.typewriterData or {})
    Globals.optionTextThreads = {}
    for _, optionInfo in optionId_info do
        table.insert(Globals.optionTextThreads, task.defer(function()
            Globals.typewriter:writeText(optionInfo.textLabel, optionInfo.text, false)
        end))
    end
end


----- Main -----

local function main()
    connectDialogEvents()
    connectButtonEvents()
end


---------- Calling function ----------

main()
