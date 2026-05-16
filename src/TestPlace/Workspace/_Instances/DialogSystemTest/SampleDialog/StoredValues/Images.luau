--!strict

-- Images


---------- Imports ----------

local _Assets = script.Parent.Parent
local DialogInfo = require(_Assets:WaitForChild("DialogInfo"))


---------- Types ----------

type AvatarThumbnailType = "Avatar" | "AvatarBust" | "AvatarHeadShot"


---------- Module ----------

local Module = {}


----- Module fields -----

Module.getUserThumbnail = function(userId: number, thumbnailType: AvatarThumbnailType)
    return `rbxthumb://type={thumbnailType}&id={userId}&w=352&h=352`
end

Module.getPresetScaledImageData = function(imageId: string): DialogInfo.DialogIndividualImageData
    return {
        imageId = imageId,
        size = UDim2.fromScale(0.3, 1),
    }
end

Module.getPresetScaledUserThumbnailImageData = function(userId: number, thumbnailType: AvatarThumbnailType)
    local imageId = Module.getUserThumbnail(userId, thumbnailType)
    return Module.getPresetScaledImageData(imageId)
end


---------- Return module ----------

table.freeze(Module)
return Module
