--[[
	Author: lichaoye
	Date: 2017-05-11
	提示充值界面-view
]]

local NewSignTipsView = class("NewSignTipsView", UIBase)

function NewSignTipsView:ctor( winName, vip)
	NewSignTipsView.super.ctor(self, winName)
	self.vip = vip or 0
end

function NewSignTipsView:registerEvent()
	NewSignTipsView.super.registerEvent(self)
	-- EventControler:addEventListener(LineUpEvent.PRAISE_LIST_UPDATE_EVENT, self.updateUI, self)
    -- self.btn_close:setTap(c_func(self.press_btn_close, self))
    self:registClickClose("out")
    self.btn_1:setTap(function()
    	-- WindowControler:showWindow("RechargeMainView")
    	self:startHide()
    end)
end

function NewSignTipsView:loadUIComplete()
	self:registerEvent()
	self:setViewAlign()
	self:updateUI()
end

-- 适配
function NewSignTipsView:setViewAlign()
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyone, UIAlignTypes.LeftBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_buyfive, UIAlignTypes.RightBottom)
   -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.MiddleBottom)
end

function NewSignTipsView:updateUI()
	self.txt_1:setString(GameConfig.getLanguageWithSwap("new_sign_go_vip", self.vip))
end

function NewSignTipsView:press_btn_close()
	self:startHide()
end

return NewSignTipsView