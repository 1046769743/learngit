local ArenaRefreshCdView = class("ArenaRefreshCdView", UIBase)

function ArenaRefreshCdView:ctor(winName)
	ArenaRefreshCdView.super.ctor(self, winName)
end

function ArenaRefreshCdView:loadUIComplete()
	local PVPEVENT_RRFRESH_CD = "CD_ID_PVP_UP_LEVEL"
	self.panel_refresh_cd.btn_2:setTap(c_func(self.onClearCdPopBtnTap, self))
	-- self:updateUI()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime, self) ,0)
	EventControler:addEventListener(PVPEVENT_RRFRESH_CD, self.startHide, self)
	EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE, self.reachVipDemand, self)
end

function ArenaRefreshCdView:updateTime()
	local left = FuncPvp.getPvpCdLeftTime()

	local minute = math.floor(left / 60)
	local sec = left - minute * 60
	local timeStr = string.format("%02d:%02d", minute, sec)
	-- local str = GameConfig.getLanguageWithSwap("tid_pvp_1040", timeStr)
	self.panel_refresh_cd.txt_time:setString(timeStr)	
end

function ArenaRefreshCdView:onClearCdPopBtnTap()
	WindowControler:showWindow("ArenaClearChallengeCdPop")
end

function ArenaRefreshCdView:startHide()
	self.panel_refresh_cd:setVisible(false)
end

function ArenaRefreshCdView:reachVipDemand()
	if UserModel:vip() >= 6 then
		self:startHide()
	end
end

return ArenaRefreshCdView

