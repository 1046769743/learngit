-- Author: ZhangYanguang
-- Date: 2017-04-19
-- 六界旧的回忆主界面

local WorldPVEListView = class("WorldPVEListView", UIBase);

function WorldPVEListView:ctor(winName,fromGetWay,raidId,targetResId,targetResNum)
    WorldPVEListView.super.ctor(self, winName);

    echo("WorldPVEListView raidId====",raidId, "targetResId===", targetResId, "targetResNum===", targetResNum)
    if raidId then
    	self.showSelectAnim = true
    	self.targetRaidId = raidId

    	if targetResId and targetResNum then
    		-- 资源需求Id和数量
    		self.targetData = {
	    		targetId = targetResId,
	    		needNum = targetResNum
	    	}
    	end
    end

    self.fromGetWay = fromGetWay
    self.isInit = true

    self.isEasySweep = self:checkIsEasySweep()

    echo("self.isEasySweep======",self.isEasySweep)
end

function WorldPVEListView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()

	self:initDefaultStoryId()
	self:switchStory(self.defaultStoryId)
end 

function WorldPVEListView:initDefaultStoryId( )
	self.defaultStoryId = self.storyList[#self.storyList]
	if self.targetStoryId then
		self.defaultStoryId = self.targetStoryId
	elseif self.fromGetWay then
		-- 下一关
		local nextRaidId = WorldModel:getNextMainRaidId()
		-- 下一关被锁定
		if WorldModel:isRaidLock(nextRaidId) then
			if #self.storyList > 1 then
				self.defaultStoryId = self.storyList[#self.storyList-1]
			end
		end
	end
end

function WorldPVEListView:onBattleExitResume(cacheData )
    WorldPVEListView.super.onBattleExitResume(cacheData)
    -- 如果创建时有目标关卡(进战斗前打开该界面时带有目标关卡)
	if self.targetRaidId then
		return
	end

    if cacheData and cacheData.raidId then
    	self.targetRaidId = cacheData.raidId
    	self:initTargetData()
    	self:switchStory(self.targetStoryId)

    	if UserModel:isLvlUp() then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
        end 
	end
end

function WorldPVEListView:getEnterBattleCacheData()
	local raidId = self.targetRaidId or self.curRaidId
    return  {raidId = raidId}
end

function WorldPVEListView:initData()
	self:initTargetData()

	self.maxRewardNum = 4
	self.spCost = 6
	WorldPVEListView.spCost = self.spCost

	-- 多于5章，使用滚动条
	self.maxStoryTagNum = 5

	-- self.storyList = WorldModel:getPassStoryList(FuncChapter.stageType.TYPE_STAGE_MAIN)
	self.storyList = self:getPVEStoryList()
	-- 下一章第一关
	-- local nextLockRaidId = WorldModel:getNextMainRaidId()
	-- self.nextLockRaidId = nextLockRaidId
	-- self.nextStoryRaidList = {}
	-- self.nextStoryId = nil
	-- if WorldModel:isRaidLock(nextLockRaidId) then
	-- 	self.nextStoryRaidList[1] = nextLockRaidId
	-- 	self.nextStoryId = FuncChapter.getStoryIdByRaidId(nextLockRaidId)
	-- 	self.storyList[#self.storyList+1] = self.nextStoryId
	-- end
end

-- 初始化目标跳转相关数据
function WorldPVEListView:initTargetData()
	if self.targetRaidId then
		self.targetStoryId = tostring(FuncChapter.getStoryIdByRaidId(self.targetRaidId))
		local raidData =  FuncChapter.getRaidDataByRaidId(self.targetRaidId)
		self.targetRaidIndex = raidData.section
	end
end

function WorldPVEListView:onClickSwitchStory(storyId)
	-- 点击后取消目标storyID
	self.targetStoryId = nil
	self:switchStory(storyId)
end

function WorldPVEListView:switchStory(storyId)
	if storyId == nil then
		echoError("WorldPVEListView:switchStory storyId===",storyId)
		return
	end
	
	self.curStoryId = storyId
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_SWTCH_STORY)

	self.storyData = FuncChapter.getStoryDataByStoryId(self.curStoryId)

	-- 如果是下一章(还未解锁)
	--[[
	if self.curStoryId == self.nextStoryId then
		self.raidDataList = self.nextStoryRaidList
	else
		self.raidDataList = WorldModel:getPassRaidList(self.curStoryId)
	end
	]]

	-- 更新关卡列表数据
	local raidDataList,hasNextUnlockRaid = self:getRaidList(self.curStoryId)
	self.raidDataList = raidDataList
	-- 如果没有指定目标关卡，且当前章显示的最后一关是解锁的
	if not self.targetRaidId and hasNextUnlockRaid then
		self.targetRaidId = self.raidDataList[#self.raidDataList]
		self:initTargetData()
	end

	self:updateUI()
end

--[[
	获取章列表
	已通关的章+下一章(第一关被锁定的章)
]]
function WorldPVEListView:getPVEStoryList()
	local storyList = WorldModel:getPassStoryList(FuncChapter.stageType.TYPE_STAGE_MAIN)
	-- 下一关
	local nextLockRaidId = WorldModel:getNextMainRaidId()

	local nextStoryId = nil
	-- 下一关被锁定
	if WorldModel:isRaidLock(nextLockRaidId) then
		nextStoryId = FuncChapter.getStoryIdByRaidId(nextLockRaidId)
	else
		local storyId = FuncChapter.getStoryIdByRaidId(nextLockRaidId)
		if storyId and tostring(storyId) ~= tostring(storyList[#storyList]) then
			nextStoryId = storyId
		end
	end

	if nextStoryId then
		storyList[#storyList+1] = nextStoryId
	end

	return storyList
end

--[[
	获取storId对应的关卡列表(本章已通关的+本章下一关解锁的)
]]
function WorldPVEListView:getRaidList(storyId)
	local raidDataList = {}
	raidDataList = WorldModel:getPassRaidList(storyId)

	local hasNextUnlockRaid = false

	local nextRaidId = nil
	if raidDataList == nil or #raidDataList == 0 then
		nextRaidId = FuncChapter.getRaidIdByStoryId(storyId,1)
		raidDataList = {}
		raidDataList[1] = nextRaidId
	else
		-- 获取本章内下一个解锁的关卡
		local raidId = raidDataList[#raidDataList]
		nextRaidId = WorldModel:getNextRaidInStory(raidId)
		if nextRaidId and nextRaidId ~= raidId then
			raidDataList[#raidDataList+1] = nextRaidId

			hasNextUnlockRaid = true
		end
	end

	return raidDataList,hasNextUnlockRaid
end

function WorldPVEListView:initView()
	self:initViewAlign()

	self.scrollList = self.panel_zhujian.scroll_1
	self.scrollStoryList = self.scroll_2

	self:initScrollCfg()
end

function WorldPVEListView:registerEvent()
	self.btn_zhenrong:setTap(c_func(self.onClickEmbattle,self))
	self.btn_back:setTap(c_func(self.onClickBack,self))

	-- 体力变化
	EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.onSpChange, self)
	-- 道具变化(扫荡触发升级时，体力变化时道具还未变更)
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.onSpChange, self)
	-- 战斗结束
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)
	-- 星级宝箱更新
    EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, self.updateStarBoxes, self)
    -- 阵容变化
    EventControler:addEventListener(TeamFormationEvent.TEAMFORMATIONEVENT_CHANGE_TEAMFORMATION,self.updateFormationBtn,self)
    -- 日常任务变化
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,self.onDailyQuestChange,self)
end

-- UI适配
function WorldPVEListView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ziyuan,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_hulu,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jdt,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_buzu,UIAlignTypes.MiddleBottom)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.scroll_2,UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_zhenrong,UIAlignTypes.RightBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_buzu,UIAlignTypes.MiddleBottom)
end

function WorldPVEListView:initScrollCfg()
	-- 章信息及节列表滚动条
	local itemStoryInfo = self.panel_zhujian.panel_bao
	itemStoryInfo:setVisible(false)

	local createStoryInfoFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(itemStoryInfo)
		self:setStoryInfoView(itemView,itemData)
		return itemView
	end


	local itemView = self.panel_zhujian.panel_saodang
	itemView:setVisible(false)
	local createRaidItemFunc = function(itemData)
		local raidItemView = UIBaseDef:cloneOneView(itemView)
		self:setRaidItemView(raidItemView,itemData)
		return raidItemView
	end

	-- 跳转panel
	local getWayPanel = self.panel_zhujian.panel_1
	getWayPanel:setVisible(false)

	local createGetWayItemFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(getWayPanel)

		local goEliteMainView = function()
			 if WorldModel:isOpenElite() then
                EliteMainModel:enterEliteExploreScene()
                -- WindowControler:showWindow("EliteMainView")
            else
                WindowControler:showTips(GameConfig.getLanguage("#tid_worldAerial_002"))
            end
		end

		local goQuestMainView = function()
			local isOpen,value,type,tip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST)
			if isOpen then
				WindowControler:showWindow("QuestMainView",FuncQuest.QUEST_TYPE.EVERYDAY)
			else
				WindowControler:showTips(tip)
			end
		end

		itemView.panel_1.btn_1:setTap(c_func(goEliteMainView))
		itemView.panel_1:setTouchedFunc(c_func(goEliteMainView))

		itemView.panel_2.btn_2:setTap(c_func(goQuestMainView))
		itemView.panel_2:setTouchedFunc(c_func(goQuestMainView))
			
		local dataList = DailyQuestModel:getAllShowDailyQuestId()
		if dataList and #dataList == 0 then
			itemView.panel_2:setVisible(false)
		end

		return itemView
	end

	local sweepTipPanel = self.panel_zhujian.panel_sdtips
	sweepTipPanel:setVisible(false)

	local createSweepTipFunc = function(itemData)
		local itemView = UIBaseDef:cloneOneView(sweepTipPanel)
		local raidBouns = FuncDataSetting.getDataByHid("RaidBouns")
		local bonus = raidBouns.arr
		for i=1,3 do
			itemView["panel_shuang"..i]:visible(false)
		end
		
		-- 奖品固定的，必须是3个
		local rewardNum = 3
		for i=1,rewardNum do
	        local rewardUI = itemView["UI_"..i]
	        rewardUI:setVisible(true)
	        if ActTaskModel:doubleIsOpen() then
        		itemView["panel_shuang"..i]:visible(true)
        	end

	        local rewardStr = "1," .. bonus[i] .. ",1"
	        local params = {
	            reward = rewardStr,
	        }

	        rewardUI:setResItemData(params)
	        rewardUI:showResItemNum(false)
	        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
	        FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr)
	    end

		return itemView
	end

	self.listParams = 
	{	
		{
            data = {},
            createFunc = createStoryInfoFunc,
            itemRect = { x = 0, y = -111, width = 834, height = 111 },
            perNums = 1,
            offsetX = 10,
	        offsetY = 5,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
        },

        {
            data = {""},
            createFunc = createSweepTipFunc,
            itemRect = { x = 0, y = 0, width = 477, height = 58 },
            perNums = 1,
            offsetX = 191,
	        offsetY = 5,
	        widthGap = 0,
	        heightGap = 0,
	        perFrame = 1,
        },

        {
            data = {},
            createFunc = createRaidItemFunc,
            itemRect = { x = 0, y = -148, width = 836, height = 140 },
            perNums = 1,
            offsetX = 10,
	        offsetY = 2,
	        widthGap = 0,
	        heightGap = -7,
	        perFrame = 1,
        },

        -- 获取途径
        {
            data = {},
            createFunc = createGetWayItemFunc,
            itemRect = { x = 0, y = -148, width = 836, height = 140 },
            perNums = 1,
            offsetX = 10,
	        offsetY = -6,
	        widthGap = 0,
	        heightGap = 5,
	        perFrame = 1,
        }
    }

    -- 章列表滚动条
    self.mc_yeqian:setVisible(false)
    local storyItemView = self.mc_yeqian.currentView.mc_1

    local createStoryItemFunc = function(itemData) 
    	local itemView = UIBaseDef:cloneOneView(storyItemView)
		self:setStoryItemView(itemView,itemData)
		return itemView
	end

    self.storyListParams = 
	{
		{
            data = {},
            createFunc = createStoryItemFunc,
            itemRect = { x = 0, y = -73, width = 77, height = 73 },
            perNums = 1,
            offsetX = 0,
	        offsetY = 0,
	        widthGap = 0,
	        heightGap = 10,
	        perFrame = 1,
        }
    }

    -- 注意，如果分组有修改，记得修改关卡列表在滚动条中的groupIndex
    self.raidListGoupIndex = 3
