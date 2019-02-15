--[[
	Author: 张燕广
	Date:2017-08-03
	Description: 锁妖塔笼子类
]]

local TowerBasicModel = require("game.sys.view.tower.model.TowerBasicModel")
TowerCageModel = class("TowerCageModel",TowerBasicModel)

function TowerCageModel:ctor( ... )
 	TowerCageModel.super.ctor(self,...)

 	-- 笼子内图片
 	self.cageInnerName = "tower_cage_fengyin"
 	-- 笼子外图片
	-- self.cageOutsideName = "tower_cage_wai"
end

function TowerCageModel:setGrid(grid)
	self.grid = grid
end

function TowerCageModel:setCageId(cageId)
	self.cageId = cageId
	self.cageData = FuncTower.getTowerCage(cageId)
	self.mustKillMonsters = self.cageData.parameter or {}
end

-- 每帧刷新
function TowerCageModel:dummyFrame()
	self:updateCageStatus()
end

-- 更新笼子状态
function TowerCageModel:updateCageStatus()
	if not self.grid then
		return
	end

	if self.grid:hasExplored() then
		if self:isClear() then
			-- 删除笼子
			self.grid:clearCage()
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_CLOSETOWERITEMCAGE,self.grid)
		else
			self:createCageView()
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_UPDATATOWERITEMCAGE,self.grid) 
		end
	end
end

-- 创建笼子
function TowerCageModel:createCageView()
	if not self.isShow then
		local eventModel = self.grid:getEventModel()
		local eventView = eventModel:getEventView()
		if not eventView then
			return
		end

		local innerSprite = display.newSprite(FuncRes.iconTowerEvent(self.cageInnerName))
		-- local outsideSprite = display.newSprite(FuncRes.iconTowerEvent(self.cageOutsideName))

		eventView:addChild(innerSprite,1)
		innerSprite:pos(0,0)

		-- eventView:addChild(outsideSprite,1)
		-- outsideSprite:pos(10,10)

		-- self.outsideSprite = outsideSprite
		self.innerSprite = innerSprite

		self.isShow = true
	end
end

-- 笼子是否被解除了
function TowerCageModel:isClear()
	local killMonsters = TowerMainModel:getKillMonsters()

	for k,v in pairs(self.mustKillMonsters) do
		-- 还有怪没被杀死
		if not killMonsters[v] then
			return false
		end
	end

	return true
end

function TowerCageModel:deleteMe()
	-- if self.outsideSprite then
	-- 	self.outsideSprite:removeFromParent()
	-- end

	if self.innerSprite then
		self.innerSprite:removeFromParent()
	end

	TowerCageModel.super.deleteMe(self)
end

return TowerCageModel
