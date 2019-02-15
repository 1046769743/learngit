local ActivityItemExchange = class("ActivityItemExchange", UIBase)
function ActivityItemExchange:ctor(winName)
	ActivityItemExchange.super.ctor(self, winName)
end

function ActivityItemExchange:loadUIComplete()
	self:registerEvent()
end

function ActivityItemExchange:registerEvent()
	self.mc_btn:getViewByFrame(1).btn_1:setTap(c_func(self.onExchangeTap, self))
	self.mc_btn:getViewByFrame(2).btn_1:setTap(c_func(self.onExchangeTap, self))
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
end

function ActivityItemExchange:onTaskFinished(event)
	if not self.config then return end
	local params = event.params
	local taskId = params.taskId
	if taskId == self.config.id then
		self:updateUI()
	end
end

function ActivityItemExchange:onExchangeTap()
	local onlineId = self.actRecord:getOnlineId()
	local taskId = self.config.id
	local actInfo = self.actRecord:getActInfo()
	local finished = ActTaskModel:isTaskFinished(onlineId, taskId, actInfo) 
	local conditionOk = ActConditionModel:isTaskConditionOk(onlineId, taskId, self.actRecord:getActType())
	--优先判断活动结束
	local actActive = self.actRecord:isActInActivePeriod()
	if not actActive then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1004"))
		return 
	end
	if finished then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1003"))
		return
	end
	if not conditionOk then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1001"))
		return
	end
	ActTaskModel:tryFinishTask(onlineId, self.config.id)
end

function ActivityItemExchange:setActivityTaskData(record, data)
	self.actRecord = record
	self.config = data
end

function ActivityItemExchange:updateUI()
	if UserModel:isTest() then
		self.txt_name:setString(string.format("%s-%s", self.actRecord:getActId(), self.config.id))
	else
		local desc = ""
		if self.config.desc then
			desc = GameConfig.getLanguage(self.config.desc)
		end
		self.txt_name:setString(desc)
	end
	self:setExchangeItems()
	self:setButtonUIAndProgress()
end

function ActivityItemExchange:setButtonUIAndProgress()
	local onlineId = self.actRecord:getOnlineId()
	local taskId = self.config.id
	local actInfo = self.actRecord:getActInfo()
	local finished, leftNum = ActTaskModel:isTaskFinished(onlineId, taskId, actInfo) 

	local frame = _yuan3(finished, 2, 1)
	self.mc_btn:showFrame(frame)
	self.mc_btn:getViewByFrame(1).btn_1:getUpPanel().panel_red:visible(false)

	if finished then
		self.txt_progress1:visible(false)
	else
		self.txt_progress1:setString(GameConfig.getLanguageWithSwap("#tid18007", leftNum))
	end
end

function ActivityItemExchange:setExchangeItems()
	local conditionParam = self.config.conditionParam
	for i=1,1 do
		local leftItemData = conditionParam[i]
		local leftItemUI = self.mc_content.currentView["UI_item_left_"..i]
		if leftItemUI and leftItemData then
			leftItemUI:setResItemData({reward = leftItemData})
		end
	end

	local rewardArr = self.config.reward
	for i=1,2 do
		local reward = rewardArr[i]
		local ui_item = self.mc_content.currentView["UI_item_right_"..i]
		if ui_item then
			if reward then
				ui_item:setResItemData({reward = reward})
			else
				ui_item:visible(false)
			end
		end
	end
end

function ActivityItemExchange:close()
	self:startHide()
end

return ActivityItemExchange
