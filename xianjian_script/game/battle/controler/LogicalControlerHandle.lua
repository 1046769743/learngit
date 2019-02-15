--
-- Author: xd
-- Date: 2018-01-11 10:07:55
-- 主要处理 logical 里面的操作相关的东西
LogicalControlerHandle = class("LogicalControlerHandle",LogicalControler)
local Fight = Fight
-- local BattleControler = BattleControler

--operationInfo = {}
--插入一个人的操作 operationType 1是放技能,params 空或者2 表示小技能或者普攻, 3表示大招, 对应Fight.skillIndex_small
--timely 操作为点击攻击时此参数有效，标记是否是在其他人小技能出手时的出手
--operationType,  2 是放法宝,params对应法宝序列 1或者2 ,
-- 3表示跳过本回合操作 不需要传参数
--delayFrame 延迟多少帧 执行 检测攻击行为 
function LogicalControlerHandle:insertOneHandle(operationInfo )
	--如果不是在回合中的 那么不执行
	if not self.isInRound then
		echo ("如果不是在回合中的 那么不执行")
		return
	end
	operationInfo.type = operationInfo.type or Fight.operationType_giveSkill
	local camp = operationInfo.camp
	local timely = operationInfo.timely or false
	local params = operationInfo.params
	local posIndex = operationInfo.index
	self.controler.viewPerform:resumeViewAlpha()
	echo("roundCount,camp,posIndex,type",self.roundCount,camp,posIndex,operationInfo.type,self.attackingHero,"==aaaa")
	
	local countStr = tostring(self.roundCount)
	if not self.operationMap[self.controler.__currentWave][countStr] then
		self.operationMap[self.controler.__currentWave][countStr] = {order = {},camp = camp}
	end

	local orderArr = self.operationMap[self.controler.__currentWave][countStr].order
	--记录上一次操作的情况
	local lastOperationInfoNums = #orderArr

	table.insert(orderArr,operationInfo )

	--如果是结束回合操作 直接先在这里判断
	if operationInfo.type == Fight.operationType_endRound then
		if self.attackingHero then
			return
		end
		
		return self:doEndRound(operationInfo.camp)
	end
	
	--让这个操作的人 隐藏脚下光环
	local hero = nil

	-- 神器技能
	if operationInfo.type == Fight.operationType_artifactSKill then
		hero = self.controler.artifactControler:getArtifactModel(camp)
	else
		hero = self:findHeroModel(camp, posIndex)
	end

	-- 这种机制下大招怒气要先减掉
	if params ~= Fight.skillIndex_small then
		if not self.controler:isTowerTouxiAndFirstWaveRound() then
			if operationInfo.type == Fight.operationType_artifactSKill then
				-- 缓存当前的怒气状态
				self.controler.energyControler:cacheEnergy(hero, operationInfo.skillId)
				self.controler.energyControler:useEnergy(hero:getEnergyCost(operationInfo.skillId), camp)
			else
				-- 缓存当前的怒气状态
				self.controler.energyControler:cacheEnergy(hero)
				self.controler.energyControler:useEnergyByHero(hero)
			end 
		end
	end

	-- 插入某个操作序列
	local _insertOneOperationInfo = function( )
		table.insert(orderArr,operationInfo )
	end
	--如果是模拟跑的 直接在这里执行下一次攻击
	if Fight.isDummy then
		return self:checkAttack(operationInfo)
	else
		-- 正在释放神力之中
		if self.controler.artifactControler:cheskIsAttacking() then
			-- 检查一下追进度的问题
			self:checkNeddQuickOrGet()
			return
		end
		-- 正在刷怪中不直接释放
		if self._isrefreshing then
			return
		end
		--如果当前是正在攻击中
		if self.attackingHero  then
			-- 标记为等待放大招（只有放大招才会在有攻击人物的时候收到消息）
			hero.isWaiting = true

			-- 如果正在放的是小技能而且必须是 没有缓存操作 则直接播大招
			local currentSkill = self.attackingHero.currentSkill
			-- 暗改
			if timely and (currentSkill and currentSkill.skillIndex == Fight.skillIndex_small and self.attackingHero ~= hero )
				and self.attackNums == lastOperationInfoNums
				and not self.attackingHero:getOnePet()  and params ~= Fight.skillIndex_small   -- 攻击者没有宠物
				then
				-- 小技能不被加入队列
				-- 满足加速条件加速并且返回等待
				-- 计算加速帧数
				local lastFrame = currentSkill:getSkillFrame()
				local nowFrame = self.attackingHero:getCurFrame()
				local diffFrame = lastFrame - nowFrame
				
				if diffFrame > 5 then
					echo("加速帧数",diffFrame)
					self.controler:setLastSpeedUpFrame(diffFrame)
				end
			end

			return
		end
		--如果是不在回合中的 
		if not self.isInRound then
			return
		end

		self:checkAttack(operationInfo)
	end
