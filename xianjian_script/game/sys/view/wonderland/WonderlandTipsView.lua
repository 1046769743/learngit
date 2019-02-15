-- WonderlandTipsView


local WonderlandTipsView = class("WonderlandTipsView", UIBase);

--[[
	local newdata = {
        _type = self.checkpoint_type,
        itemData = itemData,
    }
]]
function WonderlandTipsView:ctor(winName,data)
    WonderlandTipsView.super.ctor(self, winName);

    dump(data,"skill data = = ========")
    self.data = data
end

function WonderlandTipsView:loadUIComplete()
    self:registerEvent();
    self:updateUI();
end 

function WonderlandTipsView:registerEvent()
    WonderlandTipsView.super.registerEvent();
    EventControler:addEventListener(WonderlandEvent.SKILLTIPS_BACK_UI,self.clickButtonBack,self)
    self:registClickClose("out")
end

function WonderlandTipsView:updateUI()
	local _type = self.data._type or 1
	local floor = self.data.floor or 1
	local skilltab = FuncWonderland.getSkillTipsByfloor(_type,floor)
	local string = skilltab[self.data.itemData.id]
	self.panel_1.rich_4:setString(GameConfig.getLanguage(string))
end

function WonderlandTipsView:clickButtonBack()
	self:startHide()
end




return WonderlandTipsView;
