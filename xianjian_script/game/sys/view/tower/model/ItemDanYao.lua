--[[
    Author: 曹称
    Date:2017-08-01
    Description: 锁妖塔道具-丹药类
    1.使用后可复活一名已阵亡的角色，并恢复其50%的血量
]]

local TowerItemBaseModel = require("game.sys.view.tower.model.TowerItemBaseModel")
ItemDanYao = class("ItemDanYao",TowerItemBaseModel)

function ItemDanYao:ctor( controler,gridModel)
    ItemDanYao.super.ctor(self,controler,gridModel)
end        

function ItemDanYao:registerEvent()
    ItemDanYao.super.registerEvent(self)
end

function ItemDanYao:onEventResponse()
    ItemDanYao.super.onEventResponse(self)
end    

-- 确认使用道具
function ItemDanYao:doUseItem(event)
    local itemId = event.params.itemId
    local itemTime = event.params.itemTime
    if self:checkCanUseItem(itemId,itemTime) then
        WindowControler:showWindow("TowerChooseBuffTarget",FuncTower.CHOOSEHERO_TYPE.GOODS_VIEW,itemId,{})
    end
end    

return ItemDanYao