--[[
	Author: TODO
	Date:2018-07-04
	Description: TODO
]]

local GuildExploreGrid = class("GuildExploreGrid", UIBase);

function GuildExploreGrid:ctor(winName)
    GuildExploreGrid.super.ctor(self, winName)
end

function GuildExploreGrid:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildExploreGrid:registerEvent()
	GuildExploreGrid.super.registerEvent(self);
end

function GuildExploreGrid:initData()
	-- TODO
end

function GuildExploreGrid:initView()
	-- TODO
end

function GuildExploreGrid:initViewAlign()
	-- TODO
end

function GuildExploreGrid:updateUI()
	-- TODO
end

function GuildExploreGrid:deleteMe()
	-- TODO

	GuildExploreGrid.super.deleteMe(self);
end

return GuildExploreGrid;
