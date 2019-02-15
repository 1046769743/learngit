--[[
	Author: TODO
	Date:2018-08-10
	Description: TODO
]]

local WuXingBattleConfirmView = class("WuXingBattleConfirmView", UIBase);

function WuXingBattleConfirmView:ctor(winName, params, tipStr)
    WuXingBattleConfirmView.super.ctor(self, winName)
    self.params = params
    self.tipStr = tipStr
end

function WuXingBattleConfirmView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function WuXingBattleConfirmView:registerEvent()
	WuXingBattleConfirmView.super.registerEvent(self);

	self.btn_2:setTouchedFunc(c_func(self.clickConfirmButton, self))
	self.btn_1:setTouchedFunc(c_func(self.startHide, self))
	self.UI_1.btn_close:setTouchedFunc(c_func(self.startHide, self))
	self:registClickClose("out")
end

function WuXingBattleConfirmView:clickConfirmButton()
	EventControler:dispatchEvent(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.params)         
    TeamFormationModel:saveLocalData()
	self:startHide()
end

function WuXingBattleConfirmView:initData()
	-- TODO
end

function WuXingBattleConfirmView:initView()
	self.UI_1.mc_1:setVisible(false)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_team_tips_015"))
	self.txt_1:setString(self.tipStr)
end

function WuXingBattleConfirmView:initViewAlign()
	-- TODO
end

function WuXingBattleConfirmView:updateUI()
	-- TODO
end

function WuXingBattleConfirmView:deleteMe()
	-- TODO

	WuXingBattleConfirmView.super.deleteMe(self);
end

return WuXingBattleConfirmView;
