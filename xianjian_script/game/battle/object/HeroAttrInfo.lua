local Fight = Fight
-- local BattleControler = BattleControler

HeroAttrInfo = class("HeroAttrInfo")

--英雄属性转换器
function HeroAttrInfo:ctor( data,hid,camp,isChar,isRoboot,userData,formation)
	self.data = data
	-- dump(self.data,"22222222222222222222222")
	self.hid = hid
	self.camp = camp
	self.isChar = isChar
	self.isRoboot = isRoboot
	self.userData = userData
	self.formation = formation
	self:getAttrCfg()
end


function HeroAttrInfo:getAttrCfg()
	self.attr = {}

	local propData
	
	if not self.isRoboot then
		--如果是主角
		if self.isChar then
			-- 对外接口 -- 主角属性
			propData =  FuncChar.getCharAttr( self.userData, self.formation)
			
		else
			-- 属性
			propData = FuncPartner.getPartnerAttribute(self.data, self.userData, self.formation)
		end
	else
		propData = self.data.propData
	end



	local turnHeroData = {}
	for i,v in ipairs(propData) do
		local key = FuncBattleBase.getAttributeData(v.key).keyName
		turnHeroData[key] = v.value
	end
	self.attr.isCharacter = self.isChar
	self.attr.hid = self.hid
	self.attr.rid = self.hid .. "_"..self.camp

	self.attr.lv 	= self.data.level or 1
	--暂时初始能量给0
	self.attr.energy = 0
	
	self.attr.maxenergy = turnHeroData.maxenergy or 1
	self.attr.energydiff = 0
	self.attr.energyExtreme = Fight.energyExtreme

	self.attr.hp 	= turnHeroData.hp or turnHeroData.maxhp
	self.attr.maxhp = turnHeroData.maxhp
	--@测试
	if Fight.all_high_hp then
		self.attr.hp = 10000000
		self.attr.maxhp = 10000000
	end
	-- self.attr.hp = 50000
	-- 	self.attr.maxhp = 50000
	-- if Fight.enemy_low_hp then
	-- 	self.attr.hp = 1
	-- 	self.attr.maxhp = 1
	-- end

	self.attr.atk 	= turnHeroData.atk or 0
	self.attr.def = turnHeroData.def or 0
	self.attr.crit = turnHeroData.crit or 0
	self.attr.resist = turnHeroData.resist or 0
	self.attr.wreck = turnHeroData.wreck or 0
	self.attr.block = turnHeroData.block or 0 
	self.attr.blockR = turnHeroData.blockR or 0
	-- echo(self.attr.blockR,"___self.attr.blockR")
	-- echo(self.attr.blockR,"___self.attr.blockR",self.hid)

	self.attr.type = turnHeroData.type 

	self.attr.hit = 1--self:sta_hit()
	-- self.attr.dodge = self:sta_dodge()
	self.attr.critR = turnHeroData.critR or 0
	self.attr.injury = turnHeroData.injury or 0 	--伤害率
	self.attr.avoid = turnHeroData.avoid  or 0		--免伤率
	self.attr.buffHit = turnHeroData.buffHit or 0	-- buff命中
	self.attr.buffResist = turnHeroData.buffResist or 0	-- buff抵抗

	self.attr.dropCount = turnHeroData.dropCount or 0

	self.attr.cureR = 0 		--治疗效果 
	self.attr.curegetR = 0 		--被治疗效果 

	self.attr.boss = 2
	self.attr.showTopHpbar = 0	-- 不显示
	self.attr.feigndie = 0 -- 伙伴都不会假死
	-- self.attr.head = staticData.icon or ""
	-- self.attr.icon = staticData.icon or ""
	-- self.attr.headBG =  ""

	self.attr.artImg =  ""
	-- self.attr.artTxt = self:sta_artTxt() or ""
	-- self.attr.artTrea = self:sta_artTrea() or ""
	-- self.attr.artTreaTxt = self:sta_artTreaTxt() or ""
	-- self.attr.sex = staticData.sex or 1	 				--性别
	self.attr.profession = 1 		--职业 暂时全部给1
	-- self.attr.viewSize =  {50,140}
	self.attr.viewScale = 100
	self.attr.beusedScale =  100
	
	self.attr.suckR = turnHeroData.suckR or 0		--吸血 
    self.attr.thorns = turnHeroData.thorns 	or 0	--反弹 	
    self.attr.magdef = turnHeroData.magdef or 0

    --小技能的触发参数 初始值,每回合增加值,释放要求值
    self.attr.sskp = nil

	self.attr.hpAi = {					} 


	
	
	self.attr.beKill = nil  		-- 被杀后做什么事

	self.attr.immunity =  0

	self.attr.figure = 1 		--体积 默认是1

	self.attr.isRobootNPC = false 	-- 对应EnemyInfo加入一个参数值
	self.attr.hpCount = 0 --几格血

	self.attr.ability = 10 --其实没什么用

	self.attr.star = self.data.star or 1
	self.attr.quality = self.data.quality or 1

	if Fight.isDummy then
		self.attr.talk = {}
	else
		-- 初始化战斗内气泡数据
		local talkInfo = FuncPartner.getPartnerTalkById(self.hid)
		self.attr.talk = talkInfo and table.copy(talkInfo) or {}
	end

	if IS_CHECK_CONFIG then
		if not ( self.attr.figure == 1 or self.attr.figure ==2 or self.attr.figure == 4 or self.attr.figure ==6) then
			echoError("找策划", self.attr.hid.."HeroAttrInfo中的figure体型配置不正确,必须为 1 2 4 6")
		end
	end
   	-- 觉醒资源
   	if FuncPartner.checkWuqiAwakeSkill(self.data) then
   	-- if FuncPartner.checkAllEquipsAwake(self.data) then --全部觉醒
   		self.attr.awakenWeapon = FuncPartner.getPartnerAwakenWeapon( self.hid )
   	end
	-- 设定法宝数据
	self.attr.treasures = {}
	local treasureId
	if self.isChar then
		treasureId = FuncChar.getHeroData(self.hid).treasureId
		local garmentId --这个参数用于战斗结算显示的皮肤用
		if self.data.userExt then
			garmentId = self.data.userExt.garmentId or ""
		end
		if garmentId ~= "" then
			self.attr.garmentId = garmentId
			treasureId= FuncGarment.getGarmentTreasure(garmentId,self.data.avatar)
		end

	else
		if self.data.skin then
			self.attr.garmentId = self.data.skin
		end
		treasureId = FuncPartner.getPartnerTreasureIdByIdAndSkin(self.hid,self.data.skin)
	end
	if not treasureId then
		echoError ("找策划，没有找到对应的treasureId",self.hid,"_暂时用300032代替")
		treasureId =  "300032"
	end
	-- 组装法宝数据
	local trs = {partnerId = self.hid,hid = treasureId,treaType = Fight.treaType_base}
	if not Fight.isDummy then
		local sourceId = FuncBattleBase.getSourceByTreasureId(treasureId)
		local sourceData = FuncTreasure.getSourceDataById(sourceId)
		self.attr.viewSize = table.copy(sourceData.viewSize or {50,140})
	else
		self.attr.viewSize = {50,140}
	end
	if not self.isChar then
		if not self.isRoboot then
			trs.skillInfo = FuncPartner.getPartnerSkillParams(self.data)
			-- 原始技能数据存一份，用于计算五灵的技能增强
			local originSkillData = table.copy(self.data.skills)
			trs.originSkillData = originSkillData
		else
			local data = {
				id = self.hid,
				skills = FuncPartner.getSkillByPartnerIdForRobot( self.hid,self.data.skilllvl )
			}
			trs.skillInfo = FuncPartner.getPartnerSkillParams(data)
		end
	end
	table.insert(self.attr.treasures,trs)
	-- 主角需要设置一下normal法宝
	if self.isChar then
		local tmpId = self.data.treasures[next(self.data.treasures)].id
		if not self.isRoboot then
			-- 这里做一下兼容(下面的rid取值方法应该废弃了!)
			if self.formation.treasureFormation["p1"] then
				tmpId = self.formation.treasureFormation["p1"]
			else
				tmpId = self.formation.treasureFormation[tostring(self.data.rid)]
			end
		end
		self:resetTreasure(tmpId)
	end
