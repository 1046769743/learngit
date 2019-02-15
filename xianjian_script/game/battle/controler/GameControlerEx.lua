
--
-- Author: xiangdu
-- Date: 2017-06-01 16:01:28gameMode
--
local Fight = Fight
-- local BattleControler = BattleControler


GameControlerEx = class("GameControlerEx",GameControler)

GameControlerEx.isPlayAnimDialog = false

function GameControlerEx:ctor( ... )
	GameControlerEx.super.ctor(self,...)
	if Fight.isDummy then
		return
	end
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ONSERVER_CONNECT, self.onServerConnect, self)
end


--战斗重连上了
function GameControlerEx:onServerConnect( event )
	
	if not self.resIsCompleteLoad then
		echo("在重连的过程中资源还没加载完毕--")
		return
	end
	echo("_______重连上了")

	--直接发送资源加载完毕的消息.等待客户端去处理
	self.server:loadBattleResOver()

end


--[[
展示立绘对话或者是动画
@time为时机 
1：标识人物出厂前
2: 人物出场但是还没有开打
3:战斗结束后
4:一方出手后
]]
function GameControlerEx:checkDialogAndAnimation( time,callBackName,params,callBakParams,wave)
	-- body
	--echo(time,callBackName,params,callBakParams,"===============")
	if wave == nil then wave = self.__currentWave end
	local info = self.levelInfo:sta_storyPlot(wave)

	 -- echo("战斗中的剧情对话的--------",time)
	 -- dump(info)

	local callFunc 
	if callBackName then
		if type(callBackName) == "string" then
			callFunc = self[callBackName]
		else
			callFunc = callBackName
		end
		
	end

	callBakParams = callBakParams or {}
	local callBack = function (  )
		-- 做容错 此时战斗可能已经销毁了
		if self.layer then
			self.layer:setGameVisible(true)
		end
		if self._isDied then
			return
		end
		self.isPlayAnimDialog = false
		callFunc(self,unpack(callBakParams) )
	end

	

	local chkInfo = function (time)
		for k,v in pairs(info) do
			if tostring(v.time) == tostring(time) then
				return v
			end
		end
		return nil
	end


	--dump(info)
	--1,5,plotId;
	-- if info ~= nil and (BattleControler._battleInfo.withStory or self:chkHasGuide() ) then
	-- 去掉 self:chkHasGuide() 暂时不确定为何这里需要引导的判定（否则，旧的回忆会因为这里而播动画）
	local bInfo = self.levelInfo:getBattleInfo()
	if info ~= nil and (bInfo.withStory) then
		--有对话形式
		local item = chkInfo(time)
		if item~=nil then
			if item.type == 1 then
				--立绘对话
				if item.time ==1 or item.time == 2 or item.time == 3 then
					--隐藏游戏场景
					
					--echo("剧情对话-------1111111111111112222222222222222333333333333")
					PlotDialogControl:showPlotDialog(item.plotid, callBack)
					return
				end
				if item.time == 4 and item.params == params then

					PlotDialogControl:showPlotDialog(item.plotid, callBack)
					--echo("剧情对话4444444444444444444444444===============")
					return
				end
				--第几个回合回合后执行
				if item.time == 5 and item.params == params then
					PlotDialogControl:showPlotDialog(item.plotid, callBack)
				end
			else
				--2,1,101010,0;2,3,101011,0;
				--动画展示
				if item.time == 1 or item.time == 3 then
					--这里先处理战斗前和战斗后，其他时机暂时不处理
					--AnimDialogControl:init() 
					--echoError("战前或者战后剧情",BattleControler:chkCurRaidJuQingFinshed(),"===")
					if BattleControler:chkCurRaidJuQingFinshed() and item.time == 1 then
						callBack()
					else
						-- 添加开战动画参数
						AnimDialogControl:showPlotDialog(item.plotid, callBack,bInfo.raidId,item.time,nil,nil,"battle",item.time == 1)	
						self.isPlayAnimDialog = true
						-- 剧情宝箱
						local rewardData = WorldServer:getExtraBonus()
						if rewardData then
							AnimDialogControl:animDialogBoxReward( rewardData )
						end
						-- 做容错 此时战斗可能已经销毁了
						if self.layer then
							self.layer:setGameVisible(false)
						end
					end
					return
				else
				end
			end
		end
	end
	--如果没有找到，则直接执行回调方法
	callBack()
end



--[[
试炼中强制杀死某个怪物
]]
function GameControlerEx:killOneEnemyByTrial( v )
	if v then
		v:startDoDiedFunc()
	end
end



--[[
在回合结束后执行 下一个回合开始
]]
function GameControlerEx:insertPlotDialogBeforStarRound()
	if self.logical.currentCamp == 1 then
		self:playSwitchRoundEff()
	end
	self.logical:startRound()	
end
-- 获取额外加成的buff(流血、灼烧伤害提升[万分比])
function GameControlerEx:getExpecialBuffArr( )
	return self._expecialBuffArr
end

-- 修改model的基础属性(通常是进战斗的buff、锁妖塔，共享副本等)
function GameControlerEx:changeModelDataValue( model,buffAttr,isDebuff)
	local attConvert = FuncBattleBase.getAttributeData(buffAttr.key)
	if attConvert then
		local kName = attConvert.keyName
		if kName == Fight.value_buffBleeding or 
		kName == Fight.value_buffBurn then
			echo("流血或灼烧加成走额外的逻辑")
			if not self._expecialBuffArr then
				self._expecialBuffArr = {}
			end
			local isHave = false
			for k,v in pairs(self._expecialBuffArr) do
				if v.kName == kName then
					isHave = true
					break
				end
			end
			-- 没有才会加、这个不会叠加(注意、因为不是加在人身上的,以后要改叠加，得改这个机制)
			if not isHave then
				local tmpTbl = table.copy(buffAttr)
				tmpTbl.kName = kName
				table.insert(self._expecialBuffArr,tmpTbl)
			end
		else
			local value = buffAttr.value
			if isDebuff then
				value = -value
			end
			model:changeDataValue(kName,value,buffAttr.mode )
		end
	else
		dump(buffAttr,"数据======")
		echoError("进战斗buff数值配置错误，请找对应玩法的策划-----")
	end
end

--===========================================================================================
--                     序章、引导相关begin
--============================================================================================

--[[
(开始自动战斗)关闭所有引导相关
]]
function GameControlerEx:closeTutorial( ... )
	-- self:showGuideArrow(false)
	-- self:setWeakGuideCount(false)
	-- 时间到了关闭的引导一定是弱引导，强制引导会暂停时间
	TutorialManager.getInstance():hideBattleWeakGuide()
	-- 恢复UI
	self.gameUi:resumeUIClick()
end

-- 执行对话调用板子逻辑，与引导结构相同，分开来处理
function GameControlerEx:doRoundStartPlot( step, disableClick, followup )
	if Fight.isDummy then return end
	local callBack = function()
		self:clearOneCallFunc("setDisableUIClick")
		self.__doRoundStartPlot = false
		-- 后续步骤
		-- 配置中不允许出现重复触发的情况
		if followup and followup[1] then
			local nstep = followup[1]
			table.remove(followup,1)

			self:doRoundStartPlot(nstep, FuncGuide.isDisableBattleClick(nstep), followup)
			-- return
		else
			-- 这个模式，阵营1默认重启倒计时，阵营2继续流程
			if self.logical.currentCamp == Fight.camp_1 then
				self:setCountDownPause(false)
				-- 重置倒计时时才恢复自由点击
				self.gameUi:resumeUIClick()
			else
				-- 继续
				self.logical:checkNextHandle(self.logical.currentCamp)
				-- 重置点击
				self.gameUi:resumeUIClick()
			end
		end

		--[[
		-- 重置倒计时
		if FuncGuide.isResetCountDown(step) then
			self:hideUICountDown(false)
			self:setCountDownPause(false)
			-- 重置倒计时时才恢复自由点击
			self.gameUi:resumeUIClick()
		end

		-- 敌人完成后继续攻击
		if FuncGuide.isContinueFight(step) then
			-- 继续
			self.logical:checkNextHandle(self.logical.currentCamp)
		end
		]]
	end
	-- 标记正在进行回合开始前的对话（此时不触发弱引导，但不检查强制引导，两者不应该同时配置）
	self.__doRoundStartPlot = true

	TutorialManager.getInstance():showBattleTutorialLayer(step,callBack)

	self:setDisableUIClick(disableClick)
end

--[[
执行序章的新手引导
]]
function GameControlerEx:doXvZhangTutorial( step ,disableClick, followup)
	-- 引导和序章都跳过时才不做
	if IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()) then return end
	echo("步骤",step)
	local callBack = function (  )
		self:clearOneCallFunc("setDisableUIClick")
		--引导说话完毕接着第三步
		-- echo("引导setp",disableClick,step)
		echo("完成了步骤", step)
		self.__nowTutorialStep = nil
		-- 后续步骤
		-- 配置中不允许出现重复触发的情况
		if followup and followup[1] then
			local nstep = followup[1]
			table.remove(followup,1)

			self:doXvZhangTutorial(nstep, FuncGuide.isDisableBattleClick(nstep), followup)
			-- return
		end
		-- 判断是否有步骤结束触发的内容
		local nstep,nfollowup = FuncGuide.getBattleProcessStepByStepFinish(self.levelInfo.hid, step)

		if nstep then
			self:doXvZhangTutorial(nstep, FuncGuide.isDisableBattleClick(nstep), nfollowup)
			-- return
		end

		-- 配置不了特殊处理
		if step == 20 then
			-- 第20步之后判断是否引导李逍遥从2号位换到1号位
			-- 1号位是主角就换位置
			if self.campArr_1[1].data.isCharacter then
				self:doXvZhangTutorial(21, FuncGuide.isDisableBattleClick(21))
			else
				-- 做介绍
				self:doXvZhangTutorial(22, FuncGuide.isDisableBattleClick(22))
			end
		-- elseif step == 1001 or step == 1002 then
		-- 	-- 停止暂停时间
		-- 	self:setCountDownPause(false)
		elseif step == 23 then
			-- 第23步之后打开换位的限制
			Fight.xvzhangParams.changePos2 = {1,2,3,4,5,6}
		elseif step == 2 then
			-- 第2步之后显示头像
			-- 手动关闭头像显示
			if self.gameUi then
				self.gameUi:setIconViewVisible(true)
			end
			-- 恢复亮暗程度
			if self.viewPerform then
				self.viewPerform:setHeroLightOrDark(self.campArr_1)
			end
		end

		-- 重置倒计时
		if FuncGuide.isResetCountDown(step) then
			-- self:hideUICountDown(false)
			-- 重置到该有的状态
			self.gameUi:updateUIVisibleStatus()
			self:setCountDownPause(false)
			-- 重置倒计时时才恢复自由点击
			self.gameUi:resumeUIClick()
		end
		echo("这里对不对", step, self.logical.currentCamp,FuncGuide.isContinueFight(step))
		-- 敌人完成后继续攻击
		if FuncGuide.isContinueFight(step) then
			-- 继续
			self.logical:checkNextHandle(self.logical.currentCamp)
		end

		-- self.gameUi:resumeUIClick()
	end
	self.__nowTutorialStep = step
	TutorialManager.getInstance():showBattleTutorialLayer(step,callBack)
	-- echo("打印一下",FuncGuide.getBattleFinishMessage(step) == TutorialEvent.TUTORIAL_PARTNER_ATK,FuncGuide.getBattleHeroHid(step))
	-- 判断是不是点人头像的，如果是就获取位置
	if FuncGuide.getBattleFinishMessage(step) == TutorialEvent.TUTORIAL_PARTNER_ATK 
		and FuncGuide.getBattleHeroHid(step)
	then
		local hid = FuncGuide.getBattleHeroHid(step)
		-- 设置新位置
		local pos = self:getPosByHeroHid(hid)
		-- 这里找个人引导，并且改一下指引位置
		TutorialManager.getInstance():setBattleExtraPos(pos)
	end

	self:setDisableUIClick(disableClick)

	-- self:pushOneCallFunc(5, "setDisableUIClick", {disableClick})
