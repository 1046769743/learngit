--[[
	Author: TODO
	Date:2018-06-08
	Description: TODO
]]

local DebugPublicView = class("DebugPublicView", UIBase);

function DebugPublicView:ctor(winName)
    DebugPublicView.super.ctor(self, winName)
end

function DebugPublicView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function DebugPublicView:registerEvent()
	DebugPublicView.super.registerEvent(self);
end

function DebugPublicView:initData()
	-- TODO
end

function DebugPublicView:initView()
	-- TODO
end

function DebugPublicView:initViewAlign()
	-- TODO
end

function DebugPublicView:updateUI()
	-- TODO
end

function DebugPublicView:deleteMe()
	-- TODO

	DebugPublicView.super.deleteMe(self);
end

return DebugPublicView;
