

local PartnerEquipAwakInfoView = class("PartnerEquipAwakInfoView", UIBase);


function PartnerEquipAwakInfoView:ctor(winName, params)
    PartnerEquipAwakInfoView.super.ctor(self, winName);
    self.partnerId = params.partnerId or "5002"
    self.equipId = params.equipId or "20010"
    self.awakeEquipId = params.awakeEquipId or "30001"

end

function PartnerEquipAwakInfoView:loadUIComplete()
	self:registerEvent();
	self:updateUI();
end 

function PartnerEquipAwakInfoView:registerEvent()
	PartnerEquipAwakInfoView.super.registerEvent();

	self:registClickClose("out")
    self.btn_close:setTap(c_func(self.close,self))

end

function PartnerEquipAwakInfoView:updateUI()
	local partnerData = PartnerModel:getPartnerDataById(self.partnerId)
	local equipData = partnerData.equips[self.equipId]
	local equipCfg = FuncPartner.getEquipmentById(self.equipId)
    equipCfg = equipCfg[tostring(equipData.level)]
    -- 装备名称
    -- local nameColor = equipCfg.nameColor
    -- nameColor = string.split(nameColor,",")
    -- self.mc_name1:showFrame(tonumber(nameColor[1]))
    -- local _equipName = FuncPartner.getEquipmentName( self.equipId,self.partnerId )
    -- local _equipAwakeName = FuncPartnerEquipAwake.getEquipAwakeName( self.awakeEquipId )
    -- if tonumber(nameColor[2]) > 1 then
    --     local colorNum = tonumber(nameColor[2]) - 1
    --     self.mc_name1.currentView.txt_1:setString(GameConfig.getLanguage(_equipAwakeName).." +"..colorNum)
    -- else

    --     self.mc_name1.currentView.txt_1:setString(GameConfig.getLanguage(_equipAwakeName))
    -- end 
    local _equipAwakeName = FuncPartnerEquipAwake.getEquipAwakeName( self.awakeEquipId )
    self.txt_name:setString(GameConfig.getLanguage(_equipAwakeName))
    -- 装备icon
    local ctn1 = self.ctn_1
    local index = FuncPartner.getEquipIndexById( self.partnerId,self.equipId )

	local sprPath1 = FuncRes.iconPartnerEquipment(FuncPartnerEquipAwake.getEquipAwakeIcon(self.awakeEquipId ))
    echo("路径 ==== ",sprPath1)
    local spr1= cc.Sprite:create(sprPath1) 
    spr1:setScale(1) 
    spr1:pos(-1, 45)
    ctn1:removeAllChildren()
    ctn1:addChild(spr1)


    local anim = self:createUIArmature("UI_shop", "UI_shop_zhuangbeijuexing",  ctn1, true, GameVars.emptyFunc)
    anim:setScale(1.1)
    anim:pos(0, 50)
    -- 觉醒的技能
    local partnerCfg = FuncPartner.getPartnerById(self.partnerId)
    local skillId = nil
    local skillInfo = nil
    local isTreasureSkill = false
    if self.equipId == FuncPartner.getPartnerWuqiId(self.partnerId) then
        self.txt_jihuotps:setString(GameConfig.getLanguage("#tid_partner_awaken_007"))
        if FuncPartner.isChar(self.partnerId) then
            skillId = partnerCfg.awakeSkillId
        else
            skillId = partnerCfg.weaponAwakeSkillId
        end
        skillInfo = FuncPartner.getSkillInfo(skillId)
    else
        self.txt_jihuotps:setString(GameConfig.getLanguage("#tid_partner_awaken_005"))
        if FuncPartner.isChar(self.partnerId) then
            local treasureId = TeamFormationModel:getOnTreasureId()
            skillId = FuncTreasureNew.getTreasureAwakeSkillId(treasureId, self.partnerId)
            skillInfo = FuncTreasureNew.getTreasureSkillDataDataById(skillId)
            isTreasureSkill = true
        else
            skillId = partnerCfg.awakeSkillId
            skillInfo = FuncPartner.getSkillInfo(skillId)
        end  
    end
    --图标
    local  skillPath = FuncRes.iconSkill(skillInfo.icon)
    local  skillSprite = cc.Sprite:create(skillPath)
    self.panel_1.mc_skill:showFrame(1)
    local skillCtn = self.panel_1.mc_skill.currentView.ctn_1
    skillSprite:setScale(1.4)
    skillCtn:removeAllChildren()
    skillCtn:addChild(skillSprite)

    -- name
    self.txt_1:setString(GameConfig.getLanguage(skillInfo.name))

    if isTreasureSkill then
        local treasureId = TeamFormationModel:getOnTreasureId()
        local data = TreasureNewModel:getTreasureData(treasureId)
        FuncCommUI.regesitShowTreasureSkillTipView(skillSprite,
              {treasureId = treasureId, skillId = skillId, data = data}, false)
    else
        FuncCommUI.regesitShowSkillTipView(skillSprite,{partnerId = self.partnerId, id = skillId, level = 1 ,isUnlock = false},false)
    end
    --描述

    
    --消耗
    local costT = FuncPartnerEquipAwake.getEquipAwakeCost( self.awakeEquipId )
    -- 暂时写俩
    self.UI_item1:visible(false)
    self.UI_item2:visible(false)
    for i=1,#costT do
    	if i > 2 then
    		break
    	end
    	local panel = self["UI_item"..i]
    	panel:visible(true)
    	panel:setRewardItemData({reward = costT[i]})
    	local resNum,_,_ ,resType,resId = UserModel:getResInfo( costT[i] )
    	FuncCommUI.regesitShowResView(panel,resType,resNum,resId,costT[i],true,true)
    end

    -- 觉醒按钮
    -- 判断是否已觉醒
    if PartnerModel:checkEquipAwakeById( self.partnerId,self.equipId ) then
    	self.txt_5:visible(false)
    	self.mc_juexing:showFrame(2)
    else
    	self.txt_5:visible(false)
    	self.mc_juexing:showFrame(1)

    	-- 判断是否可觉醒
    	local btn = self.mc_juexing.currentView.btn_1
    	local isCan,_type,resId = self:checkEquipAwake()
    	if isCan then
    		FilterTools.clearFilter(btn)
    	else
    		FilterTools.setGrayFilter(btn)
    	end
        if _type ~= 1 then
            self.txt_5:visible(false)
        else
            self.txt_5:visible(true)
        end
    	btn:setTap(c_func(self.equipAwakeTap,self))
    end

    -- 属性显示 
    self:attrShow()

