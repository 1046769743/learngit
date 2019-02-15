--[[
	Author: caocheng
	Date:2017-10-14
	Description: 五行布阵伙伴详情界面
]]

local WuXingPartnerDetailView = class("WuXingPartnerDetailView", UIBase);

function WuXingPartnerDetailView:ctor(winName,partnerId,isMulti)
    WuXingPartnerDetailView.super.ctor(self, winName)
    self.partnerId = partnerId
    self.isMulti =isMulti
end

function WuXingPartnerDetailView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingPartnerDetailView:registerEvent()
	WuXingPartnerDetailView.super.registerEvent(self);

    local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_bg, 0)
    coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
    coverLayer:setTouchedFunc(c_func(self.needHideDetailView, self))
    coverLayer:setTouchSwallowEnabled(true)

	self.btn_close:setTouchedFunc(c_func(self.needHideDetailView, self))
    self.panel_bg:setTouchedFunc(GameVars.emptyFunc, nil, true)
 --    EventControler:addEventListener(TeamFormationEvent.CLOSE_TEAMDETAILVIEW, self.press_close, self)
end

function WuXingPartnerDetailView:needHideDetailView()
    EventControler:dispatchEvent(TeamFormationEvent.CLOSE_PARTNER_DETAILVIEW)
end

function WuXingPartnerDetailView:initData()
    self.isNpc = false
	if tostring(self.partnerId) == "1" then
		self.partnerData = 	PartnerModel:getPartnerDataById(tostring(UserModel:avatar()))
	else
        if FuncWonderland.isWonderLandNpc(self.partnerId) then
            self.isNpc = true
        else
            self.partnerData = PartnerModel:getPartnerDataById(tostring(self.partnerId))
            self.partnerCfgData = FuncPartner.getPartnerById(self.partnerId)
        end	
	end

    self.partnerTags = TeamFormationModel:getCurrentTags()
end

function WuXingPartnerDetailView:setPartnerData(partnerId,isMulti)
    self.partnerId = partnerId
    self.isMulti = isMulti
    self:initData()
    self:initView()
end

function WuXingPartnerDetailView:initView()
	--创建spine
	self:initHeroSpine()
    if self.isNpc then  
        -- self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_wuxing_003"))
        -- self:initNpcView()
    else
        -- self.panel_di.txt_1:setString(GameConfig.getLanguage("#tid_wuxing_004"))
        -- --创建属性
        self:initHeroData()
        -- --创建仙术
        -- self:initSkillView()
        self:updateRightScrollView()
    end
end

function WuXingPartnerDetailView:initViewAlign()

end

function WuXingPartnerDetailView:updateUI()

end

function WuXingPartnerDetailView:updateRightScrollView()
    self.panel_1:setVisible(false)
    local offSetY = 0
    if tostring(self.partnerId) == "1" then
        local skillCfg = FuncTreasureNew.getTreasureSkills(self.treasureId, UserModel:avatar())
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(tostring(skillCfg[1]))
        local skillDes_show = GameConfig.getLanguage(skillData.describe)
        _, self.desHeight = self.panel_1.panel_3.rich_skillxiangqing:setStringByAutoSize(skillDes_show, 0)
        offSetY = self.desHeight - 150
    else
        local partnerCfg = FuncPartner.getPartnerById(self.partnerId)
        local skillData = FuncPartner.getSkillInfo(tostring(partnerCfg.skill[1]))
        local skillDes_show = GameConfig.getLanguage(skillData.describe)
        _, self.desHeight = self.panel_1.panel_3.rich_skillxiangqing:setStringByAutoSize(skillDes_show, 0)
        if self.desHeight > 60 then
            offSetY = self.desHeight - 60
        end
    end

    if self.desHeight < 60 then
        self.desHeight = 60 
    end

    local createCellFunc = function (itemData)
        local view = UIBaseDef:cloneOneView(self.panel_1)
        self:updateItemView(view, itemData)
        return view
    end

    local scrollParams = {
        {
            data = {1},
            createFunc = createCellFunc,
            perFrame = 1,
            perNums = 1,
            offsetX = 5,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -(700 + offSetY), width = 380, height = (700 + offSetY)},
        }
    }

    self.scroll_1:cancleCacheView()
    self.scroll_1:styleFill(scrollParams)
    self.scroll_1:gotoTargetPos(1, 1, 0, 0)
    self.scroll_1:hideDragBar()
