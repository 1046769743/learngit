--
-- Author: xd
-- Date: 2015-11-27 18:47:13
--
--战斗服务器交互
local BattleServer = class("BattleServer")


BattleServer.battleId = nil 		--战斗id
BattleServer.handleIndex = 0 		--操作序列
BattleServer.serverHandleIndex = 0 		--服务端的操作序列(用于校验顺序性)
BattleServer._delayTime = 0			--切后台返回延迟的时间


function BattleServer:ctor( controler )
	self.controler = controler
	self.battleId = nil
	EventControler:addEventListener("notify_battle_battleStart_5036", self.notify_battle_battleStart_5036, self)
	EventControler:addEventListener("notify_battle_recevieHandle_5040", self.notify_battle_recevieHandle_5040, self)
	EventControler:addEventListener("notify_battle_recevieHBattleResult_5048", self.notify_battle_recevieHBattleResult_5048, self)
	EventControler:addEventListener("notify_battle_crossPeak_battleResult_5922", self.notify_battle_battleResult, self)
	EventControler:addEventListener("notify_battle_loadingRes_timeOut_5034", self.notify_battle_loadingRes_timeOut_5034, self)
	EventControler:addEventListener("notify_guild_activity_round_account_5644", self.notify_guild_activity_round_account_5644, self)
	-- 战斗操作通知
	EventControler:addEventListener("notify_crosspeak_battleOperation", self.notify_crosspeak_battleOperation, self)

	EventControler:addEventListener("notify_battle_guildBoss_battleResult_6240", self.notify_battle_battleResult, self)
	
	-- 调试指令
	EventControler:addEventListener("notify_debug_command", self.notify_debug_command, self)
	
	EventControler:addEventListener(SystemEvent.SYSTEMEVENT_APP_ENTER_FOREGROUND,self.resumeBattle,self)
		

	
	self.battleId = BattleControler._battleInfo.battleId
	echo("__server battleId",self.battleId)
	self.handleIndex = 0
	self.serverHandleIndex = 0
	self._delayTime = 0
	self.__rewardInfo = nil
	self.cacheHandleInfo = {}
end


----------------------------------处理通知-----------------------------------
-- 收到战斗结果的广播
function BattleServer:notify_battle_recevieHBattleResult_5048( e )
	if not self.controler then
		return
	end
	local rt = e.params.params.rt

	-- self.controler:processGameResult(rt)

	-- BattleControler:recvGameResult()
end
function BattleServer:notify_battle_battleResult( e )
	if not self.controler then
		return
	end
	local data = e.params.params.data
	if data then
		if (not Fight.isDummy) or  (not IS_CHECK_DUMMY) then 
			if not self.controler._hasSaveBattleInfo then
				BattleControler:saveBattleInfo()
			end
			
		end
		-- 这里推送的是结果[胜利还是失败]
		local rewardData = {}
	    if BattleControler:checkIsCrossPeak() then
		    rewardData.crossPeak = data
		    rewardData.result = data.result
	    elseif BattleControler:getBattleLabel() == GameVars.battleLabels.guildBossGve then
		    rewardData = data
		    rewardData.result = Fight.result_win --共闯秘境永远是胜利的
	    end
	    self.controler:showMultyReward(rewardData)
	    self.__rewardInfo = data
		-- self.controler:processGameResult(rt)
		ServerRealTime:handleClose()--关闭连接
	end


-- 	-- BattleControler:recvGameResult()
end


function BattleServer:notify_battle_reward(e)
	echo("___________战斗结果______notify_battle_reward")
	if not self.controler then
		echo("________(720)还没开始战斗,服务器发来 战斗结果 信息")
		--return 
	end

	BattleControler:showReward( e.params )
end

