--[[
	Author: lxh
	Date:2018-05-02
	Description: 排行榜中奇侠排行信息查看界面
]]

local RankListPartnerInfoView = class("RankListPartnerInfoView", UIBase);

--由于战力榜RankListAbilityInfoView中点击奇侠可以跳转该界面 所以这种情况需要传_playerInfo， 奇侠榜点击传_itemData即可
function RankListPartnerInfoView:ctor(winName, _curSelectTag, _itemData, _playerInfo)
    RankListPartnerInfoView.super.ctor(self, winName)
    self.itemData = _itemData
    self.rankTagType = _curSelectTag
    self.playerInfo = _playerInfo
end

function RankListPartnerInfoView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
end 

function RankListPartnerInfoView:registerEvent()
	RankListPartnerInfoView.super.registerEvent(self);

	self.panel_bg.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function RankListPartnerInfoView:initData()
	self.panel_1:setVisible(false)
	self.panel_2:setVisible(false)
	self.panel_3:setVisible(false)
	self.panel_0:setVisible(false)
	--需要先判断是从哪里跳转过来的  如果是战力榜RankListAbilityInfoView 则直接加载界面
	if self.playerInfo then
		self:updateUI()
	else
		--如果是奇侠榜则先判断是否有缓存数据
		self.playerInfo = RankListModel:getCachePlayerInfoByRid(self.itemData.rid)
		if self.playerInfo then
			self:updateUI()
		else		
			local rid_string = string.split(self.itemData.rid, ":")
			local rid = tostring(rid_string[1])
			RankServer:getPlayInfo(rid, c_func(self.getPlayerInfoCallBack, self))
		end
	end
	
end

function RankListPartnerInfoView:getPlayerInfoCallBack(event)
	if event.result then
		self.playerInfo = event.result.data.data
		RankListModel:cachePlayerInfoByRid(self.itemData.rid, self.playerInfo)
		self:updateUI()
	else
		echoError("获取玩家信息返回数据报错")
	end
end

function RankListPartnerInfoView:initView()
	self.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_ranklisttitle_1002"))
end

function RankListPartnerInfoView:initViewAlign()
	-- TODO
end

function RankListPartnerInfoView:updateUI()
	if self.itemData.isChar then
		local garmentId = ""
		if self.playerInfo.userExt and self.playerInfo.userExt.garmentId then
			garmentId = self.playerInfo.userExt.garmentId
		end
		self.panel_0.ctn_1:removeAllChildren()
		local spine = GarmentModel:getSpineViewByAvatarAndGarmentId(self.playerInfo.avatar, garmentId, nil, self.itemData)
		self.panel_0.ctn_1:addChild(spine)
		local treasureId = "404"
		if self.playerInfo.treasureFormation then
			treasureId = self.playerInfo.treasureFormation["p1"]
		end
		self.panel_0.mc_nima:showFrame(4)

		local quaData = FuncPartner.getPartnerQuality(self.playerInfo.avatar)
		local nameColor = quaData[tostring(self.playerInfo.quality)].nameColor
		nameColor = string.split(nameColor, ",")
		self.panel_0.mc_1:showFrame(tonumber(nameColor[1]))
		if tonumber(nameColor[2]) > 1 then
			self.panel_0.mc_1.currentView.txt_1:setString(self.playerInfo.name.."+"..(nameColor[2] - 1))
		else
			self.panel_0.mc_1.currentView.txt_1:setString(self.playerInfo.name)
		end
		self.panel_0.mc_2:showFrame(tonumber(self.playerInfo.star))

		local ability = FuncChar.getCharPower(self.playerInfo, nil, treasureId)
		self.panel_0.panel_power.UI_power:setPower(ability)

		self:updateScrollView(treasureId)
	else
		local partnerId = self.itemData.partners.id
		local partnerData = self.itemData.partners
		local partnerCfgData = FuncPartner.getPartnerById(partnerId)
		local quaData = FuncPartner.getPartnerQuality(partnerId)

		self.panel_0.ctn_1:removeAllChildren()
		local spine = FuncPartner.getHeroSpineByPartnerIdAndSkin(partnerId, partnerData.skin, nil, partnerData)
		self.panel_0.ctn_1:addChild(spine)
		self.panel_0.mc_nima:showFrame(tonumber(partnerCfgData.type))

		local nameColor = quaData[tostring(partnerData.quality)].nameColor
		nameColor = string.split(nameColor, ",")
		self.panel_0.mc_1:showFrame(tonumber(nameColor[1]))
		if tonumber(nameColor[2]) > 1 then
			self.panel_0.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(partnerCfgData.name).."+"..(nameColor[2] - 1))
		else
			self.panel_0.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(partnerCfgData.name))
		end
		
		self.panel_0.mc_2:showFrame(tonumber(partnerData.star))
		local ability = 0
		if not self.itemData.score then
			ability = FuncPartner.getPartnerAbility(self.itemData.partners, self.playerInfo)
		else
			ability = self.itemData.score
		end
		self.panel_0.panel_power.UI_power:setPower(ability)

		self:updateScrollView(partnerData)
	end
	self.panel_0:setVisible(true)
