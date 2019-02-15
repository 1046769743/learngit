--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔道具-神眼符
	1.可查看未探索的格子
	2.选中的格子及周围6个格子变半透效果，存在5秒，期间内对格子/格子内道具做任何操作都无响应
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemShenYanFu = class("ItemShenYanFu",TowerItemBaseTargetModel)

function ItemShenYanFu:ctor( controler,gridModel)
	ItemShenYanFu.super.ctor(self,controler,gridModel)

	-- 作弊持续时长,秒
	self.CHEAT_KEEP_TIME = 5
end

function ItemShenYanFu:registerEvent()
	ItemShenYanFu.super.registerEvent(self)

end

-- 道具事件回应
function ItemShenYanFu:onEventResponse()
	ItemShenYanFu.super.onEventResponse(self)
end

-- 当点击了格子
function ItemShenYanFu:onClickGrid(event)
	if not self.willSelectTarget then 
		return
	end

	if event then
		local grid = event.params.grid
		if self:checkOptionalGrid(grid) then
			self.controler.charModel:setCharItem(self)
			self:onEnsureTarget(grid)
		end
	end

	self.willSelectTarget = false
end

-- 当确定了道具的使用目标
function ItemShenYanFu:onEnsureTarget(grid)
	self.targetGrid = grid
	echo("神眼符使用",grid.xIdx,grid.yIdx)
	local itemId = self.eventId
	local charGrid = self.controler.charModel:getGridModel()
	-- 主角位置
	local gridPos = cc.p(charGrid.xIdx,charGrid.yIdx)

	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos})
end

function ItemShenYanFu:playUseAnim()
	if self.targetGrid then
		local spbName = "UI_suoyaota"
	    local useAnim = ViewSpine.new(spbName, {}, nil,spbName);
	    useAnim:playLabel("UI_suoyaota_tianyan");
	    useAnim:pos(self.targetGrid.pos.x,self.targetGrid.pos.y)
	    useAnim:setIsCycle(false)

		local zorder = self.targetGrid:getZOrder() + 1
		useAnim:zorder(zorder)

		local viewCtn = self.targetGrid.viewCtn
		viewCtn:addChild(useAnim)
	end
end

-- 开启作弊模式
function ItemShenYanFu:doCheat()
	local grids = self:findCheatGrids(self.targetGrid)
	self.cheatGrids = grids

	for k,v in pairs(grids) do
		v:setCheatStatus(true)
	end

	local closeCheat = function()
		local grids = self.cheatGrids or {}
		for k,v in pairs(grids) do
			v:setCheatStatus(false)
		end
	end

	-- 5秒后关闭作弊
	WindowControler:globalDelayCall(c_func(closeCheat), self.CHEAT_KEEP_TIME)
end

-- 关闭作弊模式
-- function ItemShenYanFu:closeCheat()
-- 	local grids = self.cheatGrids or {}
-- 	for k,v in pairs(grids) do
-- 		v:setCheatStatus(false)
-- 	end
-- end

-- 当使用道具成功
function ItemShenYanFu:onUseItemSuccess(event)
	if self:checkItemId(event) then
		if self.targetGrid then
			self.controler.charModel:setCharItem(nil)
			echo("神眼符道具使用成功")
			self:playUseAnim()
			self:doCheat()
			-- 调用父类
	        ItemShenYanFu.super.onUseItemSuccess(self,event)
		end
	end
end

-- 找到需要作弊的格子
function ItemShenYanFu:findCheatGrids(gridModel)
	local gridsArr = {}
	if gridModel then
		local grids = self.controler:getSurroundGrids(gridModel)
		for k,v in pairs(grids) do
			if not v:hasExplored() then
				gridsArr[#gridsArr+1] = v
			end
		end

		gridsArr[#gridsArr+1] = gridModel
	end

	return gridsArr
end

--[[
	找到目标格子
]]
function ItemShenYanFu:findTargetGrids()
	local grids = self.controler:findNotExploredGrids()
	return grids
end

function ItemShenYanFu:checkActiveGrid()
	return false
end

return ItemShenYanFu
