--
-- Author: xd
-- Date: 2016-02-19 15:57:21
--
local BackGroundBase = class("DynamicBgView2", UIBase);

--背景加载完成以后 需要动态适配 背景 宽度 
function BackGroundBase:loadUIComplete()
	--动态计算scaleX
	local scaleX = GameVars.width / GameVars.gameResWidth
	local scaleY = GameVars.height / GameVars.gameResHeight
	--x偏移
	local offsetX = -(GameVars.width - GameVars.gameResWidth )/2

	--y偏移
	local offsetY = (GameVars.height - GameVars.gameResHeight )/2

	local upView = self.panel_1


	--先偏移上面
	--offsetView(upView,offsetX,offsetY)
	self._root:setScaleX(scaleX)
	self._root:setScaleY(scaleY)
	self._root:pos(offsetX,offsetY)


end
return BackGroundBase