end

-- --主角的属性详情
-- function RankListPartnerInfoView:updateCharRightDetailView(_treasureId)
-- 	--处理属性相关数据 并加载右侧属性信息
-- 	local attrs = FuncChar.getCharAttr(self.playerInfo, nil, _treasureId)
-- 	self:updateRightAttrInfo(attrs)

-- 	--处理装备相关数据 并加载右侧装备信息
-- 	local equipments = self.playerInfo.equips
-- 	local equipmentOrder = FuncPartner.getPartnerEquipment(self.playerInfo.avatar)
-- 	self:updateRightEquipmentInfo(equipments, equipmentOrder, self.playerInfo.avatar)

-- 	--处理主角仙术相关数据 并加载右侧仙术信息
-- 	local charSkill = FuncChar.getCharSkillId(self.playerInfo.avatar)
-- 	local treasureSkills = FuncTreasureNew.getTreasureSkills(_treasureId, self.playerInfo.avatar)
-- 	local skillStarMap = FuncTreasureNew.getStarSkillMap(_treasureId, self.playerInfo.avatar)
-- 	local treasureData = self.playerInfo.treasures[tostring(_treasureId)]
-- 	self.playerInfo.id = self.playerInfo.avatar
-- 	local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.playerInfo)

-- 	local skills_show = {}
-- 	local skillsNewMap = {}
-- 	for k,v in pairs(skillStarMap) do
-- 		local index = v.star
-- 		if index ~= 1 then
-- 			index = index + 1
-- 		end
-- 		skillsNewMap[index] = {skillId = v.skill, star = v.star, level = self.playerInfo.level, isTreasureSkill = true} 
-- 	end

-- 	skillsNewMap[2] = {skillId = charSkill, level = self.playerInfo.level, isCharSkill = true}
-- 	skillsNewMap[9] = {skillId = awakeSkillData.id, level = self.playerInfo.level, isAwake = equipAwake}
-- 	for i,v in ipairs(skillsNewMap) do
-- 		if v.isTreasureSkill then
-- 			if treasureData.star >= v.star then
-- 				table.insert(skills_show, v)
-- 			end
-- 		else
-- 			if v.isCharSkill then
-- 				table.insert(skills_show, v)
-- 			elseif v.isAwake then
-- 				table.insert(skills_show, v)		
-- 			end
-- 		end
-- 	end

-- 	self:updateRightSkillInfo(skills_show, treasureData)
-- end

