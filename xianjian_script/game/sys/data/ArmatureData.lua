--道具系统相关事件
local ArmatureData = {}

--对fla的缩放信息 因为有些图片材质过大 所以对整体进行缩放
ArmatureData.scaleInfo = {
    jiuyanshimo = 0.8; --1/0.8,
    --muhuayi = 0.8;

}

-- 动画材质导出时的缩放比例
ArmatureData.exportScale = {
	jiuyanshimo = 0.8,
}

ArmatureData.aniScaleInfo = {
    jingmuhanlingbuyun_ueffect = 1.4,
}

function ArmatureData:getArmatureShowScale( flaName,aniName )
    -- if not flaName then
    -- 	return 1
    -- end
    if not aniName then
        return 1
    end

    local targetScale = self.aniScaleInfo[aniName]
    if not targetScale then
        targetScale = self.scaleInfo[flaName]
    end

    if not targetScale then
    	return 1
    end

    
    return targetScale

end




return ArmatureData