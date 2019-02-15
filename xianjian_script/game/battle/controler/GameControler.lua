
--
-- Author: xiangdu
-- Date: 2014-01-01 16:01:28gameMode
--
--游戏世界的坐标系 采用  flash 坐标系  最终转化成cocos 坐标系,容器的初始化顶点在左上角
local Fight = Fight
-- local BattleControler = BattleControler
local table = table
GameControler = class("GameControler")
--GameControler.allDropBox = nil 		--所有掉落宝箱数组
GameControler.allModelArr = nil 	--所有对象数组
GameControler.depthModelArr = nil 	--只需要进行深度排列的数组
GameControler.campArr_1 = nil 		--1我放成员数组
GameControler.campArr_2 = nil 		--2敌方成员数组
GameControler._pvpDummy = true 		-- pvp战斗不需要备份

GameControler.character = nil
GameControler.diedArr_1 = nil 		--死亡即将被复活的数组
GameControler.diedArr_2 = nil 		--死亡即将被复活的数组2
GameControler.screen = nil
GameControler.replayGame = 0       -- 游戏 replayGame 0 正常战斗 1 回放当前战斗 2 回放已经打完的战斗	

GameControler.scenePause = false	   --普通场景暂停 考虑到追打造技能状态  那么 这个时候 是暂停普通场景的
GameControler.scenePauseLeft = - 1 		--剩余场景暂停时间						
GameControler.skillPauseInfo = nil  --技能播放暂停信息
GameControler.callFuncArr = nil 		--回调队列 因为初始化的人物一定要分帧创建 否则会非常卡
GameControler.callFuncArrCache = nil 	-- 回调队列缓存
GameControler.callFuncUpdating = nil 	-- 标记是否进行队列遍历
GameControler.callFuncClearFlag = nil 	-- 标记是否进行了删除
GameControler._gamePause = false 	-- 是否游戏暂停  考虑到 游戏模拟场景  

GameControler.gameSpeed = 1   		-- 当前游戏播放速度  
GameControler.updateCount = 0   	-- 刷新间隔
GameControler.updateScale = 10 		-- 游戏速度放缩
GameControler.updateDt = 0
GameControler.delayDt = 0
GameControler.lastScale = 1  		-- 上次播放的游戏速度 做一个保存  这个是全局的
GameControler.updateScaleCount = 0 	-- scale计数
GameControler.middlePos = 0

GameControler.addOtherSpeed =0 			--额外添加的速度
GameControler.originSpeed = 1

GameControler._gameResult = 0 		--游戏结果   0 还未分胜负 1 胜利  2 失败 3 平局 4 主动退出
GameControler.__gameStep = Fight.gameStep.wait 	--英雄当前运动阶段  1表示 等待  2表示前进中 3表示开始遇敌 4进入战斗中
GameControler.gameMode = 1 			--游戏模式  1是普通 2是竞技场
GameControler.gameLeftTime = -1 	--游戏剩余时间
GameControler.__currentWave = 0 		--第几批怪物

GameControler._conditions = 1 			-- 战斗进入1 正常，2重连，3中途加入
GameControler._mirrorPos = 1 			-- 控制视图左右互换 1 正常 -1互换
GameControler._battleStar = nil			-- 战斗星级 0特等,往后加
GameControler._loadingComplete = false -- 自己加载完成 
GameControler._countId = 0
GameControler._sceenRoot = nil
--@测试变量
GameControler.runGameIndex = 0 			--当前跑的游戏次数 备份多少次就需要跑多少变
GameControler.useOperateInfo = nil		-- 文件中存储的操作信息
GameControler.cacheValueMap = nil 		--缓存的一些变量 就是判断一些属性是否存在
GameControler.isDebugHero = false 		--是否是debugHero阶段



-- 断线重连数据 
-- 该方法在runGameToTargetRound 中赋值，然后当运行至对一个的wave round attackNums后isQuick 会被设置为false
-- isQuick 是否是快跑逻辑 ,默认为false、oldUpdateScale 旧的 updateScale
-- {isQuick = false,oldUpdateScale = nil, wave = 0,round = 0,attackNums = 0}
GameControler.reloadData = {}
-- 战前检查
GameControler.isRunInitFirst = false --是否已经执行过initFirst方法
GameControler.isReceiveStart = false --是否收到战斗开始消息
GameControler.resIsCompleteLoad = false --资源是否加载完成

-- 是否是暂停界面退出
GameControler._isPauseOut = false 
-- 截止当前波数开始时的总回合数(怒气每回合增长需要记录到)
GameControler._lastWaveRoundCount = 0
-- 存一个当前战斗引导步骤
GameControler.__nowTutorialStep = nil
-- 暂停倒计时
GameControler.__countDownPause = false

-- 剩余加速帧数
GameControler._lastSpeedUpFrame = 0

-- 终止战斗复盘（只用作发生错误时终止复盘 使用setCancelCheck方法）
GameControler._isCancelCheck = false

-- 缓存当前玩家的自动战斗操作，在不影响逻辑的时候发出
--[[
	_waitAuto = {
		old = false
		new = false
		waiting = false
	}
]]
GameControler._waitAuto = nil 

function GameControler:ctor( root )
	--self.allDropBox = {}
	self.allModelArr = {}
	self.depthModelArr = {}
	self.campArr_1 = {}
	self.campArr_2 = {}
	self.diedArr_1 = {}
	self.diedArr_2 = {}
	self.callFuncArr = {}
	self.callFuncArrCache = {}
	self.callFuncUpdating = false
	self.callFuncClearFlag = false
	self.skillPauseInfo = {left=0}
	self._sceenRoot = root
	--初始化battleser
	self.server = BattleServer.new(self)
	self.cacheValueMap = {}
	if Fight.debug_battleSpeed then
		self.updateScale = Fight.debug_battleSpeed
		self.originSpeed = Fight.debug_battleSpeed
	end
	self.reloadData = {isQuick = false,oldUpdateScale=self.originSpeed, wave = 0,round = 0,attackNums = 0}
	self.isRunInitFirst = false
	self.isReceiveStart = false
	self.resIsCompleteLoad = false
	self._isPauseOut = false
	self._lastWaveRoundCount = 0
	echo("_____创建游戏--------")
	self.addOtherSpeed =0 			--额外添加的速度
	self.originSpeed = 1
	self._lastSpeedUpFrame = 0
	self._isCancelCheck = false
	self._isEndBattle = false
	-- 存一下，不然可能错误的打开
	self.__IS_IGNORE_LOG = IS_IGNORE_LOG

	self._waitAuto = {
		old = false,
		new = false,
		waiting = false,
	}
	-- 初始化逻辑控制器
	self:initLogical()
end
-- 初始化逻辑控制器
function GameControler:initLogical()
	--逻辑控制器
	self.logical = LogicalControlerEx.new(self)
end

function GameControler:initCountId( count )
    count = count and count or 0
    self._countId = count
end

-------------------------------------------------------------------------
----------------------- load 加载阶段,材质加载 -------------------------------
-------------------------------------------------------------------------

--判断加载材质
function GameControler:checkLoadTexture( )
	if not Fight.isDummy  then
		self._initTime = TimeControler:getTempTime(  )
		local layer= LayerManager.new(self)
		self.layer = layer
		self._sceenRoot:addChild(layer.a)

		-- 缓存材质
		if BattleControler:getIsRestart() and not Fight.use_operate_info then
			self.resControler = BattleControler:getResControler()
			self.resControler:resetControler(self)
			self:onResloadComp()
		else
			self.resControler = GameResControler.new(self)
			self.resControler:cacheResource(self.levelInfo.cacheObjectHeroArr,self.levelInfo.cacheArtifact,c_func(self.onResloadComp,self))
		end
	else
		self:initFirst()
	end
end


function GameControler:onResloadComp(  )
	echo(TimeControler:getTempTime() - self._initTime,"初始化战斗耗时")
	
	WindowControler:globalDelayCall(c_func(self.delayInitGame,self), 5/GameVars.GAMEFRAMERATE )
end

function GameControler:delayInitGame(  )
	--如果是纯跑逻辑 或者是回放的  那么需要等待服务器回调
	EventControler:dispatchEvent(LoadEvent.LOADEVENT_BATTLELOADCOMP, {result = 1})
	if Fight.isDummy or self:isReplayGame()   then
		self:initFirst()
	else
		-- echoError("测试 注释掉了巅峰竞技场的数据")
		-- if self.gameMode == Fight.gameMode_gve  
		--   then
		-- if self.gameMode == Fight.gameMode_gve  or
		-- 	BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp or
		-- 	BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp2
		-- 	  then
		-- 	echo("__发送资源加载完毕事件")
		-- 	--发送资源加载完毕事件
		-- 	self.server:loadBattleResOver()
		-- else
		if BattleControler.isPreloading then
		else
			self:initFirst()
		end

		-- end
	end
end
-- 登录初始化的时候处理
function GameControler:realInitFirst()
	self:initFirst()
end



function GameControler:initGameData( objectLevel )
	self.levelInfo = objectLevel

	self._battleStar = 0

	-- 控制视图互换位置
	self._mirrorPos = 1

	-- GVE的时候，如果敌方是机器人或者离线的玩家、则默认将他们设定为自动战斗
	if self.gameMode == Fight.gameMode_gve then
		local bInfo = self.levelInfo:getBattleInfo()
		for i,v in pairs(bInfo.battleUsers) do
			if v.userBattleType == Fight.battle_type_robot or v.userBattleType == 6 then
				local vv = self.logical.userStateMap[v.rid]
				if vv then
					vv.auto = true
					vv.roundAuto = true
					vv.buzhenState = true
				end
			end
		end
	end

end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-----------------------  等待状态,创建人物--------------------------------
-------------------------------------------------------------------------

function GameControler:beforeCreateStep()
	-- 等loading或播动画过程中不进入，等待调用
	if BattleControler:isWaitLoadingAni() or self.isPlayAnimDialog then return end

	-- 序章第一关也不显示开战
	if not Fight.isDummy and not self:chkIsXvZhang() and
		 not BattleControler:checkIsCrossPeak() then
	    self.gameUi:playKaiZhanTeXiao(function( )
	    	self:enterCreateStep()
	    end)
	else
		self:enterCreateStep()
	end