end
-- 额外设置的属性值(调用这个方法可能会覆盖以前设置的值)
function HeroAttrInfo:setExAttr( arr )
	if self.attr then
		for k,v in pairs(arr) do
			if self.attr[k] then
				-- echoWarn ("attr中key = %s 会被%s覆盖（原值）",k,self.attr[k],v)
			end
			self.attr[k] = v
		end
	else
		echoError ("还没有初始化class 就调用这个方法了")
	end
end
-- 比武切磋替换法宝
function HeroAttrInfo:resetTreasure( treasureId )
	for k,v in pairs(self.attr.treasures) do
		if v.treaType == Fight.treaType_normal then
			table.remove(self.attr.treasures,k)
			break
		end
	end
	-- 计算法宝
	local trs = {}
	local battleTrsId = FuncTreasureNew.getBattleTreasureId(treasureId,self.attr.hid)
	trs.hid = battleTrsId


	if Fight.isDummy	then
		self.attr.viewSize =  {50,140}
	else
		-- 处理一下 viewSize
		local sourceId = FuncBattleBase.getSourceByTreasureId(battleTrsId)
		local sourceData = FuncTreasure.getSourceDataById(sourceId)

		self.attr.viewSize = table.copy(sourceData.viewSize or {50,140})
	end

	

	trs.treaType = Fight.treaType_normal
	table.insert(self.attr.treasures,trs)
	trs.partnerId = self.hid 

	local skillInfo = nil
	if not self.isRoboot then
		skillInfo = FuncChar.getPartnerSkillParams(self.data,treasureId)
	else
		skillInfo = FuncChar.getPartnerSkillParamsForRobot(self.data,treasureId)
	end

	for i,v in ipairs(self.attr.treasures) do
		-- (主角如果有五行的时候，需要做这个处理)获取法宝的时候需要主角的数据，所以添加了主角的数据，后面这地方做优化
		v.treasureId = treasureId
		v.userData = self.data
		v.skillInfo = skillInfo
	end
end

return HeroAttrInfo


