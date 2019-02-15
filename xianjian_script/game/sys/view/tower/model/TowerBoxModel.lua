--[[
	Author: 张燕广
	Date:2017-07-31
	Description: 锁妖塔宝箱事件类
]]

local TowerEventModel = require("game.sys.view.tower.model.TowerEventModel")
TowerBoxModel = class("TowerBoxModel",TowerEventModel)

function TowerBoxModel:ctor( controler,gridModel)
	TowerBoxModel.super.ctor(self,controler,gridModel)
	self:initData()
end

function TowerBoxModel:initData()
	-- 动画类别
	self.ANIM_TYPE = {
		-- 通用特效
		COMMON = 1,
		-- 特有特效，用特效代替icon
		SPECIAL = 2,
		-- 没有特效，显示icon
		NONE = 3,
	}

	-- 宝箱暂时没有通用类型特效
	-- 通用特效名字
	self.comAnimName = ""

	local gridInfo = self.grid:getGridInfo()

	-- dump(gridInfo, "desciption")
	local boxId = nil
	if gridInfo.ext ~= nil and gridInfo.ext.boxId then
		boxId= gridInfo.ext.boxId
	else	
		boxId= gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
	end

	-- echo("_________ boxId __________",boxId)

	self:setEventId(boxId)
end

-- 宝箱事件响应
function TowerBoxModel:onEventResponse()
	local params = {x=self.grid.xIdx,y=self.grid.yIdx}

	local boxId = self.eventId
	echo("boxId=",boxId)

	TowerControler:choseChestView(boxId,params)
end

-- 设置事件ID
function TowerBoxModel:setEventId(eventId)
	TowerBoxModel.super.setEventId(self,eventId)
	self.boxData = FuncTower.getBoxData(eventId)
end

-- 创建宝箱事件视图
function TowerBoxModel:createEventView()
	local boxId = self.eventId
	local boxData = self.boxData
	local animType = self.boxData.animType
	local viewCtn = self.grid.viewCtn
	-- 创建宝箱动画
	local boxView = self:createAnim(animType)

	if boxView == nil or animType == self.ANIM_TYPE.COMMON then
		local iconName = boxData.png
		-- 如果是一次性宝箱且已经领取
		local isOneOff,isGot = TowerMainModel:isOneOffBoxAndHaveGot(boxId)
		if isOneOff and isGot then
		 	iconName = boxData.openedPng
		 	if not iconName then
		 		echoError("________ 配表错误!!! 一次性宝箱没配已领取图标 ___________")
		 		return
		 	end
		end
		local iconPath = FuncRes.iconTowerEvent(iconName)
		local iconSprite = display.newSprite(iconPath)
		-- 通用特效，需要换装
		if animType == self.ANIM_TYPE.COMMON then
			FuncArmature.changeBoneDisplay(boxView,"node",iconSprite)
		else
			boxView = iconSprite
		end
	end
	
	local x = self.grid.pos.x
	local y = self.grid.pos.y
	local z = 0

	local tempX,tempY = boxView:getPosition()
	-- TODO 为什么要做这种特殊处理？
	-- if tonumber(boxId) == 1002 or tonumber(boxId) == 1001 then
	-- 	boxView:setPosition(tempX,tempY+10)
	-- else
	-- 	boxView:setPosition(tempX,tempY+30)
	-- end

	boxView:setPosition(tempX,tempY+10)
	
	self:initView(viewCtn,boxView,x,y,z)
	local zorder = self.grid:getZOrder() + 1
	self:setZOrder(zorder)
end

-- 创建宝箱动画
function TowerBoxModel:createAnim(animType)
	local ui = self.controler.ui

	local anim = nil
	if animType == self.ANIM_TYPE.NONE then
		return anim
	elseif animType == self.ANIM_TYPE.SPECIAL then
		local animName = self.boxData.anim
		anim = ui:createUIArmature(self.controler.animFlaName,animName,nil, false, GameVars.emptyFunc)
	elseif animType == self.ANIM_TYPE.COMMON then
		anim = ui:createUIArmature(self.controler.animFlaName,self.comAnimName,nil, false, GameVars.emptyFunc)
	end
	anim:startPlay(true)
	return anim
end

return TowerBoxModel
