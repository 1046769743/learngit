local ActivityRecord = class("ActivityRecord")

function ActivityRecord:init(data)
	self.data = data
end

function ActivityRecord:getActId()
	return self.data.actInfo.id
end

function ActivityRecord:getActOnlineInfo( )
	return self.data.onlineInfo
end

function ActivityRecord:getActInfo()
	return self.data.actInfo
end

function ActivityRecord:getTimeInfo()
	return self.data.timeInfo
end

function ActivityRecord:getDisplayLeftTime()
	local timeInfo = self:getTimeInfo()
	local now = TimeControler:getServerTime()
	local left = timeInfo.show_end_t - now
	if left <0 then
		left =0
	end
	return left
end

function ActivityRecord:getSortOrder()
	return self.data.actInfo.order
end

function ActivityRecord:getActTitle()
	return GameConfig.getLanguage(self.data.actInfo.title)
end

function ActivityRecord:getActDesc()
	return GameConfig.getLanguage(self.data.actInfo.desc)
end

--活动在开启期间
function ActivityRecord:isActInActivePeriod()
	local now = TimeControler:getServerTime()
	local timeInfo = self:getTimeInfo()
	return now >= timeInfo.start_t and now <= timeInfo.end_t
end

function ActivityRecord:isActInShowPeroid()
	local now = TimeControler:getServerTime()
	local timeInfo = self:getTimeInfo()
	return now>= timeInfo.show_start_t and now < timeInfo.show_end_t
end

function ActivityRecord:isActCanReceiveAfterEnd()
	return FuncActivity.isDisplayedActCanReceiveAfterActEnd(self:getOnlineId())
end

function ActivityRecord:getActIcon()
	return self.data.actInfo.icon
end

function ActivityRecord:getActType()
	return self.data.actType
end

function ActivityRecord:getOnlineId()
	return self.data.onlineInfo.id
end

--福利里面的id
function ActivityRecord:getDisplayedTaskIds()
	local actInfo = FuncActivity.getActConfigById(tostring(self.data.actInfo.id))
	local ids = {}
	if actInfo.isActivity and actInfo.isActivity == 1 then	
	else
		ids = FuncActivity.getActDisplayedTaskIds(self.data.actInfo.id)
	end
	return ids
end

--新活动的任务id
function ActivityRecord:getNewActTastIds()
	local actInfo = FuncActivity.getActConfigById(tostring(self.data.actInfo.id))
	local ids = {}
	if actInfo.isActivity and actInfo.isActivity == 1 then	
		ids = FuncActivity.getActDisplayedTaskIds(self.data.actInfo.id)
	end
	return ids
end

--是否有可做的内容，用于显示小红点  福利
function ActivityRecord:hasTodoThings(ids)
	if self:getActType() == FuncActivity.ACT_TYPE.EXCHANGE then
		-- return false -- 所有兑换类 没有红点
	end
	local isActActive = self:isActInActivePeriod()
	if not isActActive and not self:isActCanReceiveAfterEnd() then
		return false
	end

	local onlineId = self:getOnlineId()
	local actInfo = self:getActInfo()
	local actType = self:getActType()
	-- dump(ids,"ids = = = = = == = = = = = == = = = = = = ")

	local hasTodo = false
	for _, taskId in pairs(ids) do	
		local conditionOk = ActConditionModel:isTaskConditionOk(onlineId, taskId, actType)
		if conditionOk then
			-- echo("onlineId ============ taskId ============= ",onlineId,taskId)
			local finished = ActTaskModel:isTaskFinished(onlineId, taskId, actInfo)
			if not finished then
				hasTodo = true
			end
		end
	end
	return hasTodo
end

