--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 10:22:28
--Description: 开服嘉年华主界面
--

local CarnivalMainView = class("CarnivalMainView", UIBase);

function CarnivalMainView:ctor(winName)
    CarnivalMainView.super.ctor(self, winName)
end

function CarnivalMainView:loadUIComplete()
	-- CarnivalModel:checkRedPoint()	
	self:initData()	
	self:registerEvent()
	self:initView()
	self:initViewAlign()
	-- self:updateUI()
	if CarnivalModel.haveCheckRedPoint ~= true then
		self:updateUI()
	end

	ShopModel:getGuildModelData()
end 


--------------------------------------------------------------------------
-- ===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
-- 跳转到其他界面参与战斗时恢复界面用
-------------------------------------------------------------------------- 
function CarnivalMainView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 CarnivalMainView")
    return  {
    			themeId = self.currentThemeId,
                activityId = self.currentActivityId,
                taskId = self.currentTaskId
            }
end
function CarnivalMainView:onBattleExitResume(cacheData )
    -- dump(cacheData,"战斗恢复view CarnivalMainView")
    CarnivalMainView.super.onBattleExitResume(cacheData)
    if cacheData and cacheData.themeId and cacheData.activityId then
        self.currentThemeId = cacheData.themeId
        self.currentActivityId = cacheData.activityId
        self.currentTaskId = cacheData.taskId

        self:initData()
        self:updateUI() --更新UI
    end
end

function CarnivalMainView:registerEvent()
	CarnivalMainView.super.registerEvent(self);
	self:registClickClose("out")
	self.btn_1:setTap(c_func(self.onClose, self))  -- 返回
	EventControler:addEventListener(CarnivalEvent.CARNIVAL_PERIOD_CHANGED, self.newPeriodOpen, self)
	-- 点击全目标奖励框
	self.panel_dian.btn_1:setTap(c_func(self.openWholeTargetRewardView, self)) 

	-- 显示嘉年华倒计时
    self:scheduleUpdateWithPriorityLua(c_func(self.downTime, self), 0);
    -- 一个主题开启
    EventControler:addEventListener(CarnivalEvent.ONE_THEME_OPENED, self.newThemeOpen, self)
	-- 嘉年华关闭
    EventControler:addEventListener(CarnivalEvent.CARNIVAL_CLOSE, self.onClose, self)
 
    -- 获取完一个奖励,更新目标奖励进度条
    EventControler:addEventListener(CarnivalEvent.GOT_ONE_TASK_REWARD, self.onTaskStatusChange, self)
    -- 领取了全目标奖励,全目标头像红点消失
    EventControler:addEventListener(CarnivalEvent.GOT_WHOLE_TASK_REWARD, self.onBigRewardGot, self)



    -- 用户等级提升
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.onTaskStatusChange, self)

	-- 六界通关
    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, self.onTaskStatusChange, self)
	-- 精英通关
    EventControler:addEventListener(EliteEvent.ELITE_UNIT_TONGGUAN, self.onTaskStatusChange, self)

	-- 法宝圆满
    EventControler:addEventListener(TreasureEvent.FABAO_YUANMAN, self.onTaskStatusChange, self)

    -- 法宝升星/觉醒/合成
    EventControler:addEventListener(TreasureNewEvent.UP_STAR_SUCCESS_EVENT, self.onTaskStatusChange, self)
    EventControler:addEventListener(TreasureNewEvent.JUEXING_SUCCESS_EVENT, self.onTaskStatusChange, self)
    EventControler:addEventListener(TreasureNewEvent.COMBINE_SUCCESS_EVENT, self.onTaskStatusChange, self)


	--伙伴的数目发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT, self.onTaskStatusChange, self)
    --某一个伙伴升级成功
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT, self.onTaskStatusChange, self)
    --伙伴的星级提高
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT, self.onTaskStatusChange, self)
    --品质发生变化
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT, self.onTaskStatusChange, self)
    --伙伴的技能发生了变化
    EventControler:addEventListener(PartnerEvent.PARTNER_SKILL_CHANGED_EVENT, self.onTaskStatusChange, self)

    -- 竞技场排名发生变化
    EventControler:addEventListener(PvpEvent.PVP_RANK_CHANGED, self.onTaskStatusChange, self)
    -- 竞技币发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_PVP_COIN_CHANGE, self.onTaskStatusChange, self)

    -- if self.carnivalPeriod == FuncCarnival.CarnivalId.SECOND_PERIOD then
		-- 购买体力监听
    	EventControler:addEventListener(UserEvent.USEREVENT_BUY_SP_SUCCESS, self.onTaskStatusChange, self)
    	-- 消耗铜钱监听
    	EventControler:addEventListener(UserEvent.USEREVENT_COIN_CHANGE, self.onTaskStatusChange, self)
    	--消耗仙玉监听 用于监听仙盟捐献
    	EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.onTaskStatusChange, self)
    	--抽取神器事件
    	EventControler:addEventListener(ArtifactEvent.ACTEVENT_CHOUKA_CALLBACK, self.onTaskStatusChange, self)
    	--激活或进阶神器
    	EventControler:addEventListener(ArtifactEvent.ACTEVENT_COMBINATION_ADVANCED, self.onTaskStatusChange, self)
    	--竞技场扫荡
    	EventControler:addEventListener(PvpEvent.PVP_SWEEP_SUCCESS_EVENT, self.onTaskStatusChange, self) 
    	--巅峰竞技场段位积分监听事件
    	EventControler:addEventListener(CrossPeakEvent.CROSSPEAK_SEGMENTANDSCORE_CHANGE_EVENT, self.onTaskStatusChange, self)	
	-- end
	--聚魂次数发生变化
	EventControler:addEventListener(NewLotteryEvent.MOVE_CELL_RUNACTION, self.onTaskStatusChange, self)
	--领取可选奖励
	EventControler:addEventListener(CarnivalEvent.GET_CARNIVAL_OPTION_REWARD, self.getOptionReward, self)
