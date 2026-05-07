--!strict

-- Dialog Types


---------- Types ----------

export type DialogGuiStyle = {
    backgroundColor: ColorSequence?,
    borderStrokeColor: Color3?,
    textColor: Color3?,
    textFont: Font?,
    textStrokeColor: Color3?,
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

export type DialogTextData = {
    dialogText: string,
    speakerName: string?,
    charSpeed: number?,
}

export type DialogOptionData = {
    id: string,
    text: string,
}

export type DialogEntry = {
    dialogGuiStyle: DialogGuiStyle?,
    imageData: DialogImageData?,
    textData: DialogTextData,
    options: {DialogOptionData}?,
}

export type DialogSequence = {
    sequenceId: string,
    entry: DialogEntry,
    nextSequenceId: string,
    nextSequenceCallback: (() -> ())?,
    optionId_sequenceId: {[string]: string}?,
    optionId_callback: {[string]: () -> ()}?,
}


---------- Return module ----------

return {}
