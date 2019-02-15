--[[
	Author: lxh
	Date:2017-10-17
	Description: TODO
]]

local ShareFindRewardView = class("ShareFindRewardView", UIBase);

function ShareFindRewardView:ctor(winName, _rewards)
    ShareFindRewardView.super.ctor(self, winName)

    if _rewards then
    	self.findRewards = _rewards
    else
    	echoError("\n\n未传入发现奖励")
    end
    
end

function ShareFindRewardView:loadUIComplete()
	-- local size = self.panel_di:getContainerBox()
	-- self.panel_di:setScaleX(GameVars.width/size.width)
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ShareFindRewardView:registerEvent()
	ShareFindRewardView.super.registerEvent(self)

	self.btn_qiang:setTouchedFunc(c_func(self.showFindReward, self))
	-- self:registClickClose(-1, c_func(self.close, self))
end

function ShareFindRewardView:initData()
	-- TODO
end

function ShareFindRewardView:showFindReward()
	self:close()
	FuncCommUI.startFullScreenRewardView(self.findRewards)
end

function ShareFindRewardView:initView()
	dump(self.findRewards, "\n\nself.findRewards====")
	self.txt_jixu:setVisible(false)
	local count = table.length(self.findRewards)

	if count > 3 then
		echoError("\n\n配表中的奖励条数超过了3条，联系策划修改")
		count = 3
	end

	self.mc_z1:showFrame(count)

	for i = 1, count do
		local reward = string.split(self.findRewards[i], ",")
		local rewardType = reward[1]
		local rewardNum = reward[table.length(reward)]
		local rewardId = reward[table.length(reward) - 1]

		local commonUI = self.mc_z1.currentView["UI_" .. tostring(i)]
		commonUI:setResItemData({reward = self.findRewards[i]})
		commonUI:showResItemName(false)
		commonUI:showResItemRedPoint(false)
        FuncCommUI.regesitShowResView(commonUI,
            rewardType, rewardNum, rewardId, self.findRewards[i], true, true)
	end
end

function ShareFindRewardView:initViewAlign()
	-- TODO
end

function ShareFindRewardView:updateUI()
	-- TODO
end

function ShareFindRewardView:close()
	local findReward = {}
	ShareBossModel:setFindRewardStatus(findReward)
	self:startHide()
end

function ShareFindRewardView:deleteMe()
	-- TODO

	ShareFindRewardView.super.deleteMe(self);
end

return ShareFindRewardView;
