--[[
    Author:曹称  
    Date:2017-09-28
    Description: 锁妖塔道具-土灵符
    1.使用后，可随机传送到本层的某一点（优先传送至未探索且无事件的格子）
]]

local TowerItemBaseModel = require("game.sys.view.tower.model.TowerItemBaseModel")
ItemTuLingFu = class("ItemTuLingFu",TowerItemBaseModel)

function ItemTuLingFu:ctor( controler,gridModel)
    ItemTuLingFu.super.ctor(self,controler,gridModel)
end

function ItemTuLingFu:registerEvent()
    ItemTuLingFu.super.registerEvent(self)
end

function ItemTuLingFu:onEventResponse()
    ItemTuLingFu.super.onEventResponse(self)
end    

-- 确认使用道具
-- todo 设置了位置才和服务器交互 可能造成位置设了但是无法继续探索的问题
-- 
function ItemTuLingFu:doUseItem(event)
    local itemId = event.params.itemId
    local itemTime = event.params.itemTime
    if self:checkCanUseItem(itemId,itemTime) then
        local newZGrid =  self.controler:findTulingFuItemTargetGrid()    
        local gridPos = {}
        gridPos.x = newZGrid.xIdx
        gridPos.y = newZGrid.yIdx
        
        TowerMapModel:saveCharGridPos(newZGrid.xIdx,newZGrid.yIdx)
        self.controler:setHeroPos(gridPos)
        echo("______ 设置主角位置 完成 __________",gridPos.x,gridPos.y)

        EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos})
    end
end 

-- function ItemTuLingFu:onUseItemSuccess( event )
--     ItemTuLingFu.super.onUseItemSuccess( event )
--     TowerMapModel:saveCharGridPos(newZGrid.xIdx,newZGrid.yIdx)
--     self.controler:setHeroPos(gridPos)
--     echo("______ 设置主角位置 完成 __________",gridPos.x,gridPos.y)
-- end

return ItemTuLingFu