function BattleServer:notify_battle_recevieHandle_5040( e )
	echo("__收到操作通知---------notify_battle_recevieHandle_5040--------")
	-- dump(e.params,"_notify_battle_recevieHandle_5040____")
	-- 当前我还没有加载完成，不需要做任何操作
	if self.controler.resIsCompleteLoad == false then
		echo("我的还没有加载完成-该操作消息会通过加载完成的时候发给我5040")
		return
	end
	local params = e.params.params.data

	-- 只要收到这几条通知，就说明不需要重发了
	if params.type == Fight.handleType_endRound or 
		params.type == Fight.handleType_battle_small or
		params.type == Fight.handleType_battle then
		self.cacheHandleInfo = {}
	end
	self.controler.logical:receiveOneHandle(params)
	-- local nextIdx = self.controler.logical:getContinueIndex() + 1
	-- -- echo("s======",self.serverHandleIndex,params.index)
	-- if nextIdx < params.index then
	-- 	-- dump(params,"params======")
	-- 	-- self:reGetOperation(nextIdx)--重新获取操作序列
	-- 	echo ("操作序列不一致,需要重新获取操作序列",nextIdx,params.index)
	-- 	return
	-- elseif nextIdx > params.index then
	-- 	echo("_这是已经废弃的操作")
	-- 	dump(params,"____已经处理过的操作")
	-- 	return
	-- else
	-- 	-- 这里做消息的校验
	-- 	--收到一个操作通知
	-- 	self.controler.logical:receiveOneHandle(params)
	-- end
end


-- 掉线与上线推送
function BattleServer:notify_battle_userDrop_740(e)
	local netData = e.params.params.data
	if not self.controler then
		return
	end
end

-- 仙界对接战斗推送消息
function BattleServer:notify_crosspeak_battleOperation(e)
	if self.controler.resIsCompleteLoad == false then
		echo("我的还没有加载完成-该操作消息会通过加载完成的时候发给我")
		return
	end
	local netData = e.params.params
	if self.controler then
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CROSSPEAK_RESETWAITTIME)
		self.controler.logical:receiveOneHandle(netData)
	end
end
-- 仙界对决战斗结束推送消息
function BattleServer:notify_crosspeak_battleEnd(e)
	local netData = e.params.params
	if self.controler then
		self.controler.logical:receiveOneHandle(netData)
	end
end


------------------处理操作---------------
------------------处理操作---------------
------------------处理操作---------------

--发送一个点击操作
--[[
	info.camp, info.index, info.type, info.params
	info.timely（操作为点击攻击时此参数有效，标记是否是在其他人小技能出手时的出手）
]]
function BattleServer:sendOneClickHandle( info)
	local lastTime
	if self.controler then
		lastTime = self.controler.logical:getSkillFrameTime()
	end
	if info.params == 2 then
		self:sendOneHandle(Fight.handleType_battle_small, info,lastTime)
	else
		self:sendOneHandle(Fight.handleType_battle, info,lastTime)
	end
end

--发送自动战斗操作
-- {auto},自动1 非自动0
function BattleServer:sendOneAutoHandle( info )
	self:sendOneHandle(Fight.handleType_auto, info )
end

--[[
	发送换位操作
	把 heroRid 换位到 posIndex posIndex 位置的人是 posRid（用于做校验）
]]
-- {rid,pos,posRid,camp}
function BattleServer:sendChangePosHandle( info)
	self:sendOneHandle(Fight.handleType_changePos ,info)
end
-- 发送试炼战斗使用buff操作
-- hType:1 开始拖拽，2 取消拖拽，3对某个heroRid使用buff
function BattleServer:sendHeroPickBuffHandle(info)
	self:sendOneHandle( Fight.handleType_buff ,info)
end
-- 仙界对决布阵开始
-- {camp}
function BattleServer:sendBZStartHandle(info)
	self:sendOneHandle( Fight.handleType_battle_bzStart ,info)
end

-- 仙界对决换人开始
-- {camp}
function BattleServer:sendChangeStartHandle(info)
	self:sendOneHandle( Fight.handleType_battle_changeStart ,info)
end
-- 发送布阵完成操作 
-- {camp}
function BattleServer:sendBuZhenFinishHandle(info)
	self:sendOneHandle(Fight.handleType_bzFinish,info)
end
-- 发送换人完成操作
-- {change,camp} change默认0，超时1
function BattleServer:sendChangeHeroFinishHandle(info)
	info = info or {}
	self:sendOneHandle(Fight.handleType_changeFinish,info)
end

