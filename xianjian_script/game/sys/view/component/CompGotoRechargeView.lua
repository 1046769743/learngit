local CompGotoRechargeView = class("CompGotoRechargeView", UIBase)

function CompGotoRechargeView:ctor(winName)
	CompGotoRechargeView.super.ctor(self, winName)
end

function CompGotoRechargeView:loadUIComplete()
	self.UI_1.mc_1:showFrame(2)
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2010"))
	self.txt_1:setString(GameConfig.getLanguage("tid_common_2011"))
	self:registerEvent()
end

function CompGotoRechargeView:registerEvent()
	local contentView = self.UI_1.mc_1.currentView
	contentView.btn_1:setTap(c_func(self.gotoRecharge, self))
	contentView.btn_2:setTap(c_func(self.close, self))
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self:registClickClose("out")
end

function CompGotoRechargeView:close()
	self:startHide()
end

function CompGotoRechargeView:setTitle(str)
	self.UI_1.txt_1:setString(str);
end

function CompGotoRechargeView:setContentStr(str)
	self.txt_1:setString(str);
end

function CompGotoRechargeView:gotoRecharge()
	WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
	self:close()
end

return CompGotoRechargeView




