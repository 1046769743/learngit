
--[[
	Author: caocheng
	Date:2017-07-26
	Description:锁妖塔的选择弹窗
]]

local DelegateRecallTipsView = class("DelegateRecallTipsView", UIBase);

function DelegateRecallTipsView:ctor(winName,tipType,callback)
    DelegateRecallTipsView.super.ctor(self, winName)
    self.tipType = tipType
    self.callback = callback
end

function DelegateRecallTipsView:loadUIComplete()
	self:registerEvent()
	self:initView()
end 

function DelegateRecallTipsView:registerEvent()
	DelegateRecallTipsView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_sure,self))
end

function DelegateRecallTipsView:initView()
	if self.tipType == 1 then
		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_delegate_2002"))
		self.rich_1:setString(GameConfig.getLanguage("#tid_delegate_2015"))
		self.UI_1.mc_1:showFrame(2)
		self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.press_btn_close,self))
		self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_sure,self))
	elseif self.tipType == 3 then
		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_delegate_2014"))
		self.rich_1:setString(GameConfig.getLanguage("#tid_delegate_2012"))
	else
		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_delegate_3013"))
		self.rich_1:setString(GameConfig.getLanguage("#tid_delegate_3014"))
	end
end

function DelegateRecallTipsView:press_btn_close()
	self:startHide()
end
function DelegateRecallTipsView:press_btn_sure( )
	if self.callback then
		self.callback()
	end
	self:startHide()
end

return DelegateRecallTipsView;
