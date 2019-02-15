
-- Author: xd
-- Date: 2018-07-17 17:53:54
-- 泉水model
local ExploreSpringInstance = class("ExploreSpringInstance", ExploreBaseInstance)

function ExploreSpringInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 1,height =FuncGuildExplore.gridHeight *3}
end
return ExploreSpringInstance