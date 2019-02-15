--
-- Author: xd
-- Date: 2016-09-13 16:30:11
--逻辑控制器
local Fight = Fight

-- local BattleControler = BattleControler -- 2018.04.14注掉，以这种方式赋值，BattleControler无法被全局替换
local table = table

LogicalControler  = class("LogicalControler")
--回合计数
LogicalControler.roundCount = 0
--操作信息表
--[[
	waves = {
		roundCount = {
			order = {
				{index = posIndex,type = 1,params=1,camp =1}
			},
			auto = {
				rid:{order = 0,value= 1表示自动 ,0表示取消自动}
			}

			state = {
				rid:{order = 0 ,value = 1,0下线}		
			}
		}
	} 
	 
	
操作协议
{
  type:int, 1 表示正常的技能攻击操作, 2表示 切换自动战斗, 3表示玩家掉线或者在线 ,4表示玩家的换位操作,
  info:string ,
    针对type1 的操作格式,由客户端传递,是一个json.encode后的字符串, 
    针对type2 玩家切换自动战斗, 1 表示 自动战斗, 0表示取消自动战斗,
    针对type3 玩家上线掉线操作, 0 表示玩家掉线, 1表示掉线重连,
    针对type4 玩家换位的操作格式,由客户端传递,是一个json.encode后的字符串, 

  index, 操作的序号,
  rid: 操作的玩家角色rid,
  wave:  第几波
  round: 第几回合
}

	
]]
--操作表
LogicalControler.operationMap = nil 

--手动操作行为表 比如 点击自动按钮, 比如取消自动, 比如吃buff,比如布阵完毕
LogicalControler.handleOperationInfo =nil
--[[
	p1 = {attackNums,wave,type,round,info,index} --p 后就是index值 
]]

LogicalControler.currentHandleIndex = 0 		--当前执行到的操作序列index,执行一次就+1

LogicalControler.lastCacheHandleIndex = 0 		--上次缓存的 操作index

--用户状态数组 
--[[
	--是否是自动战斗,是否是在线状态、本回合是否是自动战斗，回合布阵状态(每回合开始都会设置为true),换人状态
	rid = {auto = false, lineState = false,roundAuto = false,buzhenState = false,changeHero = false}
]]
LogicalControler.userStateMap = {
	
}
-- rid对应的camp对象
-- {"dev_123" = 1,"dev_234"=2}
LogicalControler.ridCamp = {
	
}



--当前是哪一方
LogicalControler.currentCamp = 1
--攻击中的hero2017.7.4
LogicalControler.attackingHero =nil
--被中断的攻击中的hero(放小技能时另一个人放了大招)
LogicalControler.preAttackingHero = nil

--当前回合已经攻击的人的数量	
LogicalControler.attackNums = 0

--当前回合插入的操作index 这个和attackNums有区别 
LogicalControler.attackHandleIndex = 0

--排队队列数组
LogicalControler.queneArr_1 = nil 
LogicalControler.queneArr_2 = nil 

--剩余连击时间 0 表示连击中断 > 0 表示连击中 可以连击计时 连击间隔是 2秒也就是60帧
LogicalControler.leftCombFrame = -1

--剩余自动战斗时间
LogicalControler.leftAutoFrame = -1
--计时状态
LogicalControler.countState = nil

--布阵的时间
LogicalControler.leftBuZhenFrame = -1
 
LogicalControler.logsInfo = ""
  
--是否在回合中
LogicalControler.isInRound = false 


--被动技能数组
LogicalControler.passiveGroup = nil

LogicalControler.uphandleCamp = 1 		--先手阵营

LogicalControler.atkPos = 1 -- 攻击位（roundModel_switch模式下用到）

-- 回合模式
LogicalControler.roundModel = 1 

-- 六界轶事 玩法技术(宝物、击杀数)
LogicalControler.missionNum = 0
--[[
	大招出手顺序，如果无值则按照默认大招Ai出手
	{
		camp_1 = {
			order = {
				key = partenrId, string key [1,n]出手顺序;string partenrId 伙伴Id，1为主角	
			}
			count = 1, 记录进行到的位置
		}
	}
]]
LogicalControler.maxSkillAiOrder = nil

-- 记录每回合的状态 {wave}
LogicalControler.roundStateMap = nil

--记录每个操作的tag ,比如自动战斗  就不能在一回合里面执行多次
LogicalControler.handleRunTagMap = nil


-- 战斗服的状态
LogicalControler._battleState = nil

LogicalControler._roundSTRP = nil -- 标记回合前流程位置
LogicalControler._roundENDP = nil -- 标记回合后流程位置

-- 战斗开始
LogicalControler._battleBegin = false -- 标记战斗是否已经开始（首次进入战斗过程后置为true）

-- 标记是否正在刷怪
LogicalControler._isrefreshing = false 

local globalAiOrder = nil

function LogicalControler:ctor( controler )
	if not BattleControler then
		BattleControler = _G["BattleControler"]
		Fight = _G["Fight"]
	end
	--初始化的时候给定状态是切换状态(修改为空闲状态，因为巅峰竞技场一进来追进度的时候有问题)
	self._battleState = battleState_none
	globalAiOrder = Fight.aiOrder
	self.controler = controler
	self.operationMap = { {},{},{} }
	self.handleOperationInfo = {}
	self.userStateMap = {}
	self.ridCamp={}
	self.handleRunTagMap = {}
	self.maxHandleIndex = 0

	self._roundSTRP = {
		step = 1, -- 回合流程标记
		heroP = {}, -- 存放执行到的人物标记
	}

	self._roundENDP = {
		step = 1, -- 回合流程标记
		heroP = {}, -- 存放执行到的任务标记
	}

	--拿到所有的user
	local userInfo = BattleControler._battleInfo.battleUsers
	for k,v in pairs(userInfo) do
		local _index = v.rid or v._id
		if not _index then _index = "1" end
		self.userStateMap[_index] = {auto = false,lineState =Fight.lineState_lineOn,roundAuto = false,
									buzhenState = false,changeHero = false}
		self.ridCamp[_index] = v.team or k
	end

	--当前的操作序号
	self.currentOperationIndex = 0

	self.roundStateMap = {}


	--当前阵营 默认是左方  以后有新规则在修改
	self.currentCamp = 1
	self.roundCount  = 1
	self.queneArr_1 ={}
	self.queneArr_2 ={}
	self.logsInfo =""
	self.isInRound = false
	self.passiveGroup = {}
	self.missionNum = 0

	self.maxSkillAiOrder = {
		[Fight.camp_1] = {
			order = nil,
			count = 1,
		},
		[Fight.camp_2] = {
			order = nil,
			count = 1,
		},
	}
end

function LogicalControler:setHandleOperationInfo( allInfo )
	self.handleOperationInfo = allInfo
end
-- 加载回合回怒机制
function LogicalControler:addRoundEnergy(camp)
	local energyCamp = self:getEnergyByRound(1,camp)
	self.controler.energyControler:addEnergy(Fight.energy_entire,energyCamp,nil,camp)
end
-- 根据回合数获取对应该增加的怒气值
function LogicalControler:getEnergyByRound(round,camp)
	local energyInfo = self.controler.levelInfo:getBattleEnergyRule()
	-- 仙界对决有双倍回怒的玩法
	local diff = 1
	if BattleControler:checkIsCrossPeak() and 
		self.controler.levelInfo:getCrosspeakPlayType() == Fight.crosspeak_energy then
		diff = 2
	end
	local energyCamp = energyInfo.roundEnergy + energyInfo.roundEnergyDiff * (round - 1) * diff
	local roundEnergyMax = self.controler.energyControler:getRoundEnergyMax(camp)
	if energyCamp > roundEnergyMax then energyCamp = roundEnergyMax end
	return energyCamp
end

