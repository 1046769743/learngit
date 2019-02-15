--
-- Author: ZhangYanguang
-- Date: 2016-12-21
--
-- 扫荡奖品展示列表界面

local WorldSweepListView = class("WorldSweepListView", UIBase);

--[[
-- params结构
{
	rewardData = rewardData, 	--扫荡奖品
	targetData = targetData,	--目标数据
	raidId = raidId 			--关卡ID
}

-- targetData结构
{
	targetId = targetId,
	needNum = needNum,
}

rewardData结构 
{
	{
		reward = {"1,402,1","1,303,1"},
		sweepReward = {"1,601,1","1,602,1"},
	},
	{
		reward = {"1,601,1","1,302,1"},
		sweepReward = {"1,601,1","1,602,1"},
	},
}
--]]
function WorldSweepListView:ctor(winName,params)
    WorldSweepListView.super.ctor(self, winName);
    -- dump(params, "\n\nparams====")
    self.defaultRatio = 1
    -- self.showFindReward = false
    self.targetData = params.targetData
    -- 如果有目标道具ID
    if self.targetData and self.targetData.targetId then
    	self.targetResId = self.targetData.targetId
    	-- 如果是完整道具，转成其对应的碎片ID
    	local itemId = FuncItem.getItemPropByKey(self.targetData.targetId,"fragmentId")
    	if itemId then
    		self.targetData.targetId = itemId
    		self.targetResId = itemId
    	end
    end

    self.raidId = params.raidId
    self.targetRaidId = params.targetRaidId
    self.sweepType = params.sweepType

    -- 奖品数据
    self.rewardData = table.copy(params.rewardData)
    self.ratio = params.ratio or self.defaultRatio

    -- dump(self.rewardData,"self.rewardData----------")
end

function WorldSweepListView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()
	self:updateUI()
end

function WorldSweepListView:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.onClose, self));
	-- self.btnConfirm:setTap(c_func(self.onClose, self));
	self.btnConfirm:setTap(c_func(self.clickSweepAgain, self));
	self.btnClose:setTap(c_func(self.onClose, self));
end

-- 初始化数据
function WorldSweepListView:initData()
	self.hasInited = false

	-- 每次扫荡奖品最多数量
	self.rewardNumPerRow = 5
	
	-- 显示累计奖品的最少扫荡次数
	self.minCountRewardTimes = 2

	local raidData = FuncChapter.getRaidDataByRaidId(self.raidId)
	-- 金币
	self.sweepCoin = raidData.coin
	-- 消耗的体力转经验值
    self.sweepExp = raidData.spCost
    -- 体力消耗
    self.spCost = raidData.spCost

    self:updateData()
end

function WorldSweepListView:updateData()
	self:resetData()

	-- 实际扫荡的次数
    self.sweepTimes = #self.rewardData
    self.totalSweepCoin = self.sweepCoin * self.sweepTimes
    self.totalSweepExp = self.sweepExp * self.sweepTimes

    self.hasInitScroll = false
    -- self.isShowing = true
end

-- 重置数据
function WorldSweepListView:resetData()
	-- 行展示延迟秒
	self.rowDelaySec = 0.05
	-- 每个奖品展示延迟秒
	self.cellDelaySec = 0.1
	-- 滚动条行滚动时间
	self.scrollTime = self.rowDelaySec
	-- FadeIn动画时间
	self.rowFadeInTime = 0.2
	self.rewardFadeInTime = 0.2

	-- 是否展示中
	self.isShowing = false
	self.isSpeedUp = false

	self.rowNum = nil
end

function WorldSweepListView:setBtnActionStatus(visible)
	local callBack = function()
		self.btnConfirm:setVisible(visible)
		self.UI_1.btn_close:setVisible(visible)
		self.btnClose:setVisible(visible)
		if visible then
			self:registClickClose("out")
			self.isSweeping = false
		end	
	end

	local delayFrame = 0
	if visible then
		delayFrame = 10
	end

	self:delayCall(c_func(callBack), delayFrame / GameVars.GAMEFRAMERATE )
end

