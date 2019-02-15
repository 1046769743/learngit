--
--Author:      zhuguangyuan
--DateTime:    2018-01-24 14:26:31
--Description: 仙盟副本规则界面
--


local GuildBossRuleView = class("GuildBossRuleView", UIBase);

function GuildBossRuleView:ctor(winName)
    GuildBossRuleView.super.ctor(self, winName)
end

function GuildBossRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildBossRuleView:registerEvent()
	GuildBossRuleView.super.registerEvent(self);
	self.UI_diban.btn_1:setTouchedFunc(c_func(self.close, self))
	self:registClickClose("out")
end

function GuildBossRuleView:initData()
	-- TODO
end

function GuildBossRuleView:initView()
	local viewName = "规则"
	self.UI_diban.txt_1:setString(viewName)

	local content = GameConfig.getLanguage("#tid_unionlevel_rule_1")
	self.txt_1:setString(content)
end

function GuildBossRuleView:initViewAlign()
	-- TODO
end

function GuildBossRuleView:updateUI()
	-- TODO
end

function GuildBossRuleView:close( ... )
	self:startHide()
end
function GuildBossRuleView:deleteMe()
	GuildBossRuleView.super.deleteMe(self);
end

return GuildBossRuleView;
