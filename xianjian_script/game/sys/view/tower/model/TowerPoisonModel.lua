--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔毒事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerPoisonModel = class("TowerPoisonModel",TowerEventModel)

function TowerPoisonModel:ctor( controler,gridModel)
	TowerPoisonModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerPoisonModel:initData()
	local gridInfo = self.grid:getGridInfo()
	local poisonId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	self:setEventId(poisonId)
end

function TowerPoisonModel:registerEvent()
	TowerPoisonModel.super.registerEvent(self)
	-- 道具使用成功更新数据后
	EventControler:addEventListener(TowerEvent.TOWEREVENT_USE_ITEM_UPDATE,self.updatePoisonedStatus,self)
end

function TowerPoisonModel:onEventResponse()
	-- WindowControler:showTips("点击了毒")
end

function TowerPoisonModel:createEventView()
	local poisonId = self:getEventId()
	local mapBuffData = FuncTower.getMapBuffData(poisonId)
	local animName = mapBuffData.anim

	local viewCtn = self.grid.viewCtn
	if animName then
		local anim = self.controler.ui:createUIArmature("UI_suoyaota_b", animName ,nil, true ,GameVars.emptyFunc)
		local x = self.grid.pos.x
		local y = self.grid.pos.y
		local z = 0

		self:initView(viewCtn,anim,x,y,z)
		local zorder = self.grid:getZOrder() + 1
		self:setZOrder(zorder)

		self:updatePoisonedStatus()
	else
		echoError("毒动画配置为空") 
	end
end

-- 当主角运动到格子
function TowerPoisonModel:onCharArriveTargetGrid(grid)
	self:updatePoisonedStatus()
end

-- 更新中毒状态
function TowerPoisonModel:updatePoisonedStatus()
	-- 如果使用了解毒草
	if TowerMainModel:hasPoisonBuff() then
		local charModel = self.controler.charModel
		FilterTools.clearFilter(charModel.myView)
	else
		-- 判断主角当前坐标
		local charGrid = self.controler.charModel:getGridModel()
		if charGrid == self.grid then
			self:bePoisoned()
		end
	end
end

-- 中毒操作
function TowerPoisonModel:bePoisoned()
	local charModel = self.controler.charModel
	FilterTools.clearFilter(charModel.myView)
	FilterTools.setViewFilter(charModel.myView,FilterTools.colorMatrix_kuilei)
end

return TowerPoisonModel