end

function WuXingPartnerDetailView:updateItemView(view, itemData)
    view.panel_power.UI_power.UI_1:setPower(self.powerNum)
    if self.partnerTags and #self.partnerTags > 0 then
        local hasBuff = false
        local attr_addition = TeamFormationModel:getAttrAddition()
        if tostring(self.partnerId) == "1" then
            local treasureData = FuncTreasureNew.getTreasureDataById(self.treasureId)
            local wuling = treasureData.wuling

            for i,v in ipairs(self.partnerTags) do
                if tonumber(v[1]) == 3 and tonumber(v[2]) == wuling then
                    hasBuff = true
                    break
                end
            end
        else
            local tags = self.partnerCfgData.tag
            
            for i,v in ipairs(self.partnerTags) do
                if tags and tostring(tags[tonumber(v[1])]) == tostring(v[2]) then
                    hasBuff = true
                    break
                end
            end
        end

        if hasBuff and attr_addition then            
            local attrDes = FuncBattleBase.getFormatFightAttrValueByMode(attr_addition[1].key, attr_addition[1].value, attr_addition[1].mode)
            local name = FuncBattleBase.getAttributeName(attr_addition[1].key)
            view.panel_1.txt_2:setString("   "..name.."+"..attrDes)
        else
            view.panel_1.txt_2:setString("      "..GameConfig.getLanguage("#tid_wuxing_037"))
        end        
    else
        view.panel_1.txt_2:setString("      "..GameConfig.getLanguage("#tid_wuxing_037"))
    end

    if tostring(self.partnerId) == "1" then
        view.panel_2:setVisible(false)
        view.panel_3:pos(0, -100)
        self:initCharSkill(view.panel_3)
    else
        view.panel_2:setVisible(true)
        view.panel_3:pos(0, -212)
        self:initSkillView(view.panel_3)
        self:initTagsView(view.panel_2)
    end
end

function WuXingPartnerDetailView:initTagsView(_view)
    local tags = self.partnerCfgData.tag
    local keyMap = {
                        ["2"] = {value = tags[2], index = 1}, 
                        ["4"] = {value = tags[4], index = 2}, 
                        ["6"] = {value = tags[6], index = 3}, 
                        ["3"] = {value = tags[3], index = 4}
                    }

    local xiLieTag = FuncCommon.getTagNameByTypeAndId(2, tags[2])
    local zhongZuTag = FuncCommon.getTagNameByTypeAndId(4, tags[4])
    local menPaiTag = FuncCommon.getTagNameByTypeAndId(6, tags[6])
    local wulingTag = FuncCommon.getTagNameByTypeAndId(3, tags[3])

    _view.mc_1:showFrame(1)
    _view.mc_2:showFrame(1)
    _view.mc_3:showFrame(1)
    _view.mc_4:showFrame(1)

    if self.partnerTags and #self.partnerTags > 0 then
        for i,v in ipairs(self.partnerTags) do
            if keyMap[v[1]] and keyMap[v[1]].value == v[2] then
                local index = keyMap[v[1]].index
                _view["mc_"..index]:showFrame(2)
            end
        end    
    end

    _view.mc_1.currentView.txt_2:setString(GameConfig.getLanguage(xiLieTag))
    _view.mc_2.currentView.txt_2:setString(GameConfig.getLanguage(zhongZuTag))
    _view.mc_3.currentView.txt_2:setString(GameConfig.getLanguage(menPaiTag))
    _view.mc_4.currentView.txt_2:setString(GameConfig.getLanguage(wulingTag))