end

--设置是否禁掉 uiclick
function GameControlerEx:setDisableUIClick( disableClick )
	if disableClick then
		-- echoError("屏蔽所有点击 ========")
		self.gameUi:disabledUIClick()
	else
		-- echoError("恢复所有点击 ========")
		self.gameUi:resumeUIClick()
	end
end

--[[
	重启倒计时
]]
function GameControlerEx:resetCountDown()
	-- 不好改，强制一下
	self._forceCountDown = true
	if self.gameUi then
		self.gameUi:resetCountDown()
	end
end

-- 加一下暂停倒计时的方法
function GameControlerEx:setCountDownPause(value)
	self.__countDownPause = value
end

-- 隐藏UI倒计时
function GameControlerEx:hideUICountDown(value)
	if self.gameUi then
		self.gameUi:hideOrShowCD(not value)
	end
end

-- 获取是否在暂停中
function GameControlerEx:isCountDownPause()
	return self.__countDownPause
end

-- 获取位置的方法，封装一下
function GameControlerEx:getPosByHeroHid(hid)
	if self.gameUi then
		return self.gameUi:getPosByHeroHid(hid)
	end
end

--[[
检查序章战斗新手引导
在攻击完毕之后的引导
]]
function GameControlerEx:chkIsXvZhangTutorialAtkComp(posIndex,camp,attackNums,wait,switch)
	-- 引导序章都跳过才不检查
	if (IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue())) 
		or Fight.isDummy
		or DEBUG_SERVICES
	then
		return wait,switch 
	end
	
	-- 已经登录了
	if LoginControler:isLogin() then
		-- 如果不在通关这一关，不做任何引导逻辑（主线才有raidId）
		bInfo = self.levelInfo:getBattleInfo()
		local raidId = bInfo.raidId
		if raidId and WorldModel:isPassRaid(raidId) then -- 通关了
			return wait,switch
		end
	end

	-- 不应该有强制引导则正常返回
	if not FuncGuide.hasBattleGuide(self.levelInfo.hid) then return wait,switch end

	local wait = wait
	local switch = switch
	local step = nil
	local disableClick = false
	
	if self:chkIsXvZhang() then
		local round = self.logical.roundCount
		local atkNums = self.logical.attackNums

		if camp == 1 and round == 1 then
			-- 1号位攻击完毕引导放大招
			-- if posIndex == 1 and self.logical.attackNums == 1 then -- 应该不用判断位置
			-- 这里没有用位置用了第几个攻击的人
			if atkNums == 2 then -- 1号位大招完
				wait = true
				-- 特殊处理，弹出战斗
				-- BattleControler:onExitBattle()
				-- 赋值一个战斗结果并且调用战后动画的检查
				-- 延迟一个小时间后结束战斗
				self:pushOneCallFunc(10, function()
					self:setBattleResult(Fight.result_win)
					self:checkDialogAndAnimation(3,"afterCheckReward",0,{})
				end)
			end
		end
	end

	if not self.levelInfo then return wait,switch end

	local key = self.__currentWave .. camp .. self.logical.roundCount .. attackNums
	local step,followup = FuncGuide.getBattleProcessStepByRound(self.levelInfo.hid, key) 
	if step then
		wait = true
		switch = false
		-- 暂停时间
		self:setCountDownPause(true)
		-- 先屏蔽掉点击
		self:setDisableUIClick(true)
		self:pushOneCallFunc(30, c_func(self.doXvZhangTutorial,self), {step,FuncGuide.isDisableBattleClick(step),followup})
	end

	return wait,switch
end

-- 点击布阵后的引导返回是否开始攻击
function GameControlerEx:chkXvZhangTutorialAfterBuzhen()
	local wait = false
	if IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()) then return end

	return wait
end

-- 回合前检查说话，弹板（结构类似引导，但不走同一套配表）
function GameControlerEx:chkRoundStartPlot(wait)
	local result = wait or false
	
	if Fight.isDummy then return result end
	-- 我方自动战斗不显示
	if self.logical:checkIsAutoAttack(Fight.camp_1) 
		or tonumber(LS:prv():get(StorageCode.battle_world_pve_auto,0)) == 1 
	then 
		return result 
	end

	local startRoundPlot = self.levelInfo.startRoundPlot
	if startRoundPlot then
		-- dump(startRoundPlot, "查看转换情况")
		local key = string.format("%s_%s_%s",self.__currentWave,self.logical.currentCamp,self.logical.roundCount)
		if startRoundPlot[key] then
			local steps = table.copy(startRoundPlot[key])
			local step = steps[1]
			table.remove(steps,1)
			-- 需要触发
			self:doRoundStartPlot(step, FuncGuide.isDisableBattleClick(step), steps)

			if self.logical.currentCamp == Fight.camp_1 then
				-- 阵营1暂停倒计时
				self:setCountDownPause(true)
			else
				-- 阵营2停止流程
				result = true
			end
		end
	end

	return result
end

-- 回合开始前的引导
function GameControlerEx:chkXvZhangTutorialRoundStart(wait)
	local result = wait or false

	if (IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()))
		or Fight.isDummy
		or DEBUG_SERVICES
	then
		return result 
	end
	
	-- 序章也在登录之后，修改为非序章中执行下面逻辑 2018.5.24 by ZhangYanguang
	-- 已经登录了
	if not PrologueUtils:showPrologue() and LoginControler:isLogin() then
		-- 如果不在通关这一关，不做任何引导逻辑（主线才有raidId）
		bInfo = self.levelInfo:getBattleInfo()
		local raidId = bInfo.raidId
		if raidId and WorldModel:isPassRaid(raidId) then -- 通关了
			return result
		end
	end

	-- 不应该有强制引导则正常返回
	if FuncGuide.hasBattleGuide(self.levelInfo.hid) then
		if not self.levelInfo then return result end

		local key = self.__currentWave .. self.logical.currentCamp .. self.logical.roundCount .. "0"
		local step,followup = FuncGuide.getBattleProcessStepByRound(self.levelInfo.hid, key) 
		-- echoError("有没有这里",key)
		if step then
			-- 暂停倒计时
			self:setCountDownPause(true)
			-- self:hideUICountDown(true)
			
			self:doXvZhangTutorial(step, FuncGuide.isDisableBattleClick(step), followup)
			-- 阵营2或者登仙台需要等待
			if self.logical.currentCamp == Fight.camp_2 
				or tostring(self.levelInfo.hid) == Fight.xvzhangParams.pvp then
				result = true
			end
		end
	end

	-- 弱引导 阵营2不检查下面的内容 
	if self.logical.currentCamp == Fight.camp_2 then return result end

	if self.__doRoundStartPlot then return result end

	-- 检查弱引导
	if FuncGuide.hasBattleWeakGuide(self.levelInfo.hid) then
		local flag = self:chkWeakGuideFormation()
		if not flag then
			self:chkWeakGuideBig()
		end
	end

	return result
end

--[[
总判断是否是序章
]]
function GameControlerEx:chkHasGuide()
	-- 如果有引导走这个判断
	if FuncGuide.hasBattleGuide(self.levelInfo.hid) then
		return true
	else
		return false
	end
end

-- 检查强制屏蔽头像点击的关卡
function GameControlerEx:chkDisableAtkIcon()
	if self:chkIsXvZhang() then
		return true
	end
	-- 第一关，第二波，需要屏蔽
	if self:chkIsLevel1_1() and self.__currentWave == 2 then
		return true
	end

	return false
end

--[[
检查是否是序章
]]
function GameControlerEx:chkIsXvZhang()
	-- 关闭序章时不检查
	if (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()) then return false end

	if self.levelInfo and tostring( self.levelInfo.hid ) == Fight.xvzhangParams.xuzhang then
		return true
	end
	return false
end

-- 1-1
function GameControlerEx:chkIsLevel1_1()
	-- 关闭引导时不做检查
	if IS_CLOSE_TURORIAL then return false end

	if self.levelInfo and tostring(self.levelInfo.hid) == Fight.xvzhangParams.level1_1 then
		return true
	end

	return false
end

-- 是否是特殊处理的1-2
function GameControlerEx:chkIsLevel1_2()
	-- 关闭引导时不做检查
	if IS_CLOSE_TURORIAL then return false end

	if self.levelInfo and tostring(self.levelInfo.hid) == Fight.xvzhangParams.level1_2 then
		return true
	end

	return false
end

-- 是否是龙幽特殊入场
function GameControlerEx:chkIsLevel_splongyou()
	if self.levelInfo and tostring(self.levelInfo.hid) == Fight.xvzhangParams.level_splongyou then
		return true
	end

	return false
end

-- 是否是赵灵儿特殊入场
function GameControlerEx:chkIsLevel_spzhaolinger()
	if self.levelInfo and tostring(self.levelInfo.hid) == Fight.xvzhangParams.level_spzhaolinger then
		return true
	end

	return false
end

-- 试炼引导buff判断
function GameControlerEx:chkTrialGuideBuff()
	if self:chkTrialGuide() and self.__currentWave == 1 then
		return true
	end

	return false
end

-- 试炼引导
function GameControlerEx:chkTrialGuide()
	-- 关闭引导时不做检查
	if IS_CLOSE_TURORIAL then return false end
	if DEBUG_SERVICES then return false end
	
	if self.levelInfo 
		and tostring(self.levelInfo.hid) == Fight.xvzhangParams.trial 
		and tonumber(LS:prv():get(StorageCode.tutorial_first_trial,0)) == 0
	then
		return true
	end
	return false
end

--[[
	检查引导布阵
	返回是否布阵
]]
function GameControlerEx:chkXvZhangBuZhen()
	local round = self.logical.roundCount
	local result = true
	
	if IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()) then return result end

	-- 序章第一个回合不布阵
	-- if self:chkIsXvZhang() and round == 1 then
	-- 	result =  false
	-- end

	return result
end
--[[
	引导影响头像显示
]]
function GameControlerEx:chkXvZhangIconShow()
	local round = self.logical.roundCount
	local atkNums = self.logical.attackNums
	local result = true
	
	if IS_CLOSE_TURORIAL and (DEBUG_SKIP_PROLOGURE or not PrologueUtils:showPrologue()) then return result end


	return result
end
--[[
	引导影响怒气步骤
]]
function GameControlerEx:chkXvZhangEnergy( energy )
	if IS_CLOSE_TURORIAL then return energy end
	local round = self.logical.roundCount

	return energy
end

--[[
是否是引导拖拽
]]
function GameControlerEx:chkYinDaoDrag()
	local levelId = self.levelInfo.hid

	-- 有当前引导步骤
	if self.__nowTutorialStep then
		return FuncGuide.getChangePos(self.__nowTutorialStep) ~= nil
	end

	return false
end

--[[
	引导拖拽终点
]]
function GameControlerEx:getYinDaoDragTarget()
	if self.__nowTutorialStep then
		local pos = FuncGuide.getChangePos(self.__nowTutorialStep)
		return pos[2],pos[1]
	end
end

