--[[
	Author: TODO
	Date:2017-11-17
	Description: TODO
]]

local HappySignShowView1 = class("HappySignShowView1", UIBase);

function HappySignShowView1:ctor(winName)
    HappySignShowView1.super.ctor(self, winName)
end

function HappySignShowView1:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	-- self:delayCall(function ()
	-- 		self.panel_lyr:setVisible(true)
	-- 	end, 10 / GameVars.GAMEFRAMERATE)
end 

function HappySignShowView1:registerEvent()
	HappySignShowView1.super.registerEvent(self);

	self.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose(-1, c_func(self.close, self))
end

function HappySignShowView1:initData()
	-- TODO
end

function HappySignShowView1:initView()
	-- self.panel_lyr:setVisible(false)
end

function HappySignShowView1:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_close, UIAlignTypes.RightTop)
end

function HappySignShowView1:updateUI()
	-- TODO
end

function HappySignShowView1:close()
	self:startHide()
end

function HappySignShowView1:deleteMe()
	-- TODO

	HappySignShowView1.super.deleteMe(self);
end

return HappySignShowView1;
