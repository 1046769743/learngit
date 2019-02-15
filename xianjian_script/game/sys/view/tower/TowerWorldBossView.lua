--[[
	Author: caocheng
	Date:2017-07-27
	Description: caocheng
]]

local TowerWorldBossView = class("TowerWorldBossView", UIBase);

function TowerWorldBossView:ctor(winName)
    TowerWorldBossView.super.ctor(self, winName)
end

function TowerWorldBossView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerWorldBossView:registerEvent()
	TowerWorldBossView.super.registerEvent(self);
	self.UI_1.btn_1:setTap(c_func(self.press_btn_close, self))
end

function TowerWorldBossView:initData()
	-- TODO
end

function TowerWorldBossView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_064")) 
end

function TowerWorldBossView:initViewAlign()
	-- TODO
end

function TowerWorldBossView:updateUI()
	-- TODO
end

function TowerWorldBossView:deleteMe()
	-- TODO

	TowerWorldBossView.super.deleteMe(self);
end


function TowerWorldBossView:press_btn_close()
	self:startHide()
end
return TowerWorldBossView;