--用于判断单笔充值的红点  因为单笔充值有点特殊 有些可以做几次
function ActivityRecord:checkDanBiRedPoint()
	local isActActive = self:isActInActivePeriod()
	if not isActActive and not self:isActCanReceiveAfterEnd() then
		return false
	end

	local showRedPoint = false
	-- 完成进度
	local ids = self:getNewActTastIds()
	local actOnlineId = self:getOnlineId()
	local actInfo = self:getActInfo()
	local actType = self:getActType()

	for _, actTaskId in pairs(ids) do
		local finishNum,allNum = ActConditionModel:getTaskConditionProgress(actOnlineId, actTaskId)

		local allNumWan = FuncActivity.getTaskCanDoNum(actTaskId)
		local hasGotTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, actInfo)
		local finishNumWan = allNumWan - hasGotTimes
		
		-- 判断是否已领取
		local isGet = (tonumber(finishNumWan) <= 0)
		if not isGet then
			local isConditionOk = (finishNum >= allNum)
			local receiveTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, actInfo)
			local targetFinishTimes = receiveTimes + 1
			isConditionOk = ActConditionModel:isTaskConditionOk(actOnlineId, actTaskId, actType, targetFinishTimes)

			if isConditionOk then
				-- 可领取
				showRedPoint = true
				break
			end
		end
	end
	return showRedPoint
end















local ActTaskModel = class("ActTaskModel", BaseModel)

function ActTaskModel:init(d)
	ActTaskModel.super.init(self, d)
	self.allActTaskData = d  --活动的所有数据
	EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, self.onFuncInit, self)

	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
			self.checkRedPoint, self)

	EventControler:addEventListener(ActivityEvent.ACTEVENT_FULI_RED_EVENT, 
			self.checkRedPoint, self)

	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, 
			self.checkRedPoint, self)

	EventControler:addEventListener("ActTaskModel_check_redpoint", self.checkRedPoint, self)
	TimeControler:startOneCd("ActTaskModel_check_redpoint",5)

	EventControler:addEventListener("ActTaskModel_timeLeft", self.checkTimeEvnt, self)
	TimeControler:startOneCd("ActTaskModel_timeLeft",6)



end

function ActTaskModel:checkTimeEvnt( ) 
	-- 每日目标的时间倒计时
	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERYDAYTARGET) then
		local alldata = FuncActivity.getEverydayActs()
		local createTime = UserModel:ctime()
	    local openDays = UserModel:getCurrentDaysByTimes(createTime)
        local currentData = alldata[openDays]
        if currentData then
    	    local leftTime = currentData:getDisplayLeftTime()
    	    TimeControler:startOneCd("ActTaskModel_everydaytarget_redpoint",leftTime)
    	    EventControler:addEventListener("ActTaskModel_everydaytarget_redpoint", self.checkEverydayTargetRed, self)
        end
	end

	

    -- 开服活动得倒计时
    local kaifuData = FuncActivity.getOnlineFuLiActs()
    local eventKey = "kaifuhuodong_time_"
    for i,v in pairs(kaifuData) do
    	local keyName = eventKey..v:getOnlineId()
    	local leftTime = v:getDisplayLeftTime()
    	TimeControler:startOneCd(keyName,leftTime+2)
    	EventControler:addEventListener(keyName, self.kaifuActTimeOver, self)
    end
end

function ActTaskModel:kaifuActTimeOver()
	-- 判断红点
	self:checkRedPoint( )
	-- 刷新UI
	ActKaiFuModel:getQianggouData( )
	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_KAIFU_TIMEOVER)
	ActTaskModel:checkTimeEvnt( ) 
end

function ActTaskModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncActivity" then
		self:checkAndDoInitOnlineActs()
		self:checkTodoNums()
	end
end

--每日目标是否显示
function ActTaskModel:checkEverydayShow( )
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERYDAYTARGET) then
		return false
	end
	local alldata = FuncActivity.getEverydayActs()
	local createTime = UserModel:ctime()
	local openDays = UserModel:getCurrentDaysByTimes(createTime)
	local currentData = alldata[openDays]
    if not currentData then
    	return false
    end

    return true
end

--每日目标的红点
function ActTaskModel:getEverydayTargetRed( )
	-- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.WuLingMainView) then
	-- 	return false
	-- end

	local alldata = FuncActivity.getEverydayActs()
	local createTime = UserModel:ctime()
	local openDays = UserModel:getCurrentDaysByTimes(createTime)
    local currentData = alldata[openDays]
    if not currentData then
    	return false
    else
    	local onlineId = currentData:getOnlineId()
    	local actData = currentData:getActInfo()
    	local actTaskId = actData.taskList[1]
    	local actType = currentData:getActType()
    	if ActTaskModel:isTaskFinished(onlineId, actTaskId, actData) then
    		return false
    	else
    		if ActConditionModel:isTaskConditionOk(onlineId, actTaskId, actType) then
    			return true
    		else
    			return false
    		end
    	end
    end
