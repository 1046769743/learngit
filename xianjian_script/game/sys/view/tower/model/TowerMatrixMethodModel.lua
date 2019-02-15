--[[
    Author: 曹称
    Date:2017-09-18
    Description: 锁妖塔法阵事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerMatrixMethodModel = class("TowerMatrixMethodModel",TowerEventModel)

function TowerMatrixMethodModel:ctor( controler,gridModel)
    TowerMatrixMethodModel.super.ctor(self,controler,gridModel)
    self:initData()
end

function TowerMatrixMethodModel:registerEvent()
    TowerMatrixMethodModel.super.registerEvent(self)
end

function TowerMatrixMethodModel:initData()
    local gridInfo = self.grid:getGridInfo()
    local matrixMethodId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
    self:setEventId(matrixMethodId)
end

function TowerMatrixMethodModel:setEventId(eventId)
    --暂时代替
    local eventId = 1
    TowerMatrixMethodModel.super.setEventId(self,eventId)
    self.MatrixMethodData = FuncTower.getTowerAltarDataByID(eventId)
end

function TowerMatrixMethodModel:onEventResponse()
    local params = {x=self.grid.xIdx,y=self.grid.yIdx}
    --暂时代替
    self.eventId = 1
    local matrixMethodId = self.eventId
    WindowControler:showWindow("TowerMatrixMethodView",matrixMethodId,params)
end

function TowerMatrixMethodModel:createEventView(eventId)
    local animName = self.MatrixMethodData.anim
    local matrixMethod = self.controler.ui:createUIArmature(self.controler.animFlaName,animName,nil, false, GameVars.emptyFunc)
    local viewCtn = self.grid.viewCtn
    local x = self.grid.pos.x
    local y = self.grid.pos.y
    local z = 0
    self:initView(viewCtn,matrixMethod,x,y,z)

    local zorder = self.grid:getZOrder() + 1
    matrixMethod:startPlay(true)
    self:setZOrder(zorder)
end

function TowerMatrixMethodModel:deleteMe()
    -- 更新格子
    EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_GRIDS)
    
    TowerMatrixMethodModel.super.deleteMe(self)
end

return TowerMatrixMethodModel