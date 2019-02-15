--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 09:48:43
--Description: 嘉年华动态数据类
--


local CarnivalModel = class("CarnivalModel",BaseModel)

-- 任务状态
CarnivalModel.taskStatus = {
	TODO = 1,
	CAN_GET_REWARD = 2,
	HAVE_GOT_REWARD = 3,
}

-- 其他系统与任务id的映射关系
CarnivalModel.otherSystemMapActivityId = {
	["userLevel"] = {},
	["mainLine"] = {},
	["elite"] = {},
	["towerFloor"] = {},
	["finishMainLineTaskNum"] = {},
	["ownFriends"] = {},
	["treasureMaxLevel"] = {},
	["haveStarOverPartner"] = {},
	["haveQualityOverPartner"] = {},
	["haveUniqueSkillOverPartner"] = {},
	["havePartner"] = {},
	["partnerLevelOver"] = {},
	["partnerStarOver"] = {},
	["partnerQualityOver"] = {},
	["partnerUniqueSkillOver"] = {},
	["partnerHave"] = {},
	["haveLevelOverPartner"] = {},
	["haveQualityOverEquips"] = {},
}



-- 注册时钟事件用的事件名字
CarnivalModel.eventName = "CarnivalModel_Event_"
CarnivalModel.haveCheckRedPoint = nil

-- 服务器发送过来的数据
-- 'scheduleId'        // 调度id
-- 'taskId'            // 子任务id
-- 'receiveTimes'      // 领取次数
-- 'expireTime'        // 过期时间
function CarnivalModel:init(d)
	CarnivalModel.super.init(self, d)
	self.modelName = "Carnival"
	-- 当前嘉年华id
	self.currentCarnivalId = FuncCarnival.CarnivalId.SERVICE_OPEN

	self:initData()
	self:registerEvent()

	ActTaskModel:init(d)
end


function CarnivalModel:initData()
	-- self:delayCall(c_func(self.sentHomeRedPoint,self),3)
	-- echo(" _________________ 嘉年华model __________________ ")
	-- if TreasureNewModel:getOwnTreasures() then
	-- self:sentHomeRedPoint()
	-- else
	-- 	self:initData()
	-- end
	if self:getCarnivalLeftTime(self.currentCarnivalId) <= 0 then
		self.currentCarnivalId = FuncCarnival.CarnivalId.SECOND_PERIOD
	end
	-- 初始化themeID
	self.themeIdList = FuncCarnival.getCarnivalContainThemeIdsById(self.currentCarnivalId)
	self.delayTimeToCheckRedPoint = 3
	TimeControler:startOneCd("carnical_check_redpoint",self.delayTimeToCheckRedPoint)
end

-- 注意要在 CarnivalModel:init(d) 函数执行完毕之后才能调用
-- 否则可能出错
function CarnivalModel:getVisibleThemeIds()
	return self.themeIdList
end

function CarnivalModel:getPeriodStatus()
	if self:getCarnivalLeftTime(FuncCarnival.CarnivalId.SERVICE_OPEN) <= 0 then
		return FuncCarnival.CarnivalId.SECOND_PERIOD
	else
		return FuncCarnival.CarnivalId.SERVICE_OPEN
	end
end

--=============================================================================
--Author:      zhuguangyuan
--DateTime:    2017-10-19 09:01:45
--Description: 红点事件逻辑优化
--=============================================================================
-- 发送主城红点事件
function CarnivalModel:sentHomeRedPoint()
	local isShowRedPoint = self:isShowHomeRedPoint()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
   {redPointType = HomeModel.REDPOINT.ACTIVITY.CARNIVAL, isShow = isShowRedPoint})
end

-- 展示主城红点
function CarnivalModel:isShowHomeRedPoint()
	if not self:isCarnivalOpen() then
		return false
	end
	for k,themeId in pairs(self.themeIdList) do
		if self:isShowThemeRedPoint(themeId) then
			return true
		end
	end
	if self:isShowWholeTargetRedPoint() then
		return true
	end
	return false 
end

-- 展示主题红点
function CarnivalModel:isShowThemeRedPoint(themeId)
	local activityIdList = FuncCarnival.getActivitiesByThemeId( themeId )
	for k1,actId in pairs(activityIdList) do
		if self:isShowActivityRedPoint(themeId, actId) then
			return true
		end
	end
	return false 
