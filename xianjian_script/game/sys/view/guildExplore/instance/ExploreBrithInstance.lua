--
-- Author: xd
-- Date: 2018-07-03 11:58:15
--出生点 实力
local ExploreBrithInstance = class("ExploreResInstance", ExploreBaseInstance)
function ExploreBrithInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 2,height =FuncGuildExplore.gridHeight *2}
end

--设置出生点
function ExploreBrithInstance:setBirthPoint( gridX,gridY,index )
	self.birthIndex = index
	self:setGridPos(gridX, gridY)

	local downPanel = display.newSprite():parent(self.controler.mapControler.a22,1)
	self.controler.mapControler:setTerrainTexture("panel_explore_img_pingtai", downPanel,true )
	downPanel:pos(self.pos.x,self.pos.y)
	local upPanel
	if index == 2 then
		upPanel = display.newSprite():parent(self.controler.mapControler.a22,1)
		self.controler.mapControler:setTerrainTexture("panel_explore_img_pingtaiB", upPanel,true )
		upPanel:pos(self.pos.x,self.pos.y)
		self.myView = upPanel
	end
	self:realPos()
end

return ExploreBrithInstance