--初始化一波数据
function LogicalControler:initWaveData(  )
	self.roundCount = 1
	self.currentCamp = 1

	--如果对方先手比我高 那么 对方先出手
	if self.controler:getUphandle(1) < self.controler:getUphandle(2) then
		self.currentCamp = 2
	end
	-- 巅峰竞技场随机一方出手
	if BattleControler:checkIsCrossPeak() then
		self.currentCamp = self.controler.cpControler:getHandleCamp()
		-- 另一方添加一点怒气
		local ecamp = self.currentCamp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
		self.controler.energyControler:addEnergy(Fight.energy_entire, 
			Fight.energy_add_by_crosspeak, nil, ecamp)

		self:addRoundEnergy(self.currentCamp)
	end
	--记录先手阵营
	self.uphandleCamp = self.currentCamp

	self.attackingHero =nil
	self.queneArr_1 ={}
	self.queneArr_2 ={}
	self.roundStateMap = {}
	-- 切波可能会退还怒气
	self.controler.energyControler:returnEnergyByCamp()
	-- 先在这里给模式赋值
	-- self.roundModel = Fight.roundModel_normal
	-- self.roundModel = Fight.roundModel_semiautomated
	-- self.roundModel = Fight.roundModel_switch
end

-- 初始化回合模式
function LogicalControler:initRoundModel(gameMode)
	local bLabel = BattleControler:getBattleLabel()
	if bLabel == GameVars.battleLabels.pvp then
		self.roundModel = Fight.roundModel_switch
	else
		self.roundModel = Fight.roundModel_semiautomated
	end
	-- gameMode = gameMode or Fight.gameMode_pve
	-- if gameMode == Fight.gameMode_pvp then

	-- 	self.roundModel = Fight.roundModel_switch
	-- else
	-- 	self.roundModel = Fight.roundModel_semiautomated
	-- end
end

-- 根据初始化自动战斗状态
function LogicalControler:initAutoStatus( )
	for k,v in pairs(self.userStateMap) do
		if k == self.controler:getUserRid() then
			local scode = self.controler:getUserAutoStatus(k)
			if scode == 1 then
				-- self.controler.server:sendOneAutoHandle({auto=1})
				self.controler:setGameAuto(true)
			end
			break
		end
	end
end

--每帧刷新函数 主要是一些及时操作
function LogicalControler:updateFrame()
	--更新剩余自动战斗时间
	self:updateAutoFrame()
end



--更新剩余自动战斗时间
function LogicalControler:updateAutoFrame(  )
	if not BattleControler:checkIsCrossPeak() then
		-- 如果是敌方阵营的
		if self.currentCamp == 2 then
			return
		end
	end
	-- 复盘、pvp、暂停
	if self.controler:isReplayGame() or
		BattleControler:checkIsPVP() or
		self.controler:isCountDownPause()
	 		then
		return
	end
	if self.leftAutoFrame > 0 then
		self.leftAutoFrame = self.leftAutoFrame -1
		-- echo("bb===",self.leftAutoFrame)
		if self.leftAutoFrame == 0 then
			self:setLeftAutoFrame(-1)
			local bState = self:getBattleState()
			echo ("战斗状态:",bState,"====")
			if bState == Fight.battleState_switch then
				self:endRound(self.currentCamp )
			elseif bState == Fight.battleState_changePerson then
				if not BattleControler:checkIsMultyBattle() then
					self.controler.server:sendChangeHeroFinishHandle({change=1,camp = BattleControler:getTeamCamp()})
				end
				self:setLeftAutoFrame(self:getWaitTime())
			elseif bState == Fight.battleState_formation then
				if not BattleControler:checkIsMultyBattle() then
					self.controler.server:sendBuZhenFinishHandle({camp = BattleControler:getTeamCamp()})
				end
				self.controler:closeTutorial()
			elseif bState == Fight.battleState_selectPerson then
				self.controler.cpControler:chkCrossPeakBpByTimeOut()
			elseif bState == Fight.battleState_formationBefore then
				self.controler.cpControler:chkCrossPeakBeforeChangeByTimeOut()
			end
		end
	else
		-- echo("s====")
	end
end

-- 获取倒计时对应的时间
function LogicalControler:getLeftAutoFrame( )
	return self.leftAutoFrame
end
-- 供外部调用的
function LogicalControler:setLeftAutoFrame( value )
	self.leftAutoFrame = value
end
--开始一回合
function LogicalControler:startRound(  )
	echo ("_________strtRound",self.currentCamp)
	-- 移除掉黑屏特效
	self.controler:hideBlackScene()

	--开始时 随机确定小技能
	--首回合最少给2个skill
	-- SkillChooseExpand:sureSkillIndex(self, self.currentCamp  )

	--先清除被动技能序列
	self:clearPassiveSkill()

	self.leftCombFrame = -1

	self:changeAllBuZhenStatus(false)--将布阵按钮状态设置为false
	--同步用户的自动战斗状态
	for k,v in pairs(self.userStateMap) do
		v.roundAuto = v.auto
	end

	--做回合前的事情
	self.attackNums = 0
	self.attackHandleIndex = 0
	--回合前血条全量
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = true})
	-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = self.currentCamp ==1 and 2 or 1,visible = true})
	self._battleBegin = true
	
	-- 首回合(第一波)
	if self.controler.__currentWave == 1 and self.roundCount == 1 then
		self:updateBattleState(Fight.battleState_wait)
		if not Fight.isDummy then
			-- 战斗开始前打点
			self.controler:doClientAction(0)
		end
	end

	self:toRoundStr()
	return self:doRoundFirst(self.currentCamp)
end

-- 更新阵位加强信息
function LogicalControler:updateElementEnhance()
	for i,hero in ipairs(self.controler.campArr_1) do
		hero:updateElementEnhance()
	end
	for i,hero in ipairs(self.controler.campArr_2) do
		hero:updateElementEnhance()
	end
end

--one heroRead
function LogicalControler:oneHeroReady(  )
	echo("正常开始一个回合",self.isInRound)
	--如果已经是在回合中了 那么不判断了
	if self.isInRound then
		return
	end


	local campArr = self.currentCamp == 1 and self.controler.campArr_1 or self.controler.campArr_2

	-- if Fight.isDummy then
	-- 	return 
	-- end
	if self:checkCampHasRelive(self.currentCamp) then
		return 
	end
	--遍历所有人 判定是否ready
	for i,v in ipairs(campArr) do
		if not v.isRoundReady then
			return 
		end
	end
	
	local mapStr = self.controler.__currentWave *100 +self.roundCount;
	if self.roundStateMap[mapStr] then
		return
	end
	self.roundStateMap[mapStr] = true

	-- 隐藏可能存在的总伤害（因为回合前的技能不走onSkillActionComplete）
	local totalEff = self.controler.__totalDamageEff
	if totalEff and totalEff.setShowEnd then
		totalEff:setShowEnd(true)
	end

	return self:delayStartRound()
end

--回合开始前 需要延迟一会才开打 比如可能会延迟受伤  buff 等等
function LogicalControler:delayStartRound()
	-- self.controler.artifactControler:checkSpiritSkill(1, "9050101", self.controler.campArr_1[1])
	-- 神器回合前技能
	return self.controler.artifactControler:checkArtifactChance(self.currentCamp, Fight.artifact_roundStart)
end
-- 这里加入一个神力的使用阶段
function LogicalControler:startSpiritPowerRound( )
	self:updateBattleState(Fight.battleState_none)
	if BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
		self.controler.resIsCompleteLoad = true --这里直接标记资源加载完成
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_LEVEL_HP_SHOW)
		-- 只有第一次进来才会发这个操作
		-- if self.currentCamp == Fight.camp_1 then
			if Fight.isDummy or self.controler:isQuickRunGame() or 
			self.controler:isReplayGame() then
				return self:readSaveHandle()
			else
				if self.roundCount == 1 then
					-- 如果是断线重连进来的，需要发这个操作、否则发资源加载完成操作
					self.controler.server:loadBattleResOver()
					-- 发送资源加载完成操作(这个是操作)(等待进入神力阶段)
					self.controler.server:sendGuildBossReady()
				else
					self:sendGuildBossGveStartRound()
				end
			end
		-- else
		-- 	self:realStartRound()
		-- end
	else
		return self:realStartRound()
	end
