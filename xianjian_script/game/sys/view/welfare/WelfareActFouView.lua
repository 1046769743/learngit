--每日任务

local WelfareActFouView = class("WelfareActFouView", UIBase);

function WelfareActFouView:ctor(winName)
    WelfareActFouView.super.ctor(self, winName);
end

function WelfareActFouView:onBecomeTopView()
	-- 重新回到顶层 需要刷新一次Ui
	self:reFreshUI()
end

function WelfareActFouView:loadUIComplete()
	self:registerEvent();

	self:initData()
	self:initBtns( )
	self:updateUI(self.currentData)

	self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	-- title
	-- local title = self.currentData:getActInfo().title
	-- local titTxt = self.panel_1.txt_1
	-- titTxt:setString(GameConfig.getLanguage(title))
end 

function WelfareActFouView:registerEvent()
	WelfareActFouView.super.registerEvent();
	self:registClickClose("out")

	self.btn_close:setTap(c_func(self.close,self))

	EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT, 
			self.reFreshUI, self)
	EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, 
			self.reFreshUI, self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE, 
			self.reFreshUI, self)

	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK,
			self.onTaskFinished, self)

	EventControler:addEventListener("ActTaskModel_everydaytarget_redpoint",
			self.reFreshUI, self)
end

function WelfareActFouView:updateWinthActInfo(actData)
end

function WelfareActFouView:initData( )
	local allDatas = FuncActivity.getEverydayActs()
	local sortFunc = function(a,b)
		local aData = a:getActInfo()
		local bData = b:getActInfo()
		if a.order > b.order then
			return true
		end
		return false
	end


	self.allData = allDatas
    local num = table.length(allDatas)

    local createTime = UserModel:ctime()
	local openDays = UserModel:getCurrentDaysByTimes(createTime)
    echo("openDays ====== ",openDays)
    if openDays > table.length(self.allData) then
    	openDays = 1
    end
    local currentData = self.allData[openDays]
    self.currentData = currentData
    self.openDays = openDays
end

function WelfareActFouView:initBtns( )
	local selectIndex = 1
	for i = 1,table.length(self.allData) do
		self.panel_pg["mc_"..i]:showFrame(1)
		local panel = self.panel_pg["mc_"..i].currentView.txt_1
		local data = self.allData[i]

		local isCanGet = ActConditionModel:isTaskConditionOk(data:getOnlineId(), data:getActInfo().taskList[1], data:getActType())
		local isGetReward = ActTaskModel:isTaskFinished(data:getOnlineId(), data:getActInfo().taskList[1], data:getActInfo())

		if isCanGet then
			if isGetReward then
				-- 任务完成 领取完奖励
				-- 红点显示
				self.panel_pg["panel_red"..i]:visible(false)
			else
				-- 任务完成 可以领取奖励
				-- 红点隐藏
				self.panel_pg["panel_red"..i]:visible(false)
				if self.openDays == i then
					self.panel_pg["panel_red"..i]:visible(true)
				end
			end
		else
			-- 任务时间还没到
			-- 红点隐藏
			self.panel_pg["panel_red"..i]:visible(false)
		end

		panel:setTouchedFunc(function (  )
			self.currentFrame = 30
			self:updateUI(data)
		end)

		if tostring(data:getActId()) == tostring(self.currentId) then
			self.panel_pg["mc_"..i]:showFrame(2)
			selectIndex = i
		end
	end


	self.mc_2:showFrame(selectIndex)
end
-- 1 已经结束 2 正在进行 3 将要进行 4 不可显示
function WelfareActFouView:checkOpen(data)
	local createTime = UserModel:ctime()
	local openDays = UserModel:getCurrentDaysByTimes(createTime)

	local index = 1
	for i = 1,table.length(self.allData) do
		if data == self.allData[i] then
			index = i
			break
		end
	end
	if index < openDays then
		return 1
	end
	if index == openDays then
		return 2
	end
	if index == (openDays+1) then
		return 3
	end
	if index > (openDays+1) then
		return 4,index - openDays
	end
end

