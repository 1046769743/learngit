--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 11:37:57
--Description: 嘉年华读取静态数据表函数集
-- 一个嘉年华有多个主题
-- 一个主题有多个活动
-- 一个活动有多个任务

FuncCarnival= FuncCarnival or {}

local carnivalData = nil
local themeData = nil
local activityData = nil 
local taskData 	 = nil
local taskConditionData = nil

-- 所有的嘉年华id
FuncCarnival.CarnivalId = {
	SERVICE_OPEN = 1,
	SECOND_PERIOD = 2,
}

-- 主题开启平台
FuncCarnival.ACT_PLATFORMS = {
	IOS = "1",
	ANDROID = "2",
	DEV = "dev",
	ALL = nil,
}

-- 区服类型
FuncCarnival.ACT_OPEN_SERVER_TYPE = {
	ALL = "1", --全区服开启
	INCLUDE = "2", --包含某些区服
	EXCLUDE = "3", --不包含某些区服
}

-- 主题开启状态
FuncCarnival.ACT_OPEN_STATUS = {
	CLOSE = 0,
	OPEN = 1,
}

-- 主题开启时间类型
FuncCarnival.LIMIT_TYPE = {
	SERVEROPEN_T = 1, --开服时间
	USERINIT_T = 2, --玩家创建角色时间
	NATURAL_T =3, --自然时间戳
}

-- 主题类型									
FuncCarnival.ACT_TYPE = {
	TASK = 1,
	EXCHANGE = 2,
}

-- 主题是否可重置
FuncCarnival.ACT_RESET_TYPE = {
	RESET = 1,
	NORESET = 0,
}

-- 是否追溯
FuncCarnival.TRACE_TYPE = {
	TRACE = 1,
	NOTRACE = 0,
}

--活动结束后，是否可领
FuncCarnival.ACT_END_RECEIVE_TYPE = {
	ON = 1,
	OFF = 0,
}

-- 任务类型
-- 根据不同类型做实时统计，以判断某些任务是否完成
-- 完成则显示相应的红点
FuncCarnival.TRACE_TASK_FUNCS = {
--===============================================================
	[500] = "userLevel",	-- 玩家等级达到X

	[600] = "mainLine",		-- 挑战寻仙副本通过第X关
	[601] = "elite",		-- 挑战问情副本通过第X关
	[602] = "elite",		-- 寻仙副本特等通过X个关卡
--===============================================================

	[703] = "pvpRank",		-- 登仙台排名
--===============================================================

	[800] = "towerFloor",	-- 锁妖塔达到多少层
--===============================================================

	-- [1101] = "finishMainLineTaskNum",	-- 完成主线任务X个

	-- [1200] = "ownFriends",	-- 拥有X个好友

	-- [1300] = "userLevel",	-- 灵脉达到X点X级

--===============================================================
	-- [1500] = "haveTreasure",	-- 拥有XX（ID）的法宝
	-- [1502] = "userLevel",	-- [xx;XX;]法宝的威能达到XX
	-- [1503] = "userLevel",	-- X个法宝的威能达到XX
	-- [1504] = "userLevel",	-- [xx;XX;]法宝的星级达到XX
	[1505] = "haveXXStarTreasureNumXX",	-- X个法宝的星级达到XX
	-- [1506] = "userLevel",	-- [xx;XX;]法宝的等级达到XX
	-- [1507] = "userLevel",	-- X个法宝的等级达到XX
	-- [1508] = "userLevel",	-- [xx;XX;]法宝的等级进阶圆满
	-- [1509] = "userLevel",	-- X个法宝的等级进阶圆满
	[1510] = "haveXXQualityTreasureNumXX",	-- 拥有XX个X品法宝
	-- [1511] = "userLevel",	-- XX个X品法宝养到XX级
	-- [1512] = "haveXXQualityXXStarTreasureNumXX",	-- XX个X品法宝达到X星
	-- [1513] = "userLevel",	-- XX个X品法宝养成圆满
	-- [1514] = "userLevel",	-- 总共激活XX个星耀
	-- [1515] = "userLevel",	-- 已激活[XX;XX;]星耀

	-- [1516] = "treasureMaxLevel", -- 法宝最高等级达到X级

	-- [1900] = "treasureMaxLevel", -- 将XX天赋提升到XX级
	-- [1902] = "treasureMaxLevel", -- 使用过XXX点天赋点
--===============================================================
	[2103] = "haveStarOverPartner", 		--拥有X个X星的伙伴
	[2104] = "haveQualityOverPartner",		--x个伙伴达到XX品质
	[2107] = "haveUniqueSkillOverPartner",	--拥有X个XX等级的绝技
	[2108] = "havePartner",					--拥有XX伙伴
	[2109] = "partnerLevelOver",			--XX伙伴等级达到XX级
	[2110] = "partnerStarOver",				--XX伙伴达到X星
	[2111] = "partnerQualityOver",			--XX伙伴达到XX品质
	[2112] = "partnerUniqueSkillOver",		--XX伙伴绝技达到XX级
	[2113] = "partnerHave",					--拥有XX个伙伴
	[2114] = "haveLevelOverPartner",		--拥有XX个XX等级的伙伴
	-- [2115] = "havePartnerGroup",			--拥有xx奇侠组合（支持多个） 废弃 使用2108
	[2200] = "haveQualityOverEquips",		--X件装备达到XX品质
	[2300] = "haveArtifactGroup",			--拥有X套X颜色的神器
	[2301] = "haveArtifactAdvance",			--X套神器进阶到+X
	[2602] = "achieveCrossPeakSegment",		--是否达到巅峰竞技场段位
}

