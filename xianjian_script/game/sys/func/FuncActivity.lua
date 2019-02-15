FuncActivity = FuncActivity or {}

FuncActivity.isDebug = false

FuncActivity.ACT_PLATFORMS = {
	IOS = "1",
	ANDROID = "2",
	DEV = "dev",
	ALL = nil,
}

FuncActivity.ACT_OPEN_SERVER_TYPE = {
	ALL = "1", --全区服开启
	INCLUDE = "2", --包含某些区服
	EXCLUDE = "3", --不包含某些区服
}

FuncActivity.ACT_OPEN_STATUS = {
	CLOSE = 0,
	OPEN = 1,
}

FuncActivity.ACT_TIME_LIMIT_TYPE = {
	SERVEROPEN_T = 1, --开服时间
	USERINIT_T = 2, --玩家创建角色时间
	NATURAL_T =3, --自然时间戳
}
									
FuncActivity.ACT_TYPE = {
	TASK = 1,
	EXCHANGE = 2,
}

FuncActivity.ACT_RESET_TYPE = {
	RESET = 1,
	NORESET = 0,
}

FuncActivity.TRACE_TYPE = {
	TRACE = 1,
	NOTRACE = 0,
}

--活动结束后，是否可领
FuncActivity.ACT_END_RECEIVE_TYPE = {
	ON = 1,
	OFF = 0,
}


FuncActivity.TILI_STR = {
	[1] = "你有口福了，这是小蛮亲手做的~",
	[2] = "打烊了！小蛮困了！换个时间再来吧！",
	[3] = "一定要现在吃么~给钱！小蛮就给你做！",
	[4] = "对不起对不起，放错佐料了。这50仙玉，给你作为赔礼啦~",
}





FuncActivity.TRACE_TASK_FUNCS = {
	[500] = "userLevel",
	-- 主线进度
	[600] = "mainLine",
	-- 竞技场排名
	[703] = "pvpRank",
	-- 锁妖塔的层数
	[800] = "towerFloor",
	[1516] = "treasureMaxLevel",
	--拥有X个X星的伙伴
	[2103] = "haveStarOverPartner",
	--x个伙伴达到XX品质
	[2104] = "haveQualityOverPartner",
	--拥有X个XX等级的绝技
	[2107] = "haveUniqueSkillOverPartner",
	--拥有某某伙伴
	[2108] = "havePartner",
	--XX伙伴等级达到XX级
	[2109] = "partnerLevelOver",
	--XX伙伴达到X星
	[2110] = "partnerStarOver",
	--XX伙伴达到XX品质
	[2111] = "partnerQualityOver",
	--XX伙伴绝技达到XX级
	[2112] = "partnerUniqueSkillOver",
	--拥有XX个伙伴
	[2113] = "partnerHave",
	--拥有XX个XX等级的伙伴
	[2114] = "haveLevelOverPartner",
	--X件装备达到XX品质
	[2200] = "haveQualityOverEquips",
	--拥有X套X颜色的神器
	[2300] = "haveArtifactGroup",
	--参加过仙界对决
	[2601] = "hasCrosspeak",	
	-- 通过无底深渊第X关
	[2801] = "reachEndlessFloor",	

	-- 单笔充值达到x仙玉
	[203]	 = "oneCharge",
	-- 累积x天充值达到60仙玉
	[202]	 = "accumulateCharge",
}

local sortByOrder = function(a, b)
	return tonumber(a:getSortOrder()) < tonumber(b:getSortOrder())
end

local config_acts = nil
local config_acts_conditions = nil
local config_acts_tasks = nil
local config_acts_online = nil
local config_acts_spFood = nil

local config_act_rushBuy = nil

function FuncActivity.init()
	config_acts = Tool:configRequire("activity.Activity")
	config_acts_conditions = Tool:configRequire("activity.ActivityCondition")
	config_acts_tasks = Tool:configRequire("activity.ActivityTask")
	config_acts_online = Tool:configRequire("activity.ActivityOnline")
	config_acts_spFood = Tool:configRequire("activity.SpFood")
	config_act_rushBuy = Tool:configRequire("activity.RushBuy")
	config_act_traveler = Tool:configRequire("activity.Traveler") -- 六界游商随机所需数据配表
end

