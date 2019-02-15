--[[
	Author: TODO
	Date:2017-10-27
	Description: TODO
]]

local Empty_Comp_tc = class("Empty_Comp_tc", UIBase);

function Empty_Comp_tc:ctor(winName)
    Empty_Comp_tc.super.ctor(self, winName)
end

function Empty_Comp_tc:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function Empty_Comp_tc:registerEvent()
	Empty_Comp_tc.super.registerEvent(self);
end

function Empty_Comp_tc:initData()
	-- TODO
end

function Empty_Comp_tc:initView()
	-- TODO
end

function Empty_Comp_tc:initViewAlign()
	-- TODO
end

function Empty_Comp_tc:updateUI()
	-- TODO
end

function Empty_Comp_tc:deleteMe()
	-- TODO

	Empty_Comp_tc.super.deleteMe(self);
end

return Empty_Comp_tc;