function FuncCarnival.init(  )
	carnivalData = Tool:configRequire("activity.CarnivalOnline")
	themeData 	 = Tool:configRequire("activity.ActivityOnline")
	activityData = Tool:configRequire("activity.Activity")
	taskData 	 = Tool:configRequire("activity.ActivityTask")
	taskConditionData = Tool:configRequire("activity.ActivityCondition")
end

--=====================================================
-- CarnivalOnline 表 
-- 嘉年华数据相关
--=====================================================
-- 获取嘉年华数据
function FuncCarnival.getCarnivalDataById(carnivalId)
	if carnivalId and carnivalData[tostring(carnivalId)] then
		return carnivalData[tostring(carnivalId)]
	end
	return nil
end

-- 获取某个嘉年华包含的所有主题id
function FuncCarnival.getCarnivalContainThemeIdsById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.scheduleId
	end
	return nil
end
-- 获取某个嘉年华全目标任务的主题id
function FuncCarnival.getCarnivalWholeTargetIdsById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.carnivalScheduleId
	end
	return nil
end

-- 获取某个嘉年华包含的所有主题名字
function FuncCarnival.getCarnivalContainThemeNamesById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.themeName
	end
	return nil
end

-- 获取某个嘉年华的全目标奖励type
function FuncCarnival.getCarnivalWholeTargetRewardTypeById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.rewardType
	end
	return nil
end

-- 获取某个嘉年华的全目标奖励物品id
function FuncCarnival.getCarnivalWholeTargetRewardIdById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.itemId
	end
	return nil
end

-- 获取某个嘉年华的全目标奖励基础数量（每完成一次任务获得的奖励数量）
function FuncCarnival.getCarnivalWholeTargetRewardBaseCountById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	if data then
		return data.baseCount
	end
	return nil
end

-- 获取某个嘉年华的全目标奖励总数量
function FuncCarnival.getCarnivalWholeTargetRewardMaxCountById(carnivalId)
	local data = carnivalData[tostring(carnivalId)]
	local baseCount = FuncCarnival.getCarnivalWholeTargetRewardBaseCountById(carnivalId)
	if data then
		return data.maxCount / baseCount
	end
	return nil
end



-- 根据嘉年华id 和 主题id获取主题名字
function FuncCarnival.getCarnivalNameByThemeId(carnivalId, themeId )
	local themeIds = FuncCarnival.getCarnivalContainThemeIdsById(carnivalId)
	local names = FuncCarnival.getCarnivalContainThemeNamesById(carnivalId)
	-- dump(themeIds,"themeIds = ")
	-- dump(names,"names = ")

	for k,v in pairs(themeIds) do
		-- echo("v ---- ",v)
		-- echo("themeId ---- ",themeId)

		if tostring(v) == tostring(themeId) then
			return names[k]
		end
	end
	
	echoError("------ 找不到对应id的主题的名字----",themeId)
	return nil
end





--=====================================================
-- ActivityOnline 表 
-- 主题开启结束相关
--=====================================================
-- 获取某个主题下的所有活动id
function FuncCarnival.getActivitiesByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.actId
	end
end

-- 主题开启平台
function FuncCarnival.getPlatformByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.platform 
	end
end
-- 主题开启渠道
function FuncCarnival.getChannelByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.channel 
	end
end

-- 主题开启区服类型
function FuncCarnival.getServerTypeByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.serverType 
	end
end

-- 主题开启服务器
function FuncCarnival.getServerByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.server 
	end
end
-- 主题开启时间类型
function FuncCarnival.getTimeTypeByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.timeType 
	end
end


-- 主题开启时间
function FuncCarnival.getOpenDayByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.start 
	end
end

-- 主题结束时间
function FuncCarnival.getCloseDayByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data["end"]
	end
end

-- 主题展示起始时间
function FuncCarnival.getShowStartDayByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.showStart 
	end
end

-- 主题展示结束时间
function FuncCarnival.getShowEndByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.showEnd
	end
end

-- 主题展示期间是否可以领取奖励
function FuncCarnival.getCanGetRewardOptionByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.last
	end
end

-- 主题开启选项
function FuncCarnival.getShutDownByThemeId( themeId )
	local data = themeData[tostring(themeId)]
	if data then
		return data.shutDown
	end
end




