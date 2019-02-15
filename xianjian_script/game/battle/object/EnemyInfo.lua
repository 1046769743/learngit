--定义globalCfgkey,对配表属性做映射
local globalCfgKey = {
	"hid","viewScale","beusedScale","lv","figure","hpAi",
	"maxenergy","atk","def","magdef",
	"hp","maxhp","crit","resist","critR",
	"block","wreck","blockR","injury","avoid","buffHit","buffResist",
	"dropCount","baseTrea","trea1","immunity","boss", 
	"roundTreasure","rdmDropBuff",
	"elementsDmg2","elementsDmg3","feigndie","showTopHpbar","talk","hpCount",
	-- "name","sex","icon","head","headBG",
}
local Fight = Fight
-- local BattleControler = BattleControler

EnemyInfo = class("EnemyInfo")
ObjectCommon.mapFunction(EnemyInfo,globalCfgKey)

EnemyInfo.attr = nil

function EnemyInfo:ctor( hid,levelRevise,towerLevelRevise,userData)
	self.__staticData =  ObjectCommon.getPrototypeData( "level.EnemyInfo",hid )
	if not self.__staticData then
		hid = "10008"
		self.__staticData =  ObjectCommon.getPrototypeData( "level.EnemyInfo",hid )
	end

	self:initLevelRevise(levelRevise)

	self.towerLevelRevise = towerLevelRevise
	if not self.towerLevelRevise then
		self.towerLevelRevise = 100
	end
	self.towerLevelRevise = self.towerLevelRevise
	self.hid = hid
	self.userData = userData
	self:getAttrCfg()
end


function EnemyInfo:getAttrCfg()
	self.attr = {}
	self.attr.hid = self.hid
	self.attr.rid = self.hid
	self.attr.lv 	= self:sta_lv()

	self.attr.maxenergy = self:sta_maxenergy()
	self.attr.energydiff = 0
	self.attr.energyExtreme = Fight.energyExtreme
	self.attr.hp 	= math.round(self:sta_hp() * self.levelRevise["base"] * self.towerLevelRevise / 10000)       		--关卡修正  血量
	self.attr.maxhp = math.round(self:sta_maxhp() * self.levelRevise["base"] * self.towerLevelRevise / 10000)			--关卡修正  最大血量
	self.attr.isRobootNPC = true
	--@测试
	if Fight.all_high_hp then
		self.attr.hp = 10000000
		self.attr.maxhp = 10000000
	end
	-- self.attr.hp = 50000
	-- 	self.attr.maxhp = 50000
	if Fight.enemy_low_hp then
		self.attr.hp = 1
		self.attr.maxhp = 1
	end
	self.attr.quality = 1
	self.attr.garmentId = ""
	self.attr.star = 1

	self.attr.atk 	= math.round(self:sta_atk() * self.levelRevise["base"] * self.towerLevelRevise / 10000)					--关卡修正  攻击
	self.attr.def = math.round(self:sta_def() * self.levelRevise["base"] * self.towerLevelRevise / 10000)					--关卡修正  防御
	self.attr.crit = math.round(self:sta_crit() * self.levelRevise["secondL"] / 100) + self.levelRevise["crit"]
	self.attr.resist = math.round(self:sta_resist() * self.levelRevise["secondL"] / 100) + self.levelRevise["resist"]
	self.attr.wreck = math.round(self:sta_wreck() * self.levelRevise["secondL"] / 100) + self.levelRevise["wreck"]
	self.attr.block = math.round(self:sta_block() * self.levelRevise["secondL"] / 100) + self.levelRevise["block"]
	self.attr.blockR = self:sta_blockR() or 0

	self.attr.hit = 1--self:sta_hit()
	-- self.attr.dodge = self:sta_dodge()
	self.attr.critR = self:sta_critR()
	self.attr.injury = self:sta_injury() or 0 	--伤害率
	self.attr.avoid = self:sta_avoid()  or 0		--免伤率
	self.attr.buffHit = math.round((self:sta_buffHit() or 0) + self.levelRevise["buffHit"])	-- buff命中
	self.attr.buffResist = math.round((self:sta_buffResist() or 0) + self.levelRevise["buffResist"]) -- buff抵抗

	self.attr.dropCount = self:sta_dropCount() or 0
	-- if Fight.isDummy then
	-- 	self.attr.name	= self.hid
	-- else
	-- 	self.attr.name	= GameConfig.getLanguage(self:sta_name())
	-- end
	
	self.attr.cureR = 0 		--治疗效果 
	self.attr.curegetR = 0 		--被治疗效果 

	self.attr.boss = self:sta_boss() or 0
	self.attr.showTopHpbar = self:sta_showTopHpbar() or 0 -- 是否显示顶端血条
	self.attr.feigndie = self:sta_feigndie() or 0
	-- self.attr.head = self:sta_head() or ""
	-- self.attr.icon = self:sta_icon() or ""
	-- self.attr.headBG = ""

	self.attr.artImg = ""
	-- self.attr.artTxt = self:sta_artTxt() or ""
	-- self.attr.artTrea = self:sta_artTrea() or ""
	-- self.attr.artTreaTxt = self:sta_artTreaTxt() or ""
	-- self.attr.sex = self:sta_sex() 						--性别

	-- 目前先拿baseTrea 定位血条位置、当更换法宝的时候位置也应该做修改
	local baseTrea = self:sta_baseTrea()
	-- 登仙台主角时装
	if self.userData and self.userData.avatar and self.userData.garmentId then
		baseTrea = FuncGarment.getGarmentTreasure(self.userData.garmentId,self.userData.avatar)
	end
	if not Fight.isDummy then
		-- 近战
		if baseTrea then
			local sourceId = FuncBattleBase.getSourceByTreasureId(baseTrea)
			local sourceData = FuncTreasure.getSourceDataById(sourceId)
			self.attr.viewSize = table.copy(sourceData.viewSize or {50,140})
		else
			echoWarn("怪物没有默认法宝--在定位血条位置的时候会有问题",self.hid)
			self.attr.viewSize ={50,140}
		end
	else
		self.attr.viewSize ={50,140}
	end
	
	local viewScale = self:sta_viewScale() or 100
	self.attr.viewScale = viewScale
	-- 根据比例修改体型
	self.attr.viewSize[1] = self.attr.viewSize[1] * viewScale/100
	self.attr.viewSize[2] = self.attr.viewSize[2] * viewScale/100

	self.attr.beusedScale = self:sta_beusedScale() or 100
	
	self.attr.suckR = 0 		--吸血 不单配 默认为0
    self.attr.thorns = 0 		--反弹 		默认为0
    self.attr.magdef = math.round(self:sta_magdef() * self.levelRevise["base"] * self.towerLevelRevise  / 10000) 		--法防 默认为0

    self.attr.hpCount = self:sta_hpCount() or 0
	--hpAi[vector;hp[int];t[int];id[string];p1[int];p2[int]]
	self.attr.hpAi = self:sta_hpAi() 
										or 
										{
										 -- 	{hp=85,t=1,id="1001",p1=1,p2=0},	
											-- {hp=84,t=2,id="30014",p1=1,p2=0},	
											-- {hp=83,t=1,id="1002",p1=1,p2=0},	
											-- {hp=50,t=1,id="1002",p1=1,p2=0},
											-- {hp=30,t=1,id="1003",p1=1,p2=0},
											-- {hp=10,t=1,id="1004",p1=1,p2=0},	
										} 


	self.attr.immunity = self:sta_immunity() or 0

	self.attr.figure = self:sta_figure() or 1 		--体积 默认是1
	if IS_CHECK_CONFIG then
		if not ( self.attr.figure == 1 or self.attr.figure ==2 or self.attr.figure == 4 or self.attr.figure ==6) then
			echoError(self.attr.hid.."EnemyInfo中的figure体型配置不正确,必须为 1 2 4 6")
		end
	end
	if self.attr.boss == 0 then
		self.attr.peopleType = Fight.people_type_monster -- 怪物的AiMode
	elseif self.attr.boss == 2 then
		self.attr.peopleType = Fight.people_type_npc
	else
		self.attr.peopleType = Fight.people_type_boss
	end

   

	self.attr.treasures = {}

	self.attr.roundTreasure = self:sta_roundTreasure()

	self.attr.talk = self:sta_talk() or {}

	-- local baseTrea = self:sta_baseTrea()

	-- 近战
	if baseTrea then
		local trs = {}
		trs.hid = baseTrea
		trs.treaType = Fight.treaType_base
		-- 受到五行阵位的增强的技能参数（可能为空）
		trs.elementEnhanceSKill2 = self:sta_elementsDmg2() -- 小技能
		trs.elementEnhanceSkill3 = self:sta_elementsDmg3() -- 大招

		table.insert(self.attr.treasures,trs)
	end
	self:resetTreasure()
