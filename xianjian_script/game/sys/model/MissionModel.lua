
local MissionModel = class("MissionModel", BaseModel)

function MissionModel:init(d)
    MissionModel.super.init(self, d)
	self.missionData = d
	self.todayData = nil
	self.weekD = nil
	-- dump(self.missionData, "missiondata--11--", 7)
	self.missioningRewardKey = {}

	MissionModel.eventName = "MissionEvent";
	self.missionState = {
		Finish = 1, -- 结束
		Doing = 2, -- 进行中
		Coming = 3,-- 即将开始
	}

	self.boxStatus = {
		CanGet = 1, -- 可领取
		NotCanGet = 2, -- 不可领取
		Getted = 3, -- 已领取
	}

	
	-- local data = os.date("*t", serverTime)
	-- -- 今天的秒数
	-- local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	-- 下午四点秒数
	if self.missionData.expireTime then
		local serverTime = TimeControler:getServerTime()
		local leftTime = self.missionData.expireTime - serverTime
		if leftTime < 0 then 
			self:clearData()
		else
			TimeControler:startOneCd("MissionDataClear", leftTime + 1 );
			EventControler:addEventListener("MissionDataClear", self.clearData, self);
		end
	end
	
	
end

-- 清空数据倒计时
function MissionModel:clearData()
	-- echoError("MissionModel:clearDa ------ ")
	self.missionData.counts = {}
	self.missionData.rewardBit = 0
	EventControler:dispatchEvent(MissionEvent.BOX_REFRENSH)
end
-- 
function MissionModel:updateData(d)
	-- dump(d,"-----dddddd------",6)
    MissionModel.super.updateData(d)
    if d.counts  then
    	for i,v in pairs(d.counts) do
            -- if self.missionData.counts[i] then
            --     self.missionData.counts[i] = self.missionData.counts[i] + v
            -- else
            --     self.missionData.counts[i] = v
            -- end
            if self.missionData.counts then
            	self.missionData.counts[i] = v
            else
            	self.missionData.counts = {}
            	self.missionData.counts[i] = v
            end
            
    	end
    end
    if d.rewardBit then
    	self.missionData.rewardBit = d.rewardBit
    end
    if d.expireTime then
    	self.missionData.expireTime = d.expireTime
    	if self.missionData.expireTime then
    		local serverTime = TimeControler:getServerTime()
			local leftTime = self.missionData.expireTime - serverTime
			-- echoError("leftTime ------ ",leftTime)
			TimeControler:startOneCd("MissionDataClear", leftTime + 1 );
			EventControler:addEventListener("MissionDataClear", self.clearData, self);
		end
    end
    EventControler:dispatchEvent(MissionEvent.BOX_REFRENSH)
end

-- 通过时间和ID 获取进度
function MissionModel:getMissionJindu(missionId)
	local missionData = FuncMission.getMissionDataById(missionId)
	local missionType = missionData.type

    local counts = self.missionData.counts
    if counts and missionType then
        local key = missionType .. "_" .. self:getMissionFourTimeStamp()
        return counts[key] or 0
    end
    return 0
end

-- 记录当前进入的房间号
function MissionModel:setMissionKey(missionId)
	local missionData = FuncMission.getMissionDataById(missionId)
	local missionType = missionData.type
	local key = missionType .. "_" .. self:getMissionFourTimeStamp()
	
    self.missioningKey = key
end

--[[
	获取当天4点的时间戳
	4点前算作前一天
]]
function MissionModel:getMissionFourTimeStamp()
	local fourHour = 4
	
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	if data.hour < fourHour then
		local preDayTime = serverTime - (24 * 60 * 60)
		data = os.date("*t", serverTime)
	end

	local year = data.year
	local month = data.month
	local day = data.day
	local hour = fourHour
	local min = 0
	local sec = 0

	local timeStamp = os.time({year=year,day=day, month=month,hour=hour, minute=min, second=sec})

	return timeStamp
end

function MissionModel:getMissioningKey()
	return self.missioningKey
