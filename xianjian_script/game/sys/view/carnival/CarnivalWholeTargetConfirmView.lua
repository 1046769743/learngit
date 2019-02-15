--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 10:22:48
--Description: 开服嘉年华 - 全目标奖励界面 - 确定领取奖励
--


local CarnivalWholeTargetConfirmView = class("CarnivalWholeTargetConfirmView", UIBase);

function CarnivalWholeTargetConfirmView:ctor(winName)
    CarnivalWholeTargetConfirmView.super.ctor(self, winName)
end

function CarnivalWholeTargetConfirmView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function CarnivalWholeTargetConfirmView:registerEvent()
	CarnivalWholeTargetConfirmView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.onClose, self)) 
end

function CarnivalWholeTargetConfirmView:initData()
	-- TODO
end

function CarnivalWholeTargetConfirmView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_jianianhua_002"))
	self.panel_1:setVisible(false)
end

function CarnivalWholeTargetConfirmView:initViewAlign()
	-- TODO
end

function CarnivalWholeTargetConfirmView:updateUI()
	self.UI_1.mc_1:showFrame(2)
	local currentView = self.UI_1.mc_1.currentView
	currentView.btn_1:setTap(c_func(self.onConfirm, self)) 
	currentView.btn_2:setTap(c_func(self.onCancel, self)) 
end
function CarnivalWholeTargetConfirmView:onConfirm()
	echo("\n\n -----领取全目标奖励")
	CarnivalModel:getWholeTargetReward()
	self:onClose()
end
function CarnivalWholeTargetConfirmView:onCancel()
	echo("\n\n -----取消 领取全目标奖励")
	self:onClose()
end


function CarnivalWholeTargetConfirmView:onClose()
	self:startHide()
end
function CarnivalWholeTargetConfirmView:deleteMe()
	-- TODO

	CarnivalWholeTargetConfirmView.super.deleteMe(self);
end

return CarnivalWholeTargetConfirmView;
