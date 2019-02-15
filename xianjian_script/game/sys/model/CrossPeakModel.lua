
local CrossPeakModel = class("CrossPeakModel", BaseModel)

function CrossPeakModel:init(d)
    CrossPeakModel.super.init(self, d)
	self.data = d
	-- dump(d," ----- 巅峰竞技场-------------",8)
	self:registerEvent()

	if self.data.activeRewardExpireTime then
		local serverTime = TimeControler:getServerTime()
		local leftTime = self.data.activeRewardExpireTime - serverTime
		if leftTime < 0 then 
			self:clearData()
		else
			TimeControler:startOneCd("CrossPeakDataClear", leftTime + 1 );
			EventControler:addEventListener("CrossPeakDataClear", self.clearData, self);
		end
	end

	-- 赛季到期刷新
	local seasonLeftTime = self:getSeasonLeftTime()
	TimeControler:startOneCd("CrossPeakSeasonRefrensh", seasonLeftTime + 1 );
	EventControler:addEventListener("CrossPeakSeasonRefrensh", self.CrossPeakSeasonRefrensh, self);

	self.battSem = self:getMaxSegment()
	
	self:requestRank()
	local refreshNextRenwuTime = CrossPeakModel:nextRenwuRefreshTime( )
	if refreshNextRenwuTime > 0 then
		TimeControler:startOneCd(CrossPeakEvent.CROSSPEAK_RENWU_SHUAXIN_EVENT, refreshNextRenwuTime + 1);
		EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_RENWU_SHUAXIN_EVENT, self.renwuShuaxin, self); 
	end

	-- 赛季结束 数据重置
	local seasonLeftT = self:getSeasonOverLeftTime()
	if seasonLeftT > 0 then
		TimeControler:startOneCd("CrossPeakSeasonOver", seasonLeftT);
		EventControler:addEventListener("CrossPeakSeasonOver", self.clearSeasonData, self);
	end

	self:onChkSendOpenTime()
end

-- 获取赛季结束的剩余时间
function CrossPeakModel:getSeasonOverLeftTime()
	-- 赛季时长是自然月
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime)
    -- 今天是几号
    local day = data.day
    local monthDays = CrossPeakModel:getMonthDays(data ) 
    local leftD = monthDays - day
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
    local leftTime = 0
    -- 下个月 1号5点
    if data.day == 1 and data.hour < 5 then
    	leftTime = 5 * 3600 - currentMiao 
    else
    	leftTime = leftD*24*3600 + 24*3600 - currentMiao + 5 * 3600
    end
	
    echo("leftTime === ",leftTime)

    return leftTime
end

function CrossPeakModel:clearSeasonData( )
	local curSeg = self:getCurrentSegment()
	local jcSeg = FuncCrosspeak.getSegmentDataByIdAndKey(tostring(curSeg),"inheritSegment")
	local jcScore = FuncCrosspeak.getSegmentMinScore( jcSeg )

	self.data.score = jcScore
	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT)
end

function CrossPeakModel:renwuShuaxin( event )
	self:requestRank()
end

function CrossPeakModel:CrossPeakSeasonRefrensh( event )
	self:clearCrossPeakData()
	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_SEASON_OVER_EVENT)
end

-- 注册监听事件
function CrossPeakModel:registerEvent(  )
    -- 匹配成功
	EventControler:addEventListener("notify_crosspeak_match_success",self.matchSucceed, self);
	-- 取消匹配成功
	EventControler:addEventListener("notify_crosspeak_match_quxiao_5918",self.matchQuxiao, self);
    -- 匹配失败
    EventControler:addEventListener("notify_crosspeak_match_failed_5920",self.matchFailed, self);
    -- 触发挑战事件
    EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_TRIGGER_MATCH_EVENT,self.tiaozhanAction, self);
    -- 断网
    EventControler:addEventListener(NetworkEvent.SERVER_ON_CLOSE,self.doCloseViewForServerClose,self)
    -- 跨天重新更新消息
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.onChkSendOpenTime,self)
    -- 活动开启消息推送推送
    for i=1,2 do
	    EventControler:addEventListener("notify_crosspeak_time"..i,self.notifyTimeOpen,self)
    end
end
function CrossPeakModel:notifyTimeOpen( ... )
	EventControler:dispatchEvent(HomeEvent.LIMIT_NEXT_UI,{_type = FuncCommon.SYSTEM_NAME.CROSSPEAK})
end
function CrossPeakModel:onChkSendOpenTime(  )
	TimeControler:removeOneCd("notify_crosspeak_time1")
	TimeControler:removeOneCd("notify_crosspeak_time2")
	-- 到达开启时间校验
	local isOpen,timeArr = self:isActionTimeOpen()
	if timeArr then
		for k,v in pairs(timeArr) do
			--仙界对决开启后的推送
			TimeControler:startOneCd("notify_crosspeak_time"..k,v)
			echo ("仙界对决时间开启推送",v)
		end
	end