end

function CarnivalMainView:getOptionReward(event)
    local rewardIndex = event.params.index
    local taskId = event.params.taskId
    CarnivalModel:getTaskReward(self.currentThemeId, taskId, rewardIndex)
end

function CarnivalMainView:newPeriodOpen()
	self.isNewPeriod = true
	self:initData()
	self:updateUI() 
end

function CarnivalMainView:newThemeOpen()
	self:initData()
	self:initView()
	self:updateUI()  
end

function CarnivalMainView:onBigRewardGot()
	-- 发送主题红点
	CarnivalModel:sentHomeRedPoint()
	self:updateTargetRewardIcon()
end
-- -- 领取奖励后做相应的更新
-- function CarnivalMainView:onTaskRewardGot(event)
-- 	-- 发送主题红点
-- 	CarnivalModel:sentHomeRedPoint()
-- 	self.taskList = self:getTaskListAfterSorted(self.currentActivityId)
-- 	self.currentTaskId = self.taskList[1]

-- self:updateUI()
-- end

function CarnivalMainView:onTaskStatusChange()
	-- 发送主题红点
	CarnivalModel:sentHomeRedPoint()
	self.taskList = self:getTaskListAfterSorted(self.currentActivityId)
	self.currentTaskId = self.taskList[1]

	self:updateUI()
end