-- 仙界对决进入战前上下人阶段
function BattleServer:sendEnterBeforeChangeHandle(info)
	info = info or {}
	self:sendOneHandle(Fight.handleType_enterBeforeChange,info)
end
-- 仙界对决战前换人完成
function BattleServer:sendBeforeChangeSureHandle( info )
	info = info or {}
	self:sendOneHandle(Fight.handleType_beforeChangeSure,info)
end
-- 战前换人
-- {rid,partnerId[0代表下阵，1代表主角],posNum[0~6]}
function BattleServer:sendBeforeChangeHandle(info)
	self:sendOneHandle(Fight.handleType_beforeChange,info)
end
-- 仙界对决战前换位
-- {rid,type[1:奇侠,2:五灵(暂无)],posSource,posTarget,posRid}
function BattleServer:sendBeforeChangePosHandle(info)
	self:sendOneHandle(Fight.handleType_beforeChangePos,info)
end
-- 仙界对决进入bp阶段
function BattleServer:sendEnterEnterBPHandle(info)
	info = info or {}
	self:sendOneHandle(Fight.handleType_enterSelectCard,info)
end
-- 仙界对决bp选人或者法宝
-- {teamId,selectList{cardId,cardType,teamId}}
function BattleServer:sendBPHandle( info )
	self:sendOneHandle(Fight.handleType_selectCard,info)
end
-- 仙界对决认输{team}
function BattleServer:sendGiveUpHandle( info )
	self:sendOneHandle(Fight.handleType_giveUp,info)
end
-- 仙界对决托管
function BattleServer:sendAutoFlagHandle( info )
	self:sendOneHandle(Fight.handleType_autoFlag,info)
end
-- 发送多人同步校验数据[测试接口]{logsInfo =}
function BattleServer:sendDebugCommand( info )
	local params = {checkInfo = json.encode(info)}
	ServerRealTime:sendRequest(params,MethodCode.battle_debugCommand,nil,true)
end


--[[
	发送换灵操作
	info = {
		element
		round
		pos
		camp
	}
]]
function BattleServer:sendChangeElementHandle(info)
	self:sendOneHandle(Fight.handleType_changeElement, info)
end
-- 回合结束
function BattleServer:sendEndRoundHandle(info)
	local lastTime
	if self.controler then
		lastTime = self.controler.logical:getSkillFrameTime()
		--更新回合开始帧
		self.controler.logical:updateSkillStartFrameIdx()
	end
	self:sendOneHandle(Fight.handleType_endRound, info,lastTime)
end
-- {camp,nextState[4换人阶段，2回合阶段],canCtrl[0不能控制，回合时间缩短，1可以控制]} 回合结束
function BattleServer:sendStartRoundHandle(info)
	local lastTime
	if self.controler then
		lastTime = self.controler.logical:getSkillFrameTime()
	end
	self:sendOneHandle(Fight.handleType_startRound, info,lastTime)
end
-- 巅峰竞技场上下阵操作
-- {rid,pos,hid,camp,ctype} ctype:0下阵  1上阵
function BattleServer:sendChangeHandle( info )
	self:sendOneHandle(Fight.handleType_changeHero, info)
end
-- *****###### 共闯秘境相关
-- 战前加载完成
function BattleServer:sendGuildBossReady( )
	self:sendOneHandle(Fight.handleType_guildBossReady,{})
end
function BattleServer:sendEnterSpiritRoundDebug( info )
	self:sendOneHandle(Fight.handleType_enterSpiritRound, info)
end
-- 神力阶段结束
function BattleServer:sendEndSpiritRound( )
	self:sendOneHandle(Fight.handleType_endSpiritRound, {})
end
-- {sid神力id,rid =发送的角色,pos换位神力新位置,posRid触摸的角色,camp阵营}
function BattleServer:sendUseOneSpirit(info)
	self:sendOneHandle(Fight.handleType_useSpirit, info)
end
-- 推荐神力
function BattleServer:sendRecommendOneSpirit(info)
	self:sendOneHandle(Fight.handleType_recommendSpirit, info)