end
-- 匹配相关消息
function CrossPeakModel:matchSucceed(event)
	if event.error == nil then
		dump(event.params,"__matchSucceed")
		--wk 加了一个battleLabel判断
		local battleLabel = event.params.params.data.battleLabel 
		if  battleLabel == GameVars.battleLabels.crossPeakPvp2 then
			ServerRealTime:startConnect( event.params.params.data,c_func(self.onBattleStart,self)  )
		end
		
	end
end

function CrossPeakModel:onBattleStart( event )
	echo("battleStart----")
	if not event.result then
		echoError("___战斗开始报错")
		EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_FAILED_EVENT)
		return
	end
	local data = event.result.data
	-- 显示刷新
	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_SUCCEED_EVENT)
	
	--这里需要开始修改流程

	local serverData = data
	-- serverData.battleLabel = GameVars.battleLabels.crossPeakPvp
	local battleInfo = BattleControler:turnServerDataToBattleInfo(serverData)
	BattleControler:startBattleInfo(battleInfo);
end


-- 匹配取消
function CrossPeakModel:matchQuxiao( event )
	if event.error == nil then
		EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_FAILED_EVENT)
	end
end

function CrossPeakModel:matchFailed(event)
    EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_MATCH_FAILED_EVENT)
end
-- 判断当前是否在开启时间内
function CrossPeakModel:isActionTimeOpen( )
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime)
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
    local openTime = FuncCrosspeak.getArossPeakOpenTime() or {}
    local isOpen = false
    for i,v in pairs(openTime) do
    	if v.timestart <= currentMiao and v.timeend > currentMiao then
    		isOpen = true
    		break
    	end
    end
    -- echo("dd==",data.hour,data.min,data.sec,currentMiao)
    -- dump(openTime,"s====")
    -- 还有多少秒到达开启时间
    local _timeArr = {}
    -- if not isOpen then
	    for i,v in pairs(openTime) do
	    	if currentMiao <= v.timestart  then
	    		local tmp = v.timestart - currentMiao
	    		table.insert(_timeArr,tmp)
	    	end
	    end
    -- end
    -- dump(_timeArr,"s===")
    return isOpen,_timeArr
end

function CrossPeakModel:tiaozhanAction( event )
	-- 判读是否在开启时间范围内
    local isOpne = self:isActionTimeOpen( )
	if not isOpne then
		WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2025"))
		return
	end
	-- 首先判断是否可以挑战
	local tiems = 1--CrossPeakModel:getCurrentSYTimes()
	-- 是否 进布阵
	local buzhen = true
	if event then
		buzhen = event.params
	end

	-- 判断当前玩法
	local seg = CrossPeakModel:getCurrentSegment()
	local battleModel = FuncCrosspeak.getSegmentDataByIdAndKey(seg,"battleModel")
	if tonumber(battleModel) == 2 then
		buzhen = false
	end

	if not buzhen then
		-- todo  //是否进入布阵 或者 直接匹配
		if CrossPeakModel:checkPKRobot( ) then

            CrossPeakServer:startBattleWithRobot(function(params)
                if params.result then
                    local info = params.result.data.battleInfo
                    local battleInfo = BattleControler:turnServerDataToBattleInfo(info)
                    BattleControler:startBattleInfo(battleInfo)
                end
            end)
        else
        	CrossPeakServer:startMatchServer(c_func(self.tiaozhenTapCallback,self))
        end
		
	else
		WindowControler:showWindow("WuXingTeamEmbattleView", FuncTeamFormation.formation.crossPeak)
		-- if buzhen then
			
		-- elseif tiems <= 0 then
		-- 	WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2026")) 
		-- 	WindowControler:showWindow("CrosspeakBuyView")
		-- end
	end
end
function CrossPeakModel:tiaozhenTapCallback(event)
    if event.result then
        -- 弹出 匹配UI
        echo("弹出 匹配UI-----")
        WindowControler:showWindow("CrosspeakMatchView")
	else
		local code = event.error.code 
		-- if code == 590104 then
		-- 	WindowControler:showTips("匹配失败")
		-- end
	end
end
-- 排行榜的请求
function CrossPeakModel:requestCrossPeakRank( _type,call)
	echo("打开--------排行")
	local isOpne = self:isActionTimeOpen( )
	-- if not isOpne then
	-- 	return
	-- end
	local start = 1
	local length = 20

	if not self.crossPeakRankData then
		self.crossPeakRankData = {}
	end

	if self.crossPeakRankData[_type] then
		length = table.length(self.crossPeakRankData[_type])
		start = start + length
	end
	CrossPeakServer:getCrossPeakRankSever(_type,start,length,c_func(self.requestCrossPeakRankCallBack,self,_type,call) )
