--伙伴碎片合成
--2016-12-21 19:57:00
--@Author:xiaohuaixong
local PartnerDisplayItemView = class("PartnerDisplayItemView",UIBase)

function PartnerDisplayItemView:ctor(_name)
    PartnerDisplayItemView.super.ctor(self,_name)
end

function PartnerDisplayItemView:loadUIComplete()

    self.kaiguan = self.panel_1.panel_kai
    self:registerEvent()

end



function PartnerDisplayItemView:registerEvent()
    PartnerDisplayItemView.super.registerEvent(self)
    --伙伴红点开关变化
    EventControler:addEventListener(PartnerEvent.PARTNER_REDPOINT_KAIGUAN_EVENT,self.redPointKaiguanChange,self)
end
function PartnerDisplayItemView:setParentView(_view)
    self.parentView = _view
end

function PartnerDisplayItemView:redPointKaiguanChange()
    --红点开关
    local itemPanel = self.panel_1
    local iconPanel = itemPanel.panel_1
    local _bool = PartnerModel:getRedPoindKaiGuanById(self._id)
    self:kaiguanDisplay(itemPanel.panel_kai,_bool)
    if _bool then
        --红点显示
        local isShow = self:isShowredPoint(self.data.id)
        iconPanel.panel_red:visible(isShow)
    else    
        iconPanel.panel_red:visible(false)
    end
end


--每组件更新函数
function PartnerDisplayItemView:updateEveryItemView(_item)
    self._id = _item.id
    self.data = _item
    local itemPanel = self.panel_1
    local iconPanel = itemPanel.panel_1
    local partnerData = FuncPartner.getPartnerById(_item.id)
    --名字
    local quaData = FuncPartner.getPartnerQuality(_item.id)
    quaData = quaData[tostring(_item.quality)]
    local nameColor = quaData.nameColor
    nameColor = string.split(nameColor,",") 
    itemPanel.mc_name:showFrame(tonumber(nameColor[1]))
    if tonumber(nameColor[2]) > 1 then
        local colorNum = tonumber(nameColor[2]) - 1
        itemPanel.mc_name.currentView.txt_1:setString(FuncPartner.getPartnerName(self.data.id).."+"..colorNum)
    else
        itemPanel.mc_name.currentView.txt_1:setString(FuncPartner.getPartnerName(self.data.id))
    end
    --战力
    itemPanel.mc_zhansui:showFrame(1)
    local _ability = CharModel:getCharOrPartnerAbility(self.data.id)
    itemPanel.mc_zhansui.currentView.UI_number:setPower(_ability)
    --星级
    iconPanel.mc_star:showFrame(_item.star)
    --等级
    iconPanel.txt_1:setString(_item.level)
    --品质框
    local qualityData = FuncPartner.getPartnerQuality(_item.id)
    qualityData = qualityData[tostring(_item.quality)]
    iconPanel.mc_2:showFrame(qualityData.color)
    --头像
    local _spriteIcon = self:partnerIcon(iconPanel.mc_2.currentView.ctn_1,partnerData.icon )

    --头像的点击事件
    iconPanel:setTouchedFunc(function ()
        --跳转到提升UI
        EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGE_TISHENG_UI_EVENT,self._id)
        self.parentView:startHide()
    end)
    
    --红点开关
    local _bool = PartnerModel:getRedPoindKaiGuanById(_item.id)
    self:kaiguanDisplay(itemPanel.panel_kai,_bool)
    if _bool then
        --红点显示
        local isShow = self:isShowredPoint(_item.id)
        iconPanel.panel_red:visible(isShow)
    else    
        iconPanel.panel_red:visible(false)
    end
    -- 设置开关的响应事件
    itemPanel.panel_kai:setTouchedFunc(c_func(self.kaiguanTap,self,itemPanel,_item.id))
end
--每组件更新函数
function PartnerDisplayItemView:updateEveryCombineItemView(_item)
    self._id = _item
    local itemPanel = self.panel_1
    local iconPanel = itemPanel.panel_1
    local partnerData = FuncPartner.getPartnerById(_item)
    --名字
    itemPanel.mc_name:showFrame(1)
    itemPanel.mc_name.currentView.txt_1:setString(FuncPartner.getPartnerName(self._id))
    --背景
    itemPanel.mc_1:showFrame(2)
    --碎片数量
    itemPanel.mc_zhansui:showFrame(2)
     local haveNum = ItemsModel:getItemNumById(self._id)
    local needNum = partnerData.tity
   
    itemPanel.mc_zhansui.currentView.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_004")..haveNum.."/"..needNum)

    --星级
    iconPanel.mc_star:showFrame(partnerData.initStar)
    --等级
    iconPanel.txt_1:visible(false)
    iconPanel.panel_txtLevel:visible(false)
    --品质框
    local qualityData = FuncPartner.getPartnerQuality(_item)
    qualityData = qualityData[tostring(partnerData.initQuality)]
    iconPanel.mc_2:showFrame(qualityData.color)
    --头像
    local _spriteIcon = self:partnerIcon(iconPanel.mc_2.currentView.ctn_1,partnerData.icon )
    -- 策划说 和伙伴列表一样
    FilterTools.setGrayFilter(_spriteIcon)
    --头像的点击事件
    iconPanel:setTouchedFunc(function ()
        --跳转到合成UI
        EventControler:dispatchEvent(PartnerEvent.PARTNER_CHANGE_HECHENG_UI_EVENT,partnerData)
        self.parentView:startHide()
    end)
    
    --红点显示
    local isShow = false
    iconPanel.panel_red:visible(isShow)
    --红点开关
    local _bool = false
    self:kaiguanDisplay(itemPanel.panel_kai,_bool)

    itemPanel.panel_kai:visible(false)
