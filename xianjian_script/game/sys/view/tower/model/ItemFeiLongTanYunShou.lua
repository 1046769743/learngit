--[[
	Author: 张燕广
	Date:2017-08-01
	Description: 锁妖塔道具-飞龙探云手
	1.用于偷怪物身上的物品，可偷窃的怪物的物品
	2.确定使用道具后，先标出可被偷窃的怪，选择怪后主角移动过去执行偷窃操作
	3.TowerMonster表steal字段配置了可被偷窃的物品
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemFeiLongTanYunShou = class("ItemFeiLongTanYunShou",TowerItemBaseTargetModel)

function ItemFeiLongTanYunShou:ctor( controler,gridModel)
	ItemFeiLongTanYunShou.super.ctor(self,controler,gridModel)
		
	-- 偷东西动画
	--方位对应的动作 左边是动作,右边是sc
	self.stealFaceAction = {
        --右 
        {"UI_suoyaota_feilong_1",1,},
        -- 右上
        {"UI_suoyaota_feilong_3",-1},
        -- 左上
        {"UI_suoyaota_feilong_3",1},
        -- 左
        {"UI_suoyaota_feilong_1",-1},
        -- 左下
        {"UI_suoyaota_feilong_2",-1},  
        --右下
        {"UI_suoyaota_feilong_2",1},
    }
end

function ItemFeiLongTanYunShou:registerEvent()
	ItemFeiLongTanYunShou.super.registerEvent(self)
end

-- 道具事件回应
function ItemFeiLongTanYunShou:onEventResponse()
	ItemFeiLongTanYunShou.super.onEventResponse(self)
end

-- 当主角运动到目标怪
-- 检查是否为可选格子 发送开始使用道具消息 
function ItemFeiLongTanYunShou:onCharArriveTargetGrid(event)
	if not self.controler.charModel:checkGiveItemSkill() then
		return
	end

	if event and event.params then
		local grid = event.params.grid
		self.charTargetGrid = grid

		-- 是否是备选的格子
		if not self:checkOptionalGrid(self.charTargetGrid) then
			return
		end

		self:onEnsureTarget(self.charTargetGrid)
	else
		-- echoError("ItemFeiLongTanYunShou:onCharArriveGrid grid is nil")
	end
end

-- 当确定了道具的使用目标
function ItemFeiLongTanYunShou:onEnsureTarget(grid)
	local itemId = self.eventId
	local gridPos = cc.p(grid.xIdx,grid.yIdx)
	-- 目标怪ID
	local monsterId = grid.eventModel:getEventId()
	EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos,monsterId=monsterId})
end

-- 当使用道具成功
-- 播放获得道具界面 发消息 更新mainModel数据 并更新mapview的左下角的飞龙道具图标
function ItemFeiLongTanYunShou:onUseItemSuccess(event)
	local serverEvent = {}
	if self:checkItemId(event) then
		echo("飞龙道具使用成功")
		self.controler.charModel:setCharItem(nil)
		local userItemFunc = function()
			local serverData = serverEvent.params.serverData

			local towerReward = {}
			if serverData.rewardGoods then
				local reward = FuncTower.towerItemType..","..serverData.rewardGoods .. ",1"
				towerReward = {reward}
			end
			
			WindowControler:showWindow("TowerGetRewardView",serverData.reward,towerReward)

			-- 调用父类
			ItemFeiLongTanYunShou.super.onUseItemSuccess(self,serverEvent)
		end

		-- 必须深度拷贝数据，否则在回调中event就被释放了
		serverEvent.params = table.deepCopy(event.params)
		-- 从主角位置到目标位置播放一个偷东西的动画
		local stealAnim = self:playStealAnim()
		stealAnim:registerFrameEventCallFunc(stealAnim.totalFrame, 1, c_func(userItemFunc))
	end
end

-- 找到目标格子
function ItemFeiLongTanYunShou:findTargetGrids()
	local allMonsterGrids = self.controler:findGridsByType(FuncTowerMap.GRID_BIT_TYPE.MONSTER)
	local gridsArr = {}
	-- 过滤不能使用是怪的类型
	-- 道具表中会配置可用使用的对象的类型
	local attrArr = self.itemData.attribute
	if attrArr == nil or #attrArr == 0 then
		gridsArr = allMonsterGrids
	else
		for k, v in pairs(allMonsterGrids) do
			local monsterType = v:getEventModel():getMonsterType()
			if table.find(attrArr,tostring(monsterType)) then
				gridsArr[#gridsArr+1] = v
			end
		end
	end

	return gridsArr
end

function ItemFeiLongTanYunShou:getNotFoundTips()
	return "飞龙没有找到目标格子"
end

-- 播放偷东西动画
function ItemFeiLongTanYunShou:playStealAnim()
	local charModel = self.controler.charModel
	local x = charModel.pos.x
	local y = charModel.pos.y
	
	-- 目标怪
	local targetModel = self.charTargetGrid
	local targetPoint = cc.p(targetModel.pos.x,targetModel.pos.y)
	-- 计算出主角与目标怪朝向
	local angle = charModel:calAngle(targetPoint)
	local index = charModel:getActionIndex(angle)

	local animName = self.stealFaceAction[index][1]
	local actionX = self.stealFaceAction[index][2]

	local ui = self.controler.ui
	local anim = ui:createUIArmature(self.controler.animFlaName,animName, charModel.viewCtn, false, GameVars.emptyFunc);
	anim:pos(x+30,y+60)
	anim:setScaleX(actionX)

	local zorder = targetModel:getZOrder() + 1
	anim:zorder(zorder)
	anim:startPlay(false)

	return anim
end

return ItemFeiLongTanYunShou