end

function ActTaskModel:checkEverydayTargetRed( )
	local isRed = self:getEverydayTargetRed()
	-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
	-- {redPointType = HomeModel.REDPOINT.ACTIVITY.EVERYDAYTARGET, isShow = isRed})
	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_EVENTDAYTASK_REFRESH_RED)
end

function ActTaskModel:checkRedPoint( )

	self:checkEverydayTargetRed( )
    self:checkAndDoInitOnlineActs()
	self:checkTodoNums()
end

function ActTaskModel:checkAndDoInitOnlineActs()
	if self._online_acts_inited then return end
	self.onlineActs = FuncActivity.getOnlineFuLiActs()
	self._online_acts_inited = true

	self:checkTodoNums()
end

-- 领取奖励
function ActTaskModel:tryFinishTask(onlineId, taskId)
	ActivityServer:finishTask(
		onlineId, taskId, c_func(self.onFinishTaskOk, self, onlineId, taskId))
end
function ActTaskModel:onFinishTaskOk(onlineId, taskId, serverData)
	local result = serverData.result
	if result and result.data and result.data.reward then
		FuncCommUI.startFullScreenRewardView(result.data.reward)
	end
	self:checkEverydayTargetRed()
	EventControler:dispatchEvent(ActivityEvent.ACTEVENT_FINISH_TASK_OK, {taskId= taskId, onlineId = onlineId})
	self:checkTodoNums()
end



function ActTaskModel:updateData(data)
	ActTaskModel.super.updateData(self, data)
	-- dump(data, "------ActTaskModel:updateData-----");
end

-- 展示主城红点
function ActTaskModel:checkTodoNums()
	local showHomeRedPoint = function(show)
		-- 灵石商店
		local red1 = NewLotteryModel:fuliIsShowRed()
		-- 开服抢购
		local red2 = ActKaiFuModel:kaifuRed()
		-- 抽签
		local red3 = NewSignModel:isNewSignRedPoint()
		-- 体力
		local red4 = WelfareModel:getTiliRed()

		local red5 = RetrieveModel:getRedRot()

		local isRed = red1 or red2 or red3 or red4 or red5 or show
		echo("======福利界面的按钮红点=======",isRed)
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
			{redPointType = HomeModel.REDPOINT.MAPSYSTEM.WELFARE, isShow = isRed})
	end
	-- 新活动的红点
	local showHomeRedPointNewAct = function(show)

		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
			{redPointType = HomeModel.REDPOINT.MAPSYSTEM.ACTIVITYENTRANCE, isShow = show}) -- 新活动红点
	end
	if not self.onlineActs then 
		showHomeRedPoint(false)
		showHomeRedPointNewAct(false)
		return
	end
	showHomeRedPoint(false)
	showHomeRedPointNewAct(false)

	for _, record in pairs(self.onlineActs) do
		local actId = record:getActId()
		local ids = record:getDisplayedTaskIds()
		if record:hasTodoThings(ids) then
			showHomeRedPoint(true)
		end
	end

	for _, record in pairs(self.onlineActs) do
		local ids = record:getNewActTastIds()	
		if record:hasTodoThings(ids) then
			showHomeRedPointNewAct(true)
		end
	end
	
	return
end

function ActTaskModel:doubleIsOpen()
	local onlineActsArr = FuncActivity.getOnlineFuLiActs()
	for _, record in pairs(onlineActsArr) do
		local actId = record:getActId()
		if actId == "20" then
			local timeInfo = record:getTimeInfo()
			local now = TimeControler:getServerTime()
			local left = timeInfo.show_end_t - now
			if left <=0 then
				return false
			else
				return true
			end
		end
	end
	return false
end