end
-- 多人共闯秘境发送开始战斗
function LogicalControler:sendGuildBossGveStartRound( )
	local info = {camp = self.currentCamp,nextState = Fight.bzState_buzhen,canCtrl=1}
	self.controler.server:sendStartRoundHandle(info)
end

-- 加一个中间过程，为了插入神器的流程
function LogicalControler:realStartRound()
	self.controler.viewPerform:resumeViewAlpha()

	-- 第一回合、校验自动战斗
	if self.controler:isTowerTouxi() then
		if self.roundCount == 2 then
			self:initAutoStatus()
		end
	else
		if self.roundCount == 1 then
			self:initAutoStatus()
		end
	end
	-- 检查缓存的自动战斗状态
	self.controler:chkSendGameAuto()

	--如果已经出结果了
	if self.controler.__gameStep == Fight.gameStep.result then
		return
	end
	-- 锁妖塔战斗的时候，有可能第一波怪物已经死亡。所以当没有第一波怪物的时候，直接跳过第一波怪物
	if BattleControler:checkIsTower() or BattleControler:checkIsExploreBattle()  then
		if #self.controler.campArr_2 == 0 then
			self.controler:chkNextRound()
			return
		end
	end
	echo("delyaStartRound------------",self.currentCamp,self.roundCount)
	if self.currentCamp == Fight.camp_1 then
		self.controler:loadBattleBuffs()
		self.controler:loadRefreshQuestions()
	else
		self.controler:chkRefreshQuestionResult(true)
	end

	self.controler:setGameStep(Fight.gameStep.battle)
	self.isInRound = true

	--回合前的自动战斗时间为20秒
	if self.currentCamp == 1 then
		self:setLeftAutoFrame(Fight.autoFightFrame1)
	end
	-- 弱引导倒计时
	if not self:checkIsAutoAttack(self.currentCamp) then
		-- self.controler:setWeakGuideCount(true)
	end
	for i=#self.controler.campArr_1,1,-1 do
		local hero = self.controler.campArr_1[i]
		hero:checkWordEff()
	end
	local rCount = self.controler:getCurrRound()
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_beforeRound,roundCount = rCount})
	-- echo("开始新的回合---------",self.currentCamp)
	--发送回合开始事件  如果超时 就设置为自动 
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ROUNDSTART,self.currentCamp)
	if self.roundCount == 1 then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOW_SKILLICON)
	end

	
	-- 当是敌方回合时，如果状态为等待，说明触发了文本，需要等待
	local wait = self.controler:chkRoundStartPlot()
	--回合开始前的引导（约定上面的和这里引导的不会同时触发）
	wait = self.controler:chkXvZhangTutorialRoundStart(wait)

	if wait then
		return
	end

	if self.currentCamp == 2  then
		--如果是调试hero的  return
		if self.controler.isDebugHero then
			return
		end
	end
	local atkHandleInfo = self:readSaveHandle()
	--如果是有攻击行为的 那么直接return
	if atkHandleInfo then
		-- echo("如果是有攻击行为的 那么直接return")
		return
	end
	-- 第一回合做的特殊处理
	if self.roundCount == 1 and self:checkHasFirstRoundEspecial() then
		return
	end

	
	if BattleControler:checkIsCrossPeak() then
		if self:chkchangeHero(self.currentCamp) then
			if not BattleControler:checkIsMultyBattle() then
				-- 多人的时候，需要等待服务器推送才可以布阵
				self.controler.formationControler:doChangeHero()
			end
		else
			return self:checkNextHandle(self.currentCamp)
		end
	else
		-- 检查布阵
		if self:chkBeforeRoundBuZhen(self.currentCamp) then
			if not BattleControler:checkIsMultyBattle() then
				-- 多人的时候，需要等待服务器推送才可以布阵
				self.controler.formationControler:doChangeHero()
			end
		else
			return self:checkNextHandle(self.currentCamp)
		end
	end
end
--本回合自动战斗
function LogicalControler:doAutoFightAi(rid,camp,needCheckReadSave)
	rid = rid or self.controler:getUserRid()
	camp = camp or self.ridCamp[rid]
	echo ("回合自动战斗---",rid,camp,self.currentCamp,self.controler.__gameStep,
		self.attackingHero,BattleControler:getTeamCamp(),self.controler:getUserRid())
	if self.currentCamp ~= camp then
		return
	end
	
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end
	--如果当前有正在攻击的人 那么不执行
	if self.attackingHero then
		return 
	end
	self:updateBattleState(Fight.battleState_battle)
	return self:checkNextHandle(camp)
end

-- 回合前流程检查顺序（写在这里只初始化一次）
local processSTRT = {
	[Fight.process_relive] = 1,
	[Fight.process_treasure] = 2, -- 换法宝
	[Fight.process_myRoundStart] = 3,
	[Fight.process_enemyRoundStart] = 4,
}
-- 回合后流程检查顺序
local processENDT = {
	[Fight.process_end_treasure] = 1,
	[Fight.process_end_myRoundEnd] = 2,
	[Fight.process_end_enemyRoundEnd] = 3,
}
local processSTRTR = {}
local processENDTR = {}
-- 初始化另一个表
local function initTR()
	for k,v in pairs(processSTRT) do
		processSTRTR[v] = k
	end
	for k,v in pairs(processENDT) do
		processENDTR[v] = k
	end
end

initTR()

-- roundType 1 回合前 2 回合后
function LogicalControler:processRound(roundType, key, camp)
	local useTable = roundType == Fight.p_roundStart and processSTRTR or processENDTR
	local roundP = roundType == Fight.p_roundStart and self._roundSTRP or self._roundENDP
	-- 检查顺序
	local key = key or useTable[roundP.step]
	-- 按顺序执行每一个人当前key下需要进行的内容
	local campArr = nil
	-- 敌方回合阵营初取敌方
	if key == Fight.process_enemyRoundStart 
		or key == Fight.process_end_enemyRoundEnd
	then
		campArr = self.controler:getCampArr(camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1)
	else
		campArr = self.controler:getCampArr(camp)
	end
	-- 找人
	local function findOneHero(campArr)
		local hero = nil

		for _,h in ipairs(campArr) do
			if not roundP.heroP[h] then
				hero = h
				roundP.heroP[h] = true
				break
			end
		end

		return hero
	end

	local hero = findOneHero(campArr)
		
	-- 这种情况需要检查死人堆里有没有要复活的
	if not hero and key == Fight.process_relive then
		local diedArr = self.controler:getDiedCampArr(camp)
		hero = findOneHero(diedArr)
	end

	-- 
	if hero then
		if roundType == Fight.p_roundStart then
			return hero:doRoundFirstProcess(key)
		elseif roundType == Fight.p_roundEnd then
			return hero:doRoundEndProcess(key)
		end
	else
		-- 进行下一个流程
		roundP.step = roundP.step + 1
		roundP.heroP = {}
		local newkey = useTable[roundP.step]

		-- echo("转换新的key",camp,roundType,roundP.step,newkey)
		
		if newkey then
			return self:processRound(roundType, newkey, camp)
		else
			if roundType == Fight.p_roundStart then
				-- 可以正常开始回合了
				return self:oneHeroReady()
			elseif roundType == Fight.p_roundEnd then
				-- 正常结束回合
				return self:checkRoundWait(camp)
			end
		end
	end
end

-- 重置流程状态
function LogicalControler:resetRoundSTRP()
	self._roundSTRP = {
		step = 1, -- 回合流程标记
		heroP = {}, -- 存放执行到的人物标记
	}
end

