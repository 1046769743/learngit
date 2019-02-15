--[[
	Author: ZhangYanguang
	Date:2018-03-14
	Description: 通知权限界面
]]

local PushPermissionView = class("PushPermissionView", UIBase);

function PushPermissionView:ctor(winName)
    PushPermissionView.super.ctor(self, winName)
end

function PushPermissionView:loadUIComplete()
	-- "通知推送"
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_013"))

	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.startHide,self))
end

return PushPermissionView