-- 新的弱引导相关内容
-- 布阵的弱引导 返回是否触发了
function GameControlerEx:chkWeakGuideFormation()
	if IS_CLOSE_TURORIAL or Fight.isDummy then return end
	local result = false

	-- 判断是否是需要弱引导的回合
	local levelId = tostring(self.levelInfo.hid)
	local key = string.format("%s%s%s",self.__currentWave,self.logical.roundCount,"2")
	local step = FuncGuide.getBattleWeakStepByKey(levelId, key)

	if step then
		-- 看是否有人贫血
		local campArr = self.campArr_1
		for _,hero in ipairs(campArr) do
			-- 虚弱状态
			if hero.data:isHealthWeek() then
				-- self.__hasChkWeakGuideFormation = true
				result = true
				break
			end
		end
		if result then
			-- 触发贫血的引导
			self:doXvZhangTutorial(step, FuncGuide.isDisableBattleClick(step))
			-- 暂停时间
			-- self:setCountDownPause(true)
		end
	end

	-- local round = Fight.xvzhangParams.weakGuideLevels[levelId]
	-- local nowRound = self.logical.roundCount

	-- if not self.__hasChkWeakGuideFormation 
	-- 	and round == nowRound
	-- then
	-- 	-- 看是否有人贫血
	-- 	local campArr = self.campArr_1
	-- 	for _,hero in ipairs(campArr) do
	-- 		-- 虚弱状态
	-- 		if hero.data:isHealthWeek() then
	-- 			self.__hasChkWeakGuideFormation = true
	-- 			result = true
	-- 			break
	-- 		end
	-- 	end
	-- 	if result then
	-- 		-- 触发贫血的引导
	-- 		self:doXvZhangTutorial(1002, true)
	-- 		-- 暂停时间
	-- 		self:setCountDownPause(true)
	-- 	end
	-- end

	return result
end

-- 寻找能放大招的人，仅引导用，其他地方不要调用
-- 优先找怒气消耗最低的人
function GameControlerEx:getGuideMaxSkillHero(camp)
	local result = nil
	local campArr = self:getCampArr(camp)
	
	local tempArr = {}
	local energyCost = {}

	for _,hero in ripairs(campArr) do
		-- 能放大招
		if hero.data:checkCanGiveSkill() then
			-- result = hero
			table.insert(tempArr, hero)
			energyCost[hero] = hero:getEnergyCost()
		end
	end

	local function sortFunc(a, b)
		if energyCost[a] == energyCost[b] then
			return a.data.posIndex < b.data.posIndex
		end

		return energyCost[a] < energyCost[b]
	end

	table.sort(tempArr, sortFunc)

	result = tempArr[1]

	return result
end

-- 放大招的弱引导
function GameControlerEx:chkWeakGuideBig()
	if IS_CLOSE_TURORIAL or Fight.isDummy then return end
	local result = false

	-- 判断是否是需要弱引导的回合
	local levelId = tostring(self.levelInfo.hid)
	local key = string.format("%s%s%s",self.__currentWave,self.logical.roundCount,"1")
	local step = FuncGuide.getBattleWeakStepByKey(levelId, key)

	if step then
		-- 看是否有人能放大招
		local tempHero = self:getGuideMaxSkillHero(Fight.camp_1)
		if tempHero then
			-- self.__hasChkWeakGuideBig = true
			result = true
			-- 触发放大招的引导
			self:doXvZhangTutorial(step, FuncGuide.isDisableBattleClick(step))
			-- 暂停时间
			-- self:setCountDownPause(true)

			local pos = self:getPosByHeroHid(tempHero.data.hid)
			-- 这里找个人引导，并且改一下指引位置
			TutorialManager.getInstance():setBattleExtraPos(pos)
		end
	end


	-- -- 判断是否是需要弱引导的关卡
	-- local levelId = tostring(self.levelInfo.hid)
	-- local round = Fight.xvzhangParams.weakGuideLevels[levelId]
	-- local nowRound = self.logical.roundCount
	
	-- if not self.__hasChkWeakGuideBig
	-- 	and round == nowRound
	-- then
	-- 	-- 看是否有人能放大招
	-- 	local tempHero = self:getGuideMaxSkillHero(Fight.camp_1)
	-- 	if tempHero then
	-- 		self.__hasChkWeakGuideBig = true
	-- 		result = true
	-- 		-- 触发放大招的引导
	-- 		self:doXvZhangTutorial(1001, false)
	-- 		-- 暂停时间
	-- 		self:setCountDownPause(true)

	-- 		local pos = self:getPosByHeroHid(tempHero.data.hid)
	-- 		-- 这里找个人引导，并且改一下指引位置
	-- 		TutorialManager.getInstance():setBattleExtraPos(pos)
	-- 	end
	-- end

	return result
end

-- 设置可以开始进行点击人物引导的倒计时
function GameControlerEx:setWeakGuideCount(canCount)
	if canCount then
		self.leftWeakGuideFrame = 5* GameVars.GAMEFRAMERATE
	else
		self.leftWeakGuideFrame = nil
	end
end

function GameControlerEx:showGuideArrow(isShow)
	local pos = nil
	if isShow then -- 不倒计时
		-- self:setWeakGuideCount(false)
		-- 默认提示点第一个人
		-- bug：如果第一个人出现冰冻等状态就会导致指示不对、当自动战斗的时候也需要将其隐藏
		-- 修改，找到一个满怒的人
		if #self.campArr_1> 0 then
			for k,v in pairs(self.campArr_1) do
				if v.data:checkCanGiveSkill() then
					pos = v.myView:convertLocalToNodeLocalPos(self.gameUi, cc.p(0, 0))
					break
				end
			end
		end
		if not pos then return end
		-- pos = self.campArr_1[1].myView:convertLocalToNodeLocalPos(self.gameUi, cc.p(0, 0))
		-- fix
		pos.y = pos.y + 80
	else -- 重置倒计时
		-- self:setWeakGuideCount(true)
	end
	self:setWeakGuideCount(false)
	self.gameUi:showGuideArrow(isShow, pos)
end

-- 检查自动战斗弱引导
-- 功能开启后首次进入pve关卡会显示此内容
function GameControlerEx:chkAutoAttackGuide(gameui, parent)
	-- 2017.12.13 屏蔽此显示
	-- 2018.01.19 打开此显示
	-- if true then return end
	
	if Fight.isDummy then return end
	if not LoginControler:isLogin() then
        return
    end

    -- 有引导的关卡不显示自动战斗气泡
    if self:chkHasGuide() then return end

    -- 主线或精英
    local pve = (BattleControler:getBattleLabel() == GameVars.battleLabels.worldPve)
    
    local isAutoOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.AUTOMATIC)
    local autoGuide = (tonumber(LS:prv():get(StorageCode.tutorial_first_autofight,0)) == 1) -- 是否引导过

    if pve then
    	if isAutoOpen and not autoGuide then
        	LS:prv():set(StorageCode.tutorial_first_autofight,1)
        	-- 如果玩家已经点了自动战斗就不再出了
    		if self.logical:checkIsAutoAttack(Fight.camp_1) or self:getUserAutoStatus() == 1 then return end

        	-- 创建特效
        	-- 是开启关卡的下一关显示特效和气泡
    		local ani = gameui:createUIArmature("UI_zhandou", "UI_zhandou_zidongkaiqi", parent,true,GameVars.emptyFunc)
    		ani:playWithIndex(0,false,true)
    		ani:registerFrameEventCallFunc(40,1,function()
    			ani:pause()

    			-- 如果玩家已经点了自动战斗就不再出了
    			if self.logical:checkIsAutoAttack(Fight.camp_1) or self:getUserAutoStatus() == 1 then return end

    			gameui.panel_qipao:visible(true)
    			gameui.panel_qipao:scale(0)
    			gameui.panel_qipao:runAction(cc.ScaleTo:create(0.1, 1))
    		end)
    	end
    end
end

-- 检查加速按钮
-- 功能开启后首次进入pve关卡会提示
function GameControlerEx:chkSpeedGuide(gameui, parent)
	if Fight.isDummy then return end
	if not LoginControler:isLogin() then
        return
    end

    -- 主线或精英
    local pve = (BattleControler:getBattleLabel() == GameVars.battleLabels.worldPve)

    local isSpeed2Open = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLESPEEDTWO)
    local isSpeed3Open = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.BATTLESPEEDTHREE)
    local nowSpeed = tonumber(LS:prv():get(StorageCode.tutorial_first_battlespeed,0))

    if pve then
       	local flag = nil
       	-- 没引导过2倍速
       	if isSpeed2Open and nowSpeed < 2 then
       		LS:prv():set(StorageCode.tutorial_first_battlespeed,2)
       		flag = 2
       	end
       	-- 没引导过3倍速
       	if isSpeed3Open and nowSpeed < 3 then
       		LS:prv():set(StorageCode.tutorial_first_battlespeed,3)
       		flag = 3
       	end
       	-- 应该引导
       	if flag then
       		-- 如果当前已经是此倍速了
       		if flag == tonumber(LS:prv():get(StorageCode.battle_game_speed,1)) then
       			return
       		end
    			-- 创建特效
           	-- 是开启关卡的下一关显示特效和气泡
       		local ani = gameui:createUIArmature("UI_zhandou", "UI_zhandou_zidongkaiqi", parent,true,GameVars.emptyFunc)
       		ani:playWithIndex(0,false,true)
       		ani:registerFrameEventCallFunc(40,1,function()
       			ani:pause()

       			gameui.panel_qipao2:visible(true)
       			gameui.panel_qipao2:scale(0)
       			gameui.panel_qipao2:runAction(cc.ScaleTo:create(0.1, 1))
       		end)
       	end
    end
end
--===========================================================================================
--                     序章、引导相关end
--============================================================================================

--缓存属性变量相关
function GameControlerEx:getCacheValue( key  )
	return self.cacheValueMap[key]
end

function GameControlerEx:setCacheValue( key,value )
	self.cacheValueMap[key] = value
end

-- 获取当前回合数、有多波怪物的时候，获取上一波怪物总回合+当前回合
function GameControlerEx:getCurrRound( )
	return (self._lastWaveRoundCount + self.logical.roundCount)
end
--[[
	以下方法更多的是在试炼中使用到---试炼-start----
]]
-- 获取当前波怪的最大回合数
function GameControlerEx:getMaxRound( )
	local levelInfo = self.levelInfo
	if levelInfo.staticData[tostring(self.__currentWave)] then
		local maxRound = levelInfo.staticData[tostring(self.__currentWave)].round
		if maxRound then
			return (maxRound*2)--表中填的是大回合数、游戏中分敌我小回合
		end
	end
	if BattleControler:checkIsCrossPeak() then
		return Fight.crosspeakMaxRound
	end
	return Fight.maxRound
end

-- 获取boss剩余血量,返回0表是没获取到boss(boss已经死亡，或者压根就没boss)
function GameControlerEx:getBossHpPercent( )
	for k,v in pairs(self.campArr_2) do
        -- 检查是否有boss
        if v:getHeroProfession() == Fight.profession_boss or v.data:boss() == 1 then
    		local bossHpPer = math.round(v.data:getAttrPercent(Fight.value_health )*100)
    		return bossHpPer
        end
    end
    return 0
end
function GameControlerEx:updateTrialGoldNum(who )
	-- 如果出结果了，那就不计算这个怪了
	if self.__gameStep == Fight.gameStep.result then
		return
	end
	-- 只有是怪物才能获得奖励
	if who.camp == Fight.camp_2 then
		local tRt = self:getTrialResult()
		if who.data:hpCount() > 0  then
			-- boss击杀没有奖励，是走血量的
			-- tRt.bossNum = tRt.bossNum + 1
		else
			tRt.monsterNum = tRt.monsterNum + 1
		end
		if not Fight.isDummy then
			-- 发送事件让UI刷新
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TRIAL_ITEM_UPDATE,who)
		end
	end
end
-- 试炼中当扣一格血的时候是否掉落道具
function GameControlerEx:chkOnHpCountBuckle( who )
	if who.data:hpCount() > 0 then
		if not self._currHpCount then
			self._currHpCount = who.data:hpCount()
			-- 每格血对应的百分比
		    self._HpTmpPer = math.ceil(who.data:maxhp()/self._currHpCount)
		end
		local tmpCount = math.ceil(who.data:hp()/self._HpTmpPer)
		local value = self._currHpCount - tmpCount
		if value > 0 then
			self._currHpCount = tmpCount
			-- 扣血了所以需要更新值
			local tRt = self:getTrialResult()
			-- echo ("b===",self._currHpCount,value,tRt.bossNum)
			tRt.bossNum = tRt.bossNum + value
			if not Fight.isDummy then
				local pos = who.myView:convertToWorldSpace(cc.p(0,0))
				FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TRIAL_ITEM_UPDATE,who)
			end
		end
	end