-- 重置回合后流程状态
function LogicalControler:resetRoundENDP()
	self._roundENDP = {
		step = 1, -- 回合后流程标记
		heroP = {}, -- 存放执行到的人物标记
	}
end

--回合前做些事
function LogicalControler:doRoundFirst( camp )
	local campArr = self.controler:getCampArr(camp)
	-- local length = #campArr


	-- 锁妖塔不需要回合回怒
	if not BattleControler:checkIsTower() then
		local round = math.ceil(self.controler:getCurrRound()/2)
		local energyCamp = self:getEnergyByRound(round,camp)
		-- 引导过程中可能会影响到怒气值
		energyCamp = self.controler:chkXvZhangEnergy(energyCamp)
		
		self.controler.energyControler:addEnergy(Fight.energy_entire, energyCamp, nil, camp)

		-- 这个模式下，两边怒气一起涨
		if self.roundModel == Fight.roundModel_switch then
			local toCamp = camp == Fight.camp_1 and Fight.camp_2 or Fight.camp_1
			local energyToCamp = energyCamp
			roundEnergyMax = self.controler.energyControler:getRoundEnergyMax(toCamp)
			if energyToCamp > roundEnergyMax then energyToCamp = roundEnergyMax end
			self.controler.energyControler:addEnergy(Fight.energy_entire, energyToCamp, nil, toCamp)			
		end
	end

	local function echoEnergy(camp)
		echo("回合开始前阵营:%s,总怒气:%s",camp,self.controler.energyControler:getEnergyInfo(camp).entire)
	end

	echoEnergy(Fight.camp_1)
	echoEnergy(Fight.camp_2)

	local function _setRoundReady(b)
		for i=#campArr,1,-1 do
			local hero = campArr[i]
			hero:setRoundReady(b)
		end
	end

	self:resetRoundSTRP()

	--重置标记，结算buff等不占用时间
	for i=#campArr,1,-1 do
		local hero = campArr[i]
		hero:doRoundFirst()
	end

	if self.roundCount == 1 then
		-- 第一个回合需要更新一下两个阵营人物的阵位加强的信息（目前是技能等级导致的技能参数变化）
		self:updateElementEnhance()
	end

	-- 敌方回合前做的事情（这里目前只有动作相关没有需要等待内容，不加入流程）
	-- 切记如果这里如果有需要等待帧长度的事情，一定要加入流程进行单人遍历，不然会有复盘问题
	local toArr = camp == 1 and self.controler.campArr_2 or self.controler.campArr_1
	for k,v in pairs(toArr) do
		v:doToRoundFirst()
	end

	return self.controler.triggerSkillControler:excuteTriggerSkill(c_func(self.processRound, self, 1, Fight.process_relive, camp))
	-- return self:processRound(1, Fight.process_relive, camp)
end

--回合结束后做什么事
function LogicalControler:doRoundEnd( camp )
	-- 更新阵位信息
	self.controler.formationControler:updateRoundEnd(camp)
	--回合结束后应该让对方阵营 
	local campArr = self.controler:getCampArr(camp)
	local toCamp = camp ==1 and 2 or 1
	local toArr = self.controler:getCampArr(toCamp)
	--判断是否主角攻击类法宝需要崩溃
	local length =#campArr
	for i=length,1,-1 do
		local hero = campArr[i]
		hero:doRoundEnd()
	end
	length = #toArr
	for i=length,1,-1 do
		local hero = toArr[i]
		hero:doToRoundEnd()
	end

	-- 这种回合模式下buff在对方回合也需要刷新（就是为了刷新buff）
	if self.roundModel == Fight.roundModel_switch then
		local length =#toArr
		for i=length,1,-1 do
			local hero = toArr[i]
			hero:doRoundEnd()
		end

		length = #campArr
		for i=length,1,-1 do
			local hero = campArr[i]
			hero:doToRoundEnd()
		end
	end

	self:resetRoundENDP()

	--发送回合后
	-- if camp == 1 then
	-- 	self:doChanceFunc({camp = 1,chance =Fight.chance_roundEnd})
	-- 	self:doChanceFunc({camp = 2,chance = Fight.chance_toEnd})
	-- else
	-- 	self:doChanceFunc({camp = 2,chance =Fight.chance_roundEnd})
	-- 	self:doChanceFunc({camp = 1,chance = Fight.chance_toEnd})
	-- end

	return self:processRound(2, Fight.process_end_treasure, camp)
end


--判断进入下一回合
function LogicalControler:enterNextRound( camp )

	self:setLeftAutoFrame(-1)

	echo(self.currentCamp,"___进入下一回合",camp)

	self.roundCount = self.roundCount +1
	if camp == 1 then
		self.currentCamp = 2
	else
		self.currentCamp = 1
	end
	local bLabel = BattleControler:getBattleLabel()
	--如果是最后一回合了
	-- pangkangning 2017.11.08 修改当前波数的判定
	if self.controler:getCurrRound() == self.controler:getMaxRound() then
		if BattleControler:checkIsShareBossPVE() or
			bLabel == GameVars.battleLabels.guildBossPve or
			bLabel == GameVars.battleLabels.missionBombPve or
			BattleControler:checkIsTrail() ~= Fight.not_trail or
			bLabel == GameVars.battleLabels.exploreElite     then
			return self.controler:enterGameWin()
		elseif BattleControler:checkIsCrossPeak() then
			-- 巅峰竞技场校验到底谁赢谁数
			return self.controler.cpControler:chkCrossPeakEnd()
		else
			return self.controler:enterGameLose()
		end
	end

	return self.controler:checkNewRoud()
end

--[[
	检查协助攻击
	@@lastHero 刚刚完成攻击的hero
	@@lastSkillIndex 刚刚释放的技能index
	return是否进行了协助攻击
]]
function LogicalControler:chkDoAssistAttack(lastHero,lastSkillIndex)
	-- 之后大招之后才会做协助攻击
	if lastSkillIndex ~= Fight.skillIndex_max then return false end
	if not lastHero then return false end
	if lastHero._isDied then return false end

	local result = false
	local tHero = nil
	local tSkill = nil

	-- 现在只检查己方
	local campArr = lastHero.campArr

	-- 目前不会有多个人一起协助攻击，所以没有考虑有多个的情况
	for _,hero in ipairs(campArr) do
		result,tSkill = hero:chkDoAssistAttack(lasthero,lastSkillIndex)
		if result then
			tHero = hero
			break
		end
	end

	-- 做协助攻击
	if result then
		-- 标记为正在攻击
		self.attackingHero = tHero
		tHero:checkSkill(tSkill, false, tSkill.skillIndex)
	end

	return result
end

