--[[
	Author: TODO
	Date:2017-11-17
	Description: TODO
]]

local HappySignShowView2 = class("HappySignShowView2", UIBase);

function HappySignShowView2:ctor(winName)
    HappySignShowView2.super.ctor(self, winName)
end

function HappySignShowView2:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	-- self:delayCall(function ()
	-- 		self.panel_yth:setVisible(true)
	-- 	end, 2 / GameVars.GAMEFRAMERATE)
end 

function HappySignShowView2:registerEvent()
	HappySignShowView2.super.registerEvent(self);

	self.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose(-1, c_func(self.close, self))
end

function HappySignShowView2:initData()
	-- TODO
end

function HappySignShowView2:initView()
	-- self.panel_yth:setVisible(false)
end

function HappySignShowView2:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_close, UIAlignTypes.RightTop)
end

function HappySignShowView2:updateUI()
	-- TODO
end

function HappySignShowView2:close()
	self:startHide()
end

function HappySignShowView2:deleteMe()
	-- TODO

	HappySignShowView2.super.deleteMe(self);
end

return HappySignShowView2;