end

function PartnerEquipAwakInfoView:attrShow( )
    local partnerData = PartnerModel:getPartnerDataById(self.partnerId)
    local equData = FuncPartner.getEquipmentById(self.equipId)
    local equipData = partnerData.equips[self.equipId]
    equData = equData[tostring(equipData.level)]
    --加成
    local awakeId = FuncPartner.getAwakeEquipIdByid( self.partnerId,self.equipId )
    local plusVec = FuncPartnerEquipAwake.getEquipsAttrById( partnerData,self.equipId,false )
    local awakeVec = FuncPartnerEquipAwake.getEquipsAttrById( partnerData,self.equipId,true ) 
    dump(plusVec, "====plusVec====", 4)
    dump(awakeVec, "====awakeVec====", 4)
    for i=1,4 do
        self["panel_sx"..i]:visible(false)
    end
    local t = {}
    local index = 1
    for i,v in pairs(plusVec) do
        if index <= 4 then
            local panel = self["panel_sx"..index]
            panel:visible(true)
            local name,value1 = FuncPartnerEquipAwake.getNameAndValueStaheTable(v)
            panel.txt_1:setString(name)
            panel.txt_2:setString(v.value)
            local value3 = v.value
            for ii,vv in pairs(awakeVec) do
                if tostring(vv.key) == tostring(v.key) then
                    value3 = vv.value - value3
                end
            end
            panel.txt_3:setString("+"..value3)
            index = index + 1
        end
    end
    for i,v in pairs(awakeVec) do 
        if index <= 4 then
            local isHav = false
            for ii,vv in pairs(plusVec) do
                if tostring(vv.key) == tostring(v.key) then
                    isHav = true
                    table.insert(t,vv)
                end
            end
            if not isHav then
                local panel = self["panel_sx"..index]
                panel:visible(true)
                local name,value2 = FuncPartnerEquipAwake.getNameAndValueStaheTable(v)
                panel.txt_1:setString(name)
                panel.txt_2:setString(0)
                panel.txt_3:setString("+"..v.value)
                index = index + 1
                local data = {
                    attrOrderId = v.attrOrderId,
                    key = v.key,
                    name = v.name,
                    value = 0

                }
                table.insert(t,data)
            end
        end
    end
    
    -- 战力
    local power1 = self:equipPower( equipData )
    local power2 = self:equipPower( equipData,true ) + FuncPartnerEquipAwake.getEquipAwakeAbility( awakeId )
    self.UI_1:setPower(power1)
    self.UI_2:setPower(power2)

    self.beforPower = power1
    self.afterPower = power2

    self.beforAttr = t
    self.afterAttr = awakeVec