--=====================================================
-- Activity 表 
-- 每个主题下的活动相关
--=====================================================
-- 获取静态活动列表数据
function FuncCarnival.getActivityData()
	return activityData
end

-- 通过id获取某个活动的数据
function FuncCarnival.getActivityDataByActivityId(activityId)
	return activityData[tostring(activityId)]
end

-- 通过id获取某个活动的排序
function FuncCarnival.getActivityOrderByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.order
	end
end
-- 通过id获取某个活动的标签上的icon
function FuncCarnival.getActivityIconByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.icon
	end
end

-- 通过id获取某个活动的标题
function FuncCarnival.getActivityNameByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.title
	end
end

-- 通过id获取某个活动的内容描述
function FuncCarnival.getActivityDescriptionByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.desc
	end
end

-- 通过id获取某个活动的特殊标记
-- 1.双倍
-- 2.限时
-- 3.热门
-- 4.折扣
function FuncCarnival.getActivityMarkByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.mark
	end
end

-- 通过id获取某个活动的可见等级
function FuncCarnival.getActivityVisibleLevelByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.level
	end
end

-- 通过id获取某个活动的任务列表
function FuncCarnival.getActivityTaskListByActivityId(activityId)
	local data = activityData[tostring(activityId)]
	if data then
		return data.taskList 
	end
end





--=====================================================
-- ActivityTask 表 
-- 每个活动下的任务相关
--=====================================================
-- 获取静态任务列表数据
function FuncCarnival.getTaskData()
	return taskData
end

-- 根据任务Id获取任务数据
function FuncCarnival.getTaskById(taskId)
	return taskData[tostring(taskId)]
end

-- 根据任务Id获取任务描述
function FuncCarnival.getTaskDescriptionById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.desc 
	end
end

-- 根据任务Id获取任务类型
-- 1 只有行为类
-- 2 只有兑换条件
-- 3 嘉年华活动
-- 4 不可领取类
function FuncCarnival.getTaskTypeById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.type 
	end
end

-- 根据任务Id获取任务条件id
function FuncCarnival.getTaskConditionIdById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.condition 
	end
end

-- 根据任务Id获取任务条件参数
function FuncCarnival.getTaskConditionParamById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.conditionParam 
	end
end

-- 根据任务Id获取完成任务应该达到的数量
function FuncCarnival.getTaskConditionNumById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.conditionNum 
	end
end

-- 根据任务Id获取任务可完成次数
-- 有些任务可以完成多次，奖励叠加
function FuncCarnival.getTaskCanDoTimesById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.times 
	else
		echoError("-----可完成次数配表值为空个-----------",taskId)
	end
end

-- 根据任务Id获取任务完成后的奖励
function FuncCarnival.getTaskRewardById(taskId)
	local data = taskData[tostring(taskId)]
	if data then
		return data.reward 
	end
end



--=====================================================
-- ActivityCondition 表 
-- 任务条件 跳转界面等
--=====================================================
-- 通过任务id获取条件
function FuncCarnival.getTaskConditionById( taskId )
	local conditionId = FuncCarnival.getTaskConditionIdById(taskId)
	local data = taskConditionData[tostring(conditionId)]
	if data then
		return data
	end
	return nil
end

-- 通过任务id获取跳转界面ui
function FuncCarnival.getTaskLinkUIById( taskId )
	local data = FuncCarnival.getTaskConditionById( taskId )
	if data and data.link then
		return data.link
	end
	return nil
end

-- 通过任务id获取跳转界面ui参数
function FuncCarnival.getTaskLinkParamsById( taskId )
	local data = FuncCarnival.getTaskConditionById( taskId )
	if data and data.linkParams then
		return data.linkParams
	end
	return nil
end

-- 通过任务id获取任务条件是否追溯
-- 追溯则客户端进行统计
-- 不追溯则服务端进行统计
function FuncCarnival.getTaskTraceById( taskId )
	local data = FuncCarnival.getTaskConditionById( taskId )
	if data and data.trace then
		return data.trace
	end
	return nil
end

function FuncCarnival.getJumpSysName( taskId )
	local data = FuncCarnival.getTaskConditionById( taskId )
	if data and data.sysName then
		return data.sysName
	end
	return nil
end


--=====================================================
--=====================================================
-- 设置每个任务属于的活动类型
-- function FuncCarnival.setTaskActivityId()
-- 	echo("------------------------------------ FuncCarnival.setTaskActivityId() --------------------------------------------------------------")
-- 	self.activityList = FuncCarnival.getActivityData()
-- 	self.taskList = FuncCarnival.getTaskData()
-- 	dump(self.activityList,"self.activityList")
-- 	dump(self.taskList,"self.taskList")
-- 	for k1,perActivity in pairs(self.activityList) do
-- 		for k2,task in pairs(perActivity.taskList) do
-- 			self.taskList[task].activity = perActivity.id
-- 		end
-- 	end
-- 	dump(self.activityList,"self.activityList")
-- 	dump(self.taskList,"self.taskList")
-- 	return self.taskList
-- end