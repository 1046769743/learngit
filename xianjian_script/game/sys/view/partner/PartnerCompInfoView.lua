--[[
	Author: xd
	Date:2018-08-01
	Description: 通用伙伴信息展示弹窗
]]

local PartnerCompInfoView = class("PartnerCompInfoView", UIBase);

--[[
传入通用伙伴信息数据 以及userInfo
如果不希望附带加成 比如神器 等属性 那么userInfo传入空table
partnerInfo 如果是我未拥有的伙伴, 那么构造数据 ,只需要id
{
	id = 3001,
}
isChar 是否是主角  如果为true, partnerInfo 为空
showType 显示方式  后面根据需要扩展,比如要展示完整技能或者已有技能.
buttonIsShow = 关闭按钮是不是显示   ---不传显示，传不显示
]]

function PartnerCompInfoView:ctor(winName,partnerInfo,userInfo,isChar,showType,callFunc)
    PartnerCompInfoView.super.ctor(self, winName)
    self.callFunc = callFunc
    self:frishUIData(partnerInfo,userInfo,isChar,showType)
end

function PartnerCompInfoView:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initData()
	self:initView()
	self:updateUI()

end 



function PartnerCompInfoView:registerEvent()
	PartnerCompInfoView.super.registerEvent(self);
	self.panel_bg.btn_close:setTap(function ()
		if  self.callFunc then
			self.callFunc()
		else
			self:startHide()
		end
	end)--c_func(self.startHide,self))
	if not self.callFunc then
		self:registClickClose("out" ,call ,touchThrough,onMovedClear)
	end

	-- if self.buttonIsShow then
	-- 	self.panel_bg.btn_close:setVisible(false)
	-- else
	-- 	self.panel_bg.btn_close:setVisible(true)
	-- end
end

function PartnerCompInfoView:frishUIData(partnerInfo,userInfo,isChar,showType,isFrish)
	self.partnerInfo = partnerInfo
    --如果没有星级 说明是为拥有这个伙伴
    if  not self.partnerInfo.star then
    	local cfgs = FuncPartner.getPartnerById(partnerInfo.id)
    	self.partnerInfo = {
    		id = partnerInfo.id,
    		star =cfgs.initStar,
    		quality = 1,
    		level = 1,
    		starPoint = 0,
    		skills = {},
    		equips = {},
    		position =0,
    	}
    	local skillArr = cfgs.skill

    	local unLockArr = FuncPartner.getUnLockSkillByStar( self.partnerInfo.id,self.partnerInfo.star )
    	for i,v in ipairs(unLockArr) do
    		self.partnerInfo.skills[v] = 1
    	end
    end

    self.playerInfo = userInfo
    self.isChar = isChar

    if isFrish then
		self:initData()
		self:initView()
		self:updateUI()
    end
end




function PartnerCompInfoView:initData()
	-- TODO
end

function PartnerCompInfoView:initView()
	-- TODO
end

function PartnerCompInfoView:initViewAlign()
	-- TODO
end

function PartnerCompInfoView:updateUI()

	self.ctn_1:stopAllActions()
	if self.isChar then
		
		local treasureId = "404"
		if self.playerInfo.treasureFormation then
			treasureId = self.playerInfo.treasureFormation["p1"]
		end
		
		self.mc_3:showFrame(4)
		
		local quaData = FuncPartner.getPartnerQuality(self.playerInfo.avatar)
		local nameColor = quaData[tostring(self.playerInfo.quality)].nameColor
		nameColor = string.split(nameColor, ",")
		local nameFrame = tonumber(nameColor[1])
		self.mc_1:showFrame(nameFrame)
		if tonumber(nameColor[2]) > 1 then
			self.mc_1.currentView.txt_1:setString(self.playerInfo.name.."+"..(nameColor[2] - 1))
		else
			self.mc_1.currentView.txt_1:setString(self.playerInfo.name)
		end

		self.mc_4:showFrame(tonumber(self.playerInfo.star))
		self.ability = FuncChar.getCharPower(self.playerInfo, nil, treasureId)
		self.treasureId = treasureId
		self:updateScrollView()

        local element = FuncTreasureNew.getTreasureDataById(self.treasureId).wuling or 6 
        self.mc_2:showFrame(element)

        self.txt_1:setString(GameConfig.getLanguage(FuncPartner.getDescribe(self.playerInfo.avatar) ))

	else
		local partnerId = self.partnerInfo.id
		local partnerData = self.partnerInfo
		local partnerCfgData = FuncPartner.getPartnerById(partnerId)
		local quaData = FuncPartner.getPartnerQuality(partnerId)
		self.txt_1:setString(GameConfig.getLanguage(FuncPartner.getDescribe(self.partnerInfo.id) ))
		self.mc_3:showFrame(tonumber(partnerCfgData.type))

		local nameColor = quaData[tostring(partnerData.quality)].nameColor
		nameColor = string.split(nameColor, ",")
		local nameFrame = tonumber(nameColor[1])
		self.mc_1:showFrame(nameFrame)
		if tonumber(nameColor[2]) > 1 then
			self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(partnerCfgData.name).."+"..(nameColor[2] - 1))
		else
			self.mc_1.currentView.txt_1:setString(GameConfig.getLanguage(partnerCfgData.name))
		end
		
		self.mc_4:showFrame(tonumber(partnerData.star) or partnerCfgData.initStar)
		
		self.ability = FuncPartner.getPartnerAbility(partnerData, self.playerInfo)
		self:updateScrollView()
        self.mc_2:showFrame(partnerCfgData.elements)
	end
	self.ctn_1:delayCall(c_func(self.delayShowSpine,self), 0.1)