function FuncActivity.getRushBuyConfig( )
	return config_act_rushBuy
end
function FuncActivity.getRushBuyById( id )
	local data = config_act_rushBuy[tostring(id)]
	if not data then
		echoWarn(string.format('config_act_rushBuy:%s config is nil', id))
		return nil
	end
	return data
end

function FuncActivity.checkoutRushBuyOver(days )
	if days < 0 then
		echoWarn("开服天数是负的")
		return false
	end
	if table.length(config_act_rushBuy) >= days then
		return true
	end
	return false
end

function FuncActivity.getRushBuyCostById( day,index )
	local data = FuncActivity.getRushBuyById( day )
	return data["discountPrice"..index]
end

function FuncActivity.getActsConfig()
	return config_acts
end

--获取每日活动得数据
function FuncActivity.getEverydayActs()
    local allActs = FuncActivity.getOnlineActs(true)
    local data = {}
    for i,v in pairs(allActs) do
		-- 需要将每日任务paichu
		if v:getActInfo().uiNumber == 7 then
			table.insert(data,v)
		end
	end
    return data
end

--获得在福利UI中展示的活动
function FuncActivity.getOnlineFuLiActs(exTime)
	local allActs = FuncActivity.getOnlineActs(exTime)
	local data = {}
	for i,v in pairs(allActs) do
		local lineInfo = v:getActOnlineInfo( )
		if lineInfo then
			if lineInfo.welfareShow == 1 then
				if v:getActInfo().uiNumber ~= 7 then
					table.insert(data,v)
				end
			end
		end
	end
	
	return data
end
	

--获得能展示活动, 大类，左边的条条
function FuncActivity.getOnlineActs(exTime)
	local config = config_acts_online
	local activeActs = {}
    local  _version=AppInformation:getAppPlatform();
	for id, info in pairs(config) do
		local actId = info.actId[1]
		--//手工排除掉版署版本的活动
		local open = FuncActivity.checkActShouldShow(info,exTime)
		local actInfo = config_acts[actId]
		if not info.platform then
			info.platform = _version
		end
		if info.platform == _version and open and actInfo then
			local start_t, end_t, show_start_t, show_end_t = FuncActivity.getOnlineActTime(info)
			local data = {
				onlineInfo = info,
				actInfo = actInfo,
				order = actInfo.order,
				actType = FuncActivity.getActType(actInfo.id),
				timeInfo = {
					start_t = start_t,
					end_t = end_t,
					show_start_t = show_start_t,
					show_end_t = show_end_t,
				}
			}
			table.insert(activeActs, ActTaskModel:genActivityRecord(data)) --#################################
		end
	end
	table.sort(activeActs, sortByOrder)
	return activeActs
end

function FuncActivity.getActivityTaskConfig(actTaskId) 
	local config = config_acts_tasks[actTaskId]
	if not config then
		echoError(string.format('activityTask:%s config is nil', actTaskId))
	end
	return config
end

function FuncActivity.getOnlineConfig(onlineId)
	local config = config_acts_online[onlineId]
	if not config then
		echoError(string.format('activityOnline:%s config is nil', onlineId))
	end
	return config
end

-- 根据actId获取onlineConfig
function FuncActivity.getOnlineConfigByActId(actId)
	local onlineConfig = nil

	for id,info in pairs(config_acts_online) do
        for i,v in pairs(info.actId) do
            if v == tostring(actId) and info.shutDown == 1 then
			    onlineConfig = info
                break   
		    end
        end
	end

	return onlineConfig
end

--活动结束后，展示期之前，已完成活动项是否可领取
function FuncActivity.isDisplayedActCanReceiveAfterActEnd(onlineId)
	local onlineConfig = FuncActivity.getOnlineConfig(onlineId)
	return onlineConfig.last == FuncActivity.ACT_END_RECEIVE_TYPE.ON
end














-- ==================================================================================

