--[[
	Author:李朝野
	Date: 2017.08.05
	Modify: 2018.1.2 大修改，与之前完全不同
]]
--[[
	李忆如被动

	技能描述：
	开场阶段（敌我同时）战斗首个回合前，蕴儿会趴伏在敌方一个目标身后，（随机一人，优先小怪）;
	如果目标为小怪，则在小怪被击倒之后，被忆如控制并跑到李忆如身后（贴着站，需要展示过程，有一个缩放系数控制小怪被控制后的体积大小，统一处理即可），被李忆如控制；
	如果是奇侠/Boss，则降低其一定防御力；
	目标被击倒后，找寻下一个目标，如果再为小怪，则替换原有的跟班。

	脚本处理部分：
	回合开始前选敌并根据选敌的类型上buff；
	指定人物死亡后重新选敌并上buff，同时如果目标可被收为宠物则处理相关逻辑

	参数：
	atkId1 带有蕴️儿buff的攻击包
	atkId2 带有减防buff的攻击包
	action 成功施法时播放的动作
]]
local Skill_liyiru_4 = class("Skill_liyiru_4", SkillAiBasic)

function Skill_liyiru_4:ctor(skill,id,atkId1,atkId2,action)
	Skill_liyiru_4.super.ctor(self, skill, id)

	self:errorLog(atkId1, "atkId1")
	self:errorLog(atkId2, "atkId2")
	self:errorLog(action, "action")

	self._atkData1 = ObjectAttack.new(atkId1)
	self._atkData2 = ObjectAttack.new(atkId2)
	self._action = action

	-- 记录选定角色
	self._tHero = nil

	-- 记录首回合
	self._firstRound = true
end

-- 首回合
function Skill_liyiru_4:onMyRoundStart(selfHero)
	-- 首回合或没有记录的角色，当切波时会导致没有记录的角色
	if self._firstRound or not self._tHero then
		self._firstRound = false

		-- 动作相关
		self:_chkDoAction(function()
			-- 找一个人做逻辑
			self:doBuffForHero(self:doChooseHero())
		end)
	end
end

-- 有角色死亡时
function Skill_liyiru_4:onOneHeroDied(attacker, defender )
	if defender:checkWillBeRelive() then return end

	-- 李忆如死了清理相关buff
	if self:isSelfHero(defender) then
		for _,hero in ipairs(defender.toArr) do
			local buffs1 = self._atkData1:sta_buffs()
			local buffs2 = self._atkData2:sta_buffs()
			for _,buffid in ipairs(buffs1) do
				hero.data:clearOneBuffByHid(buffid)
			end

			for _,buffid in ipairs(buffs2) do
				hero.data:clearOneBuffByHid(buffid)
			end
		end
	end
	
	-- 是标记的人物
	if self._tHero == defender then
		-- 是小怪
		if SkillBaseFunc:checkProfession(Fight.profession_monster, defender) then
		-- if true then
			-- 处理宠物逻辑
			self:managerPet(defender)
		end

		-- 再找一个人
		self:doBuffForHero(self:doChooseHero())
	end
end

-- 处理宠物逻辑
function Skill_liyiru_4:managerPet(hero)
	local selfHero = self:getSelfHero()
	-- 标记为宠物
	hero.__willBPet = true
	hero.data:clearAllBuff()
	-- 给对象一个变宠物方法
	function hero:beComePet()
		local toArr = self.toArr
		local campArr = self.campArr
		local camp = self.camp

		self.hasHealthDied = false
		self.way = selfHero.way
		self.camp = selfHero.camp

		self.toArr = campArr
		self.campArr = toArr
		self.toCamp = camp

		self.data.posIndex = selfHero.data.posIndex
		self.data.gridPos.x = selfHero.data.gridPos.x
		self.data.gridPos.y = selfHero.data.gridPos.y


		self.data:changeValue(Fight.value_health, self.data:maxhp(), Fight.valueChangeType_num)

		-- 更新一下位置
		selfHero:setInitPos()
		
		self._isPet = true
		self.__willBPet = false
		-- 做一下复活动作(可以打断死亡动作)
		self:justFrame(Fight.actions.action_relive)
		-- self:setPos(selfHero.pos.x, selfHero.pos.y ,selfHero.pos.z - 1)
		self:movetoInitPos(2)
	end

	if hero.healthBar then
		hero.healthBar:setVisible(false)
	end

	selfHero:removeOnePet()
	selfHero:addOnePet(hero)
end

-- 对选定角色做相关行为
function Skill_liyiru_4:doBuffForHero(hero)
	self._tHero = hero

	if not hero then return end

	local selfHero = self:getSelfHero()
	-- 小怪只做蕴儿攻击包
	if not SkillBaseFunc:checkProfession(Fight.profession_monster, hero) then
		selfHero:sureAttackObj(hero,self._atkData2,self._skill)
	end

	selfHero:sureAttackObj(hero,self._atkData1,self._skill)

	self:skillLog("李忆如选定，阵营:%s,%s号位职业类型:%s",hero.camp,hero.data.posIndex,hero:getHeroProfession())
end

-- 选敌
function Skill_liyiru_4:doChooseHero()
	local selfHero = self:getSelfHero()
	local campArr = selfHero.toArr

	local monsterT = {}
	local otherT = {}

	for _,hero in ipairs(campArr) do
		if SkillBaseFunc:isLiveHero(hero) then
			if SkillBaseFunc:checkProfession(Fight.profession_monster, hero) then
				monsterT[#monsterT + 1] = hero
			else
				otherT[#otherT + 1] = hero
			end
		end
	end

	local tempArr = #monsterT == 0 and otherT or monsterT

	local idx = BattleRandomControl.getOneRandomInt(#tempArr+1,1)

	return tempArr[idx]
end

--[[
	处理做动作的函数
]]
function Skill_liyiru_4:_chkDoAction(callFunc)
	if not Fight.isDummy and self._action ~= "none" then
		local selfHero = self:getSelfHero()
		-- 可攻击才做动作
		if selfHero.data:checkCanAttack() then
			selfHero:setRoundReady(Fight.process_myRoundStart, false)
			selfHero:justFrame(self._action)
			-- 做完动作再准备完成
			local totalFrames = selfHero:getTotalFrames(self._action)
			selfHero:pushOneCallFunc(tonumber(totalFrames), "setRoundReady",{Fight.process_myRoundStart,true})
			-- 需要特殊配合表现写死帧数做操作
			selfHero:pushOneCallFunc(45, callFunc, {})
		else
			callFunc()
		end
	else
		callFunc()
	end
end

return Skill_liyiru_4