end

--延迟一帧创建spine 防止卡顿
function PartnerCompInfoView:delayShowSpine(  )
	self.ctn_1:removeAllChildren()
	if self.isChar then
		local garmentId = ""
		if self.playerInfo.userExt and self.playerInfo.userExt.garmentId then
			garmentId = self.playerInfo.userExt.garmentId
		end
		local spine = GarmentModel:getSpineViewByAvatarAndGarmentId(self.playerInfo.avatar, garmentId)
		spine:scale(1.5)
		self.ctn_1:addChild(spine)
	else
		local partnerId = self.partnerInfo.id
		local partnerData = self.partnerInfo
		local spine = FuncPartner.getHeroSpineByPartnerIdAndSkin(partnerId, partnerData.skin)
		self.ctn_1:addChild(spine)
		spine:scale(1.5)
	end
end

function PartnerCompInfoView:updateScrollView(  )
	local node = display.newNode()
	self.panel_s1:setVisible(false)
	self.panel_s3:setVisible(false)
	self.panel_s4:setVisible(false)
	-- self.panel_s3:setVisible(false)
	local infoArr = {
		self:getPowerPanel(),
		-- self:getDesPanel(),
		self:getSkillInfo(),
		self:getPropPanel( UIBaseDef:cloneOneView(self.panel_s3),1),
		self:getPropPanel( UIBaseDef:cloneOneView(self.panel_s4),2),
	}

	local currentBox

	local offsetArr = {
		{-0,0},
		{-0,-15},
		{-0,-15},
		{-0,-15}
	}
	--计算总box
	for i,v in ipairs(infoArr) do
		v.panel:parent(node)
		if not currentBox then
			currentBox = v.box
			v.panel:pos(offsetArr[i][1],offsetArr[i][2])

		else
			v.panel:pos(offsetArr[i][1],offsetArr[i][2]-currentBox.height)
			currentBox.height = currentBox.height + v.box.height
		end
	end

	local createFunc = function (  )
		
		return node

	end

	local params = {
		{
			data = {1},
			createFunc = createFunc,
			itemRect = node:getContainerBox(),
			offsetX =-0,
			offsetY = -5,
		}
	}
	self.scroll_1:cancleCacheView()
	self.scroll_1:styleFill(params)

end

--获取战力panel
function PartnerCompInfoView:getPowerPanel(  )
	self.panel_1:setVisible(false)
	local panel = UIBaseDef:cloneOneView(self.panel_1);
	panel.UI_number:setPower(self.ability or 0)
	local box = panel:getContainerBox()
	return {panel = panel,box = box}
end

--获取简介panel
function PartnerCompInfoView:getDesPanel( )
	local des
	self.panel_s1:visible(false)
	local clonePanel = UIBaseDef:cloneOneView(self.panel_s1);
	if self.isChar then
		des = GameConfig.getLanguage(FuncPartner.getDescribe(self.playerInfo.avatar) )
	else
		des = GameConfig.getLanguage(FuncPartner.getDescribe(self.partnerInfo.id) )
	end
	clonePanel.panel_1.txt_2:setString(des)
	return {panel = clonePanel,box = clonePanel:getContainerBox()} 
end


