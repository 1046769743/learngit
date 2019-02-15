--[[
    Author: caocheng
    Date:2017-08-23
    Description: 查看别人阵容的详情界面
]]

local OtherTeamFormationDetailView = class("OtherTeamFormationDetailView", UIBase);

function OtherTeamFormationDetailView:ctor(winName)
    OtherTeamFormationDetailView.super.ctor(self, winName)
end

function OtherTeamFormationDetailView:loadUIComplete()
    self:registerEvent()
    self:initData()
    self:initViewAlign()
    self:initView()
    self:updateUI()
end 

function OtherTeamFormationDetailView:registerEvent()
    OtherTeamFormationDetailView.super.registerEvent(self);
    self.btn_back:setTap(c_func(self.pree_btn_close,self))
end

function OtherTeamFormationDetailView:initData()
    self.itemData = LineUpModel:getOtherTeamFormationData()
    -- dump(self.itemData, "\n\nself.itemData==")
    self.teamData = LineUpModel:getOtherTeamFormation()
    self._curIdx = 1
end

function OtherTeamFormationDetailView:initView()
    self.panel_level.btn_yuanjjia:visible(false)
    self:createTeamFormationList()
end

function OtherTeamFormationDetailView:initViewAlign()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_gfj, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_power,UIAlignTypes.RightTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_dingwei,UIAlignTypes.LeftTop)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.MiddleBottom)
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_level, UIAlignTypes.LeftTop)
end

function OtherTeamFormationDetailView:updateUI()
    self:updateDetails()
end

function OtherTeamFormationDetailView:deleteMe()
    -- TODO

    OtherTeamFormationDetailView.super.deleteMe(self);
end

function OtherTeamFormationDetailView:createTeamFormationList()
    local partners = LineUpModel:getDetailList()
    -- dump(partners,"当前的别人数据")
    -- dump(self.itemData,"data")
    local pNums = #partners
    self.panel_1.mc_1:showFrame(pNums)
    local currentView = self.panel_1.mc_1.currentView
    currentView.__pNums = pNums
    for i=1,pNums do
        local itemData = partners[i]
        local idx = i
        local view = currentView["panel_ren" .. i]
        self:updateItem(view, itemData, idx)
    end

end

function OtherTeamFormationDetailView:updateItem(view, itemData, idx)
    local panel = view
    panel._idx = idx

    panel.txt_3:setString(itemData.level)

    -- 选中框
    panel.panel_1:visible(idx == self._curIdx)
    -- 红点
    panel.panel_red:visible(false)

    local _iconPath = nil
    if itemData.isChar then
        -- 品质
        local qualityData = FuncChar.getCharQualityDataById(itemData.quality)
        -- 边框颜色
        local border = qualityData.border
        panel.mc_2:showFrame(tonumber(border)) 
        _iconPath = itemData.icon
    else
        -- 品质
        local _frame = FuncPartner.getPartnerQuality(tostring(itemData.id))[tostring(itemData.quality)].color
        panel.mc_2:showFrame(_frame) 
        -- 伙伴的表格
        local _partnerInfo = FuncPartner.getPartnerById(itemData.id)           
        _iconPath = _partnerInfo.icon
        
    end
    -- 伙伴的Icon
    local _ctn = panel.mc_2.currentView.ctn_1
    local _spriteIcon = nil
    if tostring(itemData.id) == "1" then
        _spriteIcon = FuncGarment.getGarmentIcon(itemData.garmentId,itemData.avatar)
    else    
        _spriteIcon = display.newSprite(FuncRes.iconHero(_iconPath))
        if itemData.skin ~= "" then
            _spriteIcon = FuncPartnerSkin.getPartnerHeadIcon(itemData.id, itemData.skin)
        end
    end
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    headMaskSprite:anchor(0.5,0.5)
    headMaskSprite:pos(-1,0)
    headMaskSprite:setScale(0.99)

    -- 通过遮罩实现头像裁剪
    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
    _ctn:removeAllChildren()
    _ctn:addChild(_spriteIcon)
    _spriteIcon:scale(1.2)

    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if tonumber(itemData.star) == 0 then
        panel.mc_dou:visible(false)
    else
        panel.mc_dou:visible(true)
        panel.mc_dou:showFrame(itemData.star)
    end
    -- -- 注册按钮回调事件
    panel:setTouchedFunc(c_func(self.onCellTouchCallFunc, self, itemData, idx) )
    panel:setTouchSwallowEnabled(true)
