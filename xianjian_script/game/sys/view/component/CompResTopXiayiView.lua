local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopXiayiView = class("CompResTopXiayiView", ResTopBase)
function CompResTopXiayiView:ctor(winName)
	CompResTopXiayiView.super.ctor(self, winName)
end

function CompResTopXiayiView:loadUIComplete()
	CompResTopXiayiView.super.loadUIComplete(self)
	self:updatePreNum(UserModel:getRescueCoin())
	self:registerEvent()
	self:updateUI()
end

function CompResTopXiayiView:updateUI()
	local current = UserModel:getRescueCoin()
	-- local preNum = self:getPreNum()
	-- if preNum < current then
	-- 	if not self:isManualUpdateNum() then
	-- 		self:playNumChangeEffect(preNum, current)
	-- 	end
	-- else
	if current == nil then
		current = 0
	end
	self.txt_xianyu:setString(current)
	-- 	self:updatePreNum(current)
	-- end
end

function CompResTopXiayiView:registerEvent()
	self.btn_xianyujiahao:setTap(c_func(self.onAddTap, self))
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CompResTopXiayiView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.CHIVALROUS)
end
function CompResTopXiayiView:close()
	self:startHide()
end

return CompResTopXiayiView