end

function WorldPVEListView:onBattleClose()
	if WorldModel:isPVEBattleWin() then
		self.onRaidChange = true
	else
		self.onRaidChange = false
	end

	if self.onRaidChange then
		self:updateStarBoxes()
	end

	self:updateFormationBtn()

	self:checkOpenShopByDelayTime(1.7)
end

-- 检查临时商店是否开启
function WorldPVEListView:checkOpenShopByDelayTime(delayTime)
    local openShop = function()
    	local openShopType = WorldModel:getOpenShopType()
	    if openShopType ~= nil and table.length(openShopType) > 0 then
	    	WorldModel:resetDataBeforeBattle()
	        WindowControler:showWindow("ShopKaiqi", openShopType)
	    end
	end

	if delayTime == nil or delayTime == 0 then
		openShop()
	else
		self:delayCall(c_func(openShop), delayTime)
	end
end

--[[
	日常任务发生变化
]]
function WorldPVEListView:onDailyQuestChange()
	if self.hasShowGetWayView then
		self:updateUI()
	end
end

function WorldPVEListView:updateUI()
	local panelInfo = self.panel_zhujian
	-- 章名称
	local storyName = self.storyData["name"]
	storyName = GameConfig.getLanguage(storyName)
	panelInfo.txt_1:setString(storyName)

	self:updateRaidList()
	-- self:updateSpCost()
	self:updateStarBoxes()
	self:updateFormationBtn()

	self:updateStoryList()
