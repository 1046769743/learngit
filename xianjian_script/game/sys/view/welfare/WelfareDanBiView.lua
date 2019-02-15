--[[
	Author: TODO
	Date:2018-08-08
	Description: TODO
]]

local WelfareDanBiView = class("WelfareDanBiView", UIBase);

function WelfareDanBiView:ctor(winName)
    WelfareDanBiView.super.ctor(self, winName)
end

function WelfareDanBiView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WelfareDanBiView:registerEvent()
	WelfareDanBiView.super.registerEvent(self);

	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
	EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT, self.reFreshUI, self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR_COMPLETE, self.reFreshUI, self)
end

function WelfareDanBiView:reFreshUI( )
	if not self.actData then 
		return 
	end
	self:initListUI( )
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

function WelfareDanBiView:onTaskFinished(event)
	if not self.actData then 
		return 
	end

	local params = event.params
	local onlineId = params.onlineId
    local tastId = params.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initListUI()
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

function WelfareDanBiView:initData()
	-- TODO
end

function WelfareDanBiView:initView()
	-- TODO
end

function WelfareDanBiView:initViewAlign()
	-- TODO
end

function WelfareDanBiView:updateUI()
	-- TODO
end

function WelfareDanBiView:updateWinthActInfo(actData)
	self.actData = actData
	self.actInfo = actData:getActInfo()
	self.actOnlineId = self.actData:getOnlineId()
	-- self.ctn_1:removeAllChildren()
    -- local sprite = FuncPartner.getPartnerLiHuiByIdAndSkin("5022")
    -- sprite:setScale(0.4)
    -- local maskSprite = display.newSprite(FuncRes.iconOther("loading_img_zhezhao"))
    -- maskSprite:pos(0, 170)
    -- sprite = FuncCommUI.getMaskCan(maskSprite, sprite)
	-- self.ctn_1:addChild(sprite)  --宝物图片

    self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self:initListUI()
end

function WelfareDanBiView:initListUI( )	
	local listData = {}
	for i,v in pairs(self.actInfo.taskList) do
		table.insert(listData, v)
	end
	--排序 需要有沉底逻辑
	table.sort(listData,c_func(self.sortFunc,self))

    self.listData = listData
	self:initList(listData)
end

function WelfareDanBiView:sortFunc(taskIdA, taskIdB)
	local getA = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdA, self.actInfo)
	local getB = ActTaskModel:isTaskFinished(self.actOnlineId, taskIdB, self.actInfo)
	if getA == getB then
		local finishNumA,allNumA = ActConditionModel:getTaskConditionProgress(self.actOnlineId, taskIdA)
		local finishNumB,allNumB= ActConditionModel:getTaskConditionProgress(self.actOnlineId, taskIdB)
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

--加载滚动条
function WelfareDanBiView:initList(listData)
	self.panel_tiao:visible(false)
	local createCellItemFunc = function ( itemData)
		local view = UIBaseDef:cloneOneView(self.panel_tiao)
		self:updateCellItem(view, itemData)
		return view
	end
	local updateCellItemFunc = function (itemData,itemView)
        self:updateCellItem(itemView, itemData)
    end
	local scrollParams = {
		{
			data = listData,
			createFunc = createCellItemFunc,
            updateCellFunc = updateCellItemFunc,
			offsetX = -15,
            offsetY = -5,
			perFrame = 1,
			itemRect = {x = 0, y = -290, width = 300, height = 290},
			perNums= 1,
			heightGap = 0,
			widthGap = -60,
		}
	}
	self.scroll_1:styleFill(scrollParams)
    self.scroll_1:hideDragBar()

    if not self._lastIndex then
    	self._lastIndex = 1
    end
    self.scroll_1:gotoTargetPos(self._lastIndex, 1, 1)
end

