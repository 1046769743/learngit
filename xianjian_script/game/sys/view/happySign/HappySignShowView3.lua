--[[
	Author: TODO
	Date:2017-11-17
	Description: TODO
]]

local HappySignShowView3 = class("HappySignShowView3", UIBase);

function HappySignShowView3:ctor(winName, _onlineDay)
    HappySignShowView3.super.ctor(self, winName)
    self.onlineDay = _onlineDay
    self.happySignDay = 7
end

function HappySignShowView3:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	-- self:delayCall(function ()
	-- 		self.panel_txj:setVisible(true)
	-- 		self.mc_1:setVisible(true)
	-- 	end, 1 / GameVars.GAMEFRAMERATE)
end 

function HappySignShowView3:registerEvent()
	HappySignShowView3.super.registerEvent(self);

	self.btn_close:setTouchedFunc(c_func(self.close, self))
	self:registClickClose(-1, c_func(self.close, self))
end

function HappySignShowView3:initData()
	
end

function HappySignShowView3:initView()
	local leftDay = self.happySignDay - self.onlineDay
	if leftDay <= 0 then
		leftDay = 1
	end
	self.mc_1:showFrame(leftDay)
	-- self.panel_txj:setVisible(false)
	-- self.mc_1:setVisible(false)
end

function HappySignShowView3:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_close, UIAlignTypes.RightTop)
end

function HappySignShowView3:updateUI()
	-- TODO
end

function HappySignShowView3:close()
	self:startHide()
end

function HappySignShowView3:deleteMe()
	-- TODO

	HappySignShowView3.super.deleteMe(self);
end

return HappySignShowView3;
