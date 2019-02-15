--[[
    Author:caocheng  
    Date:2017-09-22
    Description: 锁妖塔道具-迷魂香
    1.使用后，让一名非boss、非野怪的正常、警戒怪进入睡眠状态
    2.迷魂香与飞龙逻辑基本相同
    3.TODO可以考虑重构合并迷魂香与飞龙
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemMiHunXiang = class("ItemMiHunXiang",TowerItemBaseTargetModel)

function ItemMiHunXiang:ctor( controler,gridModel)
    ItemMiHunXiang.super.ctor(self,controler,gridModel)
    
    -- 偷东西动画
    --方位对应的动作 左边是动作,右边是sc
    self.stealFaceAction = {
        --右 
        {"UI_suoyaota_feilong_1",1,},
        -- 右上
        {"UI_suoyaota_feilong_3",-1},
        -- 左上
        {"UI_suoyaota_feilong_3",1},
        -- 左
        {"UI_suoyaota_feilong_1",-1},
        -- 左下
        {"UI_suoyaota_feilong_2",-1},  
        --右下
        {"UI_suoyaota_feilong_2",1},
    }
end

function ItemMiHunXiang:registerEvent()
    ItemMiHunXiang.super.registerEvent(self)
end

function ItemMiHunXiang:onEventResponse()
    ItemMiHunXiang.super.onEventResponse(self)
end    

-- 当主角运动到目标怪
function ItemMiHunXiang:onCharArriveTargetGrid(event)
    if not self.controler.charModel:checkGiveItemSkill() then
        return
    end
    
    if event and event.params then
        local grid = event.params.grid
        self.charTargetGrid = grid

        -- 是否是备选的格子
        if not self:checkOptionalGrid(self.charTargetGrid) then
            return
        end

        local charModel = self.controler.charModel
        -- 从主角位置到目标位置播放一个偷东西的动画
        local stealAnim = self:playStealAnim()

        local userItemFunc = function()
            self.controler.charModel:setCharItem(nil)
            local itemId = self.eventId
            local gridPos = cc.p(grid.xIdx,grid.yIdx)

            -- 目标怪ID
            local monsterId = self.charTargetGrid.eventModel:getEventId()
            EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos,monsterId=monsterId})
        end
        stealAnim:registerFrameEventCallFunc(stealAnim.totalFrame, 1, c_func(userItemFunc))
    else
        -- echoError("ItemMiHunXiang:onCharArriveGrid grid is nil")
    end
end

-- 获取已选择的目标怪Id
function ItemMiHunXiang:getTargetMonsterId()
    local useTargets = self:getUseTargets()
    local monsterId = nil
    if useTargets and #useTargets > 0 then
        local targetModel = useTargets[1]
        monsterId = targetModel.eventModel:getEventId()
    end

    return monsterId
end

-- 当使用道具成功
function ItemMiHunXiang:onUseItemSuccess(event)
    if self:checkItemId(event) then
        echo("迷魂香道具使用成功")
        self.controler.charModel:setCharItem(nil)
        -- 调用父类
        ItemMiHunXiang.super.onUseItemSuccess(self,event)
    end
end

-- 找到目标格子
function ItemMiHunXiang:findTargetGrids()
    local allMonsterGrids = self.controler:findGridsByType(FuncTowerMap.GRID_BIT_TYPE.MONSTER)
    local gridsArr = {}
    -- 过滤怪的属性
    local attrArr = self.itemData.attribute
    if attrArr == nil or #attrArr == 0 then
        gridsArr = allMonsterGrids
    else
        for k, v in pairs(allMonsterGrids) do
            local monsterType = v:getEventModel():getMonsterType()
            if table.find(attrArr,tostring(monsterType)) then
                gridsArr[#gridsArr+1] = v
            end
        end
    end

    return gridsArr
end

-- 播放催眠动画
function ItemMiHunXiang:playStealAnim()
    local charModel = self.controler.charModel
    local x = charModel.pos.x
    local y = charModel.pos.y
    
    -- 目标怪
    local targetModel = self.charTargetGrid
    local targetPoint = cc.p(targetModel.pos.x,targetModel.pos.y)
    -- 计算出主角与目标怪朝向
    local angle = charModel:calAngle(targetPoint)
    local index = charModel:getActionIndex(angle)

    local animName = self.stealFaceAction[index][1]
    local actionX = self.stealFaceAction[index][2]

    local ui = self.controler.ui

    local anim = ui:createUIArmature(self.controler.animFlaName,animName, charModel.viewCtn, false, GameVars.emptyFunc);
    anim:pos(x,y+90)
    anim:setScaleX(actionX)

    local zorder = charModel:getZOrder() + 1
    anim:zorder(zorder)
    anim:startPlay(false)

    return anim
end
       
return ItemMiHunXiang