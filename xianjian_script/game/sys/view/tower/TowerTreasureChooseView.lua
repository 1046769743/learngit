--[[
	Author: TODO
	Date:2017-12-22
	Description: TODO
]]

local TowerTreasureChooseView = class("TowerTreasureChooseView", UIBase);

function TowerTreasureChooseView:ctor(winName)
    TowerTreasureChooseView.super.ctor(self, winName)
end

function TowerTreasureChooseView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerTreasureChooseView:registerEvent()
	TowerTreasureChooseView.super.registerEvent(self);
end

function TowerTreasureChooseView:initData()
	-- TODO
end

function TowerTreasureChooseView:initView()
	-- TODO
end

function TowerTreasureChooseView:initViewAlign()
	-- TODO
end

function TowerTreasureChooseView:updateUI()
	-- TODO
end

function TowerTreasureChooseView:deleteMe()
	-- TODO

	TowerTreasureChooseView.super.deleteMe(self);
end

return TowerTreasureChooseView;