end
function CrossPeakModel:requestCrossPeakRankCallBack(rankType,call,event)
	echo(rankType,event,"===========")
	if event.result then
		local sortFunc = function ( a,b )
			if tonumber(a.rank) < tonumber(b.rank) then
				return true
			end
			return false
		end
		-- dump(event.result.data.rankList, "排行榜数据 _______", 5)
		-- echo("rankType ==== ",rankType)

		if event.result.data then
			if self.crossPeakRankData[rankType] then
				for i,v in pairs(event.result.data.rankList) do
					table.insert(self.crossPeakRankData[rankType], v)
				end
				table.sort(self.crossPeakRankData[rankType],sortFunc)
			else
				self.crossPeakRankData[rankType] = {}
				if event.result.data then
					for i,v in pairs(event.result.data.rankList) do
						table.insert(self.crossPeakRankData[rankType], v)
					end
				end
				
				-- self.crossPeakRankData[rankType] = event.result.data.rankList
				table.sort(self.crossPeakRankData[rankType],sortFunc)
			end
			local rank = event.result.data.playerRank
			if rankType == 1 then
				if self:getCurrentRank( ) ~= rank then
					self.currentRank = rank 
					EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RANK_CHANGE_EVENT,rankType)
				end
			else
				self.currentGuildRank = rank
				self.currentGuildScore = event.result.data.playerGuildScore or 0
			end
		end
		
		if call then
			call()
		end
		
	else
		echoError("请求巅峰竞技场排行失败")
	end

	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RANK_RANK_CALLBACK_EVENT)
end

function CrossPeakModel:currentGuildRankAndScore( )
	return self.currentGuildRank,self.currentGuildScore
end

function CrossPeakModel:getCrossPeakRankData( rankType )
	if not self.crossPeakRankData then
		self.crossPeakRankData = {}
	end
	return self.crossPeakRankData[rankType]
end
function CrossPeakModel:clearCrossPeakRankData( )
	self.crossPeakRankData = nil
end

-- 战报列表信息请求
function CrossPeakModel:getReportListData( )
	CrossPeakServer:crossPeakReportListSever(c_func(self.getReportListDataCallBack,self) )
end
function CrossPeakModel:getReportListDataCallBack(event )
	if event.result then
		local data = event.result.data.reports
		-- dump(data, "xxxx _______", 5)
		WindowControler:showWindow("CrosspeakHuiFangView", data)
	end
end

-- 段位处理
function CrossPeakModel:doCloseViewForServerClose(event)
	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_CLOSE_MATCH_UI_EVENT)
end
-- 清空数据倒计时
function CrossPeakModel:clearData()
	self.data.todayTimes = nil
	self.data.activeRewards = nil
end
-- 清空段位相关数据
function CrossPeakModel:clearCrossPeakData( )
	self.data.historyMaxSegment = 1
	self.data.score = 1000
	self.data.maxSegment = 1
	self.data.currSegment = 1
	self.data.todayTimes = nil
end

-- 
function CrossPeakModel:updateData(d)
	-- echoError("-------------巅峰竞技场---------")
    CrossPeakModel.super.updateData(d)
    table.deepMerge(self.data,d)
    dump(d," -----刷新 巅峰竞技场-------------",4)

	
    if d.score then
    	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT)
    	self:requestRank()
    end

	if d.todayTimes then 
    	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_CHALLENGE_TIMESCHANGE_EVENT)
    end

	if d.activeRewards then 
        EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_HET_REWARD_EVENT)
    end

    if d.boxes then
    	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_BOX_STATE_EVENT)
	end

	if d.cpMissionInfo then
		EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RENWU_DATACHANGE_EVENT)
	end

    
    EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RED_POINT_CHANGE_EVENT)
end
--删除数据
function CrossPeakModel:deleteData(data) 
	table.deepDelKey(self.data, data, 1)
	EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RENWU_DATACHANGE_EVENT)
	dump(self.data, "--删除数据--dd====", 5)
end

--记录进战斗段位
function CrossPeakModel:setSegment( segment )
	self.battSem = segment
end
function CrossPeakModel:getSegment( )
	return self.battSem
end

-- 判断是否是单人战斗 即打机器人
function CrossPeakModel:checkPKRobot( )
	local curSeg = self:getCurrentSegment()
	local needNum = FuncCrosspeak.getSegmentDataByIdAndKey(curSeg,"fightRobotNum") or 0
	local curNum = self.data.currSegmentRobotTimes or 0
	-- echoError("当前 打了几场机器人 === ",curNum,needNum,curSeg)
	if curNum >= needNum then
		return false
	end
	return true
