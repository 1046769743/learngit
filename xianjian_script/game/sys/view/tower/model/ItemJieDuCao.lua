--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔道具-解毒草
	1.使用后，免疫本层所有的毒性伤害
	2.特殊处理：注意不同于其他道具,该道具只在本层有效
	3.使用解毒草后，战前发送主角位置，服务器做校验
]]

local TowerItemBaseModel = require("game.sys.view.tower.model.TowerItemBaseModel")
ItemJieDuCao = class("ItemJieDuCao",TowerItemBaseModel)

function ItemJieDuCao:ctor( controler,gridModel)
	ItemJieDuCao.super.ctor(self,controler,gridModel)
	self:initData()
end

function ItemJieDuCao:initData()
	ItemJieDuCao.super.initData(self)
end

-- 道具事件回应
function ItemJieDuCao:onEventResponse()
	ItemJieDuCao.super.onEventResponse(self)
end

-- 子类重写，使用道具成功
function ItemJieDuCao:onUseItemSuccess(event)
	ItemJieDuCao.super.onUseItemSuccess(self,event)
end

return ItemJieDuCao
