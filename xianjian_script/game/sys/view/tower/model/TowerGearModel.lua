--
--Author:      zhuguangyuan
--DateTime:    2018-03-09 14:41:40
--Description: 开格子机关事件类,在打开格子后就响应的事件模型
-- 1.三测只有聚灵格子,后续可扩展


local TowerBasicModel = require("game.sys.view.tower.model.TowerBasicModel")
TowerGearModel = class("TowerGearModel",TowerBasicModel)

function TowerGearModel:ctor( controler,gridModel )
 	TowerGearModel.super.ctor(self,controler)
 	self.grid = gridModel
end

-- 设置格子信息
function TowerGearModel:setGrid(grid)
	self.grid = grid
	self.gridStatus = self.grid:getGridStatus()
	self.gridInfo = TowerMapModel:getGridInfo(self.grid.xIdx,self.grid.yIdx)
end

-- 设置机关id
function TowerGearModel:setGearId(gearId)
	self.gearId = tostring(gearId)
end

-- 设置机关类型,三测只有聚灵格子类型
function TowerGearModel:setGearType(gearType)
	self.gearType = tostring(gearType)
end

function TowerGearModel:onAfterOpenGrid()

end

function TowerGearModel:deleteMe()
	TowerGearModel.super.deleteMe(self)
end

return TowerGearModel