-- 初始化滚动条配置
function WorldSweepListView:initScrollCfg()
	local createItemView = function(itemView,rewardData)
		self:setRewardRowItemView(itemView,rewardData)
		-- 默认隐藏滚动条内容
		itemView:setVisible(false)
		itemView:setTouchedFunc(c_func(self.doSpeedUp,self))
		return itemView
	end

	-- 创建一次扫荡奖品
	local createRewardRowItemViewFunc = function(rewardData)
		local mcItemView = UIBaseDef:cloneOneView(self.mcItemView)
		mcItemView:showFrame(1)
		if #rewardData.reward > self.rewardNumPerRow then
			mcItemView:showFrame(2)
		end
		
		return createItemView(mcItemView.currentView,rewardData)
	end

	-- 创建总计扫荡奖品
	local createRewardRowTotalItemViewFunc = function(rewardData)
		local mcItemView = UIBaseDef:cloneOneView(self.mcItemTotalView)
		mcItemView:showFrame(1)
		if #rewardData.reward > self.rewardNumPerRow then
			mcItemView:showFrame(2)
		end

		return createItemView(mcItemView.currentView,rewardData)
	end

	-- 创建额外奖励
	local createExtraRewardRowItemViewFunc = function(rewardData)
		local itemView = UIBaseDef:cloneOneView(self.panelItemExtraView)
		return createItemView(itemView,rewardData)
	end

	self.panel_jd:setVisible(false)
	-- 创建目标道具信息
	local createTergetItemViewFunc = function(data)
		local itemView = UIBaseDef:cloneOneView(self.panel_jd)
		self:setTargetItemView(itemView,data)
		return itemView
	end

	-- 一行配置
	self.oneRowItemView = {
		data = nil,
        createFunc = createRewardRowItemViewFunc,
        itemRect = {x=0,y=-147,width = 464,height = 147},
        perNums= 1,
        offsetX = 10,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 10, --一帧内全部显示
	}

	-- 两行配置
	self.twoRowItemView = {
		data = nil,
        createFunc = createRewardRowItemViewFunc,
        itemRect = {x=0,y=-231,width = 464,height = 231},
        perNums= 1,
        offsetX = 18,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 10,
	}

	-- 总计奖励获得一行配置
	self.oneRowTotalItemView = {
		data = nil,
        createFunc = createRewardRowTotalItemViewFunc,
        itemRect = {x=0,y=-150,width = 464,height = 150},
        perNums= 1,
        offsetX = 13,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 10,
	}

	-- 总计奖励获得两行配置
	self.twoRowTotalItemView = {
		data = nil,
        createFunc = createRewardRowTotalItemViewFunc,
        itemRect = {x=0,y=-233,width = 464,height = 233},
        perNums= 1,
        offsetX = 13,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 10,
	}

	-- 额外奖励一行配置
	self.oneRowExtraItemView = {
		data = nil,
        createFunc = createExtraRewardRowItemViewFunc,
        itemRect = {x=0,y=-147,width = 464,height = 147},
        perNums= 1,
        offsetX = 13,
        offsetY = -13,
        widthGap = 0,
        heightGap = 0,
        perFrame = 20,
	}

	-- 目标道具一行配置
	self.oneRowTargetItemView = {
		data = nil,
        createFunc = createTergetItemViewFunc,
        itemRect = {x=0,y=0,width = 434,height = 78},
        perNums= 1,
        offsetX = 13,
        offsetY = -10,
        widthGap = 0,
        heightGap = 0,
        perFrame = 1,
	}
end

-- 初始化View
function WorldSweepListView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2065"))
	self.UI_1.mc_1:setVisible(false)

	-- 奖品滚动条
	self.scrollItemList = self.scroll_1

	-- 一次扫荡itemView
	self.mcItemView = self.mc_gc
	self.mcItemView:setVisible(false)

	-- 扫荡总结itemView
	self.mcItemTotalView = self.mc_zj
	self.mcItemTotalView:setVisible(false)

	-- 额外奖励itemView
	self.panelItemExtraView = self.panel_ew
	self.panelItemExtraView:setVisible(false)

	-- 确定按钮
	self.mc_1:showFrame(2)
	self.btnConfirm = self.mc_1.currentView.btn_1
	self.btnConfirm:setVisible(false)
	self.btnClose = self.mc_1.currentView.btn_2
	self.btnClose:setVisible(false)

	-- 展示目标道具状态
	self.panelItemView_1 = self.panel_small1
	self.panelItemView_2 = self.panel_small2

	-- 初始化滚动配置
	self:initScrollCfg()

	self:initGlobalTouch()