end

-- 更新布阵按钮状态
function WorldPVEListView:updateFormationBtn()
	local isOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
	if isOpen then
		self.btn_zhenrong:setVisible(true)
		self:updateFormationRedPoint()
	else
		self.btn_zhenrong:setVisible(false)
	end
end

-- 更新布阵按钮红点状态
function WorldPVEListView:updateFormationRedPoint()
	local isShow = false--TeamFormationModel:hasIdlePosition()
	self.btn_zhenrong:getUpPanel().panel_red:setVisible(isShow)
end

function WorldPVEListView:updateRaidList()
	self.listParams[1].data = {self.curStoryId}
	self.listParams[3].data = self.raidDataList

	-- 如果关卡ID是锁定的，显示获取途径
	self.hasShowGetWayView = false
	local lastRaidId = self.raidDataList[#self.raidDataList]
	self.listParams[4].data = {}
	if WorldModel:isRaidLock(lastRaidId) then
		self.listParams[4].data = {""}
		self.hasShowGetWayView = true
	end

	self.scrollList:cancleCacheView()
	self.scrollList:styleFill(self.listParams)

	if self.targetStoryId == self.curStoryId then
		-- echo("\n self.targetRaidIndex=====",self.targetRaidIndex)
		-- echo("targetRaidId=",self.targetRaidId)
		self.scrollList:gotoTargetPos(self.targetRaidIndex,self.raidListGoupIndex,1)
	else
		self.scrollList:gotoTargetPos(1,1,0,false)
	end
end

function WorldPVEListView:updateStoryList()
	if self.isInit then
		if #self.storyList <= self.maxStoryTagNum then
			self.mc_yeqian:setVisible(true)
			self.mc_yeqian:showFrame(#self.storyList)
			for i=1,#self.storyList do
				local mcStory = self.mc_yeqian.currentView["mc_" .. i]
				local storyId = self.storyList[i]
				self:setStoryItemView(mcStory,storyId)
			end
		else
			self.storyListParams[1].data = self.storyList
			self.scrollStoryList:cancleCacheView()
			self.scrollStoryList:styleFill(self.storyListParams)
			self.scrollStoryList:hideDragBar()
		end
	end

	self.isInit = false


	if #self.storyList > self.maxStoryTagNum then
		if self.targetStoryId then
			self:gotoTargetStory(self.targetStoryId)
		else
			self:gotoTargetStory(self.curStoryId)
		end
	end
end

function WorldPVEListView:gotoTargetStory(storyId)
	if storyId then
		local index = self:getStoryIndexNum(storyId)
		self.scrollStoryList:gotoTargetPos(index,1,1)
	end
end

function WorldPVEListView:getStoryIndexNum(storyId)
	for i=1,#self.storyList do
		if storyId == self.storyList[i] then
			return i
		end
	end
end

function WorldPVEListView:setStoryInfoView(itemView,storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	-- 剧情
	local storyDes = GameConfig.getLanguage(storyData["des"])
	itemView.txt_des:setString(storyDes)

	-- 章背景
	local bg = storyData["bg"]
	local bgSprite = display.newSprite(FuncRes.iconPVE(bg))
	itemView.ctn_bg:removeAllChildren()
	itemView.ctn_bg:addChild(bgSprite)

	itemView.btn_huigu:setTap(c_func(self.onClickRememory,self))

	-- 剧情回顾按钮
	if WorldModel:isPassStory(storyId) then
		itemView.btn_huigu:setVisible(true)
	else
		itemView.btn_huigu:setVisible(false)
	end
end

function WorldPVEListView:setStoryItemStatus(itemView,storyId)
	-- 选中状态
	if storyId == self.curStoryId then
		itemView:showFrame(2)
	else
		itemView:showFrame(1)
	end
end

function WorldPVEListView:setStoryItemView(itemView,storyId)
	itemView.updateRedStatus = function()
		-- 红点状态
		if WorldModel:hasStarBoxesByStoryId(storyId) then
			-- 当前选择的章不显示红点
			if storyId == self.curStoryId then
				itemView.currentView.panel_red:setVisible(false)
			else
				itemView.currentView.panel_red:setVisible(true)
			end
		else
	 		itemView.currentView.panel_red:setVisible(false)
		end
	end

	itemView.updateStoryItemView = function()
		self:setStoryItemStatus(itemView,storyId)
		self:setStoryName(itemView.currentView.btn_1,storyId)
		itemView:updateRedStatus()
	end

	itemView:updateStoryItemView()

	
	EventControler:addEventListener(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES, itemView.updateRedStatus, itemView)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_SWTCH_STORY, itemView.updateStoryItemView, itemView)
	itemView:setTouchedFunc(c_func(self.onClickSwitchStory,self,storyId))
end

function WorldPVEListView:setStoryName(btnStoryName,storyId)
	local storyData = FuncChapter.getStoryDataByStoryId(storyId)
	local chapter = storyData["chapter"]

	-- itemView.currentView.btn_1:setBtnStr(chapterStr)
	local mcNameUp = btnStoryName:getUpPanel().mc_1
	local mcNameDown = btnStoryName:getDownPanel().mc_1

	local chapterStr = WorldModel:getChapterNum(chapter)

	-- 20章之前用第一帧
	if chapter <= 20 then
		mcNameUp:showFrame(1)
		mcNameDown:showFrame(1)
	else
		mcNameUp:showFrame(2)
		mcNameDown:showFrame(2)
	end

	mcNameUp.currentView.txt_1:setString(chapterStr)
	mcNameDown.currentView.txt_1:setString(chapterStr)
end

function WorldPVEListView:setRaidItemView(itemView,itemData)
	local raidId = itemData
	local raidData = FuncChapter.getRaidDataByRaidId(raidId)
	local storyId  = raidData["chapter"]
	local section = raidData["section"]
	local raidName = GameConfig.getLanguage(raidData["name"])

	local condition = raidData.condition

	-- itemView.txt_1:setString(section)
	itemView.txt_2:setString(raidName)

	-- 经验
	itemView.txt_3:setString(raidData.spCost)

	-- 铜钱
	itemView.txt_4:setString(FuncCommUI.turnOneNumToStr(raidData.coin))

	-- 星级
	self:updateRaidScore(itemView.mc_hulu,raidId)

	-- 更新奖品
	self:updateReward(itemView,raidData)

	local spCost = self.spCost
	itemView.updateSpCost = function()
		-- 更新体力消耗及开启提醒
		-- 更新体力展示
		itemView.mc_2:setVisible(true)
		if WorldModel:isRaidLock(raidId) then
			itemView.mc_2:showFrame(1)
			local tip = UserModel:getConditionTip(condition)
			itemView.mc_2.currentView.txt_1:setString(tip)
		elseif WorldModel:isPassRaid(raidId) then
			local mySp = UserExtModel:sp()
		    local txtSpCost = nil
		    -- 满足
		    if mySp >= spCost then
		    	itemView.mc_2:showFrame(2)
		    else
		        -- 不足
		        itemView.mc_2:showFrame(3)
		    end
		-- 解锁未通关，显示前往
		else
			itemView.mc_2:setVisible(false)
		end
	end

	itemView:updateSpCost()

	self:setBtnVisible(itemView,true)
	
	-- 设置 战 按钮显示状态
	if WorldModel:isRaidLock(raidId) then
		self:setBtnVisible(itemView,false)
		itemView.mc_1:showFrame(2)
		FilterTools.setGrayFilter(itemView.mc_1.currentView.btn_zhan)
		itemView.btn_1:visible(false)
		itemView.mc_saodang:visible(false)
	-- 已经通关，显示战
	elseif WorldModel:isPassRaid(raidId) then
		itemView.mc_1:showFrame(1)
		itemView.btn_1:visible(true)
		itemView.mc_saodang:visible(true)
	-- 解锁未通关，显示前往
	else
		itemView.mc_1:showFrame(2)
		itemView.btn_1:visible(false)
		itemView.mc_saodang:visible(false)
	end

	-- 设置操作按钮
	self:updateBtnListener(itemView,raidId)

	if self.targetRaidId == raidId and self.showSelectAnim then
		self:createSelectAnim(itemView)
	end
end

function WorldPVEListView:setBtnVisible(itemView,visible)
	itemView.btn_1:setVisible(visible)
	itemView.mc_saodang:setVisible(visible)
end

-- 创建选中流光动画
function WorldPVEListView:createSelectAnim(itemView)
	local animCtn = itemView.ctn_te
	animCtn:removeAllChildren()
	local selectAnim = self:createUIArmature("UI_liujie","UI_liujie_jiudehuiyilg",animCtn, true, GameVars.emptyFunc)

	-- local childAnim = selectAnim:getBoneDisplay("layer3")
	-- childAnim:setVisible(false)
end

-- 更新关卡成绩
function WorldPVEListView:updateRaidScore(mcStar,raidId)
	if not mcStar then
		return
	end

	local raidScore = WorldModel:getBattleStarByRaidId(raidId)
	-- 成绩星级mc
	mcStar:setVisible(true)
    -- 一星
    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
        mcStar:showFrame(1)
    -- 二星
    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
        mcStar:showFrame(2)
    -- 三星
   	elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        mcStar:showFrame(3)
    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
    	-- 三个黑色星星
    	mcStar:setVisible(false)
    end
end

function WorldPVEListView:updateBtnListener(itemView,raidId)
	-- 是否是一键扫荡
	if self.isEasySweep and self.targetRaidId == raidId then
		itemView.mc_saodang:showFrame(2)
	else
		itemView.mc_saodang:showFrame(1)
	end
	
	-- 扫荡一次 
	local isOpen,tipMsg = WorldModel:checkSweepOneOpen()
	if not isOpen then
		FilterTools.setGrayFilter(itemView.btn_1)
	end
	-- 扫荡十次
	local isOpen2,tipMsg2 = WorldModel:checkSweepTenOpen()
	if not isOpen2 then
		FilterTools.setGrayFilter(itemView.mc_saodang)
	end

	itemView.btn_1:setTap(c_func(self.onClickSweepOne,self,raidId))

	-- 扫荡10次或一键扫荡
	local btnSweepTen = itemView.mc_saodang.currentView.btn_2
	btnSweepTen:setTap(c_func(self.onClickSweepTen,self,raidId))

	itemView.mc_1.currentView.btn_zhan:setTap(c_func(self.onClickBattle,self,raidId))

	if itemView.updateSweepText == nil then
		itemView.updateSweepText = function()
			if self.isEasySweep and self.targetRaidId == raidId then
				return
			end

			local times = 10
		    local btnTip = nil

		    -- 更新体力展示
		    local mySp = UserExtModel:sp()
		    -- 体力足够一次战斗
		    if mySp >= self.spCost then
		        local leftTimes = math.floor(mySp / self.spCost)
		        -- 不足10次
		        if leftTimes < times then
		            times = leftTimes
		        end
		    end

		    -- 扫荡10次或一键扫荡
			local btnSweepTen = itemView.mc_saodang.currentView.btn_2

		    btnTip = GameConfig.getLanguageWithSwap("#tid_story_10103",times)
		    btnSweepTen:setBtnStr(btnTip)
		end
	end

	itemView:updateSweepText()
end

function WorldPVEListView:onClickBattle(raidId)
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.SP, tonumber(self.spCost), true) then
        return
    end

    self.raidData = FuncChapter.getRaidDataByRaidId(raidId)

    if WorldModel:isRaidLock(raidId) then
    	local condition = self.raidData.condition
    	local tip = UserModel:getConditionTip(condition)
    	WindowControler:showTips(tip)
    	return
    elseif WorldModel:isPassRaid(raidId) then
    	self.curRaidId = raidId
    	self.level = self.raidData.level
    	local formation = TeamFormationModel:getFormation(FuncTeamFormation.formation.pve)
   	 	WorldServer:enterPVEStage(raidId,c_func(self.enterMainStageCallBack,self),formation)
    else
    	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_AUTO_CLICK_CUR_NPC)
    	self:startHide()
    end
