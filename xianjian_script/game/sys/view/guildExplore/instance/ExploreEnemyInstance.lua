--
-- Author: xd
-- Date: 2018-07-03 11:57:01
-- 探索怪物model
local ExploreEnemyInstance = class("ExploreEnemyInstance", ExploreBaseInstance)

function ExploreEnemyInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth * 2,height =FuncGuildExplore.gridHeight *4}
end

--当数据发生变化
function ExploreEnemyInstance:onDataChange( changeData )
	if not self.myView then
		return
	end
	if self._data.type == FuncGuildExplore.gridTypeMap.elite then
		local percent = self._data.params.levelHpPercent or 10000
		self.myView.panel_xuetiao.progress_1:setPercent(math.floor(percent/100) )

	end
	

end

return ExploreEnemyInstance