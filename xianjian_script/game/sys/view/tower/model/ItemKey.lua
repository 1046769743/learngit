--[[
	Author: 张燕广
	Date:2017-08-01
	Description: 锁妖塔道具-钥匙
    1.用于开启特殊宝箱
]]

-- @deprecated 暂未用到，梳理下一版需求后，再决定是否删除该类
local TowerItemBaseModel = require("game.sys.view.tower.model.TowerItemBaseModel")
ItemKey = class("ItemKey",TowerItemBaseModel)

function ItemKey:ctor( controler,gridModel)
    ItemKey.super.ctor(self,controler,gridModel)
end

function ItemKey:registerEvent()
    ItemKey.super.registerEvent(self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_UPDATATOWERITEMCAGE, self.stopItemAnimation,self)
    EventControler:addEventListener(TowerEvent.TOWEREVENT_CLOSETOWERITEMCAGE,self.playItemAnimation,self)
end    

function ItemKey:stopItemAnimation(params)
    if params.params == self.grid then
        if self.itemData.animType ~= self.ANIM_TYPE.NONE then
            self.itemData.animType = self.ANIM_TYPE.NONE 
        end    
    end
end

function ItemKey:playItemAnimation(params)
    if params.params == self.grid then
        if self.myView and self.itemData.animType == self.ANIM_TYPE.NONE then
            self:deleteMyView()
            self.itemView = nil
            self.itemData.animType = self.ANIM_TYPE.COMMON
            self:createEventView()
        end    
    end
end

return ItemKey