end

-- 开始PVE战斗
function WorldPVEListView:enterMainStageCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId

        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleInfo.battleUsers;
        battleInfo.randomSeed = event.result.data.battleInfo.randomSeed;
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        battleInfo.levelId = self.level
        
        -- dump(battleInfo.battleUsers)

        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 保存当前战斗信息，战斗结算会用到
        local cacheBattleInfo = {}
        cacheBattleInfo.raidId = self.curRaidId
        cacheBattleInfo.battleId = self.battleId
        cacheBattleInfo.level = self.level
        -- 主角加经验(等于体力消耗)
        cacheBattleInfo.spCost = self.spCost
        -- 伙伴加经验
        cacheBattleInfo.heroAddExp = self.raidData.expPartner or 0

        WorldModel:resetDataBeforeBattle()
        WorldModel:setCurPVEBattleInfo(cacheBattleInfo)
        

         -- 初始化PVE战斗结果
        local cacheData = {
            battleRt = Fight.result_lose,
            raidId = self.curRaidId,
            -- 缓存关卡成绩
            raidScore = WorldModel:getBattleStarByRaidId(self.curRaidId)
        }
        battleInfo.battleId = self.battleId
        battleInfo.levelId = self.level
        battleInfo.raidId = self.curRaidId
        battleInfo.battleParams = event.result.data.battleInfo.battleParams

        WorldModel:setPVEBattleCache(cacheData)
        -- 开始战斗
        BattleControler:startPVE(battleInfo)

        self:startHide()
    end