end

-- 获取任务信息并排序
function MissionModel:getMissionData()
	local cfgData = FuncMission.getOpenMissionData()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- dump(data, "当前时间 ============ ", 3)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	-- echo("当前的秒数 === ",currentMiao)
	local weekD = data.wday - 1
    if weekD == 0 then
        weekD = 7 -- 日期是星期天 开始的
    end

	-- if self.todayData and self.weekD == weekD then
	-- 	return self.todayData			                     
	-- end
	-- self.weekD = weekD
	-- 获取今天的任务列表
	local todayData = {}
	-- dump(cfgData,"cfgData-----------")
	for i,v in pairs(cfgData) do
		if MissionModel:checkMissionOpen(v) then
			for ii,vv in pairs(v.week) do
				if tonumber(vv) == weekD then
	                -- ii 是v.time数组索引
					local starTime = v.time[ii]
					local times = {}

					if string.find(starTime, ",") then
						times = string.split(starTime,",")
					else
						times[#times+1] = starTime
					end
	                
					for iii,vvv in pairs(times) do
						local _data = {}
						_data.startTime = tonumber(vvv)
						_data.finishTime = tonumber(vvv + v.duration)
						_data.id = v.id
						-- _data.timestr = fmtSecToHHMMSS(vvv)
						table.insert(todayData, _data)
					end
				end
			end
		end
	end
	table.sort(todayData,function ( a,b)
		if a.startTime < b.startTime then
			return true
		else
			return false
		end
	end)
	for i = 1,#todayData do
		todayData[i].index = i
		-- 注册mission开启或关闭的事件
		self:addTimeEventByMission(todayData[i])
	end

	
	-- dump(todayData, "今天的数据", 4)
	self.todayData = todayData
	return self.todayData
end

-- 获取满足条件的所有的轶事数据
function MissionModel:getTodayAllData(  )
	local cfgData = FuncMission.getOpenMissionData()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- dump(data, "当前时间 ============ ", 3)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	-- echo("当前的秒数 === ",currentMiao)
	local weekD = data.wday - 1
    if weekD == 0 then
        weekD = 7 -- 日期是星期天 开始的
    end
    local userLevel = UserModel:level()
	local todayData = {}
	for i,v in pairs(cfgData) do
		local limitLevel = v.limit
		if userLevel >= limitLevel then
			for ii,vv in pairs(v.week) do
				if tonumber(vv) == weekD then
					-- ii 是v.time数组索引
					local starTime = v.time[ii]
					local times = {}

					if string.find(starTime, ",") then
						times = string.split(starTime,",")
					else
						times[#times+1] = starTime
					end
					
					for iii,vvv in pairs(times) do
						local _data = {}
						_data.startTime = tonumber(vvv)
						_data.finishTime = tonumber(vvv + v.duration)
						_data.id = v.id
						-- _data.timestr = fmtSecToHHMMSS(vvv)
						table.insert(todayData, _data)
					end
				end
			end
		end
	end

	return todayData
end

function MissionModel:checkMissionOpen(cfg)
	local userLevel = UserModel:level()
	local limitLevel = cfg.limit
	if limitLevel > userLevel then
		return false
	elseif limitLevel == userLevel then
		return true
	else
		local cfgAllData = FuncMission.getOpenMissionData()
		-- 得到统一玩法的table
		local missT = {}
		for i,v in pairs(cfgAllData) do
			if v.type == cfg.type and v.limit <= userLevel then
				table.insert(missT, v)
			end
		end
		--根据开启等级排序
		function missionSort( a,b )
	        if a.limit < b.limit then
	            return true
	        end
	        return false
	    end
		table.sort(missT,missionSort)
		--判断是否开启
		if missT[#missT].id == cfg.id then
			return true
		else
			return false
		end
	end
end

-- 为id为 mission 的轶事开启计时
function MissionModel:addTimeEventByMission(mission)

    local eventName = MissionModel.eventName .. tostring(mission.id)..tostring(mission.startTime);
    if mission == nil or self:isNeedCdTime(mission) <= 0 then 
        return ;
    end 

    local leftTime = self:isNeedCdTime(mission);

    -- 多1s，省的发消息的时候还没有更新
    TimeControler:startOneCd(eventName, leftTime + 1);
    local _allEvent = {}
	_allEvent[eventName] = mission.id;

    for k, v in pairs(_allEvent) do
    	-- echo("剩余时间 ==== ",leftTime.."_"..k)
        EventControler:addEventListener(k, self.missionUIRefresh, self);     
    end
end
function MissionModel:missionUIRefresh()
	-- echo("yisss 00000000")
	EventControler:dispatchEvent(MissionEvent.MISSIONUI_REFRESH)  
	
end
-- 判断是否需要倒计时的剩余时间
function MissionModel:isNeedCdTime(mission)
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec

	local leftTime = 0 
	if currentMiao >= mission.finishTime then
		leftTime = -1
	elseif currentMiao < mission.finishTime and currentMiao >= mission.startTime then
		leftTime = mission.finishTime - currentMiao
	elseif currentMiao < mission.startTime then
		leftTime = mission.startTime - currentMiao
	end
	return leftTime
end

-- 判断当前是否有开启的任务
function MissionModel:getHasOpenMission(mapSpace)
	if not MissionModel:missionSystemOpen() then
		return nil,nil
	end
	local cfgData = FuncMission.getOpenMissionData()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec

	local todayData = MissionModel:getMissionData()
	for i=1, #todayData do
		if currentMiao >= todayData[i].startTime and currentMiao <= todayData[i].finishTime then
			local missionCfg = FuncMission.getMissionDataById( todayData[i].id )
			local spaceT = string.split(missionCfg.space[1],",")
            if spaceT[1] == mapSpace then
                return spaceT,todayData[i]
            end
		end
	end
	return nil,nil
end

-- 获取开启任务的类型
function MissionModel:getMissionType( mapId)
	local cfgData = FuncMission.getOpenMissionData()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec

	local todayData = MissionModel:getMissionData()
    local openTable = {}
	for i=1, #todayData do
		if currentMiao >= todayData[i].startTime and currentMiao <= todayData[i].finishTime then
			local missionCfg = FuncMission.getMissionDataById( todayData[i].id )
			local spaceT = string.split(missionCfg.space[1],",")
            local _mapId = FuncChapter.getSpaceDataByName(spaceT[1]).map
            if tostring(_mapId) == tostring(mapId) then
                return missionCfg.type
            end
		end
	end
	return 1
end

-- 获取任务显示位置计算
function MissionModel:getMissionPosition( )
	local cfgData = FuncMission.getOpenMissionData()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec

	local todayData = MissionModel:getMissionData()
	for i=1, #todayData do
		if currentMiao >= todayData[i].startTime and currentMiao <= todayData[i].finishTime then
			return i
		end
	end
	-- 此时间段 没有任务开启 找即将开启任务
	local index = 1
	for i=1,#todayData do
		if currentMiao <= todayData[i].startTime then
			if todayData[i].startTime < todayData[index].startTime or todayData[index].startTime < currentMiao then
				index = todayData[i].index
			end
		end
	end
	return index
end

-- 通过ID获取现在进行到的期数
function MissionModel:getMissionIndex(missionId)
	local cfgData = FuncMission.getMissionDataById(missionId)
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- dump(data, "当前时间 ============ ", 3)
	-- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	echo("当前的秒数 === ",currentMiao)
	local weekD = data.wday - 1
    if weekD == 0 then
        weekD = 7 -- 日期是星期天 开始的
    end
 		
 	for index=1,#cfgData.week do
 		if tonumber(cfgData.week[index]) == weekD then
 			local starTime = cfgData.time[index]
 			local times = {}
 			if string.find(starTime, ",") then
				times = string.split(starTime,",")
			else
				times[#times+1] = starTime
			end

			for i=1,#times do
		        local starTime = tonumber(times[i])
		    	if starTime <= currentMiao and starTime+cfgData.duration >= currentMiao  then
		    		return i-1
		    	end
		    end
 		end
 	end

	echoWarn("此时间段没有任务进行")
	return 0
end

--[[
	判断任务是否完成目标
]]
function MissionModel:checkFinishMissionGoal(spaceName)
	-- 如果任务完成，不再显示npc
    local openMissionMapSpace,missionData = self:getHasOpenMission(spaceName)
	if missionData then
		-- 任务状态
    	local missionState,leftTime = MissionModel:getMissionState(missionData)
    	if missionState == self.missionState.Doing then
    		local data = FuncMission.getMissionDataById( missionData.id )
    		local jindu = MissionModel:getMissionJindu(missionData.id,missionData.startTime)
    		local total = data.goalParam
    		echo("jindu--------",jindu,total)
        	if tonumber(jindu) >= tonumber(total) then
        		return true
        	end
    	end
	end

    return false
end

--[[
	获取任务获得的奖励及是否是必得奖励
]]
function MissionModel:getMissionReward(missionId)
	local isMust = true
	local bonus = FuncMission.getProbableReward(missionId)
	local rewardArr = FuncMission.getConfirmReward(missionId)
	if rewardArr == nil then
		isMust = false
	end

	local rewards = {}

	if bonus then
		-- 获取需要的格式
	    for i,v in pairs(bonus) do
	        local strT = string.split(v,",")
	        local str = ""
	        if strT[2] == FuncDataResource.RES_TYPE.ITEM then
	            str = strT[2]..","..strT[3]..","..strT[4]
	        else
	            str = strT[2]..","..strT[3]
	        end
	        
	       	rewards[#rewards+1] = str
	    end
	end
	
	if rewardArr then
		for i=1,#rewardArr do
	    	rewards[#rewards+1] = rewardArr[i]
	    end
	end

    return rewards
end

-- 判断任务状态
function MissionModel:getMissionState(data)
	local serverTime = TimeControler:getServerTime()
	local timedata = os.date("*t", serverTime)
	-- 今天的秒数
	local currentMiao = timedata.hour * 60 * 60 + timedata.min * 60 + timedata.sec
	if currentMiao >= data.startTime and currentMiao < data.finishTime then
		local leftTime = data.finishTime - currentMiao
		return self.missionState.Doing ,leftTime
	elseif currentMiao < data.startTime then
		return self.missionState.Coming,0
	elseif currentMiao >= data.finishTime then
		return self.missionState.Finish,0
	end
end
-- 当前完成的任务数量
function MissionModel:getFinishMissionNum()
	if self.missionData.counts then
        local missionD = MissionModel:getTodayAllData()
        local num = 0
		for i,v in pairs(missionD) do
		    local jindu = MissionModel:getMissionJindu(v.id,v.startTime)
            local dataCfg = FuncMission.getMissionDataById( v.id )
			local total = dataCfg.goalParam
			-- echo("total == ",total,"   === jin =",jindu)
			if jindu >= total then
				num = num + 1
			end
		end
		return num
	end
	return 0
end

-- 获取宝箱状态
function MissionModel:getBoxState(index)
	local rewardT = {}
	if self.missionData.rewardBit  then
		rewardT = number.int2BinaryArray(self.missionData.rewardBit)
	end
	-- dump(rewardT, "-------", 3)
	if rewardT[index] and rewardT[index] == 1 then
		return self.boxStatus.Getted
	else
		local num = MissionModel:getFinishMissionNum()
		-- echoError("当前完成的任务数量 == ",num)
        if num > 0 and num >= index then
            return self.boxStatus.CanGet
        else
            return self.boxStatus.NotCanGet
        end
	end
end 

-- 记录对手ID
function MissionModel:setTarget(id)
    self.target = id
end
function MissionModel:getTarget()
    return self.target
end
-- 记录进行轶事的id
function MissionModel:setDoingMissionId(id)
	self.doingMissionId = id
end
function MissionModel:getDoingMissionId()
	return self.doingMissionId
end

-- 战斗完 是否有奖励  做存储用
function MissionModel:setBattleReward(rt)
	if self.missioningKey ~= nil then
		self.missioningRewardKey[self.missioningKey] = rt
	end
end

function MissionModel:getBattleReward()
	return self.missioningRewardKey[self.missioningKey]
end

-- 过滤服务器返回的NPC数据
function MissionModel:filtrateNpcData( missionData )
	local num = 6
	local data = {}
	for i=1,#missionData do
		if #data < num then
			table.insert(data, missionData[i])
		end
	end

	-- 如果不够 拷贝到10个
	if #data < num then
		while #data < num do
			local v = table.deepCopy(data[1])
			table.insert(data, v)
		end
	end

	return data
end

-- 判断系统是否开启
function MissionModel:missionSystemOpen( )
	return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MISSION)
end
-- 是否显示小红点
function MissionModel:isShowRed()
	for i=1,3 do
		if self:getBoxState(i) == self.boxStatus.CanGet then
			return true
		end
	end
	return false
end

-- 判断当前地标是否有轶事
function MissionModel:isMissionAnimDialog( spaceName,order )
	local openMissionMapSpace,missionData = MissionModel:getHasOpenMission(spaceName)
	if openMissionMapSpace and openMissionMapSpace[1] == spaceName
        and openMissionMapSpace[2] == tostring(order) then
        return true 
    end
    return false
end

--------------------------------------------------
-- 获取答题今天的总得分
function MissionModel:getAllMissionQuestScore()
	-- 答题的missionid
	local data = self:getMissionData()
	local score = 0
	for i,v in pairs(data) do
		local missionType = FuncMission.getMissionTypeById( v.id )
		if FuncMission.MISSIONTYPE.QUEST == missionType then
			score = score + self:getMissionJindu(v.id,v.startTime)
		end
	end
	return score
end
-- 取题
function MissionModel:getMissionQuest( missionData)
	local randseed = self:getRandomSeed( missionData )
	local alldata = FuncMission.getMissionQuestByType( self:getmissionQuestType(randseed ))
	local finishData = MissionModel:getFinishQuset( missionData )

	local data = {}
	for k,v in pairs(alldata) do
		local isNoFinsish = true
		for ii,vv in pairs(finishData) do
			if vv.id == v.id then
				isNoFinsish = false
				break
			end
		end
		if isNoFinsish then
			table.insert(data,v)
		end
	end
	local funcSort = function ( a,b )
		if tonumber(a.id) < tonumber(b.id) then
			return true
		end
		return false
	end
	table.sort(data,funcSort)
	local lenght = table.length(data)
	math.randomseed(randseed)
	local index = math.random(1,lenght)
	echo("正在 答题--=-== ",randseed,data[index].id)
	return data[index]
end
-- 统计10题内已经出现过得题
function MissionModel:getMissionQuestByRandseed( randseed,finishT)
    local allData = FuncMission.getMissionQuestByType( self:getmissionQuestType(randseed ))
    local data = {}
    for k,v in pairs(allData) do
    	if not table.isValueIn(finishT,v) then
    		table.insert(data,v)
    	end
    end
    local lenght = table.length(data)
	math.randomseed(randseed)
	local index = math.random(1,lenght)
    return data[index]
end
function MissionModel:getFinishQuset( missionData )
	local maxFinishNum = 30
	local _,index1 = MissionModel:getQuestLeftTime( missionData )
	
	local a,b = math.modf(index1/(maxFinishNum*15))
	local tTime = FuncMission.questCostTime
	local startNum = index1 - maxFinishNum
	if startNum < 0 then
		startNum = 0
	end

	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	    -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	local finishQuestT = {}
	-- local aa = 1
	index1 = index1 - 1
	echo("已经答题的次数 ==== ",startNum,index1)
	for i=startNum,index1 do
		local randseed = serverTime - currentMiao + i * tTime
		local data = self:getMissionQuestByRandseed( randseed,finishQuestT)
		if data then
			table.insert(finishQuestT, data)
			-- echo("--------------已经答题的id == ",randseed,data.id)
		end
	end
	return finishQuestT
end
--获取难易度
function MissionModel:getmissionQuestType(randseed )
	local jiandan = 60
	local yiban = 30
	local kunnan = 10
	math.randomseed(randseed)
	local index = math.random(1,100)
	if index <= 60  then
		return FuncMission.QUESTTYPE.JIANDAN
	elseif index <= 90 then
		return FuncMission.QUESTTYPE.YIBAN
	elseif index <= 100 then
		return FuncMission.QUESTTYPE.KUNNAN
	end
end
-- 记录当前答题的数量
function MissionModel:addMissionQuestNum(starTime)
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	    -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	local key = "missionquest_"..(serverTime -currentMiao+starTime)

	if not self.questNum then
		self.questNum = LS:prv():get(key,0);
	end
	self.questNum = self.questNum + 1
	LS:prv():set(key,self.questNum);
end
function MissionModel:getMissionQuestNum(starTime)
	if not self.questNum then
		local serverTime = TimeControler:getServerTime()
		local data = os.date("*t", serverTime)
		    -- 今天的秒数
		local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
		local key = "missionquest_"..(serverTime -currentMiao+starTime)
		self.questNum = LS:prv():get(key,0);
	end
	return self.questNum
end
-- 记录答对的数量
function MissionModel:addMissionQuestRightNum(starTime)
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	    -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	local key = "missionrightquest_"..UserModel:rid()..(serverTime - currentMiao+starTime)

	if not self.questRightNum then
		self.questRightNum = LS:prv():get(key,0);
	end
	self.questRightNum = self.questRightNum + 1
	LS:prv():set(key,self.questRightNum);
end
function MissionModel:getMissionQuestRightNum(starTime)
	if not self.questRightNum then
		local serverTime = TimeControler:getServerTime()
		local data = os.date("*t", serverTime)
		    -- 今天的秒数
		local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
		local key = "missionrightquest_"..UserModel:rid()..(serverTime -currentMiao+starTime)
		self.questRightNum = LS:prv():get(key,0);
	end
	return self.questRightNum
end
-- 获取随机种子
function MissionModel:getRandomSeed( missionData )
	local _,index1 = self:getQuestLeftTime( missionData )
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	    -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	local randseed = serverTime - currentMiao + index1 * FuncMission.questCostTime

	return randseed
end

-- 获取当前剩余倒计时
function MissionModel:getQuestLeftTime( missionData )
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	    -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec
	local passTime = currentMiao - missionData.startTime
	
	local tTime = FuncMission.questCostTime
	local index,_time = math.modf(passTime/tTime)
	local _time1 = passTime - index*tTime
	return _time1,index
end

-- 当前倒计时应显示的秒数
function MissionModel:getTimeShow( missionData )
	local leftTime = FuncMission.questCostTime - self:getQuestLeftTime( missionData )
	
	if leftTime > FuncMission.answerCostTime and leftTime <= FuncMission.questCostTime then
		-- 此时是准备阶段
		return 0 
	else
		-- 此时是倒计时阶段
		return leftTime
	end
end

-- 记录当前maporder
-- order Map.csv 同一个地标下对应多个场景
function MissionModel:setMapOrder( map,order )
	self.missionMapOrder = order
	self.missionMap = map
end
function MissionModel:getMapOrder(  )
	return self.missionMap ,self.missionMapOrder
end
function MissionModel:getMissionOrder( mapId )
	if self.missionMap and self.missionMapOrder then
		local spaceName = FuncChapter.getSpaceNameByMapId( mapId )
		if spaceName == self.missionMap then
			return self.missionMapOrder
		end
		self.missionMap = nil
		self.missionMapOrder = nil
	end
	return nil
end

return MissionModel



