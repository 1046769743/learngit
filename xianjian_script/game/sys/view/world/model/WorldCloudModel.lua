--[[
	Author: 张燕广
	Date:2017-11-02
	Description: 六界游云类
]]

local WorldMoveModel = require("game.sys.view.world.model.WorldMoveModel")
WorldCloudModel = class("WorldCloudModel",WorldMoveModel)

function WorldCloudModel:ctor( controler )
	WorldCloudModel.super.ctor(self,controler)

	self.cloudStatus = {
		INIT = 1,
		MOVE = 2,
		WILL_DIE = 3,
		DIEING = 4,
		DIE = 5
	}

	self.curStatus = self.cloudStatus.INIT

	self.canWalk = true
	self.moveSpeed = 1
	self.count =  0
	self.delayFrame = 480
end

function WorldCloudModel:initView(...)
	WorldCloudModel.super.initView(self,...)
end

function WorldCloudModel:registerEvent()
	WorldCloudModel.super.registerEvent(self)
end

function WorldCloudModel:setStatus(status)
	self.curStatus = status
end

function WorldCloudModel:dummyFrame()
	self.count = self.count + 1
	
	if self.curStatus == self.cloudStatus.INIT then
		self:starFreeMove()
	elseif self.curStatus == self.cloudStatus.MOVE then
		self:updateMove()
	elseif self.curStatus == self.cloudStatus.WILL_DIE then
		self:playDisAppearAnim()
	elseif self.curStatus == self.cloudStatus.DIEING then
		self:updateMove()
	elseif self.curStatus == self.cloudStatus.DIE then
		self:starFreeMove()
	end
end

-- 播放出现动画
function WorldCloudModel:playAppearAnim()
	local action = cc.Spawn:create(
		act.fadein(2)
	)

	local act = cc.Sequence:create(
		action,
		nil)

	self.myView:setVisible(true)
	self.myView:setOpacity(0)
	self.myView:stopAllActions()
	self.myView:runAction(act)
end

-- 播放消失动画
function WorldCloudModel:playDisAppearAnim()
	-- echo("cloud-云消失 ",self:isInScreen())
	-- 如果不在屏幕内
	if not self:isInScreen() then
		self:setStatus(self.cloudStatus.DIE)
		self.myView:setVisible(false)
		return
	end

	self:setStatus(self.cloudStatus.DIEING)
	local actCallBack = function()
		self.myView:opacity(255)
		self.myView:setVisible(false)
		self:setStatus(self.cloudStatus.DIE)
	end

	local action = cc.Spawn:create(
		act.fadeout(2)
	)

	local act = cc.Sequence:create(
		action,
		act.callfunc(actCallBack),
		nil)

	self.myView:stopAllActions()
	self.myView:runAction(act)
end

function WorldCloudModel:starFreeMove()
	self:setStatus(self.cloudStatus.MOVE)

	local callBack = function()
		if self.curStatus == self.cloudStatus.MOVE then
			self:setStatus(self.cloudStatus.WILL_DIE)
		end
	end

	local pos = self:getRandomPos()
	-- pos = {x=4671,y=-2600}
	self:setPos(pos.x,pos.y)
	self:playAppearAnim()
	self:pushOneCallFunc(self.delayFrame,c_func(callBack))
end

function WorldCloudModel:getRandomPos()
	local x = RandomControl.getOneRandomInt(50,GameVars.width/2+300)
	local y = RandomControl.getOneRandomInt(200,GameVars.height/2+300)
	local turnPos = {x=self._worldPos.x + x,y = self._worldPos.y + y}  
	return turnPos
end

function WorldCloudModel:updateMove()
	if not self:isInScreen() then
		-- self:setStatus(self.cloudStatus.WILL_DIE)
		self.myView:setVisible(false)
	else
		self.myView:setVisible(true)
	end

	local x,y = self.pos.x,self.pos.y
	local moveSpeedX = 0
	local moveSpeedY = 0

	if self.controler:isWorldMoving() then
		local moveSpeed = self.controler:getWorldMoveSpeed()
		-- echo("moveSpeed=",moveSpeed.x,moveSpeed.y)
		if self.lastMoveSpeed and self.lastMoveSpeed.x == moveSpeed.x 
			and self.lastMoveSpeed.y == moveSpeed.y then
			moveSpeedX = 1
			moveSpeedY = 0
		else
			if math.abs(moveSpeed.x) > 2 and math.abs(moveSpeed.x) < 40 then
				moveSpeedX = moveSpeed.x + 1
			elseif math.abs(moveSpeed.y) > 2 and math.abs(moveSpeed.y) < 40 then
				moveSpeedY = moveSpeed.y
			end
			
			self.lastMoveSpeed = moveSpeed
		end

		local newX = x + moveSpeedX / 2
		local newY = y + moveSpeedY / 2
		self:setPos(newX,newY,0)
	else
		moveSpeedX = 1
		local newX = x + moveSpeedX / 2
		local newY = y + moveSpeedY / 2
		self:setPos(newX,newY,0)

		-- if self.count % 2 == 0 then
		-- 	local newX = x + moveSpeedX
		-- 	local newY = y + moveSpeedY
		-- 	self:setPos(newX,newY,0)
		-- end
	end
end

function WorldCloudModel:checkRoation3DBack()
	return false
end

function WorldCloudModel:deleteMe()
	WorldCloudModel.super.deleteMe()
	self.cloudStatus = nil
end

return WorldCloudModel