end

-- 仙盟击杀奇侠数量
function CrossPeakModel:getGuildKillPartnerNum(  )
	return self.guildKillNum or 0
end
function CrossPeakModel:getGuildKillNum(  )
	if GuildModel:isInGuild() then
		CrossPeakServer:crossPeakGuildKillSever(c_func(self.getGuildKillNumCB,self) )
	end
end
function CrossPeakModel:getGuildKillNumCB( event )
	if event.result then
		self.guildKillNum = event.result.data.beatPartners
	end
end

-- 红点显示
function CrossPeakModel:isShowRed()
	-- 判断当前时间是否开启
	if not CrossPeakModel:isActionTimeOpen( ) then
		return false
	end
	--判断当前是否有可领取奖励
	if CrossPeakModel:isShowSegmentRed() then
		return true	
	end
	--判断当前是否有可领取宝箱
	if CrossPeakModel:isCanGetBoxReward( ) then
		return true
	end
	--判断任务宝箱是否可领取
	if CrossPeakModel:isShowRenWuRed() then
		return true
	end
	return false	
end

function CrossPeakModel:isCanGetBoxReward( )
	for i=1,5 do --目前5个宝箱
		if CrossPeakModel:getBoxStatr( i ) == 3 then
			return true
		end
	end
	return false
end
-- 奖励
function CrossPeakModel:isShowSegmentRed()
	--判断当前是否有可领取奖励
	local data = FuncCrosspeak.getCrossPeakActiveReward()
	for i,v in pairs(data) do
		if self:isShowRedById( v.id ) then
			return true	
		end
	end
	return false	
end
function CrossPeakModel:isShowRedById( id )
	if true then
		return false
	end
    -- 判断是否已领取
    if self.data.activeRewards and self.data.activeRewards[id]  then
        return false
    end
	local data = FuncCrosspeak.getCrossPeakActiveRewardById( id )
	local conditon = data.gainCondition
    conditon = conditon[1]
    local num = conditon.num
    local num1 = 0
    local iscan = false
    if conditon.id == 1 then
        -- 对战次数
        num1 = CrossPeakModel:getTiaozhanNum( )
    elseif conditon.id == 2 then
        -- 胜场次数
        num1 = CrossPeakModel:getWinNum( )
    end 
    if num1 >= num then
    	iscan = true
    end
    return iscan
end
-- 任务红点
function CrossPeakModel:isShowRenWuRed()
	-- 判断任务宝箱是否可领
	local isRed = false
	local boxId = CrossPeakModel:renWuBoxId( )
	if boxId then
		local finishCount = CrossPeakModel:renWuFinishCount( )
		local boxData = FuncCrosspeak.getBoxDataById( boxId )
		local maxCout = boxData.taskNum
		if finishCount >= maxCout then
			return true
		end
	end
	-- 判断小阶段任务是否可领
	local renWuData = CrossPeakModel:renWuData()
	if table.length(renWuData) > 0 then
		for i,v in pairs(renWuData) do
			local _data = FuncCrosspeak.getTastDataById( i )
			if _data then
				local maxNum = _data.needCount
				if tonumber(v) >= tonumber(maxNum) then
					return true
				end
			end
			
		end
	end

	return false

end
-- 当前玩家排名
function CrossPeakModel:getCurrentRank( )
	return self.currentRank or 0
end
function CrossPeakModel:requestRank()
	echo("请求服务器排行========================")
	local isOpen = CrossPeakModel:isSystemOpen()
	if isOpen then
		CrossPeakServer:requestRankServer( c_func(self.requestRankCallBack,self) )
	end
end
function CrossPeakModel:requestRankCallBack( event )
	if event.result then
		local rank = event.result.data.rank 
		self.currentRank = rank 
		EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_RANK_CHANGE_EVENT)
	end
end
function CrossPeakModel:openCrossPeakUI( )
	CrossPeakServer:requestRankServer( c_func(self.requestRankOpenUICallBack,self) )

	-- 打开巅峰的时候请求
	self:getGuildKillNum(  )
end
function CrossPeakModel:requestRankOpenUICallBack(event )
	if event.result then
		local rank = event.result.data.rank 
		self.currentRank = rank 
		WindowControler:showWindow("CrosspeakNewMainView")
	end
end
-- 当前玩家积分
function CrossPeakModel:getCurrentScore()
	return self.data.score or 1000
end
-- 判断玩家是否进行过仙界对决
function CrossPeakModel:checkedDuijue( )
	if self.data.score then
		return true
	end
	return false
