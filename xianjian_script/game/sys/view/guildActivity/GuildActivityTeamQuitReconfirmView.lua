--
--Author:      zhuguangyuan
--DateTime:    2018-01-09 18:28:48
--Description: 退出队伍二次确认界面
--


local GuildActivityTeamQuitReconfirmView = class("GuildActivityTeamQuitReconfirmView", UIBase);

function GuildActivityTeamQuitReconfirmView:ctor(winName,_viewType,_params)
    GuildActivityTeamQuitReconfirmView.super.ctor(self, winName)
    self.viewType = _viewType
    self.params = _params
end

function GuildActivityTeamQuitReconfirmView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildActivityTeamQuitReconfirmView:registerEvent()
	GuildActivityTeamQuitReconfirmView.super.registerEvent(self);
end

function GuildActivityTeamQuitReconfirmView:initData()
	-- TODO
end

function GuildActivityTeamQuitReconfirmView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_081")) 
	self.UI_1.btn_close:setTap(c_func(self.onClose,self))
	self.UI_1.mc_1:showFrame(2)
	self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.onClose,self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.confirmQuitTeam,self))
	-- 退队/退出挑战
	if self.viewType == FuncGuildActivity.tipViewType.quitTeam then
		self.txt_1:setString(GameConfig.getLanguage("#tid_guild_082"))
	elseif self.viewType == FuncGuildActivity.tipViewType.quitChallenge then
		self.txt_1:setString(GameConfig.getLanguage("#tid_guild_083"))
	end
end

-- 确认退出队伍
function GuildActivityTeamQuitReconfirmView:confirmQuitTeam()
	EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_CONFIRM,{} )
	self:startHide()
end

function GuildActivityTeamQuitReconfirmView:initViewAlign()
	-- TODO
end

function GuildActivityTeamQuitReconfirmView:updateUI()
	-- TODO
end

function GuildActivityTeamQuitReconfirmView:onClose()
	self:startHide()
end

function GuildActivityTeamQuitReconfirmView:deleteMe()
	-- TODO

	GuildActivityTeamQuitReconfirmView.super.deleteMe(self);
end

return GuildActivityTeamQuitReconfirmView;