end

-- 展示活动红点
function CarnivalModel:isShowActivityRedPoint(themeId, activityId)
	local taskList = FuncCarnival.getActivityTaskListByActivityId(activityId)
	for k,taskId2 in pairs(taskList) do
		if self:isShowTaskRedPoint(themeId, taskId2 ) then
			return true
		end
	end
	return false 
end

-- 展示任务红点
function CarnivalModel:isShowTaskRedPoint(themeId, taskId )
	if self:isThemeCanShow(themeId) and self:isThemeCanDoTask(themeId) then
		local status = self:getTaskStatusByTaskId(themeId, taskId) 
		if status == CarnivalModel.taskStatus.CAN_GET_REWARD then
			return true
		end
	end
	return false
end

-- 展示全目标奖励红点
function CarnivalModel:isShowWholeTargetRedPoint()
	local tt = self:getCanGetWholeRewardLeftTime(self.currentCarnivalId) 
	local isHaveGot = self:getGotWholeTargetReward()
	if (tt <= 0) and (not isHaveGot) then
		return true
	end
	return false 
end
--=============================================================================
--=============================================================================

--更新数据
function CarnivalModel:updateData(data)
	CarnivalModel.super.updateData(self,data);
	-- dump(self._data,"更新数据的 self._data")
	-- zanshi
	-- self:checkRedPoint()
	ActTaskModel:updateData(data)
end

--删除数据
function CarnivalModel:deleteData(data) 
end


function CarnivalModel:registerEvent()
	self:registerThemeOpenEvent()	
	self:registerWholeTargetOpenEvent()
	self:registerCarnivalCloseEvent()
	EventControler:addEventListener("carnical_check_redpoint", self.checkHomeRedPoint, self)

	if self.currentCarnivalId == FuncCarnival.CarnivalId.SERVICE_OPEN then
	    -- 用户等级提升
	    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.sentHomeRedPoint, self)
		-- 六界通关
	    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, self.sentHomeRedPoint, self)
		-- 精英通关
	    EventControler:addEventListener(EliteEvent.ELITE_UNIT_TONGGUAN, self.sentHomeRedPoint, self)
		-- 法宝圆满
	    EventControler:addEventListener(TreasureEvent.FABAO_YUANMAN, self.sentHomeRedPoint, self)
	    -- 法宝升星/觉醒/合成
	    EventControler:addEventListener(TreasureNewEvent.UP_STAR_SUCCESS_EVENT, self.sentHomeRedPoint, self)
	    EventControler:addEventListener(TreasureNewEvent.JUEXING_SUCCESS_EVENT, self.sentHomeRedPoint, self)
	    EventControler:addEventListener(TreasureNewEvent.COMBINE_SUCCESS_EVENT, self.sentHomeRedPoint, self)
		--伙伴的数目发生了变化
	    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.sentHomeRedPoint, self)
	    --某一个伙伴升级成功
	    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT, self.sentHomeRedPoint, self)
	    --伙伴的星级提高
	    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT, self.sentHomeRedPoint, self)
	    --品质发生变化
	    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT, self.sentHomeRedPoint, self)
	    --伙伴的技能发生了变化
	    EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT, self.sentHomeRedPoint, self)
	    -- 竞技场排名发生变化
	    EventControler:addEventListener(PvpEvent.PVP_RANK_CHANGED, self.sentHomeRedPoint, self)
	    -- 竞技币发生变化
	    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE, self.sentHomeRedPoint, self)   
	end

    if self.currentCarnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
		-- 购买体力监听
    	EventControler:addEventListener(UserEvent.USEREVENT_BUY_SP_SUCCESS, self.sentHomeRedPoint, self)
    	-- 消耗铜钱监听
    	EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.sentHomeRedPoint, self)
    	--消耗仙玉监听 用于监听仙盟捐献
    	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.sentHomeRedPoint, self)
    	--抽取神器事件
    	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK, self.sentHomeRedPoint, self)
    	--激活或进阶神器
    	EventControler:addEventListener(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED, self.sentHomeRedPoint, self)
    	--竞技场扫荡
    	EventControler:addEventListener(PvpEvent.PVP_SWEEP_SUCCESS_EVENT, self.sentHomeRedPoint, self) 
    	--巅峰竞技场段位积分监听事件
    	EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT, self.sentHomeRedPoint, self)	
	end
