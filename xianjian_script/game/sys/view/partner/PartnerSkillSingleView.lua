--[[
	Author: Long Xiaohua
	Date:2017-08-10
	Description: TODO
]]

local PartnerSkillSingleView = class("PartnerSkillSingleView", UIBase);

function PartnerSkillSingleView:ctor(winName, _skillId, _partnerInfo, _notObtain)
    PartnerSkillSingleView.super.ctor(self, winName)
    self.skillId = _skillId
    self.partnerId = _partnerInfo.id
    self.partnerInfo = _partnerInfo
    self._notObtain = _notObtain
end

function PartnerSkillSingleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
end 

function PartnerSkillSingleView:registerEvent()
	PartnerSkillSingleView.super.registerEvent(self);

    local coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self.ctn_bg, 0)
    coverLayer:pos(-GameVars.width / 2,  GameVars.height / 2)
    coverLayer:setTouchedFunc(function ()
            self.panel_skilltips:fadeOut(0.4)
            self.ctn_bg:setVisible(false)
        end)
    coverLayer:setTouchSwallowEnabled(true)
    self.ctn_bg:setVisible(false) 
       
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self:registClickClose("out")
    -- 监听仙术等级的变化及时刷新UI
	EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT, self.updateUI, self)
    EventControler:addEventListener(TreasureNewEvent.UP_STAR_SUCCESS_EVENT, self.updateUI, self)
    EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.updateUI, self)
end

function PartnerSkillSingleView:initData()
    self.posY = self.rich_1:getPositionY()

    if not self._notObtain then
        local _star = PartnerModel:getAwakenSkillStar(self.partnerId)
        self.treasureId = TeamFormationModel:getOnTreasureId()
        
        local isWuqiAwake, wuqiSkillData = FuncPartner.checkWuqiAwakeSkill(self.partnerInfo)
        local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.partnerInfo,_star,self.treasureId)

        if tostring(awakeSkillData.id) == tostring(self.skillId) then
            self.isAwakenSkill = true
            self.equipAwake = equipAwake
            self.skillInfo = awakeSkillData
        end

        if tostring(wuqiSkillData.id) == tostring(self.skillId) then
            self.isWeaponAwakenSkill = true
            self.isWuqiAwake = isWuqiAwake
            self.skillInfo = wuqiSkillData
        end

        if not self.skillInfo then
            if FuncPartner.isChar(self.partnerId) and not FuncChar.isCharskill(self.partnerId, self.skillId) then
                self.skillInfo = FuncTreasureNew.getTreasureSkillDataDataById(tostring(self.skillId))
            else
                self.skillInfo = FuncPartner.getSkillInfo(self.skillId)
            end
        end    
        
        self.partnerData = PartnerModel:getPartnerDataById(self.partnerId)
        self.partnerLevel = self.partnerData["level"]
        self.oldPower = CharModel:getCharOrPartnerAbility(self.partnerId)
        self.curPower = CharModel:getCharOrPartnerAbility(self.partnerId)
        self:initView()
        self:updateUI()
    else
        self:initView()
        self:updateNotObtainPartnerSkillView()
    end
    self:updateSkillIcon()
end

--未获得奇侠时仙术展示特殊处理
function PartnerSkillSingleView:updateNotObtainPartnerSkillView()
    local weaponAwakeSkillId = self.partnerInfo.weaponAwakeSkillId
    local awakeSkillId = self.partnerInfo.awakeSkillId
    local starConditions = self:starSkillCondition()
    self.skillInfo = FuncPartner.getSkillInfo(self.skillId)
    local _iconPath = FuncRes.iconSkill(self.skillInfo.icon)
    self._iconSprite = cc.Sprite:create(_iconPath)
    local skillName = GameConfig.getLanguage(self.skillInfo.name)
    local skillLevel = 1
    local description = GameConfig.getLanguage(self.skillInfo.describe)
    local description2 =  FuncPartner.getPartnerSkillDesc(self.skillId, skillLevel)
    
    -- self.txt_2:setVisible(false)
    self.mc_qian:setVisible(false)
    self.mc_qian2:setVisible(false)
    self.mc_man:setVisible(false)
    self.panel_nuqi:setVisible(false)
    self.txt_3:setVisible(false)
    self.panel_level:setVisible(false)
       
    local _, height = self.rich_up:setStringByAutoSize(description, 0)
    if description2 == nil then
        description2 = ""
    end

    if self.skillId == weaponAwakeSkillId then
        self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
    elseif self.skillId == awakeSkillId then
        self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
    else
        local starCondition = starConditions[tostring(self.skillId)]
        self.txt_2:setString(GameConfig.getLanguageWithSwap("#tid_partner_ui_034", starCondition))
    end

    -- self.rich_1:setString(description2)
    self.desWidth, self.desHeight = self.rich_1:setStringByAutoSize(description2, 0)
    self.rich_1:setPositionY(self.posY + 90 - height)
    
    -- order为4，5，6，7时为被动技能
    if self.skillInfo.order == 2 then
        self.mc_zd:showFrame(3)
        self._type = 3
    elseif self.skillInfo.order == 3 then
        if self.skillInfo.priority == 1 then
            self._iconSprite:setScale(0.69)
            self.panel_nuqi:setVisible(true)
            self.txt_3:setVisible(true)
            local attrData = FuncPartner.getInitAttr(self.partnerInfo)
            local energyCost = 0
            for i,v in ipairs(attrData) do
                if tostring(v[1].key) == "5" then
                    energyCost = v[1].value
                    break
                end
            end

            self.txt_3:setString(energyCost)
            self.mc_zd:showFrame(1)
            self._type = 1
        else
            self.mc_zd:showFrame(2)
            self._type = 2
        end            
    else
        self.mc_zd:showFrame(4)
        self._type = 4
    end

    self.txt_1:setString(skillName)
