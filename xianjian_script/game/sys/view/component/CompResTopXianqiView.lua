local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopXianqiView = class("CompResTopXianqiView", ResTopBase);

function CompResTopXianqiView:ctor(winName)
    CompResTopXianqiView.super.ctor(self, winName);
end

function CompResTopXianqiView:loadUIComplete()
	CompResTopXianqiView.super.loadUIComplete(self)
	self:registerEvent()
	self:updateUI()
end 

function CompResTopXianqiView:registerEvent()
	CompResTopXianqiView.super.registerEvent(self);
	self.btn_xianyujiahao:setTap(c_func(self.clickAdd,self))
	EventControler:addEventListener(UserEvent.USEREVENT_CROSSPEAKCOIN_CHANGE, self.updateUI, self)
end

function CompResTopXianqiView:updateUI()
	local haveXianqi = UserModel:getCrossPeakCoin()
	self.txt_xianyu:setString(haveXianqi)
end

function CompResTopXianqiView:clickAdd( ... )
	WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_040"))
end


return CompResTopXianqiView;