end

function CarnivalModel:checkHomeRedPoint( event )
	local eventName = event.name
	-- dump(event,"event")
	TimeControler:removeOneCd( eventName )
	self:sentHomeRedPoint()
end

-- 注册主题开启事件
-- 若还在线则通过cd进行计时并发送开启事件
-- 若开启时不在线，后来再登 则标记最新的作为新开启
function CarnivalModel:registerThemeOpenEvent()
	local openThemeId = nil
	for _,themeId in pairs(self.themeIdList) do
    	local eventName = CarnivalModel.eventName..tostring(themeId)
    	local leftTime = self:getLeftTime(themeId)
    	-- echo("\n\n 注册主题开启事件 themeId,eventName,leftTime -----  ",themeId,eventName,leftTime)
		if leftTime > 0 then 
			TimeControler:startOneCd(eventName, leftTime + 1);
			EventControler:addEventListener(eventName, self.oneThemeOpen, self)
		end
	end
end

-- 注册全目标开启事件
function CarnivalModel:registerWholeTargetOpenEvent()
	local eventName = CarnivalModel.eventName.."CARNIVAL_WHOLE_TARGET_REWARD_OPEN" 
	local leftTime = CarnivalModel:getCanGetWholeRewardLeftTime(self.currentCarnivalId)
    echo("\n\n 注册全目标开启事件 ,eventName,leftTime -----  ",eventName,leftTime)
	if leftTime > 0 then 
		TimeControler:startOneCd(eventName, leftTime + 1);
		EventControler:addEventListener(eventName, self.oneWholeTargetOpen, self)
	end
end

-- 注册嘉年华关闭事件
function CarnivalModel:registerCarnivalCloseEvent()
	local eventName = CarnivalModel.eventName.."CARNIVAL_CLOSE"
	local leftTime = self:getCarnivalLeftTime(self.currentCarnivalId)
    echo("\n\n 注册嘉年华关闭事件 ,eventName,leftTime -----  ",eventName,leftTime)

	if leftTime > 0 then 
		TimeControler:startOneCd(eventName, leftTime);
		EventControler:addEventListener(eventName, self.carnivalClose, self)
	end
end

-- 相对于开启活动时间(北京时间凌晨4点)的出生日期
-- 活动在出生日期后的第2天四点开启，则出生日期 + 3600*24*1 即可得到开启活动的时间戳
-- 活动在出生日期后的第3天四点开启，则出生日期 + 3600*24*2 即可得到开启活动的时间戳
function CarnivalModel:getBornTime(yyyy)
	local bornTime = yyyy 
	if bornTime == nil then
		-- bornTime = TimeControler:getServerTime() + TimeControler.timeDifference --UserModel:ctime()   
		bornTime = UserModel:ctime() + TimeControler.timeDifference 
	end
	local timeStruct = os.date("*t",bornTime)
 	local hour = tonumber(timeStruct.hour)
	local str = TimeControler:turnTimeSec( bornTime, TimeControler.timeType_dhhmmss );
	-- echo("\n\n\n------当前传入 bornTime 的时间----",str)
	local int_day = math.floor(bornTime/(60*60*24))
	if int_day>0 then
	    local dayAndTime = string.split(str,"天")
	    timeArr = string.split(dayAndTime[2],":")
	    if tonumber(timeArr[1]) < 4 then
	    	dayAndTime[1] = dayAndTime[1] - 1 
	    end
	    bornTime = dayAndTime[1]*3600*24 + 4*3600
	else
	    timeArr = string.split(str,":")
	   	if tonumber(timeArr[1]) < 4 then
	    	bornTime = -4*3600
	    end
    end
	local str2 = TimeControler:turnTimeSec( bornTime, TimeControler.timeType_dhhmmss );
	-- echo("\n\n\n------算得 bornTime 的时间----",str2)

    bornTime = bornTime - TimeControler.timeDifference
    return bornTime
end