end
function GameControlerEx:getTrialResult(  )
	if not self._trialResult then
		self._trialResult = {monsterNum=0,bossNum=0}
	end
	return self._trialResult
end
-- 获取对应的单个掉落奖励
function GameControlerEx:getTrialSimpleReward( )
	local p = self.levelInfo.battleInfo.battleParams
	local rewardType,monsterReward,bossReward = FuncTrail.getRewardByTrialId(p.trialId)
	local bCount,mCount = 0,0
	for k,v in pairs(bossReward) do
		local strArr = string.split(v,",")
		bCount = bCount + tonumber(strArr[#strArr])
	end
	for k,v in pairs(monsterReward) do
		local strArr = string.split(v,",")
		mCount = mCount + tonumber(strArr[#strArr])
	end
	return bCount,mCount,rewardType
end
-- 回合刷新题库
function GameControlerEx:loadRefreshQuestions( )
	local tmpArr = self.levelInfo:getRefreshQuestions()
	if tmpArr then
		local rndIdx = BattleRandomControl.getOneRandomInt(#tmpArr+1,1)
		self._rQuestion = table.deepCopy(tmpArr[rndIdx])
		self._rqUseArr = {} --重置答过的位置
		-- 随机一个结果值
		local rIdx = BattleRandomControl.getOneRandomInt(#self._rQuestion.resultRange+1,1)
		table.insert(self._rQuestion.formulary,self._rQuestion.resultRange[rIdx])
	end
end
-- 获取问答现在填的格子的位置(这两方法只在ui用到，用于显示特效位置和用户填充位置)
function GameControlerEx:getQUseArr( )
	return self._rqUseArr or {}
end
function GameControlerEx:resetQUseArr(  )
	if not self._rqUseArr then
		return
	end
	for k,v in pairs(self._rqUseArr) do
		self._rqUseArr[k] = 0
	end
end
-- 使用怒气后更新题库公式
function GameControlerEx:udpateRefreshQuestion(value)
	if self._rQuestion then
		local count = #self._rQuestion.formulary
		for i=1,count,2 do
			local v = self._rQuestion.formulary[i]
			if not v or v == "" then
				self._rQuestion.formulary[i] = value
				if not self._rqUseArr then
					self._rqUseArr = {}
				end
				self._rqUseArr[i] = 1 --ui特效使用
				self:chkRefreshQuestionResult()
				break
			end
		end
	end
end
-- 检查问答结果正确与否 force 强制计算公式结果
function GameControlerEx:chkRefreshQuestionResult(force)
	if self._rQuestion then
		if self._rQuestion.result then
			-- 已经出结果了
			return
		end
		local count = #self._rQuestion.formulary
		for i=1,count,2 do
			local v = self._rQuestion.formulary[i]
			if (not v or v == "") then
				if force then-- 强制出结果了、因为有些数没填，那就是错的
					self._rQuestion.result = Fight.answer_wrong
				end
				-- 未出结果
				FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ANSWER_UPDATE)
				return
			end
		end
		local tmpArr = table.deepCopy(self._rQuestion)
		-- 检查公式，先做乘法公式
		for i=count - 1,2,-2 do
			local v = tmpArr.formulary[i]
			if v == Fight.answer_mul then
				-- 将结果值存入前一个数组内做下一次计算
				tmpArr.formulary[i-1] = tmpArr.formulary[i-1] * tmpArr.formulary[i+1]
				tmpArr.formulary[i+1] = -1 --将已经计算的设置为-1
			end
		end
		-- 算加、减法
		local result = tmpArr.formulary[1] == -1 and 0 or tmpArr.formulary[1]
		for i=2,count - 1,2 do
			local v = tmpArr.formulary[i]
			local value = tmpArr.formulary[i+1]
			if value ~= -1 then
				if v == Fight.answer_add then
					result = result + value
				elseif v == Fight.answer_sub then
					result = result - value
				end
			end
		end
		dump(self._rQuestion.formulary,"原始数据")
		dump(tmpArr.formulary,"计算*后的公式")
		echo ("公式计算的结果是====",result)
		if result == tmpArr.formulary[count] then
			self._rQuestion.result = Fight.answer_right
			-- 答对了给的奖励是击杀小怪的奖励
			local tRt = self:getTrialResult()
			tRt.monsterNum = tRt.monsterNum + 1

			if not Fight.isDummy then
				-- 发送事件让UI刷新
				FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_TRIAL_ITEM_UPDATE)
			end
		else
			self._rQuestion.result = Fight.answer_wrong
		end
		FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_ANSWER_UPDATE)
	end
end
-- 获取题库
function GameControlerEx:getRefreshQuestion( ... )
	return self._rQuestion
end
-- 回合刷新掉落的buff
function GameControlerEx:loadBattleBuffs()
	-- 先移除掉以前刷出来但是没用的buff
	self._dropBuffs = {}
	local rd = math.ceil(self.logical.roundCount/2)
	local buffInfo = self.levelInfo:getBattleBuffByRound(rd)
	if buffInfo then
		for i=1,buffInfo.num do
			local buffRdm = BattleRandomControl.getOneIndexByGroup(buffInfo.buffs,"chance")
			local buffId = buffInfo.buffs[buffRdm].buffId
			-- 多存一个bId，用于校验 1001_1_1
			table.insert(self._dropBuffs,{buffId = buffId,bId = string.format("%s_%s_%s",buffId,i,rd)})
		end
		-- dump(self._dropBuffs,"aa====")
	end
end
function GameControlerEx:getBattleBuffs()
	return self._dropBuffs or {}
end
-- 战斗使用拖拽的buff
function GameControlerEx:useBattleBuff(heroObj,info)
	for k,v in pairs(self._dropBuffs) do
		if v.bId == info.bId then
			heroObj:checkCreateBuff(info.buffId, heroObj,nil)
			self._dropBuffs[k] = nil
			-- table.remove(self._dropBuffs,k)
			-- 发送消息让ui删除
			FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_USE_BUFF,info.bId)
			break
		end
	end
end

--[[
	以上方法更多的是在试炼中使用到---试炼-end----
]]
-- 根据传入的参数修改对应的model的基础数值
function GameControlerEx:changeAttrDataValue(object,buffAttr )
	local attConvert = FuncBattleBase.getAttributeData(buffAttr["key"])
	if attConvert then
		-- object:changeValue( attConvert.keyName,buffAttr.value,buffAttr.mode)
		local kName = attConvert.keyName
		if buffAttr["mode"] == 2 then
			-- 连带修改最大血量、共享副本里面有这个需求
			if kName == Fight.value_health then
				object[Fight.value_maxhp] = math.round(object[Fight.value_maxhp] * (1 + buffAttr["value"]/10000))
			end
			object[kName] = math.round(object[kName] * (1 + buffAttr["value"]/10000))
		else
			object[kName] = object[kName] + buffAttr["value"]
		end
	else
		dump(buffAttr,"数据======")
		echoError("进战斗buff数值配置错误，请找对应玩法的策划-----")
	end
end

--[[
	以下是对锁妖塔中战斗中使用 ---锁妖塔---start---
]]
-- 排除死亡的角色及衰减buff处理
function GameControlerEx:checkTowerMonsterDiff(towerInfo)
	local value ,hpArr = nil,nil
	local attr = {
		Fight.value_maxhp,--最大血
		Fight.value_health,--血
		Fight.value_phydef,--物防
		Fight.value_magdef,--魔防
		Fight.value_atk,--攻
	}
	-- (vv,-value,Fight.valueChangeType_ratio)
	-- 削减增益
	if towerInfo.propChange and tonumber(towerInfo.propChange) > 0 then
		value = tonumber(towerInfo.propChange)/100 --转换为百分比
	end

	if towerInfo.hpInfo and towerInfo.hpInfo ~= "" then
		if type(towerInfo.hpInfo) == 'string' then
			hpArr = json.decode(towerInfo.hpInfo)
		else
			hpArr = towerInfo.hpInfo
		end
	end
	if (not hpArr or not hpArr.enemy) and not value then
		return
	end
	-- dump(hpArr.enemy,"======aaaa")
	for i=1,#self.levelInfo.waveDatas do
		local wave = self.levelInfo.waveDatas[i]
		local count = #wave
		for j = count ,1,-1 do
			local obj = wave[j]
			-- 衰减处理
			if value then
				for _,key in pairs(attr) do
					-- obj:changeValue(key,-value,2) --百分比衰减
					obj[key] = math.round(obj[key] - obj[key] * value)
				end
			end
			if hpArr and hpArr.enemy then
				for k,newObj in pairs(hpArr.enemy) do
					if newObj.rid == obj.rid and newObj.hpPercent == 0 then
						self.levelInfo:setLevelDeadData(newObj)
						table.remove(wave,j)
					end
				end
			end
		end
	end
end
-- 锁妖塔初始化伙伴信息(血量)
function GameControlerEx:loadParnterHp( )
	local userRid = self:getUserRid()
	local _setHpInfo = function( newObj )
		for k,hero in ipairs(self.campArr_1) do
			if newObj.rid == userRid and 
				tostring(hero.data.hid) == tostring(newObj.hid) 
			then
				local maxHp = hero.data:getInitValue(Fight.value_maxhp)
				-- local maxHp = hero.data:maxhp()
				-- 计算该减的血量
				local subHp = maxHp - math.round(maxHp*(newObj.hpPercent)/10000)
				hero.data:changeValue(Fight.value_health,-subHp,1)
				break
			end
		end
	end
	-- dump(BattleControler._battleInfo.battleParams,"BattleControler._battleInfo.battleParams===")
	-- 伙伴及雇佣兵血量相关
	local arr = {"unitInfo","employeeInfo"}
	local bInfo = self.levelInfo:getBattleInfo()
	for k,v in pairs(arr) do
		local info = bInfo.battleParams[v]
		if info then
			for m,n in pairs(info) do
				if type(n) == 'string' then
					local newObj = json.decode(n)
					_setHpInfo(newObj)
				else
					_setHpInfo(n)
				end
			end
		end
	end
end
-- 加载伙伴信息
function GameControlerEx:loadMonsterHp(hpInfo)
	local hpArr = hpInfo
	if type(hpInfo) == 'string' then
		hpArr = json.decode(hpInfo)
	end
	-- if type(hpInfo) == 'table' then
	-- 	hpArr = hpInfo
	-- elseif type(hpInfo) == 'string' then
	-- 	hpArr = json.decode(hpInfo)
	-- end
	-- dump(hpArr,"s-----")
	if not hpArr.enemy then
		return
	end
	for k,newObj in pairs(hpArr.enemy) do
		for i,monster in ipairs(self.campArr_2) do
			if tostring(monster.data.rid) == tostring(newObj.rid) 
			then
				local maxHp = monster.data:getInitValue(Fight.value_maxhp)
				local subHp = maxHp - math.round(maxHp*(newObj.hpPercent)/10000)
				monster.data:changeValue(Fight.value_health,-subHp,1)
				break
			end
		end

	end
end
-- 锁妖塔飞剑扣血处理
function GameControlerEx:updateMonsterHpReduce(hpPercent )
	local totalHp = 0
	local totalNowHp = 0
	for i,monster in ipairs(self.campArr_2) do
		local maxHp = monster.data:getInitValue(Fight.value_maxhp)
		local nowHp = monster.data:hp()
		totalHp = totalHp + maxHp
		totalNowHp = totalNowHp + nowHp
	end
	local needReduceHp = math.round(totalHp * hpPercent/10000) --总共需要扣的血量值
	local tmpHp = 0
	echo("总血量---要扣的血量值，当前总血量值",totalHp,needReduceHp,totalNowHp)
	for i,monster in ipairs(self.campArr_2) do
		local value = monster.data:hp()
		-- 最后一个人用总扣血量值与前几个扣之差
		if i == #self.campArr_2 then
			value = math.round(value - (needReduceHp - tmpHp))
		else
			local redHp = math.round(value/totalNowHp * needReduceHp)
			tmpHp = tmpHp + redHp
			value = math.round(value - redHp)
		end
		if value < 0 then value = 1 end
		local subHp = monster.data:hp() - value
		monster.data:changeValue(Fight.value_health,-subHp,1)
	end
end
-- 锁妖塔中初始化buff信息、其实应该是当成光环处理
function GameControlerEx:loadTowerBuff(towerInfo)
	local isEnergyAdd = false --锁妖塔怒气上限只加一次
	for k,obj in ipairs(self.campArr_1) do
		-- buff增益
		if towerInfo.buffs then
			for m,n in pairs(towerInfo.buffs) do
				for i=1,tonumber(n) do
					local buff = FuncTower.getShopBuffData(m)
					-- local buff = {id=101,effect={10,1,300,2},cost=3,color=1} 
					if buff then
						if buff.magicUp then
							if not isEnergyAdd then
								-- 这个是怒气上限增加的buff、只加一次
								local max = self.energyControler:getMaxEntireEnergy(1)
								max = max + tonumber(buff.magicUp) * tonumber(n)
								self.energyControler:setMaxEntireEnergy(1,max)
								isEnergyAdd = true
							end
						else
							for _,vv in pairs(buff.effect) do
								self:changeModelDataValue(obj,vv)
							end
						end
					else
						echoError("找策划-，TowerShopBuff 中没有%s的数据",m)
					end
				end
			end
		end
		if towerInfo.tempBuffs then
			for m,n in pairs(towerInfo.tempBuffs) do
				for i=1,tonumber(n) do
					local goodData = FuncTower.getGoodsData(m)
					local buffAttr = FuncTower.getTowerBuffAttrData(goodData.attribute[1])
					if buffAttr then
						for _,vv in pairs(buffAttr.attr) do
							self:changeModelDataValue(obj,vv)
							echo("临时buff增益----:%s",goodData.attribute[1])
						end
					end
				end
			end
		end
		if towerInfo.mapBuff and tonumber(towerInfo.mapBuff) ~= 0 then
			local mapData = FuncTower.getMapBuffData(tostring(towerInfo.mapBuff))
			for _,vv in pairs(mapData.attr) do
				if not mapData.isDebuff or mapData.isDebuff == 1 then
					-- 减益类buff
					self:changeModelDataValue(obj,vv,true)
				else
					self:changeModelDataValue(obj,vv)
				end
			end
		end
		-- -- 削减增益
		-- if towerInfo.propChange and tonumber(towerInfo.propChange) > 0 then
		-- 	local value = tonumber(towerInfo.propChange)*100 --百分比转换为万分比
		-- 	local attr = {
		-- 		Fight.value_health,--血
		-- 		Fight.value_phydef,--物防
		-- 		Fight.value_magdef,--模仿
		-- 		Fight.value_atk,--攻
		-- 	}
		-- 	for i,vv in ipairs(attr) do
		-- 		obj: (vv,-value,Fight.valueChangeType_ratio)
		-- 	end
		-- 	echo("怪物被削弱了，----",towerInfo.propChange)
		-- end
	end
end
-- 仙盟探索buff
function GameControlerEx:loadExploreBuff(eInfo)
	for k,obj in ipairs(self.campArr_1) do
		-- 普通buff
		if eInfo.buffs then
			for m,v in pairs(eInfo.buffs) do
				local buff = FuncGuildExplore.getCfgDatas("ExploreBuff",v.tid)
				if buff.effect and #buff.effect >= v.index then
					local strArr = string.split(buff.effect[v.index],",")
					if #strArr >= 3 then
						local tmpArr = {
							key = tonumber(strArr[1]),
							mode = tonumber(strArr[2]),
							value = tonumber(strArr[3]),
						}
						for i=1,v.count do
							self:changeModelDataValue(obj,tmpArr)
							echo("角色入场buff加成====",strArr[1],strArr[2],strArr[3])
						end
					end
				end
			end
		end
		-- 矿洞buff
		if eInfo.cityBuff then
			for k,v in pairs(eInfo.cityBuff) do
				local buff = FuncGuildExplore.getCfgDatas("ExploreCity",v.tid)
				if buff.buff and #buff.buff >= v.group then
					local strArr = string.split(buff.buff[v.group],",")
					if #strArr >= 2 then
						-- 表配置的是百分比值，需要转换为万分比
						local a,b = tonumber(strArr[1]),tonumber(strArr[2])*100
						self:changeModelDataValue(obj,{key=a,mode=1,value=b})
						echo("角色入场cityBuff加成====",a,b)
					end
				end
			end
		end
		-- 装备buff
		if eInfo.equipBuff then
			for k,v in pairs(eInfo.equipBuff) do
				local buffArr = FuncGuildExplore.getCfgDatas("ExploreEquipment",v.tid)
				if buffArr[tostring(v.level1)] then
					local buff = buffArr[tostring(v.level1)]
					-- 现在暂时只有pve
					if buff.attributeA then
						for m,n in pairs(buff.attributeA) do
							self:changeModelDataValue(obj,n)
							echo("角色入场equipBuff加成====",n.key,n.value)
						end
					end
				end
			end
		end
	end
end
-- 获取血量信息
function GameControlerEx:getPartnersInfo( )
	local rInfo = {partnersInfo={},employeeInfo={}}
	-- 设置传递的值
	local function _setInfo(tmp,teamFlag)
		if teamFlag then
			tmp.teamFlag = teamFlag
			rInfo.employeeInfo[tostring(tmp.hid)] = tmp
		else
			rInfo.partnersInfo[tostring(tmp.hid)] = tmp
		end
	end
	local userRid = self:getUserRid()
	for _,oldObj in ipairs(self.levelInfo.campData1) do
		local isDead = true
		for k,hero in ipairs(self.campArr_1) do
			if oldObj.hid == hero.data.hid then
				isDead = false
				break
			end
		end
		if isDead then
			local tmp = {rid = userRid, hid = oldObj.hid,hpPercent = 0}
			_setInfo(tmp,oldObj.teamFlag)
		end
	end
	for k,hero in ipairs(self.campArr_1) do
		if not hero:isSummon() then
			local tmp = {rid = userRid, hid = hero.data.hid,
				hpPercent = 0,
			}
			-- 傀儡等不算活人
			if not hero:hasNotAliveBuff() then
				-- echo("num1111:===",hero.data:getBuffNums())
				-- 此时需要清除有协助技能的buff、光环
				hero.data:clearAllBuff()
				hero.data:clearAllAuraBuff()
				local currHp = hero.data:hp()
				-- local cMaxHp = hero.data:maxhp()
				local oMaxHp = hero.data:getInitValue(Fight.value_maxhp)
				tmp.hpPercent = math.round(currHp/oMaxHp*10000)
				-- echo("aa==",hero.data.hid,hero.data:hp(),hero.data:getInitValue(Fight.value_maxhp))
			end
		  	if tmp.hpPercent > 10000 then
		      tmp.hpPercent = 10000
		      -- echo("锁妖塔角色血量不对！")
			end
			_setInfo(tmp,hero:getTeamFlag())
		end
	end
	-- dump(rInfo,"伙伴血量==")
	return rInfo
end
-- 锁妖塔战斗结算获取战斗boss血量或者敌方血量信息
function GameControlerEx:getMonsterInfoParams( ... )
	-- 给服务器发送怪物的血量信息
	local resultInfo = {hpInfo = {}}
	resultInfo.energy = self.energyControler:getEnergyInfo(1).entire
	local enemyInfo = {}
	-- 锁妖塔BOSS战要发送对boss造成的血量
	if BattleControler:checkIsTowerBossPVE() then
		local initObj = self.levelInfo.waveDatas[1][1] --boss只有一只
		if #self.campArr_2 == 0 then
			-- boss被打死了
			rParams.towerInfo.bossHp = math.round(initObj.data:hp())
		else
			local nowObj = self.campArr_2[1]
			rParams.towerInfo.bossHp = math.round(initObj.data:hp() - nowObj.data:hp())
		end
	end
	-- 获取死亡的怪物
	-- 如果第一波有未死亡的，则b不需要计算第二波怪的数据
	local waveLife = false
	for i=1,#self.levelInfo.waveDatas do
		local waveData = self.levelInfo.waveDatas[i]
		for _,oldObj in ipairs(waveData) do
			local isDead = true
			for k,enemy in ipairs(self.campArr_2) do
				if enemy.data.rid == oldObj.rid then
					isDead = false
					break
				end
			end
			if isDead then
				local tmp = {rid = oldObj.rid,hpPercent = 0}--,energyPercent = 0
				table.insert(enemyInfo,tmp)
			else
				if i  == 1 then
					waveLife = true
				end
			end
		end
		if waveLife then
			break
		end
	end
	local oldData = self.levelInfo:getLevelDeadData()
	for k,v in ipairs(oldData) do
		local tmp = {rid = v.rid,hpPercent = 0}
		table.insert(enemyInfo,tmp)
	end
	-- 获取还活着的数据
	for k,enemy in ipairs(self.campArr_2) do
		if not enemy:isSummon() then
			local tmp = {rid = enemy.data.rid,hpPercent = 0}
			if not self:isLiveHero(enemy) then
				tmp.hpPercent = 0
			else
				local hp = enemy.data:hp()
				local maxHp = enemy.data:maxhp()
				if hp > 0 and maxHp > 0 then
					tmp.hpPercent = math.round(hp/maxHp*10000)
				else
					tmp.hpPercent = 0
				end
			end
			table.insert(enemyInfo,tmp)
		end
	end
	resultInfo.hpInfo.enemy = enemyInfo
	-- 获取血量剩余的万分比
	local percent = 0
	for k,v in pairs(enemyInfo) do
		percent = percent + v.hpPercent
	end
	-- 计算第二波还有的怪的血量
	if waveLife and self.levelInfo.monsterCount > #enemyInfo then
		local c = self.levelInfo.monsterCount - #enemyInfo
		for i=1,c do
			percent = percent + 10000
		end
	end
	if self.levelInfo.monsterCount > 0 then
		resultInfo.hpInfo.levelHpPercent = math.round(percent/self.levelInfo.monsterCount)
		 if resultInfo.hpInfo.levelHpPercent >= 10000 then
		    resultInfo.hpInfo.levelHpPercent = 10000
		    -- echoError("锁妖塔血量数据超过了10000")
		end
	else
		resultInfo.hpInfo.levelHpPercent = 0
	end
	-- 如果战斗胜利、则将地方血量都置0 (仙盟探索不把敌方血量置0) 
	if self._gameResult == Fight.result_win and 
		BattleControler:getBattleLabel() ~= GameVars.battleLabels.exploreElite then
		for k,v in pairs(resultInfo.hpInfo.enemy) do
			v.hpPercent = 0
		end
		resultInfo.hpInfo.levelHpPercent = 0
	end
	-- dump(resultInfo,"s----sssssssss=====")
	-- echo("怪物总数-----:%s---剩余血量：%s",self.levelInfo.monsterCount,resultInfo.hpInfo.levelHpPercent)
	return resultInfo
end
-- 锁妖塔偷袭战优先攻击判定
function GameControlerEx:isTowerTouxi( )
	if BattleControler:checkIsTower() then
		-- echo("锁妖塔偷袭战优先攻击判定")
		local bInfo = self.levelInfo:getBattleInfo()
		local towerInfo = bInfo.battleParams.towerInfo
		if towerInfo and towerInfo.isSleep == 1 then
			return true
		else
			return false
		end
	end
	return false
end
-- 如果是锁妖塔偷袭战、则给所有人加一个沉睡的buff
function GameControlerEx:checkTowerSleepBuff( )
	if self:isTowerTouxi() then
		for k,enemy in ipairs(self.campArr_2) do
			-- echo("添加沉睡buff-----",enemy.hid,Fight.battle_tower_touxiBuffHid)
			enemy:checkCreateBuff(Fight.battle_tower_touxiBuffHid,enemy)
			-- 并且怪物来个转身
			enemy:turnRound(true)
		end
	end
end
-- 当我方出手后，buff就清除了
function GameControlerEx:removeTowerSleepBuff( ... )
	if self:isTowerTouxiAndFirstWaveRound() then
		-- echo("锁妖塔是偷袭战、并且是第一回合则清除沉睡buff")
		for k,enemy in ipairs(self.campArr_2) do
			-- 将所有人直接转身
			enemy:turnRound(false)
			enemy.data:clearGroupBuff(Fight.buffType_sleep )
		end
	end
end
-- 判断偷袭战并且是第一回合
function GameControlerEx:isTowerTouxiAndFirstWaveRound( )
	return (self:isTowerTouxi() and self.logical.roundCount == 1 and self.__currentWave == 1)
end
-- 偷袭战一开始有一个人直接放大招 、获取偷袭的角色
function GameControlerEx:getTowerTouxiHero( ... )
	-- 优先级 攻击类伙伴→主角→防御类伙伴→辅助类伙伴
	local getModelObjByProfession = function( profession)
		for k,hero in ipairs(self.campArr_1) do
			if not profession then
				if hero.data.isCharacter then
					return hero
				end
			else
				if not hero.data.isCharacter and hero:getHeroProfession() == profession then
					return hero
				end
			end
		end
		return nil
	end
	local modelHero = getModelObjByProfession(Fight.profession_atk) --攻击类伙伴
	if modelHero then
		return modelHero
	end
	modelHero = getModelObjByProfession(nil) --主角
	if modelHero then
		return modelHero
	end
	modelHero = getModelObjByProfession(Fight.profession_def) --防御类伙伴
	if modelHero then
		return modelHero
	end
	modelHero = getModelObjByProfession(Fight.skillIndex_max)--辅助类伙伴
	if modelHero then
		return modelHero
	end
	return nil
end
--[[
	以上方法更多的是在锁妖塔中使用到---锁妖塔-end----
]]
-- 战斗结束后直接让某一方角色强制死亡
function GameControlerEx:doBattleEndCampDie(camp)
	local array = self:getCampArr(camp)
	if #array>0 then
		for i = #array,1,-1 do
			local v = array[i]
			v:doHeroDie()
		end
	end
end
-- 剔除死亡角色
function GameControlerEx:_checkDead(hpInfo)
	local wData = self.levelInfo.waveDatas[1]
	for i=#wData,1,-1 do
		local monster = wData[i]
		for rid,damage in pairs(hpInfo) do
			if tostring(rid) == tostring(monster.rid) then
				local maxHp = monster[Fight.value_maxhp]
				if maxHp - damage <=0 then
					self.levelInfo:setLevelDeadData(monster)
					table.remove(wData,i)
					break
				end
			end
		end
	end
end

--[[
	以下方法更多的是在共享副本中使用到---共享副本--start----
]]
-- 共享副本怪物存活校验
function GameControlerEx:checkShareBossDead( ... )
	local battleInfo = self.levelInfo:getBattleInfo()
	local hpInfo = battleInfo.shareBossInfo.bossHp
	self:_checkDead(hpInfo)
end
-- 初始化怪物难度系数修正
function GameControlerEx:loadMonsterFix( )
	local battleInfo = self.levelInfo:getBattleInfo()
	local sbData = FuncShareBoss.getBossDataById(tostring(battleInfo.shareBossInfo.bossId))
	-- dump(sbData,"sbData=======")
	if battleInfo.shareBossInfo and battleInfo.shareBossInfo.bossId and sbData then
		local wData = self.levelInfo.waveDatas[1]
		for i=#wData,1,-1 do
			local monster = wData[i]
			if monster.boss == 1 then
				for i,v in pairs(sbData.boss) do
					self:changeAttrDataValue(monster,v)
				end
			else
				for i,v in pairs(sbData.master) do
					self:changeAttrDataValue(monster,v)
				end
			end
		end
	end
end
function GameControlerEx:_updateCamp2Hp( hpArr )
	for rid,damage in pairs(hpArr) do
		for i,monster in ipairs(self.campArr_2) do
			if tostring(monster.data.rid) == tostring(rid) 
			then
				local maxHp = monster.data:getInitValue(Fight.value_maxhp)
				local value = maxHp - damage
				local subHp = monster.data:hp() - value
				monster.data:changeValue(Fight.value_health,-subHp,1)
				break
			end
		end
	end
end
-- 共享副本怪物血量处理
function GameControlerEx:loadShareBossHpInfo( )
	local bInfo = self.levelInfo:getBattleInfo()
	local hpArr = bInfo.shareBossInfo.bossHp
	self:_updateCamp2Hp(hpArr)
end

-- 共享副本初始化时候buff相关
function GameControlerEx:loadShareBossBuff( )
	local battleInfo = self.levelInfo:getBattleInfo()
	-- dump(battleInfo.shareBossInfo,"======battleInfo.shareBossInfo")
	if battleInfo.shareBossInfo and battleInfo.shareBossInfo.buffId 
		and battleInfo.shareBossInfo.tagsStr
	 then
	 	local objArr = string.split(battleInfo.shareBossInfo.tagsStr,";")
		local buffDB = FuncShareBoss.getBuffByBuffId(tostring(battleInfo.shareBossInfo.buffId))
		-- dump(buffDB,"buffDB=======")
		for m,n in pairs(buffDB.attr) do
			for k,obj in ipairs(self.campArr_1) do
				local tagInfo = FuncPartner.getPartnerById(obj.data.hid)
				if tagInfo and tagInfo.tag then
					for a,b in ipairs(tagInfo.tag) do
						local tagStr = a..","..b
						if table.find(objArr,tagStr) then
							self:changeModelDataValue(obj,n)
							-- echo("角色打共享副本有属性加成===",obj.data.hid)
							break
						end
					end
				end
			end
			-- echo("共享副本增益----:%s",battleInfo.shareBossInfo.buffId)
		end
	end
end
-- 须臾幻境副本加成
function GameControlerEx:loadWanderLandBuff( )
	local bInfo = self.levelInfo:getBattleInfo()
	local wlData = bInfo.wonderLand
	if not wlData then return end
	if wlData.buffs and wlData.tags and #wlData.tags > 0 then
		local buffDB = FuncWonderland.getWonderLandBuffById(wlData.buffs)
		for m,n in pairs(buffDB.attr) do
			for k,obj in ipairs(self.campArr_1) do
				if not obj.data:isRobootNPC() then
					local tagInfo = FuncPartner.getPartnerById(obj.data.hid).tag
					if tagInfo then
						for k,tag in pairs(wlData.tags) do
							local tabTbl = string.split(tag,",")
							if #tabTbl == 2 and tagInfo[tonumber(tabTbl[1])] == tabTbl[2] then
								self:changeModelDataValue(obj,n)
								break
							end
						end
					end
				end
			end
		end
	end
end

function GameControlerEx:_getHpInfo(hpInfo )
	-- 给服务器发送怪物的血量信息
	local resultInfo = {isDie = 1,damage = 0 }
	local bossHp = {}
	-- local testHp = {currhp = 0,maxhp = 0,maxCount = 0,lmp = 0,per = 0}
	-- 怪物剩余血量
	local waveData = self.levelInfo.waveDatas[1]
	for _,oldObj in ipairs(waveData) do
		local isDead = true
		for k,enemy in ipairs(self.campArr_2) do
			if enemy.data.rid == oldObj.rid then
				isDead = false
				break
			end
		end
		if isDead then
			-- testHp.maxhp = testHp.maxhp + oldObj.maxhp

			local oldDamage = hpInfo[tostring(oldObj.rid)] or 0
			local damage = oldObj.maxhp - oldDamage

			local tmp = {id = oldObj.rid,hpTotal = oldObj.maxhp,hpNow = 0,damage = damage}
			table.insert(bossHp,tmp)
		end
	end
	local oldData = self.levelInfo:getLevelDeadData()
	for k,v in ipairs(oldData) do
		local tmp = {id = v.rid,hpTotal = v.maxhp,hpNow = 0,damage = 0}
		table.insert(bossHp,tmp)
	end

	for k,enemy in ipairs(self.campArr_2) do
		if not enemy:isSummon() and
			not enemy:hasNotAliveBuff()
			then
			enemy.data:clearAllBuff()
			enemy.data:clearAllAuraBuff()
			-- testHp.maxhp = testHp.maxhp + enemy.data:maxhp()
			-- testHp.currhp = testHp.currhp + enemy.data:hp()
			-- testHp.maxCount = testHp.maxCount + 1
			-- testHp.per = hpPercent
			-- testHp.lmp = testHp.lmp + enemy.data:maxhp()
			local currHp = enemy.data:hp()
			local oldDamage = hpInfo[tostring(enemy.data.rid)] or 0
			local damage = enemy.data:maxhp() - currHp - oldDamage
			local maxhp = enemy.data:getInitValue(Fight.value_maxhp)
			if currHp > maxhp then currHp = maxhp end
			--现在boss会回血，如果伤害为负，说明怪回血了，所以强制修改为0。
			-- hpNow可以不用处理，服务端会根据根据damage和hpTotal计算hpNow
			if damage < 0 then
				damage = 0 
			end
			local tmp = {id = enemy.data.rid,hpTotal = maxhp,hpNow=currHp,damage=damage}
			table.insert(bossHp,tmp)
			if currHp > 0 then
				resultInfo.isDie = 0 --boss未死亡
			end
		end
	end
	resultInfo.bossHp = bossHp --json.encode(bossHp)
	-- 获取总伤害
	resultInfo.damage = StatisticsControler:getAllTotalDamage(1)
	if resultInfo.damage < 0 then
		resultInfo.damage = 0
	end
	-- dump(resultInfo,"总伤害=====")
	return resultInfo
end

-- 战斗结束上报怪物剩余血量级伤害数
function GameControlerEx:getShareBossInfoParams( ... )
	local bInfo = self.levelInfo:getBattleInfo()
	local hpInfo = bInfo.shareBossInfo.bossHp
	return self:_getHpInfo(hpInfo)
end
-- 共享副本玩法已结束 弹的动画
function GameControlerEx:showShareBossEnd(cb)
	self.gameUi:showJieshuDonghua(cb)
end
--[[
	以上方法更多的是在共享副本中使用到---共享副本--end----
]]
--[[
	仙盟GVE
]]
-- 仙盟战斗系数修正
function GameControlerEx:loadGuidDiff( ... )
	-- 为敌方添加对应的属性加成、主要是加攻、防、血
	local attr = {
		Fight.value_maxhp,
		Fight.value_health,
		Fight.value_phydef,
		Fight.value_magdef,
		Fight.value_atk,
	}
	local bInfo = self.levelInfo:getBattleInfo()
	local monsterId = bInfo.battleParams.monsterInfo.monsterId
	local diffArr = FuncGuildActivity.getFoodFightByMonsterId(monsterId).fightDiff
	local userLv = bInfo.battleUsers[1].level
	local idx = math.floor(userLv/10)

	if diffArr[idx] then
		for k,enemy in ipairs(self.campArr_2) do
			for i,v in ipairs(attr) do
				enemy:changeDataValue(v,diffArr[idx],Fight.valueChangeType_ratio)
			end
		end
	end
end
-- 战斗结束上报怪物剩余血量级伤害数
function GameControlerEx:getGuildBossInfoParams( ... )
	local bInfo = self.levelInfo:getBattleInfo()
	local gInfo = {}
	if bInfo.guildBossInfo then
		gInfo = self:_getHpInfo(bInfo.guildBossInfo.bossHp)
	end
	return gInfo
end
-- 在加载阶段就收到仙盟食材刷新通知
function GameControlerEx:set2Quick(value )
	self._gve2Quick = value
end
function GameControlerEx:getGVEIs2Quick( )
	return self._gve2Quick or false
end
-- 六界轶事夺宝获取宝物Id
function GameControlerEx:getMissionBaoWuId( )
	if not self.__missionBaowu then
		local bInfo = self.levelInfo:getBattleInfo()
		local id = tostring(bInfo.battleParams.id)
		local index = tonumber(bInfo.battleParams.missionBattle.index)
		self.__missionBaowu = FuncMission.getMissionParamId(id,index)
	end
	return self.__missionBaowu
end
-- 检查怪物是否是宝物
function GameControlerEx:checkMonsterIsBaoWu(monster)
	return monster.data.hid == self:getMissionBaoWuId()
end
-- 理解冰封 添加冰封buff
function GameControlerEx:checkIcePveBuff( )
	for k,enemy in ipairs(self.campArr_2) do
		enemy:checkCreateBuff(Fight.battle_icePve_buffHid,enemy)
	end
end

-- 战斗中途退出设置
function GameControlerEx:setIsPauseOut(isPauseExit )
	if isPauseExit then
		self._isPauseOut = 1
	else
		self._isPauseOut = 0
	end
end
-- 获取玩家自动战斗状态
function GameControlerEx:getUserAutoStatus(rid)
    rid = rid or self:getUserRid()
	local scode = 0
	-- 如果是重播直接返回0
	if self:isReplayGame() then
		return scode
	end
	-- 如果有引导直接返回0
	if self:chkHasGuide() then
		return scode
	end
	if Fight.isDummy then
		return scode
	end
	
    if self:getUserRid() == rid then
    	local bLabel = BattleControler:getBattleLabel()
		if BattleControler:checkIsWorldPVE() or BattleControler:checkIsLovePVE() then
            scode = tonumber(LS:prv():get(StorageCode.battle_world_pve_auto,0))
        -- elseif BattleControler:checkIsTrialPve() then
        --     scode = tonumber(LS:prv():get(StorageCode.battle_trail_pve_auto,0))
        elseif BattleControler:checkIsTower() then
            scode = tonumber(LS:prv():get(StorageCode.battle_tower_auto,0))
        elseif bLabel == GameVars.battleLabels.missionMonkeyPve or 
        	bLabel == GameVars.battleLabels.missionBattlePve then
            scode = tonumber(LS:prv():get(StorageCode.battle_mission_auto,0))
        elseif BattleControler:checkIsShareBossPVE() then
        	local sbStr = LS:prv():get(StorageCode.battle_shareboss_auto,nil)
        	if sbStr then
        		local tmpArr = json.decode(sbStr)
        		if type(tmpArr) ~= 'table' then
        			tmpArr = {}
        		end
        		for k,v in pairs(tmpArr) do
        			local bId = ShareBossModel:getSelectedId()--其实就是发现这个boss的玩家的rid
        			if tostring(k) == tostring(bId) then
        				scode = tonumber(v)
        				break
        			end
        		end
        	end
        	-- scode = tonumber(LS:prv():get(StorageCode.battle_shareboss_auto,0))
    	elseif bLabel == GameVars.battleLabels.wonderLandPve then
    		scode = tonumber(LS:prv():get(StorageCode.battle_wonderland_auto,0))
    	elseif bLabel == GameVars.battleLabels.missionIcePve then
    		scode = tonumber(LS:prv():get(StorageCode.battle_ice_auto,0))
    	elseif bLabel == GameVars.battleLabels.endlessPve then
    		scode = tonumber(LS:prv():get(StorageCode.battle_endless_auto,0))
    	elseif bLabel == GameVars.battleLabels.missionBombPve then
    		scode = tonumber(LS:prv():get(StorageCode.battle_bomb_auto,0))
        elseif bLabel == GameVars.battleLabels.guildBossPve then
        	scode = tonumber(LS:prv():get(StorageCode.battle_guildboss_auto,0))
    	elseif bLabel == GameVars.battleLabels.guildGve then
        	scode = tonumber(LS:prv():get(StorageCode.battle_guildGve_auto,0))
        elseif BattleControler:checkIsExploreBattle() then
	        if bLabel == GameVars.battleLabels.exploreElite then
	            scode = tonumber(LS:prv():get(StorageCode.battle_exploreElite_auto,value))
	        else
	            scode = tonumber(LS:prv():get(StorageCode.battle_guildExplore_auto,value))
	        end
	    end
    end
    return scode
end

-- 根据各个玩法在还没有创建model的时候处理一些数据相关、比如锁妖塔敌方怪物死亡与否
function GameControlerEx:beforeCreateModel( )
	local bLabel = BattleControler:getBattleLabel()
	local bIsExplore = BattleControler:checkIsExploreBattle()
	-- 处理锁妖塔相关信息
	if BattleControler:checkIsTower() or bIsExplore then
		-- 先算总的敌方角色
		for i=1,#self.levelInfo.waveDatas do
			local wave = self.levelInfo.waveDatas[i]
			self.levelInfo.monsterCount = self.levelInfo.monsterCount + #wave
		end
		local bInfo = self.levelInfo:getBattleInfo()
		local tmpInfo
		if bIsExplore then
			tmpInfo = bInfo.battleParams.explore
		else
			tmpInfo = bInfo.battleParams.towerInfo --锁妖塔数据
		end
		if tmpInfo then
			self:checkTowerMonsterDiff(tmpInfo)
		end
		-- dump(tmpInfo,"s====")
		-- if towerInfo and towerInfo.hpInfo and towerInfo.hpInfo ~= "" then
		-- end

	end
	-- 处理共享副本相关信息
	if BattleControler:checkIsShareBossPVE() then
		self:loadMonsterFix()--先做修正、然后再剔除死亡的角色
		self:checkShareBossDead()
	end
	-- 处理仙盟副本相关信息
	if bLabel == GameVars.battleLabels.guildBossPve or
	 bLabel == GameVars.battleLabels.guildBossGve then
	 	local bInfo = self.levelInfo:getBattleInfo()
	 	if bInfo.guildBossInfo then
			self:_checkDead(bInfo.guildBossInfo.bossHp)
	 	end
	end
end

-- pvp战斗model加属性
function GameControlerEx:afterCreatePvPModel( )
	local _addPvPBuff = function( campArr,tags,buffs,epArr)
		for k,obj in pairs(campArr) do
			if not obj.data:isRobootNPC() then
				if buffs then
					local tagInfo = FuncPartner.getPartnerById(obj.data.hid).tag
					if tagInfo then
						for m,n in pairs(tags) do
							if tostring(tagInfo[tonumber(n.key)]) == tostring(n.value) then
								for _,attr in pairs(buffs) do
									echo("角色===有buff加成",obj.data.hid)
									self:changeModelDataValue(obj,attr)
								end
							end
						end
					end
				end
				if epArr then
					-- 指定奇侠加属性
					for _,attr in pairs(epArr) do
						if obj.data.hid == attr.partnerId then
							self:changeModelDataValue(obj,attr)
							echo("特殊角色===有buff加成",attr.partnerId)
						end
					end
				end
			end
		end
	end
	local bInfo = self.levelInfo:getBattleInfo()
	if not bInfo.battleParams then
		return
	end
	local buffId = bInfo.battleParams.pvpBuffId
	local bData = FuncPvp.getBuffDataByBuffId(buffId)
	_addPvPBuff(self.campArr_1,bData.attackTeam,bData.attackProperty,bData.attackPartnerProperty)
	_addPvPBuff(self.campArr_2,bData.defendTeam,bData.defendProperty,bData.defendPartnerProperty)
end
function GameControlerEx:checkAddGuidSkill( )
	local bLabel = BattleControler:getBattleLabel()
	local bInfo = self.levelInfo:getBattleInfo()
	for k,v in pairs(bInfo.battleUsers) do
		if v.guildSkills then
			local arr = v.team == Fight.camp_1 and self.campArr_1 or self.campArr_2
			local buffs = FuncGuild.getAllPropertyDataByType(v.guildSkills,bLabel)
			for m,n in pairs(buffs) do
				for _,attr in pairs(n) do
					-- 对角色做buff处理
					for key,model in pairs(arr) do
						if not attr.target then
							self:changeModelDataValue(model,attr)
						else
							if attr.target == 0 and model.data.isCharacter then
								self:changeModelDataValue(model,attr)
							elseif model:getHeroProfession() == attr.target then
								self:changeModelDataValue(model,attr)
							end
						end
					end
				end
			end
		end
	end
end
-- 根据各个玩法在还创建model之后立即处理一些数据相关、比如锁妖塔我方敌方的血量相关
function GameControlerEx:afterCreateModel( )
	local bLabel = BattleControler:getBattleLabel()
	-- 处理锁妖塔相关信息
	if BattleControler:checkIsTower() then
		local bInfo = self.levelInfo:getBattleInfo()
		local towerInfo = bInfo.battleParams.towerInfo --锁妖塔数据
		if towerInfo then
			self:loadTowerBuff(towerInfo)
			self:loadParnterHp()
			-- 修改怒气(摆放在后面、因为锁妖塔有可能修改怒气上限的buff)
			if towerInfo.energy and towerInfo.energy > 0 then
				self.energyControler:addEnergy(Fight.energy_entire,towerInfo.energy,nil,1)
			end
			-- dump(towerInfo,"towerInfo====")
			if towerInfo and towerInfo.hpInfo and towerInfo.hpInfo ~= "" then
				self:loadMonsterHp(towerInfo.hpInfo)
			end
			-- 飞剑伤害
			if towerInfo.hpPercentReduce and towerInfo.hpPercentReduce > 0 then
				self:updateMonsterHpReduce(towerInfo.hpPercentReduce)
			end
		end
		-- 注意:如果是冰冻的话一开始会有问题，因为怪物正在播放入场动作的时候加了一个冰冻shader会使角色动画看不见
		self:checkTowerSleepBuff()
	elseif BattleControler:checkIsShareBossPVE() then
		self:loadShareBossHpInfo()
		self:loadShareBossBuff()
	elseif bLabel == GameVars.battleLabels.guildGve then
		self:loadGuidDiff()
	elseif bLabel == GameVars.battleLabels.wonderLandPve then
		self:loadWanderLandBuff()
	elseif bLabel == GameVars.battleLabels.missionIcePve then
		self:checkIcePveBuff() --加冰封怪，怪物没有入场动作
	elseif bLabel == GameVars.battleLabels.guildBossPve or
		bLabel == GameVars.battleLabels.guildBossGve then
	 	local bInfo = self.levelInfo:getBattleInfo()
	 	if bInfo.guildBossInfo then
	 		self:_updateCamp2Hp(bInfo.guildBossInfo.bossHp)
	 	end
	elseif bLabel == GameVars.battleLabels.pvp then
		self:afterCreatePvPModel()
	elseif BattleControler:checkIsExploreBattle() then
        local tmpInfo = BattleControler._battleInfo.battleParams.explore
		if tmpInfo then
			self:loadExploreBuff(tmpInfo)
			-- 修改怒气
			if tmpInfo.energy and tmpInfo.energy > 0 then
				self.energyControler:addEnergy(Fight.energy_entire,tmpInfo.energy,nil,1)
			end
			-- 修改血量
			if tmpInfo.hpInfo and tmpInfo.hpInfo ~= "" then
				self:loadMonsterHp(tmpInfo.hpInfo)
			end
		end
		self:loadParnterHp()
		-- echoError ("仙盟探索相关====")
		-- dump(BattleControler._battleInfo.battleParams,"s===")
	end
	-- 添加仙盟科技给予的buff
	self:checkAddGuidSkill()
end
-- 当进入下一波的时候
function GameControlerEx:onNextWaveAfterCreateModel(  )
	if BattleControler:checkIsTower() then
		local towerInfo = BattleControler._battleInfo.battleParams.towerInfo --锁妖塔数据
		if towerInfo and towerInfo.hpInfo and towerInfo.hpInfo ~= "" then
			self:loadMonsterHp(towerInfo.hpInfo)
		end
	end
	-- 共享副本目前没有做第二波的处理
end
-- 是否在战斗中
function GameControlerEx:checkIsRealInit( )
	return self.isRunInitFirst
end

--[[
	战斗打点
	0 回合前
	1 回合后
	2 回合中 -- 战中退出
]]
function GameControlerEx:doClientAction(time)
	-- 战斗校验不记录
	if DEBUG_SERVICES then return end
	-- 没有关卡信息不记录
	if not self.levelInfo then return end
	-- 非主线和精英不记录
	if (BattleControler:getBattleLabel() ~= GameVars.battleLabels.worldPve) then return end

	local uniqueId = nil
	if time == 0 then
		uniqueId = string.format("%s-%s","missionstart",self.levelInfo.hid)
	elseif time == 1 then
		-- 战斗结束时要区分是胜利还是失败
		if self._gameResult == Fight.result_win then
			uniqueId = string.format("%s-%s","missionend",self.levelInfo.hid)
		elseif self._gameResult == Fight.result_lose then
			uniqueId = string.format("%s-%s","missionlose",self.levelInfo.hid)
		end

		if self.__missionexit then
			-- 战中退出，不统计为失败
			uniqueId = nil
		end
	elseif time == 2 then
		-- 中途退出
		uniqueId = string.format("%s-%s","missionexit",self.levelInfo.hid)
		self.__missionexit = true
	end
	
	if uniqueId then
		ClientActionControler:sendTutoralStepToWebCenter(uniqueId)
	end
end
-- 判断是否是在自己回合
function GameControlerEx:chkIsOnMyCamp( ... )
	return self.logical.currentCamp == BattleControler:getTeamCamp()
end
-- 获取当前logical中的游戏状态
function GameControlerEx:getLogicalCountStatus( )
	return self.logical.countState
end
-- 拖拽边界判断
function GameControlerEx:tuozhuaiBianJieJianCha(camp,x,y )
	local targetX,targetY = x,y
	--边界判断
	if camp == 1 then
		targetX = math.max(self.middlePos  - GameVars.width/2 + 10,targetX)
		targetX = math.min(self.middlePos,targetX)
	else
		targetX = math.max(self.middlePos  - 10 ,targetX)
		targetX = math.min(self.middlePos  + GameVars.width/2,targetX)
	end
	targetY = math.max(Fight.buzhen_min,targetY)
	targetY = math.min(Fight.buzhen_max,targetY)
	return targetX,targetY
end
-- 根据传入的x,y 判断落在哪个区域
function GameControlerEx:getAreaTargetByPos(camp,x,y)
	local posArr = self:getHeroPosAreaByCamp(camp)
	local campArr = camp == Fight.camp_1 and self.campArr_1 or self.campArr_2
	-- 根据位置返回落在哪个区域
	local index = AttackChooseType:getAreaPosIndex(posArr, x,y)
	if index then
		local targetHero = AttackChooseType:findHeroByPosIndex( index,campArr )
		return targetHero,index
	end
	return nil,nil
end
-- 检测是否快速出战斗(先检查自动战斗状态然后发送一条自动战斗状态)
function GameControlerEx:checkToQuickGame( )
    local isAuto = self.logical:getAutoState()
    if not isAuto and not self:isReplayGame() then
    	self._isWaitToQuick = true
    	self:setGameAuto(true)
        -- self.server:sendOneAutoHandle({auto = 1})
    else
        self:quickGameToResult()
    end
end
function GameControlerEx:chkIsWaitToQuick()
	return self._isWaitToQuick
end
-- 获取ui显示的camp 
function GameControlerEx:getUIHandleCamp( ... )
	local currCamp = self.logical.currentCamp
	if BattleControler:checkIsCrossPeak() then
		if BattleControler:getTeamCamp() == Fight.camp_2 then
			-- 当是阵营二的时候表现是我方先出手
			if currCamp == Fight.camp_2 then 
				currCamp = Fight.camp_1 
			else
				currCamp = Fight.camp_2
			end
		end
	end
	return currCamp
end
-- 获取我方的campArr
function GameControlerEx:getMyCampArr( )
	local camp = BattleControler:getTeamCamp()
	local campArr = camp == Fight.camp_1 and self.campArr_1 or self.campArr_2
	return campArr
end

-- 显示战斗结算
function GameControlerEx:showMultyReward(rData )
	if not Fight.isDummy then
		if BattleControler:checkIsCrossPeak() then
			if self.gameUi then
				self.gameUi:showEndBattleAni(function(  )
					BattleControler:showReward(rData)
				end)
			end
		else
			BattleControler:showReward(rData)
		end
	end
end
-- 断线重连后，校验滤镜、血量
function GameControlerEx:checkQuick2RoundStatus()
	if Fight.isDummy then 
		return
	end
	local _checkModelBuff = function ( arr )
		for k,v in pairs(arr) do
			-- 重置位置
			v:updatePosAfterQuick()
			-- 重置buff状态
			v.data:updateBuffs()
			-- 检查滤镜
			v:checkUseFilterStyle()
			-- 同步血量
			if v.healthBar then 
				v.healthBar:pressHealthChange()
			end
		end
	end
	-- 检查角色上的buff
	_checkModelBuff(self.campArr_1)
	_checkModelBuff(self.campArr_2)
	-- 检查脚底格子上的buff
	local _checkFormationBuff = function( arr )
		for k,v in pairs(arr) do
			v:updateBuffs()
		end
	end
	_checkFormationBuff(self.formationControler:getLatticeByCamp(Fight.camp_1))
	_checkFormationBuff(self.formationControler:getLatticeByCamp(Fight.camp_2))
end
-- 仙界对决切后台不需要校验卡死
function GameControlerEx:ingoreCheckSeized(b)
	self.__ingoreSeized = b
end
function GameControlerEx:isIngoreCheckSeized()
	return self.__ingoreSeized
end
-- 仙界对决上传卡死战报
function GameControlerEx:sendSeizedUpData( )
	if Fight.isDummy or self:isReplayGame() then
		return
	end
	local bInfo = self.levelInfo:getBattleInfo()
	local str = string.format("battleInfo:\n %s \n logInfo:\n %s \n operation:\n %s",
		json.encode(bInfo), 
		LogsControler:getNearestLogs(500),
		json.encode(self.logical.handleOperationInfo))
    ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,
    	ClientTagData.battleCrossPeakError..BattleControler:getBattleLabel(),str)
end

-- 巅峰竞技场玩家掉线回合数
function GameControlerEx:getLineOffCount( rid )
	if not self.__lineOffCount or not self.__lineOffCount[rid] then
		return 0
	end
	return self.__lineOffCount[rid]
end

-- 更新玩家托管状态
function GameControlerEx:updateUserAuthFlag(info )
	if not self.__authFlagState then
		self.__authFlagState = {}
	end
	self.__authFlagState[info.rid] = info.setAuthFlag -- 0托管 1非托管
	-- 抛通知告知UI处理
	FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_AUTOFLAG_CHANGE)
