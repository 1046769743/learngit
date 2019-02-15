--
--Author:      zhuguangyuan
--DateTime:    2018-06-01 17:29:25
--Description: 每日充值(小额度)
--

local WelfareActNineView = class("WelfareActNineView", UIBase);

function WelfareActNineView:ctor(winName)
    WelfareActNineView.super.ctor(self, winName)
end

function WelfareActNineView:loadUIComplete()
	-- self:registerEvent()
	-- self:initData()
end 

function WelfareActNineView:initData()

end

function WelfareActNineView:registerEvent()
	WelfareActNineView.super.registerEvent(self);
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.oneDayPass,self)
	EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT,self.oneDayPass,self)
end
function WelfareActNineView:onTaskFinished(event )
	if not self.actData then return end
	local finishData = event.params
	dump(finishData, "finishData", nesting)
	local onlineId = finishData.onlineId
    local tastId = finishData.taskId
	if onlineId == self.actData:getOnlineId() then
		self:initView()
		self:updateUI()
		EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
	end
end

function WelfareActNineView:oneDayPass()
	if not self.actData then
		self:startHide()
		return
	end
	if self.actData:getDisplayLeftTime() <= 0 then
		self:startHide()
		return 
	end
	self:initView()
	self:updateUI()
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

-- 更新选中时候需刷新的数据
function WelfareActNineView:updateWinthActInfo(actData)
	self:registerEvent();
	self.currentFrame = 30
	-- self:updateTime()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)

	self.actData = actData
	-- dump(self.actData, "self.actData", nesting)
	self:initView()
	self:updateUI()
end

function WelfareActNineView:initView()
	-- 显示充值多少仙玉
	local finishedIndex,todoIndex,curTaskId,conditionOkStatus = self:getCurTaskStatus()
	local actTaskData = FuncActivity.getActivityTaskConfig(curTaskId) 
	-- dump(actTaskData, "actTaskData", nesting)
	local needChargeNum = tonumber(actTaskData.conditionParam[1])
	self.txt_2:setString(needChargeNum)
	-- echo("position ========= ",self.txt_3:getPositionX())
	if needChargeNum == 60 then
		self.txt_3:setPositionX(700)
	else
		self.txt_3:setPositionX(710)
	end
	local artifactId = nil
	self.needChargeNumType = {
		type1 = 60,
		type2 = 300,
	}
	if needChargeNum == self.needChargeNumType.type1 then
		self.mc_1:showFrame(1)
		artifactId = "404"
	elseif needChargeNum == self.needChargeNumType.type2 then
		self.mc_1:showFrame(2)
		artifactId = "403"
	end
	local artifactInfo =  FuncArtifact.byIdgetCCInfo(artifactId)
	local sprite = ViewSpine.new(artifactInfo.spine, nil, nil, nil);
	sprite:playLabel("stand");
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(sprite)

    local node = display.newNode()
	node:setContentSize(cc.size(250, 250))
	node:anchor(0.5, 0.5)
	node:addTo(self.ctn_1, 1)

	local artifactData = ArtifactModel:byIdgetData(artifactId)
	artifactInfo.qualityData = artifactData
	
    node:setTouchedFunc(function ()
			WindowControler:showWindow("RankListArtifactDetailView", artifactInfo)
		end)

    self.txt_4:setString(GameConfig.getLanguage(artifactInfo.combineName))
	-- FuncArtifact.addChildToCtn(self.ctn_1,ccid,1,1)

	-- 当日充值奖励
	local rewardArr = actTaskData.reward
	local effectPos = actTaskData.effectPosition
	local numOfReward = table.length(rewardArr)
	self.mc_reward:showFrame(numOfReward)
	for i=1, numOfReward do
		local rewardUI = self.mc_reward.currentView["panel_"..i].UI_1
		local rewardStr = rewardArr[i]
		rewardUI:visible(true)
		rewardUI:setRewardItemData({reward = rewardStr})
	    rewardUI:showResItemNum(true)
	    local resNum1,_,_ ,resType1,resId1 = UserModel:getResInfo( rewardStr )
		FuncCommUI.regesitShowResView(rewardUI,resType1,resNum1,resId1,rewardStr,true,true)
		self:updateItemEffect(rewardStr,effectPos,self.mc_reward.currentView["panel_"..i],i)
	end
