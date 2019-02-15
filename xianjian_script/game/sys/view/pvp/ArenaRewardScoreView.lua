--[[
	Author: ZhangYanguang
	Date:2018-05-30
	Description: PVP奖励(奖励、兑换、排名)之奖励界面
]]

local ArenaRewardScoreView = class("ArenaRewardScoreView", UIBase);

function ArenaRewardScoreView:ctor(winName)
    ArenaRewardScoreView.super.ctor(self, winName)
    self:initData()
end

function ArenaRewardScoreView:initData()
	self.REWARD_STATUS  = {
        CAN_NOT = 0,
        CAN_GET = 1,
        USED = 2,
	}

	self.maxRewardId = FuncPvp.getMaxIntegralId()

	-- 奖励数据(本地数据与网络数据组合)
	self.rewardData = {}

	-- 所有奖品
	self.allScoreRewards = FuncPvp.getIntegralRewards()
	-- 已领取的积分奖励
	self.getedRewards = {}
	-- 待领取的奖品id数组
	self.willGetRewardIds = {}

	-- 已经挑战次数
    self.challengeCount = {}

    dump(self.getedRewards,"---------------self.getedRewards------")
end

function ArenaRewardScoreView:loadUIComplete()
	self:registerEvent()
	self:initView()
	self:updateUI()
	self:gotoTargetPos()
end

function ArenaRewardScoreView:gotoTargetPos()
	local targetIndex = 1
	if #self.willGetRewardIds > 0 then
		targetIndex = self.willGetRewardIds[1]
	end

	-- 跳到第一个可领取的
	self.scrollList:gotoTargetPos(targetIndex,1,0)
end

function ArenaRewardScoreView:initView()
	self:initViewAlign()

	self.scrollList = self.scroll_1
	self.panel_1:setVisible(false)

	local createItemView = function(data)
		local itemView = UIBaseDef:cloneOneView(self.panel_1)
		self:setItemViewData(itemView,data)
		return itemView
	end

	local updateCellFunc = function(itemData,itemView,index)
		self:setItemViewData(itemView,itemData)
	end

	self.listParams = 
	{
		{
			data = self.rewardData,
	        createFunc = createItemView,
	        updateCellFunc = updateCellFunc,
	        itemRect = {x=0,y=0,width = 939,height = 137},
	        perNums= 1,
	        offsetX = -5,
	        offsetY = 5,
	        widthGap = 0,
	        heightGap = -15,
	        perFrame = 1,
		}
	}

end

function ArenaRewardScoreView:initViewAlign()

end

function ArenaRewardScoreView:registerEvent()
	self.panel_di.btn_2:setTap(c_func(self.onClickReceiveAllRewards,self))
	--积分奖励发生变化
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_CHANGED_EVENT, self.updateUI, self)
    --积分奖励界面刷新事件
    EventControler:addEventListener(PvpEvent.SCORE_REWARD_REFRESH_EVENT, self.updateUI, self)
end

function ArenaRewardScoreView:updateButtonStatus()
	if #self.willGetRewardIds == 0 then
		FilterTools.setGrayFilter(self.panel_di.btn_2)
	else
		FilterTools.clearFilter(self.panel_di.btn_2)
	end
end