--指派谁开始攻击
function LogicalControler:checkAttack(operationInfo)
	--如果不是战斗状态是不允许攻击的
	if self.controler.__gameStep ~= Fight.gameStep.battle then
		return
	end
	self:updateSkillStartFrameIdx() --更新技能开始帧
	local camp = operationInfo.camp
	local posIndex = operationInfo.index
	local operationType = operationInfo.type
	local params = operationInfo.params
	-- 后续逻辑与timely无关

	--判断敌方是否人数为0了，并且不是即时的攻击（即时攻击要强行打出来）
	local toArr = camp == 1 and self.controler.campArr_2 or self.controler.campArr_1
	-- echo("是否已经走到了这里",#toArr,timely,self.controler:chkLiveHero(toArr))
	if (not self.controler:chkLiveHero(toArr) ) then

		--如果对方没人了 但是有复活的对象  
	    self:endRound(camp)
		return 
	end

	-- 如果是神器技能
	local heroModel = nil
	-- 如果是神器技能
	if operationType == Fight.operationType_artifactSKill then
		heroModel = self.controler.artifactControler:getArtifactModel(camp)
	else
		heroModel = self:findHeroModel(camp,posIndex)
	end

	if heroModel then
		-- 出手时标记状态
		if operationType ~= Fight.operationType_artifactSKill then
			if self.roundModel == Fight.roundModel_normal then
				--设定操作为true
				heroModel.hasOperate = true
			elseif self.roundModel == Fight.roundModel_semiautomated
				or self.roundModel == Fight.roundModel_switch
			then
				if params == Fight.skillIndex_small then
					heroModel.hasAutoMove = true
				else
					heroModel.hasOperate = true
				end
			end
		end

		heroModel.isWaiting = false

		if not self:checkIsAutoAttack(camp,heroModel.data.characterRid) then
			self:setLeftAutoFrame(-1)
		end

		if self.attackingHero then
			self.preAttackingHero = self.attackingHero
		end
		self.attackingHero = heroModel
		self.attackNums = self.attackNums +1

		-- 统计出手次数
		StatisticsControler:addHandleNumber(heroModel.camp)

		-- 这里技能一定已经出手，去除一条缓存
		self.controler.energyControler:dequequeEnergyCache(heroModel, operationInfo.skillId)

		if operationType == Fight.operationType_giveSkill then
			return heroModel:checkSkill(nil,false,params)
		elseif operationType == Fight.operationType_giveTreasure then
			return heroModel:checkTreasure(params)
		elseif operationType == Fight.operationType_artifactSKill then
			return self.controler.artifactControler:checkArtifactSkill(camp, operationInfo.skillId)
		end
	else
		-- 中途被反死会导致放不出来
		-- echoError("____为什么heroModel不存在,检查配表不一致-----")
		self.attackNums = self.attackNums +1
		return self:checkNextHandle(camp)
	end
end

--[[
	攻击完成，相关变量重置后进行的内容
	@@lastHero 刚刚完成攻击的hero
	@@lastSkillIndex 刚刚释放的技能index
]]
function LogicalControler:onAttackComplete(lastHero,lastSkillIndex)
	-- 有人攻击结束后 检查缓存的自动战斗状态发操作做同步
	self.controler:chkSendGameAuto()

	--攻击完成切换成空闲状态
	self:updateBattleState(Fight.battleState_none)
	-- self.handleState = Fight.handleState_idle 
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ATTACK_COMPLETE,{camp = lastHero.camp})
	self.attackingHero = nil
	self.preAttackingHero = nil

	-- 攻击结束之后将阵位隐藏（人物被攻击时如果受到阵位保护，阵位会显示出来）
	self.controler.formationControler:doFinishBuZhen()
	
	if not Fight.isDummy  then
		self.controler.screen:setFollowType(2,{x=self.controler.middlePos,y = GameVars.halfResHeight})
		self.controler.camera:setScaleTo({10,1},{x=self.controler.middlePos,y = Fight.initYpos_3 })
	end

	--如果已经出结果了
	if self.controler.__gameStep == Fight.gameStep.result then
		return 
	end

	-- 如果跳过验证则不再继续
	if self.controler:isCancelCheck() then
		return
	end

	-- 如果有协助攻击
	if self:chkDoAssistAttack(lastHero,lastSkillIndex) then
		return
	end
	
	-- 检查是否有怪可刷

	-- 先取操作
	local operation = self:getOneHandle(self.currentCamp, self.attackNums + 1)
	-- 有操作 而且是结束回合的操作 那么直接endround
	if operation and operation.type == Fight.operationType_endRound  then
		echo("_强制结束回合,",self.currentHandleIndex)
		return self:doEndRound(operation.camp)
	end

	local camp,posIndex = lastHero.camp,lastHero.data.posIndex
	-- 检查是否需要刷怪
	if self.controler.reFreshControler:checkRefreshMonster(camp) then
		return
	end

	local switch,wait,camp = self:chkSwitchRound(camp)
	echo("切换回合相关数据======================",switch,wait,camp)
	-- 如果在序章引导过程中有可能会触发等待而不继续进行攻击
	wait,switch = self.controler:chkIsXvZhangTutorialAtkComp(posIndex, camp, self.attackNums,wait,switch)

	if switch then
		--先读取缓存操作 因为缓存操作里面也可能会有endround
		if self:readSaveHandle() then
			return
		end

		return self:endRound(camp)
	else
		if not wait then
			--从操作库里面读取	
			return self:checkNextHandle(camp)
		else
			--先读取缓存操作 因为缓存操作里面也会有操作 可能会结束回合
			if self:readSaveHandle() then
				return
			end
			-- 等待也需要显示血条
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = true})

		end
	end
end

-- 检查切换回合
function LogicalControler:chkSwitchRound(camp)
	-- 根据模式确定是否切换回合
	local switch = true
	local wait = false
	local camp = camp

	if self.roundModel == Fight.roundModel_normal then
		-- 我方人都攻击完了,并且没有储存的操作
		local operation = self:getOneHandle(camp, self.attackNums + 1)
		if not operation then
			local campArr = self.controler:getCampArr(camp)
			for _,hero in ipairs(campArr) do
				if not hero.hasOperate and hero.data:checkCanAttack() then
					switch = false
					break
				end
			end
		else
			switch = false
		end
		-- 对面没人了（或没有活人了）应该切换回合
		if #self.controler.campArr_2 == 0 and camp == 1 or not self.controler:chkLiveHero(self.controler.campArr_2) then
			switch = true
		end
	elseif self.roundModel == Fight.roundModel_semiautomated then
		-- 读存的攻击序列
		local operation = self:getOneHandle(camp, self.attackNums + 1)
		if not operation then
			-- 我方人都自动行动完了 且没有人能放大招了（有人能放大招就等几秒）
			local campArr = self.controler:getCampArr(camp)
			for _,hero in ipairs(campArr) do
				if not hero.hasAutoMove and hero.data:checkCanAttack() then
					switch = false
					break
				end
			end

			-- 都行动完了检查还有没有人能放大招
			if switch then
				for _,hero in ipairs(campArr) do
					if not hero.hasOperate and hero.data:checkCanGiveSkill() then
						-- 自动战斗不进入切换等待，技能直接甩出去
						if self:checkIsAutoAttack(camp,hero.data.characterRid) then
							switch = false 
						else
							-- pangkangning 2017.12.13 打开大招等待的3秒钟
							-- pangkangning 2017.11.16 注释掉大招等待的3秒钟
							switch = false
							wait = true
							self:updateBattleState(Fight.battleState_switch)
							echo("___进入等待时间-----",self.leftAutoFrame,"进入切换")
						end
						break
					end
				end
			end

			-- 对面没人了（或没有活人了）应该切换回合
			if #self.controler.campArr_2 == 0 and camp == 1 or 
				not self.controler:chkLiveHero(self.controler.campArr_2) then
				switch = true
				wait = false
				self:setLeftAutoFrame(-1)
			end
		else
			switch = false
		end
	elseif self.roundModel == Fight.roundModel_switch then
		-- 双方6人打完
		switch = false
		-- camp = camp == 1 and 2 or 1
		local toCamp = self.currentCamp == 1 and 2 or 1

		while self.atkPos <= 6 do
			-- 回合持有方
			local hero = self:findHeroModel(self.currentCamp, globalAiOrder[self.atkPos])
			-- 对方
			local heroTo = self:findHeroModel(toCamp, globalAiOrder[self.atkPos])

			if hero and not hero.hasAutoMove and hero.data:checkCanAttack() then
				camp = self.currentCamp
				break
			elseif heroTo and not heroTo.hasAutoMove and heroTo.data:checkCanAttack() then
				camp = toCamp
				break
			else
				self.atkPos = self.atkPos + 1
			end
		end

		if self.atkPos > 6 then
			self.atkPos = 1
			-- 如果双方还有没出手的人（重置攻击了）不切回合再来一次遍历
			local campArr1 = self.controler["campArr_1"]
			local campArr2 = self.controler["campArr_2"]
			local flag = false
			for _,hero in ipairs(campArr1) do
				if not hero.hasAutoMove and hero.data:checkCanAttack() then
					flag = true
					break
				end
			end
			if not flag then
				for _,hero in ipairs(campArr2) do
					if not hero.hasAutoMove and hero.data:checkCanAttack() then
						flag = true
						break
					end
				end
			end
			
			if flag then
				switch = false
			else
				camp = self.currentCamp
				switch = true
			end
		end
	end
	
	self.controler.viewPerform:resumeViewAlpha()
	-- 当是第一回合并且是锁妖塔偷袭战的时候
	if self.controler:isTowerTouxiAndFirstWaveRound() then
		switch = true
		camp = 2
	end

	if Fight.isDummy or self.controler:isReplayGame() then
		wait = false
	end

	return switch,wait,camp