--获取属性高级panel
function PartnerCompInfoView:getPropPanel( panel,keyType )
	--处理属性相关数据 并加载右侧属性信息
	local attrs 
	if self.isChar then
		attrs = FuncChar.getCharAttr(self.playerInfo, nil, self.treasureId)
	else
		attrs =  FuncPartner.getPartnerAttribute( self.partnerInfo,self.playerInfo,nil ) 
	end


	local attr_show = {}
	for i,v in ipairs(attrs) do
		if FuncBattleBase:getOneKeyProp( v.key ) ==keyType then
			table.insert(attr_show, v)
		end
	end
	attr_show= FuncBattleBase.formatAttribute( attr_show )
	local _view = panel
	panel.panel_1:setVisible(false)
	for i = 1, #attr_show, 1 do
		local attrGroup = attr_show[i]
		local panel_attr = UIBaseDef:cloneOneView(_view.panel_1)
		local attrKeyName = FuncBattleBase.getAttributeName(attrGroup.key)
		local attrValue = attrGroup.value
		local attr_str = attrKeyName.." "..attrValue
		panel_attr.mc_1:showFrame(FuncPartner.ATTR_KEY_MC[tostring(attrGroup.key)])
		panel_attr.txt_1:setString(attr_str)
		panel_attr:addto(_view)
		local posX = 0 + (i - 1) % 2 * 175
		local posY = -43 - math.floor((i - 1) / 2) * 42
		panel_attr:pos(posX, posY)
	end

	return {panel = panel,box = panel:getContainerBox()}  
end




--获取仙术详细信息
function PartnerCompInfoView:getSkillInfo(  )
	self.skill_show = {}
	if self.isChar then
		--处理主角仙术相关数据
		local charSkill = FuncChar.getCharSkillId(self.playerInfo.avatar)
		local treasureSkills = FuncTreasureNew.getTreasureSkills(self.treasureId , self.playerInfo.avatar)
		local skillStarMap = FuncTreasureNew.getStarSkillMap(self.treasureId , self.playerInfo.avatar)
		self.treasureData = self.playerInfo.treasures[tostring(self.treasureId )]
		local _star = PartnerModel:getAwakenSkillStar(self.playerInfo.avatar)
		local treasureId = self.treasureId 
		local equipAwake, awakeSkillData = FuncPartner.checkPartnerEquipSkill(self.playerInfo,_star,treasureId)
		
		local skillsNewMap = {}
		for k,v in pairs(skillStarMap) do
			local index = v.star
			if index ~= 1 then
				index = index + 1
			end
			skillsNewMap[index] = {skillId = v.skill, star = v.star, level = self.playerInfo.level, isTreasureSkill = true}
			if v.star < _star then
				skillsNewMap[index].activity = false
			else
				skillsNewMap[index].activity = true
			end
			 
		end
		skillsNewMap[2] = {skillId = charSkill, level = 1, isCharSkill = true}

		local isActivity,skillCfgs = FuncPartner.checkWuqiAwakeSkill(self.playerInfo)
		skillsNewMap[8] = {skillId = skillCfgs.id, level = 1, isCharSkill = true,activity = isActivity}
		skillsNewMap[9] = {skillId = awakeSkillData.id, level = self.playerInfo.level, activity = equipAwake, isTreasureSkill = true}
		
		self.skill_show = skillsNewMap
	else
		--处理仙术相关数据 并加载右侧仙术信息
		local partnerId = self.partnerInfo.id
		local skills = FuncPartner.getPartnerById(partnerId).skill


		--这里后期需要扩展维护 
		for i,v in ipairs(skills) do
			local tempSkill = {
				skillId = v,
				level = 1,
			}
			if self.partnerInfo.skills[v] then
				tempSkill.activity = true
			else
				tempSkill.activity = false
			end

			table.insert(self.skill_show,tempSkill )
		end



	end
	self.panel_s2:setVisible(false)
	local panel_s2 =UIBaseDef:cloneOneView(self.panel_s2);
	self:showOneSkillInfo(panel_s2.panel_xiangxi,self.skill_show[1],1)
	local boxXiangxi = panel_s2.panel_xiangxi:getContainerBoxToParent()
	panel_s2.panel_xiangxi2:pos(10,boxXiangxi.y - 10)
	self:showOneSkillInfo(panel_s2.panel_xiangxi2,self.skill_show[2],2)

	local boxXiangxi2 = panel_s2.panel_xiangxi2:getContainerBoxToParent()
	local startX = 26
	local startY = boxXiangxi2.y -10

	local perLineNums = 3
	local perWidth = 100
	local perHeight = 100
	panel_s2.panel_2:visible(false)
	--每行 3个
	local createNums =0
	for i=3,#self.skill_show do
		if true then
			createNums = createNums +1
			local xIndex = createNums%perLineNums
			local yIndex = math.ceil(createNums/perLineNums)
			if xIndex ==0 then
				xIndex = perLineNums
			end
			local xpos = startX + (xIndex-1) * perWidth
			local ypos = startY - (yIndex-1) * perHeight
			local panel = UIBaseDef:cloneOneView(panel_s2.panel_2)
			self:showSkillIcon(panel,self.skill_show[i],xpos,ypos)
			panel:parent(panel_s2)
		end
		
	end

	return  {panel = panel_s2,box = panel_s2:getContainerBox()}   
