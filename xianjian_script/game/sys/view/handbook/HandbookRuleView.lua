--[[
	Author: xd
	Date:2018-06-12
	Description: TODO
]]

local HandbookRuleView = class("HandbookRuleView", UIBase);

function HandbookRuleView:ctor(winName)
    HandbookRuleView.super.ctor(self, winName)
end

function HandbookRuleView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function HandbookRuleView:registerEvent()
	HandbookRuleView.super.registerEvent(self);
end

function HandbookRuleView:initData()
	-- TODO
end

function HandbookRuleView:initView()
	-- TODO
end

function HandbookRuleView:initViewAlign()
	-- TODO
end

function HandbookRuleView:updateUI()
	self.UI_1.txt_1:setString("玩法说明")
	self.UI_1.txt_1:visible(false)
	self.UI_1.panel_1:visible(false)
	self.UI_1.mc_1.currentView.btn_1:visible(false)
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))

	self.rich_1:setString(GameConfig.getLanguage("#tid_handbook_shuoming"))

	self:registClickClose("out")

end

function HandbookRuleView:deleteMe()
	-- TODO

	HandbookRuleView.super.deleteMe(self);
end

return HandbookRuleView;