--加载滚动条 组件
function WelfareDanBiView:updateCellItem(view, itemData)
	local panel = view
	local actTaskId = itemData
	local actTaskData = FuncActivity.getActivityTaskConfig(actTaskId)
	local des = actTaskData.desc
	local conditionNum = actTaskData.conditionNum

	for i = 1, 4 do
		panel["panel_"..i].UI_1:setVisible(false)
	end

	--在哪个位置加光效
	local effectPos = actTaskData.effectPosition
	dump(effectPos,"effectPos ============ ")

	-- 奖励
	local rewards = actTaskData.reward
	
	for i=1,4 do
		panel["panel_"..i].ctn_shang:removeAllChildren()
		panel["panel_"..i].ctn_xia:removeAllChildren()
	end

	for i,v in pairs(rewards) do
		if i <= 4 then
			local commUI = panel["panel_"..i].UI_1
			commUI:setVisible(true)
			commUI:setRewardItemData({reward = v})
	        -- 注册点击事件
	        local resNum, _, _, resType, resId = UserModel:getResInfo(v)
	    	FuncCommUI.regesitShowResView(commUI, resType, resNum, resId, v, true, true)
    		self:updateItemEffect(v,effectPos,panel["panel_"..i],i)
		end
	end

	-- 完成进度
	local actOnlineId = self.actData:getOnlineId()
	local finishNum,allNum = ActConditionModel:getTaskConditionProgress(actOnlineId, actTaskId)

	local allNumWan = FuncActivity.getTaskCanDoNum(actTaskId)
	local hasGotTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, self.actInfo)
	local finishNumWan = allNumWan - hasGotTimes
 	panel.txt_1:setString(GameConfig.getLanguageWithSwap(des, conditionNum))
	panel.txt_2:setString(GameConfig.getLanguageWithSwap("#tid_activity_5153", finishNumWan))

	-- 判断是否已领取
	local mc_btn = panel.mc_btn
	local isGet = (tonumber(finishNumWan) <= 0)
	if not isGet then
		panel.txt_2:setVisible(true)
		local btn = nil
		local isCanGet = false

		local isConditionOk = (finishNum >= allNum)
		local receiveTimes = ActTaskModel:getTaskReceiveTimes(actOnlineId, actTaskId, self.actInfo)
		local targetFinishTimes = receiveTimes + 1
		isConditionOk = ActConditionModel:isTaskConditionOk(actOnlineId, actTaskId, self.actData:getActType(), targetFinishTimes)

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
		panel.txt_2:setVisible(false)
		mc_btn:showFrame(3)
	end
end

--添加item上的闪光特效
function WelfareDanBiView:updateItemEffect(itemData, effectPos, panel, index)
    local ctnUp = panel.ctn_shang
    local ctnDown = panel.ctn_xia
    if effectPos then
        if effectPos[index] and tonumber(index) == tonumber(effectPos[index]) then
            ctnUp:removeAllChildren()
            ctnDown:removeAllChildren()
            local ani1, ani2 = self:addAnimation(itemData, ctnUp, ctnDown)

        else
            ctnUp:removeAllChildren()
            ctnDown:removeAllChildren()
                          
        end
    else
        ctnUp:removeAllChildren()
        ctnDown:removeAllChildren()
    end
end

function WelfareDanBiView:addAnimation(reward, ctnUp, ctnDown)
    local _effectType = {
        [1] = {
            down = "UI_shop_fangxiaceng",
            up = "UI_shop_fangshangceng",
        },
        [2] = {
            down = "UI_shop_yuanxiaceng",
            up = "UI_shop_yuanshangceng",
        },
        [3] = {
            down = "UI_shop_lenxiaceng",
            up = "UI_shop_lenshangceng",
        },
    }
    local frame = FuncCommon.getShapByReward(reward)
    -- echo("\nreward==", reward, frame)
    local ani1 = self:createUIArmature("UI_shop", _effectType[frame].up, ctnUp, true, nil)
    local ani2 = self:createUIArmature("UI_shop", _effectType[frame].down, ctnDown, true, nil)
    ani1:setScale(0.8)
    ani1:pos(0, 0)
    ani2:setScale(0.8)
    ani2:pos(0, 0)
    return ani1, ani2
end

--点击了领取或者前往按钮
function WelfareDanBiView:btnTap(isCanGet,onlineId, taskId)
	if isCanGet then
		ActTaskModel:tryFinishTask(onlineId, taskId)
	else
		-- 前往
		ActTaskModel:jumpToTaskLinkView(taskId)
	end
end

--倒计时
function WelfareDanBiView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareDanBiView:deleteMe()
	-- TODO

	WelfareDanBiView.super.deleteMe(self);
end

return WelfareDanBiView;