function WelfareActFouView:updateUI(data,refresh)
   	if not data then
		return 
	end
	-- 判断是否开启
	local state,_d = self:checkOpen(data)  
	if state > 3 then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_activity_5149",_d-1))
		return 
	end

    if tostring(self.currentId) == data:getActId() and not refresh then
        return
    end
    self.currentData = data
    self.currentId = data:getActId()
    self:initBtns()

    local actData = data:getActInfo()
    local actTaskId = actData.taskList[1]
    
    local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId)
    -- 内容
    -- self.mc_2:showFrame(1)
    -- self.mc_2.currentView.rich_1:setString(GameConfig.getLanguage(actTaskData.desc))
    -- 奖励
    for i=1,4 do
    	self["UI_"..i]:visible(false)
    end
    local rewards = actTaskData.reward
    for i,v in pairs(rewards) do
		local ui = self["UI_"..i]
		ui:visible(true)
		ui:setRewardItemData({reward = v})
        -- ui:showResItemNum(false)
        -- 注册点击事件
        local resNum,_,_ ,resType,resId = UserModel:getResInfo( v )
    	FuncCommUI.regesitShowResView(ui,resType,resNum,resId,v,true,true)
	end

	self:refreshBtn( )
end
function WelfareActFouView:refreshBtn( )
	local data = self.currentData
	local actData = data:getActInfo()
    local actTaskId = actData.taskList[1]
	local state,_d = self:checkOpen(data)
	-- 前往
	local mc_btn = self.mc_btn
	if state == 2 then
		-- 是否已领取
		if ActTaskModel:isTaskFinished(data:getOnlineId(), actTaskId, actData) then
			mc_btn:showFrame(3)
		else
			local isCanGet = ActConditionModel:isTaskConditionOk(data:getOnlineId(), actTaskId, data:getActType())
			if isCanGet then
				mc_btn:showFrame(1)
			else
				mc_btn:showFrame(2)
			end
			local btn = mc_btn.currentView.btn_1
			FilterTools.clearFilter(btn)
			btn:setTap(c_func(self.btnTap,self,actTaskId,data))
		end
	elseif state == 1 then
		-- 判读是否可领取
		local isGetted = ActTaskModel:isTaskFinished(data:getOnlineId(), actTaskId, actData)
		if isGetted then
			mc_btn:showFrame(3)
		else
			-- 判读是否可领取
			mc_btn:showFrame(4)
			local btn = mc_btn.currentView.btn_1
			FilterTools.setGrayFilter(btn)
			btn:setTap(function ( ... )
				WindowControler:showTips(GameConfig.getLanguage("#tid_activity_tip_005"))
			end)
		end
	elseif state == 3 then
		mc_btn:showFrame(1)
		local btn = mc_btn.currentView.btn_1
		FilterTools.setGrayFilter(btn)
		btn:setTap(function ( ... )
			WindowControler:showTips(GameConfig.getLanguage("#tid_activity_5148"))
		end)
	end
end

function WelfareActFouView:updateTime()
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local state = self:checkOpen(self.currentData)
		if state == 2 then
			local leftTime = self.currentData:getDisplayLeftTime()
			self.txt_time1:visible(true)
			-- echo("==========-------",fmtSecToLnDHHMMSS(leftTime),leftTime)
			self.txt_time:setString(fmtSecToLnDHHMMSS(leftTime))
		elseif state == 1 then 
			self.txt_time1:visible(false)
			self.txt_time:setString("活动已结束")
			self:refreshBtn( )
		elseif state == 3 then
			self.txt_time1:visible(false)
			self.txt_time:setString("活动明日开启")
			self:refreshBtn( )
		end
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActFouView:btnTap(actTaskId,data)
	-- 跳转
	-- 判断是否可领取
	local isCanGet = ActConditionModel:isTaskConditionOk(data:getOnlineId(), actTaskId, data:getActType())
	echo("isCanGet ==== ",isCanGet)
	if isCanGet then
		-- 可领取
		ActTaskModel:tryFinishTask(data:getOnlineId(), actTaskId)
	else
		ActTaskModel:jumpToTaskLinkView(actTaskId)
	end
end

function WelfareActFouView:onTaskFinished(event )
	if not self.currentData then return end
	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.currentData:getOnlineId() then
		self:updateUI(self.currentData,true)
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end
function WelfareActFouView:reFreshUI( )
	if not self.currentData then return end
	self:updateUI(self.currentData,true)
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end
function WelfareActFouView:reFreshUIDelay( )
	-- echo("11111111111111111111")
	self:delayCall(c_func(self.reFreshUI,self), 0.5)
end

function WelfareActFouView:close( )
	self:startHide()
end

return WelfareActFouView;
