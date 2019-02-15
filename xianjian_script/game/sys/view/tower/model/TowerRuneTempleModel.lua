--
--Author:      zhuguangyuan
--DateTime:    2018-03-07 11:09:07
--Description: 散灵法阵 事件
-- 法阵id eventId
-- 生效符文id curRuneId

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerRuneTempleModel = class("TowerRuneTempleModel",TowerEventModel)

function TowerRuneTempleModel:ctor( controler,gridModel)
    TowerRuneTempleModel.super.ctor(self,controler,gridModel)
    self:initData()
    self.basePngName = "tower_img_taizi" -- 场景中的法阵底座图标名字
end

function TowerRuneTempleModel:registerEvent()
    TowerRuneTempleModel.super.registerEvent(self)

    -- 生效的聚灵格子类型发生变化
    EventControler:addEventListener(TowerEvent.TOWER_CHANGE_RUNE_SUCCEED, self.activedRuneChanged, self)
end

function TowerRuneTempleModel:activedRuneChanged( event )
    if event and event.params then
        self.curRuneId = event.params.newRuneId -- 初始化当前符文
        echo("________ 新符文 id __________",self.curRuneId)

        self.runeData = FuncTower.getRuneDataByID(self.curRuneId)
        if self.myView then
            self.myView:removeFromParent()
            self.myView = nil
        end
        self:createEventView()
    end
end

function TowerRuneTempleModel:initData()
    local gridInfo = self.grid:getGridInfo()
    local runeTempleId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
    self:setEventId(runeTempleId)
    self:setCurRuneId()
end

function TowerRuneTempleModel:setEventId(eventId)
    TowerRuneTempleModel.super.setEventId(self,eventId)
    self.runeTempleData = FuncTower.getRuneTempleDataByID(eventId)
end

-- 设置当前生效的符文
function TowerRuneTempleModel:setCurRuneId()
    local gridInfo = self.gridInfo
    if not gridInfo then
        gridInfo = self.grid:getGridInfo()
    end
    if gridInfo["ext"] then
        if gridInfo["ext"].runeId then
            self.curRuneId = gridInfo["ext"].runeId
        end
    end
    if not self.curRuneId then
        self.curRuneId = self.runeTempleData.runeStart -- 初始化当前符文
    end
    self.runeData = FuncTower.getRuneDataByID(self.curRuneId)
end

-- 获取场景中正在生效的聚灵格子类型
function TowerRuneTempleModel:getActivedRuneId()
    return self.curRuneId
end

-- 事件回应,弹出法阵界面
function TowerRuneTempleModel:onEventResponse()
    local pos = {
        x = self.grid.xIdx,
        y = self.grid.yIdx,
    }
    WindowControler:showWindow("TowerRuneTempleView",self.eventId,self.curRuneId,pos)
end

function TowerRuneTempleModel:createEventView()
	-- -- 基座图标 无动画情况
	-- local basePng = FuncRes.iconTowerEvent(self.basePngName)
 --    local baseSprite = display.newSprite(basePng) 
 --    local viewCtn = self.grid.viewCtn
 --    local x = self.grid.pos.x
 --    local y = self.grid.pos.y + 16
 --    local z = 0
 --    self.runeCtn = display.newNode():addTo(baseSprite,1) -- 变更符文时的容器
 --    -- 基座上的符文图标
 --    self.runeCtn:removeAllChildren()
 --    local runePng1 = FuncRes.iconTowerEvent(self.runeData.runePng)
 --    local runeSprite = display.newSprite(runePng1):addto(self.runeCtn):anchor(0.5,0.5):pos(80,120)  

 --    self:initView(viewCtn,baseSprite,x,y,z)

 --    local zorder = self.grid:getZOrder() + 1
 --    self:setZOrder(zorder)

    -- 换成动画
    local runeType = self.runeData.runeEventType
    echo("__________runeType____________",runeType)
    local ani
    if runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.SWORD then
        ani = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_gongji", nil, true, GameVars.emptyFunc) 
    elseif runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN then
        ani = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_caoyao", nil, true, GameVars.emptyFunc) 
    elseif runeType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.ANGER_REGAIN then
        ani = self.controler.ui:createUIArmature("UI_suoyaota_c", "UI_suoyaota_c_nuqi", nil, true, GameVars.emptyFunc) 
    end
    ani:visible(true)
    self:initView(self.grid.viewCtn,ani,self.grid.pos.x,self.grid.pos.y+16,0)

    local zorder = self.grid:getZOrder() + 1
    self:setZOrder(zorder)
end

return TowerRuneTempleModel
