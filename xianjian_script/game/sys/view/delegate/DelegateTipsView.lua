--[[
	Author: pangkangning
	Date: 2018-05-24
	挂机消费提示框
]]

local DelegateTipsView = class("DelegateTipsView", UIBase);

function DelegateTipsView:ctor(winName,type,cost,callback)
    DelegateTipsView.super.ctor(self, winName)
    self._type = type
    self._cost = cost
    self.callback = callback
end

function DelegateTipsView:loadUIComplete()
	self:registerEvent()
	self:initView()
end 

function DelegateTipsView:registerEvent()
	DelegateTipsView.super.registerEvent(self);
	-- self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))
	self.UI_1.mc_1:showFrame(1)
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_sure,self))
end

function DelegateTipsView:initView()
	self.mc_1:showFrame(self._type)
	local _tmpView = self.mc_1.currentView
	if self._type ~= 2 then
		_tmpView.txt_2:setString(self._cost)
	end
	self.panel_gou:setTouchedFunc(c_func(self.dagouClick,self,view))
	self.panel_gou.panel_1:visible(false)--打钩
	if self._type == 3 then
		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_delegate_4008"))--标题
	else
		self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_delegate_4007"))--标题
	end
end
function DelegateTipsView:dagouClick( )
	if not self._isGou then
		self.panel_gou.panel_1:visible(true)--打钩
		self._isGou = true
		if self._type == 3 then
			DelegateModel:setSpecialTip(true)
		else
			DelegateModel:setNormalTip(true)
		end
	else
		self._isGou = false
		self.panel_gou.panel_1:visible(false)--打钩
		if self._type == 3 then
			DelegateModel:setSpecialTip(false)
		else
			DelegateModel:setNormalTip(false)
		end
	end
end
function DelegateTipsView:press_btn_close()
	self:startHide()
end
function DelegateTipsView:press_btn_sure( )
	if self.callback then
		self.callback()
	end
	self:startHide()
end

return DelegateTipsView;