end
-- 创建人物
function GameControler:enterCreateStep()
	--设置当前的RaidId的剧情已经播放完成
	BattleControler:saveCurRaidJuQingFinished()
	echo("________第一步______________进入创建人物步骤",self.updateCount)
	--设置状态
	self:setGameStep(Fight.gameStep.wait)
	self.__currentWave = self.__currentWave + 1

	--播放战斗音乐
	if not Fight.isDummy then
		if self.levelInfo.bgMusic[self.__currentWave] then
			AudioModel:playMusic(self.levelInfo.bgMusic[self.__currentWave], true)
		else
			AudioModel:playMusic(MusicConfig.m_scene_battle, true)
		end
	end
	self.middlePos = self.levelInfo.__midPos[self.__currentWave]
	
	--显示名字
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOWNAME,true)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_NEXTWAVE)
	self.logical:initWaveData()
	self.logical:initRoundModel(self.gameMode)
	-- 设置阵法信息
	local eleInfo = self.levelInfo.elementFormation
	-- dump(eleInfo,"法阵信息")
	self.formationControler:setElementsInfo(eleInfo.camp1, 1)
	self.formationControler:setElementsInfo(eleInfo.camp2[self.__currentWave], 2)
	self.formationControler:initLattice()

	-- 设置换灵信息、神器信息
	for camp=1,2 do
		local aInfo = self.levelInfo:getArtfactInfo(camp)
		if aInfo and aInfo.huanling then
			self.formationControler:setUserhuanlingInfo(aInfo.huanling,camp)
		end

		if aInfo and aInfo.skills then
			self.artifactControler:setArtifactSkills(camp, aInfo.skills)
		end
	end

	local spiritInfo = self.levelInfo:getSpiritPowerInfo()
	-- 设置神力信息
	self.artifactControler:setSpiritSkills(spiritInfo)

	self:sureHeroPosArea()

	-- 仙界对决开始没有人、
	if BattleControler:checkIsCrossPeak() then
		if not BattleControler:checkIsCrossPeakModeBP() then
			-- 初始化场上的玩家数据
			local nData = self.levelInfo:getCrossPeakNormalModeData()
			for k,v in pairs(nData) do
				self.reFreshControler:distributionOneCamp(v,k,1,Fight.enterType_stand )
			end
		end
		-- 初始化神器
		self.artifactControler:createOneArtifact(Fight.camp_1)
		self.artifactControler:createOneArtifact(Fight.camp_2)
		self:onDistributionComplete(1)
		self:onDistributionComplete(2)
		self:initEnergyInfo()
		self.cpControler:checkCrossPeakBattle2Start()
		return
	end
	-- 处理一些初始化以及入场
	self:beforeCreateModel()

	self.reFreshControler:distributionOneCamp(self.levelInfo.campData1,Fight.camp_1,1,Fight.enterType_inAction)
	self.reFreshControler:distributionOneCamp(self.levelInfo.waveDatas[1],Fight.camp_2,1,self.levelInfo.enterType[1])


	self:afterCreateModel()

	--初始化双方的天赋 以及光环之类的
	self:onDistributionComplete(1)
	self:onDistributionComplete(2)
	-- 初始化神器
	self.artifactControler:createOneArtifact(Fight.camp_1)
	self.artifactControler:createOneArtifact(Fight.camp_2)

	self:initEnergyInfo()

	-- 这里赋值出手顺序是因为，上面会初始化人物，在赋值出手顺序的方法里会排重；有个坑，如果人物是分帧加载的会有问题
	self.logical:setMaxSkillAiOrder(Fight.camp_1,self.levelInfo.maxSkillAiOrder[Fight.camp_1],true)
	self.logical:setMaxSkillAiOrder(Fight.camp_2,self.levelInfo.maxSkillAiOrder[Fight.camp_2],true)

	if Fight.isDummy then
		return self.logical:startRound()
	else
		-- 处理分拨入场（我方一定是分拨入场）
		local maxFrame1 = self:chkBatchInAction(Fight.camp_1, Fight.enterInterval, 0)
		local maxFrame2 = 0
		if self.levelInfo.enterType[1] == Fight.enterType_inAction then
			maxFrame2 = self:chkBatchInAction(Fight.camp_2, Fight.enterInterval, 0)
		end

		local finalFrame = math.max(maxFrame1, maxFrame2)
		-- self:pushOneCallFunc(maxFrame + 8, "setCampMoveFront")
		-- echo("算出来的帧数",row,Fight.enterInterval, finalFrame)
		self:pushOneCallFunc(finalFrame, "setCampMoveFront")
	end
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SHOW_GAMEUI)
	
	if BattleControler:getBattleLabel() == GameVars.battleLabels.guildGve 
		and self:getGVEIs2Quick() then
		-- 在加载的时候收到食材刷新的通知，则在此加速游戏出结果
		self:checkToQuickGame()
	end
end
-- 初始化怒气相关数据
function GameControler:initEnergyInfo( ... )
	if not BattleControler:checkIsTower() then
		-- 初始化怒气(只要配了就覆盖)
		self.energyControler:setEnergyInfo(self.levelInfo.__initEnergy[1][self.__currentWave], 1)
	end
	self.energyControler:setEnergyInfo(self.levelInfo.__initEnergy[2][self.__currentWave], 2)
end
-- 初始化神器对应的怒气养成相关 2017.11.14
-- 2017.12.05 神器怒气值是叠加以前的数据的
function GameControler:initEnergyData(camp)
	local energyInfo = self.levelInfo:getBattleEnergyRule()
	local eInfo = self.energyControler:getEnergyInfo(camp)
	local eArr = self.levelInfo:getArtfactInfo(camp)
	local a,b,c = eInfo.entire,energyInfo.maxEntireEnergy,energyInfo.roundEnergyMax
	b = b > eInfo.maxEntire and b or eInfo.maxEntire --取最大的值(锁妖塔可能有怒气上限的buff)
	a = a + energyInfo.firstRoundEnergy
	if eArr and eArr.energyInfo and #eArr.energyInfo > 0 then
		a = a + eArr.energyInfo[1]
		b = b + eArr.energyInfo[2]
		c = c + eArr.energyInfo[3]
	end
	local tmp = {entire = a,maxEntire=b,roundEnergyMax=c}
	self.energyControler:setEnergyInfo(tmp,camp)
end

--阵营初始化完毕后 开始做天赋技能,包括被动buff之类的
function GameControler:onDistributionComplete(camp )
	local campArr = camp == 1 and self.campArr_1 or self.campArr_2

	self:initEnergyData(camp)

	for i,v in ipairs(campArr) do
		--初始化光环
		v.data:initAure()
		-- 做协助技 2017.7.14
		v:doHelpSkill()
	end
end


--进入下一波
function GameControler:enterNextWave(  )
	self.__currentWave = self.__currentWave + 1
	if not Fight.isDummy then
		if self.levelInfo.bgMusic[self.__currentWave] then
			AudioModel:playMusic(self.levelInfo.bgMusic[self.__currentWave], true)
		end
	end
	self.middlePos = self.levelInfo.__midPos[self.__currentWave]
	self._lastWaveRoundCount = self._lastWaveRoundCount + self.logical.roundCount
	self.logical:initWaveData()
	self:sureHeroPosArea()
	-- 改成 stand 不然好像默认是 summon
	self.reFreshControler:distributionOneCamp(self.levelInfo.waveDatas[self.__currentWave],Fight.camp_2,2,self.levelInfo.enterType[self.__currentWave])
	--初始化阵营的天赋技
	self:onDistributionComplete(2)
	self:onNextWaveAfterCreateModel()
	self.viewPerform:resumeViewAlpha()
	-- 黑屏去除
	self:hideBlackScene()


	-- 初始化怒气(只要配了就覆盖,初始怒气会覆盖神器的养成initEnergyData())
	self.energyControler:setEnergyInfo(self.levelInfo.__initEnergy[1][self.__currentWave], 1)
	-- if not BattleControler:checkIsTower() then
	-- 	-- 初始化怒气(只要配了就覆盖,初始怒气会覆盖神器的养成initEnergyData())
	-- 	self.energyControler:setEnergyInfo(self.levelInfo.__initEnergy[1][self.__currentWave], 1)
	-- end
	self.energyControler:setEnergyInfo(self.levelInfo.__initEnergy[2][self.__currentWave], 2)
	
	-- 设置阵法信息
	local eleInfo = self.levelInfo.elementFormation
	self.formationControler:setElementsInfo(eleInfo.camp1, 1)
	self.formationControler:setElementsInfo(eleInfo.camp2[self.__currentWave], 2)
	self.formationControler:updateFormationPos()
	self.formationControler:waveUpdateLattice()
	
	--发送一个 进入下一波的通知
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_NEXTWAVE)
	--如果是 普通pve、或者多人试炼（目前是山神试炼有两波）
	if self.gameMode == Fight.gameMode_pve or self.gameMode == Fight.gameMode_gve  then
		--让我方所有人向右运动
		self:setCampMoveFront()
		-- 清除我方所有人可能存在的操作数
		self:hideCampAttackNum()
	end

end

-- 清除我方所有人可能存在的操作数
function GameControler:hideCampAttackNum()
	for i,v in ipairs(self.campArr_1) do
		v:hideAttackNum()
	end
end

--让我方所有人向右运动