end

function WorldPVEListView:onClickSweepOne(raidId)
	if self.isSweeping then
		return
	end

	-- 判断开启条件
	local isOpen,tipMsg = WorldModel:checkSweepOneOpen()
	if not isOpen then
		WindowControler:showTips(tipMsg)
		return
	end
	if not self:isSweepConditionTrue(raidId) then
		return
	end
    -- if not self:checkRaidStar(raidId) then
    --     return
    -- end

    -- 扫荡次数
    local times = 1

    local mySp = UserExtModel:sp()
    -- 体力不足
    if tonumber(mySp) < self.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self:doSweep(raidId,times,WorldModel.sweepType.SWEEP_ONE)
    end
end

--[[
	获取一键扫荡的次数
]]
function WorldPVEListView:getEasySweepTimes()
	local times = nil
	if not self:checkIsEasySweep() then
		return times
	end

	local ownNum = self:getTargetResOwnNum(self.targetData.targetId)
	local sweepNum = self.targetData.needNum - ownNum

	if ActTaskModel:doubleIsOpen() then
		times = math.round(sweepNum / 2)
	else
		times = sweepNum
	end

	return times
end

--[[
	判断是否开启一键扫荡
]]
function WorldPVEListView:checkIsEasySweep()
	-- dump(self.targetData,"self.targetData------------")
	if self.targetData and self.targetData.targetId and self.targetData.needNum then
		local ownNum = self:getTargetResOwnNum(self.targetData.targetId)
		if ownNum and ownNum < self.targetData.needNum then
			return true
		end
	end

	return false
