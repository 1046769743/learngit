
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopLingYuanView = class("CompResTopLingYuanView", ResTopBase);

function CompResTopLingYuanView:ctor(winName)
    CompResTopLingYuanView.super.ctor(self, winName);

end

function CompResTopLingYuanView:loadUIComplete()
	self:registerEvent()
    self:updateUI()

    self.btn_xianyujiahao:setTouchedFunc(c_func(self.clickGetWay, self));
end 

function CompResTopLingYuanView:updateUI()
	local num = UserModel:getWonderLandCoin()
    self.txt_xianyu:setString(num);
end

function CompResTopLingYuanView:registerEvent()
    EventControler:addEventListener(UserEvent.USEREVENT_XIANFU_CHANGE, self.updateUI, self)
end

function CompResTopLingYuanView:clickGetWay()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.XIANFU);
end


return CompResTopLingYuanView