function GameControler:setCampMoveFront(  )
	if Fight.isDummy or self:isQuickRunGame() then
		-- self:logicalStartRound()
		self:chkAfterStand()
	else

		--计算距离 速度 算出进入下一波的时间
		--玩家开始移动，进入
		for i,v in ipairs(self.campArr_1) do
			local newx,newy = self.reFreshControler:turnPosition(1,v.data.posIndex,v.data:figure(),self.middlePos)
			-- v._initPos = {x= newx,y = newy, z = 0}
			v:setInitPos({x= newx,y = newy, z = 0})
			local posParams = {x= newx,y = newy,speed = Fight.enterSpeed,call = {"initPosComplete" }}
			v:setWay(1)
			v:justFrame(Fight.actions.action_run )
			v:moveToPoint(posParams)

			if not empty(v._pet) then
				for _,pet in ipairs(v._pet) do
					-- 如果现在还没有真正成为宠物就强行执行一下方法
					if pet.__willBPet then
						pet:beComePet()
						pet.beComePet = nil
					end
					pet:setWay(1)
					pet:justFrame(Fight.actions.action_run )
					pet:moveToPoint({
						x = pet._initPos.x,
						y = pet._initPos.y,
						speed = Fight.enterSpeed,
					})
				end
			end
		end

		local currentFocusPos = self.screen.focusPos.x
		local dx = self.middlePos - currentFocusPos
		local rmax = 0.07 		--缓动系数 越大 表示运动越快
		local rmin = 0.04
		local f = (rmin-rmax) / (1200-960) * (dx - 960) + rmax
		f = f > rmax and rmax  or f
		f = f < rmin and rmin or f
		self.screen:setFollowType(2,{x=self.middlePos,y = GameVars.halfResHeight,speed = 15,f = f,minSpeed = 15})

		local delayFrame = math.floor(dx / Fight.enterSpeed )
		delayFrame = delayFrame <= 1 and 1 or delayFrame

		-- 如果第二波的入场为动作入场
		if self.__currentWave > 1 and self.levelInfo.enterType[self.__currentWave] == Fight.enterType_inAction then
			delayFrame = delayFrame +5
			local waitTime = math.floor(delayFrame / 3)
			-- 做分帧入场并且取时间
			local maxFrame = self:chkBatchInAction(Fight.camp_2,10,waitTime)
			delayFrame = math.max(delayFrame, maxFrame)
		end

		self:pushOneCallFunc(delayFrame, c_func(self.chkAfterStand, self))
	end
end

-- 处理分拨入场并返回需要等待的时间
-- @@enterInterval 分拨间隔
-- @@waitTime 初始额外等待时间
function GameControler:chkBatchInAction(camp, enterInterval, waitTime)
	local waitTime = waitTime or 0
	local enterInterval = enterInterval or Fight.enterInterval
	local campArr = self["campArr_" .. camp]

	local flag = nil
	local maxFrame = 0 -- 简单取一个最长入场时间
	local count = -1

	for _,hero in ipairs(campArr) do
		-- 间隔入场 Fight.enterInterval
		local order = math.floor((hero.data.posIndex - 1) / 2)
		if order ~= flag then
			flag = order
			count = count + 1
		end

		hero:setOpacity(0)
		-- 一半时间
		local delay = waitTime + count * enterInterval

		maxFrame = math.max(delay + hero:getTotalFrames(Fight.actions.action_inAction), maxFrame)

		hero:pushOneCallFunc(delay, "setOpacity", {255})
		hero:pushOneCallFunc(delay, "justFrame", {Fight.actions.action_inAction})

		if not Fight.isDummy then
			-- 入场结束后播放气泡用
			hero:pushOneCallFunc(maxFrame, "checkTallBubbleOnComplete")
		end
	end

	return maxFrame
end

--人物站好之后检查是否有动画
function GameControler:chkAfterStand(  )
	-- 这里要需要强插一个助战的逻辑，醉了
	if self:chkIsLevel_spzhaolinger()
		and self.logical.roundCount == Fight.xvzhangParams.zhaolingerIn_round
		and self.__currentWave == Fight.xvzhangParams.zhaolingerIn_wave 
	then
		-- 走到这里则一定有空位，找空位
		local changePos = nil
		for pos = 6,1,-1 do
			local hero = self.logical:findHeroModel(Fight.camp_1, pos)
			if not hero then
				changePos = pos
				break
			end
		end

		if not changePos then
			echoError("错误情况没有助阵的空位")
			return self:chkNextRound()
		end

		if Fight.isDummy or self:isQuickRunGame() then
			self.reFreshControler:level2_5RefreshZhaolinger(changePos)
			-- 下一个回合
			return self:logicalStartRound()
		else
			local onUserAction = function(ud)
			    if ud.step == -1 and ud.index == -1 then
			        -- --序章刷新龙幽进场
			        -- self.reFreshControler:level3_3RefreshLongyou(changePos)
			        -- self:pushOneCallFunc(30, c_func(self.chkNextRound,self),{})
			        --刷新进场
			        self.reFreshControler:level2_5RefreshZhaolinger(changePos)
			        self:pushOneCallFunc(30, "checkDialogAndAnimation",{2,"logicalStartRound",0,{}})
			    end
			end

			PlotDialogControl:showPlotDialog(Fight.xvzhangParams.zhaolingerPlot, onUserAction)
		end
	else
		if Fight.isDummy or self:isQuickRunGame() then
			self:logicalStartRound()
		else
			self:checkDialogAndAnimation( 2,"logicalStartRound",0,{})
		end
	end
end

--Logical 开始执行startRound
function GameControler:logicalStartRound(  )
	self.logical:startRound()
end

----------------------------------------------------
----------------------- 加载完成,开始主循环 ----------------------------
-------------------------------------------------------------------------
function GameControler:initFirst()
	if self.isRunInitFirst then
		echoWarn("已经执行过 initFirst 方法")
		return
	end
	self.isRunInitFirst = true
	echo("_______________________initFirst",self.__currentWave)
	
	-- 初始化变量
	self.middlePos = self.levelInfo.__midPos[1]

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
	-- 仙界对决战斗控制器
	self.cpControler = CrossPeakControler.new(self)

	if self.levelInfo:chkIsAnswerType() then
		-- 答题玩法无限怒气
		self.energyControler:setInfiniteEnergy(true)
	end
	if not Fight.isDummy then
		self.screen = ScreenControler.new(self,self.layer.a12)	
		-- self.screen:setFocus(GameVars.halfResWidth, self.screen.focusPos.y)
		
		--ui在最上层  a4  a2是
		self.gameUi = WindowControler:showBattleWindow("BattleView")
		self.gameUi:setControler(self)
		-- 创建map的的代码移至GameResControler
		-- self.map = MapControler.new(self.layer.a11,self.layer.a13,self.levelInfo.__mapId, true )

		-- 镜头直接初始化到位，因为pve也不再需要跑动入场le 
		self.screen:setFocus(self.middlePos, self.screen.focusPos.y)

		-- 初始化镜头
		self.camera = CameraControler.new(self)

		-- 初始化阵位特效
		self.formationControler:initView()
		-- 初始化事件
		self:initEvents()
	end
	
	--创建heroes
	self:initCountId(0)
	

	if not Fight.isDummy  then
		-- 是试炼解封的写死战斗，并且不是dummy不是复盘，如果已经通过将标记置为1，防止换设备重新引导试炼
		local levelId = self.levelInfo.hid
		if tostring(levelId) == Fight.xvzhangParams.trial 
			and TrailModel:getIsOpenByLevel(levelId)
		then
			LS:prv():set(StorageCode.tutorial_first_trial,1)
		end

		self:checkDialogAndAnimation(1,"pushOneCallFunc",0,{1,"beforeCreateStep"},1)
	else
		self:beforeCreateStep()
	end
	
	--开始刷新,只是刷新的时候判断是否开战
	self:startBattleLoop()
	-- testGolbalKey()
	-- 开启战斗校验、并且不是战斗服、并且不是战斗复盘的时候
    if IS_CHECK_DUMMY and Fight.isDummy and not DEBUG_SERVICES and not self:isReplayGame() then
        BattleControler:updateBattleCheckStatus(false)
    end
end

--启动战斗刷新
function GameControler:startBattleLoop()
	-- 加载资源完成,发送事件给loading,--去掉这个是因为可能是重播或者回放,就要将关闭loading页面
	echo("加载完毕-------------")
	-- 修正刷新
	local _chkUpdate = function (dt )
		self.updateDt  = self.updateDt  + dt
		--修改刷新方式 改为累进式 执行updateframe. 必须要满 1帧的时间才刷新一次.同时记录剩余刷新量.
		-- 这样就算快或者慢 计算都是准确的 前提是玩家没有开加速器
		if self.updateDt > Fight.dummyUpdata then
			local loop = math.floor(self.updateDt/Fight.dummyUpdata)
			for i=1,loop do
				self:updateFrame(Fight.dummyUpdata) 
			end
			self.updateDt = self.updateDt - Fight.dummyUpdata* loop
			return
		end

	end
	-- 刷新函数
	local listener = function( dt )
		if Fight.low_fps then
			self:updateFrame(dt)
			return
		end
		local count = Fight.check_battleSpeed
		dt = dt/count
		for i=1,count do
			_chkUpdate(dt)
		end
	end

	if DEBUG_SERVICES  then
		local time = os.clock()
		local index = 0
	else
		
		if not Fight.isDummy then
			WindowControler:getScene():showBattleRoot()
			self.schedulerId = self._sceenRoot:scheduleUpdateWithPriorityLua(listener, 0)
		end 
	end
end



function GameControler:updateFrame( dt )
	
	if GameLuaLoader:isGameDestory() then
		return
	end

	--如果已经游戏结束了 不执行
	if self._isDied then
		if self.oldUpdateScale then
			self.updateScale = self.oldUpdateScale
			self.oldUpdateScale = nil
			echo("游戏快速出结果----")
		end
		return
	end
	local lastCount
	local updateScale =  self.updateScale
	-- 正常速度
	if updateScale == 1 then
		self:runBySpeedUpdate(dt)
	--如果是降速的
	elseif updateScale < 1 then
		--判断多少帧刷新一次函数
		lastCount = math.round(self.updateScaleCount)
		self.updateScaleCount = self.updateScaleCount + updateScale
		if math.round(self.updateScaleCount) > lastCount then
			--如果是达到一次计数了 那么就做一次刷新函数
			self:runBySpeedUpdate(dt)
		end
	else
		--先计算需要刷新多少次
		local count = math.floor(updateScale)
		local t1 =os.clock()
		for i=1,count do
			self:runBySpeedUpdate(dt)
			-- 游戏结束了那就返回吧
			if self:chkIsResultComeOut() then
				break
			end
			
		end
		-- if updateScale > 5 and self._gameResult == Fight.result_none then
		-- 	print(os.clock()-t1,"___runtime",self.updateCount)
		-- end
		
		local leftCount = updateScale - count
		self.updateScaleCount = self.updateScaleCount+ count
		--如果不是整数倍数加速
		if leftCount > 0 then
			lastCount = math.round(self.updateScaleCount)
			self.updateScaleCount = self.updateScaleCount + leftCount

			--如果四舍五入后达到一次计数了 那么就做一次刷新函数
			if math.round(self.updateScaleCount) > lastCount then
				self:runBySpeedUpdate(dt)
			end
		end
		self:checkIsToReload()
		
	end

	-- 剩余加速帧数（加速）
	for i=self._lastSpeedUpFrame,1,-1 do
		self:runBySpeedUpdate(dt)

		self._lastSpeedUpFrame = self._lastSpeedUpFrame - 1
	end