-- 距离主题开启还剩多少时间
function CarnivalModel:getLeftTime( themeId )
	local timeStart = FuncCarnival.getOpenDayByThemeId( themeId )
	-- local timeEnd = FuncCarnival.getCloseDayByThemeId( themeId )
	local timeType = FuncCarnival.getTimeTypeByThemeId( themeId )

	local bornTime = self:getBornTime()

	-- if timeType == FuncCarnival.LIMIT_TYPE.SERVEROPEN_T then
	-- 	local serverInfo = LoginControler:getServerInfo()
	-- 	timeStart = timeStart + tonumber(serverInfo.openTime)
	-- 	timeEnd = timeEnd + timeStart
	-- elseif timeType == FuncCarnival.LIMIT_TYPE.USERINIT_T then
		timeStart = timeStart + bornTime 
		-- timeEnd = timeEnd + bornTime
	-- elseif timeType == FuncCarnival.LIMIT_TYPE.NATURAL_T then
	-- end

	local currentTime = TimeControler:getTime()
	local openTime = timeStart
	return openTime - currentTime  -- 8*3600
end

-- 可以领取全目标奖励倒计时
function CarnivalModel:getCanGetWholeRewardLeftTime(carnivalId)
	local dayNumber = 6
	if carnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
		dayNumber = 13
	end
	local timeEnd = 3600 * 24 * dayNumber-- 7天嘉年华
	local bornTime = self:getBornTime()

	timeEnd = timeEnd + bornTime
	-- timeEnd = timeEnd + UserModel:ctime()
	local currentTime = TimeControler:getTime()
	local leftTime = timeEnd - currentTime -- 8*3600
	return leftTime 
end

function CarnivalModel:getCarnivalLeftTime(carnivalId)
	local dayNumber = 7
	if carnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
		dayNumber = 14
	end
	local timeEnd = 3600 * 24 * dayNumber-- 7天嘉年华
	local bornTime = self:getBornTime()

	timeEnd = timeEnd + bornTime
	-- timeEnd = timeEnd + UserModel:ctime()
	local currentTime = TimeControler:getTime()
	local leftTime = timeEnd - currentTime -- 8*3600
	return leftTime 
end

function CarnivalModel:getSentCarnivalRewardLeftTime(carnivalId)
	local timeEnd = 3600 * 24 * 8 -- 7天嘉年华
	local bornTime = self:getBornTime()

	timeEnd = timeEnd + bornTime
	-- timeEnd = timeEnd + UserModel:ctime()
	local currentTime = TimeControler:getTime()
	local leftTime = timeEnd - currentTime -- 8*3600
	return leftTime 
end

-- 监听到主题开启事件
function CarnivalModel:oneThemeOpen(event)
    echo("model 里监听到主题开启事件 ---- ",event.name)
    TimeControler:removeOneCd(event.name)
    -- 发送主题开启事件
	EventControler:dispatchEvent(CarnivalEvent.ONE_THEME_OPENED,{themeId = themeId})
end
-- 监听到全目标奖励开启事件
function CarnivalModel:oneWholeTargetOpen(event)
    echo("model 监听到全目标奖励开启事件 ---- ",event.name)
    TimeControler:removeOneCd(event.name)
    -- 发送主题开启事件
	EventControler:dispatchEvent(CarnivalEvent.CARNIVAL_WHOLE_TARGET_REWARD_OPEN,{})
end
-- 监听到嘉年华关闭事件
function CarnivalModel:carnivalClose(event)
    echo("model 监听到嘉年华关闭事件 ---- ",event.name, "CarnivalModel.currentCarnivalId==", self.currentCarnivalId)
    TimeControler:removeOneCd(event.name)
    if self.currentCarnivalId == FuncCarnival.CarnivalId.SERVICE_OPEN then
		self.currentCarnivalId = FuncCarnival.CarnivalId.SECOND_PERIOD
		self.themeIdList = FuncCarnival.getCarnivalContainThemeIdsById(self.currentCarnivalId)
		EventControler:dispatchEvent(CarnivalEvent.CARNIVAL_PERIOD_CHANGED)
	else
		HomeModel._showButton[FuncHome.RIGHTBUTTON_NAME[4]] = false
		EventControler:dispatchEvent(UserEvent.BUTTON_REFRESH_EVENT)
		-- 发送嘉年华关闭事件
		EventControler:dispatchEvent(CarnivalEvent.CARNIVAL_CLOSE,{})
	end	
