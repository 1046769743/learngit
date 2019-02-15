local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTopGoldView = class("CompResTopGoldView", ResTopBase);

--[[
    self.UI_comp_res_yuanbao,
    self.btn_xianyujiahao,
    self.txt_xianyu,
]]

function CompResTopGoldView:ctor(winName)
    CompResTopGoldView.super.ctor(self, winName);
end

function CompResTopGoldView:loadUIComplete()
	CompResTopGoldView.super.loadUIComplete(self)
	self:registerEvent();
	self:updatePreNum(UserModel:getGold())
	self:updateUI();
end 

function CompResTopGoldView:registerEvent()
	CompResTopGoldView.super.registerEvent();
    self.btn_xianyujiahao:setTap(c_func(self.press_btn_xianyujiahao, self));
	self._root:setTouchedFunc(c_func(self.onAddTap, self),nil,true)

	local _x = self.panel_icon_yuanbao:getPositionX()
	local _y = self.panel_icon_yuanbao:getPositionY()
	self.panel_icon_yuanbao:setPositionX(_x - 4)
	self.panel_icon_yuanbao:setPositionY(_y - 1)

    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.updateUI, self)
    --用于切换用户数据更新显示
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.updateUI, self)
end

function CompResTopGoldView:onAddTap()
	-- 临时打开
	-- WindowControler:showWindow("RechargeMainView")
	-- WindowControler:showTips("充值功能暂未开放")
	 -- WindowControler:showWindow("TempGotoRechargeView")
	 WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
end

function CompResTopGoldView:press_btn_xianyujiahao()
	self:onAddTap()
end

function CompResTopGoldView:updateUI(event)
	local current = UserModel:getGold()
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

function CompResTopGoldView:getNumChangeEffecCtn()
	return self.ctn_1
end

function CompResTopGoldView:getAnimTextNode()
	return self.txt_xianyu
end

function CompResTopGoldView:getIconAnimCtn()
	return self.ctn_2
end

function CompResTopGoldView:getIconNode()
	return self.panel_icon_yuanbao
end

function CompResTopGoldView:getIconAnimName()
	return "UI_common_icon_anim_yuanbao"
end


return CompResTopGoldView;