end
-- 更新操作序列池(返回false说明此时不能读取操作)
function LogicalControlerHandle:updateHandleInfo(info)
	local keyIdx = "p"..info.index
	if self.handleOperationInfo[keyIdx] then
		echo("操作序列已经存在",info.index)
		return false
	end
	self.handleOperationInfo[keyIdx] = info --将操作存起来
	local startIdx = self.currentHandleIndex == 0 and 1 or self.currentHandleIndex
	-- 更新收到的最大连续的操作序列数
	for i=startIdx,info.index do
		if not self.handleOperationInfo["p"..i] then
			break
		else
			self.lastCacheHandleIndex = i
		end
	end
	if self.lastCacheHandleIndex < info.index then
		echo("说明操作不连续，需要在下一帧重新请求操作",self.lastCacheHandleIndex,info.index,startIdx)
		self._needReGetOperation = true
		return false
	else
		self._needReGetOperation = false
	end
	return true
end

--收到一个操作指令
function LogicalControlerHandle:receiveOneHandle( handleInfo )
	local index = handleInfo.index
	-- self.operationMap[tostring(index)] = params
	--如果是正常的攻击性操作
	
	--如果是收到以前的操作了 也不执行
	if index <= self.lastCacheHandleIndex then
		echo("收到以前操作了,last:",self.lastCacheHandleIndex,"index:",index)
		return
	end
	if not self:updateHandleInfo(handleInfo) then
		self:checkNeddQuickOrGet()
		return
	end

 	if self:getBattleState() == Fight.battleState_wait then
 		echo ("如果是在等待阶段，不能执行")
 		dump(handleInfo,"handole")
 		-- self.lastCacheHandleIndex = handleInfo.index --这条消息要缓存一起才对
 		self:checkNeddQuickOrGet()
 		return
 	end
 	-- if self.controler:checkIsInProgress() then
 	-- 	-- 如果是在快进游戏中，则不需要再做处理
 	-- 	return
 	-- end

 -- 	local currIdx = self.lastCacheHandleIndex+1
 -- 	--如果当前执行的操作序列是跳过了  直接return
 -- 	if handleInfo.index > currIdx and handleInfo.index > self.currentHandleIndex +1 then
 -- 		-- dump(handleInfo,"s===")
 -- 		echo("操作序列跳过",handleInfo.index,currIdx,self.currentHandleIndex)
 -- 		self:checkNeddQuickOrGet()
	-- 	return
	-- end

	if handleInfo.attackNums == 0 then
		handleInfo.attackNums = nil
	end

	-- self.lastCacheHandleIndex = handleInfo.index

	-- 收到认输数据的时候，直接执行(或者仙界对决主动退出的接口)
	if handleInfo.type == Fight.handleType_giveUp or 
		handleInfo.type == Fight.handleType_guildBossQuit then
		-- 如果此时是加载阶段，则等待加载完成后调用
		if not self.controler:checkIsRealInit() then
			self.controler:pushOneCallFunc(10*GameVars.GAMEFRAMERATE, c_func(self.doReceiveHandle, self),{handleInfo})
		else
			return self:doReceiveHandle(handleInfo)
		end
		return
	end

	if handleInfo.index == self.currentHandleIndex +1 then
		return self:doReceiveHandle(handleInfo)
	else
		--那么说明我落后了,需要直接读取操作信息
		-- self:readSaveHandle()
		echo("__ 我的操作落后了,",self.controler:getUserRid(),self.currentHandleIndex,handleInfo.index)
		self:checkNeddQuickOrGet()
	end