function ArenaRewardScoreView:setItemViewData(itemView,itemData)
	local index = self:getDataIndex(itemData)
	local indexStr = Tool:transformNumToChineseWord(index)
	local rewardId = index

	-- 第x场
	local displayStr = GameConfig.getLanguageWithSwap("tid_pvp_tips_1005",indexStr)
	itemView.txt_1:setString(displayStr)
	local reward = itemData.reward
	itemView.mc_1:showFrame(#reward)

	for i=1,#reward do
		local rewardStr = reward[i]
		local compItemView = itemView.mc_1.currentView["UI_" .. i]
		compItemView:setRewardItemData({reward = rewardStr})

		local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(compItemView:getResItemIconCtn(),resType,resNum,resId,rewardStr)
	end

	local redPoint = nil
	-- 0 不满足,1可领取 2已领取
	local status = itemData.status

	if status == self.REWARD_STATUS.CAN_NOT 
		or status == self.REWARD_STATUS.CAN_GET then
		itemView.mc_2:showFrame(1)

		local btn = itemView.mc_2.currentView.btn_1
		redPoint = btn:getUpPanel().panel_red
		redPoint:setVisible(false)

		-- 红点状态
		if status == self.REWARD_STATUS.CAN_GET then
			-- redPoint:setVisible(true)
			FilterTools.clearFilter(btn)
			-- 领取奖励
			btn:setTap(c_func(self.onClickReceiveReward,self,rewardId), enabledInWorldRect)
		else
			FilterTools.setGrayFilter(btn)
		end
	else
		itemView.mc_2:showFrame(2)
	end
end

function ArenaRewardScoreView:getDataIndex(data)
	for k,v in pairs(self.rewardData) do
		if v == data then
			return k
		end
	end
end

function ArenaRewardScoreView:updateRewardData()
	-- 已领取的积分奖励
	self.getedRewards = PVPModel:getAllScoreRewards()
	-- 已经挑战次数
    self.challengeCount = CountModel:getPVPChallengeCount()

    self.willGetRewardIds = {}
    self.rewardData = {}
    -- dump(self.getedRewards,"已经领取 self.getedRewards------------")
	for i=1,self.maxRewardId do
		local reward = self.allScoreRewards[tostring(i)]

		local status = self.REWARD_STATUS.CAN_NOT
		-- 设置奖品状态
		-- 满足条件
		if tonumber(reward.condition) <= tonumber(self.challengeCount) then
			-- 可领取
			status = self.REWARD_STATUS.CAN_GET
		end

		-- 已领取
		if self.getedRewards[tostring(i)] then
			status = self.REWARD_STATUS.USED
		end

		reward.status = status
		self.rewardData[#self.rewardData+1] = reward

		if status == self.REWARD_STATUS.CAN_GET then
			self.willGetRewardIds[#self.willGetRewardIds+1] = i
		end
	end
end

function ArenaRewardScoreView:updateUI()
	self:updateRewardData()
	self:updateCountInfo()
	self:updateButtonStatus()
	-- dump(self.rewardData,"self.rewardData------------")
	self.listParams[1].data = self.rewardData
	self.scrollList:styleFill(self.listParams)
	self.scrollList:hideDragBar()
end

-- 更新统计信息
function ArenaRewardScoreView:updateCountInfo()
	self.panel_di.txt_1:setString(self.challengeCount)
end

-- 领取奖励
function ArenaRewardScoreView:onClickReceiveReward(rewardId)
	--发送协议
    local param = {
        scoreIds = {rewardId},--积分奖励的id
    }

    self.requestRewards = {rewardId}
    PVPServer:requestScoreReward(param,c_func(self.onReceiveAllRewardsCallback, self))
end

--键领取
function ArenaRewardScoreView:onClickReceiveAllRewards()
	if #self.willGetRewardIds == 0 then
		WindowControler:showTips(GameConfig.getLanguage("pvp_score_reward_not_any_1004"))
		return
	end

    --发送协议
    local _param = {
        scoreIds = self.willGetRewardIds,--积分奖励的id
    }

    self.requestRewards = self.willGetRewardIds
    PVPServer:requestScoreReward(_param,c_func(self.onReceiveAllRewardsCallback, self))
end

-- 一键领取回调
function ArenaRewardScoreView:onReceiveAllRewardsCallback(event)
	if event and event.result ~= nil then
		local receiveList = self.requestRewards
		local rewards = {}

		for k,v in pairs(receiveList) do
			local rewardId = k
			local curReward = self.allScoreRewards[tostring(rewardId)]
			for i=1,#curReward.reward do
				rewards[#rewards+1] = curReward.reward[i]
			end
		end

		FuncCommUI.startRewardView(rewards)
	end
end

return ArenaRewardScoreView