end
-- 玩家历史最高段位
function CrossPeakModel:getMaxSegment( )
	return self.data.maxSegment or self:getCurrentSegment()
end
-- 玩家当前段位
function CrossPeakModel:getCurrentSegment()
	return self.data.currSegment or 1--FuncCrosspeak.getCurrentSegment(self:getCurrentScore())
end

-- 通过当前积分获得当前段位id和下一下段位id  下一段位没有传空
function CrossPeakModel:getCurrentAndNextSegByScore(score )
	local data = FuncCrosspeak.getCrossPeakSegmentData()
    local data1 = {}
    for i,v in pairs(data) do
        table.insert(data1,v)
    end
    local sortFunc = function ( a,b )
        if a.scoreMax < b.scoreMax then
            return true
        else
            return false
        end
    end
    table.sort(data1, sortFunc )
    local index = 0
    for i,v in pairs(data1) do
		local scoreMin = FuncCrosspeak.getSegmentMinScore( v.id )
		local scoreMax = FuncCrosspeak.getSegmentMaxScore( v.id )
		if scoreMin <= score and scoreMax >= score then
			index = i
		end
	end
	if index == 0 then
		echoError("当前积分==",score," 没在表里找到对应的段位")
		return "1","2"
	end
	local currentId = data1[index].id
	local nextId = nil
	if data1[index+1] then
		nextId = data1[index+1].id
	end
	return currentId,nextId
end

-- 获得需要上阵人数
function CrossPeakModel:getFightNumMax( )
	return FuncCrosspeak.getSegmentFightNumMax( CrossPeakModel:getCurrentSegment() )
end
function CrossPeakModel:getFightInStageMax( )
	return FuncCrosspeak.getSegmentFightInStageMax( CrossPeakModel:getCurrentSegment() )
end

---------------------------------------------------------------------
-- 活动入口信息
function CrossPeakModel:getActivityData( )
	local isOpen = self:isActivityOpen()
	local openData = {}
	openData.isOpen = isOpen
	openData.crossPeakTxt = FuncCrosspeak.getCrossPeakTxt()
	openData.showReward = FuncCrosspeak.getCrossPeakShowReward( )
	openData.openTime = FuncCrosspeak.getArossPeakOpenTime()

	return openData
end
-- 判断活动是否开启
--[[
1.系统是否开启
2.是否在开启时间区域内
]]
function CrossPeakModel:isActivityOpen()
	if not CrossPeakModel:isSystemOpen() then 
		-- 系统未开启
		return false
	end
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime)
    -- 今天是周几
    local weekD = data.wday - 1
    if weekD == 0 then
        weekD = 7 -- 日期是星期天 开始的
    end
    local openDays = FuncCrosspeak.getArossPeakOpenDay()
    local isOpenDay = false
    for i,v in pairs(openDays) do
    	if weekD == v then 
    		isOpenDay = true
    	end
    end
    if not isOpenDay then 
    	return false
    end
    -- 今天的秒数
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
    local openTime = FuncCrosspeak.getArossPeakOpenTime() or {}
    for i,v in pairs(openTime) do
    	if v.timestart <= currentMiao and v.timeend > currentMiao then
    		return true,v
    	end
    end
    return false
end
---------------------------------------------------------------------------------
-- 新玩法 开启
function CrossPeakModel:getPalyModelOpen( )
	-- 判断新玩法是否开启
	local curSeg = self:getCurrentSegment()
	local isOpen = FuncCrosspeak.getSegmentDataByIdAndKey(tostring(curSeg),"startPlayMethod")
	if isOpen and isOpen == 1 then
		return true
	end
	return false
end
---------------------------------------------------------------------------------
-- 挑战开启时间
function CrossPeakModel:getOpenTimeStr( )
	local openData = self:getActivityData( )
	local openTime = openData.openTime
    local funcSort = function (a,b)
        if (a.timestart) > (b.timestart) then
            return true
        end
        return false
    end
    table.sort( openTime, funcSort )
    local strTime = ""
    for i,v in pairs(openTime) do
        local t1,t2 = math.modf(v.timestart/3600);
        t2 = t2 * 60
        if t2 < 10 then
            t2 = "0"..t2
        end
        local startTime = t1..":"..t2
        local e1,e2 = math.modf(v.timeend/3600);
        e2 = e2 * 60
        if e2 < 10 then
            e2 = "0"..e2
        end
        local endTime = e1..":"..e2
        local str = startTime.."~"..endTime
        strTime = strTime .. str .. " "
    end 
    return strTime
end

