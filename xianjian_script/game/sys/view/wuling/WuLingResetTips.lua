--[[
	Author: TODO
	Date:2017-10-31
	Description: TODO
]]

local WuLingResetTips = class("WuLingResetTips", UIBase);

function WuLingResetTips:ctor(winName)
    WuLingResetTips.super.ctor(self, winName)
end

function WuLingResetTips:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuLingResetTips:registerEvent()
	WuLingResetTips.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTouchedFunc(c_func(self.clickClose,self,nil,true))
end

function WuLingResetTips:initData()
	-- TODO
end

function WuLingResetTips:initView()
	local tempTime = UserExtModel:fiveSoulResetTimes()
	local tempExpend = FuncDataSetting.getResetExpend(tempTime)
	self.txt_2:setString(tempExpend..GameConfig.getLanguage("#tid_wuling_001"))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_wuling_002"))
	self.UI_1.mc_1.currentView.btn_1:setTouchedFunc(c_func(self.useReset,self))
end

function WuLingResetTips:initViewAlign()
	-- TODO
end

function WuLingResetTips:updateUI()
	-- TODO
end

function WuLingResetTips:clickClose()
	self:startHide()
end

function WuLingResetTips:useReset()
	local params = {}
	WuLingServer:resetWuLing(params,c_func(self.useResetEffect,self))
end

function WuLingResetTips:useResetEffect(event)
	if event.error then

	else 
		EventControler:dispatchEvent(WuLingEvent.WULINGEVENT_MAINVIEW_CHANGE)
		self:startHide()
	end	
end

function WuLingResetTips:deleteMe()
	-- TODO

	WuLingResetTips.super.deleteMe(self);
end

return WuLingResetTips;
