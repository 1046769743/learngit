--
-- Author: xd
-- Date: 2018-07-17 17:53:54
-- 大型建筑instance
local ExploreBuildInstance = class("ExploreBuildInstance", ExploreBaseInstance)



function ExploreBuildInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 5,height =FuncGuildExplore.gridHeight *8}
	self._initDepthHeight = -800;
	self.depthHeigt = self._initDepthHeight;
	self:realPos()
end

return ExploreBuildInstance