--限制条件有：平台、渠道、区服、展示的起止时间，活动的起止时间 是否开启开关 
function FuncActivity.checkActShouldShow(onlineInfo,exTime)
	local info = onlineInfo

	local debugReturnFast = false --开启提前返回
	
	-- 等级限制 需要单独做
	local actVisibleByLevel = FuncActivity.checkActivityLevelVisibility(info.actId[1])
	if debugReturnFast and not actVisibleByLevel then return false end

	local isOpen = FuncActivity.onlineActVisibleOpenCondition(info)
	if debugReturnFast and not isOpen then return false end

	local platformOk = FuncActivity.onlineActVisiblePlatformCondition(info)
	if debugReturnFast and not platformOk then return false end

	local channelOk = FuncActivity.onlineActVisibleChannelCondition(info)
	if debugReturnFast and not channelOk then return false end

	local timeOk = true 
	if not exTime then
		timeOk = FuncActivity.onlineActVisibleTimeCondition(info)
	end
	if debugReturnFast and not timeOk then return false end

	local serverOk = FuncActivity.onlineActVisibleServerCondition(info)
	if debugReturnFast and not serverOk then return false end

	local show = actVisibleByLevel and isOpen and platformOk and channelOk and timeOk and serverOk
	-- echo(info.id, actVisibleByLevel, isOpen, platformOk,channelOk, timeOk, serverOk,show, 'checkActShouldShow')
	return show
	--return true
end

function FuncActivity.checkActivityLevelVisibility(actId)
	local config = FuncActivity.getActConfigById(actId)
	local level = config.level or 0
	return level <= UserModel:level()--#################################
end

function FuncActivity.onlineActVisibleOpenCondition(info)
	--检查一键开关
	if info.shutDown == FuncActivity.ACT_OPEN_STATUS.OPEN then
		return true
	end
	return false
end

function FuncActivity.onlineActVisiblePlatformCondition(info)
	--平台判断
	if info.platform then
		if info.platform == FuncActivity.ACT_PLATFORMS.IOS then
			if device.platform ~= "ios" then
				return false
			end
		elseif info.platform == FuncActivity.ACT_PLATFORMS.ANDROID then
			if device.platform ~= "android" then
				return false
			end
		elseif info.platform == FuncActivity.ACT_PLATFORMS.DEV then
			if AppInformation:getAppPlatform() ~= FuncActivity.ACT_PLATFORMS.DEV then
				return false
			end
		end
	end
	return true
end

function FuncActivity.onlineActVisibleChannelCondition(info)
	--渠道判断
	if info.channel then
		if info.channel ~= UserModel:getChannelName() then --#################################
			return false
		end
	end
	return true
end

function FuncActivity.onlineActVisibleServerCondition(info)
	--区服判断
	local serverId = LoginControler:getServerId()..''
	local servers = info.server or {}
	if info.serverType == FuncActivity.ACT_OPEN_SERVER_TYPE.INCLUDE then
		if not table.find(servers, serverId) then
			return false
		end
	elseif info.serverType == FuncActivity.ACT_OPEN_SERVER_TYPE.EXCLUDE then
		if table.find(servers, serverId) then
			return false
		end
	end
	return true
end

function FuncActivity.onlineActVisibleTimeCondition(info)
	--时间限制
	local now = TimeControler:getServerTime()
	
	local start_t, end_t, show_start_t, show_end_t = FuncActivity.getOnlineActTime(info)
	
	if now < show_start_t or now >= show_end_t  then
		return false
	end

	return true
end

function FuncActivity.getOnlineActTime(info)
	local start_t = info['start'] or 0
	local end_t = info['end'] or 0
	if info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.SERVEROPEN_T then
		local serverInfo = LoginControler:getServerInfo()
		local openTime = FuncActivity.getInitDayTime(tonumber(serverInfo.openTime) )
		start_t = start_t + openTime
		end_t = end_t + openTime
	elseif info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.USERINIT_T then

		local openTime = FuncActivity.getInitDayTime( UserModel:ctime() )
		start_t = start_t + openTime
		--#################################
		end_t = openTime + end_t
	elseif info.timeType == FuncActivity.ACT_TIME_LIMIT_TYPE.NATURAL_T then
	end
	local show_start_t = start_t - (info.showStart or 0)
	local show_end_t = end_t + (info.showEnd or 0)
	return start_t, end_t, show_start_t, show_end_t
end

--  当天的初始时间  凌晨4点
function FuncActivity.getInitDayTime( time )
	local data = os.date("*t",time)
	local initTime = 0
	if data.hour >= 4 then
		initTime = time - (data.hour - 4)*3600-data.min*60-data.sec
	else
		initTime = time - (data.hour+20)*3600-data.min*60-data.sec
	end

	return initTime