end

--skillInfo= {skillId = charSkill, level = self.playerInfo.level, isCharSkill = true}
--展示一个技能详细信息
function PartnerCompInfoView:showOneSkillInfo( panel,skillInfo,index )
	self:showSkillIcon(panel.panel_1,skillInfo,0,0,index)
	panel.panel_1.txt_1:visible(false)
	panel.txt_2:setString(panel.panel_1.txt_1._labelString)
	local skillCfg = nil
	if skillInfo.isTreasureSkill then
		skillCfg = FuncTreasureNew.getTreasureSkillDataDataById(skillInfo.skillId)
	else
		skillCfg = FuncPartner.getSkillInfo(skillInfo.skillId)
	end
	panel.rich_1:setStringByAutoSize(GameConfig.getLanguage(skillCfg.describe),10)

	local box = panel.rich_1:getContainerBoxToParent()
	local targetY = box.y 
	if targetY >-130 then
		targetY = -130
	end
	panel.panel_xian:pos(10,targetY)
end

--显示一个skillicon
function PartnerCompInfoView:showSkillIcon(  panel_skill,skillInfo,posX,posY ,index)
	local skillCfg = nil
	if skillInfo.isTreasureSkill then
		skillCfg = FuncTreasureNew.getTreasureSkillDataDataById(skillInfo.skillId)
	else
		skillCfg = FuncPartner.getSkillInfo(skillInfo.skillId)
	end
	if not skillCfg then
		dump(skillInfo,'_skillInfo')
		echoError("__没有技能数据")
		return
	end

	local skillKind =  FuncPartner.getSkillKind( skillInfo.skillId,  skillInfo.isTreasureSkill,skillInfo.isCharSkill )
	panel_skill.mc_xianshu:showFrame(skillKind)
	-- panel_skill.panel_number.txt_1:setString(skillInfo.level)
	panel_skill.txt_1:setString(GameConfig.getLanguage(skillCfg.name))
	local skillSp = display.newSprite(FuncRes.iconSkill(skillCfg.icon))
	if skillCfg.priority == 1 and skillCfg.order == 3 then
		skillSp:setScale(1*72/105)
	else
		skillSp:setScale(1)
	end
	
	local index = 2
    panel_skill.ctn_1:removeAllChildren()
    panel_skill.ctn_1:addChild(skillSp)
    if conditions then
    	--todo
    end

    if skillInfo.activity then
    	FilterTools.clearFilter(panel_skill.ctn_1)
    else
    	FilterTools.setGrayFilter(panel_skill.ctn_1)
    end

	panel_skill:pos(posX, posY)
	if not self.isChar then
		FuncCommUI.regesitShowSkillTipView(skillSp, {partnerId = self.partnerInfo.id, 
			id = skillInfo.skillId, level = skillInfo.level or 1, isUnlock = true, _index = index})
	else
		if skillInfo.isTreasureSkill and self.treasureData then
			FuncCommUI.regesitShowTreasureSkillTipView(skillSp, {treasureId = self.treasureData.id,
				skillId = skillInfo.skillId, index = index, data = self.treasureData, level = self.playerInfo.level})
		else
			FuncCommUI.regesitShowCharSkillTipView(skillSp, {partnerId = self.playerInfo.avatar, 
				id = skillInfo.skillId, level = self.playerInfo.level, index = 1})
		end
	end
end



function PartnerCompInfoView:deleteMe()
	-- TODO

	PartnerCompInfoView.super.deleteMe(self);
end

return PartnerCompInfoView;