--------------------------------------------------------------------------
---------------------- 初始化数据 			 -----------------------------
-------------------------------------------------------------------------- 
function CarnivalMainView:initData()
	-- 发送主题红点
	CarnivalModel:sentHomeRedPoint()

	self.carnivalPeriod = CarnivalModel:getPeriodStatus()

	self.leftTime = CarnivalModel:getCarnivalLeftTime(self.carnivalPeriod)
	self.frameCount = 0

	if self.carnivalPeriod == FuncCarnival.CarnivalId.SECOND_PERIOD then
		ShopModel:getGuildModelData()
	end
	-- 当前嘉年华对应的主题列表
	self.themeIdList = CarnivalModel:getVisibleThemeIds()
	dump(self.themeIdList, "\n\nself.themeIdList===")
	local lastPeriod = CarnivalModel:getLastPeriod()
	if not self.currentThemeId then
		self.currentThemeId = CarnivalModel:getNewOpenThemeId()
	elseif self.carnivalPeriod ~= lastPeriod then
		self.currentThemeId = CarnivalModel:getNewOpenThemeId()
	end	
	self.newOpenThemeId = CarnivalModel:getNewOpenThemeId()

	-- 当前主题对应的活动列表
	-- echo("\n\nself.currentThemeId====", self.currentThemeId)
	self.activityList = FuncCarnival.getActivitiesByThemeId( self.currentThemeId ) -- todo
	if not self.currentActivityId  then
		self.currentActivityId = self.activityList[1]  -- 默认选中第一个活动
	elseif self.carnivalPeriod ~= lastPeriod then
		self.currentActivityId = self.activityList[1]  -- 默认选中第一个活动
	end

	-- 当前活动对应的任务列表
	self.taskList = self:getTaskListAfterSorted(self.currentActivityId)
	-- dump(self.taskList, "\n\nself.taskList===")
	if not self.currentTaskId then
		self.currentTaskId = self.taskList[1]
	elseif self.carnivalPeriod ~= lastPeriod then
		self.currentTaskId = self.taskList[1]  -- 默认选中第一个任务
	end
	CarnivalModel:setLastPeriod(self.carnivalPeriod)
	-- 全目标奖励总数量
	self.totalTargetRewardNum = FuncCarnival.getCarnivalWholeTargetRewardMaxCountById(CarnivalModel:getCurrentCarnivalId())
end

function CarnivalMainView:initView()
	self.themeScrollView = self.scroll_1
	self.taskScrollView = self.scroll_2

	self.mc_1:setVisible(false)
	self.panel_ka:setVisible(false)


	self:initThemeScrollCfg()
	self:initTaskScrollCfg()
end


--------------------------------------------------------------------------
---------------------- 主题滚动条 任务滚动条 -----------------------------
-------------------------------------------------------------------------- 
function CarnivalMainView:initThemeScrollCfg()
	-- 注意itemdata 为一个item的data，此处为id
	local createThemeFunc = function(themeId)
		local itemView = UIBaseDef:cloneOneView( self.mc_1 )
		self:updateThemeItem( themeId,itemView )
		return itemView
	end
	local refreshTeamFunc = function(themeId,itemView)
		self:updateThemeItem( themeId,itemView )
		return itemView
	end

    self.themeListParams = {
        data = nil,
        createFunc = createThemeFunc,
        updateCellFunc = refreshTeamFunc,
        perNums= 1,
        offsetX = 0,
        offsetY = 8,
        widthGap = 0,
        heightGap = 0,
        itemRect = {x=0, y=-60, width = 272,height = 60}, 
        perFrame = 1
    }
    self.themeScrollView:hideDragBar()
end

function CarnivalMainView:initTaskScrollCfg()
    local createTaskFunc = function(taskId)
		local itemView = UIBaseDef:cloneOneView( self.panel_ka )
		self:updateTaskItem( taskId,itemView )
		return itemView
	end
    local refreshTaskFunc = function(taskId,itemView)
		self:updateTaskItem( taskId,itemView )
		return itemView
	end
    self.taskListParams = {
        data = nil,
        createFunc = createTaskFunc,
        updateCellFunc = refreshTaskFunc,
        perNums= 1,
        offsetX = 70,
        offsetY = 0,
        widthGap = 0,
        heightGap = 10,
        itemRect = {x=70,y=-143,width = 796,height = 150}, 
        perFrame = 1
    }
end

