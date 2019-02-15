--[[
	Author: TODO
	Date:2017-09-01
	Description: TODO
]]

local WorldNewJump = class("WorldNewJump", UIBase);

function WorldNewJump:ctor(winName)
    WorldNewJump.super.ctor(self, winName)
end

function WorldNewJump:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WorldNewJump:registerEvent()
	WorldNewJump.super.registerEvent(self);
end

function WorldNewJump:initData()
	-- TODO
end

function WorldNewJump:initView()
	-- TODO
end

function WorldNewJump:initViewAlign()
	-- TODO
end

function WorldNewJump:updateUI()
	-- TODO
end

function WorldNewJump:deleteMe()
	-- TODO

	WorldNewJump.super.deleteMe(self);
end

return WorldNewJump;