end

function WuXingPartnerDetailView:initHeroSpine()
	local view = nil
    self.ctn_1:removeAllChildren()
	if tostring(self.partnerId) == "1" then
    	view = GarmentModel:getCharGarmentSpine():addto(self.ctn_1)
    else
        local spine, sourceId = FuncTeamFormation.getSpineNameByHeroId(self.partnerId, true)
        local sourceData = FuncTreasure.getSourceDataById(sourceId)
        view = ViewSpine.new(spine,{},nil,spine,nil,sourceData):addto(self.ctn_1)	
    end
    view:playLabel("stand",true)
    view:setScaleY(1.3)
    view:setScaleX(-1.3)
end

-- function WuXingPartnerDetailView:initNpcView()
--     self.mc_tu2:showFrame(6)
--     self.mc_gfj:setVisible(false)
--     self.panel_dingwei:setVisible(false)
--     self.mc_star:setVisible(false)
--     self.panel_power:setVisible(false)
--     self.panel_weihuode:setVisible(false)
--     local npcInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", self.partnerId)
--     local name = FuncTranslate._getLanguage(npcInfo.name)
--     self.panel_name.mc_1:showFrame(1)
--     self.panel_name.mc_1.currentView.txt_1:setString(name)
--     self.mc_xxa:showFrame(1)
--     local skill_info = FuncWonderland.getWonderLandNpcSkill()
--     local skill_panel = self.mc_xxa.currentView.panel_b2
--     for i = 1, 2, 1 do
--         local skill_data = skill_info[tostring(i)]
--         local index = i + 1
--         local panel = skill_panel["panel_"..index]
--         local _iconPath = FuncRes.iconSkill(skill_data.icon)
--         local _iconSprite = cc.Sprite:create(_iconPath)
--         local skill_des = FuncTranslate._getLanguage(skill_data.miaoshu)
--         local skill_name = FuncTranslate._getLanguage(skill_data.name)
--         if i == 1 then
--             panel.mc_zb:showFrame(1)
--             panel.mc_skill:showFrame(2)
--             _iconSprite:setScale(0.69)
--         else
--             panel.mc_zb:setVisible(false)
--             panel.mc_skill:showFrame(1)
--         end
--         local ctn = panel.mc_skill.currentView.ctn_1
--         ctn:removeAllChildren()     
--         ctn:addChild(_iconSprite)

--         panel.txt_1:setString(skill_name)
--         panel.rich_3:setString(skill_des)
--         panel.panel_number:setVisible(false)
--         panel.panel_suo:setVisible(false)
--     end
-- end