function CarnivalMainView:updateThemeItem( themeId,itemView )
	local choose = nil
	if tostring(themeId) == tostring(self.currentThemeId) then
		itemView:showFrame(2)
		choose = 2
		itemView.currentView.panel_hongdian:setVisible(false)

		if tostring(themeId) == tostring(self.newOpenThemeId) then
			-- 检查新主题开启并播放特效
			local isPlayed = CarnivalModel:getEffectPlayed(self.newOpenThemeId)
			if isPlayed then
				echo("------ 特效播放过了 ----------- ")
			else
				echo("------ ！！！特效播还没有放过  ---- ")
				local flyAnimation1 = self:createUIArmature("UI_jianianhua","UI_jianianhua_jiesuo", itemView.currentView.ctn_1, false)
				CarnivalModel:setEffectPlayed(self.newOpenThemeId)
			end
		end
		itemView:getPosition()
	else
		itemView:showFrame(1)
	end

	local name = FuncCarnival.getCarnivalNameByThemeId(self.carnivalPeriod,themeId)
	name = GameConfig.getLanguage(name)
	itemView.currentView.panel_1.txt_1:setString(name)

	-- 主题不可展示则灰态处理，显示锁
	-- 只可展示不可做任务则显示锁
	-- 否则不显示锁
	local canShow = CarnivalModel:isThemeCanShow( themeId )
	local canDo = CarnivalModel:isThemeCanDoTask( themeId )
	if not canShow then
		FilterTools.setGrayFilter(itemView)
		itemView.currentView.panel_hongdian:setVisible(false)
	elseif not canDo then
		itemView.currentView.panel_suo:setVisible(true)
		itemView.currentView.panel_hongdian:setVisible(false)
	else
		itemView.currentView.panel_suo:setVisible(false)
		-- 红点事件
		-- if choose ~= 2 then
			local isshow = CarnivalModel:isShowThemeRedPoint(themeId)
			itemView.currentView.panel_hongdian:setVisible(isshow)
		-- end
	end
	itemView.currentView.panel_1:setTouchedFunc(c_func(self.onTouchTheme, self,themeId))
end