end

-- 注册全局点击事件
function WorldSweepListView:initGlobalTouch()
	local touchNode = display.newNode():addTo(self,10)
	touchNode:pos(0,-GameVars.height+GameVars.UIOffsetY)
    touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))

	local function onTouchSpeedUp(touch, event)
		self:doSpeedUp()
	end
	
 	touchNode:setTouchedFunc(c_func(onTouchSpeedUp));
end

-- 更新UI
function WorldSweepListView:updateUI()
	self:updateBtnSweepAgain()
	self:setBtnActionStatus(false)

	-- 处理奖品数据
	self:processRewardData()
	-- 获取展示目标道具
	self.targetItemsInfo = self:getSweepTargetItemsInfo()
	
	-- 2018.07.25 因需求原因暂时注释
	-- self:initTargetItemsView()

	self.__listParams = self:buildItemScrollParams()

	self.scrollItemList:styleFill(self.__listParams)
	self.scrollItemList:clearCacheView()
	
	self.scrollItemList:setOnCreateCompFunc(c_func(self.onScrollCreateComp,self))
	self.isShowing = true
	self.hasInited = true

	-- 没找到目标道具，发送错误日志
	self:sendNotFoundTargetError()
end

-- 当滚动条创建完成
function WorldSweepListView:onScrollCreateComp()
	self:delayCall(c_func(self.playRowRewardAnim,self),1 / GameVars.GAMEFRAMERATE )
end