function WuXingPartnerDetailView:initHeroData()
	self.powerNum = CharModel:getCharOrPartnerAbility(self.partnerId)
    if self.powerNum <= 0 then
        -- self.panel_power:setVisible(false)
        self.panel_weihuode:setVisible(true)
    else
        -- self.panel_power:setVisible(true)
        self.panel_weihuode:setVisible(false)
    end

	local quaData = nil
	local partnerAttrData = nil 
    local wuling = 6
	if tostring(self.partnerId) == "1" then
        self.treasureId = nil
        if self.isMulti then
            local tempTreaData = TeamFormationMultiModel:getCurTreaByIdx(1)
            self.treasureId = tempTreaData.id
        else    
            self.treasureId = TeamFormationModel:getCurTreaByIdx(1)
        end   
        self.powerNum = CharModel:getCharAbility(self.treasureId) 
        local treasureData = FuncTreasureNew.getTreasureDataById(self.treasureId)
        wuling = treasureData.wuling
		self.mc_gfj:showFrame(4)
		-- self.panel_b1.panel_2.mc_tu2:visible(false)
		quaData = FuncPartner.getPartnerQuality(UserModel:avatar())
		local describe = FuncPartner.getDescribe(UserModel:avatar()) 
        self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(describe))
        -- self.panel_power.UI_power.UI_1:setPower(powerNum)
	else
        wuling = self.partnerCfgData.elements
		self.mc_gfj:showFrame(self.partnerCfgData.type)
		-- local powerNum = CharModel:getCharOrPartnerAbility(self.partnerId)

		-- self.panel_power.UI_power.UI_1:setPower(powerNum)
		local wuxingData = FuncTeamFormation.getWuXingDataById(self.partnerCfgData.elements)
		-- self.panel_b1.panel_2.txt_1:setString("五行:"..GameConfig.getLanguage(wuxingData.name))
		quaData = FuncPartner.getPartnerQuality(self.partnerId)
		self.panel_dingwei.txt_bing:setString(GameConfig.getLanguage(self.partnerCfgData.charaCteristic))
	end

    if not self.partnerData then
        self.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(self.partnerId))
    else
        quaData = quaData[tostring(self.partnerData.quality)]
        local nameColor = quaData.nameColor
        nameColor = string.split(nameColor,",") 
        self.panel_name.mc_1:showFrame(tonumber(nameColor[1]))
        if tonumber(nameColor[2]) > 1 then
            self.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(self.partnerId).."+"..nameColor[2]-1)
        else
            self.panel_name.mc_1.currentView.txt_1:setString(FuncPartner.getPartnerName(self.partnerId))
        end
    end
	
    local star = 1
    if self.partnerCfgData then
        star = self.partnerCfgData.initStar
    end

    if self.partnerData then
        star = self.partnerData.star
    end
	self.mc_star:showFrame(star)
	
    -- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then
        self.mc_tu2:showFrame(tonumber(wuling))
    -- else
    --     self.mc_tu2:showFrame(6)
    -- end
end

function WuXingPartnerDetailView:press_close()
	self:startHide()
end

function WuXingPartnerDetailView:deleteMe()
	WuXingPartnerDetailView.super.deleteMe(self);
end

function WuXingPartnerDetailView:initSkillView(_view)
    local partnerCfg = FuncPartner.getPartnerById(self.partnerId)
    local partnerSkills = self.partnerData.skills
    local star = self.partnerData.star
    local skill_show = partnerCfg.skill
    
    for i,v in ipairs(skill_show) do
        local index = i - 1
        if i == 1 then
            _view["mc_skill"..index]:showFrame(2)
        else
            _view["mc_skill"..index]:showFrame(1)
            local posY = _view["mc_skill"..index]:getPositionY()
            _view["mc_skill"..index]:setPositionY(-(self.desHeight - 80) + posY)
        end
        local panel_skill = _view["mc_skill"..index].currentView
        local skillId = v
        local skillData = FuncPartner.getSkillInfo(tostring(skillId))
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        local isUnlock = true
        local skillIndex = 2
        panel_skill.ctn_1:removeAllChildren()
        panel_skill.ctn_1:addChild(skillIcon)
        if i == 1 then
            skillIcon:setScale(0.7)
            skillDes_show = GameConfig.getLanguage(skillData.describe)
            skillName_show = GameConfig.getLanguage(skillData.name)
            skillIndex = 1
        else
            panel_skill.txt_name:setString(GameConfig.getLanguage(skillData.name))
        end
        panel_skill.panel_number:setVisible(false)
        FilterTools.clearFilter(skillIcon)
        if not partnerSkills[v] then
            FilterTools.setGrayFilter(skillIcon)
            isUnlock = false
        end
        FuncCommUI.regesitShowSkillTipView(skillIcon, {partnerId = self.partnerId, id = skillId,
                                            level = partnerSkills[v] or 1, isUnlock = isUnlock, _index = skillIndex},false)
          
    end
    _view.txt_skillname:setString(skillName_show)
    _view.rich_skillxiangqing:setString(skillDes_show)
end