end
-- 主动退出共闯秘境
function BattleServer:sendGuildBossQuit( info )
	self:sendOneHandle(Fight.handleType_guildBossQuit, info)
end

--处理请求相关
--发送一个操作 lastTime:小技能大招对应的奇侠帧数转换为的时间(毫秒)
function BattleServer:sendOneHandle( type,info,lastTime)
	if self.controler.__gameStep == Fight.gameStep.result then
		echo ("已经出战斗结果了")
		return
	end
	if self.controler:isReplayGame() then
		echo("__复盘为什么会走这")
		return
	end
	local rid = BattleControler.gameControler:getUserRid()
	-- if self.controler.logical:chekIsJiaSu() and type == Fight.handleType_battle_small then
	-- 	echoTag('tag_battle_kaijiasu',4,"战斗中玩家开加速器了",rid)
	-- 	return 
	-- end
	-- local rid = UserModel:rid()
	self.handleIndex = self.handleIndex + 1

	local handleInfo = {
		type = type,
		rid = rid,
		info = json.encode(info),
		index = self.controler.logical.lastCacheHandleIndex+1,
		battleId = self.battleId,
		wave = self.controler.__currentWave,
		round = self.controler.logical.roundCount,
		lastTime = lastTime, 
	}
	--如果是多人战斗 那么取消attackNums
	if BattleControler:checkIsMultyBattle() then
		handleInfo.attackNums = nil
	else
		handleInfo.attackNums = self.controler.logical:getRoundHandleNums()
	end


	if Fight.isDummy or BattleControler:checkIsPVP() or 
		--如果不是追进度期间
		(self.controler:isQuickRunGame() and  (not self.controler.reloadData.isQuick)  and 
			handleInfo.type ~= Fight.handleType_giveUp and 
			handleInfo.type ~= Fight.handleType_guildBossQuit) 
		then
		self.controler.logical:receiveOneHandle(handleInfo)
	else
		-- if self.controler.gameMode == Fight.gameMode_pvp  then
		if self.controler.gameMode == Fight.gameMode_pve  then
			-- ui点击的时候，不是在主循环里面，可以直接返回
			self.controler.logical:receiveOneHandle(handleInfo)
		else
			if self.__rewardInfo then
				echo("已经出战斗结果了===")
				return
			end
			if BattleControler:checkIsMultyBattle() then
				if handleInfo.lastTime then
					local tmpInfo = table.copy(handleInfo)
					tmpInfo.lastTime = 100
					table.insert(self.cacheHandleInfo,tmpInfo)
					local count = #self.cacheHandleInfo
					if count > 1 then
						echo("有未发送的缓存，不能再发了",count)
						if count >= 3 then
							self.cacheHandleInfo = {} --防止积压太多操作
						end
						return
					end
				end
			end
			ServerRealTime:sendRequest(handleInfo,MethodCode.battle_battleOperation,c_func(self.onSendHandleBack,self),false,true,false )
			-- ServerRealTime:sendRequest(handleInfo,MethodCode.battle_handle_5037,c_func(self.onSendHandleBack,self),true,true,false )
		end
	end

end
-- 仙界对决超时发送战斗结算请求
function BattleServer:sendCrossPeakTimeOut(battleId,callBack)
	local params = {battleId = battleId}
	Server:sendRequest(params,MethodCode.battle_crosspeak_result_timeout_5001 , callBack)
end
-- 
function BattleServer:onSendHandleBack( result )
	if result.error then
		echo("_判断是否战斗结束----")
		self:checkBattleOver(result.error)
		local code = tonumber(result.error.code)
		if code == ErrorCode.battle_open_speed then
			if not self._hasShowTip then
				WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2030"))
				self._hasShowTip = true
			end
			self:delaySendOneHandle()
		end
	else
		table.remove(self.cacheHandleInfo,1) --移除第一个操作
	end
end
-- 延迟发送操作
function BattleServer:delaySendOneHandle()
	if #self.cacheHandleInfo > 0 then
		local tmpInfo = self.cacheHandleInfo[1]
		-- dump(tmpInfo,"重发消息====")
		local tempFunc = function (  )
			ServerRealTime:sendRequest(tmpInfo,MethodCode.battle_battleOperation,
									c_func(self.onSendHandleBack,self),false,true,false )
		end
		WindowControler:globalDelayCall(tempFunc, 1.5)
	end