end
-- 额外设置的属性值(调用这个方法可能会覆盖以前设置的值)
function EnemyInfo:setExAttr( arr )
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

function EnemyInfo:resetTreasure( treasureId ,tType)
	tType = tType or Fight.treaType_normal

	for i=#self.attr.treasures,1,-1 do
		local v = self.attr.treasures[i]
		if v.treaType == tType then
			table.remove(self.attr.treasures,i)
		end
	end
	local _addNormalTreasure = function( id )
		local trs = {}
		trs.hid = id
		trs.treaType = tType

		-- 受到五行阵位的增强的技能参数（可能为空）
		trs.elementEnhanceSKill2 = self:sta_elementsDmg2() -- 小技能
		trs.elementEnhanceSkill3 = self:sta_elementsDmg3() -- 大招

		table.insert(self.attr.treasures,trs)
	end
	if not treasureId then
		-- 2018.07.24 修改为只有一个，trea2在配表中被删除掉 by ZhangYanguang
		for i=1, 1 do
			local treaCfg = self["sta_trea"..i](self)
			if treaCfg then
				_addNormalTreasure(treaCfg)
			end
		end
	else
		_addNormalTreasure(treasureId)
	end
end

-- 初始化修正系数
function EnemyInfo:initLevelRevise(levelRevise)
	if not levelRevise or type(levelRevise) ~= "table" then
		if levelRevise and type(levelRevise) ~= "table" then
			echoError("levelRevise 应该为table")
		end
		levelRevise = {100,100,0,0,0,0}
	end

	self.levelRevise = {
		base = levelRevise[1] or 100,
		secondL = levelRevise[2] or 100,
		crit = levelRevise[3] or 0,
		resist = levelRevise[4] or 0,
		block = levelRevise[5] or 0,
		wreck = levelRevise[6] or 0,
		buffHit = levelRevise[7] or 0,
		buffResist = levelRevise[8] or 0,
	}
end

return EnemyInfo


