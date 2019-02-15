-- 兑换有礼
local WelfareActThrView = class("WelfareActThrView", UIBase);

function WelfareActThrView:ctor(winName)
    WelfareActThrView.super.ctor(self, winName);
end

function WelfareActThrView:loadUIComplete()
	self:registerEvent();
	self.panel_bao.mc_1:showFrame(3)
end 

function WelfareActThrView:registerEvent()
	WelfareActThrView.super.registerEvent();
    EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
			self.checkRedPoint, self)
end

function WelfareActThrView:checkRedPoint( )
	if not self.actData then return end
	
	local actInfo = self.actData:getActInfo()
	for i,v in pairs(self.listData) do
        local panel = self.scroll_1:getViewByData(v)
        if panel then
            self:updateCellItem(panel,v)
        end
	end
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

function WelfareActThrView:onTaskFinished(event )
	if not self.actData then return end
	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initListUI( )
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

function WelfareActThrView:updateWinthActInfo(actData)
	self.actData = actData
	local actInfo = actData:getActInfo()
	local title = actInfo.title
	local titTxt = self.panel_1.txt_1
	-- titTxt:setString(GameConfig.getLanguage(title))

	local desc = actInfo.desc
	local descTxt = self.txt_1
	descTxt:setString(GameConfig.getLanguage(desc))

	-- self.panel_bao.mc_1:visible(false)
	-- local titlePath = FuncRes.getActiveTitleIcon(actInfo.titlePicture) 
	-- self.panel_bao.ctn_title:removeAllChildren()
	-- local titlePathSp = display.newSprite(titlePath)
	-- titlePathSp:anchor(0,1)
	-- self.panel_bao.ctn_title:addChild(titlePathSp)
	
	-- 倒计时
    self.currentFrame = 30
	self:updateTime()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:initListUI( )
end

function WelfareActThrView:initListUI( )
	local listData = {}
	local actInfo = self.actData:getActInfo()
	for i,v in pairs(actInfo.taskList) do
		table.insert(listData,v)
	end
	table.sort(listData,c_func(self.sortFunc,self))


	dump(listData, "-------", 4)
    self.listData = listData
	self:initList(listData)
end

function WelfareActThrView:sortFunc( a,b )
	local actOnlineId = self.actData:getOnlineId()
	local actInfo = self.actData:getActInfo()
	local taskIdA = a
	local taskIdB = b

	local getA = ActTaskModel:isTaskFinished(actOnlineId, taskIdA,actInfo )
	local getB = ActTaskModel:isTaskFinished(actOnlineId, taskIdB,actInfo )
	if getA == getB then
		local finishNumA,allNumA = ActConditionModel:getTaskConditionProgress(actOnlineId, taskIdA)
		local finishNumB,allNumB= ActConditionModel:getTaskConditionProgress(actOnlineId, taskIdB)
		if (finishNumA >= allNumA and finishNumB >= allNumB) or 
			finishNumA < allNumA and finishNumB < allNumB then
			-- 都可以领取
			if tonumber(taskIdA) > tonumber(taskIdB) then
				return true
			end
			return false
		else
			if finishNumA <= allNumA then
				return true
			else
				return false
			end
		end

	else
		if not getA then
			return true
		end
		return false
	end
	return false
end


function WelfareActThrView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActThrView:initList(listData)
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
			itemRect = {x = 0,y = -131,width = 845,height = 131},
			perNums= 1,
			heightGap = 0
		}
	}
	self.scroll_1:styleFill(scrollParams);
    self.scroll_1:hideDragBar()
end

function WelfareActThrView:updateCellItem(view, itemData)
	local panel = view
	local actTaskId = itemData
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId) 


	-- 兑换条件
	local conditionParam = actTaskData.conditionParam[1]
	panel.UI_1:setRewardItemData({reward = conditionParam})
    panel.UI_1:showResItemNum(false)

    -- 注册点击事件
    local resNum1,_,_ ,resType1,resId1 = UserModel:getResInfo( conditionParam )
	FuncCommUI.regesitShowResView(panel.UI_1,resType1,resNum1,resId1,conditionParam,true,true)
	
	echo(conditionParam," ==============")
	local itemName = FuncDataResource.getResNameById(resType1,resId1)
	local itemFrame = 1
    if tonumber(resType1) == 1 then
        itemFrame = FuncItem.getItemQuality( resId1 ) + 2
    end
	panel.mc_zi1:showFrame(itemFrame)
	panel.mc_zi1.currentView.txt_1:setString(itemName.."*"..resNum1)
	

	-- 奖励
	local rewards = actTaskData.reward[1]
	local rewardUI = panel.UI_2
	rewardUI:setRewardItemData({reward = rewards})
    rewardUI:showResItemNum(false)
    -- 注册点击事件
    local resNum2,_,_ ,resType2,resId2 = UserModel:getResInfo( rewards )
	FuncCommUI.regesitShowResView(rewardUI,resType2,resNum2,resId2,rewards,true,true)
	
	local itemName2 = FuncDataResource.getResNameById(resType2,resId2)
	local itemFrame2 = 1
    if tonumber(resType2) == 1 then
        itemFrame2 = FuncItem.getItemQuality( resId2 ) + 2
    end
	panel.mc_zi2:showFrame(itemFrame2)
	panel.mc_zi2.currentView.txt_1:setString(itemName2.."*"..resNum2)
	
	local onlineId = self.actData:getOnlineId()

    -- 任务可完成次数
    local times = ActTaskModel:getTaskReceiveTimes(onlineId, actTaskId,  self.actData:getActInfo())
    local allTimes = actTaskData.times
    panel.txt_2:setString(times.."/"..allTimes)

	local mc_btn = panel.mc_btn
	-- 判断是否可兑换
	local isGetEnd = ActTaskModel:isTaskFinished(onlineId, actTaskId, self.actData:getActInfo())
	if isGetEnd then
		panel.txt_2:visible(false)
		mc_btn:showFrame(2)
	else
		panel.txt_2:visible(true)
		mc_btn:showFrame(1)
		local btn = mc_btn.currentView.btn_1
		-- 判断是否可兑换
        local strT = string.split(conditionParam,",")
        local conditonData = {}
		conditonData.gold = tonumber(strT[2])
		conditonData.level = actTaskData.levelLimit or 0
		local limitLevel = actTaskData.levelLimit or 0
		if UserModel:getGold()>= tonumber(strT[2]) and 
			UserModel:level() >= limitLevel then
			FilterTools.clearFilter(btn)
		else
			FilterTools.setGrayFilter(btn)
		end
		btn:setTap(c_func(self.btnTap,self,conditonData,onlineId,actTaskId))
	end
end
function WelfareActThrView:btnTap(conditonData,onlineId, taskId)
	if conditonData.level > UserModel:level() then
		WindowControler:showTips(GameConfig.getLanguage("tid_char_1003"))
	elseif conditonData.gold > UserModel:getGold() then
		WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
	else
		ActTaskModel:tryFinishTask(onlineId, taskId)
	end
end

return WelfareActThrView;
;
