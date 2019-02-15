--[[
	Author: 张燕广
	Date:2017-08-21
	Description: 锁妖塔道具-带有选择目标属性的道具
]]

local TowerItemBaseModel = require("game.sys.view.tower.model.TowerItemBaseModel")
TowerItemBaseTargetModel = class("TowerItemBaseTargetModel",TowerItemBaseModel)

function TowerItemBaseTargetModel:ctor( controler,gridModel)
	TowerItemBaseTargetModel.super.ctor(self,controler,gridModel)

	self.useTargets = {}
end

function TowerItemBaseTargetModel:registerEvent()
	TowerItemBaseTargetModel.super.registerEvent(self)
	EventControler:addEventListener(TowerEvent.TOWEREVENT_CLICK_GRID,self.onClickGrid,self)
end

-- 设置道具使用目标
function TowerItemBaseTargetModel:setUseTargets(useTargets)
	self.useTargets = useTargets
end

-- 获取道具使用目标
function TowerItemBaseTargetModel:getUseTargets()
	return self.useTargets
end

-- 判断选择的是否是备选格子
function TowerItemBaseTargetModel:checkOptionalGrid(clickGrid)
	local userTargets = self:getUseTargets()
	if not userTargets or #userTargets == 0 then
		return false
	end

	for k,v in pairs(userTargets) do
		if v == clickGrid then
			return true
		end
	end

	return false
end

-- 子类继承重写,检查道具使用条件
function TowerItemBaseTargetModel:checkCanUse()
	return false
end

-- 确认使用道具，子类看需求是否需要重写
function TowerItemBaseTargetModel:doUseItem(event)
	if not self:checkEventParams(event) then
		return
	end

	local itemId = event.params.itemId
	local itemTime = event.params.itemTime

	if self:checkCanUseItem(itemId,itemTime) then
		echo('TowerItemBaseTargetModel 确定使用道具',itemTime,itemId)
		local optionalGrids = self:findTargetGrids()
		if optionalGrids and #optionalGrids == 0 then
			-- local tips = self:getNotFoundTips()
			-- WindowControler:showTips(tips)
			self.controler:setSelectTargetEvent(true,false)
			self.willSelectTarget = true
			self.controler.charModel:setCharItem(self)
			return
		end
		
		self:setUseTargets(optionalGrids)
		self:playGridSelectAnim(true)
		self.willSelectTarget = true
		self.controler:setSelectTargetEvent(true)
	end
end

-- 点击了格子，子类看需求是否需要重写
function TowerItemBaseTargetModel:onClickGrid(event)
	if not self.willSelectTarget then
        return
    end

    if event then
		local grid = event.params.grid
		if self:checkOptionalGrid(grid) then
			self.controler.charModel:setCharItem(self)
		else
			self.controler.charModel:setCharItem(nil)
		end
	end

	self:playGridSelectAnim(false)
	self.willSelectTarget = false
end

-- 子类重写，没找到目标时的提示
function TowerItemBaseTargetModel:getNotFoundTips()
	return "没有找到该道具的使用目标"
end

-- 播放选择动画
function TowerItemBaseTargetModel:playGridSelectAnim(isPlay)
	local gridArr = self:getUseTargets()
	if gridArr then
		for k,v in pairs(gridArr) do
			if v and v.eventModel and v.eventModel.playSelectAnim then
				v.eventModel:playSelectAnim(isPlay or false)
			end
		end
	end
end

return TowerItemBaseTargetModel