end

-- 设置剩余加速帧数
function GameControler:setLastSpeedUpFrame(value)
	self._lastSpeedUpFrame = self._lastSpeedUpFrame + value
end

--[[
设置逐帧播放
]]
function GameControler:testFramePlay(val)
	self._isFramePlay = val
end

--总刷新函数
function GameControler:runBySpeedUpdate( dt )
	if self._isFramePlay == 1 then
		return
	end

	if self._gamePause then
		return
	end
	
	if self._isDied then
		return
	end

	-- 要求刚开始就要刷怪
	self.updateCount = self.updateCount + 1
	
	self:someUpdateInfo()
	if (not Fight.isDummy) and (not self:isQuickRunGame()) then
		if self.camera then
			self.camera:updateFrame()
		end
		if self.screen then
			self.screen:updateFrame(dt)
		end
		if self.gameUi  then
			self.gameUi:updateFrame()
		end
		--只有等于0的时候 才需要深度排列
		if self.skillPauseInfo.left == 0   then
			self.sortControler:sortDepth()
		end
		if self.layer then
			self.layer:updateFrame(dt)
		end
	end

	-- 首先刷新事件,放在最前面是因为可能用来分帧创建英雄
	if not self.scenePause then
		self:updateCallFunc()
		self.logical:updateFrame()
		if not self:isQuickRunGame() then
			self:runObjUpdate(dt)
		end
		
	end
	
	if self._isFramePlay == 2 then
		self._isFramePlay = 1
	end

end


--获取2组的最远距离
function GameControler:getGroupDistance(  )
	return self.camera.minDistance
end

-- 星级判断
function GameControler:checkBattleStar()

	--拿到星级评价
    local starInfo = self.levelInfo.__starInfo
    if not starInfo or #starInfo == 0 then
    	self._battleStar = 0
    	return
    end
    if self._battleStar > 0 then
    	print("已经出战斗结果了,不应该再调用第二次了"..tostring(self._battleStar))
    	return
    end
    if BattleControler:checkIsTrail() ~= Fight.not_trail then
    	local tId = self.levelInfo.battleInfo.battleParams.trialId
		local max = FuncTrail.getMaxRewardByTrialId(tId)
		local base = FuncTrail.getBaseRewardByTrialId(tId)
		local bCount,mCount =self:getTrialSimpleReward()
		local tRt = self:getTrialResult()
		local count = tRt.monsterNum * mCount + tRt.bossNum * bCount + base
		if count >= max then
			count = max
		end
		local per = math.round(count/max * 100)
		-- 全部获取为3星，70%到100%为2星 70%以下为1星
		if per < 70 then
			self._battleStar = 1
		elseif per >= 70 and per <= 99 then
			self._battleStar = 5
		else
			self._battleStar = 7
		end
		echo ("试炼获得的星级",self._battleStar)
		return
	end
    -- 1，顺利通关 2，死亡角色少于三人 3，无角色死亡 {type:1,value:0},{type:2,value:3}
    --类型1 表示顺利通关 无参数,类型2表示死亡人数少于value的时候,.type4,表示回合数少于
    -- local diedCnt =  #self.levelInfo.campData1 - #self.campArr_1
    local diedCnt =  #self.levelInfo.campData1 - self:countLiveHero(self.campArr_1)
    --游戏存活，我方有存活
    local checkIsLive = function ()
    	return self:chkLiveHero(self.campArr_1)
    	-- if #self.campArr_1 >0 then
    	--  	return true
    	--  end 
    	--  return false
    end

    --死亡角色<val个
    local checkLiveCnt = function ( val )
    	if diedCnt<val then
    		return true
    	end
    	return false
    end
    --所有全部存活
    local checkAllHeroLive = function ( val )
    	if diedCnt<=0 then
    		return true
    	end
    	return false
    end

    --进行了多少回合
    local checkRoundCnt = function ( val )
    	--echo("checkRoundCnt:#self.diedArr_1----",#self.diedArr_1,"val:",val,"-------------")
    	if self.logical.roundCount< val then
    		return true
    	end
    	return false
    end
    -- 检查敌方boss剩余血量(100-hp)
    local checkBossHp = function ( val )
    	local hp = 100 - self:getBossHpPercent()
    	if hp >= val then
    		return true
    	end
    	return false
    end
    -- 检查我方剩余总血量
    local checkHeroHp = function( val )
    	local currHp = 0
		for k,v in pairs(self.campArr_1) do
    		local hp = math.round(v.data:getAttrPercent(Fight.value_health )*100)
    		currHp = currHp + hp
		end
		local count = #self.levelInfo.campData1 <= 0 and 1 or #self.levelInfo.campData1
		local per = currHp/count
		if per >= val then
			return true
		else
			return false
		end
    end

    local star = {}
    --从三到一进行判断
    for i=3,1,-1 do
		if starInfo[i].type == Fight.star_live_hero then
			if self:chkLiveHero(self.campArr_1) then
				star[i] = 1
			else
				star[i] = 0
			end
    	elseif starInfo[i].type == Fight.star_live_count then
    		if checkLiveCnt(starInfo[i].value) then
    			star[i] = 1
    		else
    			star[i] = 0	
    		end
    	elseif starInfo[i].type == Fight.star_live_all then
    		if checkAllHeroLive(starInfo[i].value) then
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    		--echo("i:",star[i],"------")
    	elseif starInfo[i].type == Fight.star_round_count then
    		if checkRoundCnt(starInfo[i].value) then
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    	elseif starInfo[i].type == Fight.star_boss_hp then
    		if checkBossHp(starInfo[i].value) then
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    	elseif starInfo[i].type == Fight.star_hero_hp then
    		if checkHeroHp(starInfo[i].value) then
    			star[i] = 1
    		else
    			star[i] = 0
    		end
    	end
    end
    -- dump(starInfo,"starInfo====")
    -- echo("战斗星级处理",star[1],star[2],star[3])
    self._battleStar = math.pow(2,0)*star[1] + math.pow(2,1)*star[2] + math.pow(2,2)*star[3]
    -- print("战斗星级判断==="..tostring(self._battleStar))
end


-------------------------------------------------------------------------
----------------------- 刷新对象 ----------------------------------------
-------------------------------------------------------------------------
--执行对象的刷新函数
function GameControler:runObjUpdate( dt )

	--在启动刷新函数之前做的事
	local obj
	for i=#self.allModelArr,1,-1 do
		obj = self.allModelArr[i]
		if obj.updateFirst then
			obj:updateFirst()
		end
	end
	
	-- 有可能在中间过程中删除游戏
	local  length = #self.allModelArr
	local  tb = table.copy(self.allModelArr)
	for i=length,1,-1 do
		obj = tb[i]	
		if not obj._isDied and  obj.updateFrame then
			obj:updateFrame(0)
		end
	end

end
------------------------------------------------------------------------
-------------------------------------------------------------------------
----------------------- 事件及处理 --------------------------------------
-------------------------------------------------------------------------
--注册一些侦听
function GameControler:initEvents(  )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_GAMEPAUSE,self.checkGamePause,self )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SUREQUIT,self.pressGameQuit,self )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_CLOSE_REWARD,self.closeRewardWindow,self )
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_SUREQUIT_BEFORE_BATTLE_LOOP,self.doQuitGameBeforBattleLoop,self)
end

-- 暂停退出
function GameControler:pauseOut()
	self._battleStar = 0
	self:setBattleResult(Fight.result_lose)
	self:enterGameLose()
end

-- 测试,为了快速胜利
function GameControler:quickVictory( star)
	echo("___________点击快速结束战斗按钮",self.updateCount,star)
	if self:chkIsResultComeOut() then
		return
	end
	echo("star----------",star)
	if star == -1 then
		--竞技场胜利
		self:setBattleResult(Fight.result_win)
		self:enterGameWin()
		return
	end

	if star == -2 then
		--竞技场失败
		self:setBattleResult(Fight.result_lose)
		self:enterGameLose()
		return
	end
	self._battleStar = star or 0
	
	-- self:scenePlayOrPause(true)
	if star  == 0 then
		self.isSkip = true
		self:setBattleResult(Fight.result_lose)
		self:enterGameLose()
	else
		self.isSkip = true
		self:setBattleResult(Fight.result_win)
		self:enterGameWin(star)
	end
	
	-- self:playVictoryAction()
end


--[[
还没有开始战斗循环就结束
]]
function GameControler:doQuitGameBeforBattleLoop(  )

	--这里要缓存一个数据  标示  在客户端收到 消息 showReward的时候不能显示  失败界面 
	--[[
	当前的处理情况是：当客户端发送退出战斗的时候，直接 showReward了。然后就显示失败界面了
	但是在剧情中不能这么处理
	]]

	self:setBattleResult(Fight.result_lose)
	local resultInfo = BattleControler:getBattleDatas( false )
	--LogsControler:writeDumpToFile( resultInfo,8,8 )
	if BattleControler:isRealInBattle() then
		--echoError("发送离开战斗的消息------")
		EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_USER_LEAVE,resultInfo)
		BattleControler.betweenAction = false
		BattleControler.userLevel = true
		BattleControler.isStoryExit = true
	end
	
	self:afterCheckReward()
end