end

function FuncActivity.getActConfigById(actId)
	local info = config_acts[actId]
	if not info then
		echoError(string.format('activity:%s config is nil', actId))
		return
	end
	return info
end

function FuncActivity.getActConfigByOnlineId(onlineId)
	local onlineConfig = FuncActivity.getOnlineConfig(onlineId)
	local actId = onlineConfig.actId
	return FuncActivity.getActConfigById(actId)
end

function FuncActivity.getActType(actId)
	local taskList = FuncActivity.getActTaskIds(actId)
	if not taskList then
		echoError(string.format("tasklist is nil, activity:%s", actId))
		return
	end
	local taskId = taskList[1]
	local taskInfo = config_acts_tasks[taskId]
	if not taskInfo then
		echoError(string.format("taskInfo is nil, taskId: %s", taskId))
		return
	end
	if taskInfo.type == FuncActivity.ACT_TYPE.EXCHANGE then
		return FuncActivity.ACT_TYPE.EXCHANGE
	end
	return FuncActivity.ACT_TYPE.TASK
end

--活动是否每天能重置
function FuncActivity.isActCanReset(actInfo)
	local reset = actInfo.reset
	if reset == FuncActivity.ACT_RESET_TYPE.NORESET then
		return false
	end
	return true
end

function FuncActivity.getActTaskIds(actId)
	local config = FuncActivity.getActConfigById(actId)
	return config.taskList
end

function FuncActivity.getActTaskConfigById(taskId)
	local config = config_acts_tasks[taskId]
	if not config then
		echoError("task config is nil, taskId: %s",taskId)
		return
	end
	return config
end

--所有可以展示的 taskId 
function FuncActivity.getActDisplayedTaskIds(actId)
	local taskIds = FuncActivity.getActTaskIds(actId)
	local ret = {}

	for _, taskId in pairs(taskIds) do
		local taskShouldShow = FuncActivity.checkTaskShouldShow(taskId)
		if taskShouldShow then
			table.insert(ret, taskId)
		end
	end
	return ret
end

--检查任务领取等级是否满足
function FuncActivity.checkTaskLevel(taskId)
	local config = FuncActivity.getActTaskConfigById(taskId)
	local levelLimit = config.levelLimit
	if levelLimit then
		if tonumber(UserModel:level()) < levelLimit then --#################################
			return false
		else
			return true
		end
	else
		return true
	end
end

--检查任务项是否可以显示
function FuncActivity.checkTaskShouldShow(taskId)
	local config = FuncActivity.getActTaskConfigById(taskId)
	local levelLimit = config.levelLimit
	local level = config.level
	local vipLevel = config.vip
	if vipLevel then
		if tonumber(UserModel:vip()) < vipLevel then --#################################
			return false
		end
	end
	if level then
		if tonumber(UserModel:level()) < level then --#################################
			return false
		end
	end

	local isOnline = FuncActivity.isActivityTaskOnline(taskId);

	if  isOnline == false then 
		return false;
	end 

	return true
end

--检查任务项是否可做
function FuncActivity.checkTaskCanDoByLevel(taskId)
	local config = FuncActivity.getActTaskConfigById(taskId)
	local levelLimit = config.levelLimit
	if levelLimit then
		if tonumber(UserModel:level()) < levelLimit then -- ！！！！！todo 不能调用model数据
			--#################################
			return false
		end
	end
	return true
end

function FuncActivity.getTaskCanDoNum(taskId)
	local isLevelCando = FuncActivity.checkTaskCanDoByLevel(taskId)
	if not isLevelCando then
		return 0
	end
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	local candoNum = taskConfig.times
	return candoNum
end

