--[[
	目标成就奖励预览
]]

local QuestAchieveRewardView = class("QuestAchieveRewardView", UIBase)

function QuestAchieveRewardView:ctor(winName,rewards)
	QuestAchieveRewardView.super.ctor(self, winName)

	self._rewards = rewards -- 奖励
end

function QuestAchieveRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function QuestAchieveRewardView:registerEvent()
	self:registClickClose("out")
	-- self:registClickClose(nil,nil,false,false)
	self.UI_1.btn_close:setTap(c_func(self.clickClose,self))
end

function QuestAchieveRewardView:initData()
	-- body
end

function QuestAchieveRewardView:initViewAlign()
	-- body
end

function QuestAchieveRewardView:initView()
	-- body
end

function QuestAchieveRewardView:updateUI()
	self.UI_1.mc_1:setTouchedFunc(c_func(self.clickClose,self))

	-- 奖励预览
	self.UI_1.txt_1:setString(GameConfig.getLanguage(FuncBiography.getRewardTitle()))

	-- 直接更新奖励就行了
	local rewardNum = #self._rewards
	if rewardNum > 3 then
		rewardNum = 3
	end

	self.mc_1:showFrame(rewardNum)

	for i=1,rewardNum do
		local item = self.mc_1.currentView["UI_"..i]
		item:setRewardItemData({reward = self._rewards[i]})
		item:showResItemName(true, true)
		local reward = string.split(self._rewards[i], ",")
		local rewardType = reward[1]
		local rewardNum = reward[#reward]
		local rewardId = reward[#reward - 1]
		FuncCommUI.regesitShowResView(item, reward[1], reward[#reward], reward[#reward - 1], self._rewards[i], true, true)
		-- item:showResItemNameWithQuality()
	end
end

function QuestAchieveRewardView:clickClose()
	self:startHide()
end

return QuestAchieveRewardView