end
function PartnerEquipAwakInfoView:equipPower( equipData,isAwake )
    local equCfgData = FuncPartner.getEquipmentById(equipData.id)
    local _ability = 0
    local equCfg = equCfgData[tostring(equipData.level)]
    local sunAbility = equCfg.subAbility
    if isAwake then
        _ability = _ability + sunAbility[2]
    else
        _ability = _ability + sunAbility[1]
    end

    return _ability
end
function PartnerEquipAwakInfoView:equipAwakeTap( ... )
	local isCan,_type,resId = self:checkEquipAwake()
	if isCan then
		if FuncPartner.isChar(self.partnerId) then
			local param = {}
	        local index = FuncPartner.getEquipIndexById( self.partnerId,self.equipId )
	        param.index = index - 1
			CharServer:equipAwake(param,c_func(self.equipAwakeTapCallBack,self))
		else
			local param = {}
	        param.partnerId = self.partnerId
	        local index = FuncPartner.getEquipIndexById( self.partnerId,self.equipId )
	        param.index = index - 1
	        PartnerServer:equipAwakeRequest(param, c_func(self.equipAwakeTapCallBack,self))
		end
	else
		if _type == 1 then
			WindowControler:showTips(resId)
		elseif _type == 2 then
            local itemName = FuncItem.getItemName(resId)
			WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_partner_36",itemName))
            WindowControler:showWindow("GetWayListView", resId);
		elseif _type == 3 then
			WindowControler:showTips(GameConfig.getLanguage("#tid_partner_awakename_tips_02"))
            FuncCommUI.showCoinGetView() 
		end
	end
end

function PartnerEquipAwakInfoView:showAwakenShowView( )
    local data = {
        partnerId = self.partnerId,
        equipId = self.equipId,
        awakeEquipId = self.awakeEquipId,
        before = {
            power = self.beforPower,
            beforeAttr = table.deepCopy(self.beforAttr)
        },
        after = {
            power = self.afterPower,
            afterAttr = table.deepCopy(self.afterAttr)
        }
    }
    WindowControler:showWindow("PartnerEquipAwakenShowView",data)
end

function PartnerEquipAwakInfoView:equipAwakeTapCallBack(event)
	if event.result then
		echo("觉醒成功-==------------")
        EventControler:dispatchEvent(PartnerEvent.PARTNER_EQUIPMENT_AWAKE_EVENT);
		self:close()

        self:showAwakenShowView()

	end
end
-- 0 满足 1等级不足 2,消耗不足 3,金币不足
function PartnerEquipAwakInfoView:checkEquipAwake()
    local _unlock,_type,_tips = PartnerModel:canAwake( self.partnerId,self.equipId )
	if _unlock then
		local costT = FuncPartnerEquipAwake.getEquipAwakeCost( self.awakeEquipId )
		local resType,resId = UserModel:isResEnough(costT)
		if not resId and resType == true then
			return true
		else
			if tonumber(resType) == 1 then
				return false,2,resId
			elseif tonumber(resType) == 3 then
				return false,3,resId
			end
		end
	else
		return false,1,_tips
	end
end

function PartnerEquipAwakInfoView:close()
	self:startHide()
end

return PartnerEquipAwakInfoView;
