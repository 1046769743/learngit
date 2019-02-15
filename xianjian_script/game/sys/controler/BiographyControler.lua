--[[
	奇侠传记控制器
	author: lcy
	add: 2018.7.20
]]

BiographyControler = BiographyControler or {}

BiographyControler._cacheBattlePartnerId = nil -- 用于进战斗前缓存当前的partnerId
BiographyControler._isInBiography = false -- 是否在奇侠传记中

-- 注册固定事件（需要长期监听的）
function BiographyControler:registerFixedEvent()
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onBattleClose, self)
end

-- 注册所有做任务时需要接收的事件
function BiographyControler:registerEvent()
	-- 注册收事件
	EventControler:addEventListener(BiographyUEvent.EVENT_PLOT_FINISH,self.onGetFinishMessage, self)
	EventControler:addEventListener(BiographyUEvent.EVENT_COLLECT_FINISH,self.onGetFinishMessage, self)
	EventControler:addEventListener(BiographyUEvent.EVENT_POSITION_FINISH,self.onGetFinishMessage, self)
	EventControler:addEventListener(BiographyUEvent.EVENT_GAME_FINISH,self.onGetFinishMessage, self)
end

-- 清除所有事件
function BiographyControler:unregisterEvent()
	-- 注册收事件
	EventControler:removeEventListener(BiographyUEvent.EVENT_PLOT_FINISH,self.onGetFinishMessage, self)
	EventControler:removeEventListener(BiographyUEvent.EVENT_COLLECT_FINISH,self.onGetFinishMessage, self)
	EventControler:removeEventListener(BiographyUEvent.EVENT_POSITION_FINISH,self.onGetFinishMessage, self)
	EventControler:removeEventListener(BiographyUEvent.EVENT_GAME_FINISH,self.onGetFinishMessage, self)
end

-- 传入地标信息，返回是否有任务，如果有还会返回对应的接引NPC
function BiographyControler:checkMapHasBiography(mapId,order)
	-- 临时
	-- if true then
	-- 	return true,"1102"
	-- end

	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	-- 说明根本没任务
	if not partnerId then return end

	local map = FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "map")
	-- 是目标地标
	if map[1] == tostring(mapId) and map[2] == tostring(order) then
		return true,FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "npcid")
	end

	return false,nil
end

-- 写进入一个剧情的方法？
function BiographyControler:enterCurBiography(noanim)
	-- 能走到这里证明有任务，取任务信息（战斗回来后可能没有）
	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	if not partnerId then return end
	
	local animId = FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "animId")
	local frame = FuncBiography.getBiographyNodeValueByKey(curNodeId, step, "frame")

	-- 进入前开启注册的事件
	self:startWork()

	-- 进入前屏蔽点击
	AnimDialogControl:disabledUIClick()
	local function doEnter()
		-- 关掉以前的
		AnimDialogControl:destoryDialog()
		-- 打开屏蔽
		AnimDialogControl:resumeUIClick()

		self._isInBiography = true
		-- 先写一个单纯进入
		AnimDialogControl:showPlotDialog(animId, function()
			self._isInBiography = false
			-- 完成之后关掉注册的事件
			self:stopWork()
		end,nil,nil,nil,nil,"window")

		-- 跳到对应的帧
		local label,_ = AnimDialogControl:getLabelAndFrame()
		AnimDialogControl:doJumpFrame(label, frame)
	end

	-- 有切场效果
	if not noanim then
		local enterAnim = FuncArmature.createArmature("UI_zhuanchangyun",nil, false, GameVars.emptyFunc)
		self.enterAnim = enterAnim

		-- 由于没有容器只能直接放在scene上
		local scene = WindowControler:getCurrScene()
		scene._root:addChild(enterAnim, 1000)
		enterAnim:pos(GameVars.UIOffsetX,GameVars.height)

		enterAnim:registerFrameEventCallFunc(30, nil, doEnter)

		enterAnim:doByLastFrame(false, false, function()
			-- 删掉
			if self.enterAnim and not tolua.isnull(self.enterAnim) then self.enterAnim:removeFromParent() end
			self.enterAnim = nil		
		end)
	else
		doEnter()
	end
