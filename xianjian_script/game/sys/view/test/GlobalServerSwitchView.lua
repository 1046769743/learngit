local GlobalServerSwitchView = class("GlobalServerSwitchView", UIBase)
function GlobalServerSwitchView:ctor(winName)
	GlobalServerSwitchView.super.ctor(self, winName)
end

function GlobalServerSwitchView:loadUIComplete()
	self:registerEvent()
	self.panel_1:visible(false)
	self:showServers()
end

function GlobalServerSwitchView:showServers()
	local httpAddrs = ServiceData.vmsURLGroup
	local createFunc = function(info)
		local panel = UIBaseDef:cloneOneView(self.panel_1)
		self:initPanel(panel, info)
		return panel
	end
	local params = {
		{
			data = httpAddrs,
			createFunc = createFunc,
			perNums = 1,
			offsetX = 0,
			offsetY = 0,
			widthGap = 0,
			heightGap = 10,
			itemRect = {x=0,y= -66,width = 523,height = 66},
			perFrame=1
		}
	}
	self.scroll_1:styleFill(params)
	self.scroll_1:easeMoveto(0,0,0)
end

function GlobalServerSwitchView:initPanel(panel, info)
	local str = string.format("[%s] %s", info.name, info.ip)
	panel.txt_1:setString(str)
	panel.btn_ok:setTap(c_func(self.onSwitchTap, self, info))
end

function GlobalServerSwitchView:onSwitchTap(info)
	local version = AppInformation:getVersion()

	if device.platform == "windows" or device.platform == "mac" then
	-- if device.platform == "windows" then
		WindowControler:showTips("Windows/Mac平台不支持VMS切换")
	else
		AppInformation:setVmsURL(info.ip)
	end

	self:startHide()
end

function GlobalServerSwitchView:registerEvent()
	self:registClickClose("out")
end

function GlobalServerSwitchView:close()
	self:startHide()
end

return GlobalServerSwitchView
