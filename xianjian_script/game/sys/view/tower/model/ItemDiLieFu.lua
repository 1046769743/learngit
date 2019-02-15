--[[
	Author: 张燕广
	Date:2017-12-22
	Description: 锁妖塔道具-地裂符
	1.炸开主角位置周围的所有格子
	2.无需选中格子,主角走到某个格子,选择使用道具即可
]]

local TowerItemBaseTargetModel = require("game.sys.view.tower.model.TowerItemBaseTargetModel")
ItemDiLieFu = class("ItemDiLieFu",TowerItemBaseTargetModel)

function ItemDiLieFu:ctor( controler,gridModel)
	ItemDiLieFu.super.ctor(self,controler,gridModel)
end

function ItemDiLieFu:registerEvent()
	ItemDiLieFu.super.registerEvent(self)
end

-- 道具事件回应
function ItemDiLieFu:onEventResponse()
	ItemDiLieFu.super.onEventResponse(self)
end

-- 确认使用道具
function ItemDiLieFu:doUseItem(event)
	if not self:checkEventParams(event) then
		return
	end

	local itemId = event.params.itemId
	local itemTime = event.params.itemTime

	if self:checkCanUseItem(itemId,itemTime) then
		echo("地裂符使用道具doUseItem",itemTime,itemId)
		local optionalGrids = self:findTargetGrids()
		if optionalGrids and #optionalGrids == 0 then
			local tips = self:getNotFoundTips()
			WindowControler:showTips(tips)
			return
		else
			self:setUseTargets(optionalGrids)
			-- 主角位置
			local charGrid = self.controler.charModel:getGridModel()
			local gridPos = cc.p(charGrid.xIdx,charGrid.yIdx)
			EventControler:dispatchEvent(TowerEvent.TOWEREVENT_BEGIN_USE_ITEM,{itemId=itemId,goodsTime=self.itemTime,gridPos=gridPos})
		end
	else
		echo("不可使用")
	end
end

function TowerItemBaseTargetModel:getNotFoundTips()
	-- 周围无石板，无法使用
	return GameConfig.getLanguage("#tid_tower_prompt_111")
end

-- 当使用道具成功
function ItemDiLieFu:onUseItemSuccess(event)
	if self:checkItemId(event) then
		local targetGirds = self:getUseTargets()
		self:openGrids(targetGirds)
		-- 调用父类
		ItemDiLieFu.super.onUseItemSuccess(self,event)
	end
end

-- 将格子炸裂开
function ItemDiLieFu:openGrids(gridsArr)
	if #gridsArr == 0 then 
		WindowControler:showTips(GameConfig.getLanguage("tid_common_2064"))
	else
		for k,v in pairs(gridsArr) do
			v:forceOpen(k)
		end
	end
end

-- 找到目标格子
function ItemDiLieFu:findTargetGrids()
	local charGrid = self.controler.charModel:getGridModel()
	local tempGrids = self.controler:getSurroundGrids(charGrid)
	local gridsArr = {}

	for k,v in pairs(tempGrids) do
		if not v:hasExplored() then
			gridsArr[#gridsArr+1] = v
		end
	end

	return gridsArr
end

return ItemDiLieFu
