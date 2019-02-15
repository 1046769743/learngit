--三皇抽奖系统
--2016-1-10 15:43
--@Author:wukai
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompSanhuangcoinview = class("CompSanhuangcoinview", ResTopBase)
function CompSanhuangcoinview:ctor(winName)
	CompSanhuangcoinview.super.ctor(self, winName)
end


function CompSanhuangcoinview:loadUIComplete()
	CompSanhuangcoinview.super.loadUIComplete(self)
	self.btn_lingshijiahao:setTap(c_func(self.getpathview,self))
	self._root:setTouchedFunc(c_func(self.goToSpiritStonesShop, self))
	-- self.panel_icon_sanhuang:setScale(0.6)
	-- self.panel_icon_sanhuang:setPositionY(self.panel_icon_sanhuang:getPositionY()+10)
	self:registerEvent();
	self:setupdataUI()

end
function CompSanhuangcoinview:registerEvent()

	-- EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.setupdataUI, self)
	-- EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.setupdataUI, self)
	EventControler:addEventListener(WelfareEvent.LINGSHICLEARE_EVENT, self.setupdataUI, self)
	EventControler:addEventListener(UserEvent.USEREVENT_CHANGE_SPIRITSTONES, self.setupdataUI, self)
	
end
function CompSanhuangcoinview:setupdataUI()
	
	local number = UserModel:getGoldConsumeCoin()
	if number == nil then
		number = 0
	end
	self.txt_lingshi:setString(number)

end
function CompSanhuangcoinview:getpathview()
	-- echo("获取三皇造物符的路径")
	-- WindowControler:showTips("获取途径暂未开启")
	WindowControler:showWindow("GetWayListView",FuncDataResource.RES_TYPE.LINGSHI)

end

function CompSanhuangcoinview:goToSpiritStonesShop()
	if WindowControler:checkHasWindow("WelfareNewMinView") then
	else
		WindowControler:showWindow("WelfareNewMinView","lingshishangdian") --FuncWelfare.WELFARE_TYPE.REBATE)
	end
end


return CompSanhuangcoinview




