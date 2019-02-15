--[[
	Author: TODO
	Date:2018-09-04
	Description: TODO
]]

local ShareBossNoBossTipsView = class("ShareBossNoBossTipsView", UIBase);

function ShareBossNoBossTipsView:ctor(winName)
    ShareBossNoBossTipsView.super.ctor(self, winName)
end

function ShareBossNoBossTipsView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function ShareBossNoBossTipsView:registerEvent()
	ShareBossNoBossTipsView.super.registerEvent(self);

	self:registClickClose("out")

	
end

function ShareBossNoBossTipsView:joinOneGuild()
	if not GuildModel:closeGuildTime() then
		self:startHide()
		GuildControler:getAddGuildDataList(true)
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_023"))
	end
end

function ShareBossNoBossTipsView:jumpToFriendView()
	self:startHide()
	FriendViewControler:forceShowFriendList(nil,nil,2)
end

function ShareBossNoBossTipsView:initData()
	-- TODO
end

function ShareBossNoBossTipsView:initView()
	if GuildModel:isInGuild() then
		self.btn_jrxm:getUpPanel().txt_1:setString("添加好友")
		self.btn_jrxm:setTouchedFunc(c_func(self.jumpToFriendView, self))
	else
		self.btn_jrxm:getUpPanel().txt_1:setString("加入仙盟")
		self.btn_jrxm:setTouchedFunc(c_func(self.joinOneGuild, self))
	end
end

function ShareBossNoBossTipsView:initViewAlign()
	-- TODO
end

function ShareBossNoBossTipsView:updateUI()
	-- TODO
end

function ShareBossNoBossTipsView:deleteMe()
	-- TODO

	ShareBossNoBossTipsView.super.deleteMe(self);
end

return ShareBossNoBossTipsView;