end

function PartnerSkillSingleView:initView() 
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_021"))
    self.UI_1.mc_1:setVisible(false)
    self.panel_skilltips:opacity(0)
end

function PartnerSkillSingleView:initViewAlign()
	-- TODO
end

function PartnerSkillSingleView:isTreasureSkill()
    if self.isAwakenSkill and FuncPartner.isChar(self.partnerId) then
        return true
    end

    local avatar = UserModel:avatar()
    local treasureSkills = FuncTreasureNew.getTreasureSkills(self.treasureId,avatar)

    for i,v in ipairs(treasureSkills) do
        if tostring(self.skillId) == tostring(v)  then
            return true
        end
    end

    return false
end

function PartnerSkillSingleView:isNuqiSkill(_skillId)
    local treasureSkills = FuncTreasureNew.getTreasureSkills(self.treasureId)
    for i,v in ipairs(treasureSkills) do
        if tostring(_skillId) == tostring(v) and (i == 3 or i == 6 or i == 1) then
            return true
        end
    end
    return false
end

function PartnerSkillSingleView:isTreasureSkillLocked()
    if FuncPartner.isChar(self.partnerId) and self.isAwakenSkill then
        return not self.equipAwake
    end 
    local treasureData = TreasureNewModel:getTreasureData(self.treasureId)
    local star_skill = TreasureNewModel:getStarSkillMap(self.treasureId)
    local treasureStar = treasureData.star
    if tonumber(star_skill[tostring(self.skillId)].star) > tonumber(treasureStar) then
        return true, star_skill[tostring(self.skillId)].star
    end

    return false, star_skill[tostring(self.skillId)].star
end

function PartnerSkillSingleView:getEnergyCostById(_partnerId)
    local attrData
    if tonumber(_partnerId) == 1 then
        local charAttrData = CharModel:getCharAttr()
        attrData = FuncBattleBase.formatAttribute(charAttrData)
    else    
        local partnerData = PartnerModel:getPartnerAttr(tostring(_partnerId))
        attrData = FuncBattleBase.formatAttribute(partnerData)
    end
    local energyCost = 0
    -- 5  对应怒气消耗值
    for i,v in ipairs(attrData) do
        if tostring(v.key) == "5" then
            energyCost = v.value
            break
        end
    end
    return energyCost
end