function RankListPartnerInfoView:updateScrollView(_data)
	self.skill_show = {}
	if self.itemData.isChar then
		--处理主角仙术相关数据
		local charSkill = FuncChar.getCharSkillId(self.playerInfo.avatar)
		local treasureSkills = FuncTreasureNew.getTreasureSkills(_data, self.playerInfo.avatar)
		local skillStarMap = FuncTreasureNew.getStarSkillMap(_data, self.playerInfo.avatar)
		self.treasureData = self.playerInfo.treasures[tostring(_data)]
		self.playerInfo.id = self.playerInfo.avatar
		local _star = PartnerModel:getAwakenSkillStar(self.playerInfo.id)
		local treasureId = TeamFormationModel:getOnTreasureId()
		local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.playerInfo,_star,treasureId)
		
		local skillsNewMap = {}
		for k,v in pairs(skillStarMap) do
			local index = v.star
			if index ~= 1 then
				index = index + 1
			end
			skillsNewMap[index] = {skillId = v.skill, star = v.star, level = self.playerInfo.level, isTreasureSkill = true} 
		end

		skillsNewMap[2] = {skillId = charSkill, level = self.playerInfo.level, isCharSkill = true}
		skillsNewMap[9] = {skillId = awakeSkillData.id, level = self.playerInfo.level, isAwake = equipAwake}
		for i,v in ipairs(skillsNewMap) do
			if v.isTreasureSkill then
				if self.treasureData.star >= v.star then
					table.insert(self.skill_show, v)
				end
			else
				if v.isCharSkill then
					table.insert(self.skill_show, v)
				elseif v.isAwake then
					table.insert(self.skill_show, v)		
				end
			end
		end
	else
		--处理仙术相关数据 并加载右侧仙术信息
		local partnerId = self.itemData.partners.id
		local skills = _data.skills
		local _starSkillCondition={}
	    local _starInfos = FuncPartner.getStarsByPartnerId(partnerId)
	    for _key,_value in pairs(_starInfos) do
	        if _value.skillId ~= nil then
	            for k,v in pairs(_value.skillId) do
	                local _data = {skill = v,star = _key}
	                table.insert(_starSkillCondition, _data)
	            end
	        end
	    end
	    local _sortF = function(a,b)
	        if tonumber(a.star)<tonumber(b.star) then
	            return true
	        else
	            return false
	        end
	    end
	    table.sort(_starSkillCondition,_sortF)
	    local skill_keys = {}
	    for i,v in ipairs(_starSkillCondition) do
	    	local temp = skills[tostring(v.skill)]
	    	if temp then
	    		local tempSkill = {
					skillId = v.skill,
					level = temp,
				}
				skill_keys[tostring(v.skill)] = v.star
				table.insert(self.skill_show, tempSkill)
	    	end
	    end
	    
	    for k,v in pairs(skills) do
	    	if not skill_keys[tostring(k)] then
	    		local tempSkill = {
					skillId = k,
					level = v,
				}
				table.insert(self.skill_show, tempSkill)
	    	end
	    end
	end

	local offsetY = math.floor((#self.skill_show - 1) / 3) * 90
	local createFunc1 = function (_itemData)
		local view = UIBaseDef:cloneOneView(self.panel_1)
		self:updateRightDetailView(view, _itemData, _data)
		return view 
	end

	local createFunc2 = function (_itemData)
		local view = UIBaseDef:cloneOneView(self.panel_2)
		self:updateRightDetailView(view, _itemData, _data)
		return view 
	end

	local createFunc3 = function (_itemData)
		local view = UIBaseDef:cloneOneView(self.panel_3)
		self:updateRightDetailView(view, _itemData, _data)
		return view 
	end

	local params = {
		{	
			data = {1},
			createFunc = createFunc1,
			offsetX = 120,
			offsetY = 20,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -120, width = 320, height = 120},

		},
		{
			data = {2},
			createFunc = createFunc2,
			offsetX = 25,
			offsetY = -20,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -120, width = 320, height = 120},
		},
		{
			data = {3},
			createFunc = createFunc3,
			offsetX = 25,
			offsetY = -20,
			widthGap = 0,
			heightGap = 0,
			perFrame = 1,
			perNums = 1,
			itemRect = {x = 0, y = -(180 + offsetY), width = 320, height = 180 + offsetY},
		},
	}

	self.scroll_1:styleFill(params)
	self.scroll_1:hideDragBar()
end

function RankListPartnerInfoView:updateRightDetailView(_view, _itemData, data)
	if self.itemData.isChar then
		if _itemData == 1 then
			--处理属性相关数据 并加载右侧属性信息
			local attrs = FuncChar.getCharAttr(self.playerInfo, nil, data)
			self:updateRightAttrInfo(attrs, _view)
		elseif _itemData == 2 then
			--处理装备相关数据 并加载右侧装备信息
			local equipments = self.playerInfo.equips
			local equipmentOrder = FuncPartner.getPartnerEquipment(self.playerInfo.avatar)
			self:updateRightEquipmentInfo(equipments, equipmentOrder, self.playerInfo.avatar, _view)
		else
			--加载右侧仙术信息
			self:updateRightSkillInfo(self.skill_show, self.treasureData, _view)
		end
	else
		if _itemData == 1 then
			--处理属性相关数据 并加载右侧属性信息
			local skins = self.playerInfo.skins
			local baowuData = self.playerInfo.cimeliaGroups
			local lovesData = data.loves
			local globalLoveData = self.playerInfo.loveGlobal
			local siteAttr = nil
			local memory = self.playerInfo.memorys
			-- local attrs =  FuncPartner.getPartnerAttr(data, skins, baowuData, lovesData, globalLoveData, siteAttr, memory)
			local attrs =  FuncPartner.getPartnerAttribute( data,self.playerInfo,nil ) 
			self:updateRightAttrInfo(attrs, _view)
		elseif _itemData == 2 then
			--处理装备相关数据 并加载右侧装备信息
			local equipments = data.equips
			local partnerId = self.itemData.partners.id
			local equipmentOrder = FuncPartner.getPartnerEquipment(partnerId)
			self:updateRightEquipmentInfo(equipments, equipmentOrder, partnerId, _view)
		else
			
			self:updateRightSkillInfo(self.skill_show, nil, _view)
		end
	end	
end