end
-- 多人战斗结束
function BattleServer:sendBattleEnd( resultInfo )
	local params = {battleResultClient = resultInfo}
	ServerRealTime:sendRequest(params,MethodCode.battle_battleEnd,c_func(self.onBattleEndBack,self),true,true,false )
end
function BattleServer:onBattleEndBack( result )
	if result.error then
		self:checkBattleOver(result.error)
	end
end

-- 后台切换回来重新请求进度
function BattleServer:resumeBattle(event)
	self.controler:ingoreCheckSeized(true)
	-- dump(event.params)
-- - "<var>" = {
-- -     "dt"   = 1 --秒
-- -     "time" = 1503652761
-- -     "usec" = 886285
-- - }
	self._delayTime = event.params.dt
	if BattleControler:checkIsMultyBattle() then
		if self.controler.resIsCompleteLoad == false then
			echo("我的还没有加载完成-该操作消息会通过加载完成的时候发给我")
			return
		end
		self:getOperationByStartIdx(self.controler.logical:getContinueIndex() + 1)
	end
end

-- 退出战斗
function BattleServer:quitBattle(battleId)
	echo("753___主动退出战斗,放弃战斗")
	if battleId then
		ServerRealTime:sendRequest({battleId = battleId},MethodCode.battle_user_quit_battle_753,c_func(self.quitBattleBack,self) )
	else
		ServerRealTime:sendRequest({battleId = self.battleId},MethodCode.battle_user_quit_battle_753,c_func(self.quitBattleBack,self) )
	end
end
-- 退出战斗返回
function BattleServer:quitBattleBack(result)
	echo("754__主动退出战斗,服务器返回",result.result.serverInfo.serverTime)
	--dump(result.result)
	if self.controler then
		self.controler:closeRewardWindow()
	end
end
-- 仙界对决获取进度
function BattleServer:getOperationByStartIdx( startIdx )
	echo ("仙界对决获取进度====",startIdx)
	-- 已经在请求进度了，不需要再发消息了
	if ServerRealTime:checkHasMethod( MethodCode.battle_battleGetOperation ) then
		return
	end

	local params = {startIndex = startIdx}
	ServerRealTime:sendRequest(params,MethodCode.battle_battleGetOperation,function( result )
		self.controler:ingoreCheckSeized(false)
		if not result.result then
			self:checkBattleOver(result.error)
			return
		end
		local operation = result.result.data.operation
		if not operation then
			return
		end
		self:runGameToTargetRoundByBattleInfo(operation)
	end )
end

-- -- 巅峰竞技场消息顺序不一致导致需要重新获取消息 endIdx -1 表示从startIdx 开始获取到最新的操作
-- function BattleServer:reGetOperation( startIdx,endIdx )
-- 	if not endIdx then
-- 		endIdx = -1
-- 	end
-- 	local req = {battleId = self.battleId,startIndex = startIdx,endIndex = endIdx}
-- 	local tempFunc = function (  )
-- 		ServerRealTime:sendRequest(req,MethodCode.battle_get_operation,c_func(self.onOperationBack,self) )
-- 	end
-- 	WindowControler:globalDelayCall(tempFunc, 0.01)
-- end
-- function BattleServer:onOperationBack( result )
-- 	if not result.result then
-- 		echo("____判断战斗是否结束----")
-- 		self:checkBattleOver(result.error)
-- 		return
-- 	end

-- 	local operation = result.result.data.operation
-- 	if not operation then
-- 		return
-- 	end
-- 	self:runGameToTargetRoundByBattleInfo(operation)
-- end

--判断是否退出战斗
function BattleServer:checkBattleOver( errorInfo )
	local code = tonumber(errorInfo.code)
	if code == ErrorCode.battle_not_exisit or code == ErrorCode.battle_lose 
		or code == ErrorCode.battle_id_illegal or code ==ErrorCode.battle_lose
	 then
		-- 战斗已经结束
		WindowControler:showTips( GameConfig.getLanguage("#tid_battle_6"))
		BattleControler:onExitBattle()
	end
