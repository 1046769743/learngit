--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔五灵池事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerSpritPoolModel = class("TowerSpritPoolModel",TowerEventModel)

function TowerSpritPoolModel:ctor( controler,gridModel)
	TowerSpritPoolModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerSpritPoolModel:initData()
	self.animName = "UI_suoyaota_b_wulingta"
end

-- 五灵池事件响应
function TowerSpritPoolModel:onEventResponse()
	local params = {x=self.grid.xIdx,y=self.grid.yIdx}
    WindowControler:showWindow("TowerWuLingPoolView",params)
end

function TowerSpritPoolModel:createEventView()
	local viewCtn = self.grid.viewCtn
	local anim = self.controler.ui:createUIArmature("UI_suoyaota_b", self.animName ,nil, true ,GameVars.emptyFunc)

	local x = self.grid.pos.x
	-- 坐标修正
	local y = self.grid.pos.y + 8
	local z = 0
	self:initView(viewCtn,anim,x,y,z)
	local zorder = self.grid:getZOrder() + 1
	self:setZOrder(zorder)
end

return TowerSpritPoolModel