end

--[[
	获取目标道具的数量
]]
function WorldPVEListView:getTargetResOwnNum(targetId)
	local itemId = FuncItem.getItemPropByKey(targetId,"fragmentId")
	local ownNum = nil
	if itemId then
		ownNum = ItemsModel:getItemNumById(itemId)
	else
		ownNum = ItemsModel:getItemNumById(targetId)
	end

	return ownNum
end

-- 扫荡10次(体力不足，根据体力计算实际扫荡次数)
-- isEasySweep是否是一键扫荡
function WorldPVEListView:onClickSweepTen(raidId)
	if self.isSweeping then
		return
	end

	-- 判断开启条件
	local isOpen,tipMsg = WorldModel:checkSweepTenOpen()
	if not isOpen then
		WindowControler:showTips(tipMsg)
		return
	end

	if not self:isSweepConditionTrue(raidId) then
		return
	end

	-- if not self:checkRaidStar(raidId) then
 --        return
 --    end

    -- 扫荡次数
    local times = 10
    
    -- 如果是一键扫荡
    if self.isEasySweep and self.targetRaidId == raidId  then
    	local tempTimes = self:getEasySweepTimes()
    	if tempTimes then
    		times = tempTimes
    	end
    end

    echo("self.isEasySweep==",self.isEasySweep,times)

    local mySp = UserExtModel:sp()
     -- 体力不足
    if tonumber(mySp) < self.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        local leftTimes = math.floor(mySp / self.spCost)
        if leftTimes < times then
            times = leftTimes
        end
        self:doSweep(raidId,times,WorldModel.sweepType.SWEEP_TEN)
    end
