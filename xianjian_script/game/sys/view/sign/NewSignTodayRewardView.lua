--[[
	Author: lichaoye
	Date: 2017-05-11
	今日奖励-view
]]

local NewSignTodayRewardView = class("NewSignTodayRewardView", UIBase)

function NewSignTodayRewardView:ctor( winName )
	NewSignTodayRewardView.super.ctor(self, winName)
end

function NewSignTodayRewardView:registerEvent()
	NewSignTodayRewardView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_close, self))
    self:registClickClose("out")
end

function NewSignTodayRewardView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function NewSignTodayRewardView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewSignTodayRewardView:updateUI()
	-- dump(NewSignModel:getTodayReward(), "NewSignModel:getTodayReward()")
	self.UI_1.txt_1:setString("更多签解")
	local rewards = NewSignModel:getTodayReward()

	for i=1,4 do
		local panel = self["panel_" .. i]
		if panel then
			local reward = rewards[i]
			if reward then
				panel:visible(true)
				panel.UI_1:setResItemData({reward = reward})
				panel.mc_ci:showFrame(i)

				local rewardTmp = string.split(reward, ",")
				local rewardType = rewardTmp[1]
				local rewardNum = rewardTmp[#rewardTmp]
				local rewardId = rewardTmp[#rewardTmp - 1]

				FuncCommUI.regesitShowResView(panel.UI_1, rewardType, rewardNum, rewardId, reward, true, true)
			else
				panel:visible(false)
			end
		end
	end
end

function NewSignTodayRewardView:press_btn_close()
	self:startHide()
end

return NewSignTodayRewardView