--主角仙术加载
function PartnerSkillSingleView:updateCharSkillView()
    local charData = PartnerModel:getPartnerDataById(tostring(self.partnerId))
    local skillLevel = charData.level
    local _iconPath = FuncRes.iconSkill(self.skillInfo.icon)
    self._iconSprite = cc.Sprite:create(_iconPath)
    local skillName = GameConfig.getLanguage(self.skillInfo.name)
    local description = GameConfig.getLanguage(self.skillInfo.describe)
    local description2 = ""
    
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) == false 
        or FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PARTNER_SKILL) == false then
        skillLevel = 1
    end

    if not self:isTreasureSkill() then
        description2 = FuncPartner.getPartnerSkillDesc(self.skillId, skillLevel)
        if self.isWeaponAwakenSkill then
            if self.isWuqiAwake then
                self.txt_2:setString("")
                self.panel_level.txt_level:setString(skillLevel)
                self.panel_level:setVisible(true)
                -- self.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_006")..skillLevel)
                self.mc_man:setVisible(true)
                self.mc_man:showFrame(3)
            else
                self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
                self.mc_man:setVisible(false)
            end
        else
            self.txt_2:setString("")
            self.panel_level.txt_level:setString(skillLevel)
            self.panel_level:setVisible(true)
            -- self.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_006")..skillLevel)
            self.mc_man:setVisible(true)
            self.mc_man:showFrame(3)               
        end
        self.mc_zd:showFrame(3)
        self._type = 3                   
    else
        local isLocked, star = self:isTreasureSkillLocked()
        self.mc_man:setVisible(true)
        description2 = FuncTreasureNew.getDescriptionBySkillId(self.skillId, skillLevel)
        if  isLocked == false then
            self.txt_2:setString("")
            self.panel_level.txt_level:setString(skillLevel)
            self.panel_level:setVisible(true)
            -- self.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_006")..skillLevel)
            self.mc_man:showFrame(3)
        else
            if self.isAwakenSkill then
                self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
            else
                self.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_015")..star..GameConfig.getLanguage("#tid_partner_ui_014"))
            end 
            self.mc_man:showFrame(2)
            self.mc_man.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_partner_ui_022"))
            self.mc_man.currentView.btn_1:setTouchedFunc(function ()
                if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TREASURE_NEW) then
                    WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
                else    
                    WindowControler:showWindow("TreasureMainView", self.treasureId)
                end
            end)
        end

        if self.skillInfo.order == 3 then 
            if self.skillInfo.priority == 1 then
                self._iconSprite:setScale(0.69)
                self.panel_nuqi:setVisible(true)
                self.txt_3:setVisible(true)
                local energy = self:getEnergyCostById("1")
                self.txt_3:setString(tostring(energy))
                self.mc_zd:showFrame(1)
                self._type = 1

                self.panel_nuqi:setPositionY(-165)
                self.txt_3:setPositionY(-165)
            else                   
                self.mc_zd:showFrame(2)
                self._type = 2
            end
        else
            self.mc_zd:showFrame(4)
            self._type = 4
        end
    end

    self.txt_1:setString(skillName)
    self.mc_qian:setVisible(false)
    self.mc_qian2:setVisible(false)
    local _, height = self.rich_up:setStringByAutoSize(description, 0)
    if description2 == nil then
        description2 = ""
    end
    -- self.rich_1:setString(description2)
    self.desWidth, self.desHeight = self.rich_1:setStringByAutoSize(description2, 0)
    self.rich_1:setPositionY(self.posY + 90 - height)
end