-- 获得需要展示的目标道具
function WorldSweepListView:getSweepTargetItemsInfo()
	local targetItemInfo = {}

	if self.targetData then
		local curItemInfo = table.deepCopy(self.targetData)
		-- 扫荡获取的数据
		local sweepNum = self:getSweepNum(curItemInfo.targetId)
		-- 扫荡前数量
		if self.sweepType == WorldModel.sweepType.SWEEP_ONE then
			curItemInfo.ownNum = ItemsModel:getItemNumById(self.targetData.targetId)
		else			
			curItemInfo.ownNum = ItemsModel:getItemNumById(self.targetData.targetId)	
		end
		curItemInfo.sweepNum = sweepNum
		targetItemInfo[#targetItemInfo+1] = curItemInfo
	end
	
	return targetItemInfo
end

-- 获得扫荡出该道具的总数量
function WorldSweepListView:getSweepNum(itemId)
	local countNum = function(rewardData,itemId)
		for i=1,#rewardData do
			local rewardStr = rewardData[i]
			local rewardArr = string.split(rewardStr,",")

			if tostring(rewardArr[2]) == tostring(itemId) then
				return rewardArr[3]
			end
		end

		return 0
	end

	local totalNum = countNum(self.totalReward,itemId)
	totalNum = totalNum + countNum(self.totalSweepReward,itemId)

	return totalNum
end

-- 处理原始奖品数据
-- 排序，统计累计奖品及额外获得(sweepReward)
function WorldSweepListView:processRewardData()
	WorldModel:sortSweepRewards(self.rewardData)
	local totalReward,totalSweepReward = WorldModel:countSweepRewards(self.rewardData)

	self.rewardData[#self.rewardData+1] = {reward = totalReward}
	self.rewardData[#self.rewardData+1] = {reward = totalSweepReward}

	self.totalReward = totalReward
	self.totalSweepReward = totalSweepReward
end

-- 是否显示累计奖品
function WorldSweepListView:showTotalReward(realSweepTimes)
	if realSweepTimes >= self.minCountRewardTimes then
		return true
	else
		return false
	end
end

-- 是否显示第几次奖励
function WorldSweepListView:showWichTimesReward(realSweepTimes)
	if realSweepTimes <=  1 then
		return false
	else
		return true
	end
end

-- 动态构建滚动配置
function WorldSweepListView:buildItemScrollParams()
	local listParams = {}

	local oneRowItemView = nil
	local twoRowItemView = nil

	local beginIdx = 1
	local showWichTimes = self:showWichTimesReward(self.sweepTimes)
	-- 只显示两个总计
	if not showWichTimes then
		beginIdx = #self.rewardData - 1
	end

	for i=beginIdx,#self.rewardData do
		local rewardNum = #self.rewardData[i].reward
		local rowParams = nil
		-- 倒数第二行，总计
		if i > 1 and i == #self.rewardData - 1 then
			oneRowItemView = self.oneRowTotalItemView
			twoRowItemView = self.twoRowTotalItemView
		-- 倒数第一行，额外总计
		elseif i > 1 and i == #self.rewardData then
			oneRowItemView = self.oneRowExtraItemView
		else
			oneRowItemView = self.oneRowItemView
			twoRowItemView = self.twoRowItemView
		end

		if rewardNum <= self.rewardNumPerRow then
			rowParams = table.deepCopy(oneRowItemView)
		else
			rowParams = table.deepCopy(twoRowItemView)
		end

		-- 位置修正
		if i==beginIdx then
			rowParams.offsetY = 2
		end

		rowParams.data = {self.rewardData[i]}

		listParams[#listParams+1] = rowParams
	end

	-- 需要插入目标道具信息itemView
	if self.targetResId then
		local rowParams = table.deepCopy(self.oneRowTargetItemView)
		--[[
		1 = {
	         "needNum"  = 10
	         "ownNum"   = 1028
	         "targetId" = "9601"
     	}
		]]
		local data = self.targetItemsInfo[1]
		data.reward = {"1," .. self.targetResId .. ",0"}

		rowParams.data = {data}
		listParams[#listParams+1] = rowParams
	end

	return listParams
end

-- 动画加速
function WorldSweepListView:doSpeedUp()
	if self.rowNum == nil or self.rowNum < 1 then
		return
	end

	if not self.hasInited then
		return
	end

	local callBack = function()
		if self.isShowing then
			local scale = 3
			self.isSpeedUp = true

			-- self.rowDelaySec = self.rowDelaySec / 5
			self.cellDelaySec = self.cellDelaySec / scale
			self.scrollTime = self.rowDelaySec
		end
	end
	
	self:delayCall(c_func(callBack), 0.1)
end

-- 初始化目标Items
function WorldSweepListView:initTargetItemsView()
	self.tempTargetItemNum = {}
	local targetItemNum = 0
	if self.targetItemsInfo then
		targetItemNum = #self.targetItemsInfo
	end

	for i=1,targetItemNum do
		local targetItem = self.targetItemsInfo[i]
		local targetId = targetItem.targetId
		local needNum = targetItem.needNum
		local ownNum = targetItem.ownNum

		local panelItem = self["panel_small" .. i]
		panelItem:setVisible(false)
		
		local rewardStr = self:findTargetReward(targetId)
		-- 如果没有找到目标，仍然显示目标道具
		if rewardStr == nil then
			if targetId then
				rewardStr = "1," .. targetId .. ",0"
			end
		end

		if rewardStr then
			panelItem:setVisible(true)
			local compResItemView = panelItem["UI_1"]
			compResItemView:setResItemData({reward = rewardStr})
			compResItemView:showResItemName(false)
			compResItemView:showResItemNum(false)

			self.tempTargetItemNum[targetId] = ownNum
			self:updateOneTargetItemView(panelItem,ownNum,needNum)
		end
	end

	if targetItemNum < 2 then
		for i=targetItemNum+1,2 do
			local panelItem = self["panel_small" .. i]
			panelItem:setVisible(false)
		end
	end
end

-- 更新目标Items
function WorldSweepListView:updateTargetItem(rewardStr)
	local sweepItemId = nil
	local sweepItemNum = nil

	if rewardStr then
		local rewardArr = string.split(rewardStr,",")
		if #rewardArr == 2 then
			sweepItemId = rewardArr[1]
			sweepItemNum = rewardArr[2]
		else
			sweepItemId = rewardArr[2]
			sweepItemNum = rewardArr[3]
		end

		if self.targetItemsInfo then
			for i=1,#self.targetItemsInfo do
				local targetItem = self.targetItemsInfo[i]
				local targetId = targetItem.targetId
				if tostring(sweepItemId) == tostring(targetId) then
					local panelItem = self["panel_small" .. i]
					panelItem:setVisible(true)

					local needNum = targetItem.needNum
					local ownNum = self.tempTargetItemNum[targetId] + sweepItemNum

					self:updateOneTargetItemView(panelItem,ownNum,needNum)
					self.tempTargetItemNum[targetId] = ownNum
				end
			end
		end
	end
end

-- 更新一个目标item
function WorldSweepListView:updateOneTargetItemView(panelItem,ownNUm,needNum)
	panelItem.mc_1:showFrame(1)
	if ownNUm < needNum then
		panelItem.mc_1:showFrame(2)
	end

	panelItem.mc_1.currentView.txt_1:setString(ownNUm .. "/" .. needNum)
	-- panelItem.txt_2:setString(needNum)
end

-- 根据itemId查找奖品字符串
function WorldSweepListView:findTargetReward(itemId)
	local findItem = function(rewardStr,itemId)
		local rewardArr = string.split(rewardStr,",")
		if tostring(rewardArr[2]) == tostring(itemId) then
			return true
		end

		return false
	end

	local rewardStr = nil
	for i=1,#self.totalReward do
		rewardStr = self.totalReward[i]
		if findItem(rewardStr,itemId) then
			return rewardStr
		end
	end

	for i=1,#self.totalSweepReward do
		rewardStr = self.totalSweepReward[i]
		if findItem(rewardStr,itemId) then
			return rewardStr
		end
	end

	return nil
end

-- 指定了目标道具，且扫荡的是指定关卡，如果没有扫到报错到错误平台
function WorldSweepListView:sendNotFoundTargetError()
	if self.targetRaidId == self.raidId and self.targetData then
		local targetId = self.targetData.targetId
		if targetId then
			local rewardStr = self:findTargetReward(targetId)
			if rewardStr == nil then
				local errorInfo = {
					targetRaidId = targetRaidId,
					targetResId = targetId,
					reward = self.rewardData
				}

				if not AppInformation:isReleaseMode() then
					echoError ("没有扫到指定道具self.targetRaidId=",self.targetRaidId)
				end
				
				local logMsg = json.encode(errorInfo)
				ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,"sweepError",logMsg)
			end
		end
	end
end

-- 动画播放结束
function WorldSweepListView:onPlayRewardAnimFinish()
	local showLvUpView = function()
		EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE)
		self:resetData()		
		self:setBtnActionStatus(true)
	end
	
	if UserModel:isLvlUp() then
		local delaySec  = 0.2
		-- 发送主角升级消息 
		self:delayCall(c_func(showLvUpView),delaySec)
	else
		-- add by zgy   2017/8/17
		self:checkOpenShopByDelayTime(0.2)
		self:resetData()
		self:setBtnActionStatus(true)
	end

	-- ======================================================================================
	-- 注册点击tips
	echoWarn("____________ 结束之后注册点击事件 ____________")
	for k,v in pairs(self.__listParams) do
		local rewardData = v.data[1]
		local rowItemView = self.scrollItemList:getViewByData(rewardData)
		if rewardData.reward then
			for k,v in pairs(rewardData.reward) do
				local rewardStr = v 
				local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
				if rowItemView then
					FuncCommUI.regesitShowResView(rowItemView["UI_" .. k],resType,resNum,resId,rewardStr,true,true)
				end   		
			end
		end
	end
	-- ======================================================================================

	-- if ShareBossModel:checkFindReward() then
	-- 	self.showFindReward = true
	-- 	local delaySec = 0.5
	-- 	self:delayCall(function ()
	-- 		self:startHide()
	-- 	end, delaySec)
	-- end
end
-- 检查临时商店是否开启
function WorldSweepListView:checkOpenShopByDelayTime(delayTime)
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



-- 展示扫荡结果中一行奖品动画
function WorldSweepListView:playRowRewardAnim()
	if not self.isShowing then
		return
	end

	if self.rowNum == nil then
		self.rowNum = 1
	else
		self.rowNum = self.rowNum + 1
	end

	-- echo("self.rowNum===" .. self.rowNum .. ",#self.__listParams=" .. #self.__listParams)
	-- 是否展示完毕
	if self.rowNum > #self.__listParams then
		-- EventControler:dispatchEvent(WorldEvent.SWEEP_ANIMATION_COMPLETE)
		-- self:onPlayRewardAnimFinish()
		-- rewardData = [self.rowNum].data[1]
		return
	end

	local rewardData = nil
	local rowItemView = nil

	local callBack = function()
		rowItemView:setVisible(true)
		self:gotoScrollTargetPos(self.rowNum,self.scrollTime)
		self:playOneRewardAnim(rowItemView,rewardData,1)
	end

	-- 如果是加速
	if self.isSpeedUp then
		for i=1,(#self.__listParams - self.rowNum) + 1 do
			rewardData = self.__listParams[self.rowNum].data[1]
			rowItemView = self.scrollItemList:getViewByData(rewardData)

			if rowItemView == nil then
				echoWarn ("\n\n-----------WorldSweepListView:playRowRewardAnim self.rowNum====",self.rowNum)
				echo("#self.__listParams-",#self.__listParams,self.rowNum)
				-- dump(rewardData)
				-- dump(self.rewardData)
				-- dump(self.__listParams)
				self:onPlayRewardAnimFinish()
				return
			end

			self:showRowRewardItemView(rowItemView,rewardData,true)
			-- self.scrollItemList:gotoTargetPos(1,self.rowNum,1,self.scrollTime * i)
			self:gotoScrollTargetPos(self.rowNum,self.scrollTime,self.scrollTime * i)

			self.rowNum = self.rowNum + 1

			-- 是否展示完毕
			if self.rowNum > #self.__listParams then
				self:delayCall(c_func(self.onPlayRewardAnimFinish,self),self.scrollTime * i)
			end
		end
	else
		rewardData = self.__listParams[self.rowNum].data[1]
		rowItemView = self.scrollItemList:getViewByData(rewardData)
		FuncCommUI.playFadeInAnim(rowItemView,self.rowFadeInTime,callBack)
	end

	-- 如果是总计或额外奖励，需要一次显示完所有奖品，设置为加速显示
	if self.rowNum == #self.__listParams - 1 then
		self.isSpeedUp = true
	end
end

-- 展示扫荡结果中一个奖品的动画
function WorldSweepListView:playOneRewardAnim(rowItemView,rewardData,index)
	if not self.isShowing then
		return
	end

	if index > #rewardData.reward then
		-- 播放下一行奖品
		self:delayCall(c_func(self.playRowRewardAnim,self), self.rowDelaySec)
		return
	end

	local nextIndex = nil

	-- 如果是加速
	if self.isSpeedUp then
		for i=index,#rewardData.reward do
			local curRewardView = rowItemView["UI_" .. i]
			-- 一行最多10个奖品，如果超过10个curRewardView为nil，不会显示
			if curRewardView then
				rowItemView["UI_" .. i]:setVisible(true)
				self:onOneRewardUpdateFinish(rewardData.reward[i])
			end
		end

		nextIndex = #rewardData.reward + 1
		self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)
	else
		local callBack = function()
			self:onOneRewardUpdateFinish(rewardData.reward[index])
			nextIndex = index + 1
			self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)
		end

		-- nextIndex = index + 1
		-- rowItemView["UI_" .. index]:setVisible(true)
		-- self:delayCall(c_func(self.playOneRewardAnim,self,rowItemView,rewardData,nextIndex), self.cellDelaySec)

		-- 播放展示动画
		if rowItemView["UI_" .. index] == nil then
			echoWarn("\n\nrowItemView  UI_index = nil", index)
		else
			FuncCommUI.playFadeInAnim(rowItemView["UI_" .. index],self.rewardFadeInTime,callBack)
		end
	end
end

-- 一个奖品展示完毕
function WorldSweepListView:onOneRewardUpdateFinish(rewardStr)
	-- 如果是总计
	if self.rowNum and self.rowNum >= #self.__listParams - 1 then
		return
	end
	
	-- 2018.07.25 需要原因注释掉
	-- self:updateTargetItem(rewardStr)
end

-- 跳转到滚动条指定位置
function WorldSweepListView:gotoScrollTargetPos(whichNum,scrollTime,delayTime)
	local callBack = function()
		if whichNum == nil or whichNum >= #self.__listParams then
			return
		end

		self.scrollItemList:gotoTargetPos(1,whichNum,1,scrollTime)
	end

	if delayTime and delayTime > 0 then
		self:delayCall(c_func(callBack),delayTime)
	else
		callBack()
	end
end

-- 展示一次扫荡内容
function WorldSweepListView:showRowRewardItemView(rowItemView,rewardData,visible)
	rowItemView:setVisible(visible)
	if rewardData.reward == nil then
		return
	end

	for i=1,#rewardData.reward do
		local curRewardView = rowItemView["UI_" .. i]
		-- 一行最多10个奖品，如果超过10个curRewardView为nil，不会显示
		if curRewardView then
			curRewardView:setVisible(visible)
			self:onOneRewardUpdateFinish(rewardData.reward[i])
		end
	end
end

function WorldSweepListView:setTargetItemView(itemView,data)
	-- local data = {
	-- 	targetRes = "1,9601,1",
	-- 	targetNeedResNum = 10,
	-- 	ownResNum = 5,
	-- 	sweepNum = 3,
	-- }
	itemView:setVisible(false)

	local uiView = itemView.UI_1
	self:updateOneItemView(uiView,data.reward[1],true)

	itemView.txt_2:setString("X" .. (data.sweepNum * self.ratio) .. "，")

	if data.ownNum >= data.needNum then
		itemView.mc_1:showFrame(1)
	else
		itemView.mc_1:showFrame(2)
	end

	itemView.mc_1.currentView.txt_2:setString(data.ownNum .. "/" .. data.needNum)
end

-- 更新一行奖品（一次扫荡内容）
function WorldSweepListView:setRewardRowItemView(rowItemView,rowRewardData)
	local rewardArr = rowRewardData.reward

	-- 第几次扫荡
	local whichSweep = self:getDataIndex(rowRewardData)

	-- if rowItemView.txt_2 and rowItemView.txt_3 then
	if whichSweep <= self.sweepTimes then
		-- 第几次
		-- local num = Tool:transformNumToChineseWord(whichSweep)
		-- rowItemView.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_story_10100",num))
		rowItemView.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_story_10100",whichSweep))
		-- 经验
		rowItemView.txt_2:setString(self.sweepExp)
		-- 铜钱
		rowItemView.txt_3:setString(self.sweepCoin)

	-- 总结奖励
	elseif whichSweep ==  self.sweepTimes + 1 then
		-- 经验
		rowItemView.txt_2:setString(self.totalSweepExp)
		-- 铜钱
		rowItemView.txt_3:setString(self.totalSweepCoin)
	end
	
	self:hideAllItemView(rowItemView)

	-- echo("奖品一行数量：",whichSweep,"-",#rewardArr)
	for i=1,#rewardArr do
		local itemData = rewardArr[i]
		local itemView = rowItemView["UI_" .. i]
		if itemView then
			self:updateOneItemView(itemView,itemData)
		else
			echoWarn("WorldSweepListView:setRewardRowItemView itemView is nil and i is ",i)
		end
	end
end

-- 更新一个奖品道具ItemView
function WorldSweepListView:updateOneItemView(itemView,itemData,hideNum)
	local data = {
		-- reward = itemData
		reward = self:ratioReward(itemData,self.ratio)
	}

	itemView:setResItemData(data)
	itemView:showResItemName(false)
	if hideNum then
		itemView:showResItemNum(false)
	end
end

-- 奖品倍率
function WorldSweepListView:ratioReward(itemData,ratio)
	if not ratio or ratio == 1 then
		return itemData
	end

	local newItemData = ""
	if itemData then
		local arr = string.split(itemData,",")
		local num = arr[#arr]
		arr[#arr] = tonumber(arr[#arr]) * ratio

		local len = #arr
		for i=1,len do
			if i ~= 1 then
				newItemData = newItemData .. ","
			end
			newItemData = newItemData .. tostring(arr[i])
		end
	end

	return newItemData
end

-- 根据奖品数据获取是第几次
function WorldSweepListView:getDataIndex(rowRewardData)
	for i=1,#self.rewardData do
		if self.rewardData[i] == rowRewardData then
			return i
		end
	end
end

-- 隐藏一行奖品中所有奖品itemView
function WorldSweepListView:hideAllItemView(rowItemView)
	for i=1,self.rewardNumPerRow * 2 do
		local compResItemView = rowItemView["UI_" .. i]
		if compResItemView then
			compResItemView:setVisible(false)
		end
	end
end

function WorldSweepListView:updateBtnSweepAgain( )
	-- 扫荡次数
    local times = nil
    if self.sweepType == WorldModel.sweepType.SWEEP_ONE then
    	times = 1
    elseif self.sweepType == WorldModel.sweepType.SWEEP_TEN then
    	times = 10

    	local mySp = UserExtModel:sp()
    	if tonumber(mySp) >= self.spCost then
    		local leftTimes = math.floor(mySp / self.spCost)
	    	if leftTimes < times then
	            times = leftTimes
	        end
	    end

	    -- 精英挑战次数限制
    	if WorldModel:isEliteRaid(self.raidId) then
    		leftEliteTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
    		if leftEliteTimes == 0 then
    			times = 3
    		elseif leftEliteTimes < times or (leftEliteTimes > 0 and times == 0) then 
    			times = leftEliteTimes
    		end
    	end
    end

    self.btnConfirm:setBtnStr("再扫" .. times .. "次")
end

-- 点击再次扫荡
function WorldSweepListView:clickSweepAgain( )
	if self.isSweeping then
		return
	end

	-- 扫荡次数
    local times = 1
    if self.sweepType == WorldModel.sweepType.SWEEP_ONE then
    	times = 1
    elseif self.sweepType == WorldModel.sweepType.SWEEP_TEN then
    	times = 10
    end

     -- 体力限制
    local mySp = UserExtModel:sp()
    if tonumber(mySp) < self.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        local leftTimes = math.floor(mySp / self.spCost)
        if leftTimes < times then
            times = leftTimes
        end
    end

    -- 精英挑战次数限制
    if WorldModel:isEliteRaid(self.raidId) then
	    local leftEliteTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
	    if leftEliteTimes == 0 then
		    local buyTimes = WorldModel:getEliteBuyTimes(self.raidId)
		    local maxTimes = WorldModel:getEliteMaxBuyTimes()
		    echo("__________ buyTimes,maxTimes ________________",buyTimes,maxTimes)
		    if buyTimes < maxTimes then
		        WindowControler:showWindow("WorldBuyChallengeTimesView",self.raidId);
		    else
		        WindowControler:showTips(GameConfig.getLanguage("tid_story_10119"))
		    end
	    	-- WindowControler:showWindow("WorldBuyChallengeTimesView",self.raidId)
	    	return
	    end
	    if leftEliteTimes < times then 
    		times = leftEliteTimes
    	end
	end

	self.isSweeping = true
    WorldServer:sweep(self.raidId,times,c_func(self.sweepAgainCallBack,self))
end

function WorldSweepListView:sweepAgainCallBack(serverData)
	if serverData and serverData.result ~= nil then
		self.rewardData = table.copy(serverData.result.data.reward)
		self.ratio =  serverData.result.data.ratio or self.defaultRatio

        self:initData()
        self:updateUI()
        ShareBossModel:setFindRewardStatus(serverData.result.data.shareBossReward)
    end
end

function WorldSweepListView:onClose()
	self:startHide()
end

function WorldSweepListView:startHide()
	if self.isShowing then
		return
	end
	WorldSweepListView.super.startHide(self)
end

return WorldSweepListView
