--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔道具-石板
	1.可将指定的陷阱改变为正常可行走的格子
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemShiBan = class("ItemShiBan",TowerItemBaseTargetModel)

function ItemShiBan:ctor( controler,gridModel)
	ItemShiBan.super.ctor(self,controler,gridModel)
end

function ItemShiBan:registerEvent()
	ItemShiBan.super.registerEvent(self)
end

-- 道具事件回应
function ItemShiBan:onEventResponse()
	ItemShiBan.super.onEventResponse(self)
end

-- 当主角运动到目标
function ItemShiBan:onCharArriveTargetGrid(event)
	if not self.controler.charModel:checkGiveItemSkill() then
		return
	end

	if event and event.params then
		local grid = event.params.grid
		-- 是否是备选的格子
		if not self:checkOptionalGrid(grid) then
			return
		end

		self:onEnsureTarget(grid)
	else
		-- echoError("ItemZiJinHuLu:onCharArriveGrid grid is nil")
	end
end

-- 当确定了道具的使用目标
function ItemShiBan:onEnsureTarget(grid)
	self.controler.charModel:setCharItem(nil)
	self.targetGrid = grid
	local gridPos =  cc.p(grid.xIdx,grid.yIdx)
	local itemId = self.eventId
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos})
end

-- 当使用道具成功
function ItemShiBan:onUseItemSuccess(event)
	if self:checkItemId(event) then
		if self.targetGrid then
			-- 播放填平格子动画
			self:playUseAnim(self.targetGrid)
			-- 调用父类
			ItemShiBan.super.onUseItemSuccess(self,event)
		end
	end
end

function ItemShiBan:playUseAnim(grid)
	if self.controler.ui and self.controler.ui.createUIArmature then
		local anim = self.controler.ui:createUIArmature("UI_suoyaota", "UI_suoyaota_fangkuaitianbu" ,self.targetGrid.viewCtn, true ,GameVars.emptyFunc)
		if anim and not tolua.isnull(anim) then
			anim:setVisible(true)
			anim:pos(grid.pos.x,grid.pos.y)
			-- +1 防止被新创建的地板盖住动画
			anim:zorder(grid.zorder+1)

			anim:startPlay(false)
		end
	else
		echoWarn("石板道具createUIArmature is ",self.controler.ui.createUIArmature)
	end
end

--[[
	找到目标格子
	1.查找可以到达的普通障碍物(坑)
]]
function ItemShiBan:findTargetGrids()
	local grids = self.controler:findGridsByType(FuncTowerMap.GRID_BIT_TYPE.OBSTACLE)
	local targetGrids = {}

	-- 过滤掉障碍物中非坑障碍物
	for k,v in pairs(grids) do
		if v.eventModel:isNormalObstracle() then
			targetGrids[#targetGrids+1] = v
		end
	end

	return targetGrids
end

return ItemShiBan
