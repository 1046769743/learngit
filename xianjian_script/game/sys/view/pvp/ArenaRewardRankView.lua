--[[
	Author: ZhangYanguang
	Date:2018-05-30
	Description: PVP奖励(奖励、兑换、排名)之排名界面
]]

local ArenaRewardRankView = class("ArenaRewardRankView", UIBase);

function ArenaRewardRankView:ctor(winName)
    ArenaRewardRankView.super.ctor(self, winName)
    self:initData()
end

function ArenaRewardRankView:initData()
	self.REWARD_STATUS  = {
        CAN_NOT = 0,
        CAN_GET = 1,
        USED = 2,
	}

	-- 奖励数据(本地数据与网络数据组合)
	self.rewardData = {}

	-- 所有奖品
	self.allRankRewards = PVPModel:getSortedRankRewards()
	-- 已领取的奖励
	self.getedRewards = {}
	-- 待领取的奖品id数组
	self.willGetRewardIds = {}
end

function ArenaRewardRankView:loadUIComplete()
	self:registerEvent()
	self:initView()
	self:updateUI()
end

function ArenaRewardRankView:initView()
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
	        itemRect = {x=0,y=-414,width = 265,height = 414},
	        perNums= 1,
	        offsetX = -15,
	        offsetY = 2,
	        widthGap = -35,
	        heightGap = -10,
	        perFrame = 1,
		}
	}
end

function ArenaRewardRankView:registerEvent()
	--积分奖励发生变化
    EventControler:addEventListener(PvpEvent.RANK_REWARD_CHANGED_EVENT, self.updateUI, self)
end

function ArenaRewardRankView:setItemViewData(itemView,itemData)
	local rewardId = itemData.id

	-- 排名进入xx
	local displayStr = GameConfig.getLanguageWithSwap("tid_pvp_tips_1006",itemData.rankMax)
	-- 排名
	itemView.txt_1:setString(displayStr)

	local reward = itemData.reward
	itemView.mc_1:showFrame(#reward)

	for i=1,#reward do
		local compItemView = itemView.mc_1.currentView["UI_" .. i]
		local rewardStr = reward[i]
		compItemView:setRewardItemData({reward = rewardStr})

		local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        FuncCommUI.regesitShowResView(compItemView:getResItemIconCtn(),resType,resNum,resId,rewardStr)
	end

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
			btn:setTouchedFunc(c_func(self.onClickReceiveReward,self,rewardId))
		else
			FilterTools.setGrayFilter(btn)
			btn:setTouchedFunc(function ()
					WindowControler:showTips(GameConfig.getLanguage("pvp_rank_condition_not_satisfy_1002"))
				end)
		end
	else
		itemView.mc_2:showFrame(2)
	end
end

function ArenaRewardRankView:updateRewardData()
	self.pvpPeakRank = PVPModel:pvpPeakRank()
	-- 已领取的奖励
	self.getedRewards = PVPModel:getRankRewards()

	self.willGetRewardIds = {}
	self.rewardData = {}
	for i=1,#self.allRankRewards do
		local reward = self.allRankRewards[i]
		local status = self.REWARD_STATUS.CAN_NOT

		local rankMin = reward.rankMin
		local rankMax = reward.rankMax

		if (self.pvpPeakRank >= rankMin and self.pvpPeakRank <= rankMax) or
		 self.pvpPeakRank < rankMin then
			-- 可领取
			status = self.REWARD_STATUS.CAN_GET
		end

		-- 已领取
		if self.getedRewards[reward.id] then
			status = self.REWARD_STATUS.USED
		end

		reward.status = status
		self.rewardData[#self.rewardData+1] = reward
	
		if status == self.REWARD_STATUS.CAN_GET then
			self.willGetRewardIds[#self.willGetRewardIds+1] = i
		end
	end
end

function ArenaRewardRankView:updateUI()
	self:updateRewardData()
	self:updateRankInfo()

	self.listParams[1].data = self.rewardData
	self.scrollList:styleFill(self.listParams)

	local targetIndex = 1
	if #self.willGetRewardIds > 0 then
		targetIndex = self.willGetRewardIds[1]
	end

	-- 跳到第一个可领取的
	self.scrollList:gotoTargetPos(targetIndex,1,1)
end

function ArenaRewardRankView:updateRankInfo()
	local len = string.len(self.pvpPeakRank)
	local mcRank = self.panel_up.mc_1
	mcRank:showFrame(len)

	for i=1,len do
		local num = string.sub(tostring(self.pvpPeakRank),i,i)
		local mcNum = mcRank.currentView["mc_" .. i]
		mcNum:showFrame(num + 1)
	end
end

-- 领取奖励
function ArenaRewardRankView:onClickReceiveReward(rewardId)
	self.requestRewards = {rewardId}

	--发送协议
    local param = {
        id = rewardId,--积分奖励的id
    }

    PVPServer:requestRankReward(param,c_func(self.onReceiveRewardsCallback, self))
end

-- 领取奖励回调
function ArenaRewardRankView:onReceiveRewardsCallback(event)
	if event and event.result ~= nil then
		local receiveList = self.requestRewards

		local rewards = {}

		for k,v in pairs(receiveList) do
			local rewardId = k
			local curReward = self.allRankRewards[tonumber(rewardId)]
			for i=1,#curReward.reward do
				rewards[#rewards+1] = curReward.reward[i]
			end
		end

		FuncCommUI.startRewardView(rewards)
		EventControler:dispatchEvent(PvpEvent.PVP_RANK_REWARD_EVENT)
		-- self:updateUI()
	end
end

return ArenaRewardRankView