end
-- 监听到发送邮件事件
function CarnivalModel:sentCarnivalReward(event)
    echo("model 监听到发送邮件事件 ---- ",event.name)
    TimeControler:removeOneCd(event.name)
    -- 调用接口发送邮件
end

--=====================================================
-- 主题
--=====================================================
function CarnivalModel:isCarnivalOpen()
	if self.currentCarnivalId == FuncCarnival.CarnivalId.SERVICE_OPEN then
		return true
	else
		for k,v in pairs(self.themeIdList) do
			if CarnivalModel:isThemeCanDoTask( v ) then
				return true
			end
		end
		return false
	end
end


-- 主题是否可显示
function CarnivalModel:isThemeCanShow( themeId )
	-- 暂时只检测时间条件
	local timeStart = FuncCarnival.getOpenDayByThemeId( themeId ) - 3600 * 24
	local timeEnd = FuncCarnival.getCloseDayByThemeId( themeId )
	local timeType = FuncCarnival.getTimeTypeByThemeId( themeId )
	
	if CarnivalModel:checkTimeValid(timeStart, timeEnd, timeType) then
		return true
	end
	return false
end

-- 主题是否开启（可做任务）
function CarnivalModel:isThemeCanDoTask( themeId )
	-- 暂时只检测时间条件
	local timeStart = FuncCarnival.getOpenDayByThemeId( themeId )
	local timeEnd = FuncCarnival.getCloseDayByThemeId( themeId )
	local timeType = FuncCarnival.getTimeTypeByThemeId( themeId )

	if CarnivalModel:checkTimeValid(timeStart, timeEnd, timeType) then
		return true
	end
	return false
end

-- 检测当前时间是否在开服嘉年华有效时间内
function CarnivalModel:checkTimeValid( timeStart, timeEnd, timeType )
	-- if timeType == FuncCarnival.LIMIT_TYPE.SERVEROPEN_T then
	-- 	local serverInfo = LoginControler:getServerInfo()
	-- 	timeStart = timeStart + tonumber(serverInfo.openTime)
	-- 	timeEnd = timeEnd + timeStart
	-- elseif timeType == FuncCarnival.LIMIT_TYPE.USERINIT_T then
	local bornTime = self:getBornTime()
	timeStart = timeStart + bornTime  
	timeEnd = timeEnd + bornTime
	-- elseif timeType == FuncCarnival.LIMIT_TYPE.NATURAL_T then
	-- end
	local currentTime = TimeControler:getTime()

	if timeStart <= currentTime and currentTime <= timeEnd then
		return true
	end
	return false
end


-- 取得新开启（可做任务）的主题id
function CarnivalModel:getNewOpenThemeId()
	-- dump(self.themeIdList,"\n\n\n\n\n\n\n\n\n\n\n ===================== 所有的主题数据 ")
	for k = #self.themeIdList,1,-1 do
		echo("--------- self.themeIdList[k] -----",self.themeIdList[k])
		if self:isThemeCanShow(self.themeIdList[k]) and self:isThemeCanDoTask(self.themeIdList[k]) then
			echo("开启主题为--- ",self.themeIdList[k])
			return self.themeIdList[k]
		end
	end
end

-- 主题开启特效已经播放过
-- 记录在本地
function CarnivalModel:setEffectPlayed(themeId)
	LS:prv():set("user__CarnivalEffectPlayed__"..tostring(themeId).."__"..UserModel:rid(),"1")
end
-- 检查主题开启特效是否已经播放过
function CarnivalModel:getEffectPlayed(themeId)
	local isEffectPlayed = LS:prv():get("user__CarnivalEffectPlayed__"..tostring(themeId).."__"..UserModel:rid(),"0")
	if isEffectPlayed == "1" then
		return true
	end
	return false
end

-- 全目标奖励已经领取
-- 记录在本地
function CarnivalModel:setGotWholeTargetReward()
	echo("\n\n\n\n___________ 设置已领取终极大奖 ——————————————————————————")
	LS:prv():set("user__Carnival__"..self.currentCarnivalId.."__"..UserModel:rid(),"1")
