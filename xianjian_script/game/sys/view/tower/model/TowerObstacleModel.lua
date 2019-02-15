--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔障碍物事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerObstacleModel = class("TowerObstacleModel",TowerEventModel)

function TowerObstacleModel:ctor(controler,gridModel)
	TowerObstacleModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerObstacleModel:initData()
	-- 障碍物类型
	self.OBSTRACLE_TYPE = {
		-- 普通坑
		KENG = 1,
		-- 石牌
		MUPAI = 2
	}

	local gridInfo = self.grid:getGridInfo()
	local obstracleId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	self:setEventId(obstracleId)
end

function TowerObstacleModel:onEventResponse()
	if self.obstracleData.type == self.OBSTRACLE_TYPE.MUPAI then
		dump(self.obstracleData, "self.obstracleData")
		WindowControler:showWindow("TowerObstacleView",self.obstracleData)
	end
end

-- 是否是普通障碍物(坑)
function TowerObstacleModel:isNormalObstracle()
	return tonumber(self.obstracleData.type) == self.OBSTRACLE_TYPE.KENG
end

-- 设置事件ID
function TowerObstacleModel:setEventId(eventId)
	TowerObstacleModel.super.setEventId(self,eventId)
	self.obstracleData = FuncTower.getObstacleData(eventId)
end

function TowerObstacleModel:createEventView()
	local obstracleId = self:getEventId()
	local viewCtn = self.grid.viewCtn
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0

	local view = nil
	local size = nil
	if obstracleId == FuncTowerMap.NORMAL_OBSTACLE_ID then
		-- 障碍物选择时必须的参数
		-- if self.grid.xIdx == 10 and self.grid.yIdx == 3 then
		view = self.controler:getNormalObstacleView()
		-- echo('self.grid.xIdx,yIdx=',viewCtn,self.grid.xIdx,self.grid.yIdx,view,obstracleId)
		size = view:getContentSize()
		-- end
	else
		local animName = self.obstracleData.anim
		if animName then
			view = self.controler.ui:createUIArmature("UI_suoyaota_b", animName ,nil, true ,GameVars.emptyFunc)
		end
	end

	if view then
		self:initView(viewCtn,view,x,y,z,size)
		local zorder = self.grid:getZOrder()
		self:setZOrder(zorder)
		-- if self.grid.xIdx == 10 and self.grid.yIdx == 3 then
		-- 	echo('xyz=',x,y,z)
		-- 	echo("self.myView info=====",self.pos.x,self.pos.y)
		-- end
	end
end

return TowerObstacleModel