end

-- 检查扫荡条件  -- 三星关卡才能扫荡
function WorldPVEListView:isSweepConditionTrue(raidId)

    local raidScore = WorldModel:getBattleStarByRaidId(raidId)
    if raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
    	-- 先判断是否开启特权
		local privilegeData = UserModel:privileges() 
	    local additionType = FuncCommon.additionType.switch_super_sweep 
	    local curTime = TimeControler:getServerTime()
	    local fromSys = FuncCommon.additionFromType.CARD
	    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )
	    if isHas then
			return true
	    end

        local tipMsg = GameConfig.getLanguage("#tid2133")
        WindowControler:showTips(tipMsg)
        return false
    end
end

-- 扫荡
function WorldPVEListView:doSweep(raidId,times,sweepType)
    local sweepCallBack = function(serverData)
    	self.isSweeping = false
        if serverData and serverData.result ~= nil then
            local params = {
                rewardData = serverData.result.data.reward,
                targetData = self.targetData,
                ratio = serverData.result.data.ratio or 1,
                raidId = raidId,
                -- 目标关卡
                targetRaidId = self.targetRaidId,
                sweepType = sweepType,
                spCost = self.spCost
            }
            ShareBossModel:setFindRewardStatus(serverData.result.data.shareBossReward)
            WindowControler:showWindow("WorldSweepListView",params)
        end
    end

    self.isSweeping = true
    WorldServer:sweep(raidId,times,c_func(sweepCallBack))
end

-- 检查星级
function WorldPVEListView:checkRaidStar(raidId)
	local raidScore,_ = WorldModel:getBattleStarByRaidId(raidId)

    if raidScore >= WorldModel.stageScore.SCORE_ONE_STAR then
        return true
    else
    	echoError("WorldPVEListView:checkRaidStar raidScore=",raidScore)
    	return false
    end
end

function WorldPVEListView:updateReward(itemView,raidData)
	local rewardArr = raidData["bonusView"]

	local rewardNum = #rewardArr
    if rewardNum > self.maxRewardNum then
        rewardNum = self.maxRewardNum
    end

	-- 默认先隐藏全部
    for i=1,self.maxRewardNum do
        itemView["UI_"..i]:setVisible(false)
        itemView["panel_shuang"..i]:visible(false)
    end

    for i=1,rewardNum do
        local rewardUI = itemView["UI_"..i]
        rewardUI:setVisible(true)
        if ActTaskModel:doubleIsOpen() then
        	itemView["panel_shuang"..i]:visible(true)
        end

        local rewardStr = rewardArr[i]
        local params = {
            reward = rewardStr,
        }

        rewardUI:setResItemData(params)

        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr)
    end
end

function WorldPVEListView:onSpChange()
	self.isEasySweep = self:checkIsEasySweep()
	echo("self.isEasySweep=======",self.isEasySweep)

	for k,v in pairs(self.raidDataList) do
		local view = self.scrollList:getViewByData(v)
		-- 下一章的itemView，没有view.updateSweepText
		if view then
			self:updateBtnListener(view,v)
			
			if view.updateSpCost then
				view:updateSpCost()
			end
		end
	end
end

