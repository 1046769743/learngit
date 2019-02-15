-- Author: ZhangYanguang
-- Date: 2017-01-13
-- 主角天赋点
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompResTalentPointView = class("CompResTalentPointView", ResTopBase);

function CompResTalentPointView:ctor(winName)
    CompResTalentPointView.super.ctor(self, winName);
end

function CompResTalentPointView:loadUIComplete()
	self:registerEvent()

	self.btn_tianfujiahao:setVisible(false)
	self:updateUI()
end 

function CompResTalentPointView:registerEvent()
	EventControler:addEventListener(UserEvent.USEREVENT_TALENT_POINT_CHANGE, self.updateUI, self)
end

function CompResTalentPointView:updateUI()
	self.txt_tianfu:setString(UserModel:getTalentPoint())
end

return CompResTalentPointView