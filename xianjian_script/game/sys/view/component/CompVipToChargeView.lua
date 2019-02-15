local CompVipToChargeView = class("CompVipToChargeView", UIBase)

function CompVipToChargeView:ctor(winName, params)
	CompVipToChargeView.super.ctor(self, winName)
	self.tip = params.tip or ""
	self.btnStr = params.btnStr or GameConfig.getLanguage("tid_common_2007") 
	self.title = params.title or GameConfig.getLanguage("tid_common_2032")  
end

function CompVipToChargeView:loadUIComplete()
	self.txt_1:setString(self.tip)
	self.UI_1.txt_1:setString(self.title)

	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	local okBtn = self.UI_1.mc_1.currentView.btn_1
	okBtn:setTap(c_func(self.onOkTap, self))
end

function CompVipToChargeView:onOkTap()
	--TODO 此处应该跳往充值界面
	WindowControler:showTips(GameConfig.getLanguage("tid_common_2031"))
	self:startHide()
end

function CompVipToChargeView:close()
	self:startHide()
end

return CompVipToChargeView

