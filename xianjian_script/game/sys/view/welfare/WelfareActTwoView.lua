--
--Author:      
--Description: 造物送好礼137,锁妖塔活动153,等仙台154,单笔充值156,无底深渊挑战157 等都走这里
--

--
--Author:      zhuguangyuan
--DateTime:    2018-06-14 11:32:53
--Description: 单笔充值计数156,需做特殊处理
--
-- 1.每个任务可完成多次,item中显示 剩余可完成次数/最多可完成次数
-- 2.每个任务可完成的一次完成与否,都走task finish逻辑
-- 3.其实相当于把多个task 糅合成一个task

local WelfareActTwoView = class("WelfareActTwoView", UIBase);

function WelfareActTwoView:ctor(winName)
    WelfareActTwoView.super.ctor(self, winName);
end

function WelfareActTwoView:loadUIComplete()
	self:registerEvent();
	-- self.panel_bao.mc_1:showFrame(2)
end 

function WelfareActTwoView:registerEvent()
	WelfareActTwoView.super.registerEvent();

	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
	
	EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT, 
			self.reFreshUI, self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE, 
			self.reFreshUI, self)
end
function WelfareActTwoView:reFreshUI( )
	if not self.actData then return end
	self:initListUI( )
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end
function WelfareActTwoView:onTaskFinished(event )
	if not self.actData then return end
	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initListUI()
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end
function WelfareActTwoView:updateWinthActInfo(actData)
	self.actData = actData
	local actInfo = actData:getActInfo()

	local title = actInfo.title
	-- local titTxt = self.panel_1.txt_1

	local desc = actInfo.desc
	local descTxt = self.txt_1
	descTxt:setString(GameConfig.getLanguage(desc))

	-- self.panel_bao.mc_1:visible(false)
	local titlePath = FuncRes.getActiveTitleIcon(actInfo.titlePicture) 
	self.ctn_title:removeAllChildren()
	local titlePathSp = display.newSprite(titlePath)
	titlePathSp:anchor(0.5,0.5)
	self.ctn_title:addChild(titlePathSp)

    self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:initListUI()
end

function WelfareActTwoView:initListUI( )
	-- 需做特殊处理的活动 单笔充值活动id
	self.specialMap = {"156"}
	
	local listData = {}
	local actInfo = self.actData:getActInfo()
	for i,v in pairs(actInfo.taskList) do
		table.insert(listData,v)
	end
	table.sort(listData,c_func(self.sortFunc,self))

	-- dump(listData, "-------", 4)
    self.listData = listData
	self:initList(listData)
end

function WelfareActTwoView:sortFunc( a,b )
	local actOnlineId = self.actData:getOnlineId()
	local actInfo = self.actData:getActInfo()
	local taskIdA = a
	local taskIdB = b
	-- -- 单笔充值活动只做顺序排序,不做领取与否的沉底排序
	-- if table.isValueIn(self.specialMap,tostring(actOnlineId)) then
	-- 	if tonumber(taskIdA) < tonumber(taskIdB) then
	-- 		return true
	-- 	else
	-- 		return false
	-- 	end
	-- end

	local getA = ActTaskModel:isTaskFinished(actOnlineId, taskIdA,actInfo )
	local getB = ActTaskModel:isTaskFinished(actOnlineId, taskIdB,actInfo )
	if getA == getB then
		local finishNumA,allNumA = ActConditionModel:getTaskConditionProgress(actOnlineId, taskIdA)
		local finishNumB,allNumB= ActConditionModel:getTaskConditionProgress(actOnlineId, taskIdB)
		if finishNumA >= allNumA and finishNumB >= allNumB then
			-- 都可以领取
			if tonumber(taskIdA) < tonumber(taskIdB) then
				return true
			end
			return false
		elseif finishNumA < allNumA and finishNumB < allNumB then 
			-- 都不可以领取
			if tonumber(taskIdA) < tonumber(taskIdB) then
				return true
			end
			return false
		else
			if finishNumA >= allNumA then
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


