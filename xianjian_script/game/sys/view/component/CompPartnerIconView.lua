local CompPartnerIconView = class("CompPartnerIconView", UIBase);

function CompPartnerIconView:ctor(winName)
    CompPartnerIconView.super.ctor(self, winName);
end

function CompPartnerIconView:loadUIComplete()
    self:registerEvent()
    
    if self.txt_1 then
        self.txt_1:visible(false)
    end
end 

function CompPartnerIconView:registerEvent()
    CompPartnerIconView.super.registerEvent();

end


function CompPartnerIconView:updataUI(_partnerId, skin, isMonster, systemId, notChangeLevel)
    if not isMonster and tonumber(_partnerId) > 7000 then
        isMonster = true 
    end
    if isMonster then
        local monsterInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", _partnerId)
        local icon = monsterInfo.icon
        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:pos(-1,0)
        headMaskSprite:setScale(0.99)
        self.headMaskSprite = headMaskSprite
        
        local iconSpr = display.newSprite(FuncRes.iconHero(icon))
        _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
        local _ctn = self.ctn_1
        _ctn:removeAllChildren()
        _ctn:addChild(_spriteIcon)
        _spriteIcon:scale(1.2)
        self.mc_kuang:showFrame(1)
        self.mc_di:visible(false)
        self.mc_dou:visible(false)
        self.panel_lv:visible(false)
    else
        local partnerCfg = FuncPartner.getPartnerById(_partnerId)
        local _level = 1
        local _star = partnerCfg.initStar
        local _quality = partnerCfg.initQuality
        if systemId and tonumber(systemId) == tonumber(FuncTeamFormation.formation.crossPeak) then
            local currentSegment = CrossPeakModel:getCurrentSegment()
            local currentSegmentData = FuncCrosspeak.getSegmentDataById(currentSegment)
            local level = currentSegmentData.optionPartnerLevel
            local star = currentSegmentData.optionPartnerStar
            local quality = currentSegmentData.optionPartnerQuality
            _quality = quality
            _level = level
            _star = star
        else
            local data = PartnerModel:getPartnerDataById(_partnerId)
            if data then
                _quality = data.quality
                _level = data.level
                _star = data.star
            end
        end
        
        local _color = FuncChar.getBorderFramByQuality(_quality)
        self.mc_di:visible(true)
        self.mc_dou:visible(true)
        self.panel_lv:visible(true)
        self.mc_kuang:showFrame(tonumber(_color))
        self.mc_di:showFrame(tonumber(_color))
        self.mc_dou:showFrame(tonumber(_star))

        if not notChangeLevel then
            self.panel_lv.txt_3:setString(tostring(_level))
        end

        local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        headMaskSprite:pos(-1,0)
        headMaskSprite:setScale(0.99)
        self.headMaskSprite = headMaskSprite
        
        local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(_partnerId,skin)
        _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
        

        local _ctn = self.ctn_1
        _ctn:removeAllChildren()
        _ctn:addChild(_spriteIcon)
        _spriteIcon:scale(1.2)
    end

    self.txt_1:visible(false)
end

function CompPartnerIconView:updataUIByPartnerData(_partnerData)
    local _partnerId = _partnerData.id
    local skin = _partnerData.skin
    local _level = _partnerData.level
    local _star = _partnerData.star
    local _quality = _partnerData.quality
    local _color = FuncChar.getBorderFramByQuality(_quality)
    self.mc_kuang:showFrame(tonumber(_color))
    self.mc_di:showFrame(tonumber(_color))
    self.mc_dou:showFrame(tonumber(_star))
    self.panel_lv.txt_3:setString(tostring(_level))
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)
    self.headMaskSprite = headMaskSprite   
    local iconSpr = FuncPartner.getPartnerIconByIdAndSkin(_partnerId, skin)
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)   
    local _ctn = self.ctn_1
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)
end

--
function CompPartnerIconView:setStar( star )
    self.mc_dou:showFrame(tonumber(star))
end
function CompPartnerIconView:setQulity( _quality )
    local _color = FuncChar.getBorderFramByQuality(tonumber(_quality))
    self.mc_kuang:showFrame(tonumber(_color))
    self.mc_di:showFrame(tonumber(_color))
end
function CompPartnerIconView:setLevel( _level )
    self.panel_lv.txt_3:setString(tostring(_level))
end

-- 头像是否置灰
function CompPartnerIconView:setIconZhiHui(isZhihui)
    if isZhihui then
        FilterTools.setGrayFilter(self.ctn_1);
    else
        FilterTools.clearFilter(self.ctn_1);
    end
end


function CompPartnerIconView:RotationIcon(_rotation)
    self.headMaskSprite:rotation(_rotation)
    self.mc_kuang:rotation(_rotation)
    self.mc_di:rotation(_rotation)
end

function CompPartnerIconView:hideStar(isShow)
    self.mc_dou:visible(isShow)
end
function CompPartnerIconView:hideLevel(isShow)
    self.panel_lv:visible(isShow)
end

function CompPartnerIconView:showName( name )
    self.txt_1:visible(true)
    self.txt_1:setString(name)
end

return CompPartnerIconView;