function CarnivalMainView:updateTaskItem( taskId,itemView )
	-- 任务描述
	local taskDescription = FuncCarnival.getTaskDescriptionById(taskId)
	taskDescription = GameConfig.getLanguage(taskDescription)
	itemView.txt_1:setString(taskDescription)

	-- 展示奖品 点击可显示tips 最多可显示4个奖励
	local rewardString = FuncCarnival.getTaskRewardById(taskId)
	-- dump(rewardString,"\n\n\n\n\n rewardString-------")
	--因为新版本增加了可选逻辑  需要先拿第一个奖励数据判断为哪一种类型 再分类显示   type = 100为可选
	local firstReward = string.split(rewardString[1], ",")
	--初始化为空字符 是因为注册点击事件时会将点击事件追加到参数最后  不能传nil进去
	local optionId = ""
	if firstReward and tostring(firstReward[1]) == FuncDataResource.RES_TYPE.OPTION then
		itemView.mc_hyj:showFrame(2)
		local panel_items = itemView.mc_hyj.currentView
		optionId = firstReward[2]
        local optionRewards = FuncItem.getOptionInfoById(optionId)
        for i = 1, 4 do
            local index = i
            local itemData = optionRewards[index]
            if itemData then
                panel_items["UI_"..index]:setVisible(true)
                if index > 1 then
                    panel_items["txt_"..(index - 1)]:setVisible(true)
                end
                panel_items["UI_"..index]:setResItemData({reward = itemData})
                panel_items["UI_"..index]:showResItemName(false)

                --注册点击事件 弹框
                local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
                FuncCommUI.regesitShowResView(panel_items["UI_"..index], resType, needNum, resId,itemData,true,true)
            else
                panel_items["UI_"..index]:setVisible(false)
                if index > 1 then
                    panel_items["txt_"..(index - 1)]:setVisible(false)
                end
            end
        end
	else
		itemView.mc_hyj:showFrame(1)
		local panel_items = itemView.mc_hyj.currentView
		local numOfReward = 4
		-- itemView["UI_1"]:setVisible(false)
		-- local rewardView = UIBaseDef:cloneOneView(itemView["UI_1"])
		if #rewardString < 4 then
			for i = #rewardString + 1,4 do
				panel_items["UI_"..i]:setVisible(false)
			end
			numOfReward = #rewardString
		end
		for i = 1,numOfReward do
			local str1 = rewardString[i]
			local params = {
				reward = str1,
			}
			panel_items["UI_"..i]:visible(true)
			panel_items["UI_"..i]:setResItemData(params)
			panel_items["UI_"..i]:setTouchEnabled(true)
			panel_items["UI_"..i]:showResItemNum(true)  -- 隐藏数量

	    	local resNum,_,_ ,resType,resId = UserModel:getResInfo( str1 )
	    	FuncCommUI.regesitShowResView(panel_items["UI_"..i],resType,resNum,resId,str1,true,true)
		end
	end
	
	

	-- 任务状态及点击事件
	local sysName = FuncCarnival.getJumpSysName( taskId )
	local conditionId = FuncCarnival.getTaskConditionIdById(taskId)
	local ownNum,needNum = CarnivalTaskConditionModel:getTaskConditionProgress(self.currentThemeId, taskId)
	if ownNum > needNum then
		ownNum = needNum
	end
	local taskStatus = CarnivalModel:getTaskStatusByTaskId(self.currentThemeId,taskId)

	itemView.mc_1:showFrame( taskStatus )
	itemView.txt_zhi:setVisible(true)
	if ownNum > 10000 then
		ownNum = FuncCommon.getStringByNumberAndDigit(ownNum, 10000, 1)
		ownNum = ownNum.."万"
	end

	if needNum > 10000 then
		needNum = FuncCommon.getStringByNumberAndDigit(needNum, 10000, 1)
		needNum = needNum.."万"
	end
	if taskStatus == CarnivalModel.taskStatus.TODO then
		if (conditionId == 600) or (conditionId == 601) or (conditionId == 703) then
			itemView.txt_zhi:setString("0/1")
		else
			itemView.txt_zhi:setString(ownNum.."/"..needNum)
		end
		itemView.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.onTouchTask, self, taskId, taskStatus, self.currentThemeId))
	elseif taskStatus == CarnivalModel.taskStatus.CAN_GET_REWARD then
		if (conditionId == 600) or (conditionId == 601) or (conditionId == 703) then
			itemView.txt_zhi:setString("1/1")
		else
			itemView.txt_zhi:setString(ownNum.."/"..needNum)
		end
		itemView.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.onTouchTask, self, taskId, taskStatus, self.currentThemeId, optionId))
	elseif taskStatus == CarnivalModel.taskStatus.HAVE_GOT_REWARD then
		itemView.txt_zhi:setVisible(false)
	end

	local canDo = CarnivalModel:isThemeCanDoTask( self.currentThemeId ) 
	local canShow =  CarnivalModel:isThemeCanShow( self.currentThemeId ) 
	if canShow and (not canDo) then
		-- FilterTools.setGrayFilter(itemView.mc_1)
		itemView.mc_1:showFrame( 4 )
		itemView.txt_zhi:setVisible(false)
	end
end


