--[[
	Author: lcy
	Date: 2018.07.03
	
	继承自gamecontroler，精简部分不用逻辑
	另，此种方式不涉及dummy校验，不打算处理相关逻辑
]]

MiniGameControler = class("MiniGameControler", GameControlerEx)

function MiniGameControler:ctor( ... )
	MiniGameControler.super.ctor(self, ...)

	self._dyingArr = {}
end
-- override
function MiniGameControler:initLogical()
	self.logical = MiniLogicalControler.new(self)
end
-- override
function MiniGameControler:initFirst()
	if self.isRunInitFirst then
		echoWarn("已经执行过 initFirst 方法")
		return
	end
	self.isRunInitFirst = true

	echo("_________MiniGameControler_____initFirst",self.__currentWave)

	-- 初始化变量
	self.middlePos = self.levelInfo.__midPos[1]
	-- 考虑是否需要换一个refreshControler
	self.reFreshControler = RefreshEnemyControler.new(self)
	self.updateDt = 0
	self.delayDt = Fight.dummyUpdata

	-- 排序站位控制器
	self.sortControler = GameSortControler.new(self)
	--视图表达控制器
	self.viewPerform = ViewPerformControler.new(self)
	-- 怒气控制器
	self.energyControler = EnergyControler.new(self)
	-- 布阵控制器
	self.formationControler = FormationControler.new(self)
	-- 神器控制器
	self.artifactControler = ArtifactControler.new(self)
	-- 触发技能控制器
	self.triggerSkillControler = TriggerSkillControler.new(self)
	-- 战斗校验控制器
	self.verifyControler = verifyControler.new(self)

	self.screen = ScreenControler.new(self,self.layer.a12)

	self.map = MapControler.new(self.layer.a11,self.layer.a13,self.levelInfo.__mapId, true )

	-- 要换
	self.gameUi = WindowControler:showBattleWindow("BattleSkillShowView")
	self.gameUi:setControler(self)

	-- 镜头直接初始化到位，因为pve也不再需要跑动入场le 
	self.screen:setFocus(self.middlePos, self.screen.focusPos.y)

	-- 初始化镜头
	self.camera = CameraControler.new(self)

	-- 初始化阵位特效
	self.formationControler:initView()

	--创建heroes
	self:initCountId(0)

	-- 控制器初始化一下流程信息
	self.logical:initShowInfo(self.levelInfo.partnerShowSkillInfo)

	self:beforeCreateStep()

	--开始刷新,只是刷新的时候判断是否开战
	self:startBattleLoop()
end

-- override
function MiniGameControler:initEvents()

end

-- override
function MiniGameControler:beforeCreateStep()
	self:enterCreateStep()
end

-- override
function MiniGameControler:chkNextRound()
	return self.logical:startRound()
end

-- override
function MiniGameControler:oneHeroeHealthDied(who, attacker)
	local index = table.indexof(who.campArr, who)
	--如果没有index 说明是已经删除过了
	if not index then
		return
	end

	--发送英雄死亡事件(挪到这里来为了自己死亡的时候也能收到事件)
	self.logical:doChanceFunc({camp = 0,chance = Fight.chance_onDied,defender = who,attacker = attacker })

	-- 在英雄死亡的事件中有可能会发生删除行为，会导致遍历错误，改成下面的方式
	-- table.remove(who.campArr,index)
	local num = table.removebyvalue(who.campArr, who)
	-- 如果已经被删除过了，则返回
	if num == 0 then
		return
	end

	-- 检查一下死亡相关的buff
	who:checkDieBuffs(attacker)
	--如果是将要复活的 存到diedArr里面去
	if who:checkWillBeRelive() or who:checkWillDieSkill() then
		local diedArr = who.diedArr
		table.insert(diedArr, who)
	else
		--取消光环作用
		who.data:cancleAure()

		-- 清理可能存在的触发回调（先放在不会复活的里，否则目前炸药桶无法爆炸）
		self.triggerSkillControler:removeOneSkillFuncByModel(who)

		self.logical:onOneHeroDied(who)

		table.insert(self._dyingArr,who)
	end

	who:onRemoveCamp()
end

function MiniGameControler:resetMiniGame()
	local function middleCallFunc()
		return self:_resetMiniGame()
	end
	local function finalCallFunc()
		-- 延迟几帧再开始
		return self:pushOneCallFunc(5, "logicalStartRound", {})
	end
	return self:showTransitionEff(middleCallFunc, finalCallFunc)
end

function MiniGameControler:_resetMiniGame()
	-- 将上一场的人物都销毁
	local function destoryCamp(campArr)
		for _,hero in ripairs(campArr) do
			-- 不再做死亡过程中的内容
			if hero.diedInfo then
				hero.diedInfo.canDo = false
			end
			-- 先隐藏
			hero:setVisible(false)
			hero:setOpacity(0)
			-- 销毁
			hero:deleteMe()
		end
		-- 置空
		-- campArr = {}
	end

	-- 重新创建人物相关内容
	local function reCreateHero(camp)
		local datas = three(camp == Fight.camp_1, self.levelInfo.campData1, self.levelInfo.waveDatas[1])
		for i,v in ipairs(datas) do
			local objHero = ObjectHero.new(v.hid, v)
			self.reFreshControler:createHeroes(objHero, camp, v.posIndex, Fight.enterType_stand, camp)
		end

		self.logical:sortCampPos(camp)

		for i,v in ipairs(self:getCampArr(camp)) do
			--初始化光环
			v.data:initAure()
			-- 做协助技
			v:doHelpSkill()
			-- 血条
			-- v.healthBar:showOrHideBar(true)
			-- v.healthBar:setOpacity(255)
		end
	end

	-- resetLattice
	local function resetLattice(campArr)
		for _,lattice in ipairs(campArr) do
			-- 清掉所有buff
			lattice:clearAllBuff(true)
		end
	end

	destoryCamp(self.campArr_1)
	destoryCamp(self.campArr_2)

	destoryCamp(self.diedArr_1)
	destoryCamp(self.diedArr_2)
	
	destoryCamp(self._dyingArr)

	reCreateHero(Fight.camp_1)
	reCreateHero(Fight.camp_2)

	-- 清理格子
	resetLattice(self.formationControler:getLatticeByCamp(Fight.camp_1))
	resetLattice(self.formationControler:getLatticeByCamp(Fight.camp_2))

	-- 重置logical数据
	self.logical:initWaveData()
	-- 重置统计信息
	StatisticsControler:resetStatisticsInfo()
	-- 重置循环点的随机数
	self.logical:resetCycleRandomSeed()
end

-- 做转场效果
function MiniGameControler:showTransitionEff(middleCallFunc, finalCallFunc)
	if self.gameUi then
		self.gameUi:shwoTransitionEff(middleCallFunc,finalCallFunc)
	else
		if finalCallFunc then finalCallFunc() end
	end
end

-- 调用miniLogicalControler的excuteShowSkillProcess方法
function MiniGameControler:excuteShowSkillProcess()
	self.logical:excuteShowSkillProcess()
end

-- override
function MiniGameControler:clearOneObject(target)
	MiniGameControler.super.clearOneObject(self, target)

	table.removebyvalue(self._dyingArr, target)
end

-- override
function MiniGameControler:pressGameQuit(...)
	if self.__gameStep == Fight.gameStep.result then
		return
	end
	self:setGameStep(Fight.gameStep.result)
	self._sceenRoot:unscheduleUpdate()
	
	local controler = MiniBattleControler.getInstance()
	controler:onExitBattle()
end

function MiniGameControler:isInMiniBattle()
	return true
end

return MiniGameControler