end

function WelfareActNineView:updateUI()
	-- 领取状态
	local onlineId = self.actData:getOnlineId()
	local finishedIndex,todoIndex,curTaskId,conditionOkStatus = self:getCurTaskStatus()
	if tonumber(finishedIndex) < tonumber(todoIndex) then
		-- 已达到条件,可领取
		if conditionOkStatus then
			self.mc_2:showFrame(1)
			local contentView = self.mc_2:getCurFrameView()
			local function getTodaysReward()
				ActTaskModel:tryFinishTask(onlineId, curTaskId)
			end
			contentView:setTouchedFunc(c_func(getTodaysReward))
		else
			self.mc_2:showFrame(3)
			local contentView = self.mc_2:getCurFrameView()
			local function gotoDoTask()
				ActTaskModel:jumpToTaskLinkView(curTaskId)
			end
			contentView:setTouchedFunc(c_func(gotoDoTask))
		end
	elseif tonumber(finishedIndex) == tonumber(todoIndex) then
		self.mc_2:showFrame(2)
	end

	-- 五天奖励
	local effectPosAll = {}
	local actInfo = self.actData:getActInfo()
	for i,taskId in ipairs(actInfo.taskList) do
		local actTaskData = FuncActivity.getActivityTaskConfig(taskId) 
		local effectPos = actTaskData.effectPosition
		local rewardStr = actTaskData.reward[1]
		local rewardUI = self.panel_2["panel_"..i].UI_1
		rewardUI:visible(true)
		rewardUI:setRewardItemData({reward = rewardStr})
	    rewardUI:showResItemNum(false)
	    local resNum1,_,_ ,resType1,resId1 = UserModel:getResInfo( rewardStr )
		FuncCommUI.regesitShowResView(rewardUI,resType1,resNum1,resId1,rewardStr,true,true)
		if effectPos ~= nil then
			effectPosAll[i] = effectPos[1]
			self:updateItemEffect(rewardStr,effectPosAll,self.panel_2["panel_"..i],1)
		end
		
		local itemName = FuncCommon.getNameByReward(rewardStr)
		self.panel_2["panel_"..i].panel_2.txt_1:setString(itemName)
		self.panel_2["panel_"..i].mc_1:showFrame(i)
		if i <= finishedIndex then
			self.panel_2["panel_"..i].panel_1:visible(true)
		else
			self.panel_2["panel_"..i].panel_1:visible(false)
		end
	end

	-- 设置进度条
    local preogress = self.panel_2.panel_jindu.progress_1
    local percent = (todoIndex-1)/(table.length(actInfo.taskList)-1) * 100
    preogress:setDirection(ProgressBar.l_r)
    preogress:setPercent(percent)
end