-- 动态生成item滚动区配置参数
function CarnivalMainView:buildThemeScrollParams()
    local ListParams = {}
    local copyItemParams = nil

    for k,v in ipairs(self.themeIdList) do
        copyItemParams = table.deepCopy(self.themeListParams)
        copyItemParams.data = {v}
        ListParams[ #ListParams + 1 ] = copyItemParams
    end
    return ListParams
end

-- 动态生成item滚动区配置参数
function CarnivalMainView:buildTaskScrollParams()
    local ListParams = {}
    local copyItemParams = nil

    for k,v in ipairs(self.taskList) do
        copyItemParams = table.deepCopy(self.taskListParams)
        copyItemParams.data = {v}
        ListParams[ #ListParams + 1 ] = copyItemParams
    end
    return ListParams
end

-- 根据任务列表获取考虑完成沉底排序后的任务列表
function CarnivalMainView:getTaskListAfterSorted(activityId)
	local taskList = FuncCarnival.getActivityTaskListByActivityId(activityId)
    local toDoTaskes = {}
    local haveDoneTaskes = {}
    local targetList = {}
    self.mapTaskIdToOrder = {}
    for k,v in ipairs(taskList) do
    	local taskStatus = CarnivalModel:getTaskStatusByTaskId(self.currentThemeId,v)
    	if taskStatus == CarnivalModel.taskStatus.CAN_GET_REWARD then
    		targetList[ #targetList + 1 ] = v
    		-- table.insert(self.mapTaskIdToOrder, tostring(v))
    		self.mapTaskIdToOrder[tostring(v)] = #targetList 
    	elseif taskStatus == CarnivalModel.taskStatus.TODO then
    		toDoTaskes[#toDoTaskes + 1] = v 
    	elseif taskStatus == CarnivalModel.taskStatus.HAVE_GOT_REWARD then
    		haveDoneTaskes[#haveDoneTaskes + 1] = v
	    end
    end

    if next(toDoTaskes) ~= {} then
    	for k,v in ipairs(toDoTaskes) do
			targetList[ #targetList + 1 ] = v
			-- table.insert(self.mapTaskIdToOrder, tostring(v))
			self.mapTaskIdToOrder[tostring(v)] = #targetList 
    	end
    end
    if next(haveDoneTaskes) ~= {} then
    	for k,v in ipairs(haveDoneTaskes) do
			targetList[ #targetList + 1 ] = v
			-- table.insert(self.mapTaskIdToOrder, tostring(v))
			self.mapTaskIdToOrder[tostring(v)] = #targetList 
    	end
    end
    return targetList
end

--------------------------------------------------------------------------
-- 点击主题 活动 任务的响应函数
-- 更新数据  -- 更新ui
--------------------------------------------------------------------------
function CarnivalMainView:onTouchTheme(themeId)
	-- echo("\n\n\n\n -- 主题点击--self.currentThemeId，themeId,--------",self.currentThemeId,themeId)
	-- self.themeScrollView:gotoTargetPos(tonumber(themeId), 1, 1, 0.2)
	local canShow = CarnivalModel:isThemeCanShow( themeId )
	local canDo = CarnivalModel:isThemeCanDoTask( themeId )

	if not canDo and not canShow then
	 	local timeStart = FuncCarnival.getOpenDayByThemeId( themeId )
		local str = TimeControler:turnTimeSec( timeStart, TimeControler.timeType_dhhmmss );
		local int_day = math.floor(timeStart/(60*60*24))
		if int_day>0 then
		    local dayAndTime = string.split(str,"天")
		    local day = dayAndTime[1] + 1
		    str = "第 "..day.." 天开启"
		else
			str = "第 1 天开启"
		   end
		WindowControler:showTips( { text = str })
		return
	end

	if tostring(themeId) ~= tostring(self.currentThemeId) then
		local lastThemeId = self.currentThemeId
		self.currentThemeId = themeId

		self.activityList = FuncCarnival.getActivitiesByThemeId( self.currentThemeId ) 
		self.currentActivityId = self.activityList[1]  -- 默认选中第一个活动

		self.taskList = self:getTaskListAfterSorted(self.currentActivityId)
		self.currentTaskId = self.taskList[1]

		-- self:updateThemeUI()
		self:updateActivityUI()
		self:updateTaskUI()

		local lastView = self.themeScrollView:getViewByData(lastThemeId)
		local currentView = self.themeScrollView:getViewByData(self.currentThemeId)
		if lastView then
			self:updateThemeItem(lastThemeId, lastView)
		end

		if currentView then
			self:updateThemeItem(self.currentThemeId, currentView)
		end	
	end
end

function CarnivalMainView:onTouchActivity(activityId)
	if tostring(activityId) ~= tostring(self.currentActivityId) then
		self.currentActivityId = activityId
		
		self.taskList = self:getTaskListAfterSorted(self.currentActivityId)
		self.currentTaskId = self.taskList[1]

		self:updateActivityUI()
		self:updateTaskUI()
	end
end
function CarnivalMainView:onTouchTask(taskId, taskStatus, curThemeId, optionId)
	if tostring(taskId) ~= tostring(self.currentTaskId) then
		self.currentTaskId = taskId 
	end

	if not CarnivalModel:isThemeCanDoTask(self.currentThemeId) then
		WindowControler:showTips(GameConfig.getLanguage("#tid_jianianhua_001"));
		return
	end

	if taskStatus == CarnivalModel.taskStatus.TODO then
		CarnivalModel:jumpToTaskLinkView(taskId, curThemeId)
	elseif taskStatus == CarnivalModel.taskStatus.CAN_GET_REWARD then
		if optionId and optionId ~= "" then
			local params = {
                optionId = optionId,
                isCarnival = true,
                taskId = taskId,
            }
            WindowControler:showWindow("ItemOptionView", nil, nil, params)
		else
			CarnivalModel:getTaskReward(self.currentThemeId,taskId)
		end		
	end
end

function CarnivalMainView:initViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
end



--------------------------------------------------------------------------
-------------------------- 更新UI函数    ---------------------------------
--------------------------------------------------------------------------
-- 根据数据变化 更新所有UI
function CarnivalMainView:updateUI()
	self:updateThemeUI()
	self:updateActivityUI()
	self:updateTaskUI()
	self:updateProgressBar()
	self:updateTargetRewardIcon()
end

-- 更新主题界面
function CarnivalMainView:updateThemeUI()
	local themeParams = self:buildThemeScrollParams()
	self.themeScrollView:cancleCacheView()	
	self.themeScrollView:styleFill(themeParams)
	self.themeScrollView:refreshCellView( 1 )
	local num = string.sub(self.currentThemeId, string.len(self.currentThemeId)-1, string.len(self.currentThemeId))
	-- self.themeScrollView:gotoTargetPos(num, 1, 1, 0)
	self.mc_titile:showFrame(self.carnivalPeriod)
	self.mc_bg:showFrame(self.carnivalPeriod)
	
	if not self.targetAnim or self.isNewPeriod then
		self.panel_dian.btn_1:getUpPanel().mc_qmb:showFrame(self.carnivalPeriod)
		self.panel_dian.btn_1:getUpPanel().mc_qmb:setVisible(false)
		self.panel_dian.btn_1:getUpPanel().mc_qmb.currentView:pos(-150, 70)
		self.panel_dian.btn_1:getUpPanel().ctn_anim:removeAllChildren()
		self.targetAnim = self:createUIArmature("UI_jianianhua", "UI_jianianhua_mubiaojiangli", self.panel_dian.btn_1:getUpPanel().ctn_anim, true)
		FuncArmature.changeBoneDisplay(self.targetAnim, "node", self.panel_dian.btn_1:getUpPanel().mc_qmb.currentView)

		local changedNode = UIBaseDef:cloneOneView(self.panel_dian.btn_1:getUpPanel().mc_qmb)
		changedNode:showFrame(self.carnivalPeriod)
		changedNode.currentView:pos(-150, 70)
		FuncArmature.changeBoneDisplay(self.targetAnim, "node3", changedNode.currentView)

		local changedNode1 = UIBaseDef:cloneOneView(self.panel_dian.btn_1:getUpPanel().mc_qmb)
		changedNode1:showFrame(self.carnivalPeriod)
		changedNode1.currentView:pos(-150, 70)
		FuncArmature.changeBoneDisplay(self.targetAnim:getBoneDisplay("saoguang"), "node2", changedNode1.currentView)

		local changedNode2 = UIBaseDef:cloneOneView(self.panel_dian.btn_1:getUpPanel().mc_qmb)
		changedNode2:showFrame(self.carnivalPeriod)
		changedNode2.currentView:pos(-150, 70)
		FuncArmature.changeBoneDisplay(self.targetAnim, "node4", changedNode2.currentView)
	end
end

-- 更新活动界面
function CarnivalMainView:updateActivityUI()
	-- 根据活动数展示相应帧
	local numOfActivity = #self.activityList
	self.mc_ka:showFrame( numOfActivity )
	local currentView = self.mc_ka.currentView

	-- 展示所有否活动标题 
	-- 选中效果、点击的响应事件
	for k,activityId in ipairs(self.activityList) do 
		local mcActivity = currentView["mc_"..k]
		if self.currentActivityId == activityId then
			mcActivity:showFrame(2) -- 选中
		else
			mcActivity:showFrame(1)			
		end
		local isShow = CarnivalModel:isShowActivityRedPoint(self.currentThemeId,activityId)
		mcActivity.currentView.panel_hongdian:setVisible(isShow)

		local activityName = FuncCarnival.getActivityNameByActivityId( activityId )
		activityName = GameConfig.getLanguage( activityName )
		-- mcActivity.currentView.btn_1:getUpPanel().txt_1:setString( activityName ) 
		mcActivity.currentView.btn_1:setBtnStr(activityName,"txt_1")
		mcActivity.currentView.btn_1:setTap(c_func(self.onTouchActivity, self, activityId)) 
	end
end

-- 更新任务界面
function CarnivalMainView:updateTaskUI()
	local taskParams = self:buildTaskScrollParams()
	-- self.taskScrollView:cancleCacheView()
	self.taskScrollView:styleFill(taskParams)
	self.taskScrollView:refreshCellView(1)
	local num = self.mapTaskIdToOrder[tostring(self.currentTaskId)]
	self.taskScrollView:gotoTargetPos(num, 1, 1, 0)
end

-- 更新全目标奖励进度条
function CarnivalMainView:updateProgressBar()
	local ownNum = CarnivalModel:getWholeTargetNum(CarnivalModel:getCurrentCarnivalId())
	echo("获得全目标奖励数量 ======== ",ownNum)
    local txt = self.panel_dian.panel_lvtiao.txt_1
    local str = ownNum.."/"..self.totalTargetRewardNum
    txt:setString(str)

    local preogress = self.panel_dian.panel_lvtiao.progress_1
    local percent = ownNum / self.totalTargetRewardNum * 100
    preogress:setDirection(ProgressBar.l_r)
    preogress:setPercent(percent)
end


-- 更新倒计时界面
function CarnivalMainView:downTime()
	if self.leftTime < 0 then
        return
    end
    if self.frameCount % GameVars.GAMEFRAMERATE == 0 then 
    	self.leftTime = CarnivalModel:getCarnivalLeftTime(CarnivalModel:getCurrentCarnivalId())
	    local str = TimeControler:turnTimeSec( self.leftTime, TimeControler.timeType_dhhmmss );
	    local int_day = math.floor(self.leftTime/(60*60*24))
		if int_day>0 then
		    local dayAndTime = string.split(str,"天")
		    self.mc_number:showFrame(dayAndTime[1] + 1)
	    	self.txt_x2:setString(dayAndTime[2]) 
		else
			self.mc_number:showFrame(1)
	    	self.txt_x2:setString(str) 
	    end       
    end 
    self.frameCount = self.frameCount + 1
end

-- 显示全目标奖励icon
function CarnivalMainView:updateTargetRewardIcon()
	local panel11 = self.panel_dian.btn_1:getUpPanel()
	if CarnivalModel:isShowWholeTargetRedPoint() then
		panel11.panel_hongdian:setVisible(true)
	else
		panel11.panel_hongdian:setVisible(false)
	end

	-- local rewareId = FuncCarnival.getCarnivalWholeTargetRewardIdById(CarnivalModel:getCurrentCarnivalId())
	-- local icon = FuncItem.getIconPathById( rewareId )
	-- echoError("rewareId=====", rewareId)
	-- local icon = FuncRes.iconItem( rewareId )

 --    local iconSprite = display.newSprite(icon)
	-- iconSprite:setScale(0.9)
	-- iconSprite:pos(25,0)
	-- self.panel_dian.btn_1:getUpPanel().ctn_1:removeAllChildren()
	-- self.panel_dian.btn_1:getUpPanel().ctn_1:addChild(iconSprite)
end


--------------------------------------------------------------------------
---------------------- 打开全目标奖励    ---------------------------------
--------------------------------------------------------------------------
function CarnivalMainView:openWholeTargetRewardView()
	WindowControler:showTopWindow("CarnivalWholeTargetRewardView")
end

function CarnivalMainView:deleteMe()
	CarnivalMainView.super.deleteMe(self);
end

function CarnivalMainView:onClose()
	self:startHide()
end
return CarnivalMainView;