end
-- 检查是否需要追进度、或者重新获取操作序列
function LogicalControlerHandle:checkNeddQuickOrGet()
	if self._needReGetOperation then
		self.controler.server:getOperationByStartIdx(self.lastCacheHandleIndex+1)
	else
		if not self.controler:checkIsInProgress() then
			echo("如果中途的操作序列连续，并且不是追进度，则需要追进度")
			self.controler:runGameToTargetRound()
		end
	end
end

--执行收到的操作 
function LogicalControlerHandle:doReceiveHandle( handleInfo )
	--走到这里来了就必须得让handleIndex 加一次
	
	if not handleInfo.tag then
		--这些操作只错 index校验就可以了
		if handleInfo.type == Fight.handleType_changePos or handleInfo.type == Fight.handleType_changeHero
			or handleInfo.type == Fight.handleType_state  or handleInfo.type == Fight.handleType_beforeChange
			or handleInfo.type == Fight.handleType_beforeChangePos or handleInfo.type == Fight.handleType_enterBeforeChange
			or handleInfo.type == Fight.handleType_auto or handleInfo.type == Fight.handleType_recommendSpirit
			or handleInfo.type == Fight.handleType_endSpiritRound or handleInfo.type == Fight.handleType_enterSpiritRound
			or handleInfo.type == Fight.handleType_useSpirit or handleInfo.type == Fight.handleType_formationInBattleBegin
			or handleInfo.type == Fight.handleType_buff
			then
			handleInfo.tag = tostring(handleInfo.index)
		else
			handleInfo.tag = handleInfo.wave.."_".. handleInfo.round.. "_"..handleInfo.type.."_"..tostring(handleInfo.info).. "_".. tostring(handleInfo.timely)
		end
	end
	echo("doReceiveHandle,currentHandleIndex:",self.currentHandleIndex,"targetIndex",handleInfo.index,"_tag",handleInfo.tag,
		"lastCacheHandleIndex:",self.lastCacheHandleIndex)

	-- 去重处理
	if self.handleRunTagMap[handleInfo.tag] then
		self.currentHandleIndex = self.currentHandleIndex +1
		echo("_这个tag 处理过了---",handleInfo.tag)
		-- dump(handleInfo,"__handleInfo")
		return false,false
	end
	-- echoError ("----sss",self.controler.__currentWave)
	local cWave = self.controler.__currentWave

	-- 不是上下线操作再做判断/自动战斗也不校验时机（在回合结束后 roundCount增加前点自动战斗，复盘和实际有差异）
	-- 认输也不校验
	if handleInfo.type ~= Fight.handleType_state and handleInfo.type ~= Fight.handleType_giveUp and
	 handleInfo.type ~= Fight.handleType_guildBossQuit then
		--判断是否是废弃的操作
		if handleInfo.wave < cWave then
			echo("_是废弃操作",handleInfo.wave,cWave)
			-- dump(handleInfo,"__handleInfo")
			self.handleRunTagMap[handleInfo.tag] = true
			self.currentHandleIndex = self.currentHandleIndex +1
			return false,false
		elseif  handleInfo.wave == cWave  then
			--如果回合数小于了 也返回false
			if(handleInfo.round < self.roundCount) then
				echo("回合数小了 handleInfo.round",handleInfo.round,self.roundCount)
				self.handleRunTagMap[handleInfo.tag] = true
				self.currentHandleIndex = self.currentHandleIndex +1
				-- dump(handleInfo,"__handleInfo")
				return false ,false
			elseif handleInfo.round > self.roundCount then
				-- if handleInfo.type == Fight.handleType_startRound and
				-- 	handleInfo.round == self.roundCount + 1 then
				-- 	self.lastCacheHandleIndex = handleInfo.index
				-- 	echo("如果此操作是回合开始，则不再校验")
				-- end
				echo("回合数大了 break,handleInfo.round",handleInfo.round,self.roundCount)
				return false, true
			else
				--回合数相等 那么就需要判断攻击数是否OK
				local attackNums = handleInfo.attackNums
				local roundAtkNums = self:getRoundHandleNums()
				if not attackNums or attackNums == 0 then
					attackNums =  roundAtkNums
				else
					if attackNums < roundAtkNums then
						echoError("___为什么这个攻击数会小 而且没有做---判定失效")
						-- dump(handleInfo,"__handleInfo")
						self.currentHandleIndex = self.currentHandleIndex +1
						self.handleRunTagMap[handleInfo.tag] = true
						return false,false
					elseif attackNums > roundAtkNums then
						echo("___不该在这次攻击---")
						return false, true
					end
				end
			end

		else
			-- echoError("__为什么波数超过的行为会在这里做")
			echo("波数不相等 break,handleInfo.round",handleInfo.round,self.roundCount,cWave)

			return false,true
		end
	end


	-- dump(handleInfo,"__handleInfo")
	self.currentHandleIndex = self.currentHandleIndex +1
	self.handleRunTagMap[handleInfo.tag] = true
	--是否中断攻击
	local isOffAttack =false
	local info = ""
	if handleInfo.info then
		info = json.decode(handleInfo.info)
	end
	if BattleControler:checkIsMultyBattle() then
		local time = nil
		if not Fight.isDummy and handleInfo.expireTime and handleInfo.expireTime > 0 then
			time = math.ceil((handleInfo.expireTime - TimeControler:getBattleServerTime()*1000)/1000)
			if time <= 0 or time > 99 then
				time = math.ceil((handleInfo.expireTime - handleInfo.stateStartTime)/1000)
			end
			if time <= 0 then
				time = 0
			end
			if time >= 99 then
				time = 99
			end
		end
		self:updateWaitTimeByHandle(time)

	end
	if handleInfo.type == Fight.handleType_battle or handleInfo.type == Fight.handleType_battle_small then

		self:checkAccelerator(handleInfo,info) --加速器校验
		--如果当前有正在攻击的对象
		-- if self.attackingHero then
		-- 	return
		-- end
		self:updateBuZhenStatus(true,handleInfo.rid) --收到自动战斗的信息的时候，布阵状态也是true
		self:checkFormationStatus(handleInfo.rid)

		--判断这个操作是否有效
		if self:checkOneAttackCanRun(info) then
			-- 仙界对决点大招的时候，需要检查回合伤害buff增加
			if BattleControler:checkIsCrossPeak() and
				handleInfo.type == Fight.handleType_battle then
				self.controler.cpControler:checkAddCrosspeakRoundBuff(self.currentCamp)
			end
			self:updateBattleState(Fight.battleState_battle)
			self:insertOneHandle(info)
			isOffAttack = true
		end
	elseif handleInfo.type == Fight.handleType_auto  then -- 自动战斗
		self:checkFormationStatus(handleInfo.rid)
		if info.auto == 1 then
			self:updateBuZhenStatus(true,handleInfo.rid) --收到自动战斗的信息的时候，布阵状态也是true
			self:setAutoFight(true, handleInfo.rid)

			-- 自动战斗时，同步怒气值
			self.controler.energyControler:setEntire(Fight.camp_1,info.e1)
			self.controler.energyControler:setEntire(Fight.camp_2,info.e2)

			-- 回合中才需要进行攻击行为
			if self.currentCamp == self.ridCamp[handleInfo.rid] and self.isInRound then
		        self:doAutoFightAi(handleInfo.rid)
		        isOffAttack = true
		    end
			--快速战斗出结果
			if self.controler:chkIsWaitToQuick() then
				local auto =self:getAutoState()
				self.controler:checkToQuickGame()
			end
		else
			self:setAutoFight(false, handleInfo.rid)
			isOffAttack = false
		end
		-- dump(info,"what???-----")
	--如果是超时 那么让所有人都自动战斗
	elseif handleInfo.type == Fight.handleType_overTime then
		self:changeAllBuZhenStatus(true)
		--取消布阵操作
		self:cancleFormation()

		self:doAutoFightAi(handleInfo.rid,nil,true)
		isOffAttack = true
	elseif handleInfo.type == Fight.handleType_state  then --上下线操作
		
		-- echo("__handleType_state___",tostring(info),Fight.lineState_lineOff,self.currentCamp == self.ridCamp[handleInfo.rid])
		--如果当前回合是在自己回合掉线的时候  才中断攻击
		if tostring(info.state) == Fight.lineState_lineOff and self.currentCamp == self.ridCamp[info.rid]  then --and self.currentCamp == 1
			
			self:setUserLineState(tostring(info.state),info.rid)
			-- self:doAutoFightAi(handleInfo.rid,nil,true)
			-- isOffAttack = true
			isOffAttack = false
		else
			self:setUserLineState(tostring(info.state),info.rid)
			isOffAttack = false
		end

	--如果是 换位
	elseif handleInfo.type == Fight.handleType_changePos  then
		--做位置交换功能
		--如果布阵状态是true了  那么不能换位. 当网络不好的时候 会先收到对方发了一条超时信息 在发换位信息
		if self:getBuzhenState(handleInfo.rid) then
			return
		end
		self:exchangeHeroPos(info.posRid,info.pos,info.camp)
	elseif handleInfo.type == Fight.handleType_buff then
		--试炼buff相关操作
		self:onTrialDrop(info,handleInfo.rid)
	elseif handleInfo.type == Fight.handleType_bzFinish then
		isOffAttack = self:checkBZFinish(handleInfo,info)
		echo(isOffAttack,"____布阵完成操作")
	elseif handleInfo.type == Fight.handleType_endRound then
		echo("回合结束")
		if self.attackingHero then
			echo("回合结束消息,此时不能就回合结束，需要将还有的操作都做完才可以结束")
			return self:insertOneHandle({camp=info.camp,type=Fight.operationType_endRound})
		end
		self:doEndRound(info.camp)
		isOffAttack = true
	elseif handleInfo.type == Fight.handleType_startRound then
		-- 单人的时候、判定进入倒计时开始时间、多人进入服务器推送进入的状态
		self:updateStartRoundStatus(info)
		-- isOffAttack = true
	--换灵
	elseif handleInfo.type == Fight.handleType_changeElement then
		self.controler.formationControler:changeElement(info)
	elseif handleInfo.type == Fight.handleType_changeFinish then
		-- echo("换人完成",handleInfo.rid,"____")
		-- echo("仙界对决换人完成--，等待进入布阵状态")
		self:crossPeakChange2BuZhen()
	elseif handleInfo.type == Fight.handleType_changeHero then
		-- echo("巅峰竞技场上下阵")
		self:updateBattleState(Fight.battleState_changePerson)
		self:crossPeakChange(info)
	-- elseif handleInfo.type == Fight.handleType_sureBattle then
	-- 	isOffAttack = self:crossPeakSureHandle(info)
	elseif handleInfo.type == Fight.handleType_battle_bzStart or
		handleInfo.type == Fight.handleType_formationInBattleBegin then
		-- echo("仙界对决战中布阵")
		if BattleControler:checkIsCrossPeak() then
			self:doCrossPeakUpHeroFirst(info.camp)
		elseif BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
			self:doEndSpiritRound()
			self.controler.formationControler:setBZUserRid(info.rid)
			isOffAttack = true
		end
		self:updateBattleState(Fight.battleState_formation)
		self:chkMultyBattleStatus()
	elseif handleInfo.type == Fight.handleType_battle_changeStart then
		-- echo("仙界对决战中换人")
		self:updateBattleState(Fight.battleState_changePerson)
		self:chkMultyBattleStatus()
	elseif handleInfo.type == Fight.handleType_enterSelectCard then
		-- 仙剑对决进入战前bp
		self:updateBattleState(Fight.battleState_selectPerson)
		self.controler.cpControler:enterCrossPeakBP()
	elseif handleInfo.type == Fight.handleType_selectCard then
		-- echo("仙界对决战前bp")
		self:updateBattleState(Fight.battleState_selectPerson)
		self.controler.cpControler:updateCrossPeakBPData(info)
		return false,true
	elseif handleInfo.type == Fight.handleType_enterBeforeChange then
		echo("仙界对决进入战前上下人")
		self:updateBattleState(Fight.battleState_formationBefore)
		self.controler.cpControler:enterCrossPeakBeforeChange(info)
		return false,true
	elseif handleInfo.type == Fight.handleType_beforeChangePos  then
		-- echo("仙界对决战前位置交换")
		self:updateCrossPeakBeforeChangePos(info)
	elseif handleInfo.type == Fight.handleType_beforeChange then
		-- echo("仙界对决战前上下人")
		self:updateCrossPeakBeforeChange(info)
	elseif handleInfo.type == Fight.handleType_giveUp then
		echo("仙界对决",info.team,"方认输")
		self.controler.cpControler:updateCrossPeakGiveUp(info)
		return false,true
	elseif handleInfo.type == Fight.handleType_autoFlag then
		echo ("玩家托管了===",info.rid,"托管状态:",info.setAuthFlag)
		self.controler:updateUserAuthFlag(info)
	elseif handleInfo.type == Fight.handleType_enterSpiritRound then
		echo("进入神力阶段")
		self:enterSpiritRound(info)
		return false,true
	elseif handleInfo.type == Fight.handleType_useSpirit then
		echo("使用神力")
		if self:getBattleState() == Fight.battleState_spirit then
			self.controler.artifactControler:useOneSpirit(info)
		else
			echoError ("当前不是神力阶段，why")
		end
		return false,true
	elseif handleInfo.type == Fight.handleType_recommendSpirit then
		echo("推荐神力")
		self.controler.artifactControler:updateRecommendSpirit(info)
	elseif handleInfo.type == Fight.handleType_guildBossQuit then
		self.controler:userQuickGuildBoss(info)
	elseif handleInfo.type == Fight.handleType_endSpiritRound then
		echo("把神力界面关掉，然后等待服务器推送进入战中布阵116")
	end
	return isOffAttack