-- 退出按钮
function GameControler:pressGameQuit( e )
	if self.gameMode == Fight.gameMode_pve   then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_GAMEPAUSE )
		self:setIsPauseOut(true)
		if BattleControler:checkIsTower() then
			-- 游戏先出结果
			self.__gameStep = Fight.gameStep.result
			-- 如果是锁妖塔，那就是直接退出战斗
			local resultInfo = BattleControler:getBattleDatas( false )
			EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_TOWER_LEAVE,resultInfo)
			BattleControler:onExitBattle()
			return
		end
		-- self:quickVictory(0,true)
		self:pauseOut()
		return
	end
	self:closeRewardWindow()
end

-- 关闭奖励界面
function GameControler:closeRewardWindow( ... )
	echo("当前的战斗结果---------",self._gameResult,"============")
	if self._gameResult == Fight.result_win then
		self:checkDialogAndAnimation(3,"afterCheckReward",0,{})
	else
		self:afterCheckReward()
	end
end

--[[
真正关闭战斗
]]
function GameControler:afterCheckReward(  )
	self._sceenRoot:unscheduleUpdate()
	BattleControler:onExitBattle(self._gameResult)
end
-------------------------------------------------------------------------------
-------------------------------------------------------------------------------
---------------------  数组管理   ---------------------------------------------
-------------------------------------------------------------------------------

--清除一个对象
function GameControler:clearOneObject( target )
	table.removebyvalue(self.allModelArr,target,true)
	table.removebyvalue(self.depthModelArr,target,true)
	table.removebyvalue(self:getCampArr(target.camp),target,true)	
	table.removebyvalue(self:getDiedCampArr(target.camp), target, true)
	-- 移除自身的回调
	self:clearOneCallFuncByObj(target)
end

--添加一个对象
function GameControler:insertOneObject(target ,outSort)

	if table.indexof(self.allModelArr, target) == false then
		table.insert(self.allModelArr, target)
	end
	if target.modelType == Fight.modelType_heroes then
		local campArr = self:getCampArr(target.camp)		
		if table.indexof(campArr, target) == false then
			table.insert(campArr, target)
		end
	end
	if not outSort then
		table.insert(self.depthModelArr, target)
	end
end

-------------------------------------------------------------------------
----------------------- 一些信息刷新 ------------------------------------
-------------------------------------------------------------------------
--一些更新信息,黑屏时间, 超时等
function GameControler:someUpdateInfo(  )
	if not self.scenePause then		
		if self.skillPauseInfo.left > 0  then
			self.skillPauseInfo.left  = self.skillPauseInfo.left - 1
			--如果达到技能恢复的时间了  那么 让所有人恢复技能暂停
			if self.skillPauseInfo.left == 0 then
				self:hideBlackScene()
			end
		end
	end

	if self.scenePause then
		if self.scenePauseLeft > 0 then
			self.scenePauseLeft = self.scenePauseLeft - 1
			if self.scenePauseLeft == 0 then
				--取消场景暂停
				self:scenePlayOrPause(false)
			end
		end
	end

end


function GameControler:showBlackScene(  )
	if (not Fight.isDummy) and (not self:isQuickRunGame() ) then
		self.sortControler:sortDepth()
		self.layer:showBlackImage(self.middlePos,-GameVars.halfResHeight )
		--echo("__显示黑屏-_-__---")
		self:clearOneCallFunc("hideBlackScene")
		--放大招的时候 加速
		-- self.addOtherSpeed = 1
		self:checkMaxSkillSpeed(true)
		
		self.skillPauseInfo.left = 99999

		--让所有的特效判定一次深度
		for i,v in ipairs(self.allModelArr) do
			if v.modelType == Fight.modelType_effect and v.onSkillBlack  then
				v:onSkillBlack()
			end
		end
	end
end

--隐藏黑屏
function GameControler:hideBlackScene()
	if not Fight.isDummy  then
		self.layer:hideBlackImage()
	end
	self.skillPauseInfo.left = 0
	self:checkMaxSkillSpeed(false)
end

-------------------------------------------------------------------------
----------------------- 回调函数信息 ------------------------------------
-------------------------------------------------------------------------
--更新回调
function GameControler:updateCallFunc(  )
	-- 保证循环不被破坏
	self.callFuncUpdating = true

	--执行一些回调
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		if callInfo and callInfo._valid and callInfo.left > 0 then
			callInfo.left = callInfo.left -1
			if callInfo.left ==0 then
				--必须先移除这个回调信息 因为回调函数里面可能继续有回调
				-- 减少遍历这里保留直接删除，因为这里的倒序删除不会产生问题
				table.remove(self.callFuncArr,i)
				--如果回调是字符串
				if type(callInfo.func) == "string" then
					if callInfo.params then
						self[callInfo.func](self,unpack(callInfo.params))
					else
						self[callInfo.func](self)
					end
				else
					if callInfo.params then
						callInfo.func(unpack(callInfo.params))
					else
						callInfo.func()
					end
				end
				
			end
		end
	end

	self.callFuncUpdating = false

	self:clearUnValidCallFunc()
	self:purgeCallFuncCache()
end


--一个英雄生命值为0了
function GameControler:oneHeroeHealthDied( who, attacker )	
	self.logical:chkStatisticsNum(who)
	local index = table.indexof(who.campArr, who)
	--如果没有index 说明是已经删除过了
	if not index then
		return
	end
	-- 发送英雄死亡事件，让头像隐藏
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_SOMEONE_DEAD)
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

	-- 退还可能扣了但并没有释放成功的怒气
	self.energyControler:returnEnergyByHero(who)

	--发送英雄死亡事件
	-- self.logical:doChanceFunc({camp = 0,chance = Fight.chance_onDied,defender = who,attacker = attacker })
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
	end

	if BattleControler:checkIsTrail() ~= Fight.not_trail then
		-- if not who.data:checkHasOneBuffType(Fight.buffType_kuilei) then
			self:updateTrialGoldNum(who)
		-- end
	end
	who:onRemoveCamp()
	if  self:isQuickRunGame() then
		if not (who:checkWillBeRelive() or who:checkWillDieSkill()) then
			self:pushOneCallFunc(200, who.alreadyDead, {who})
			--who:alreadyDead()
		end
		
	end

	self:checkGameResult()
end
-- 判断是否是活人
function GameControler:isLiveHero(hero)
	local isMission = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionMonkeyPve)
	local isBomb = (BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve)
	local isZL = hero:getHeroProfession() == Fight.profession_neutral or hero:getHeroProfession() == Fight.profession_obstacle
	local isdied = false
	if isMission or isBomb then
		isdied = hero:hasNotAliveBuff()
	else
		isdied = (hero:hasNotAliveBuff() or isZL)
	end
	-- 如果是车轮战、并且还有可刷的怪，则中立怪不死
	if self.levelInfo:chkIsRefreshType() and self.reFreshControler:getRefreshCount() > 0 then
		-- echo("还有可刷的怪")
		if isZL then
			isdied = false
		end
	end

	return not isdied
end
-- 判断是否还有活人（傀儡不算活人）、中立 障碍物也不算活人
function GameControler:chkLiveHero( campArr )
	local result = false
	for _,hero in ipairs(campArr) do
		if self:isLiveHero(hero) then
			result = true
			break
		end
	end

	return result
end

-- 统计活人数量
function GameControler:countLiveHero( campArr )
	local count = 0
	for _,hero in ipairs(campArr) do
		if self:isLiveHero(hero) then
			count = count + 1
		end
	end

	return count
end
-- 检查是否已经出结果
function GameControler:chkIsResultComeOut( )
	if self.__gameStep == Fight.gameStep.result then
		return true
	end
	return false
end

--判断胜负
function GameControler:checkGameResult()
	if self.reFreshControler:checkNeedRefresh() then
		-- 此时如果我方没有活人了，也需要结束
		if self:countLiveHero(self.campArr_1) == 0 then
			self:enterGameWin()
		end
		-- 这里兼容一下，如果都把人打死了，还能刷怪，则需要刷一次。
		self.reFreshControler:checkRefreshMonster(self.logical.currentCamp)
		return
	end
	local bLabel = BattleControler:getBattleLabel()
	--如果是最后一波  那么死一个人就要判定一次胜负
	-- echo("胜负判定---------",self.__currentWave == self.levelInfo.maxWaves,self.__currentWave,self.levelInfo.maxWaves)
	local isLastWave = (self.__currentWave == self.levelInfo.maxWaves)
	local hasEnemy = false
	for i,v in ipairs(self.campArr_2) do
		if v:getHeroProfession() ~= Fight.profession_neutral and 
			v:getHeroProfession() ~= Fight.profession_obstacle and
			self:isLiveHero(v)
			then
			hasEnemy = true
			break
		end
	end
	-- 猴子玩法
	if bLabel == GameVars.battleLabels.missionMonkeyPve 
	 then
		 -- 猴子玩法不判定中立怪和障碍物
	 	if #self.campArr_2 > 0 then
	 		hasEnemy = true
	 	end
		local count = self.reFreshControler:getRefreshCount()
		if isLastWave and not hasEnemy and count == 0 then
			if not hasEnemy then
				for k,v in ipairs(self.campArr_2) do
					if self:checkMonsterIsBaoWu(v) then
						self.logical:updateColletMonkeyNum()
					end
				end
			end
			self:enterGameWin()
		end
		if #self.campArr_1 == 0 and #self.diedArr_1 == 0 or not self:chkLiveHero(self.campArr_1) then
			self:enterGameLose()
		end
		return
	end
	-- 炸药桶
	if bLabel == GameVars.battleLabels.missionBombPve then
		if isLastWave and not hasEnemy then
			-- 检查回合是否大于总回合数，否则就返回none
			if self:getCurrRound() >= self:getMaxRound() then
				self:enterGameWin()
			end
			return
		end
		if #self.campArr_1 == 0 and #self.diedArr_1 == 0 or not self:chkLiveHero(self.campArr_1) then
			self:enterGameLose()
		end
		return
	end
	-- 车轮战
    if self.levelInfo:chkIsRefreshType() then
		local count = self.reFreshControler:getRefreshCount()
		if isLastWave and not hasEnemy and count == 0 then
			self:enterGameWin()
		end
		if #self.campArr_1 == 0 and #self.diedArr_1 == 0 or not self:chkLiveHero(self.campArr_1) then
			self:enterGameLose()
		end
    	return
    end

	if isLastWave and not hasEnemy then
		self:enterGameWin()
		return
	end
	--如果我方人死光了（或没有活人了
	if #self.campArr_1 == 0 and #self.diedArr_1 == 0 or not self:chkLiveHero(self.campArr_1) then
		if BattleControler:checkIsShareBossPVE() or 
			bLabel == GameVars.battleLabels.guildBossPve or
			bLabel == GameVars.battleLabels.exploreElite or
			BattleControler:checkIsTrail() ~= Fight.not_trail then
			self:enterGameWin()
		else
			self:enterGameLose()
		end
		return
	end

	-- 我方没有活人了
	-- echo("波数-----",self.__currentWave,self.levelInfo.maxWaves)
	if isLastWave then
		local rst = self.levelInfo:checkGameResult(self)
		if rst == Fight.result_win then
			self:enterGameWin()
			for i,v in ipairs(self.campArr_2) do
				--做退场行为
				v:doExitGameAction()
			end
		elseif rst == Fight.result_lose then
			self:enterGameLose()
		end
	end
