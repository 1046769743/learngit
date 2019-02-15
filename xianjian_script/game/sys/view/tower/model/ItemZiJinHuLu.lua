--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔道具-紫金葫芦
	1.将生命少于约30%的怪物(必须是星怪)收入葫芦炼丹药
	2.实际效果是秒杀怪，而后获得药品奖励（成功时播放怪物消失动画,正常给予星级奖励）
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemZiJinHuLu = class("ItemZiJinHuLu",TowerItemBaseTargetModel)

function ItemZiJinHuLu:ctor( controler,gridModel)
	ItemZiJinHuLu.super.ctor(self,controler,gridModel)
	self:initData()
end

function ItemZiJinHuLu:initData()
	-- 怪生命值30%
	self.hpPercent = TowerConfig.ZIJINHULU_HP or 30
end

function ItemZiJinHuLu:registerEvent()
	ItemZiJinHuLu.super.registerEvent(self)
end

-- 道具事件回应
function ItemZiJinHuLu:onEventResponse()
	ItemZiJinHuLu.super.onEventResponse(self)
end

-- 当主角运动到目标怪
function ItemZiJinHuLu:onCharArriveTargetGrid(event)
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
function ItemZiJinHuLu:onEnsureTarget(grid)
	self.targetGrid = grid

	local monsterModel = grid:getEventModel()
	echo("确定了目标，开始释放道具itemId=",self.eventId)

	local itemId = self.eventId
	local monsterId = monsterModel:getEventId()

	-- 选择的目标怪的坐标
	local gridPos = cc.p(grid.xIdx,grid.yIdx)
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos,monsterId=monsterId})
end

-- 播放葫芦动画
function ItemZiJinHuLu:playUseAnim(callBack)
	local spbName = "UI_suoyaota"
    local huluAnim = ViewSpine.new(spbName, {}, nil,spbName);
    huluAnim:playLabel("UI_suoyaota_hulu");
    huluAnim:pos(self.targetGrid.pos.x,self.targetGrid.pos.y + 50)
    huluAnim:setIsCycle(false)

	local zorder = self.targetGrid:getZOrder() + 1
	huluAnim:zorder(zorder)

	local viewCtn = self.targetGrid.viewCtn
	viewCtn:addChild(huluAnim)

	if callBack then
		self.controler.ui:delayCall(callBack,huluAnim:getCurrentAnimTotalFrame() / GameVars.GAMEFRAMERATE)
	end
end

function ItemZiJinHuLu:playDieAnim()
	local grid = self.targetGrid
	if grid then
		-- 播放死怪动画
		local monsterModel = grid:getEventModel()
		if monsterModel and monsterModel.playDieAnim then
			monsterModel:playDieAnim()

			-- 播放加星动画
			local addStar = monsterModel:getLastStar()
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_ITEM_KILL_MONSTER,{targetGrid=grid,addStar=addStar})
		else
			echoWarn("紫金葫芦 monsterModel=",monsterModel,grid,grid.xIdx,grid.yIdx)
		end
	end
end

-- 当道具使用成功
function ItemZiJinHuLu:onUseItemSuccess(event)
	local serverEvent = {}
	
	if self:checkItemId(event) then
		self.controler.charModel:setCharItem(nil)

		-- 播放葫芦动画
		self:playUseAnim(c_func(self.playDieAnim,self))

		-- 必须深度拷贝数据，否则在回调中event就被释放了
		serverEvent.params = table.deepCopy(event.params)
		-- 更新道具数据
		local callBack = function()
			local serverData = serverEvent.params.serverData

			local towerReward = {}
			if serverData.rewardGoods then
				local reward = FuncTower.towerItemType..","..serverData.rewardGoods .. ",1"
				towerReward = {reward}
			end
			
			-- 调用父类
        	ItemZiJinHuLu.super.onUseItemSuccess(self,serverEvent)

			-- 完美通关奖励
			local perfectData = TowerMainModel:getPerfactReward()
			WindowControler:showWindow("TowerGetRewardView",serverData.reward,towerReward,nil,nil,perfectData)
		end
	
		self.controler.ui:delayCall(c_func(callBack), 0.5)
	end
end

-- 查找生命值低于self.hpPercent的怪
function ItemZiJinHuLu:findTargetGrids()
	local allMonsters = self.controler:findEventModelsByType(FuncTowerMap.GRID_BIT_TYPE.MONSTER)
	local grids = {}

	for k, v in pairs(allMonsters) do
		local eventId = v:getEventId()
		-- 如果是星怪
		if v:isStarMonster() then
			local monsterHpData = TowerMainModel:getMonsterInfo(tostring(eventId))
			if monsterHpData then
				local monsterHpNum = monsterHpData.levelHpPercent
				if monsterHpNum then
					local hpPercent = monsterHpNum
					if hpPercent < (self.hpPercent * 100) then
						local grid = v:getGrid()
						grids[#grids+1] = grid
					end
				end
			end
		end
	end

	return grids
end

return ItemZiJinHuLu