function FuncActivity.getTaskConditionId(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.condition
end

function FuncActivity.getTaskConditionNum(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.conditionNum
end

function FuncActivity.getTaskConditionParam(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.conditionParam
end

function FuncActivity.getTaskConditionAssist(taskId)
	local taskConfig = FuncActivity.getActTaskConfigById(taskId)
	return taskConfig.conditionAssist
end

function FuncActivity.getTaskCondition(taskId)
	local conditionId = FuncActivity.getTaskConditionId(taskId)
	local config = FuncActivity.getConditionById(conditionId)
	return config
end

--任务的跳转配置
function FuncActivity.getTaskJumpLink(taskId)
	local conditionConfig = FuncActivity.getTaskCondition(taskId)
	local link = conditionConfig.link
	return link
end

function FuncActivity.getTaskLinkParams(taskId)
	local conditionConfig = FuncActivity.getTaskCondition(taskId)
	return conditionConfig.linkParams or {}
end
function FuncActivity.getJumpSysName( taskId )
	local conditionConfig = FuncActivity.getTaskCondition(taskId)
	return conditionConfig.sysName 
end

function FuncActivity.getConditionById(conditionId)
	local config = config_acts_conditions[conditionId..'']
	if not config then
		echoError(string.format("condition is nil, conditionId : %s", conditionId))
	end
	return config
end

--task 是否是追溯的
function FuncActivity.isTaskDataTrace(taskId)
	local config = FuncActivity.getTaskCondition(taskId)
	if tonumber(config.trace) == FuncActivity.TRACE_TYPE.TRACE then
		return true
	else
		return false
	end
end

-- 根据条件ID，获取ActivityTask列表
function FuncActivity.getActivityTaskListByCondition(condId)
	local actTaskList = {}

	for actId,info in pairs(config_acts_tasks) do
		if info.condition and tonumber(info.condition) == tonumber(condId) then
			actTaskList[#actTaskList+1] = actId
		end
	end

	return actTaskList
end

function FuncActivity.getActivityIdByActTaskId(actTaskId)
	local actIdList = {}

	for id,info in pairs(config_acts) do
		if info.taskList then
			local taskList = info.taskList
			for i=1,#taskList do
				if taskList[i] == tostring(actTaskId) then
					actIdList[#actIdList+1] = id
				end
			end
		end
	end

	return actIdList
end

-- 根据ActivityTaskId判断其是否在线
function FuncActivity.isActivityTaskOnline(actTaskId)
	local actIdList = FuncActivity.getActivityIdByActTaskId(actTaskId)
	local platform = AppInformation:getAppPlatform()

	for i=1,#actIdList do
		local actId = actIdList[i]
		local onlineConfig = FuncActivity.getOnlineConfigByActId(actId)

		local open = FuncActivity.checkActShouldShow(onlineConfig)
		if onlineConfig.platform == platform and open then
			return true
		end
	end

	return false
end


--获取今日菜谱时间
function FuncActivity.getDailyTime()
	local time = FuncDataSetting.getDataVector("SpReceivedTime")
	local house = 24
	local index = 1
	local newTime = {}
	for i=1,house do
		local ishave = false
		for k,v in pairs(time) do
			if tonumber(k) == i then
				newTime[index] = {k,v}
				index = index + 1
			end
		end
	end
	return newTime
end
--获取补偿数量
function FuncActivity.getCompensation()
	return FuncDataSetting.getOriginalData("PoisonCompensate")
end

--获取当天数据
function FuncActivity.getInTheDayData()
	local allSpData = config_acts_spFood   --获取所有体力奖励
	local newTab = {} 
	local time_sever = os.date("*t", TimeControler:getServerTime())
	-- dump(time_sever,"11111======")
	math.randomseed(time_sever.day)
	local num = table.length(allSpData)
	local index = 1
	for i=1,100 do
		local ran = math.random(1,num)
		if #newTab == 0 then
			newTab[index] = ran
			index = index + 1
		else
			if index > 4 then
				break
			end
			local ishave = false
 			for x = 1,#newTab do
				if newTab[x] == ran then
					ishave = true
				end
			end
			if not ishave then
				newTab[index] = ran
				index = index + 1
			end
		end
	end

	dump(newTab,"===随机获得数据 = =====",9)
    return newTab
end

--根据类型获食物表得值
function FuncActivity.getValueByParameter(foodid,parameter)
	if foodid == nil or foodid == 0 then
		foodid = 1   --给一个默认值
	end
	local fooddata = config_acts_spFood[tostring(foodid)]
	return fooddata[parameter]
end

-- 根据创角日长 获取随机配表数据
function FuncActivity.getTravelerRandomDataByBornDate(bornDate)
	-- if config_act_traveler[tostring(bornDate)] then
		return config_act_traveler
		-- return config_act_traveler[tostring(bornDate)]
	-- end
end









