-- ArtifactRuleView.lua
-- Author: Wk
-- Date: 2017-07-22
-- 神器规则界面   --废弃
local ArtifactRuleView = class("ArtifactRuleView", UIBase);

function ArtifactRuleView:ctor(winName)
    ArtifactRuleView.super.ctor(self, winName);
end

function ArtifactRuleView:loadUIComplete()
	self:registClickClose("out")
	self.UI_diban.txt_1:setString(GameConfig.getLanguage("#tid_shenqi_013"))
	self.UI_diban.btn_1:setTouchedFunc(c_func(self.press_btn_close, self,itemData),nil,true);
	self:initData()
end 

function ArtifactRuleView:registerEvent()
	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function ArtifactRuleView:initData()

end


function ArtifactRuleView:press_btn_close()
	
	self:startHide()
end


return ArtifactRuleView;