end

--获取某个位置操作
function LogicalControlerHandle:getOneHandle( camp,index )
	local countStr = tostring(self.roundCount)

	local tempmap1 = self.operationMap[self.controler.__currentWave]
	if not tempmap1 then
		echo("_has no operation:",self.controler.__currentWave)
		return nil
	end
	local tempmap2 = tempmap1[countStr]
	if not tempmap2 then
		return nil
	end
	return tempmap2.order[index]
end

--获取当前回合的操作数量
function LogicalControlerHandle:getRoundHandleNums(  )
	local countStr = tostring(self.roundCount)
	local tempTb = self.operationMap[self.controler.__currentWave]
	if not tempTb then
		return 0
	end
	tempTb = tempTb[countStr]
	if not tempTb then
		return 0
	end
	return #tempTb.order
end


--从当前操作数开始 获取最大的连续数
function LogicalControlerHandle:getContinueIndex( )
	-- local targetIndex = self.currentHandleIndex
	-- local mapObj = self.handleOperationInfo
	-- local fromIndex = targetIndex+1
	-- for i=fromIndex,9999 do
	-- 	--循环遍历的函数一定要注意性能,所以这里一定要先把 self.handleOperationInfo 用一个local 变量缓存起来
	-- 	local index = mapObj["p"..i]
	-- 	if not index  then
	-- 		break
	-- 	end
	-- 	targetIndex = i
	-- end
	-- if self.lastCacheHandleIndex ~= targetIndex then
	-- 	echoError("为什么操作序列不一致 快去去查看日志",self.lastCacheHandleIndex,targetIndex)
	-- 	if not Fight.isDummy then 
	-- 		local str = json.encode(self.handleOperationInfo)
	-- 		LogsControler:saveLocalLog("操作序列str"..str)
	-- 	end
		
	-- end
	return self.lastCacheHandleIndex
