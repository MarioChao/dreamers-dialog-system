--!strict

-- Dialog Types


---------- Types ----------

export type DialogGuiStyle = {
    backgroundColor: ColorSequence?,
    backgroundTransparency: number?,
    borderStrokeColor: Color3?,
    textColor: Color3?,
    textFont: Font?,
    textStrokeColor: Color3?,
    textStrokeTransparency: number?,
}

export type DialogIndividualImageData = {
    imageId: string?,
    size: UDim2?,
}

export type DialogImageData = {
    centerImage: DialogIndividualImageData?,
    leftImage: DialogIndividualImageData?,
    rightImage: DialogIndividualImageData?,
}

export type TypewriterData = {
    charSpeed: number?,
    regex_pauseDelay: {[string]: number?}?,
    charSounds: {Sound}?,
}

export type DialogTextData = {
    speakerName: string,
    dialogText: string,
    typewriterData: TypewriterData?,
}

export type DialogSingleOptionData = {
    id: string,
    text: string,
}

export type DialogOptionsData = {
    options: {DialogSingleOptionData},
    typewriterData: TypewriterData?,
}

export type DialogEntry = {
    dialogGuiStyle: DialogGuiStyle?,
    imageData: DialogImageData?,
    textData: DialogTextData,
    optionsData: DialogOptionsData?,
}

export type DialogNode = {
    nodeId: string,
    entry: DialogEntry,
    nextNodeId: string,
    nextNodeCallback: (() -> ())?,
    optionId_nodeId: {[string]: string}?,
    optionId_callback: {[string]: () -> ()}?,
}


---------- Return module ----------

return {}