end

function PartnerDisplayItemView:partnerIcon(ctn,iconName )
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)

    local iconSpr = display.newSprite(FuncRes.iconHead(iconName)) 
    local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
    _spriteIcon:setScale(1.2)
    ctn:removeAllChildren()
    ctn:addChild(_spriteIcon)
    return _spriteIcon
end

--红点开关逻辑
function PartnerDisplayItemView:kaiguanTap(_panel,_partnerId)
    _panel.panel_kai:setTouchEnabled(false)
    FuncPartner.playPartnerRedBtnSound( )
    local _callBack = function ( ... )
        _panel.panel_kai:setTouchEnabled(true)
    end
    self:delayCall(_callBack, 0.5)
    local _bool = PartnerModel:getRedPoindKaiGuanById(_partnerId)
    local kaiguanPanel = _panel.panel_kai
    local guanPosX = -6
    local kaiPosX = 28
    local posY = kaiguanPanel.mc_1:getPositionY();
    local moveAnim;
    if _bool then -- 开到关
        kaiguanPanel.mc_1:showFrame(2)
        kaiguanPanel.mc_2:showFrame(2)
        moveAnim = act.moveto(0.2,guanPosX,posY)
    else --关到开
        kaiguanPanel.mc_1:showFrame(1)
        kaiguanPanel.mc_2:showFrame(1)
        moveAnim = act.moveto(0.2,kaiPosX,posY)
    end
    kaiguanPanel.mc_1:runAction(moveAnim)

    PartnerModel:setRedPoindKaiGuanById(_partnerId,not _bool)

    if not _bool then
        _panel.panel_1.panel_red:visible(self:isShowredPoint(_partnerId))
    else
        _panel.panel_1.panel_red:visible(not _bool)
    end


--    local kaiguanKey = "zongkaiguai";
--    local zong_bool = FuncPartner.getPartnerRedPoint(kaiguanKey)
--    if zong_bool == false and not _bool then -- 总开关关闭 小开关开启
--        EventControler:dispatchEvent(PartnerEvent.PARTNER_REDPOINT_ZONGKAIGUAN_EVENT)
--    end
    EventControler:dispatchEvent(PartnerEvent.PARTNER_REDPOINT_ZONGKAIGUAN_EVENT)

    PartnerModel:partnerRedPoint()
    PartnerModel:homeRedPointEvent()
end

--开关显示
function PartnerDisplayItemView:kaiguanDisplay(_panel,isBool)
    local guanPosX = -6
    local kaiPosX = 28
    if isBool then
        _panel.mc_1:showFrame(1)
        _panel.mc_2:showFrame(1)
        _panel.mc_1:setPositionX(kaiPosX)
    else
        _panel.mc_1:showFrame(2)
        _panel.mc_2:showFrame(2)
        _panel.mc_1:setPositionX(guanPosX)
    end
end


--判断某一个伙伴图标的红点是否应该显式
function PartnerDisplayItemView:isShowredPoint(_partnerId)
    local _tag1 = PartnerModel:isShowUpgradeRedPoint(_partnerId)--升级
    if _tag1 then
        return true 
    end
    local _tag2 = PartnerModel:isShowStarRedPoint(_partnerId) --升星
    if _tag2 then 
        return true 
    end
    local _tag3 = PartnerModel:isShowQualityRedPoint(_partnerId) --升品
    if _tag3 then 
        return true 
    end
    local _tag4 = PartnerModel:isShowEquipRedPoint(_partnerId)--装备
    if _tag4 then 
        return true 
    end
    local _tag5 = PartnerModel:isEquipAwakeRedPoint(_partnerId) -- 觉醒
    if _tag5 then 
        return true 
    end
    return false
end

--点击碎片的来源
function PartnerDisplayItemView:clickButtonGetSource(_item)
    WindowControler:showWindow("GetWayListView", _item);
end

return PartnerDisplayItemView