--奇侠仙术加载
function PartnerSkillSingleView:updatePartnerSkillView()
    -- dump(self.skillInfo, "\n\nself.skillInfo====")
    local _iconPath = FuncRes.iconSkill(self.skillInfo.icon)
    self._iconSprite = cc.Sprite:create(_iconPath)
    local skillName = GameConfig.getLanguage(self.skillInfo.name)
    local skillLevel = self:getSkillLevel(self.skillId)
    local description = GameConfig.getLanguage(self.skillInfo.describe)
    local description2 = nil

    local level = skillLevel
    if level == 0 then
        -- 仙术未解锁时技能描述按1级时展示
        level = level + 1
        description2 =  FuncPartner.getPartnerSkillDesc(self.skillId, level)
    else
        description2 =  FuncPartner.getPartnerSkillDesc(self.skillId, level)
    end
    
    self._starSkillCondition = self:starSkillCondition()

    local coinCost = self:getSkillUpCoin()
    local oneKeyCost, tempLevel = self:getSkillUpCoin(true)

    if skillLevel == 0 then
        -- 仙术未解锁时花费为0，显示几星解锁
        coinCost = 0
        oneKeyCost = 0
        if self.isAwakenSkill then
            self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_008"))
        elseif self.isWeaponAwakenSkill then
            self.txt_2:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
        else
            self.txt_2:setString(GameConfig.getLanguageWithSwap("#tid_partner_ui_034", self._starSkillCondition[self.skillId]))
        end
    else
        self.txt_2:setString("")
        self.panel_level.txt_level:setString(skillLevel)
        self.panel_level:setVisible(true)
        -- self.txt_2:setString(GameConfig.getLanguage("#tid_partner_ui_006")..skillLevel)
    end
       
    local _, height = self.rich_up:setStringByAutoSize(description, 0)
    if description2 == nil then
        description2 = ""
    end
    -- self.rich_1:setString(description2)
    self.desWidth, self.desHeight = self.rich_1:setStringByAutoSize(description2, 0)
    self.rich_1:setPositionY(self.posY + 90 - height)   

    if skillLevel == FuncPartner.maxPartnerLevel then
        -- 仙术等级已达上限显示  已圆满
        self.mc_man:setVisible(true)
        self.mc_man:showFrame(3)
    elseif skillLevel == self.partnerLevel then
        self.mc_man:setVisible(true)
        self.mc_man:showFrame(1)
    elseif skillLevel == 0 then
        -- 仙术未解锁时 修炼按钮不可见
        self.mc_man:setVisible(false)
    else
        self.mc_man:setVisible(true)
        self.mc_man:showFrame(1)
        self.mc_man.currentView.btn_1:setTouchEnabled(true)
        self.mc_man.currentView.btn_2:setTouchEnabled(true)
    end

    if coinCost == 0 then
        self.mc_qian:setVisible(false)
        self.canXiuLian = false
    else
        -- 判断是否可以升级
        self.mc_qian:setVisible(true)
        self.canXiuLian = false
        local userCoin = UserModel:getCoin()
        if coinCost <= userCoin then
            self.mc_qian:showFrame(1)
            self.canXiuLian = true
        else
            self.mc_qian:showFrame(2)
        end            
        self.mc_qian.currentView.txt_1:setString(coinCost)
    end

    self.mc_man:getViewByFrame(1).btn_1:setTap(c_func(self.onTouchXiuLian, self, false))
    
    if oneKeyCost == 0 then
        self.mc_qian2:setVisible(false)
        self.canOneKey = false
    else
        -- 一键升级
        self.mc_qian2:setVisible(true)
        self.canOneKey = false

        local userCoin = UserModel:getCoin()
        if oneKeyCost <= userCoin then
            self.mc_qian2:showFrame(1)
            self.canOneKey = true
        else
            self.mc_qian2:showFrame(2)
        end 
          
        self.mc_qian2.currentView.txt_1:setString(oneKeyCost) 
    end
    self.mc_man:getViewByFrame(1).btn_2:setTap(c_func(self.onTouchXiuLian, self, true))

    -- order为4，5，6，7时为被动技能
    if self.skillInfo.order == 2 then
        self.mc_zd:showFrame(3)
        self._type = 3
    elseif self.skillInfo.order == 3 then
        if self.skillInfo.priority == 1 then
            self._iconSprite:setScale(0.69)
            self.panel_nuqi:setVisible(true)
            self.txt_3:setVisible(true)
            local energy = self:getEnergyCostById(self.partnerId)
            self.txt_3:setString(tostring(energy))
            self.mc_zd:showFrame(1)
            self._type = 1

            self.panel_nuqi:setPositionY(-165)
            self.txt_3:setPositionY(-165)
        else
            self.mc_zd:showFrame(2)
            self._type = 2
        end            
    else
        self.mc_zd:showFrame(4)
        self._type = 4
    end
    
    self.txt_1:setString(skillName)
end

-- 更新UI界面
function PartnerSkillSingleView:updateUI()
    if self._notObtain then
        return
    end
    self.panel_level:setVisible(false)
    self.panel_nuqi:setVisible(false)
    self.txt_3:setVisible(false)
    if tonumber(self.partnerId) < 5000 then
        self:updateCharSkillView()
    else
        self:updatePartnerSkillView()
    end	
end

function PartnerSkillSingleView:updateSkillIcon()
    self:updateSkillTips()
    self.panel_skill1.ctn_1:addChild(self._iconSprite)
    self.mc_zd.currentView:setTouchedFunc(function ()
            self.ctn_bg:setVisible(true)
            self.panel_skilltips:fadeIn(0.2)  
        end)
end

--需要配表
function PartnerSkillSingleView:updateSkillTips()
    if self._type == 1 then
        -- self.panel_skilltips.rich_1:setString(GameConfig.getLanguage(self.skillInfo.dis))
        self.panel_skilltips.rich_1:setString("")
        self.panel_skilltips.txt_2:setString(GameConfig.getLanguage("#tid_partner_skilltips_004"))
    elseif self._type == 2 then
        -- self.panel_skilltips.rich_1:setString(GameConfig.getLanguage(self.skillInfo.dis))
        self.panel_skilltips.rich_1:setString("")
        self.panel_skilltips.txt_2:setString(GameConfig.getLanguage("#tid_partner_skilltips_003"))
    elseif self._type == 3 then
        -- self.panel_skilltips.rich_1:setString(GameConfig.getLanguage(self.skillInfo.dis))
        self.panel_skilltips.rich_1:setString("")
        self.panel_skilltips.txt_2:setString(GameConfig.getLanguage("#tid_partner_skilltips_001"))
    elseif self._type == 4 then
        -- self.panel_skilltips.rich_1:setString(GameConfig.getLanguage(self.skillInfo.dis))
        self.panel_skilltips.rich_1:setString("")
        self.panel_skilltips.txt_2:setString(GameConfig.getLanguage("#tid_partner_skilltips_002"))
    end