end


function OtherTeamFormationDetailView:onCellTouchCallFunc( itemData, idx)
    if self._curIdx == idx then return end

    self._curIdx = idx

    local currentView = self.panel_1.mc_1.currentView

    for i=1,currentView.__pNums do
        local view = currentView["panel_ren" .. i]
        view.panel_1:visible(view._idx == self._curIdx)
    end

    -- 刷新左侧
    self:updateDetails(itemData)
end

function OtherTeamFormationDetailView:updateDetails(itemData)
    local itemData = itemData or LineUpModel:getDetailList()[self._curIdx]
    if self._curIdx == 1 then -- 主角
        local qualityData = FuncChar.getCharQualityDataById(itemData.quality)
        -- 名字
        local name = itemData.name
         self.panel_dingwei.mc_tu2:visible(false)
        quaData = FuncPartner.getPartnerQuality(itemData.avatar)
        quaData = quaData[tostring(itemData.quality)]
        local nameColor = quaData.nameColor
        nameColor = string.split(nameColor,",") 
        self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
        if tonumber(nameColor[2]) > 1 then
            self.panel_name.mc_1.currentView.txt_1:setString(itemData.name.."+"..nameColor[2]-1)
        else
            self.panel_name.mc_1.currentView.txt_1:setString(itemData.name)
        end

        local offsetX = FuncCommUI.getStringWidth(name, 28) + 5
        
        -- 战力
        self.panel_power.UI_number:setPower(itemData.power)
        -- 主角类型
        self.panel_gfj.mc_gfj:showFrame(4)
        local heroData = FuncChar.getCharInitData()
        --装备
        self:updateEquipment(self.panel_duo, self.itemData.equips, heroData.equipment, itemData.avatar)
        --定位
        local describe = FuncPartner.getDescribe(itemData.avatar) 
        self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(describe))
        local heroTreasures =  self.itemData.treasures[tostring(self.teamData.treasureFormation["p1"])]
        self.skillT = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(heroTreasures.id,itemData.avatar)
        local heroSkillList = {}
        for i = 1,table.length(self.skillT) do
            local starSkillMap = FuncTreasureNew.getStarSkillMap(heroTreasures.id,itemData.avatar)
            if heroTreasures.star >= starSkillMap[self.skillT[i]].star then
                heroSkillList[tostring(self.skillT[i])] = math.floor((itemData.level))
            end
        end 
        self:updateSkill(self.panel_duo, heroSkillList,true)
    else 
        -- 伙伴的表格
        local _partnerInfo = FuncPartner.getPartnerById(itemData.id)
        self.panel_dingwei.mc_tu2:visible(true)
        self.panel_dingwei.mc_tu2:showFrame(_partnerInfo.elements)
        -- 伙伴类型
        self.panel_gfj.mc_gfj:showFrame(tonumber(_partnerInfo.type))
        -- 战力
        local _power = FuncPartner.getPartnerAbility(itemData, self.itemData, self.itemData.formation)
        self.panel_power.UI_number:setPower(_power)
        -- 装备
        self:updateEquipment(self.panel_duo, itemData.equips, _partnerInfo.equipment, itemData.id)
        -- 技能
        self:updateSkill(self.panel_duo, itemData)
        -- 名字
        -- self.mc_1.currentView.panel_name.txt_1:setString(GameConfig.getLanguage(_partnerInfo.name) .. "+" .. itemData.quality)

        local offsetX = FuncCommUI.getStringWidth(GameConfig.getLanguage(_partnerInfo.name), 28) + 5
        self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(_partnerInfo.charaCteristic))

        quaData = FuncPartner.getPartnerQuality(itemData.id)
        quaData = quaData[tostring(itemData.quality)]
        local nameColor = quaData.nameColor
        nameColor = string.split(nameColor,",") 
        self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
        if tonumber(nameColor[2]) > 1 then
            self.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(itemData.id).."+"..nameColor[2]-1)
        else
            self.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(itemData.id))
        end
    end

    -- 公用部分
    -- 台子
    local platform = self.panel_duo.panel_zhu
    -- 人物
    local _ctn = platform.ctn_1
    _ctn:removeAllChildren()
    local _sprite = FuncLineUp.initNpc(itemData)
    _sprite:setScale(1.7)
    _ctn:addChild(_sprite)
    -- 星级（不知道有没有0星，但是出现了，先在这里做个容错吧）
    if tonumber(itemData.star) == 0 then
        platform.mc_dou:visible(false)
    else
        platform.mc_dou:visible(true)
        platform.mc_dou:showFrame(itemData.star)
    end
    -- 等级
    self.panel_level.txt_bing:setString(itemData.level .. GameConfig.getLanguage("tid_common_2049"))
