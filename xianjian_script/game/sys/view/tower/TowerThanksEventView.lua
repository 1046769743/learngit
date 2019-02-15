--[[
	Author: caocheng
	Date:2017-07-29
	Description: Npc选择结果之一，感谢
]]

local TowerThanksEventView = class("TowerThanksEventView",UIBase);

function TowerThanksEventView:ctor(winName,eventID)
    TowerThanksEventView.super.ctor(self,winName)
    self.eventID = eventID or {}
end

function TowerThanksEventView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initView()
	self:updateUI()
end 

function TowerThanksEventView:registerEvent()
	TowerThanksEventView.super.registerEvent(self);
	 self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close,self))
end

function TowerThanksEventView:initData()
	-- TODO
end

function TowerThanksEventView:initView()
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.press_btn_close,self))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_057")) 
	self.UI_1.mc_1.currentView.btn_1:getUpPanel().txt_1:setString(GameConfig.getLanguage("#tid_tower_ui_058"))
end

function TowerThanksEventView:updateUI()
	-- TODO
end

function TowerThanksEventView:deleteMe()
	-- TODO

	TowerThanksEventView.super.deleteMe(self);
end

function TowerThanksEventView:press_btn_close()
	self:startHide()
end

return TowerThanksEventView;