end





--读取合适的操作 返回攻击行为的操作信息
function LogicalControlerHandle:readSaveHandle(  )

	local wave = self.controler.__currentWave
	local round = self.roundCount
	local attackNums = self.attackNums

	local attackInfo = nil
	
	echo(wave,round,attackNums,self.currentHandleIndex,"____aaaaaaaaaaareadSaveHandleaaaaaaa")
	-- dump(self.handleOperationInfo,"self.handleOperationInfo=====")
	local startIndex = self.currentHandleIndex
	for i=startIndex+1,9999 do
		local info = self.handleOperationInfo["p"..i]
		if info then
			echo(info.wave == wave , info.round == round ,"_aaaaasas_")
			-- if info.wave == wave and info.round == round then
				-- self.currentHandleIndex = i
			if info.index ~= self.currentHandleIndex +1  then
				-- dump(info,"__handleInfo")
				echo("___操作中断了-是否需要等待服务器操作回来----info.index",info.index,self.currentHandleIndex)
				return  nil
			end
			
			-- dump(info,"___readSaveHandle"..info.wave.."_"..info.round.."_"..info.attackNums.."_"..info.index)
			local isOffAttack,isBreak =  self:doReceiveHandle(info)
			if isOffAttack then
				attackInfo = info
				break
			end
			if isBreak then
				break
			end

		else
			break
		end
	end

	return  attackInfo