-- 获取赛季时间
function CrossPeakModel:getActivityOpenTime()
	-- 赛季时长是自然月
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime)
    -- 今天是周几
    local weekD = data.wday - 1
    if weekD == 0 then
        weekD = 7 -- 日期是星期天 开始的
    end
    local str = string.format("%04d-%02d-%02d",data.year,data.month,data.day)--YYYY-MM-DD
    local startTime = FuncCrosspeak.dataChange(str,-weekD+1)
    local endTime = FuncCrosspeak.dataChange(str,7-weekD)
    -- echoError ("a1===",str,startTime,endTime)
    return startTime,endTime
end

-- 本期剩余挑战次数
function CrossPeakModel:getCurrentSYTimes( )
	local totalNum = FuncDataSetting.getDataByConstantName("CrossPeakFreeTime")
	local num = totalNum - self:getChallengeTimes( ) + self:getCrossBuyTimes( )
	return num
end
-- 本期剩余时间
function CrossPeakModel:getSeasonLeftTime(  )
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
    -- 今天是几号
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
    local day = data.day
    local setHour = 5
    if day == 1 and data.hour < setHour then
    	local leftTime = setHour*60*60 - currentMiao
    	return leftTime
    end
    
    local monthDays = CrossPeakModel:getMonthDays(data) 
    local leftTime = (monthDays - day + 1) * 24*60*60 - currentMiao + setHour*60*60

    return leftTime
end

-- 取每个月的天数
function CrossPeakModel:getMonthDays(timeData )
	local day31 = {1,3,5,7,8,10,12}
	local day30 = {4,6,9,11}
	local month = tonumber(timeData.month)
	if table.indexof(day31,month) then
		return 31
	elseif table.indexof(day30,month) then
		return 30
	else
		local runNianFunc = function ( _year )
			local a4,b4 = math.modf(_year/4)
			if b4 == 0 then
				local a100,b100 = math.modf(_year/100)
				local a400,b400 = math.modf(_year/400)
				if b100 == 0 then
					if b400 == 0 then
						return true
					end
				else
					if b100 > 0 then
						return true
					end
				end
			end
			return false
		end
		local year = tonumber(timeData.month)
		if runNianFunc(year) then
			return 29
		else
			return 28
		end
	end

	return 30
end

-- 当前期挑战次数
function CrossPeakModel:getChallengeTimes( )
	-- 判断当前是第几期
	local openTimes = FuncCrosspeak.getArossPeakOpenTime()
	local serverTime = TimeControler:getServerTime()
    local data = os.date("*t", serverTime)
    -- 今天的秒数
    local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec

    -- 对开启时间进行排序 时间小的在前
    local sortFunc = function ( a,b )
    	if a.timestart < b.timestart then
    		return true
    	end
    	return false
    end
    table.sort( openTimes, sortFunc )
	
	local currentIndex = 1
	for i,v in pairs(openTimes) do
		if v.timestart <= currentMiao and v.timeend > currentMiao then
			currentIndex = i
		end
	end

	local tzNum = 0
	if self.data and self.data.todayTimes then
		tzNum = self.data.todayTimes[tostring(currentIndex)] or 0
	end

	return tzNum
end

-- 已购买的挑战次数
function CrossPeakModel:getCrossBuyTimes( )
	return CountModel:getCrossBuyNum()
end

-- 胜利次数
function CrossPeakModel:getWinNum( )
	return CountModel:getCrossWinNum()
end

-- 击倒奇侠次数
function CrossPeakModel:getJidaoNum( )
	return CountModel:getCrossKillPartnerNum()
end
-- 今天挑战次数
function CrossPeakModel:getTiaozhanNum( )
	return CountModel:getCrossZhanNum()
end
-- 今天的总挑战次数
function CrossPeakModel:getAllTZNumToday( )
	local num = 0 
	local tiems = nil
	if self.data and self.data.todayTimes then
		tiems = self.data.todayTimes
	end
	for i,v in pairs(tiems) do
		num = num + v
	end

	return num 
end
-----------------------------------------------------------------
-- 奖励相关数据
-- 活跃度获取奖励数据
function CrossPeakModel:getActivityRewardData()
 	-- 挑战次数
 	local challengeTimes = self:getTiaozhanNum()
 	-- 胜利次数
 	local winTimes = self:getWinNum( )

 	local rewardData = {}
 	
 	local activityRewardData = FuncCrosspeak.getCrossPeakActiveReward()
 	for i,v in pairs(activityRewardData) do 
 		local enough = self:isCanGetActivityReward(v.id,challengeTimes,winTimes)
 		local data = {}
 		data.enough = enough
 		data.id = v.id
 		data.reward = v.reward
 		table.insert(rewardData,data)
 	end

 	local _sortFunc = function (a,b)
 		if a.enough == b.enough then 
 			if tonumber(a.id) < tonumber(b.id) then
 				return true
 			else
 				return false
 			end
 		elseif a.enough and not b.enough then 
 			return true
		elseif not a.enough and b.enough then 
			return false
		else
			return false
 		end
 	end
 	table.sort(rewardData,_sortFunc)

 	return rewardData
