--[[
	奇侠传记奖励View
	author: lcy
	add: 2018.7.20
]]

local BiographyRewardView = class("BiographyRewardView", UIBase)

function BiographyRewardView:ctor(winName,rewards)
	BiographyRewardView.super.ctor(self, winName)

	self._rewards = rewards
end

function BiographyRewardView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end

function BiographyRewardView:registerEvent()
	-- self:registClickClose("out")
	-- self:registClickClose(nil,nil,false,false)
	self.UI_1.btn_close:setTap(c_func(self.clickClose,self))
end

function BiographyRewardView:initData()
	-- body
end

function BiographyRewardView:initViewAlign()
	-- body
end

function BiographyRewardView:initView()
	-- body
end

function BiographyRewardView:updateUI()
	-- 隐藏确定
	self.UI_1.mc_1:visible(false)
	-- 奖励预览
	self.UI_1.txt_1:setString(GameConfig.getLanguage(FuncBiography.getRewardTitle()))

	-- 直接更新奖励就行了
	local rewardNum = #self._rewards
	if rewardNum > 4 then
		rewardNum = 4
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

function BiographyRewardView:clickClose()
	self:startHide()
end

return BiographyRewardView