function WelfareActTwoView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActTwoView:initList(listData)
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
			offsetX = -6,
            offsetY = -1,
			perFrame = 1,
			itemRect = {x = 0,y = 0,width = 638.8,height = 168.5},
			perNums= 1,
			heightGap = -35
		}
	}
	self.scroll_1:styleFill(scrollParams);
    self.scroll_1:hideDragBar()

    if not  self._lastIndex then
    	self._lastIndex = 1
    end
    self.scroll_1:gotoTargetPos(self._lastIndex, 1, 1)
end

function WelfareActTwoView:updateCellItem(view, itemData)
	local panel = view
	local actTaskId = itemData
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId) 
	local des = actTaskData.desc
	local conditionNum = actTaskData.conditionNum
	local txt = panel.txt_1
	txt:setString(GameConfig.getLanguage(des))

	-- 奖励
	local rewards = actTaskData.reward
	local rewardUI = panel.UI_1
	local posX = rewardUI:getPositionX()
	local posY = rewardUI:getPositionY()
	local ctn = panel.ctn_reward
	ctn:removeAllChildren()
	rewardUI:visible(false)
	for i,v in pairs(rewards) do
		local ui = UIBaseDef:cloneOneView(rewardUI)
		ui:setRewardItemData({reward = v})
        -- ui:showResItemNum(false)
        -- 注册点击事件
        local resNum,_,_ ,resType,resId = UserModel:getResInfo( v )
    	FuncCommUI.regesitShowResView(ui,resType,resNum,resId,v,true,true)

    	ctn:addChild(ui)
    	ui:pos((i-1)*90+posX,posY)

	end

	-- 完成进度
	local actOnlineId = self.actData:getOnlineId()
	local finishNum,allNum = ActConditionModel:getTaskConditionProgress(actOnlineId, actTaskId)

	local txtJD = panel.txt_2
	local finishNumWan = FuncCommUI.turnOneNumToStr(finishNum )
	local allNumWan = FuncCommUI.turnOneNumToStr(allNum)
	local hasGotTimes = 0
	-- 如果是小额充值活动,则显示需要调整一下
	if table.isValueIn(self.specialMap,tostring(actOnlineId)) then
		hasGotTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, self.actData:getActInfo())
		allNumWan = FuncActivity.getTaskCanDoNum(actTaskId)
		finishNumWan = allNumWan - hasGotTimes -- 剩余可做次数
	end
 	
 	if tonumber(actOnlineId) == 156  then
 		txtJD:setString("还可领取"..finishNumWan.."次")
 	else
 		txtJD:setString(finishNumWan.."/"..allNumWan)
 	end
	
	-- 判断是否已领取
	local mc_btn = panel.mc_btn
	local isGet = ActTaskModel:isTaskFinished(actOnlineId, actTaskId, self.actData:getActInfo())
	if table.isValueIn(self.specialMap,tostring(actOnlineId)) then
		isGet = (tonumber(finishNumWan) <= 0) 
	end
	if not isGet then
		txtJD:visible(true)
		local btn = nil
		local isCanGet = false

		local isConditionOk = (finishNum >= allNum)
		if table.isValueIn(self.specialMap,tostring(actOnlineId)) then
			local receiveTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, self.actData:getActInfo())
			local targetFinishTimes = receiveTimes + 1
			isConditionOk = ActConditionModel:isTaskConditionOk(actOnlineId, actTaskId, self.actData:getActType(),targetFinishTimes)
		end

		if isConditionOk then
			-- 可领取
			mc_btn:showFrame(1)
			btn = mc_btn.currentView.btn_1
			isCanGet = true
		else
			-- 前往
			mc_btn:showFrame(2)
			btn = mc_btn.currentView.btn_1
		end
		btn:setTap(c_func(self.btnTap,self,isCanGet,actOnlineId,actTaskId))
	else
		txtJD:visible(false)
		mc_btn:showFrame(3)
	end
end
function WelfareActTwoView:btnTap(isCanGet,onlineId, taskId)
	-- 保存本次位置
	-- self:saveCurPos()

	if isCanGet then
		ActTaskModel:tryFinishTask(onlineId, taskId)
	else
		-- 前往
		ActTaskModel:jumpToTaskLinkView(taskId)
	end
	
end

function WelfareActTwoView:saveCurPos()
	local x,index = self.scroll_1:getGroupPos(1)
	if tonumber(self._lastIndex) ~= tonumber(index) then
		self._lastIndex = index
	end
end

return WelfareActTwoView;
