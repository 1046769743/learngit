--[[
	Author: lichaoye
	Date: 2017-05-11
	获取累计奖励界面-view
]]

local NewSignGetTotalView = class("NewSignGetTotalView", UIBase)

--[[
	params = {
		vip = , -- 需要显示的vip
		vtype = ,1.vip够的情况领取的 2.vip不够的情况领取的 3.补领
		reward = "",
	}
]]
function NewSignGetTotalView:ctor( winName, params )
	NewSignGetTotalView.super.ctor(self, winName)
	-- self.datas = {reward = "1,1019,1",vip = 2, vtype = 3}
	self.datas = params
end

function NewSignGetTotalView:registerEvent()
	NewSignGetTotalView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    self:registClickClose("out")
    self.btn_1:setTap(c_func(self.press_btn_close, self))
end

function NewSignGetTotalView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
	self:tempView()
end

-- 适配
function NewSignGetTotalView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewSignGetTotalView:updateUI()
	self.mc_1:showFrame(self.datas.vtype)
	local noview = self.mc_1.currentView
	-- 文字
	local text
	local vtype = tonumber(self.datas.vtype)
	if vtype == 1 or vtype == 3 then
		text = "new_sign_at_vip"
	else
		text = "new_sign_vip_can"
	end
	-- text = GameConfig.getLanguageWithSwap(text, self.datas.vip)
	-- noview.txt_1:setString(text)

	-- 奖励（暂时只显示一种）
	-- for i=1,2 do
		local i = 1
		local iconUI = noview["UI_" .. i]
		if iconUI then
			iconUI:setResItemData(self.datas)

			local reward = string.split(self.datas.reward, ",")
			local rewardType = reward[1]
			local rewardNum = reward[#reward]
			local rewardId = reward[#reward - 1]

			FuncCommUI.regesitShowResView(iconUI, rewardType, rewardNum, rewardId, self.datas.reward, true, true)
		end
	-- end
end

function NewSignGetTotalView:press_btn_close()
	self:startHide()
end

function NewSignGetTotalView:tempView()
	-- body
	local nowview = self.mc_1.currentView
	nowview.UI_2:setVisible(flase)
	nowview.txt_1:setVisible(flase)
end

return NewSignGetTotalView