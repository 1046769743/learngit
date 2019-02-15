--[[
	Author: TODO
	Date:2018-06-26
	Description: TODO
]]
local GohomeChongZhiBase = require("game.sys.view.component.CompChongZhiShowUI")
local WelfareChongZhiView = class("WelfareChongZhiView", GohomeChongZhiBase);

function WelfareChongZhiView:showChongZhiTips()
	if not self.coverLayer then
		self.coverLayer = WindowControler:createCoverLayer(nil, nil, cc.c4b(0,0,0,0), true):addto(self._root, 0)
		self.coverLayer:pos(-GameVars.UIOffsetX,  GameVars.UIOffsetY + 68)
		self.coverLayer:setTouchedFunc(c_func(self.needHideChongZhiTips, self))
		self.coverLayer:setTouchSwallowEnabled(false)
	else
		self.coverLayer:setVisible(true)
	end
	
	self.panel_tips:fadeIn(0.2)
end

--前往充值
function WelfareChongZhiView:travelToChongZhi()
	-- echo("========前往充值========")
	WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
end

return WelfareChongZhiView;