--活动的每项任务是否领取了
function ActTaskModel:isTaskFinished(onlineId, taskId, actInfo)
	local key = string.format("%s_%s", onlineId, taskId)
	local data = self._data[key]

	-- dump(self._data,"\n\n\n\n\n\n\n -----@@@@@@@@@@@@@@@@ ActTaskModel ---- self._data")
	-- echo("key ============",key)
	local candoNum = FuncActivity.getTaskCanDoNum(taskId)

	if not data then return false, candoNum end
	local receiveTimes = self:getTaskReceiveTimes(onlineId, taskId, actInfo)
	local leftCanDoNum = candoNum - receiveTimes
	leftCanDoNum = _yuan3(leftCanDoNum<=0, 0, leftCanDoNum)
	return leftCanDoNum <=0, leftCanDoNum
end

function ActTaskModel:getTaskReceiveTimes(onlineId, taskId, actInfo)
	local key = string.format("%s_%s", onlineId, taskId)
	local data = self._data[key]
    if not data then
        return 0
    end
	local count = data.receiveTimes or 0
	if FuncActivity.isActCanReset(actInfo) then
		local now = TimeControler:getServerTime()
		if now > (data.expireTime or 0 ) then
			count = 0
		end
	end
	return count
end

function ActTaskModel:getDataKey(onlineId, taskId)
	return string.format("%s_%s", onlineId, taskId)
end


function ActTaskModel:genActivityRecord(data)
	local record = ActivityRecord.new()
	record:init(data)
	return record
end

function ActTaskModel:jumpToTaskLinkView(taskId)
	local link = FuncActivity.getTaskJumpLink(taskId)
	local linkParams = FuncActivity.getTaskLinkParams(taskId)
	local uiName = WindowsTools:getWindowNameByUIName(link)
	--echo(uiName, link, 'jumpToTaskLinkView000000000000000000000000000000')

	-- 注意开启判断
	local sysName = FuncActivity.getJumpSysName( taskId )
	-- echoError("\n\n\n\n --link,linkParams,uiName,--------",link,linkParams,uiName,sysName)
	if sysName == nil then
		isOpen = true
	else 
		isOpen = FuncCommon.isSystemOpen(sysName)
	end

	echo("sysName ============ ",sysName)

	echo("taskId ============ ",taskId)

	if sysName == "endless" then
		if not isOpen then
			WindowControler:showTips( "主角34级开启无底深渊" )
			return
		end
	else
		if not isOpen then
			WindowControler:showTips( GameConfig.getLanguage("#tid_guild_005") )
			return
		end
	end

	
	
	if uiName then
		if uiName == "GuildMainBuildView" then
			-- 仙盟单独处理
			local isaddGuild = GuildModel:isInGuild()
			if not isaddGuild then
				WindowControler:showTips(GameConfig.getLanguage("#tid_chat_005"))
			else
				GuildControler:getMemberList(3)
			end
		elseif uiName == "EndlessMainView" then
			EndlessControler:enterEndlessMainView()
		else
			WindowControler:showWindow(uiName, unpack(linkParams))
		end
		
	end
end

--打印所有展示的活动信息
function ActTaskModel:dumpActivity()
	local allLeftRecord = FuncActivity.getOnlineFuLiActs();
	for _, record in pairs(allLeftRecord) do

		local actId = record:getActId();
		local onlineId = record:getOnlineId();
		local actInfo = record:getActInfo();
		local actType = record:getActType();

		echo("=====")
		echo("-----Activity id ", tostring( actId ) );
		--所有展示的tasks
		local taskIdArray = FuncActivity.getActDisplayedTaskIds(actId);
		for _, taskId in pairs(taskIdArray) do
			--显示任务id
			local taskConfig = FuncActivity.getActivityTaskConfig(taskId);
			local desTid = taskConfig.desc;
			local desStr = GameConfig.getLanguage(desTid);

			local conditionId = FuncActivity.getTaskConditionId(taskId)

			echo("");
			echo("onlineId ", tostring(onlineId));
			echo(tostring(desStr) , " 任务id ", tostring(taskId), "conditionId ", tostring(conditionId));


			--是不是已经完成了
			local isAlreadyGet = self:isTaskFinished(onlineId, taskId, actInfo);
			echo("已经都领取了 ", tostring(isAlreadyGet));
			
			--可不可领取
			local conditionOk = ActConditionModel:isTaskConditionOk(onlineId, 
				taskId, actType);
			echo("可以领取 ", tostring(conditionOk));
		end

	end
end

return ActTaskModel