end

-- 结束一个回合
function LogicalControler:endRound( camp )
	if BattleControler:checkIsMultyBattle() then
		-- 复盘的情况下直接读操作（追进度类似复盘）
		if self.controler:checkIsInProgress() 
			or Fight.isDummy 
			or self.controler:isReplayGame() 
		then
			return self:readSaveHandle()
		else
			return self.controler.server:sendEndRoundHandle({camp = camp})
		end
	else
		return self:doEndRound(camp)
	end
end
-- 做结束一回合该做的事情
function LogicalControler:doEndRound( camp )
	self.isInRound =false
	echo("正常回合结束 ===",self.isInRound)
	self.controler.reFreshControler:updateRefreshWave()

	local rCount = self.controler:getCurrRound()
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,{tType = Fight.talkTip_afterRound,roundCount = rCount})
	self:updateBattleState(Fight.battleState_wait)

	return self.controler.artifactControler:checkArtifactChance(self.currentCamp, Fight.artifact_roundEnd, camp)
end

function LogicalControler:endRoundThing(camp)
	--这里需要延迟一会才进入下一回合 因为 这个时候 可能有人还没有恢复过来
	
	--如果对方有将要复活的人 那么就复原位置
	if self:checkCampHasRelive(camp == 1 and 2 or 1) then
		self:clearQueneAndInitPos(camp)
	end

	-- 回合结束可能会退还怒气
	self.controler.energyControler:returnEnergyByCamp(camp)

	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ROUNDEND)

	if not Fight.isDummy  then
		self.controler.viewPerform:resumeViewAlpha(true)
		--让屏幕焦点移到中心去
		self.controler.screen:setFollowType(2,{x=self.controler.middlePos,y = GameVars.halfResHeight})
		self.controler.camera:setScaleTo({10,1},{x=self.controler.middlePos,y = Fight.initYpos_3 })
	end

	return self:doRoundEnd(camp)
end

function LogicalControler:checkRoundWait(camp)
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2
	--遍历所有人 判定是否ready
	for i,v in ipairs(campArr) do
		if not v.isRoundReady then
			return 
		end
	end

	if camp == Fight.camp_1 then
		local isWait = self:checkIsEmptyOrIsMonkey()
		if isWait then
			return
		else
			-- 在六界轶事夺宝中。没有刷新的怪物、并且场上没有怪物了
			if BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve and
				self.controler.reFreshControler:getRefreshCount() == 0 and
				#self.controler.campArr_2 == 0 then
					self.controler:enterGameWin()
				return
			end
		end
	    -- 炸药桶
	    if BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve then
	    	if self.controler.reFreshControler:getRefreshCount() > 0  then
	    		-- 如果刷怪，需要等待
	    		if self:checkRefresh() then
	    			return
	    		end
	    	else
	    		if #self.controler.campArr_2 == 0 then
					self.controler:enterGameWin()
	    			return
	    		end
	    	end
	    end
	else
		-- 车轮战
	    if self.controler.levelInfo:chkIsRefreshType() then
	    	-- 如果、刷怪ai不计入结算，场上没有活人
			local isFinish = self.controler.reFreshControler:checkIsFinish()
			if isFinish and not self.controler:chkLiveHero(self.controler.campArr_2)  then
				self.controler:enterGameWin()
				return
			end
	    	if self.controler.reFreshControler:getRefreshCount() > 0  then
	    		-- 如果刷怪，需要等待
	    		if self:checkRefresh() then
	    			return
	    		end
	    	else
	    		if #self.controler.campArr_2 == 0 then
					self.controler:enterGameWin()
	    			return
	    		end
	    	end
	    end
	end
	if not Fight.isDummy  then
		self.controler:pushOneCallFunc(Fight.roundSwitchFrame, c_func(self.enterNextRound,self),{camp}  )
	else
		return self:enterNextRound(camp)
	end
end

--判断下一次操作
function LogicalControler:checkNextHandle( camp )
	-- 先取操作
	local operation = self:getOneHandle(camp, self.attackNums + 1)
	-- echoError ("ac------",operation,self.controler.__currentWave,self.roundCount,camp, self.attackNums + 1)
	-- 有操作
	if operation then

		--如果是强制结束回合了就不往下走了
		if operation.type == Fight.operationType_endRound then
			self.attackNums = self.attackNums + 1
			self:doEndRound(operation.camp)
			return
		else
			return self:checkAttack(operation)
		end

	else -- 没有操作插入操作
		-- 如果是有可操作人物的状态（普通模式）
		if self:chkInRoundBuZhen(camp) then
			self.controler.viewPerform:resumeViewAlpha()
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWHEALTHBAR,{camp = 0,visible = true})		
			return
		end
		local atkHandleInfo = self:readSaveHandle()
		--如果是有攻击行为的 那么直接return
		if atkHandleInfo then
			return
		end

		local hero = self:findNextHero(camp)
		-- self:findHeroModel(camp,self.atkPos) -- 获取攻击位的人物
		-- 无人可攻击
		if not hero then
			-- 当是pvp情况下，无人可攻击可能是第一回合攻击位没有刷新导致的，此时是否切换回合也应该由方法决定
			if self.roundModel == Fight.roundModel_switch then
				local switch,wait,camp = self:chkSwitchRound(camp)
				if switch then
					return self:endRound(camp)
				else
					return self:checkNextHandle(camp)
				end
			else
				return self:endRound(camp)
			end
		end

		

		local opInfo = hero:chooseOneAutoHandle(self.roundModel)
		local bLabel = BattleControler:getBattleLabel()
		-- 多人战斗需要每个技能都当操作发送
		if  bLabel == GameVars.battleLabels.crossPeakPvp or
		 	BattleControler:checkIsMultyBattle() 
		 	 then
				if self.controler.__gameStep == Fight.gameStep.result then
					echo("已经出战斗结果了====")
					return
				end
				if Fight.isDummy and BattleControler:checkIsMultyBattle() then
					-- 这里其实是没读到下一条操作(战斗可能结束、也可能是结果不一致导致了卡死)
					BattleControler:setMultyBattleNotFinish()
					echoTag('tag_battle_not_finish',4,"没有读取到下一条操作--上传报错平台")
					return
				end
				if self.controler:isReplayGame() then
					echo ("多人复盘不应该走这里")
					return
				end
		    self.controler.server:sendOneClickHandle(opInfo)
		else
			return self:insertOneHandle(opInfo)
		end
	end

end

--[[
	传入阵营，返回最高优先级的神器技能
]]
function LogicalControler:getArtifactAi( camp )
	
end

--[[
	传入可以放大招的人的数组，返回优先级最高的人
	campArr 可以放大招的人的shuzu 
	orderT 映射过的出手顺序表 key = hero val = idx

	modify 2017.12.21 扩充逻辑，如果有指定大招顺序则按照指定的出手
	modify 2018.05.29 扩充逻辑，先检查是否有可释放的神器技能（自动战斗下）

	camp 出手阵营
]]
function LogicalControler:getMaxSkillHeroAi( campArr, orderT, camp )
	local rstHero = nil

	-- 自动战斗的情况下最优先考虑神器（直接返回了结构上不太好看）
	if self:checkIsAutoAttack(camp) and self.controler.artifactControler:getCanUseManualSkill(camp, true) then
		return self.controler.artifactControler:getArtifactModel(camp)
	end

	-- 优先玩家设置的，如果玩家没有设置则走默认释放大招的逻辑
	if self.maxSkillAiOrder[camp].order then
		rstHero = self:playerMaxSkillHeroAi(camp)
	else
		rstHero = self:defaultMaxSkillHeroAi(campArr, orderT)
	end

	return rstHero