end

-- 检查全目标奖励是否已经领取
function CarnivalModel:getGotWholeTargetReward()
	local themeId,taskId = 20001,1000000
	if self.currentCarnivalId == FuncCarnival.CarnivalId.SECOND_PERIOD then
		themeId,taskId = 20002,2000000
	end
	local status = CarnivalModel:getTaskStatusByTaskId(themeId,taskId)
	if status == CarnivalModel.taskStatus.HAVE_GOT_REWARD then
		return true
	else
		return false
	end

	-- local isGotWholeTargetReward = LS:prv():get("user__Carnival__"..CarnivalModel.currentCarnivalId.."__"..UserModel:rid(),"0")
	-- if isGotWholeTargetReward == "1" then
	-- 	return true
	-- end
	-- return false
end

--=====================================================
-- 活动
--=====================================================
-- 活动是否可显示
function CarnivalModel:isActivityVisible( activityId )
	-- 等级限制等
end


--=====================================================
-- 任务
--=====================================================
-- 跳转到指定界面
function CarnivalModel:jumpToTaskLinkView(taskId, curThemeId)
	local link = FuncCarnival.getTaskLinkUIById(taskId)
	local linkParams = FuncCarnival.getTaskLinkParamsById(taskId)

	--登录天数  特殊处理
	if link == "102" then
		local ownNum,needNum = CarnivalTaskConditionModel:getTaskConditionProgress(curThemeId, taskId)
		local tips = string.format("再登陆%d天可领取", needNum - ownNum)
		WindowControler:showTips(tips)
		return
	end

	--分享次数  单独处理
	if link == "2901" then
		local ownNum,needNum = CarnivalTaskConditionModel:getTaskConditionProgress(curThemeId, taskId)
		local tips = string.format("再分享%d次可领取", needNum - ownNum)
		WindowControler:showTips(tips)
		return
	end

	local uiName = WindowsTools:getWindowNameByUIName(link)
	
	-- 注意开启判断
	local sysName = FuncCarnival.getJumpSysName( taskId )
	-- echoError("\n\n\n\n --link,linkParams,uiName,--------",link,linkParams,uiName,sysName)
	if sysName == nil then
		isOpen = true
	else 
		isOpen = FuncCommon.isSystemOpen(sysName)
	end

	if not isOpen then
		WindowControler:showTips( GameConfig.getLanguage("#tid_guild_005") )
		return
	end

	if uiName and isOpen then
		if tostring(sysName) == FuncCommon.SYSTEM_NAME.GUILD and not GuildModel:isInGuild() then
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_006"))
			return
		end
		
		if linkParams then
			WindowControler:showWindow(uiName, unpack(linkParams))
		else
			if uiName == "TowerMainView" then
				echo("进入锁妖塔")
				TowerControler:enterTowerMainView()
			elseif uiName == "ShareBossMainView" then
				echo("进入幻境协战")
				ShareBossControler:enterShareBossMainView()
			elseif uiName == "EndlessMainView" then
				EndlessControler:enterEndlessMainView()
			else
				WindowControler:showWindow(uiName)
			end

		end

	end
end

-- 通过任务id判断任务状态
function CarnivalModel:getTaskStatusByTaskId(themeId,taskId)
	-- echo("\n ---- 通过任务id判断任务状态 ---")
	local status = CarnivalModel.taskStatus.TODO

 	local times = self:getTaskCanGetRewardTimes(themeId, taskId)
 	if times == 0 then
 		status = CarnivalModel.taskStatus.HAVE_GOT_REWARD
 		return status
 	end

	-- 未领取或者待做
	local ok = CarnivalTaskConditionModel:isTaskConditionOk(themeId, taskId)
	if not ok then
		status = CarnivalModel.taskStatus.TODO
	else
		status = CarnivalModel.taskStatus.CAN_GET_REWARD
	end
	return status
end

-- 获取可以领取奖励的次数
function CarnivalModel:getTaskCanGetRewardTimes(themeId, taskId)
	local key = string.format("%s_%s", themeId, taskId)
	-- dump(self._data,"self._data === = ")
	local data = self._data[key]
	local haveDoneTimes = 0
	if data then
		haveDoneTimes = data.receiveTimes
	end
	local canDoTimes = FuncCarnival.getTaskCanDoTimesById(taskId)
	return canDoTimes - haveDoneTimes