end


-- 自由点追进度
function LogicalControlerHandle:startCatchProgress(  )
	--如果不是空闲状态 是不能readSavehandle的,否则 执行顺序会出错
	local bState = self:getBattleState()
	if bState == Fight.battleState_battle or bState == Fight.battleState_wait   then
		echo ("_当前状态不是闲置状态,不能readSaveHandle",self:getBattleState())
		return 
	end
	local result = self:readSaveHandle()
	--这里要根据状态判断下 接下来的行为,前提是没有中断攻击
	if result then
		return
	end
	--如果是攻击过程中中断了 那么就 需要继续判断
	if self.attackNums ~=0 then
		echo("___checkNextHandle------",self.attackingHero)
		--必须是当前没有正在攻击的人我才去做一次
		if not self.attackingHero then
			self:checkNextHandle(self.currentCamp)
		end
		
	end

end



----------------玩家状态属性管理----------------------
----------------玩家状态属性管理----------------------
----------------玩家状态属性管理----------------------

--设置或者取消自动 true  是自动  false  是不自动
function LogicalControlerHandle:setAutoFight( value ,rid )
	rid = rid or self.controler:getUserRid()

	for k,v in pairs(self.userStateMap) do
		if k == rid then
			v.auto = value
			v.roundAuto = value
			
			if value then
				v.buzhenState = value
			end
		end
	end

	-- 如果更新的是自己的状态，同时更新缓存
	if rid == self.controler:getUserRid() then
		self.controler:updateGameAuto(value, true)
	end

	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CHANGEAUTOFIGHT)