end

--[[
回合结束，检查新的回合
]]
function GameControler:checkNewRoud()
	if not Fight.isDummy then
		self:checkDialogAndAnimation( 4,"checkNewRoudInCtrl",self.logical.roundCount,{})
	else
		return self:checkNewRoudInCtrl()
	end
end

--[[
在这里判断回合结束就可以  执行相应的逻辑
]]
function GameControler:checkNewRoudInCtrl(  )
	local currRound = self:getCurrRound( )
	local maxRound = self:getMaxRound()+1 --判断是否是最大回合的下一个回合
	local trailType = BattleControler:checkIsTrail()
	echo("------当前的回合数",self.logical.roundCount,"============",maxRound,trailType)
	if self:chkIsLevel_splongyou()
		and self.__currentWave == Fight.xvzhangParams.longyouIn_wave
		and self.logical.roundCount == Fight.xvzhangParams.longyouIn_round then
		-- 判断是不是有空位
		local changePos = nil

		for pos = 6,1,-1 do
			local hero = self.logical:findHeroModel(Fight.camp_1, pos)
			if not hero then
				changePos = pos
				break
			end
		end
		-- 没有空位或有龙幽
		if not changePos then
			echoError("错误情况没有助阵的空位")
			return self:chkNextRound()
		end
		
		-- 要求给一点怒气
		-- self.energyControler:addEnergy(Fight.energy_entire,1,nil,1)

		-- 强行加个怒气
		self.energyControler:addEnergy(Fight.energy_entire,4,nil,1)

		-- 要处理isDummy 这场战斗已经是战斗服需要校验的战斗了
		if not Fight.isDummy then
			-- --对话结束的回调
			local onUserAction = function(ud)
			    if ud.step == -1 and ud.index == -1 then
			        --序章刷新龙幽进场
			        self.reFreshControler:level3_3RefreshLongyou(changePos)
			        self:pushOneCallFunc(30, c_func(self.chkNextRound,self),{})
			    end
			end

			PlotDialogControl:showPlotDialog(Fight.xvzhangParams.longyouPlot, onUserAction)
		   
		    --序章刷新龙幽进场
		    -- self.reFreshControler:level3_3RefreshLongyou(changePos)
		    -- self:pushOneCallFunc(30, c_func(self.chkNextRound,self),{})
		else
			--序章刷新龙幽进场
			self.reFreshControler:level3_3RefreshLongyou(changePos)
			-- 下一回合
			return self:chkNextRound()
		end
	elseif currRound == maxRound + 1 and
		( BattleControler:getBattleLabel() == GameVars.battleLabels.missionBombPve or
		trailType ~= Fight.not_trail ) 
		then
		self:enterGameWin()
	else
		return self:chkNextRound()
	end
end

--[[
在这里要判断回合数
如果还没有召唤财神  则 5个回合
如果已经召唤了财神  
]]
function GameControler:chkNextRound(  )
	if self:chkIsResultComeOut() then
		return
	end

	-- 如果跳过验证则不再继续
	if self:isCancelCheck() then
		return
	end
	-- 检查是否需要切回合
	
	--如果敌方阵营没人了（或者没有活人了）
	if (#self.campArr_2 == 0 and #self.diedArr_2 ==0) or not self:chkLiveHero(self.campArr_2) then
		self:setGameStep(Fight.gameStep.wait)
		local isRType = (self.levelInfo:chkIsRefreshType() and self.reFreshControler:getRefreshCount() > 0)
		-- 这里判断车轮战合六界玩法
		local bLabel = BattleControler:getBattleLabel()
		if bLabel == GameVars.battleLabels.missionMonkeyPve or
			bLabel == GameVars.battleLabels.missionBombPve or
			isRType
			then

			-- 这里让玩家回到原来位置
			for i,v in ipairs(self.campArr_1) do
				v:movetoInitPos(2)
			end
			local camp = isRType and self.logical.currentCamp or 1
			-- 强制定制我方回合结束
			self.logical:endRound(camp)
			return
		end
		-- 把对面剩余活着的人物（目前是傀儡）致死
		if #self.campArr_2 ~= 0 then
			for i = #self.campArr_2,1,-1 do
				self.campArr_2[i]:doHeroDie()
			end
		end

		--加入轮空奖励等操作
		self.logical:beforNextWave()
		echo(#self.campArr_2,"___地方人数")
		for i,v in ipairs(self.campArr_1) do
			--清除负面buff
			v.data:clearBuffByKind(Fight.buffKind_huai )
			--进入下一波的时候 记得让buff次数减1
			v:doToRoundEnd()
			--过图 回复能量
			-- v.data:changeValue(Fight.value_energy , Fight.waveEnergyResume)
		end
		if Fight.isDummy  then
			self:enterNextWave()
		else
			self:pushOneCallFunc(5, "enterNextWave", params)
		end
		return
	end

	if not Fight.isDummy then
		self:checkDialogAndAnimation(5,"insertPlotDialogBeforStarRound",self.logical.roundCount,{},1)	
	else
		return self.logical:startRound()	
	end
	
end

-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function GameControler:checkReplay(  )
	self.runGameIndex = self.runGameIndex + 1
	self:gameReplay()
end

function GameControler:gameReplay()
	echo("_________________重新战斗")
	self._sceenRoot:unscheduleUpdate()

	-- 竞技场时会进行一次重播.
	if self.gameMode == Fight.gameMode_pvp then
		Fight.isDummy = false
	end
	self:deleteAll()
	self.updateCount = 0
	self.replayGame = 1
	self.__currentWave = 0
	self.gameLeftTime = -1

	-- 改变游戏状态
	self:setGameStep(Fight.gameStep.load)

	self:initFirst()	
end
------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------

function GameControler:processGameResult(result, quit,star)
	if (not BattleControler:checkIsPVP()) and result == Fight.result_win then
		self:checkBattleStar()
		-- print("为什么会走这里来====="..tostring(result))
	else
		-- print("战斗星级=="..tostring(self._battleStar).."战斗结果:"..tostring(result))
	end
	-- 这个应该是一开始就往前提，否则self._gameResult会造成赋值不一致的问题
	if self:chkIsResultComeOut() then
		return
	end
	-- 推送一条已到达最大回合通知
	if self:getCurrRound() >= self:getMaxRound() then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_WAVE_MAX)
	end
	self:setGameStep(Fight.gameStep.result)
	if (not Fight.isDummy) and star then
		self._battleStar = star
	end
	self:setBattleResult(result)

	-- 在这里处理一些逻辑
	self:onCheckGameResult()

	IS_IGNORE_LOG = self.__IS_IGNORE_LOG
	-- 如果是游戏快进结束的
	if self.quickUpdateScale then
		-- 重置动画创建
		ViewSpine:disableCtor(false)

		self:changeGameSpeed(self.quickUpdateScale)
		self.quickUpdateScale = nil
	end
	-- 
	echo("____gameResult_____".. result,self.updateCount.."  "..self:getUserRid())
	echo("self._battleStar", self._battleStar)
	
	
	-- if (not Fight.isDummy) or  (not IS_CHECK_DUMMY) then 
		self._hasSaveBattleInfo = true
		BattleControler:saveBattleInfo()
	-- end

	if quit then
		self:submitGameResult(true)
	else
		if self._gameResult == Fight.result_win and not Fight.isDummy then
			--self:checkAfterBattleDialog(c_func(self.playVictoryAction,self))
			self:playVictoryAction()
			--self:checkDialogAndAnimation(3,"playVictoryAction",0,{step = -1,index = -1})
		else
			self:playVictoryAction()
		end
	end
end

-- 胜利
function GameControler:enterGameWin(star)
	self:processGameResult(Fight.result_win,nil,star)
end

-- 失败
function GameControler:enterGameLose(  )
	self:processGameResult(Fight.result_lose)
end

-- 超时
function GameControler:enterGameTimeUp(  )
	self:enterGameLose()
end

--播放胜利失败动作后 2-3s胜利失败
-- pangkangning 2017.10.27 修改为50帧以后弹结算界面(因为某些角色大招时间过长)
function GameControler:playVictoryAction()
	if Fight.isDummy then
		self:submitGameResult(false)
	else
		local frame = 50

		if self._isPauseOut then
			frame = 5
		elseif self.isQuickGameToResult then
			frame = 5
		end
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPve then
			frame = 60
			self.gameUi:showEndBattleAni()
		end

		if self._gameResult == Fight.result_win then
			self:pushOneCallFunc(frame,"submitGameResult",{false})
		else
			self:pushOneCallFunc(frame,"submitGameResult",{false})
		end
	end
end

function GameControler:submitGameResult(quit)
	if DEBUG_SERVICES then
		return
	end

	if Fight.isDummy then
		return
	end

	-- 有引导
	if not IS_CLOSE_TURORIAL then
		-- 存两个变量
		if tostring(self.levelInfo.hid) == Fight.xvzhangParams.pvp then
			LS:prv():set(StorageCode.tutorial_first_pvp,1)
		end
		if tostring(self.levelInfo.hid) == Fight.xvzhangParams.trial then
			LS:prv():set(StorageCode.tutorial_first_trial,1)
		end
	end

	-- 单人战斗告诉分系统结果(单人多人都以阵营1为准)
	local resultInfo = BattleControler:getBattleDatas( self.isSkip )

	if self:chkIsXvZhang() then
		self.gameUi:delayCall(function ()
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
			BattleControler.betweenAction = false
		end,0.01)
		return
	end

	if Fight.allways_lose then
		self:setBattleResult(Fight.result_lose)
	end
	if self.replayGame > 0 then
		echo("_______________战斗回放出结果",self.updateCount)
		-- EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_REPLAY_GAME,resultInfo  )
		if self.gameMode == Fight.gameMode_pvp  then
			-- WindowControler:showBattleWindow("ArenaBattleReplayResult")
		end
		--暂时直接弹竞技场战斗结算界面
		WindowControler:showBattleWindow("ArenaBattleReplayResult")
		return
	end
	self._isEndBattle = true --本地已经跑完战斗了[是否做战斗校验用]

	if BattleControler:checkIsMultyBattle() then
		echo("发送多人战报数据====")
		self.server:sendBattleEnd(resultInfo)
		self.gameUi:addCrossPeakResultTimeOut(resultInfo.battleId)
	else
		-- 如果是主动退出战斗,永离
		if quit then	
		    EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_USER_LEAVE,resultInfo)
		    BattleControler.betweenAction = false
		    echo("------------个人战斗,主动退出战斗",self.updateCount)     
		   	return
		end

		echo("_______________正常战斗结果",self.logical.roundCount,BattleRandomControl.getCurStep())
		-- dump(resultInfo)
		
		BattleControler.betweenAction = false

		if Fight.isDummy  then
			BattleControler:onExitBattle()
			return
		end

		if BattleControler.isDebugBattle  then
			BattleControler:showReward({reward = {"3,100"},result = self._gameResult,star = self._battleStar})
			return
		end
		
		EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_BATTLE_RESULT,resultInfo )
	end
