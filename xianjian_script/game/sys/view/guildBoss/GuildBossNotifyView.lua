-- GuildBossNotifyView
--
--Author:      wk
--DateTime:    2018-01-24 14:26:31
--Description: 共闯秘境推送到主界面的推送



local GuildBossNotifyView = class("GuildBossNotifyView", UIBase);

function GuildBossNotifyView:ctor(winName)
    GuildBossNotifyView.super.ctor(self, winName)
end

function GuildBossNotifyView:loadUIComplete()
	self:registerEvent()
end 

function GuildBossNotifyView:registerEvent()
	GuildBossNotifyView.super.registerEvent(self);
	-- -- self.panel_1.btn_1:setTouchedFunc(c_func(self.close, self))
	-- self:registClickClose("out")
end

function GuildBossNotifyView:initData()
	local count = GuildBossModel:getInviteAddTeamList()
	self.txt_1:setString(table.length(count))
	-- self:setTouchedFunc(c_func(self.showBeInvitedView, self))
end

function GuildBossNotifyView:showBeInvitedView()
	WindowControler:showWindow("GuildBossBeInvitedView")
end

function GuildBossNotifyView:close()
	self:startHide()
end
function GuildBossNotifyView:deleteMe()
	GuildBossNotifyView.super.deleteMe(self);
end

return GuildBossNotifyView;
