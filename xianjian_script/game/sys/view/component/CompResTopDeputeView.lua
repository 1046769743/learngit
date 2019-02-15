
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopDeputeView = class("CompResTopDeputeView", ResTopBase);

function CompResTopDeputeView:ctor(winName)
    CompResTopDeputeView.super.ctor(self, winName);

end

function CompResTopDeputeView:loadUIComplete()
	self:registerEvent()
    self:updateUI()

    -- self.btn_xianyujiahao:setTouchedFunc(c_func(self.clickGetWay, self));
end 

function CompResTopDeputeView:updateUI()
	local num = UserModel:getDeputeCoin( )
    self.txt_xianyu:setString(num);
end

function CompResTopDeputeView:registerEvent()
    EventControler:addEventListener(UserEvent.USEREVENT_DEPUTE_POINT_CHANGE, self.updateUI, self)
end

function CompResTopDeputeView:clickGetWay()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.XIANFU);
end


return CompResTopDeputeView





