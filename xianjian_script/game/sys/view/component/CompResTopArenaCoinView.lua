local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopArenaCoinView = class("CompResTopArenaCoinView", ResTopBase)
function CompResTopArenaCoinView:ctor(winName)
	CompResTopArenaCoinView.super.ctor(self, winName)
end

function CompResTopArenaCoinView:loadUIComplete()
	CompResTopArenaCoinView.super.loadUIComplete(self)
	self:updatePreNum(UserModel:getArenaCoin())
	self:registerEvent()
	self:updateUI()
end

function CompResTopArenaCoinView:getAnimTextNode()
	return self.txt_xianyu
end

function CompResTopArenaCoinView:getNumChangeEffecCtn()
	return self.ctn_1
end

function CompResTopArenaCoinView:updateUI()
	
	local current = UserModel:getArenaCoin()

	local preNum = self:getPreNum()
	if preNum < current then
		if not self:isManualUpdateNum() then
			self:playNumChangeEffect(preNum, current)
		end
	else
		self.txt_xianyu:setString(self:getDisplayNumStr(current))
		self:updatePreNum(current)
	end
end

function CompResTopArenaCoinView:registerEvent()
	self.btn_xianyujiahao:setTap(c_func(self.onAddTap, self))
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CompResTopArenaCoinView:onAddTap()
	WindowControler:showWindow("GetWayListView", FuncDataResource.RES_TYPE.ARENACOIN)
end

function CompResTopArenaCoinView:close()
	self:startHide()
end

return CompResTopArenaCoinView