end

--玩家离开战斗
function BattleServer:notify_battle_user_quit_battle_756( e )
	local netData = e.params.params.data	
	local rid = BattleControler.gameControler:getUserRid()
	if netData.rid == rid then
	-- if netData.rid == UserModel:rid() then
		return
	end
end
--多人布阵loading超时
function BattleServer:notify_battle_loadingRes_timeOut_5034( e )
  local netData = e.params.params.data
  dump(netData,"netData-----")
  -- if self.controler then
  --   self.controler:initFirst()
  -- end
end
-- 仙盟GVE食材刷新需要战斗立即退出
function BattleServer:notify_guild_activity_round_account_5644(e)
	-- 如果此时正在加载中、或者没有实例化controler 则不处理
	if BattleControler:getBattleLabel() == GameVars.battleLabels.guildGve then
		if self.controler and self.controler:checkIsRealInit() and self.controler.__gameStep ~= Fight.gameStep.result then
			self.controler:checkToQuickGame()
		end
		if self.controler and not self.controler:checkIsRealInit() then
			self.controler:set2Quick(true)
		end
	end
end


--战斗开始
function BattleServer:notify_battle_battleStart_5036( e )
	echo("notify_battle_battleStart_5036________battleid_",self.battleId)

	EventControler:dispatchEvent(BattleEvent.BATTLEEVENT_START_BATTLE)
	if self.controler then
		if self.controler.resIsCompleteLoad == true  then
			self.controler:initFirst()
		-- else
		-- 	self.controler.isReceiveStart = true
		end
	end
end



---  重连过程749---750---
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
----------------------------------------------------------------------------------------------------
--通知服务器加载战斗资源完成
function BattleServer:loadBattleResOver()
	if not self.battleId then
		return 
	end
	local idx = self.controler.logical:getContinueIndex()
	echo("5031_资源加载完毕，向服务器发送通知",idx)
	ServerRealTime:sendRequest({startIndex=idx} ,MethodCode.battle_battleReady,c_func(self.loadMultyBattleResOverBack,self) )
	-- ServerRealTime:sendRequest({battleId=self.battleId  } ,MethodCode.battle_loadBattleResOver_5031,c_func(self.loadBattleResOverBack,self) )
end
-- 多人战斗资源加载完成
function BattleServer:loadMultyBattleResOverBack(result)
	local isGameReConnect = self.controler.resIsCompleteLoad
	self.controler.resIsCompleteLoad = true
	if result.result then
		local data = result.result.data
		-- 游戏快进
		if data.operation then
			if not isGameReConnect then
				-- self.controler.logical:updateBattleState(Fight.battleState_none)
			end
			
			self:runGameToTargetRoundByBattleInfo(data.operation)
		else
			if data.state == Fight.battleState_ready then
				-- 战斗准备阶段、等待服务器push战斗21消息
				self.controler.logical:updateBattleState(data.state)
			end
		end

		-- if data.state == Fight.battleState_ready then
		-- 	-- 战斗准备阶段、等待服务器push战斗21消息
		-- 	-- self.controler:initFirst()
		-- 	self.controler.logical:updateBattleState(data.state)
		-- else
		-- 	-- 游戏快进
		-- 	if data.operation then
		-- 		dump(data.operation,"===boosp")
		-- 		self.controler.logical:updateBattleState(Fight.battleState_none)
		-- 		self:runGameToTargetRoundByBattleInfo(data.operation)
		-- 	end
		-- end
	else
		if result.error and result.error.code == 1009 then
			-- 一会再请求进入战斗
			self.controler:pushOneCallFunc(10, function( )
				self:loadBattleResOver()
			end)
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_battle_7"))
			BattleControler:onExitBattle()
		end
	end
end

-- -- 资源加载完毕,可能会带着时间片信息和操作
-- function BattleServer:loadBattleResOverBack( result )
-- 	self.controler.resIsCompleteLoad = true
-- 	if result.result then
-- 		if result.result.data then
-- 			local battleInfo = result.result.data.battleInfo
-- 			echo("资源加载完成服务器返回当前多人阶段-----",battleInfo.period)
-- 			if battleInfo.period == 3 then --1布阵阶段，2准备阶段，3战斗阶段
-- 				self.controler:initFirst()