end


-- 设置某一阵营当前回合为自动战斗状态
function LogicalControlerHandle:setCampRoundAuto(camp)
	for k,v in pairs(self.userStateMap) do
		for m,n in pairs(self.ridCamp) do
			if n == camp and m == k then
				v.roundAuto = true
				break
			end
		end
	end
end

-- 检查某一阵营的自动战斗状态
function LogicalControlerHandle:chkCampIsAutoFight(camp)
	-- 如果某一阵营内有人没有自动战斗、则返回false
	for k,v in pairs(self.ridCamp) do
		if v == camp and not self:getAutoState(k) then
			return false
		end
	end
	return true
end

--获取自动战斗状态
function LogicalControlerHandle:getAutoState(rid )
	rid = rid  or self.controler:getUserRid()
	for k,v in pairs(self.userStateMap) do
		if k == rid then
			return v.auto
		end
	end
	return false
end


-- 判断是否是所有人都自动战斗
function LogicalControlerHandle:checkIsAllAutoAttack(camp)
	if camp == 2 then
		return true
	end
	if self.controler:checkCanHandle() then
		--如果点击自动按钮 获取超时了
		for k,v in pairs(self.userStateMap) do
			if v.lineState == Fight.lineState_lineOn and v.roundAuto == false then
				return false
			end
		end
	end
	return true
end

-- pangkangning 2018.08.23 添加rid参数 代表这个英雄是属于某玩家的(试炼多人战斗中一方自动战斗)
--判断是否是自动
function LogicalControlerHandle:checkIsAutoAttack( camp ,rid)
	-- if Fight.isDummy then
	-- 	return true
	-- end
	if not BattleControler:checkIsCrossPeak() then
		if camp == 2 then
			return true
		end
	else
		for k,v in pairs(self.ridCamp) do
			if v == camp then
				rid = k
				break
			end
		end
	end
	-- --如果是回放的
	-- if self.controler.replayGame > 0 then
	-- 	return true
	-- end
	rid = rid or self.controler:getUserRid()
	if self.controler:checkCanHandle() then
		--如果点击自动按钮 获取超时了
		for k,v in pairs(self.userStateMap) do

			if k == rid then
				if v.roundAuto then
					return true
				--离线状态也是自动战斗
				elseif v.lineState == Fight.lineState_lineOff  then
					-- 多人都是手动战斗
					if BattleControler:checkIsMultyBattle() then
						return false
					else
						return true
					end
				end
				return false
			end
		end

	else
		return true
	end

	return false
end


--设置玩家在线或者离线状态
function LogicalControlerHandle:setUserLineState( state,rid )
	local info = self.userStateMap[rid]
	info.lineState = state
	-- echo("__收到玩家掉线信息,rid:",rid,state)
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_LINESTATE_CHANGE)
end

