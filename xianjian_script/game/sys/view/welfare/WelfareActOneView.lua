-- 奇侠唤醒 
-- zhangqiang

local WelfareActOneView = class("WelfareActOneView", UIBase);

function WelfareActOneView:ctor(winName)
    WelfareActOneView.super.ctor(self, winName);
end

function WelfareActOneView:loadUIComplete()
	self:registerEvent();
	
end 

function WelfareActOneView:registerEvent()
	WelfareActOneView.super.registerEvent();
    EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
	EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, 
			self.refreshUI, self)
end

function WelfareActOneView:refreshUI( )
	if not self.actData then return end
	self:initListUI( )
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

function WelfareActOneView:onTaskFinished(event )
	if not self.actData then return end
	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initListUI( )
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end
function WelfareActOneView:updateWinthActInfo(actData)
	self.actData = actData
	self:registerEvent();
	local actInfo = actData:getActInfo()

	local title = actInfo.title
	-- local titTxt = self.panel_1.txt_1

	local desc = actInfo.desc
	local descTxt = self.txt_1
	descTxt:setString(GameConfig.getLanguage(desc))

	-- self.panel_bao.mc_1:visible(false)
	-- local titlePath = FuncRes.getActiveTitleIcon(actInfo.titlePicture) 
	-- self.ctn_title:removeAllChildren()
	-- local titlePathSp = display.newSprite(titlePath)
	-- titlePathSp:anchor(0,1)
	-- self.ctn_title:addChild(titlePathSp)

    self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:initListUI()
	
end

function WelfareActOneView:initListUI( )
	self.actInfo = self.actData:getActInfo()
	self.actOnlineId = self.actData:getOnlineId()
	local listData = {}
	for i,v in pairs(self.actInfo.taskList) do
		table.insert(listData,v)
	end
	
	table.sort(listData,c_func(self.sortFunc,self))
	-- dump(listData, "-------", 4)
    self.listData = listData
	self:initList(listData)
	self.scroll_1:refreshCellView(1)
end

function WelfareActOneView:sortFunc(taskIdA, taskIdB)
	local finishA = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdA, self.actInfo)
	local finishB = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdB, self.actInfo)
	if finishA == finishB then
		local actTaskDataA = FuncActivity.getActivityTaskConfig(taskIdA) 
		local patnerIdsA = actTaskDataA.conditionParam
		local actTaskDataB = FuncActivity.getActivityTaskConfig(taskIdB) 
		local patnerIdsB = actTaskDataB.conditionParam

		local haveCountA = 0
		for i,v in ipairs(patnerIdsA) do
			if PartnerModel:isHavedPatnner(v) then
				haveCountA = haveCountA + 1
			end
		end

		local haveCountB = 0
		for i,v in ipairs(patnerIdsB) do
			if PartnerModel:isHavedPatnner(v) then
				haveCountB = haveCountB + 1
			end
		end

		if haveCountA == haveCountB then
			if tonumber(taskIdA) < tonumber(taskIdB) then
				return true
			end
			return false
		else
			if haveCountA > haveCountB then
				return true
			end
			return false
		end
	else
		if finishA then
			return false
		end
		return true
	end
	return false
end

function WelfareActOneView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActOneView:initList(listData)
	self.panel_tiao:visible(false)
	local createCellItemFunc = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.panel_tiao)
		self:updateCellItem(view, itemData)
		return view
	end
	local updateCellItemFunc = function (itemData,itemView)
        self:updateCellItem(itemView, itemData);
        return itemView
    end
	local scrollParams = {
		{
			data = listData,
			createFunc = createCellItemFunc,
            updateCellFunc = updateCellItemFunc,
			offsetX = 0,
            offsetY = 0,
			perFrame = 1,
			itemRect = {x = 0,y = -126,width = 866,height = 126},
			perNums= 1,
			heightGap = 0
		}
	}
	self.scroll_1:styleFill(scrollParams);
    self.scroll_1:hideDragBar()
end

function WelfareActOneView:updateCellItem(view, itemData)
	local panel = view
	local actTaskId = itemData
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId)
	-- dump(actTaskData,"333333333")
	local des = actTaskData.desc
	panel.rich_1:setString(GameConfig.getLanguage(des))
    local actOnlineId = self.actData:getOnlineId()
	-- 唤醒
	local partnerIds = actTaskData.conditionParam
	local awakeNum = 0
	panel.mc_1:showFrame(#partnerIds)
	for i,v in ipairs(partnerIds) do
		local panel_partner = panel.mc_1.currentView["panel_"..i]
		if PartnerModel:isHavedPatnner(v) then
			panel_partner.panel_1:setVisible(true)
			awakeNum = awakeNum + 1
		else
			panel_partner.panel_1:setVisible(false)
		end

		local iconsprite = FuncPartner.getPartnerIconByIdAndSkin(v)
		panel_partner.ctn_1:removeAllChildren()
		panel_partner.ctn_1:addChild(iconsprite)
		iconsprite:setScale(0.75)
		iconsprite:setTouchedFunc(c_func(self.clickOnePartner, self, v))
	end

	-- 奖励
	local reward = actTaskData.reward
	panel.mc_2:showFrame(#reward)

	for i,v in pairs(reward) do
		local rewards = v
		local rewardUI = panel.mc_2.currentView["UI_"..i]
		rewardUI:setRewardItemData({reward = rewards})
	    -- rewardUI:showResItemNum(false)
	    -- 注册点击事件
	    local resNum2,_,_ ,resType2,resId2 = UserModel:getResInfo( rewards )
		FuncCommUI.regesitShowResView(rewardUI,resType2,resNum2,resId2,rewards,true,true)
	end
	
	local mc_btn = panel.mc_btn
	-- 判断是否领取
    local isGetEnd = ActTaskModel:isTaskFinished(actOnlineId, actTaskId, self.actData:getActInfo())
	if isGetEnd then
		-- 已经领取
		mc_btn:showFrame(3)
	else
		local btn = nil
		-- 判断是否可领取
		local isHave = false
		if awakeNum == #partnerIds then
			isHave = true
		end
		
		local isCanGet = false
		if isHave then
			-- 可领取
			mc_btn:showFrame(1)
			btn = mc_btn.currentView.btn_1
			isCanGet = true
		else
			mc_btn:showFrame(2)
			btn = mc_btn.currentView.btn_1
		end
		btn:setTap(c_func(self.btnTap,self,isCanGet,actOnlineId,actTaskId))
	end
end

function WelfareActOneView:clickOnePartner(_partnerId)
	WindowControler:showWindow("GetWayListView", _partnerId)
end

function WelfareActOneView:btnTap(isCanGet,onlineId,taskId)
	if isCanGet then
		ActTaskModel:tryFinishTask(onlineId, taskId)
	else
		-- 不可领取
		-- WindowControler:showTips("不可领取---")
		-- ActTaskModel:jumpToTaskLinkView(taskId)
		local actTaskData = FuncActivity.getActivityTaskConfig(taskId)
		local partnerIds = actTaskData.conditionParam
		local partnerId = nil
		for i,v in ipairs(partnerIds) do
			if not PartnerModel:isHavedPatnner(v) then
				partnerId = v
				break
			end
		end
		WindowControler:showWindow("PartnerView", FuncPartner.PartnerIndex.PARTNER_COMBINE, partnerId)
	end
end


return WelfareActOneView;