-- 				--不是后台切回来的，走这里的数据
-- 				self:runGameToTargetRoundByBattleInfo(battleInfo.operation,true)
-- 			else
-- 				echo("还没有到战斗阶段")
-- 				return
-- 			end
-- 		end
-- 	else
-- 		WindowControler:showTips(GameConfig.getLanguage("#tid_battle_7"))
-- 		BattleControler:onExitBattle()
-- 	end
-- end
function BattleServer:runGameToTargetRoundByBattleInfo(operation)
	
	if self.controler then
		if operation then
			local count = 0
			local opera = self.controler.logical.handleOperationInfo
			local maxIndex = self.controler.logical.lastCacheHandleIndex
			for k,v in pairs(operation) do
				-- local opkey = k
				local opkey = "p"..v.index
				-- if opera[opkey] then
				-- 	echo(opkey,"_exist_opkey__",self.controler.logical.currentHandleIndex)
				-- else
				-- 	echo(v ,opkey,"_aaaa___",self.controler.logical.currentHandleIndex)
				-- end
				
				if not opera[opkey] then
					local op 
					if type(v) == "string" then
						op = json.decode(v)
					else
						op = v
					end
					maxIndex = math.max(maxIndex,op.index)
					opera[opkey] = op
				end
				count = count + 1
			end
			local starIdx = self.controler.logical.currentHandleIndex  
			starIdx = starIdx == 0 and 1 or starIdx
			for i = starIdx,maxIndex do
				if not opera["p"..i] then
					echoError ("操作序列不连续===",i,BattleControler._battleInfo.battleId)
					return
				end
			end
			echo("----------maxIndex,",maxIndex,count,self.controler.logical.lastCacheHandleIndex)
			self.controler.logical.lastCacheHandleIndex = maxIndex
			
			if count == 0 then
				echo("没有操作序列，不需要同步")
				return
			end
		end
		-- 快进游戏
		self.controler:runGameToTargetRound()
	end
end


-- 后台返回请求数据
function BattleServer:onResumeBattle( result )
	-- dump(result,"result----")
	if result.result then
		-- dump(result.result)
		local data = result.result.data
		if data and data.battleInfo then
			if data.battleInfo.isFinish == 0 then
				self:runGameToTargetRoundByBattleInfo(data.battleInfo.operation)
				echo("快进游戏")
			else
				-- 战斗已经结束
				WindowControler:showTips( GameConfig.getLanguage("#tid_battle_6"))
				BattleControler:onExitBattle()
			end
		end
	end
end




--上报战斗结果
function BattleServer:submitGameResult( result )

	echo("battle_sumbitResult_5045_ 上报战斗结果",frame,result)
	if self.__rewardInfo then
		echo("_______服务器已经广播过来战斗结果,奖励数据了")
		return
	end

	Server:sendRequest({result = result, battleId = self.battleId  } ,MethodCode.battle_sumbitResult_5045, nil, true ) 
	--Server:sendRequest({fragment = frag, rt = result, frame = frame,battleId =self.battleId  } ,MethodCode.battle_reveiveBattleResult_717 )
end
-- function BattleServer:sendThrow()
-- 	ServerRealTime:sendRequest({battleId = self.battleId},MethodCode.battle_throw,nil,true,true,false )
-- end


---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------
---------------------------------------------------------------------------


---------------- debug command start =====

-- 接受调试指令
function BattleServer:notify_debug_command( e )
	local netData = e.params.params
	local checkInfo = json.decode(netData.checkInfo)
	-- 检查logsInfo是否一致
	-- dump(checkInfo,"s======")
	if self.controler then
		self.controler:checkDebugLogsInfo(checkInfo)
	end
end
---------------- debug command end =====


function BattleServer:deleteMe()
	EventControler:clearOneObjEvent(self)
	FightEvent:clearOneObjEvent(self)
	self.controler = nil
end


return BattleServer