end
-- ###### 巅峰竞技场相关=====end ---
-- 检查玩家是否是在托管状态
function GameControlerEx:checkUserIsAuthFlag( rid )
	if not self.__authFlagState then
		return false
	end
	rid = rid or self:getUserRid()
	if self.__authFlagState[rid] == 0 then
		return true
	end
	return false
end
-- 共闯秘境相关
function GameControlerEx:userQuickGuildBoss( info )
	if not Fight.isDummy then
		if self:getUserRid() == info.rid then
			BattleControler:onExitBattle()
		else
			echo ("对方已经离开游戏")
			-- WindowControler:showTips( GameConfig.getLanguage("#tid_battle_6"))
		end
	end
end
-- 设置战斗结束是输还是赢
function GameControlerEx:setBattleResult(value)
	if self._gameResult ~= Fight.result_none  then
		echo ("已经出结果了(暂停退出未排除)",value,self._gameResult)
	end
	self._gameResult = value
end
-- 认输值
function GameControlerEx:setIsGiveUp( value )
	self.__isGiveUp = value
end
-- 战斗服是否需要校验
function GameControlerEx:isNeedCheckServerDummy()
	if BattleControler:checkIsMultyBattle() and self.__isGiveUp then
		return false
	end
	return true
end
-- 是否需要战斗校验（关卡条件）
function GameControlerEx:isNeedCheckDummy()
	-- 巅峰竞技场认输的、不校验
	-- if self.__trow and
	-- 	BattleControler:checkIsCrossPeak() then
	-- 	return false
	-- end
	-- 试炼这一关不校验
	if tostring(self.levelInfo.hid) == Fight.xvzhangParams.trial then
		return false
	end
	-- 本地没有战斗结束、不做战斗校验
	if not self._isEndBattle then
		return false
	end
	-- 序章不检查
	if self:chkIsXvZhang() then
		return false
	end

	return true