end

-- 时间和类型的映射表
local eventT = {
	[BiographyUEvent.EVENT_PLOT_FINISH] = 1,
	[BiographyUEvent.EVENT_COLLECT_FINISH] = 2,
	[BiographyUEvent.EVENT_POSITION_FINISH] = 5,
	[BiographyUEvent.EVENT_GAME_FINISH] = 6,
}

-- 收到完成事件的方法
function BiographyControler:onGetFinishMessage(event)
	local eventName = event.name
	local params = event.params
	-- 获取当前事件
	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	-- 没有任务，返回
	if not partnerId then return end

	local bioEvent = FuncBiography.getEventsByNodeAndStep(curNodeId,step)

	local flag = false -- 标记是否完成
	-- 类型对应
	if eventT[eventName] == bioEvent.type then
		-- 需要进一步检查的类型
		if eventName == BiographyUEvent.EVENT_PLOT_FINISH then
			-- ID满足
			if tostring(params.plotId) == tostring(bioEvent.param2) then
				flag = true
			end
		elseif eventName == BiographyUEvent.EVENT_GAME_FINISH then
			-- 比较subtype
			if tostring(params.subtype) == tostring(bioEvent.subtype) then
				flag = true
			end
		else
			flag = true
		end
	end

	-- 发完成事件
	if flag then
		BiographyServer:finishTask(curNodeId, function(data)
			if data.result then
				local reward = data.result.data.reward
				if not empty(reward) then
					WindowControler:showTutoralWindow("CompScrollReward", reward)
				end
			else
				echoError("完成任务失败")
			end
		end)
	end
end

-- 进战斗的返回
function BiographyControler:doBattleActionCallBack(event)
	if event.result ~= nil then
		-- 先关闭剧情编辑器
		AnimDialogControl:destoryDialog()
		if event.result.data then
			local serviceData = event.result.data.battleInfo
			local battleInfo = BattleControler:turnServerDataToBattleInfo(serviceData)
			BattleControler:startBattleInfo(battleInfo)
		else
			echoError("奇侠传记战斗，没有返回数据")
		end
	end
end

-- 进战斗方法
function BiographyControler:enterBattle(eventId)
	-- 校验一下是否是战斗
	local partnerId,curNodeId,step = BiographyModel:getCurrentTaskInfo()
	if not partnerId then
		echoError("奇侠传记步骤发生错误，请检查资源和配表或任务进度",partnerId,curNodeId,step)
		return
	end
	local bioEvent = FuncBiography.getEventsByNodeAndStep(curNodeId,step)
	if not bioEvent then
		echoError("奇侠传记未找到对应事件",partnerId,curNodeId,step)
		return
	end
	if bioEvent.type ~= 4 then
		echoError("奇侠传记此事件非战斗类型",bioEvent.hid)
		return
	end

	self._cacheBattlePartnerId = partnerId

	-- 取主线的阵容
	BiographyServer:enterBattleEvent(eventId,TeamFormationModel:getFormation(FuncTeamFormation.formation.pve),c_func(self.doBattleActionCallBack,self))
end

-- 返回进战斗时缓存的伙伴ID
function BiographyControler:getCacheBattlePartnerId()
	return (self._cacheBattlePartnerId or "5033")
end

-- 战斗结束了，检查恢复动画
function BiographyControler:onBattleClose()
	if BattleControler:cheIsBiographyBattle() then
		-- 先这样处理看下行不行
		self:enterCurBiography(true)
	end
end

function BiographyControler:startWork()
	self:registerEvent()

	FuncArmature.loadOneArmatureTexture("UI_zhuanchangyun", nil, true)
end

function BiographyControler:stopWork()
	self:unregisterEvent()

	if self.enterAnim and not tolua.isnull(self.enterAnim) then self.enterAnim:removeFromParent() end

	FuncArmature.clearOneArmatureTexture("UI_zhuanchangyun",true)
end

-- 是否在传记任务中
function BiographyControler:isInBiograpTask()
	return self._isInBiography
end

return BiographyControler