local ActivityItemReceive = class("ActivityItemReceive", UIBase)
function ActivityItemReceive:ctor(winName)
	ActivityItemReceive.super.ctor(self, winName)
end

function ActivityItemReceive:loadUIComplete()
	self:registerEvent()
end

function ActivityItemReceive:registerEvent()
	self.mc_get:getViewByFrame(1).btn_1:setTap(c_func(self.onGetTap, self))
	self.mc_get:getViewByFrame(2).btn_1:setTap(c_func(self.onGotoTap, self))
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserDataUpdate, self)
end

function ActivityItemReceive:onUserDataUpdate(event)
	if self.config then
		self:updateUI()
	end
end

function ActivityItemReceive:onTaskFinished(event)
	if not self.config then return end
	local params = event.params
	local taskId = params.taskId
	if taskId == self.config.id then
		self:updateUI()
	end
end

function ActivityItemReceive:onGetTap()
	local finished, conditionOk = self:getStatus()
	if finished then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1002"))
		return
	end
	if not conditionOk then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1001"))
		return
	end
	local actActive = self.actRecord:isActInActivePeriod()
	if not actActive then
		if not self.actRecord:isActCanReceiveAfterEnd() then
			WindowControler:showTips(GameConfig.getLanguage("tid_activity_1004"))
			return
		end
	end
	if not self.actRecord:isActInShowPeroid() then
		WindowControler:showTips(GameConfig.getLanguage("tid_activity_1004"))
		return
	end
	ActTaskModel:tryFinishTask(self.actRecord:getOnlineId(), self.config.id)
end

function ActivityItemReceive:onGotoTap()
	local jumpLink = FuncActivity.getTaskJumpLink(self.config.id)
	if jumpLink then
		local actActive = self.actRecord:isActInActivePeriod()
		if not actActive then
			WindowControler:showTips(GameConfig.getLanguage("tid_activity_1004"))
			return
		end
		ActTaskModel:jumpToTaskLinkView(self.config.id)
	end
end

function ActivityItemReceive:getStatus()
	local onlineId = self.actRecord:getOnlineId()
	local taskId = self.config.id
	local actInfo = self.actRecord:getActInfo()
	local finished = ActTaskModel:isTaskFinished(onlineId, taskId, actInfo) 
	local conditionOk = ActConditionModel:isTaskConditionOk(onlineId, taskId, self.actRecord:getActType())
	return finished, conditionOk
end

function ActivityItemReceive:setActivityTaskData(actRecord, data)
	self.actRecord = actRecord
	self.config = data
end

function ActivityItemReceive:setTitle()
	--title
	if UserModel:isTest() then
		self.txt_name:setString(string.format("%s-%s", self.actRecord:getActId(), self.config.id))
	else
		self.txt_name:setString(GameConfig.getLanguage(self.config.desc))
	end
end

function ActivityItemReceive:setProgress()
	local actActive = self.actRecord:isActInActivePeriod()
	local canReceiveAfterEnd = self.actRecord:isActCanReceiveAfterEnd()
	if not actActive and not canReceiveAfterEnd then
		self.txt_progress:visible(false)
		return
	end

	local finished, conditionOk = self:getStatus()
	if finished then
		self.txt_progress:visible(false)
	else
		local current,needNum = ActConditionModel:getTaskConditionProgress(self.actRecord:getOnlineId(), self.config.id)
		local progress = string.format("%s/%s", current, needNum)
		self.txt_progress:visible(true)
		self.txt_progress:setString(progress)
	end
end

function ActivityItemReceive:setButtonMc()
	local finished, conditionOk = self:getStatus()
	local btnFrame = 1
	if finished then
		btnFrame = 3
		self.mc_get:showFrame(btnFrame)
	else
		local actActive = self.actRecord:isActInActivePeriod()
		local canReceiveAfterEnd = self.actRecord:isActCanReceiveAfterEnd()

		local jumpLink = FuncActivity.getTaskJumpLink(self.config.id)
		if jumpLink then
			btnFrame = _yuan3(conditionOk, 1, 2)
		else
			btnFrame = 1
		end
		self.mc_get:showFrame(btnFrame)
		--小红点
		local panel_red = self.mc_get.currentView.btn_1:getUpPanel().panel_red
		local showRed = _yuan3(conditionOk, true, false)
		if not actActive and not canReceiveAfterEnd then
			showRed = false
		end
		if panel_red then
			panel_red:visible(showRed)
		end
	end
end

function ActivityItemReceive:updateUI()
	self:setTitle()
	self:setProgress()
	self:setRewardItems()
	self:setButtonMc()
end

function ActivityItemReceive:setRewardItems()
	--items 
	local rewardArr = self.config.reward
	for i=1,4 do
		local reward = rewardArr[i]
		local ui_item = self["UI_item"..i]
		if reward then
			ui_item:visible(true)
			ui_item:setResItemData({reward = reward})
		else
			ui_item:visible(false)
		end
	end

end

function ActivityItemReceive:close()
	self:startHide()
end
return ActivityItemReceive