end
-- 获取战报数据
function GameControlerEx:getBattleAnalyze( )
    local _mergeTable = function( t1,t2 )
        for k,v in pairs(t2) do
            table.insert(t1,v)
        end
    end
    local _sortFunc = function( t )
        for k,v in pairs(t) do
            if v.percent > 0 then
                v.percent = v.percent/2
            end
        end
        table.sort(t,function(a,b)
            return a.percent > b.percent
        end)
    end
    local isPvP = BattleControler:checkIsPVP()
    local data = StatisticsControler:getStatisDatas(not isPvP)
    if BattleControler:getBattleLabel() == GameVars.battleLabels.endlessPve then
	    local data1 = EndlessServer:getWaveData()
	    if data1 then
	        _mergeTable(data.camp1,data1.camp1)
	        _mergeTable(data.camp2,data1.camp2)
	        _sortFunc(data.camp1)
	        _sortFunc(data.camp2)
	        EndlessServer:resetWaveData()
	    end
    end
    return data
end
-- 根据ttr获取对应的刷怪的头像
function GameControlerEx:getIconByAttr(attr )
	local icon
    local treasurArr = attr.treasures
    for k,v in pairs(treasurArr) do
        if v.treaType == Fight.treaType_base then
            local tObj = ObjectTreasure.new(v.hid,v)
            icon = tObj:sta_icon()
            break
        end
    end
    return icon
end
----------------------------- 临时方法，确定之后需要自己删除 -------------------------
-- 是否行优先
function GameControlerEx:isLineFirst()
	-- if self.levelInfo then
	-- 	if tostring( self.levelInfo.hid ) == "10101"
	-- 	or tostring( self.levelInfo.hid ) == "10102"
	-- 	then
	-- 		return true
	-- 	end
	-- end
	return true
end
----------------------------------------------------------------------------------
-- 根据战斗日志对比是否一致
function GameControlerEx:checkDebugLogsInfo(info )
	local myLogsInfo = self.logical:getDebugLogsInfo()
	for k,v in pairs(info.logsInfo) do
		if v ~= myLogsInfo[k] then
			echoError ("回合："..k.."对应的log不一致other:"..v.." my:"..myLogsInfo[k])
			return
		end
	end
	echo("log匹配一致======")
end

function GameControlerEx:isInMiniBattle()
	return false
end

return GameControlerEx