end
--[[
	默认自动战斗大招Ai
	campArr 可以放大招的人的数组
	orderT 映射过的出手顺序表 key = hero val = idx
]]
function LogicalControler:defaultMaxSkillHeroAi( campArr, orderT )
	-- 职业对应优先级
	local pro = {
		[Fight.profession_boss] = 5,
		[Fight.profession_sup] = 3,
		[Fight.profession_def] = 2,
		[Fight.profession_atk] = 4,
		[Fight.profession_monster] = 1,
	}
	local mt = {
		__index = function(t, key)
			return 0
		end
	}
	setmetatable(pro,mt)
	-- 能放大招优先级更高
	local energy = {
		[true] = 1,
		[false] = 0
	}

	local function sortFunc(a, b)
		-- 大招放的次数少的优先
		if a.maxSkillTimes == b.maxSkillTimes then
			-- 怒气足够的优先
			local pria = energy[a.data:isEnergyEnough()]
			local prib = energy[b.data:isEnergyEnough()]
			if pria == prib then
				local pa = a:getHeroProfession()
				local pb = b:getHeroProfession()
				-- Boss>辅>防>攻>小怪
				if pro[pa] == pro[pb] then
					-- 位置
					return orderT[a] < orderT[b]
				end

				return pro[pa] > pro[pb]
			end

			return pria > prib
		end

		return a.maxSkillTimes < b.maxSkillTimes
	end

	table.sort(campArr, sortFunc)

	local rstHero = campArr[1]

	if rstHero then
		-- 优先级最高的怒气不够，则认为没找到
		if not rstHero.data:isEnergyEnough() then
			rstHero = nil
		else
			rstHero:setAiSkill(Fight.operationType_BigSkill)
		end
	end

	return rstHero
end

--[[
	玩家设置顺序
	camp 出手阵营
]]
function LogicalControler:playerMaxSkillHeroAi(camp)
	local rstHero = nil
	local orderT = self.maxSkillAiOrder[camp].order
	local count = self.maxSkillAiOrder[camp].count
	local campArr = self.controler:getCampArr(camp)

	if empty(orderT) or empty(campArr) then return rstHero end
	-- 根据顺序找人，如果没找到则跳过找下一个，如果找到了但怒气不够则等待此人放，最多找 #orderT 次，找一圈都没找到
	for i=1,#orderT do
		local isBreak = false
		local partnerId = orderT[count]
		local character = (partnerId == "1")
		for _,hero in ipairs(campArr) do
			-- 找到了
			if character and hero.data.isCharacter or partnerId == hero.data.hid then
				-- 不考虑怒气因素可放大招就不继续找其他人
				if hero.data:checkCanGiveSkill(false,true) then
					isBreak = true
				end

				-- 此次是否能选到此人
				if not hero.hasOperate and hero.data:checkCanGiveSkill() then
					rstHero = hero
				end
			end
		end

		if rstHero then
			-- 设定为放大招
			rstHero:setAiSkill(Fight.operationType_BigSkill)
			-- 找到了确定的人切到下一个人
			count = count + 1
			if count > #orderT then count = 1 end
			self.maxSkillAiOrder[camp].count = count
		end

		if isBreak then
			-- 找到了确定的人，但是怒气不足不切到下一个人
			break 
		else
			-- 没找到人切到下一个人
			count = count + 1
			if count > #orderT then count = 1 end
			self.maxSkillAiOrder[camp].count = count
		end
	end

	return rstHero
end

--找到下一个可攻击英雄 返回nil 表示是最后一个人了
function LogicalControler:findNextHero(camp )
	-- 模式不同取到的人也不同
	local campArr = self.controler:getCampArr(camp)

	local targetHero
	if self.roundModel == Fight.roundModel_normal then
		local aiOrder
		if camp == 1 then
			aiOrder = globalAiOrder 
		else
			aiOrder = self.controler.levelInfo:getAiOrder(self.controler.__currentWave)
		end
		
		local minOrder = 100
		--遍历数组 如果
		for i,v in ipairs(campArr) do
			--必须是这个人能够攻击
			if (not v.hasOperate) and  v.data:checkCanAttack() then
				local order = table.indexof(aiOrder, v.data.posIndex)
				--比先手顺序 越小越先出手
				if minOrder > order then
					minOrder = order
					targetHero = v
				end
			end
		end
	elseif self.roundModel == Fight.roundModel_semiautomated then
		local aiOrder
		if camp == 1 then
			aiOrder = globalAiOrder 
		else
			aiOrder =  globalAiOrder
			-- self.controler.levelInfo:getAiOrder(self.controler.__currentWave)
		end

		local tempArr = {}
		local orderT = {}
		local minOrder = 100
		local atkHero = nil
		for i,hero in ipairs(campArr) do
			local order = table.indexof(aiOrder, hero.data.posIndex)
			orderT[hero] = order
			if not hero.hasAutoMove and hero.data:checkCanAttack() then
				if minOrder > order then
					minOrder = order
					atkHero = hero
				end
			end

			if self:checkIsAutoAttack(hero.camp, hero.data.characterRid) 
				and not hero.hasOperate 
				-- 不考虑怒气因素
				and hero.data:checkCanGiveSkill(false,true)
			then
				table.insert(tempArr, hero)
			end
		end
		if atkHero then
			atkHero:setAiSkill(Fight.operationType_giveSkill)
		end

		targetHero = self:getMaxSkillHeroAi(tempArr, orderT, camp) or atkHero
	elseif self.roundModel == Fight.roundModel_switch then
		local aiOrder
		if camp == 1 then
			aiOrder = globalAiOrder 
		else
			aiOrder =  globalAiOrder
			-- self.controler.levelInfo:getAiOrder(self.controler.__currentWave)
		end

		local tempArr = {}
		local orderT = {}
		local minOrder = 100
		local atkHero = nil
		for i,hero in ipairs(campArr) do
			-- 按照有大招的出手顺序找，优先把大招甩完
			if hero.data.posIndex == aiOrder[self.atkPos] then
				atkHero = hero
			end
			
			local order = table.indexof(aiOrder, hero.data.posIndex)
			orderT[hero] = order

			if self:checkIsAutoAttack(hero.camp, hero.data.characterRid) 
				and not hero.hasOperate
				-- 不考虑怒气因素
				and hero.data:checkCanGiveSkill(false,true)
			then
				table.insert(tempArr, hero)
			end
		end
		
		if atkHero then
			atkHero:setAiSkill(Fight.operationType_giveSkill)
		end

		local maxSkillHero = self:getMaxSkillHeroAi(tempArr, orderT, camp)
		targetHero = maxSkillHero or atkHero
	end

	return targetHero
end


--根据posIndex 找到指定的heroModel
function LogicalControler:findHeroModel( camp,posIndex ,containerDied )
	local campArr = self.controler:getCampArr(camp)
	local hero =  AttackChooseType:findHeroByPosIndex( posIndex,campArr )
	if not hero then
		if containerDied then
			local diedArr = self.controler:getDiedCampArr(camp)
			hero =  AttackChooseType:findHeroByPosIndex( posIndex,diedArr )
		end
	end

	

	return hero
end

--[[
排除某个model
]]
function  LogicalControler:findHeroModelExc( camp,posIndex,excModel )
	local hero = self:findHeroModel(camp, posIndex, containerDied)
	if hero and hero == excModel then
		return nil
	end
	return hero
end

