local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopCoinView = class("CompResTopCoinView", ResTopBase);

--[[
    self.UI_comp_res_tongqian,
    self.btn_lingshijiahao,
    self.txt_lingshi,
]]

function CompResTopCoinView:ctor(winName)
    CompResTopCoinView.super.ctor(self, winName);
end

function CompResTopCoinView:loadUIComplete()
	CompResTopCoinView.super.loadUIComplete(self)
	self:registerEvent();
	self:updatePreNum(UserModel:getCoin())
	self:updateUI()
end 

function CompResTopCoinView:registerEvent()
	CompResTopCoinView.super.registerEvent();
    self.btn_lingshijiahao:setTap(c_func(self.press_btn_lingshijiahao, self));
	self._root:setTouchedFunc(c_func(self.onAddTap, self), nil, true)

    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
    --用于切换用户数据更新显示
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.updateUI, self)
end

function CompResTopCoinView:onAddTap()
	-- local _ui=WindowControler:showWindow("CompBuyCoinMainView")
	-- _ui:buyCoin()
	-- FuncCommUI.showCoinGetView()
	FuncCommUI.showCoinGetView()

end

function CompResTopCoinView:press_btn_lingshijiahao()
	self:onAddTap()
end

function CompResTopCoinView:getAnimTextNode()
	return self.txt_lingshi
end

function CompResTopCoinView:getNumChangeEffecCtn()
	return self.ctn_1
end

function CompResTopCoinView:getIconAnimCtn()
	return self.ctn_2
end

function CompResTopCoinView:getIconNode()
	return self.panel_icon_tongqian
end

function CompResTopCoinView:getIconAnimName()
	return "UI_common_icon_anim_tongqian"
end

function CompResTopCoinView:updateUI(event)
	local current = UserModel:getCoin()
	local preNum = self:getPreNum()
	if preNum < current then
		if not self:isManualUpdateNum() then
			self:playNumChangeEffect(preNum, current)
		end
	else
		self.txt_lingshi:setString(self:getDisplayNumStr(current))
		self:updatePreNum(current)
	end
end


return CompResTopCoinView;