--加载右侧属性信息
function RankListPartnerInfoView:updateRightAttrInfo(attrs, _view)
	local attr_show = {}
	for i,v in ipairs(attrs) do
		if v.key == 2 then
			attr_show[1] = v
		elseif v.key == 10 then
			attr_show[2] = v
		elseif v.key == 11 then
			attr_show[3] = v
		elseif v.key == 12 then
			attr_show[4] = v
		end
	end

	_view.panel_1:setVisible(false)
	for i = 1, 4, 1 do
		local attrGroup = attr_show[i]
		local panel_attr = UIBaseDef:cloneOneView(_view.panel_1)
		local attrKeyName = FuncBattleBase.getAttributeName(attrGroup.key)
		local attrValue = attrGroup.value
		local attr_str = attrKeyName.."："..attrValue
		panel_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attrGroup.key)])
		panel_attr.rich_1:setString(attr_str)
		panel_attr:addto(_view)
		local posX = -28 + (i - 1) % 2 * 168
		local posY = -58 - math.floor((i - 1) / 2) * 42
		panel_attr:pos(posX, posY)
	end
end

--加载右侧装备信息
function RankListPartnerInfoView:updateRightEquipmentInfo(equipments, equipmentOrder, partnerId, _view)
	local equipments_show = {}
	for i,v in ipairs(equipmentOrder) do
		local temp = equipments[tostring(v)]
		if temp then
			temp.partnerId = partnerId
			temp.index = i
			table.insert(equipments_show, temp)
		end
	end
	local tempEquip3 = equipments_show[4]
	equipments_show[4] = equipments_show[3]
	equipments_show[3] = tempEquip3

	_view.panel_1:setVisible(false)
	for i,v in ipairs(equipments_show) do
		local panel_equipment = UIBaseDef:cloneOneView(_view.panel_1)
		local equipmentCfg = FuncPartner.getEquipmentById(v.id)[tostring(v.level)]
		panel_equipment.mc_1:showFrame(equipmentCfg.quality)
		panel_equipment.txt_1:setString(equipmentCfg.showLv[1].key)
		local ctn = panel_equipment.mc_1.currentView.ctn_1
        local spriteName = FuncPartner.getEquipIconByIdAndAwake(v.partnerId, v.index, v.awake)
        local spr = cc.Sprite:create(FuncRes.iconPartnerEquipment(spriteName))
        spr:setScale(1)
        ctn:removeAllChildren()
        ctn:addChild(spr)

        panel_equipment:addto(_view)
        local posX = 10 + (i - 1) % 4 * 85
		local posY = -72 - math.floor((i - 1) / 4) * 70
		panel_equipment:pos(posX, posY)
		FuncCommUI.regesitShowEquipTipView(panel_equipment, v)
	end
end

--加载右侧仙术信息
function RankListPartnerInfoView:updateRightSkillInfo(skills_show, treasureData, _view)
	_view.panel_skill:setVisible(false)
	for i,v in ipairs(skills_show) do
		local panel_skill = UIBaseDef:cloneOneView(_view.panel_skill)
		local skillCfg = nil
		if v.isTreasureSkill then
			skillCfg = FuncTreasureNew.getTreasureSkillDataDataById(v.skillId)
		else
			skillCfg = FuncPartner.getSkillInfo(v.skillId)
		end
		-- panel_skill.panel_number.txt_1:setString(v.level)
		panel_skill.txt_1:setString(GameConfig.getLanguage(skillCfg.name))
		local skillSp = cc.Sprite:create(FuncRes.iconSkill(skillCfg.icon))
		skillSp:setScale(0.8)
		local index = 2
		if skillCfg.order == 3 then
	        -- panel_skill.mc_nzb:showFrame(1)
	        if skillCfg.priority == 1 then
	        	index = 1
				skillSp:setScale(0.6)
			end
	    elseif skillCfg.order == 2 then
	        -- panel_skill.mc_nzb:showFrame(2)
	    else
	        -- panel_skill.mc_nzb:showFrame(3)
	    end
        panel_skill.ctn_1:removeAllChildren()
        panel_skill.ctn_1:addChild(skillSp)

        panel_skill:addto(_view)
        local posX = -8 + (i - 1) % 3 * 110
		local posY = -88 - math.floor((i - 1) / 3) * 90
		panel_skill:pos(posX, posY)
		if self.itemData.partners then
			FuncCommUI.regesitShowSkillTipView(skillSp, {partnerId = self.itemData.partners.id, 
				id = v.skillId, level = v.level or 1, isUnlock = true, _index = index})
		else
			if v.isTreasureSkill and treasureData then
				FuncCommUI.regesitShowTreasureSkillTipView(skillSp, {treasureId = treasureData.id,
					skillId = v.skillId, index = index, data = treasureData, level = self.playerInfo.level})
			else
				FuncCommUI.regesitShowCharSkillTipView(skillSp, {partnerId = self.playerInfo.avatar, 
					id = v.skillId, level = self.playerInfo.level, index = 1})
			end
		end
		
	end
end

function RankListPartnerInfoView:deleteMe()
	-- TODO

	RankListPartnerInfoView.super.deleteMe(self);
end

return RankListPartnerInfoView;
