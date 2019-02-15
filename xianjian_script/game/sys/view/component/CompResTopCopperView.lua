local CompResTopCopperView = class("CompResTopCopperView", UIBase);

--[[
    self.UI_comp_res_chitong,
    self.btn_xianyujiahao,
    self.txt_xianyu,
]]

function CompResTopCopperView:ctor(winName)
    CompResTopCopperView.super.ctor(self, winName);
end

function CompResTopCopperView:loadUIComplete()
	self:registerEvent();

	self:updateUI()
end 

function CompResTopCopperView:registerEvent()
	CompResTopCopperView.super.registerEvent();
    self.btn_xianyujiahao:setTap(c_func(self.press_btn_xianyujiahao, self));
	self._root:setTouchedFunc(c_func(self.onAddTap, self))
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.updateUI, self)
end

function CompResTopCopperView:onAddTap()
	WindowControler:showTips(GameConfig.getLanguage("tid_common_2030"))
end

function CompResTopCopperView:press_btn_xianyujiahao()
	self:onAddTap()
end


function CompResTopCopperView:updateUI()
	self.txt_xianyu:setString(UserModel:getToken())
end


return CompResTopCopperView;
