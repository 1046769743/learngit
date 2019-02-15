local BaseInspect = require("game.sys.config_inspect.BaseInspect")
local ActInspect = class("ActInspect", BaseInspect)

function ActInspect:ctor()
	ActInspect.super.ctor(self)
	self.configs = {
		"activity.Activity",
		"activity.ActivityTask",
		"activity.ActivityOnline",
		"activity.ActivityCondition",
	}
end



function ActInspect:getConfigItems()
	return self.configs
end

function ActInspect:action_before_run()
	self:getSortedTaskKeys()
	--活动结束之后、展示结束之前，可以领取已完成的
	local tasksCanDoWhenActEndBeforeDisplayEnd = {}
	for onlineId, onlineInfo in pairs(self.config_ActivityOnline) do
		local actId = onlineInfo.actId
		if onlineInfo.last > 0 then
			local actInfo = self.config_Activity[actId]
			if actInfo then
				local tasks = actInfo.taskList
				for _, taskId in pairs(tasks) do
					table.insert(tasksCanDoWhenActEndBeforeDisplayEnd, taskId)
				end
			end
		end
	end
	self.tasksCanDoWhenActEndBeforeDisplayEnd = tasksCanDoWhenActEndBeforeDisplayEnd
end

function ActInspect:getSortedTaskKeys()
	if self.sortedTaskIds then
		return self.sortedTaskIds
	end
	local tasks = self.config_ActivityTask
	local sortById = function(a, b)
		return tonumber(a.id) < tonumber(b.id)
	end
	local keys = table.keys(tasks, sortById)
	self.sortedTaskIds = keys
	return keys
end

function ActInspect:run_get_trace_tasks()
	local conditions = self.config_ActivityCondition
	local tasks = self.config_ActivityTask
	local keys = self:getSortedTaskKeys()
	for _, taskId in pairs(keys) do
		local taskInfo = tasks[taskId]
		local conditionId = taskInfo.condition..''
		local conditionInfo = conditions[conditionId]
		if conditionInfo.trace > 0 then
			self:log(string.format("任务：%s是追溯的,条件id:%s", taskId, conditionId))
			if table.find(self.tasksCanDoWhenActEndBeforeDisplayEnd, taskId) then
				self:logError(string.format("任务：%s是追溯的,但是活动结束之后、展示结束之前还可以领取", taskId))
			end
		end
	end
end

function ActInspect:run_get_jump_tasks()
	local conditions = self.config_ActivityCondition
	local tasks = self.config_ActivityTask
	local keys = self:getSortedTaskKeys()
	for _, taskId in pairs(keys) do
		local taskInfo = tasks[taskId]
		local conditionId = taskInfo.condition..''
		local conditionInfo = conditions[conditionId]
		if conditionInfo.link ~= nil then
			self:log(string.format("任务：%s是可跳转, 跳转：%s, 条件id:%s", taskId, conditionInfo.link, conditionId))
		end
	end
end

--检查主键
function ActInspect:run_check_main_id()
	local conditions = self.config_ActivityCondition
	local tasks = self.config_ActivityTask
	local onlineActs = self.config_ActivityOnline
	local acts = self.config_Activity
	for id, onlineInfo in pairs(onlineActs) do
		local actId = onlineInfo.actId
		if acts[actId] == nil then
			self:logError(string.format("ActivityOnline id:%s 引用的Activity actId:%s 不存在", id, actId))
		end
	end
	
	for id, actInfo in pairs(acts) do
		local taskList = actInfo.taskList
		for _, taskId in pairs(taskList) do
			if tasks[taskId] == nil then
				self:logError(string.format("Activity.csv id:%s taskList中taskId:%s在ActivityTask.csv中不存在", id, taskId))
			end
		end
	end

	for id, taskInfo in pairs(tasks) do
		local conditionId = taskInfo.condition..''
		if conditions[conditionId] ==nil then
			self:logError(string.format("ActivityTask.csv id:%s conditionId:%s 在ActivityCondition.csv 中没有对应项", id, conditionId))
		end
	end
end

--检查可见等级、可做等级限制
function ActInspect:run_check_levels()
	local tasks = self.config_ActivityTask
	local acts = self.config_Activity
	for actId, actInfo in pairs(acts) do
		local taskList = actInfo.taskList
		local actVisibleLevel = actInfo.level
		local actTaskMinVisibleLevel = 999
		for _, taskId in pairs(taskList) do
			local taskInfo = tasks[taskId]
			if taskInfo then
				local levelLimit = taskInfo.levelLimit or 0
				local visibleLevel = taskInfo.level or 0
				if actTaskMinVisibleLevel > visibleLevel then
					actTaskMinVisibleLevel = visibleLevel
				end
				if visibleLevel > levelLimit then
					self:logError(string.format("活动项:%d 可见等级%d大于其可做等级%d", taskId, visibleLevel, levelLimit))
				end
			end
		end
		if actTaskMinVisibleLevel > 0 and actTaskMinVisibleLevel > actVisibleLevel then
			self:logError(string.format("活动:%d可见等级%d小于其所有活动项中的最小可见等级:%d", actId, actVisibleLevel, actTaskMinVisibleLevel))
		end
	end
end

--检查统一平台、渠道、区服是不是开了同一个活动
function ActInspect:run_check_online_same_act()
	local onlineActs = self.config_ActivityOnline
	local onlineInfos = {}
	local checkAndUpdateOnlineInfos = function(online_key, act_id)
		if onlineInfos[online_key] == nil then
			onlineInfos[online_key] = {act_id}
		else
			if table.find(onlineInfos[online_key], act_id) then
				self:logError(string.format("平台、渠道、区服:%s 活动 %s重复配置", online_key, act_id))
			else
				table.insert(onlineInfos[online_key], act_id)
			end
		end
	end
	for id, onlineInfo in pairs(onlineActs) do
		local platform = onlineInfo.paltform or "allplatform"
		local channel = onlineInfo.channel or "allchannel"
		local serverType = onlineInfo.serverType
		local actId = onlineInfo.actId
		if serverType == "1" then --全服活动
			local key = string.format("[%s]_[%s]_[%s]", platform, channel, "allserver")
			checkAndUpdateOnlineInfos(key, actId)
		elseif serverType == "2" then --多服活动
			local servers = onlineInfo.server
			if servers == nil then
				self:logError(string.format("多服活动配置%s，servers字段为空", id))
			else
				for _,serverId in pairs(servers) do
					local key = string.format("[%s]_[%s]_[%s]", platform, channel, serverId)
					checkAndUpdateOnlineInfos(key, actId)
				end
			end
		else --排除某服的活动
		end

	end
end

function ActInspect:run_check_condition_jump_link()
	local conditions = self.config_ActivityCondition
	local windowsCfgs = WindowsTools:getWindowsCfgs()
	local getWindowNameByUIName = function(uiName)
		for k,v in pairs(windowsCfgs) do
			if v.ui ==uiName then
				return k
			end
		end
	end
	for id, info in pairs(conditions) do
		local link = info.link
		if link then
			local uiName = getWindowNameByUIName(link)
			if not uiName then
				self:logError(string.format("ActivityTaskCondition:%s 的跳转界面:%s在前端配置WindowsCfgs中没有!", id, link))
			end
		end
	end
end

return ActInspect
