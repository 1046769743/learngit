
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompGarmentResView = class("CompGarmentResView", ResTopBase);

function CompGarmentResView:ctor(winName)
    CompGarmentResView.super.ctor(self, winName);

end

function CompGarmentResView:loadUIComplete()
	self:registerEvent()
    self:updateUI()

    self.btn_xianyujiahao:setTouchedFunc(c_func(self.clickGetWay, self));
end 

function CompGarmentResView:updateUI()
    self.txt_xianyu:setString(UserModel:getSkinCoin());
end

function CompGarmentResView:registerEvent()
    EventControler:addEventListener(UserEvent.USEREVENT_PARTNER_SKINCOIN_CHANGE, self.updateUI, self)
end

function CompGarmentResView:clickGetWay()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.SKINCOIN);
end


return CompGarmentResView





