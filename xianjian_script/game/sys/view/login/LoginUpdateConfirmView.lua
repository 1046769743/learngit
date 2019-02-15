--[[
	Author: 张燕广
	Date:2017-11-30
	Description: 热更确认窗口
]]

local LoginUpdateConfirmView = class("LoginUpdateConfirmView", UIBase)


function LoginUpdateConfirmView:ctor(winName, fileSize)
	LoginUpdateConfirmView.super.ctor(self, winName)
	-- 单位是B
	self.fileSize = fileSize or 100
end

function LoginUpdateConfirmView:loadUIComplete()
	self:registerEvent()
	-- 隐藏关闭按钮
	self.panel_bao.UI_1.btn_close:setVisible(false)

	self.panel_bao.UI_1.txt_1:setString(GameConfig.getLanguage("tid_login_1062")) 

	local totalStr = self:getDisplaySize(self.fileSize)
	self.content = GameConfig.getLanguage("tid_login_1063")
	self.content = string.format(self.content,totalStr)

	self.panel_bao.txt_1:setString(self.content)
end

function LoginUpdateConfirmView:getDisplaySize(byteSize)
	local kbSize = byteSize / 1024

	local displaySizeStr = ""
	-- 大于1MB
	if kbSize >= 1024 then
		displaySizeStr = string.format("%.2f",tostring(kbSize / 1024)) .. "MB"
	else
		displaySizeStr = string.format("%.2f",tostring(kbSize)) .. "KB"
	end

	return displaySizeStr
end

function LoginUpdateConfirmView:registerEvent()
	self.panel_bao.UI_1.mc_1:showFrame(1)
	self.panel_bao.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.onConfirmUpdate,self))
	-- self.panel_bao.UI_1.btn_close:setTouchedFunc(c_func(self.onClose,self))
end

function LoginUpdateConfirmView:onConfirmUpdate()
	echo("确认更新")
	EventControler:dispatchEvent(VersionEvent.VERSIONEVENT_UPDATE_STAR)
	self:startHide()
end

return LoginUpdateConfirmView