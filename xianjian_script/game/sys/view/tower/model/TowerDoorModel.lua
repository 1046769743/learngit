--
--Author:      zhuguangyuan
--DateTime:    2018-03-07 11:11:15
--Description: 门 事件
--


local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerDoorModel = class("TowerDoorModel",TowerEventModel)

function TowerDoorModel:ctor( controler,gridModel )
 	TowerDoorModel.super.ctor(self,controler)
 	self.grid = gridModel
    self:initData()

 	self.isEventValid = true
end

function TowerDoorModel:initData()
    local gridInfo = self.grid:getGridInfo()
    local doorId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
    self:setEventId(doorId)
end

function TowerDoorModel:setEventId(eventId)
    TowerDoorModel.super.setEventId(self,eventId)
    self.doorData = FuncTower.getDoorEventDataByID(eventId)
end

function TowerDoorModel:onEventResponse()
    local params = {x=self.grid.xIdx,y=self.grid.yIdx}
    local doorId = self.eventId
    
    local doorData = FuncTower.getDoorEventDataByID(self.eventId)
    local unlockGridPosArr = doorData.unlockGrid

    local surroundPoints = {}
    for k,v in pairs(unlockGridPosArr) do
        surroundPoints[#surroundPoints + 1] = FuncTowerMap.surroundPoints[tonumber(v)]
    end
    local targetPoint = {x=self.grid.xIdx, y=self.grid.yIdx }
    local pointArr = FuncTowerMap.getSurroundPointsList(targetPoint,surroundPoints)
    local charPos = self.controler.charModel:getCurGrid()
    local charxIdx,charyIdx = charPos.x,charPos.y
    for k,v in pairs(pointArr) do
        if tostring(v.x) == tostring(charxIdx) and tostring(v.y) == tostring(charyIdx) then
            local params = {
                x = self.grid.xIdx,
                y = self.grid.yIdx,
            }
            self:playDoorDisappearAni()
            if not self.hasSentRequest then
                self.hasSentRequest = true
                TowerServer:passDoorEvent(params,c_func(self.passDoorCallback,self))
            end
            return 
        end
    end
    WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_074"))
end

function TowerDoorModel:passDoorCallback( serverData )
    if serverData.error then
        return
    else
        self:playDoorDisappearAni()
        local function updateServerData()
            local data = serverData.result.data
            TowerMainModel:updateData(data)
            self.hasSentRequest = false
        end
        self.controler.ui:delayCall(c_func(updateServerData),40/GameVars.GAMEFRAMERATE)
    end
end

function TowerDoorModel:playDoorDisappearAni()
    local animation = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_menxiaoshi", self.myView, true, GameVars.emptyFunc) 
    animation:setScale(0.9)
    animation:pos(-16,75)
end

function TowerDoorModel:createEventView(eventId)
    local doorPng = FuncRes.iconTowerEvent(self.doorData.png)
    local doorSprite = display.newSprite(doorPng)  
    doorSprite:setScale(0.9)
    local viewCtn = self.grid.viewCtn
    local x = self.grid.pos.x
    local y = self.grid.pos.y + 42
    local z = 0
    self:initView(viewCtn,doorSprite,x,y,z)

    local zorder = self.grid:getZOrder() + 1
    self:setZOrder(zorder)
end

function TowerDoorModel:deleteMe()
    TowerDoorModel.super.deleteMe(self)
end


return TowerDoorModel
