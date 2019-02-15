--
-- Author: xd
-- Date: 2018-07-03 11:58:15
--资源道具类的model
local ExploreResInstance = class("ExploreResInstance", ExploreBaseInstance)
function ExploreResInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 2,height =FuncGuildExplore.gridHeight *2}
end
return ExploreResInstance