-- 更新星级宝箱
function WorldPVEListView:updateStarBoxes()
	-- 宝箱
    local boxPanel = self.panel_jdt
    self.boxPanel = boxPanel

    local storyData = self.storyData

    -- 已拥有宝箱数量
    self.ownStar = WorldModel:getTotalStarNum(self.curStoryId)

    for i=1,3 do
        -- 宝箱数量
        local needStarNum = storyData.bonusCon[i]
        local panelBox = boxPanel["panel_box"..i]
        local panelRed = boxPanel["panel_red"..i]
        if panelRed then
        	panelRed:setVisible(false)
        end

        -- 星星mc
        local mcStar = panelBox.mc_1

        -- 需要三星的总数量
        panelBox.txt_1:setString(needStarNum)
       
        -- 判断宝箱状态
        local boxIndex = i
        local boxStatus = WorldModel:getStarBoxStatus(self.curStoryId,self.ownStar,needStarNum,boxIndex)

        -- 默认点亮星星
        mcStar:showFrame(1)

        -- 不满足开宝箱条件
        if boxStatus == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
        	mcStar:showFrame(1)
            panelBox.mc_box:showFrame(1)
            self:playStarBoxAnim(panelBox,false)
        -- 满足开宝箱条件
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
        	panelBox.mc_box:showFrame(1)
        	self:playStarBoxAnim(panelBox,true)
        	if panelRed then
	        	panelRed:setVisible(true)
	        end
        elseif boxStatus == WorldModel.starBoxStatus.STATUS_USED then
            -- 显示已领取
            panelBox.mc_box:showFrame(2)
            self:playStarBoxAnim(panelBox,false)
        end
        
        panelBox:setTouchSwallowEnabled(true)
        panelBox:setTouchedFunc(c_func(self.openStarBoxes,self,boxIndex,needStarNum))
    end

     self.panel_hulu.txt_1:setString(self.ownStar .. "/" .. storyData.bonusCon[3])

    -- 设置进度条
    local preogress = boxPanel.panel_jin.progress_huang
    local percent = self.ownStar / storyData.bonusCon[3] * 100

    preogress:setDirection(ProgressBar.l_r)
    preogress:setPercent(percent)
end

-- 开宝箱
function WorldPVEListView:openStarBoxes(index,needStarNum)
    local data = {}
    data.boxIndex = index
    data.needStarNum = needStarNum
    data.storyId = self.curStoryId

    local ownStar = WorldModel:getTotalStarNum(self.curStoryId)
    data.ownStar = ownStar

    -- 宝箱状态
    local boxStatus = WorldModel:getStarBoxStatus(self.curStoryId,ownStar,needStarNum,index)
    data.boxStatus = boxStatus

    -- 如果满足领取条件，直接领取宝箱
    if boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
		local openStarBoxCallBack = function(event)
			if event.result ~= nil then
				local rewardData = event.result.data.reward
				dump(rewardData,"rewardData-------------")
        		WindowControler:showWindow("RewardSmallBgView", rewardData);
        		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES)
			end
		end
		WorldServer:openStarBox(self.curStoryId,index,c_func(openStarBoxCallBack))
    else
    	-- 如果不满足领取或已领取
    	WindowControler:showWindow("WorldStarRewardView", data)
    end
end

-- isPlay,true表示播放动画；false表示不播放动画，如果ctn已经有动画，需要做换装的反动作，并删除动画
function WorldPVEListView:playStarBoxAnim(panelBox,isPlay)
	local ctnBox = panelBox.ctn_xing1
	if isPlay then
		if ctnBox:getChildrenCount() == 0 then
			panelBox.mc_box:setVisible(false)
			local mcView = UIBaseDef:cloneOneView(panelBox.mc_box)
			local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
	    	-- anim:pos(0,0)
	    	mcView.currentView:pos(-1,5)
	    	FuncArmature.changeBoneDisplay(anim,"node",mcView)
	    	anim:startPlay(true)
		end
	else
		if ctnBox:getChildrenCount() > 0 then
			panelBox.mc_box:setVisible(true)
			ctnBox:removeAllChildren()
		end
	end
end

-- 战斗结束回到主界面会调这个方法
function WorldPVEListView:onBecomeTopView()
	if ShareBossModel:checkFindReward() then
		local findReward = ShareBossModel:getFindReward()
		WindowControler:showWindow("ShareFindRewardView", findReward)
		ShareBossModel:resetFindReward()
	end
end

function WorldPVEListView:onClickRememory()
	-- WindowControler:showTips("剧情回顾,self.curStoryId=" .. self.curStoryId)
	BattleControler:startReplay(self.curStoryId)
end

function WorldPVEListView:onClickEmbattle()
	-- WindowControler:showWindow("TeamFormationView",FuncTeamFormation.formation.pve,{})
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve,{})
end

function WorldPVEListView:startHide()
	WorldPVEListView.super.startHide(self)

	ShareBossModel:isShowHomeViewTips()
end

function WorldPVEListView:onClickBack()
	self:startHide()
end

return WorldPVEListView