end 
-- 判断奖励是否可以领取
function CrossPeakModel:isCanGetActivityReward(_id,_chaTimes,_winTimes)
	local data = FuncCrosspeak.getCrossPeakActiveRewardById( _id )
	local condition = data.gainCondition
	for i,v in pairs(condition) do
		---1=今天的对战次数，2=今天的胜利次数
		if v.id == 1 then
			if v.num > _chaTimes then
				return false
			end
		elseif v.id == 2 then 
			if v.num > _winTimes then
				return false
			end
		else
			echoError("配错了没有类型",id)
			return false
		end
	end
	-- 判断是否已领取
	if self:getActivityReward(_id ) then
		return false
	end
	return true
end

-- 判断奖励是否已领取
function CrossPeakModel:getActivityReward(id )
	if self.data and self.data.activeRewards then
		if self.data.activeRewards[tostring(id)] and 
        tonumber(self.data.activeRewards[tostring(id)]) > 0 then
			return true
		end
	end
	echo("-----------------false----------")
	return false
end
---------------------------------------------------------------------
--系统是否开启
function CrossPeakModel:isSystemOpen()
	return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CROSSPEAK)
end

function CrossPeakModel:getHistoryMaxSegment()
	return self.data.historyMaxSegment or 1
end

----------------------宝箱数据----------------------------
function CrossPeakModel:getBoxData( )
	return self.data.boxes
end
function CrossPeakModel:getBoxDataByIndex(boxIndex)
	return self.data.boxes[tostring(boxIndex)]
end
function CrossPeakModel:getBoxStatr( boxIndex )
	local boxData = CrossPeakModel:getBoxData( )
	if boxData and boxData[tostring(boxIndex)] then
		if boxData[tostring(boxIndex)].unlockFinishTime then
			local currentTime = TimeControler:getServerTime()
			if currentTime >= boxData[tostring(boxIndex)].unlockFinishTime then
				return 3 -- 可领取状态
			else
				return 2
			end
		else
			return 1
		end
	else
		-- 没有
		return 4
	end
end

-- 1当前没有解锁中的状态
-- 2当前有解锁中的宝箱and非解锁中的宝箱
-- 3当前有解锁中的宝箱and解锁中的宝箱
-- 4当前宝箱可领取
-- 5当前有可领取宝箱
function CrossPeakModel:checkBoxUnlockByIndex( boxIndex )
	local boxData = CrossPeakModel:getBoxData( )
	local unlockinkData = nil
	for i,v in pairs(boxData) do
		if v.unlockFinishTime then
			unlockinkData = v
		end
	end
	if unlockinkData then
        local currentTime = TimeControler:getServerTime()
		if unlockinkData.index == boxIndex then
			
			if currentTime >= unlockinkData.unlockFinishTime then
				return 4
			else
				return 3
			end
		else
            if currentTime >= unlockinkData.unlockFinishTime then
				return 5
			else
				return 2
			end
		end
	else
		return 1
	end
	
end
-- 判断是否达到了今天的宝箱上限
function CrossPeakModel:isGetBoxMax( )
	local getBoxNum = CountModel:getCrossGetBoxNum()
    local maxBoxNum = FuncDataSetting.getCrosspeakMaxBoxNum(  )
    if getBoxNum >= maxBoxNum then
    	return true
    end
    return false
end
function CrossPeakModel:jiasuBoxUnlock(boxIndex)
	local boxData = CrossPeakModel:getBoxDataByIndex(boxIndex)
	local currentTime = TimeControler:getServerTime()
	
	local leftTime = 0
	if boxData.unlockFinishTime then
		leftTime = boxData.unlockFinishTime - currentTime
	else
		local dataCfg = FuncCrosspeak.getBoxDataById( boxData.boxId )
		leftTime = dataCfg.unlockNeedTime
	end
	local haveXianqi = UserModel:getCrossPeakCoin()

	local xianqiTime = FuncDataSetting.getCrosspeakXianqiNum(  )

	local allNum = math.ceil(leftTime/xianqiTime)

	local allTime = haveXianqi * xianqiTime
	if haveXianqi >= allNum then
		return true,haveXianqi,allNum
	end

	return false,haveXianqi,allNum
