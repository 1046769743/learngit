--[[
	Author: TODO
	Date:2017-11-30
	Description: TODO
]]

local TempGotoRechargeView = class("TempGotoRechargeView", UIBase);

function TempGotoRechargeView:ctor(winName)
    TempGotoRechargeView.super.ctor(self, winName)
end

function TempGotoRechargeView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TempGotoRechargeView:registerEvent()
	TempGotoRechargeView.super.registerEvent(self);
	self:registClickClose("out")
	self.btn_close:setTouchedFunc(c_func(self.press_btn_close, self))
end

function TempGotoRechargeView:initData()
	-- TODO
end

function TempGotoRechargeView:initView()
	self.btn_1:setTouchedFunc(c_func(self.gotoSignIn,self))
end

function TempGotoRechargeView:initViewAlign()
	-- TODO
end

function TempGotoRechargeView:gotoSignIn()
	if FuncCommon.isSystemOpen("happySign") then
		WindowControler:showWindow("HappySignView")
		self:startHide()
	else	
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2033"))
	end	
end

function TempGotoRechargeView:updateUI()
	-- TODO
end

function TempGotoRechargeView:press_btn_close()
	self:startHide()
end

function TempGotoRechargeView:deleteMe()
	-- TODO

	TempGotoRechargeView.super.deleteMe(self);
end

return TempGotoRechargeView;
