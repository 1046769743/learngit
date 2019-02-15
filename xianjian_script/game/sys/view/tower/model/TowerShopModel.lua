--[[
	Author: 张燕广
	Date:2017-08-04
	Description: 锁妖塔商店事件类
	1.商店领取后，格子状态为clear，会自动删掉商店
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerShopModel = class("TowerShopModel",TowerEventModel)

function TowerShopModel:ctor( controler,gridModel)
	TowerShopModel.super.ctor(self,controler,gridModel)
end

-- 商店事件回应
function TowerShopModel:onEventResponse()
	echo("商店TowerShopModel:onEventResponse self.shopId=",self.shopId)
	self:checkSkipStatus()
	if self.isOverlapWithChar then
		return
	end

	-- 打开商店
	TowerControler:showShopView(self.grid.xIdx,self.grid.yIdx)
end

-- 每帧刷新
function TowerShopModel:dummyFrame()
	TowerShopModel.super.dummyFrame(self)
	self:updateShopStatus()
	self:checkSkipStatus()
end

-- 更新商店状态
function TowerShopModel:updateShopStatus()
	self:createEventView()
end

function TowerShopModel:setShopType(shopType)
	self.shopType = shopType
end

function TowerShopModel:getShopType()
	return self.shopType
end

function TowerShopModel:setShopId(shopId)
	self.shopId = shopId
end

-- 创建商店视图
function TowerShopModel:createEventView()
	if self.myView then
		return
	end
	--和形象共存
	local shopInfo = TowerMapModel:getShopInfo(self.grid.xIdx,self.grid.yIdx)

	if shopInfo then
		local shopId = shopInfo.shopId
		local shopType = shopInfo.shopType

		local shopData = FuncTower.getTowerInnerShop(shopType)
		local spineId = shopData.spine
		local spine = self.controler:createNpcSpineById(spineId)
			
		local viewCtn = self.grid.viewCtn
		local x = self.grid.pos.x
		local y = self.grid.pos.y
		local z = 0

		self:initView(viewCtn,spine,x,y,z)
		local zorder = self.grid:getZOrder() + 1
		self:setZOrder(zorder)

		self:setEventId(shopType)
		self:setShopId(shopId)
	end
end

function TowerShopModel:checkSkipStatus(event)
	self.gridInfo = self.grid.gridInfo
	if self.gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM] == FuncTowerMap.ITEMANDSHOP_TYPE.SKIPED then
		local charModel = self.controler.charModel
		local charGrid = charModel:getGridModel()
		if self.myView and charGrid then
			-- 主角走到商店的身上
			if self.grid == charGrid then
				self.myView:opacity(100)
				self.isOverlapWithChar = true
			else
				self.myView:opacity(255)
				self.isOverlapWithChar = false
			end
		end
	end
end

function TowerShopModel:isOverlapChar()
	return self.isOverlapWithChar
end

function TowerShopModel:deleteMe()
	-- 更新格子
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATE_GRIDS)
	TowerShopModel.super.deleteMe(self)
end

return TowerShopModel