--
--Author:      zhuguangyuan
--DateTime:    2018-01-29 09:28:35
--Description: 
--

local UserHeadModel = class("UserHeadModel", BaseModel);

function UserHeadModel:init(data)
    UserHeadModel.super.init(self, data)
    self.userHeadData = data or {}
    self.userHeadData["101"] = "111222111"
    if FuncUserHead.userHeadType.isDebug then
        dump(self.userHeadData,"登录时服务器给的数据")
    end
end

function UserHeadModel:updateData(data)
    UserHeadModel.super.updateData(self, data)
    for i,v in pairs(data) do
        self.userHeadData[i] = v
    end
    if FuncUserHead.userHeadType.isDebug then
        dump(data,"底层更新玩家头像数据,服务器发送过来的")
        dump(self.userHeadData,"更新后的数据")
    end
end

function UserHeadModel:getOwnHeadFrame()
    return self.userHeadData
end

-- 检查是否拥有头像框
function UserHeadModel:checkHeadFrameIsOwn(frameId)
    local headFrames = self:getOwnHeadFrame()
    for k,v in pairs(headFrames) do
        if tostring(k) == tostring(frameId) then
            return true
        end
    end
    return false
end

-- 一个ctn 同时设置头像和头像框
-- 传入_avatar 主要用于 没传入headId 和 frameId 时 根据性别获取默认的
function UserHeadModel:setPlayerHeadAndFrame(_ctn,_avatar,_headId,_headFrameId)
    _ctn:anchor(0.5,0.5)
    _ctn:removeAllChildren()
    local headId = _headId or UserModel:head()
    local headFrameId = _headFrameId or UserModel:frame()

    if headId then
        local icon = FuncUserHead.getHeadIcon(headId,_avatar) 
        icon = FuncRes.iconHero(icon)
        local iconSprite = display.newSprite(icon)
        local artMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        artMaskSprite:anchor(0.5,0.5)
        local headSprite = FuncCommUI.getMaskCan(artMaskSprite,iconSprite)
        iconSprite:pos(-2, 1)
        -- headSprite:setScale(1.1)
        _ctn:addChild(headSprite)
    end
    if headFrameId then
        local icon = FuncUserHead.getHeadFramIcon(headFrameId) 
        icon = FuncRes.iconHero(icon)
        local iconSp = display.newSprite(icon)
        iconSp:anchor(0.5,0.5)
        iconSp:pos(-2, 1)
        -- iconSp:setScale(1.1)
        _ctn:addChild(iconSp)
    end
end

-- 一个ctn 同时设置头像和头像框
-- 传入_avatar 主要用于 没传入headId 和 frameId 时 根据性别获取默认的
function UserHeadModel:setPlayerHeadAndFrame2(_ctn,_avatar,_headId,_headFrameId)
    _ctn:anchor(0.5,0.5)
    _ctn:removeAllChildren()
    local headId = _headId or "101"
    if _avatar == 104 then
        headId = _headId or "106"
    end
    
    local headFrameId = _headFrameId or "101"

    if headId then
        local icon = FuncUserHead.getHeadIcon(headId,_avatar) 
        icon = FuncRes.iconHero(icon)
        local iconSprite = display.newSprite(icon)
        local artMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        artMaskSprite:anchor(0.5,0.5)
        local headSprite = FuncCommUI.getMaskCan(artMaskSprite,iconSprite)
        _ctn:addChild(headSprite)
    end
    if headFrameId then
        local icon = FuncUserHead.getHeadFramIcon(headFrameId) 
        icon = FuncRes.iconHero(icon)
        local iconSp = display.newSprite(icon)
        iconSp:anchor(0.5,0.5)
        _ctn:addChild(iconSp)
    end
end



-- 判断头像是否解锁
function UserHeadModel:isHeadUnLock( _headId )
    if not _headId or (_headId == "") then
        return false
    else
        local condition = FuncUserHead.getHeadCondition(_headId)
        if not condition then
            echoWarn("头像 id 的解锁条件没有配置",_headId)
            return false
        end

        -- 支持配置多个条件 但是目前只配了一个
        local isConditionOk = true 
        for k,_oneCondition in pairs(condition) do
            local conditionArr = string.split(_oneCondition,",")
            local headType = conditionArr[1]
            dump(conditionArr, "=====  conditionArr")

            -- 主角默认头像
            if headType == FuncUserHead.userHeadType.DEFAULT then
                local demandAvatar = conditionArr[2]
                if tostring(demandAvatar) == tostring(UserModel:avatar()) then
                    isConditionOk = isConditionOk and true
                else
                    isConditionOk = isConditionOk and false
                end
            -- 伙伴头像,每活动一个伙伴 将能得到对应的伙伴头像
            elseif headType == FuncUserHead.userHeadType.PARTNER then
                local partnerId = conditionArr[2]
                local isHavePartner = PartnerModel:isHavedPatnner(partnerId) 
                if isHavePartner then
                    isConditionOk = isConditionOk and true
                else
                    isConditionOk = isConditionOk and false
                end
            -- 伙伴皮肤头像
            elseif headType == FuncUserHead.userHeadType.PARTNER_SKIN then
                local partnerId = conditionArr[3]
                local partnerSkinId = conditionArr[2]
                local isHavePartner = PartnerModel:isHavedPatnner(partnerId) 
                local isHavePartnerSkin = PartnerSkinModel:isOwnOrNot(partnerSkinId)
                if isHavePartner and isHavePartnerSkin then
                    isConditionOk = isConditionOk and true
                else
                    isConditionOk = isConditionOk and false
                end
            -- 主角时装头像
            elseif headType == FuncUserHead.userHeadType.CHAR_GARMENT then
                local demandAvatar = conditionArr[3]
                local garmentId = conditionArr[2]
                local isAvatarCorrect = (tostring(demandAvatar) == tostring(UserModel:avatar()))
                local isHaveGarment = GarmentModel:isOwnOrNot(garmentId)
                if isAvatarCorrect and isHaveGarment then
                    isConditionOk = isConditionOk and true
                else
                    isConditionOk = isConditionOk and false
                end
            -- 限时活动头像
            elseif headType == FuncUserHead.userHeadType.ACTIVITY then
                isConditionOk = false
            end
        end

        return isConditionOk 
    end
end

return UserHeadModel;