end
-- 加速消耗的仙气是否满足
function CrossPeakModel:isBoxCostEnough(boxIndex)
	local boxData = CrossPeakModel:getBoxDataByIndex(boxIndex)
	local currentTime = TimeControler:getServerTime()
	
	local leftTime = 0
	if boxData.unlockFinishTime then
		leftTime = boxData.unlockFinishTime - currentTime
	else
		dump(boxData, "=======-=====", 5)
		local dataCfg = FuncCrosspeak.getBoxDataById( boxData.boxId )
		leftTime = dataCfg.unlockNeedTime
	end
	local haveXianqi = UserModel:getCrossPeakCoin()
	local haveXianyu = UserModel:getGold()

	local xianqiTime = FuncDataSetting.getCrosspeakXianqiNum(  )
	-- local xianyuTime = FuncDataSetting.getCrosspeakXianyuNum(  )

	local allTime = haveXianqi * xianqiTime
	if allTime >= leftTime then
		return true
	end

	return false,leftTime,leftTime - allTime
end
-- 新增奇侠
function CrossPeakModel:getNewAddPartnerByLevelId(_levelId )
    local batMpdel = FuncCrosspeak.getBattleModel( _levelId )
    -- echo("batMpdel === ",batMpdel)
    if tonumber(batMpdel) == 1 then
    	return self:getZXModelPartners(_levelId)
    elseif tonumber(batMpdel) == 2 then
    	return self:getXKmodelPartners( _levelId )
    end
end

-- 选卡模式的助阵奇侠
function CrossPeakModel:getXKmodelPartners( _levelId )
	-- 当前阶段
	local levelId = _levelId
	local T = {}
	if FuncCrosspeak.getBattleModel(tonumber(_levelId) -1) == 1 then
		local currentT = FuncCrosspeak.getPartersByLevelId(levelId)
		for i,v in pairs(currentT) do
			local _id = FuncCrosspeak.getCrossPeakPartnerBySourceId(v )
			local data = {sid = v,id = _id}
			table.insert(T,data)
		end
	else
		local currentT = FuncCrosspeak.getPartersByLevelId(levelId)
		local lastId = tonumber(levelId) - 1
		local lastT = FuncCrosspeak.getPartersByLevelId(tostring(lastId))
		for i,v in pairs(currentT) do
			if not table.indexof(lastT, v) then
				local _id = FuncCrosspeak.getCrossPeakPartnerBySourceId(v )
				local data = {sid = v,id = _id}
				table.insert(T,data)
			end
		end
	end
	return T
end
-- 自选模式助阵奇侠
function CrossPeakModel:getZXModelPartners(_levelId)
	local _,data = FuncCrosspeak.getCrossPeakOptionPartnerBySegment(_levelId)
	-- local T = {}
	-- for k,v in pairs(data) do
	-- 	local souId = FuncCrosspeak.getCrossPeakPartnerSourceId( v )
	-- 	local d = {sid = souId,id = v}
	-- 	table.insert(T,d)
	-- end
	return data
end

-- 竞技场任务
function CrossPeakModel:renWuData()
	if self.data.cpMissionInfo and
		self.data.cpMissionInfo.missions then
		return self.data.cpMissionInfo.missions
	end

	return {}
end

-- 竞技场任务宝箱id
function CrossPeakModel:renWuBoxId( )
	-- dump(self.data, "-------ddd-------", 5)
	if self.data.cpMissionInfo and
		self.data.cpMissionInfo.missionBoxId then
		return self.data.cpMissionInfo.missionBoxId
	end
	return nil
end
-- 任务完成数量
function CrossPeakModel:renWuFinishCount( )
	if self.data.cpMissionInfo and
		self.data.cpMissionInfo.missionFinishCount then
		return self.data.cpMissionInfo.missionFinishCount
	end
	return 0
end
-- 下一个任务刷新时间
function CrossPeakModel:nextRenwuRefreshTime( )
	-- 判断是否需要刷新
	local allRenwuData = CrossPeakModel:renWuData()
	if table.length(allRenwuData) >= 3 then
		return 0
	end
	if self.data.cpMissionInfo and
		self.data.cpMissionInfo.nestFlushTime then
		echo("self.data.cpMissionInfo.nestFlushTime === ",self.data.cpMissionInfo.nestFlushTime)
		return self.data.cpMissionInfo.nestFlushTime
	end
	-- 明天4点的时间
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	local nextTime = 0
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	if data.hour>=4 then
		nextTime = 3600 * 28 - currentMiao 
	else
		nextTime = 3600 * 4 - currentMiao 
	end
	return nextTime
end
-- 小任务是否可领取
function CrossPeakModel:xiaorenwuRedShow(  )
	local data = CrossPeakModel:renWuData()
	for i,v in pairs(data) do
		local renWuData = FuncCrosspeak.getTastDataById( i )
		local allNum = renWuData.needCount
		local num = v
		if num >= allNum then
			return true
		end
	end
	return false
end

return CrossPeakModel