end

-- 技能
function OtherTeamFormationDetailView:updateSkill( view, itemData,isHero )
    local showList = nil
    if isHero then
        showList =  LineUpModel:getSkillInOrder(itemData,self.skillT,self.itemData.avatar)
    else
        showList = LineUpModel:getSkillInOrder(itemData)
    end
    for i=1,3 do
        local currentView = view["panel_fb" .. i]
        local nowData = showList[i]
        local _skillInfo = nowData.skillInfo
        -- 技能图标
        local _ctn = currentView.ctn_1
        _ctn:removeAllChildren()
        local _iconPath = FuncRes.iconSkill(_skillInfo.icon)
        local iconSp = display.newSprite(_iconPath)
        if _skillInfo.priority == 1 then
            iconSp:setScale(0.75)
        end
        iconSp:addTo(_ctn)
        -- 技能名
        currentView.txt_2:setString(GameConfig.getLanguage(_skillInfo.name))

        if nowData.level > 0 then -- 已开启
            currentView.txt_1:setString(nowData.level)
            currentView.panel_suo:visible(false)
            -- currentView:setTouchedFunc(c_func(self.onSkillTouch, self, currentView, nowData))
            local tempTreasureData = self.itemData.treasures[tostring(self.teamData.treasureFormation["p1"])]
            if isHero then
                local params = {
                        treasureId =self.itemData.treasures[tostring(self.teamData.treasureFormation["p1"])].id,
                        skillId = nowData.id,
                        index = i,
                        level = nowData.level,
                        star = self.itemData.treasures[tostring(self.teamData.treasureFormation["p1"])].star,
                        awaken = self.itemData.treasures[tostring(self.teamData.treasureFormation["p1"])].awaken,
                        data = tempTreasureData
                 }
                FuncCommUI.regesitShowTreasureSkillTipView(currentView,params,false)
            else
                FuncCommUI.regesitShowSkillTipView(currentView, {partnerId = nowData.partnerId, id = nowData.id, level = nowData.level or 1,isUnlock = true,_index = nowData._index,isHIdeXL = true}, false)
            end 
        else -- 置灰（和伙伴界面一致，那么等级就先显示一级吧）
            currentView.txt_1:setString("1")
            currentView.panel_suo:visible(true)
            currentView:setTouchEnabled(false)
        end
    end
end


function OtherTeamFormationDetailView:pree_btn_close()
    self:startHide()
end

function OtherTeamFormationDetailView:updateEquipment(view, _playerEquip, _equipData, id)
    for i,v in ipairs(_equipData) do
         -- view["UI_" .. i].mc_1:showFrame(1)othe
         _playerEquip[v].partnerId = id
        local nowUI = view["mc_" .. i]
        local equipData = FuncPartner.getEquipmentById(v)
        local equipLvl = _playerEquip[v].level
        equipData = equipData[tostring(equipLvl)]
        nowUI:showFrame(equipData.quality)
        -- equipLvl = equipLvl - equipData.quality +1  
        local equipRealLevel = equipData.showLv[1].key
        -- 装备
        local _ctn = nowUI.currentView.ctn_1
        _ctn:removeAllChildren()
        local _spriteRes = FuncRes.iconPartnerEquipment(FuncPartner.getEquipmentIcon(id,i))
        local _sprite = display.newSprite(_spriteRes):addTo(_ctn)
        -- 装备等级
        nowUI.currentView.txt_1:setString(equipRealLevel)
        -- 装备品质
        
        
        -- equipPanel:setTouchedFunc(c_func(self.onEquipTouch, self, currentView, _playerEquip[v]))

        FuncCommUI.regesitShowEquipTipView(nowUI, _playerEquip[v])
    end
end

return OtherTeamFormationDetailView;
