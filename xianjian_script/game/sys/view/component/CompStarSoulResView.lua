
local ResTopBase = require("game.sys.view.component.CompResTopBase")
local CompStarSoulResView = class("CompStarSoulResView", ResTopBase);

function CompStarSoulResView:ctor(winName)
    CompStarSoulResView.super.ctor(self, winName);

end

function CompStarSoulResView:loadUIComplete()
	self:registerEvent()
    self:updateUI()
end 
function CompStarSoulResView:updateUI()
    --隐藏加号按钮
    self.btn_tilijiahao:visible(false)
    --星辰数量
    self.txt_xinghun:setString(self:getDisplayNumStr(UserModel:getStarDirt()))
end

function CompStarSoulResView:registerEvent()
    
end



return CompStarSoulResView