-- 获取当天开启的taskId
-- finishedIndex,todoIndex,curTaskId,conditionOkStatus
-- finishedIndex <= todoIndex,=时完成该活动的所有任务
function WelfareActNineView:getCurTaskStatus()
	local taskList = self.actData:getActInfo().taskList
	local onlineId = self.actData:getOnlineId()
	local actInfo = self.actData:getActInfo()
	local actType = self.actData:getActType()

	local finishedIndex,todoIndex,curTaskId,conditionOkStatus = 0,1,"72001",false

	-- 获取要展示的taskIndex
	-- 完成今日充值后任仍然展示今日 
	-- 第二天才展示下一个的
	-- == 按顺序展示
	for index,oneTaskId in ipairs(taskList) do
		local isFinished = ActTaskModel:isTaskFinished(onlineId, oneTaskId, actInfo)
		echo("_____ index,oneTaskId,isFinished ________",index,oneTaskId,isFinished)
		if not isFinished then
			todoIndex = index
			break
		else
			todoIndex = index
		end
	end

	-- == 用充值记录及最大充值是否今日充值来限定能否显示下一个活动
	local bornTime = CarnivalModel:getBornTime()
	local age = TimeControler:getServerTime() - bornTime
	local timeInfo = self.actData:getTimeInfo()
	dump(timeInfo, "timeInfo", nesting)
	local actStartTime = math.floor((timeInfo.start_t - bornTime) /(24*3600))
	local maxOpenDate = math.floor(age/(24*3600)) + 1
	echo("______ 本期活动开启日期,创角第几天",actStartTime,maxOpenDate)
	local finishedChargedData = ActConditionModel:getChargeDateData(onlineId)
	local maxChargeDate = 0
	local validChargeDaysNum = 0 -- 本期活动内有充值的天数
	local validChargeNum = FuncActivity.getActTaskConfigById(taskList[1]).conditionParam[1]
	for chargeDate,chargeNum in pairs(finishedChargedData) do
		if tonumber(chargeDate) > tonumber(actStartTime) then
			if tonumber(maxChargeDate) < tonumber(chargeDate) and tonumber(chargeNum) >= tonumber(validChargeNum) then
				maxChargeDate = chargeDate
			end
			if tonumber(chargeNum) >= tonumber(validChargeNum) then
				validChargeDaysNum = validChargeDaysNum + 1
			end
		end
	end
	-- 最大充值日不是今天,则今天还可以充,所以可充值日宽限一天
	if maxChargeDate < maxOpenDate then
		validChargeDaysNum = validChargeDaysNum + 1
	end

	-- 已经完成了今天的充值任务并已领取 则只展示今天的状态
	-- 到明天才展示下一天的状态 才给跳转充值的入口
	if (todoIndex > validChargeDaysNum) and (validChargeDaysNum > 0) then
		todoIndex = validChargeDaysNum
	end
	-- 如果已经完成了所有任务,则显示到最大那个
	if tonumber(todoIndex) > table.length(taskList) then
		todoIndex = table.length(taskList)
	end

	curTaskId = taskList[tonumber(todoIndex)]
	local isFinished = ActTaskModel:isTaskFinished(onlineId, curTaskId, actInfo)
	if isFinished then
		finishedIndex = todoIndex
	else
		finishedIndex = todoIndex - 1
	end

	local isConditionOk = ActConditionModel:isTaskConditionOk(onlineId, curTaskId, actType)
	if isConditionOk then
		conditionOkStatus = true
	else
		conditionOkStatus = false
	end
	echo("_______finishedIndex,todoIndex,curTaskId,conditionOkStatus ",finishedIndex,todoIndex,curTaskId,conditionOkStatus)
	return finishedIndex,todoIndex,curTaskId,conditionOkStatus
end

function WelfareActNineView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		if leftTime<=0 then
			EventControler:dispatchEvent(ActivityEvent.ONE_ACT_TIME_OVER)
			self:startHide()
		end
		self.txt_dao2:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

--添加item上的闪光特效
function WelfareActNineView:updateItemEffect(itemData, effectPos, panel, index)
    local ctnUp = panel.ctn_shang
    local ctnDown = panel.ctn_xia
    if effectPos then
        if effectPos[index] and tonumber(index) == tonumber(effectPos[index]) then
            -- 需要特效且该特效不存在时才新建特效
            -- if not ctnUp:getChildByName("ani1") then
            ctnUp:removeAllChildren()
            ctnDown:removeAllChildren()
            local ani1, ani2 = self:addAnimation(itemData, ctnUp, ctnDown)
                -- ani1:setName("ani1")
                -- ani2:setName("ani2")
            -- end
            -- ctnUp:getChildByName("ani1"):setVisible(true)
            -- ctnDown:getChildByName("ani2"):setVisible(true)

        else
            -- if ctnUp:getChildByName("ani1") then
                ctnUp:removeAllChildren()
                ctnDown:removeAllChildren()
                -- ctnUp:getChildByName("ani1"):setVisible(false)
                -- ctnDown:getChildByName("ani2"):setVisible(false)
            -- end                           
        end
    else
        ctnUp:removeAllChildren()
        ctnDown:removeAllChildren()
        -- if ctnUp:getChildByName("ani1") then
        --     ctnUp:getChildByName("ani1"):setVisible(false)
        --     ctnDown:getChildByName("ani2"):setVisible(false)
        -- end
    end
end

function WelfareActNineView:addAnimation(reward, ctnUp, ctnDown)
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
    ani1:setScale(0.85)
    ani1:pos(0, 0)
    ani2:setScale(0.85)
    ani2:pos(0, 0)
    return ani1, ani2
end

function WelfareActNineView:deleteMe()
	WelfareActNineView.super.deleteMe(self);
end

return WelfareActNineView;