--获取站位中线
function LogicalControler:getAttackMiddlePos(camp  )
	local middlePos = self.controler.middlePos
	--需要计算敌方最前面一个人的位置
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2
	if #campArr == 0 then
		return middlePos
	end
	local hero = campArr[1]
	local way = camp == 1 and 1 or -1
	--计算缩减量 
	local reduce = 0 --  - 50* way --* (math.ceil( hero.data.posIndex/2 ) -1 )  
	-- echo(reduce,middlePos,"________________aaaaaaa获取攻击中线",way,camp)
	return middlePos + reduce
end

--判断是否有将要复活的人
function LogicalControler:checkCampHasRelive( camp )
	local diedArr = camp ==1 and self.controler.diedArr_1 or self.controler.diedArr_2
	return #diedArr > 0
end


--给某个阵营排序
function LogicalControler:sortCampPos( camp )
	-- local st =  GameStatistics:costTimeBegin( "LogicalControler:sortCampPos" )
	local campArr = camp == 1 and self.controler.campArr_1 or self.controler.campArr_2

	local aiOrder 
	-- if camp == 1 then
	-- 	aiOrder = {1,2,3,4,5,6}
	-- else
	-- 	aiOrder = self.controler.levelInfo:getAiOrder(self.controler.__currentWave)
	-- end
	aiOrder = {1,2,3,4,5,6}

	local sortFunc = function (h1,h2  )

		local index1 = table.indexof(aiOrder, h1.data.posIndex) 
		if not index1 then
			dump(aiOrder,"___airoder_错误,pos:" ..h1.data.posIndex)
			index1 = 1
		end
		local index2 = table.indexof(aiOrder, h2.data.posIndex)
		if not index2 then
			dump(aiOrder,"___airoder_错误,pos:" ..h2.data.posIndex)
			index2 = 1
		end
		return index1 < index2
	end

	

	table.sort(campArr,sortFunc)
	-- for k,v in ipairs(campArr) do
	-- 	echo(v.data.posIndex,v.data.hid)
	-- end
	-- GameStatistics:costTimeEnd( "LogicalControler:sortCampPos" ,st)
end


--执行某个时机行为
---- 时机触发事件  {camp(阵营) ,chance(时机类型),attacker(触发目标),defender(防守放)  }
function LogicalControler:doChanceFunc( chanceEvent )
	-- local st = GameStatistics:costTimeBegin("LogicalControler:doChanceFunc")
	local arr
	if chanceEvent.camp == 1 then
		arr = {
			self.controler.campArr_1,
			self.controler.diedArr_1,
		}
	elseif chanceEvent.camp == 2  then
		arr = {
			self.controler.campArr_2,
			self.controler.diedArr_2,
		}
	else
		arr = {
			self.controler.campArr_1,
			self.controler.diedArr_1,
			self.controler.campArr_2,
			self.controler.diedArr_2,
		}
	end
	-- 遍历过程中是有可能发生删除的，并且删除不一定是从最后一个开始，所以需要先读出来再做遍历
	local tempArr = {}
	for i,v in ipairs(arr) do
		for _,hero in ipairs(v) do
			table.insert(tempArr, hero)
		end
		
		local length = #tempArr
		for ii=length,1 ,-1 do
			local hero = tempArr[ii]
			-- 不能判断死亡，因为有死亡事件需要触发
			if hero then
				hero.data:checkChanceTrigger(chanceEvent)
			end

			tempArr[ii] = nil
		end
	end
	-- GameStatistics:costTimeEnd("LogicalControler:doChanceFunc",st)
end

-- 当有人死亡时logical需要做的事情
function LogicalControler:onOneHeroDied(who, attacker)
	local camp = who.camp

	-- 如果人死了从设定出手的逻辑里删除
	if not empty(self.maxSkillAiOrder[camp].order) then
		local character = who.data.isCharacter
		local dieId = who.data.hid

		local orderT = self.maxSkillAiOrder[camp].order
		local count = self.maxSkillAiOrder[camp].count
		local tempT = nil
		for i,partnerId in ipairs(orderT) do
			-- 同一个人
			if character and (partnerId == "1") or partnerId == dieId then
				-- 保证指向的人不变
				if i < count then count = count - 1 end
			else
				if not tempT then tempT = {} end
				-- 不是同一个人
				table.insert(tempT,partnerId)
			end
		end

		self.maxSkillAiOrder[camp].order = tempT
		self.maxSkillAiOrder[camp].count = count
	end
	if not Fight.isDummy then
		local sourceId = who.data:getCurrTreasureSourceId()
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TALKBUBBLE,
			{tType = Fight.talkTip_onDied,deadId = sourceId})
	end
end


--被动技能管理区域---------------------------------
--被动技能管理区域---------------------------------
--被动技能管理区域---------------------------------
function LogicalControler:insertPassiveSkill( passiveSkill )
	table.insert(self.passiveGroup, passiveSkill)
end

--清空被动技能作用
function LogicalControler:clearPassiveSkill(  )
	table.clear(self.passiveGroup)
end

--轮空机制：
--在首回合内，小怪全清并且进攻方有未出手的角色，则未出手的角色在过图的时候获得1000点额外怒气的奖励
function LogicalControler:beforNextWave(  )
	--如果回合数大于1 就不执行
	if self.roundCount ~= 2 then
		return
	end

	--暂时屏蔽掉轮空奖励
	if true then
		return
	end

	--拿到所有人的操作信息
	local campArr = self.controler.campArr_1
	for i,v in ipairs(campArr) do
		-- if not v.hasAttacked then
		if not v:hasAttacked() then
			--必须是能攻击的 
			if v.data:checkCanAttack() then
				--让他能量满
				-- echo("__让我满能量,",v.data.posIndex)
				-- v.data:changeValue(Fight.value_energy , v.data:maxenergy() )
				--轮空奖励
				v:insterEffWord( {2,Fight.wenzi_lunkong,Fight.buffKind_hao}	)
			end
			
		end
	end

end

--获取某一方的回合数 需要根据先手后手 判定
function LogicalControler:getCampRoundCount( camp )
	return math.ceil(self.roundCount/2)
end

--[[
	设置大招出手顺序
	camp 阵营
	orderT 顺序表
	resetCount true 重置计数
]]
function LogicalControler:setMaxSkillAiOrder(camp, orderT, resetCount)
	if not camp or not orderT then return end
	local campArr 
	if camp == 1 then
		campArr = self.controler.campArr_1
	else
		campArr = self.controler.campArr_2
	end
	-- 将k-v数组转换成i v数组；此k v数组可以保证连续；同时过滤掉阵容里不存在的人
	local t = nil
	local nums = table.nums(orderT)
	for i=1,nums do
		local partnerId = orderT[tostring(i)]
		if AttackChooseType:findHeroByHid(partnerId, campArr) then
			if not t then t = {} end
			table.insert(t, partnerId)
		end
	end

	self.maxSkillAiOrder[camp].order = t
	if resetCount then
		self.maxSkillAiOrder[camp].count = 1
	end
end


--判断一个操作能否能执行
function LogicalControler:checkOneAttackCanRun( info )
	--如果不是在回合中的

	local camp, posIndex,operationType,params,timely = info.camp, info.index, info.type, info.params, info.timely
	if not self.isInRound then
		echo("这个操作是在回合结束的时候发的,不需要执行",camp, posIndex,operationType,params,timely)
		return false
	end

	-- 这个类型是神器技能校验方式不同
	if operationType == Fight.operationType_artifactSKill then
		return self.controler.artifactControler:artifactSkillCanUse(camp,info.skillId)
	end

	local hero = self:findHeroModel(camp, posIndex)
	if not hero then
		return false
	end
	--如果已经小技能攻击过了
	if params == Fight.skillIndex_small  then
		if hero.hasAutoMove then
			return false
		end
	else
		--如果已经攻击过了 return
		if hero.hasOperate then
			return  false
		end
		-- 如果能放大招 （为了过滤错误先注掉）
		-- if not hero.data:checkCanGiveSkill() then
		-- 	return false
		-- end
	end

	return true
end