end

-- 仙术与伙伴星级的关系统计
function PartnerSkillSingleView:starSkillCondition()
    local _starSkillCondition={}
    local _starInfos = FuncPartner.getStarsByPartnerId(self.partnerId)
    for _key,_value in pairs(_starInfos) do
        if _value.skillId ~= nil then
            for k,v in pairs(_value.skillId) do
                _starSkillCondition[v] = tonumber(_key)
            end
        end
    end

    return _starSkillCondition
end

-- 获取当前仙术的等级
function PartnerSkillSingleView:getSkillLevel()
	local skills = PartnerModel:getPartnerDataById(tostring(self.partnerId)).skills
	local level = 0
	for key, value in pairs(skills) do
		if self.skillId == key then
			level = value
		end
	end
	return level
end

-- 获取当前仙术升一级需要的铜钱
function PartnerSkillSingleView:getSkillUpCoin(isOneKey)
	local upSkillCost = FuncPartner.getSkillCostInfo(tostring(self.skillInfo.quality))
	local skillLevel = self:getSkillLevel()
	local realCost = 0
    local tempLevel = 0
	if skillLevel == 0 then
		skillLevel = 1
	end    
    if skillLevel == self.partnerLevel then
    	realCost = 0
    else
        if isOneKey then
            for i = skillLevel, self.partnerLevel - 1 do
                realCost = upSkillCost[tostring(i)].coin + realCost
                tempLevel = tempLevel + 1
            end
        else
            realCost = upSkillCost[tostring(skillLevel)].coin
            tempLevel = 1
        end	
    end
    return realCost, tempLevel
end

-- 点击修炼按钮
function PartnerSkillSingleView:onTouchXiuLian(isOneKey)
    local canXiuLian = self.canXiuLian
    if isOneKey then
        canXiuLian = self.canOneKey
    end

    local coinCost, level = self:getSkillUpCoin(isOneKey)

    if canXiuLian then
        AudioModel:playSound(MusicConfig.s_skill_xiulian, false)
        -- isAll传0为单独修炼，需要传入当前的仙术id和等级
        PartnerServer:skillLevelupRequest({partnerId = tonumber(self.partnerId), skillId = self.skillId, level = level, isAll = 0}, c_func(self.skillUp, self))
    else
        if coinCost > 0 then
            FuncCommUI.showCoinGetView() 
            local tips = GameConfig.getLanguage("tid_common_2021")
            WindowControler:showTips(tips)
        else
            WindowControler:showTips("提升奇侠等级可继续升级")
        end
    end
end

-- 技能升级时刷新当前界面
function PartnerSkillSingleView:skillUp(_param)
    EventControler:dispatchEvent(PartnerEvent.PARTNER_SKILL_UP_EVENT, {_type = "single"})
	self:updateUI()
    self.curPower = CharModel:getCharOrPartnerAbility(self.partnerId)
    local oldPower = self.oldPower
    local curPower = self.curPower
    local powerChange = function ()       
        FuncCommUI.showPowerChangeArmature(oldPower or 10, curPower or 10);
        self.oldPower = self.curPower
    end

    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAMLL_BAO, self.ctn_level, 
                                                            nil, nil, nil, c_func(powerChange))

    -- self:delayCall(function ()
    --             powerChange()
    --     end, 15/GameVars.GAMEFRAMERATE)

    local positionY = self.rich_1:getPositionY()
    local offsetX = self.desWidth / 2
    local offsetY = positionY - self.desHeight / 2 + 2
    local scale = {x = self.desWidth / 240, y = self.desHeight / 75} --self.desHeight / 25
    FuncCommUI.addAttentionAnim(FuncPartner.ATTENTION_ANIM_NAME.SAOGUANG, self.ctn_zi, offsetX, offsetY, scale)
end

function PartnerSkillSingleView:close()
	self:startHide()
end

function PartnerSkillSingleView:startHide()
    PartnerSkillSingleView.super.startHide(self)
    if self.oldPower ~= self.curPower then
        FuncCommUI.showPowerChangeArmature(self.oldPower or 10, self.curPower or 10);
    end   
end

function PartnerSkillSingleView:deleteMe()
	-- TODO

	PartnerSkillSingleView.super.deleteMe(self);
end

return PartnerSkillSingleView;