end


-------------------------------------------------------------------------
-------------------------------------------------------------------------
-------------------------------------------------------------------------
--设置英雄的 整体行动阶段   
function GameControler:setGameStep( value )
	self.__gameStep = value
end

--各种暂停操做
--暂停按钮的回调
function GameControler:checkGamePause(event  )
	if self:chkIsResultComeOut() then
		return
	end

	-- 只有单人战斗才能暂停
	if self.gameMode == Fight.gameMode_pve then	
		if self._gamePause then
			self:playOrPause(true)
		else
			self:playOrPause(false)
		end
	end	
end

--根据模式判断是否可操作
function GameControler:checkCanHandle(  )
	
	--目前暂定只有pve或者gve可以操作
	if self.gameMode ==Fight.gameMode_pve or self.gameMode == Fight.gameMode_gve then
		return true
	end
	if self.gameMode == Fight.gameMode_pvp then
		-- 巅峰竞技场是手动的
		if BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp or
			BattleControler:getBattleLabel() == GameVars.battleLabels.crossPeakPvp2
			 then
			return true
		end
	end
	return false
end


--播放或者暂停游戏
function GameControler:playOrPause(value,delay )
	self._gamePause = not value
	--让所有的事件停止
	for i,v in ipairs(self.allModelArr) do
		v:gamePlayOrPause(value)
	end
end

--普通战斗场景播放或者暂停
function GameControler:scenePlayOrPause( value,lastFrame )
	--虚拟跑的不需要场景暂停
	if Fight.isDummy  then
		return
	end
	-- echo("设置场景暂停:",value,lastFrame)
	self.scenePause = value
	for i,v in ipairs(self.allModelArr) do
		v:scenePlayOrPause(value)
	end
	if lastFrame then
		self.scenePauseLeft = lastFrame
	end
end


function GameControler:pushOneCallFunc( delayFrame,func,params )
	if not func then
		echoError("___空函数")
		return
	end
	
	if not delayFrame then
		echoError("___空帧数")
		return
	end

	if delayFrame ==0 then
		if type(func) == "string" then
			func = self[func]
			if params then
				self[func](self,unpack(params))
			else
				self[func](self)
			end
		else
			if params then
				func(unpack(params))
			else
				func()
			end
		end
		
		return
	end

	local info = {
		left = delayFrame,
		func = func,
		params = params,
		_valid = true,
	}

	if self.callFuncUpdating then
		table.insert(self.callFuncArrCache, info)
	else
		--插入到最前面
		table.insert(self.callFuncArr,1, info)
	end
end

-- 将缓存压入
function GameControler:purgeCallFuncCache()
	for i,info in ipairs(self.callFuncArrCache) do
		table.insert(self.callFuncArr,1,info)

		self.callFuncArrCache[i] = nil
	end
end

-- 遍历删除失效回调
function GameControler:clearUnValidCallFunc()
	if self.callFuncClearFlag then
		self.callFuncClearFlag = false
		for i,info in ripairs(self.callFuncArr) do
			if not info._valid then
				table.remove(self.callFuncArr, i)
			end
		end
	end
end
--清除一个回调
function GameControler:clearOneCallFunc( func,obj )
	local function clearFunc( t )
		local length = #t
		for i=length,1,-1 do
			local info = t[i]
			if info._valid and info.func == func then
				if obj then
					if info.params and info.params[1] == obj then
						if self.callFuncUpdating then
							info._valid = false
							self.callFuncClearFlag = true
						else
							table.remove(t,i)
						end
					end
				else
					if self.callFuncUpdating then
						info._valid = false
						self.callFuncClearFlag = true
					else
						table.remove(t,i)
					end
				end
				
			end
		end
	end
	clearFunc(self.callFuncArr)
	-- 缓存也要清
	clearFunc(self.callFuncArrCache)
end
-- 根据传入的targe移除parames里面是该对象的oneClallFunc
function GameControler:clearOneCallFuncByObj(target )
	local function clearFunc( t )
		local length = #t
		for i=length,1,-1 do
			local info = t[i]
			if info._valid and info.params and info.params[1] == target then
				if self.callFuncUpdating then
					info._valid = false
					self.callFuncClearFlag = true
				else
					table.remove(t,i)
				end
			end
		end
	end
	clearFunc(self.callFuncArr)
	-- 缓存也要清
	clearFunc(self.callFuncArrCache)
end

function GameControler:deleteAll()

	for i=#self.allModelArr,1 ,-1 do
		if self.allModelArr[i] and self.allModelArr[i].deleteMe then
			self.allModelArr[i]:deleteMe()
		end
	end

	if self.gameUi then
		self.gameUi:stopAllActions()
		self.gameUi:startHide()
		self.gameUi = nil
	end

	if self.map then
		self.map:deleteMe()
		self.map = nil
	end
	--清除掉所有的事件
	FightEvent:clearAllEvent()

	self.screen = nil
	self.camera = nil
	self.depthModelArr = {}
	self.allModelArr ={}
	self.campArr_1 = {}
	self.campArr_2 = {}
	self.character = nil
end

--删除自己----------
function GameControler:deleteMe( )
	if self._isDied then
		echoError("__游戏已经删除了 又重复删除了,不应该")
		return 
	end
	echo("销毁游戏-----")
	self._isDied = true
	self:deleteAll()
	if self._sceenRoot then
		self._sceenRoot:unscheduleUpdate()
		self._sceenRoot = nil
	end
	if not BattleControler:getIsRestart() then
		if self.resControler then
			self.resControler:clearResource()
		end
	end

	if self.gameBackup then
		self.gameBackup:deleteMe()
		self.gameBackup = nil
	end

	if self.layer then
		self.layer:deleteMe()
		self.layer = nil
	end

	if self.verifyControler then
		self.verifyControler:deleteMe()
	end
	echo("________销毁游戏----------")
	self.callFuncArr = nil
	FightEvent:clearOneObjEvent(self)
	EventControler:clearOneObjEvent(self)
	if self.server then
		self.server:deleteMe()
		self.server = nil
	end
end

--播放切回合特效
function GameControler:playSwitchRoundEff(  )
	if Fight.isDummy  then
		return
	end
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------
----------------------------------------------------------------------------

--加速按钮
function GameControler:changeGameSpeed(speed,isForce )
	if Fight.debug_battleSpeed and Fight.debug_battleSpeed >1  then
		speed = Fight.debug_battleSpeed
	end
	if self.originSpeed == speed and (not isForce) then
		return
	end
	--记录上次调整过的时间 因为每次初始化游戏的时候 可能需要记录这个速度
	self.lastScale = self.updateScale
	if speed == 2 then
		speed = Fight.doubleGameSpeed
	elseif speed == 3 then
		speed = Fight.thirdGameSpeed
	end
	--gve 固定修改为2倍速
	if self.gameMode == Fight.gameMode_gve  then
		speed = Fight.doubleGameSpeed
		-- return
	end
	self.originSpeed = speed
	self.updateScale = self.originSpeed + self.addOtherSpeed
	echo(self.updateScale,"____self.updateScale")
	-- 初始化计数
	self.updateScaleCount = 0
	--更新所有对象的viewPlayspeed
	for i,v in ipairs(self.allModelArr) do
		if v.updateViewPlaySpeed then
			v:updateViewPlaySpeed()
		end
	end
	if self.camera then
		self.camera:upGameSpeed()
	end
end

--改变oterSpeed
function GameControler:changeOtherSpeed( value )
	--暂时屏蔽otherspeed
	self.addOtherSpeed = value
	self:changeGameSpeed(self.originSpeed ,true)
	
end


