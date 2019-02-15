--[[
	Author: TODO
	Date:2017-10-31
	Description: TODO
]]

local WuLingDetailTips = class("WuLingDetailTips", UIBase);

function WuLingDetailTips:ctor(winName)
    WuLingDetailTips.super.ctor(self, winName)
end

function WuLingDetailTips:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuLingDetailTips:registerEvent()
	WuLingDetailTips.super.registerEvent(self);
	self:registClickClose(-1, c_func(self.press_btn_close,self))
end

function WuLingDetailTips:initData()
	-- TODO
end

function WuLingDetailTips:initView()
	self.panel_gxx.txt_1:setString(GameConfig.getLanguage("#tid_fivesoul_tips_66"))
	self.panel_gxx:pos(220, -280)
end

function WuLingDetailTips:initViewAlign()
	-- TODO
end

function WuLingDetailTips:updateUI()
	-- TODO
end

function WuLingDetailTips:press_btn_close()
	self:startHide()
end

function WuLingDetailTips:deleteMe()
	-- TODO

	WuLingDetailTips.super.deleteMe(self);
end

return WuLingDetailTips;