end

-- 获取全面目标奖励数量
function CarnivalModel:getWholeTargetNum(carnivalId)
	-- 当前只开嘉年华
	-- 返回到这个嘉年华的数据都是当前嘉年华的数据
	-- 所以暂时不需要 carnivalId 这个参数
	-- dump(self._data,"@@@@@ ------ self._data")

	local finishedTaskNum = 0
	local themeIdList = CarnivalModel:getVisibleThemeIds()
	for k,v in pairs(self._data) do
		if table.indexof(themeIdList, tostring(v.scheduleId)) then
			finishedTaskNum = finishedTaskNum + 1
		end
	end
	
	-- echo("finishedTaskNum================= ",finishedTaskNum)
	return finishedTaskNum
end


--=====================================================
-- 与服务器交互 领取奖励
--=====================================================
-- 获取任务奖励
-- 服务器不返回奖励信息
-- 通过读取前后端都使用的配表得到相应的奖励进行展示
function CarnivalModel:getTaskReward(themeId, taskId, index)
	if self.haveSentRequest then
		return 
	end
	-- 服务器返回奖励信息
	local function onGotTaskReward(serverData)
		local result = serverData.result
		if result then
			-- dump(result,"领取奖励后的信息  --- ")
			if result.data and result.data.reward then
				FuncCommUI.startFullScreenRewardView(result.data.reward)
				
				-- 检查是否删除相应的红点
				-- CarnivalModel:removeRedPoint(themeId,taskId)
				EventControler:dispatchEvent(CarnivalEvent.GOT_ONE_TASK_REWARD,{themeId = themeId, taskId = taskId})
				self.haveSentRequest = false
			end
		end
		if serverData.error then
			-- 领取次数到达上限
			if serverData.error.code == 360103 then
				EventControler:dispatchEvent(CarnivalEvent.GOT_ONE_TASK_REWARD,{themeId = themeId, taskId = taskId})
				self.haveSentRequest = false
			end
		end
		EventControler:dispatchEvent(CarnivalEvent.CARNIVAL_OPTION_REWARD_CALLBACK)
	end
	self.haveSentRequest = true 
	CarnivalServer:getTaskReward(themeId, taskId, c_func(onGotTaskReward), index)
end

-- 获取全目标奖励
-- 服务器返回奖励信息
function CarnivalModel:getWholeTargetReward()
	-- 服务器返回奖励信息
	local function onGotWholeTaskReward(serverData)
		local result = serverData.result
		if result then
			-- dump(result,"领取奖励后的信息  --- ")
			if result.data and result.data.reward then
				FuncCommUI.startRewardView(result.data.reward)
				-- self:setGotWholeTargetReward()
				EventControler:dispatchEvent(CarnivalEvent.GOT_WHOLE_TASK_REWARD,{})
			end
		end
	end

	if self:getWholeTargetNum(self.currentCarnivalId) > 0 then
		self.wholeTargetThemeId = FuncCarnival.getCarnivalWholeTargetIdsById(self.currentCarnivalId)

		local acts = FuncCarnival.getActivitiesByThemeId( self.wholeTargetThemeId )
		for _,act in pairs(acts) do
			local taskList = FuncCarnival.getActivityTaskListByActivityId(act)
			self.wholeTargetTaskId = taskList[1]
			-- echo("--------- self.wholeTargetTaskId,taskList[1]---------",self.wholeTargetTaskId,taskList[1])
		end
		local themeId = self.wholeTargetThemeId
		local taskId = self.wholeTargetTaskId
		CarnivalServer:getWholeTargetReward(themeId,taskId,c_func(onGotWholeTaskReward))
	else
		WindowControler:showTips("没有可领取的奖励")
	end
	
end

function CarnivalModel:setLastPeriod(_lastPeriod)
	self.lastPeriod = _lastPeriod
end

function CarnivalModel:getLastPeriod()
	return self.lastPeriod or self.currentCarnivalId
end

function CarnivalModel:getCurrentCarnivalId()
	return self.currentCarnivalId
end

return CarnivalModel

