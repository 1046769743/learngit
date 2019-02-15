--[[
    Author:  曹称
    Date:2017-09-25
    Description: 锁妖塔终点事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerEndPointModel = class("TowerEndPointModel",TowerEventModel)

function TowerEndPointModel:ctor( controler,gridModel)
    TowerEndPointModel.super.ctor(self,controler,gridModel)
end

function TowerEndPointModel:registerEvent()
    TowerEndPointModel.super.registerEvent(self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_CONFIRM_TO_ENTER_NEXT_FLOOR,self.goToNextFloor,self)
end

function TowerEndPointModel:setEventId(eventId)
    TowerEndPointModel.super.setEventId(self,eventId)
 end   
-- 事件回应
function TowerEndPointModel:onEventResponse()
     local params = {
            x = self.grid.xIdx,
            y = self.grid.yIdx,
            curFloor = TowerMainModel:getCurrentFloor(),
        }
    if TowerMapModel:isHasEventVisible() then
        WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.NEXTFLOOR_VIEW,params)
    else
        local curFloor = TowerMainModel:getCurrentFloor()
        if curFloor == TowerMainModel:getMaxFloor() then 
            WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_001"))
            return
        else
            local isLock = TowerMainModel:checkIsCanEnterFloor(curFloor +1)
            if TowerMainModel:checkIsArriveNextStage() or isLock then
                EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CONFIRM_TO_CLICK_LOCK)
            else
                self:goToNextFloor()
            end
        end
    end
end

function TowerEndPointModel:goToNextFloor()
    if not self.haveSentRequest then
        self.haveSentRequest = true
        local params = {
            x = self.grid.xIdx,
            y = self.grid.yIdx,
        }
        TowerServer:goNextFloor(params,c_func(self.goToNextFloorCallBack,self))
    end
end

function TowerEndPointModel:goToNextFloorCallBack(event)
    self.haveSentRequest = false
    if event.error then
    else
        TowerMainModel:saveGridAni(false)
        TowerMainModel:enterNextData(event.result.data)
        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ENTER_NEXTFLOOR)
    end    
end

function TowerEndPointModel:createEventView()
    local viewCtn = self.grid.viewCtn
    local pointView = self.controler.ui:createUIArmature("UI_suoyaota","UI_suoyaota_chuansongfazhen",nil, false, GameVars.emptyFunc)
    local tempYPos = 20
    local x = self.grid.pos.x
    local y = self.grid.pos.y +tempYPos
    local z = 0

    self:initView(viewCtn,pointView,x,y,z)
    local zorder = self.grid:getZOrder() + 1
    self:setZOrder(zorder)
end    


return TowerEndPointModel