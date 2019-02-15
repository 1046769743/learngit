local ActivityMainView = class("ActivityMainView", UIBase)
function ActivityMainView:ctor(winName)
	ActivityMainView.super.ctor(self, winName)
	self:initData()
end

function ActivityMainView:initData()
	self.acts = FuncActivity.getOnlineFuLiActs()
end

function ActivityMainView:loadUIComplete()
	--self.scale9_1:visible(false)
	--self.scroll_list:visible(false)
	--self.panel_act_name:visible(false)

	self.UI_lingqu:visible(false)
	self.UI_duihuan:visible(false)
	self.panel_act_name:visible(false)

	-- self.scrollOriginRect = self.scroll_list:getViewRect()
	-- local scrollx, scrolly = self.scroll_list:getPosition()
	-- self.scroll_list:cancleCacheView()
	-- self.scrollOriginPosX = scrollx
	-- self.scrollOriginPosY = scrolly

	self:setViewAlign()
	self:registerEvent()

	self:initTempUI();
	
	-- if #self.acts ~= 0 then
	-- 	self:initLeftButtons()
	-- end
	
	-- self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,0)
end

function ActivityMainView:initTempUI()
	self.btn_lingqu:setTap(c_func(self.finishTask, self))
end

function ActivityMainView:finishTask()
	local onlineId = self.input_temp:getText();
	local taskId = self.input_temp2:getText();

	if tonumber(onlineId) == nil or tonumber(taskId) == nil then 
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2022"));
		return;
	end 

	ActivityServer:finishTask(
		onlineId, taskId, c_func(self.onFinishTaskOk, self));

end

function ActivityMainView:onFinishTaskOk(serverData)

	local result = serverData.result
	if result.data and result.data.reward then
		echo("---result.data.reward---", result.data.reward)
		local rewardArray = string.split(result.data.reward, ";");
		FuncCommUI.startFullScreenRewardView(result.data.reward)
	end
		
end

function ActivityMainView:initLeftButtons()
	self.UI_nav:setMainView(self)
	self.UI_nav:setActivities(self.acts)
	self.UI_nav:updateUI()
end

function ActivityMainView:showActivity(index)
	local actRecord = self.acts[index]
	self:doShowActivityContent(actRecord)
end

function ActivityMainView:doShowActivityContent(actRecord)
	self:setActTitleAndDesc(actRecord)
	self:initActContents(actRecord)
	self.currentActRecord = actRecord
end

function ActivityMainView:initActContents(actRecord)
	local actType = actRecord:getActType()
	local cloneView = self.UI_lingqu

	if actType == FuncActivity.ACT_TYPE.EXCHANGE then
		cloneView = self.UI_duihuan
	end

	local createFunc = function(taskId, index)
		local ui = UIBaseDef:cloneOneView(cloneView)
		local config = FuncActivity.getActTaskConfigById(taskId)
		ui:setActivityTaskData(actRecord, config, index)
		ui:updateUI()
		return ui
	end

	local params = {
		{
			data = self:getSortedTaskIdList(actRecord),
			createFunc = createFunc,
			perNums = 1,
			offsetX =5,
			offsetY = 10,
			widthGap = 0,
			heightGap = 20,
			itemRect = {x=0,y= -150, width = 668,height = 150},
			perFrame=1
		}
	}
	self.scroll_list:styleFill(params)
	if self._scroll_target_group and self._scroll_target_index then
		self.scroll_list:gotoTargetPos(self._scroll_target_index, self._scroll_target_group, 1)
	else
		self.scroll_list:easeMoveto(0,0,0)
	end
end

function ActivityMainView:getSortedTaskIdList(actRecord)
	local taskIds = actRecord:getDisplayedTaskIds()
	local onlineId = actRecord:getOnlineId()
	local actInfo = actRecord:getActInfo()
	local sortTaskIds = function(aid, bid)
		local afinished = ActTaskModel:isTaskFinished(onlineId, aid, actInfo)
		local bfinished = ActTaskModel:isTaskFinished(onlineId, bid, actInfo)
		local adelta = _yuan3(afinished, 100, 0)
		local bdelta = _yuan3(bfinished, 100, 0)
		local anum = tonumber(aid) + adelta
		local bnum = tonumber(bid) + bdelta
		return anum < bnum
	end
	table.sort(taskIds, sortTaskIds)
	return taskIds
end

function ActivityMainView:setActTitleAndDesc(actRecord)
	local actTitle = actRecord:getActTitle()
	self.panel_act_name.txt_name:setString(actTitle)
	local descFixedWidth = 662
	local descStr = actRecord:getActDesc()
	local descStrOnelineWidth = FuncCommUI.getStringWidth(descStr, 22, 'gameFont1')
	if descStrOnelineWidth > descFixedWidth then
		local height = FuncCommUI.getStringHeightByFixedWidth(descStr, 22, "gameFont1", 662)
		local rect = self.scrollOriginRect
		local heightDelta = height - 30
		local newHeight =rect.height - heightDelta
		local newRect = {
			x = rect.x,
			y = -newHeight,
			height = newHeight,
			width = rect.width,
		}
		self.scroll_list:updateViewRect(newRect)
		self.scroll_list:pos(self.scrollOriginPosX, self.scrollOriginPosY - heightDelta)
	else
		self.scroll_list:updateViewRect(self.scrollOriginRect)
		self.scroll_list:pos(self.scrollOriginPosX, self.scrollOriginPosY)
	end
	self.panel_act_name.txt_desc:setString(descStr)
end

function ActivityMainView:onBecomeTopView()
	echo("ActivityMainView:onBecomeTopView")
	self.UI_nav:refreshCurrentView()
end

function ActivityMainView:frameUpdate()
	if self.currentActRecord then
		local timeInfo = self.currentActRecord:getTimeInfo()
		local now = TimeControler:getServerTime()
		local left = timeInfo.end_t - now
		if left <= 0 then
			self.panel_act_name.mc_time:showFrame(2)
			local showLeft = self.currentActRecord:getDisplayLeftTime()
			local str = self:_getTimeStr(showLeft)
			self.panel_act_name.mc_time.currentView.txt_jieshu_1:setString(str)
		else
			self.panel_act_name.mc_time:showFrame(1)
			local timeStr = self:_getTimeStr(left)
			self.panel_act_name.mc_time.currentView.txt_time:setString(timeStr)
		end
	end
end

function ActivityMainView:_getTimeStr(time)
	local timeStr = fmtSecToLnDHHMMSS(time)
	if time < 86400 then
		timeStr = "0天"..timeStr
	end
	return timeStr
end

function ActivityMainView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
end

function ActivityMainView:registerEvent()
	self.btn_back:setTap(c_func(self.onBackTap, self))
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
end

function ActivityMainView:onTaskFinished(event)
	local params = event.params
	local onlineId = params.onlineId
	local taskId = params.taskId
	if onlineId == self.currentActRecord:getOnlineId() then
		local isFinished, leftNum = ActTaskModel:isTaskFinished(onlineId, taskId, self.currentActRecord:getActInfo())
		if isFinished then
			local group, index = self.scroll_list:getGroupPos(1)
			self._scroll_target_group = group
			self._scroll_target_index = index
			self:doShowActivityContent(self.currentActRecord)
		end
	end
end

function ActivityMainView:onBackTap()
	self:close()
end

function ActivityMainView:close()
	self:startHide()
end
return ActivityMainView