function  WuXingPartnerDetailView:initCharSkill(_view)    
    local starSkillMap = FuncTreasureNew.getStarSkillMap(self.treasureId, UserModel:avatar())
    -- dump(starSkillMap, "\n\nstarSkillMap=====")
    local charSkill = FuncChar.getCharSkillId(UserModel:avatar())
    local skillCfg = FuncTreasureNew.getTreasureSkills(self.treasureId, UserModel:avatar())
    local awakeSkillId = FuncTreasureNew.getTreasureAwakeSkillId(self.treasureId, UserModel:avatar())
    local weaponAwakeSkillId = FuncPartner.getWeaponAwakeSkillIdByPartnerId(UserModel:avatar())
    local skill_show = {}

    for i,v in ipairs(skillCfg) do
        if i == 1 then
            skill_show[i] = v
        elseif i >= 2 then
            skill_show[i + 1] = v
        end
    end
    skill_show[2] = charSkill
    skill_show[8] = weaponAwakeSkillId
    skill_show[9] = awakeSkillId

    local dataCfg = FuncTreasureNew.getTreasureDataById(self.treasureId)
    local quality = dataCfg.initQuality
    local star = dataCfg.initStar
    local data = nil
    if TreasureNewModel:isHaveTreasure(self.treasureId) then
        data = TreasureNewModel:getTreasureData(self.treasureId)
        quality = data.quality
        star = data.star
    end

    local skillIndex = 2
    local skillDes_show = ""
    local skillName_show = ""
    for i,v in ipairs(skill_show) do
        local index = i - 1
        if i == 1 then
            _view["mc_skill"..index]:showFrame(2)
        else
            _view["mc_skill"..index]:showFrame(1)
            local posY = _view["mc_skill"..index]:getPositionY()
            _view["mc_skill"..index]:setPositionY(-(self.desHeight - 80) + posY)
        end
        local panel_skill = _view["mc_skill"..index].currentView
        local skillId = v
        local skillData = nil
        if i == 2 or i == 8 then
            skillData = FuncPartner.getSkillInfo(tostring(skillId))
        else
            skillData = FuncTreasureNew.getTreasureSkillDataDataById(tostring(skillId))
        end
        local iconPath = FuncRes.iconSkill(skillData.icon)
        local skillIcon = display.newSprite(iconPath)
        panel_skill.ctn_1:removeAllChildren()
        panel_skill.ctn_1:addChild(skillIcon)
        if i == 1 then
            skillIcon:setScale(0.7)
            skillDes_show = GameConfig.getLanguage(skillData.describe)
            skillName_show = GameConfig.getLanguage(skillData.name)
            skillIndex = 1
        else
            panel_skill.txt_name:setString(GameConfig.getLanguage(skillData.name))
        end
        panel_skill.panel_number:setVisible(false)
        FilterTools.clearFilter(skillIcon)
        if starSkillMap[skillId] then
            if FuncCommon.isSystemOpen("treasure") then
                if starSkillMap[skillId].star > star then
                    FilterTools.setGrayFilter(skillIcon)
                end
            else
                FilterTools.setGrayFilter(skillIcon)
            end            
        else
            if weaponAwakeSkillId == skillId and not FuncPartner.checkWuqiAwakeSkill(self.partnerData) then
                FilterTools.setGrayFilter(skillIcon)
            elseif awakeSkillId == skillId and not FuncPartner.checkPartnerEquipSkill(self.partnerData, star, self.treasureId) then
                FilterTools.setGrayFilter(skillIcon)
            end
        end

        if i == 2 or i == 8 then
            FuncCommUI.regesitShowCharSkillTipView(skillIcon, {partnerId = self.partnerId,
                                id = skillId, level = UserModel:level(), index = skillIndex}, false)
        else
            FuncCommUI.regesitShowTreasureSkillTipView(skillIcon,
                    {treasureId = self.treasureId, skillId = skillId, index = skillIndex, data = data}, false)
        end
    end

    _view.txt_skillname:setString(skillName_show)
    _view.rich_skillxiangqing:setString(skillDes_show)
end

return WuXingPartnerDetailView;