--判断是否可以布阵
function GameControler:checkCanBuzhen(  )
	if Fight.isDummy or self:isReplayGame() or self:isQuickRunGame() then
		return false
	end
	-- 现在序章不需要禁拖拽了
	--原来序章都不可以拖动，现在只有在序章1 中不能拖动
	-- local hasOperate  = function()
	-- 	local myCampArr = self.campArr_1
	-- 	for k,v in pairs(myCampArr) do
	-- 		if v.hasOperate then
	-- 			return true
	-- 		end
	-- 	end
	-- 	return false
	-- end

	local levelId = self.levelInfo.hid

	if self:chkYinDaoDrag() then
		return true
	end

	--如果已经布阵完成
	if self.logical:getBuzhenState() then
		return false
	end
	-- 巅峰竞技场战前换位
	local bState = self.logical:getBattleState()
	if BattleControler:checkIsCrossPeak() and 
		bState == Fight.battleState_formationBefore then
		local cpData = self.levelInfo:getCrossPeakOtherData()
		if cpData.changeCamp and cpData.changeCamp == BattleControler:getTeamCamp() then
			return true
		end
	end
	if self.logical.currentCamp ~= BattleControler:getTeamCamp() then
		return false
	end

	if self.logical:getLeftAutoFrame() == -1 then
		return false
	end
	--如果是自动战斗的
	if self.logical:checkIsAutoAttack(1) then
		return false
	end
	-- 根据回合模式判断
	if self.logical.roundModel == Fight.roundModel_semiautomated and 
		bState == Fight.battleState_switch
		then
		return false
	end
	return true

end

--确认6个位置的点击区域
function GameControler:sureHeroPosArea(  )
	self.heroPosArea = {{},{}}
	local yDis = Fight.initYpos_2 - Fight.initYpos_1
	for i=1,2 do
		for j=1,6 do
			--先记录脚下点的坐标
			local x,y = self.reFreshControler:turnPosition(i, j,1 ,self.middlePos )
			
			--然后算矩形区域 判断离哪个最近
			table.insert(self.heroPosArea[i],{x= x,y = y})
		end
	end
end
-- 获取对应阵营的点击区域
function GameControler:getHeroPosAreaByCamp( camp )
	return self.heroPosArea[camp]
end


function GameControler:getUserRid(  )
	-- if not self.__userRid then
	-- 	for k,v in pairs(BattleControler._battleInfo.battleUsers) do
	-- 		if v.team == Fight.camp_1 then
	-- 			self.__userRid = v.rid or v._id
	-- 			break
	-- 		end
	-- 	end
	-- else
	-- 	return self.__userRid
	-- end
	return BattleControler._battleInfo.userRid --在初始化的时候赋值过
end


--缓存属性变量相关
function GameControler:getCacheValue( key  )
	return self.cacheValueMap[key]
end

function GameControler:setCacheValue( key,value )
	self.cacheValueMap[key] = value
end

--设置是否是debughero
function GameControler:setDebugHero(value  )
	self.isDebugHero = value
	--如果
	if not value then
		--如果还没有攻击过 而且是敌方的
		if self.logical.currentCamp == 2  and self.logical.attackNums == 0 then
			self.logical:checkNextHandle(self.logical.currentCamp)
		end
	end
	
end

--获取先手值
function GameControler:getUphandle( camp )
	if camp == 1 then
		return  10
	else
		return self.levelInfo:getUphandle(self.__currentWave)
	end
end

--是否快速跑游戏
function GameControler:isQuickRunGame(  )
	return self.updateScale> 5
end

--是否是重播的
function GameControler:isReplayGame(  )
	return self.replayGame > 0 
end

-- 检查是否是断线重连，并且是否已经运行至重连步骤
function GameControler:checkIsToReload( )
	--必须是多人战斗
	if not BattleControler:checkIsMultyBattle() then
		return false
	end
	if self.reloadData.isQuick then
		if self.logical.currentHandleIndex >= self.reloadData.targetHandleIndex then 
			self:changeGameSpeed(self.reloadData.oldUpdateScale)
			self.reloadData.isQuick = false
			-- 检查是否有傀儡buff或者冰冻buff，给上滤镜
			self:checkQuick2RoundStatus()
			echo("断线重连运行至当前同步位置-------------已经将游戏运行至指定回合",self.logical._battleState)
			self.logical:checkMultyStatus()
			IS_IGNORE_LOG = self.__IS_IGNORE_LOG
			return true
		end
	end
	return false
end

-- 是否是在追进度之中
function GameControler:checkIsInProgress( ... )
	if self.reloadData and self.reloadData.isQuick then
		return true
	end
	return false
end

-- 游戏直接运行到指定回合[如果传了tIdx就是运行到指定回合]
function GameControler:runGameToTargetRound(tIdx)
	local targetHandleIndex = tIdx or self.logical:getContinueIndex()
	local disIndex = targetHandleIndex - self.logical.currentHandleIndex
	echo("直接运行游戏至指定回合",targetHandleIndex,disIndex)
	if disIndex == 0 then
		self.logical:checkMultyStatus()
		return
	end
	--必须大于1了 我才去执行
	if disIndex > 0 then
		--如果当前已经是快速跑游戏了
		if self.reloadData.isQuick then
			--只需要同步index
			self.reloadData.targetHandleIndex = targetHandleIndex
		else
			--这里应该修改原始速度
			self.reloadData = {isQuick = true,oldUpdateScale=self.originSpeed,targetHandleIndex = targetHandleIndex}
			-- IS_IGNORE_LOG = true
		
			local  speed = 50 + disIndex * 10
			speed = speed > 300 and 300 or speed
			--1个操作多50次操作同步
			self.originSpeed  = speed
			self.addOtherSpeed =  0
			self.updateScale = self.originSpeed + self.addOtherSpeed
		end
		
		echo("__开始追进度---",disIndex,targetHandleIndex)
		--开始读缓存操作
		self.logical:startCatchProgress()
		--这里需要恢复加速
		self:checkMaxSkillSpeed(false)
	end
end


-- 游戏快速出结果
function GameControler:quickGameToResult( ... )
	-- 禁用动画创建
	ViewSpine:disableCtor(true)

	IS_IGNORE_LOG = true --快速战斗的时候,屏蔽战斗日志
	self.quickUpdateScale = self.updateScale
	self.updateScale = 2000

	self.isQuickGameToResult = true

	for k,v in pairs(self.allModelArr) do
		v.myView:stop()
	end
	self.gameUi:visible(false)

	-- 处理可能存在的未进行的与位置有关的缓存
	local function quickCheck(campArr)
		for _,hero in ipairs(campArr) do
			if hero:isNeeddoInitPosComplete() then
				hero:doInitPosComplete()
				break
			end
		end
	end

	quickCheck(self:getCampArr(Fight.camp_1))
	quickCheck(self:getCampArr(Fight.camp_2))
end

--判断是否大招开启加速模式 value true是设置加速,false是复原
function GameControler:checkMaxSkillSpeed( value )
	--如果是巅峰竞技场, 那么就强制给一个大招2倍速
	if BattleControler:checkIsCrossPeak() then
		if value then
			self:changeOtherSpeed(0.5)
		else
			self:changeOtherSpeed(0)
		end
	end

end

-- 复盘中跳过后续战斗（错误情况，后续不再继续验证）
-- msg 错误描述
function GameControler:setCancelCheck(msg)
	self._isCancelCheck = true
	local msg = msg or ""
	echo("终止校验----",msg)

	-- 战斗服验证无法发送到平台
	if DEBUG_SERVICES then return end

	local bInfo = self.levelInfo:getBattleInfo()
	local str = string.format("%s\n%s",msg, json.encode(bInfo))
	ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA, ClientTagData.battleErrorCancelCheck, str)
end

-- 是否终止校验
function GameControler:isCancelCheck()
	return Fight.isDummy and self._isCancelCheck  -- 只有在校验的时候需要终止校验
end

--[[
	获取自身自动战斗状态（获取本机玩家自动战斗的状态，不是逻辑上判定自动战斗的标准，谨慎使用）
	返回是否是自动战斗中，以及是否等待中（等待返回中不能点击）
]]
function GameControler:getUIGameAuto()
	return self._waitAuto.new,self._waitAuto.waiting
end

-- 设置战斗自动状态，走缓存统一入口
function GameControler:setGameAuto(value)
	-- 相同的不设置,等返回中不设置
	if self._waitAuto.new == value or self._waitAuto.waiting then return end
	-- 先将new更新，是否直接发出由其他条件决定（保证不会因为网速慢反复重新发）
	self._waitAuto.new = value
	-- 回合中无人攻击的情况直接执行，其余情况使用缓存的方式
	if self.logical.isInRound 
		and not self.logical.attackingHero 
	then
		self._waitAuto.waiting = true
		self.server:sendOneAutoHandle({auto = value and 1 or 0})
	else
		-- self._waitAuto.new = value
	end
end

-- 直接更新，不手动调用
function GameControler:updateGameAuto(value)
	self._waitAuto.new = value
	self._waitAuto.old = value
	self._waitAuto.waiting = false
end

-- 检查并发送自动战斗状态
function GameControler:chkSendGameAuto()
	-- 不是自己回合不更新
	if self.logical.currentCamp ~= BattleControler:getTeamCamp() then
		return
	end
	-- 状态发生改变，发送
	if self._waitAuto.old ~= self._waitAuto.new then
		self.server:sendOneAutoHandle({
			auto = self._waitAuto.new and 1 or 0,
			e1 = self.energyControler:getEntire(Fight.camp_1),
			e2 = self.energyControler:getEntire(Fight.camp_2),
		})
	end
end

function GameControler:getCampArr( camp )
	if camp == 1 then
		return self.campArr_1
	else
		return self.campArr_2
	end
end

function GameControler:getDiedCampArr( camp )
	if camp == 1 then
		return self.diedArr_1
	else
		return self.diedArr_2
	end
end
function GameControler:getCurrentWave( )
	return self.__currentWave
end

-- 战斗出结果的时需要处理的一些战斗内的状态（只处理战斗内逻辑）
function GameControler:onCheckGameResult()
	-- 出结果才处理
	if self.__gameStep ~= Fight.gameStep.result then return end

	-- 清空所有注册的技能
	self.triggerSkillControler:clearAllCallFunc()

	-- 检查死亡列表把有死亡技的标记全都置回
	local function manageDieSkill(camp)
		for _,hero in ipairs(self:getDiedCampArr(camp)) do
			hero.willDieSkill = false
		end
	end

	manageDieSkill(Fight.camp_1)
	manageDieSkill(Fight.camp_2)
end

return GameControler