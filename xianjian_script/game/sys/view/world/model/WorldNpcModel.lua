-- Author: ZhangYanguang
-- Date: 2017-05-02
-- 六界NPC model

local WorldMoveModel = require("game.sys.view.world.model.WorldMoveModel")
WorldNpcModel = class("WorldNpcModel",WorldMoveModel)

function WorldNpcModel:ctor( controler )
	WorldNpcModel.super.ctor(self,controler)
	
	self.walkDirection = {
		LEFT = -1,
		RIGHT =1
	}

	self.npcStatus = {
		STAND = 0,		--静止状态
		WALK = 1,		--走动状态
	}

	self.curNpcStatus = self.npcStatus.WALK

	-- NPC是否可以运动
	self.canWalk = false
end

function WorldNpcModel:initView(...)
	WorldNpcModel.super.initView(self,...)
	self:setNpcActionDirection(self.walkDirection.LEFT)
	self:setClickFunc()
end

function WorldNpcModel:registerEvent()
	WorldNpcModel.super.registerEvent(self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_TOUCH,self.onTouchMap,self)
end

--[[
	设置手指动画
	小手层级要在npc/主角之上(npc/主角层级是动态变化的)
	写死小手的层级(小手功能只在前机关生效，动态设置其层级比较麻烦，所以写死层级)
]]
function WorldNpcModel:createHandAnimView()
	if self.handAnimView == nil then
		local cacheHandView = self.viewCtn:getChildByName("npcHandAnim")

		if cacheHandView ~= nil then
			self.handAnimView = cacheHandView
		else
			local handAnimView = self.controler:getNpcHandAnim()
			self.handAnimView = handAnimView
			self.viewCtn:addChild(handAnimView,9999,"npcHandAnim")
		end
		
		self.handAnimView:pos(self.pos.x,self.pos.y+self.mySize.height/2)
		self.handAnimView:setVisible(true)
	end
end

function WorldNpcModel:setHandAnimVisible(visible)
	if self.handAnimView then
		self.handAnimView:setVisible(visible)
	else
		echo("self.handAnimView is nil")
	end
end

function WorldNpcModel:setNpcWalkDis(npcWalkDis)
	self.walkDis = npcWalkDis
	self.initPosX = self.pos.x
	self.initPosY = self.pos.y

	self.minPosX = self.pos.x - self.walkDis
	self.maxPosX = self.pos.x + self.walkDis
end

function WorldNpcModel:setIsLock(isLock)
	self._isLock = isLock
end

function WorldNpcModel:isLock()
	return self._isLock
end

function WorldNpcModel:setCanWalk(canWalk)
	self.canWalk = canWalk
end

function WorldNpcModel:setNpcActionStatus(status)
	if not self.canWalk and status == self.npcStatus.WALK then
		return
	end

	if self:isInScreen() then
		self.curNpcStatus = status
	else
		self.curNpcStatus = self.npcStatus.STAND
	end
end

function WorldNpcModel:setNpcActionDirection(direction)
	self.curNpcDirection = direction
	if self.curNpcDirection == self.walkDirection.LEFT then
		self.myView.currentAni:setRotationSkewY(180);
	else
		self.myView.currentAni:setRotationSkewY(0);
	end
end

function WorldNpcModel:getSortPos()
	self._sortPos.x = self.pos.x - self.mySize.width / 2
	self._sortPos.y = self.pos.y
	return self._sortPos
end

-- npc自由移动逻辑
function WorldNpcModel:freeMove()
	if self.curNpcStatus == self.npcStatus.STAND then
		return
	end

	local speed = 1
	local x,y = self.pos.x,self.pos.y

	local newX = nil

	if self.curNpcDirection == self.walkDirection.LEFT then
		speed = - speed
	end

	newX = x + speed

	if newX <= self.minPosX then
		newX = self.minPosX
		self:setNpcActionDirection(self.walkDirection.RIGHT)
	elseif newX >= self.maxPosX then
		newX = self.maxPosX
		self:setNpcActionDirection(self.walkDirection.LEFT)
	elseif newX == self.initPosX then
		self:setNpcActionStatus(self.npcStatus.STAND)
		-- self.npcSpine:delayCall(c_func(self.setNpcActionStatus,self), 3)
		local callBack = function()
			if not self._isClickNpc then
				self:setNpcActionStatus(self.npcStatus.WALK)
			end
		end
		self:pushOneCallFunc(90,c_func(callBack))
	end

	self:setPos(newX,y,0)
end

function WorldNpcModel:controlEvent()
	if self.canWalk then
		self:freeMove()

		if self:isInScreen() then
			if not self._isClickNpc then
				self:setNpcActionStatus(self.npcStatus.WALK)
			end
		else
			self:setNpcActionStatus(self.npcStatus.STAND)
		end
	end

	if not TutorialManager.getInstance():isNpcInWorldHalt() then
		self:updateTouchNodePos()
	end
end

function WorldNpcModel:checkHit()
	local charX = self.controler.charModel.pos.x
	-- local charY = self.controler.charModel.pos.y

	local npcX,npcY = self.pos.x,self.pos.y
	if self.controler.charModel:isMeetNpc() then
		if charX > npcX then
			self:setNpcActionDirection(self.walkDirection.RIGHT)
		else
			self:setNpcActionDirection(self.walkDirection.LEFT)
		end

		self:setNpcActionStatus(self.npcStatus.STAND)
	else
		if not self._isClickNpc then
			self:setNpcActionStatus(self.npcStatus.WALK)
		end
	end
end

-- @deprecated 需求原因，暂时废弃
function WorldNpcModel:_checkHit()
	-- local charX = self.controler.charModel.pos.x
	-- local charY = self.controler.charModel.pos.y

	-- local npcX,npcY = self.pos.x,self.pos.y
	-- if math.abs(charX - npcX) <= self.controler.npcMeetDis and math.abs(charY - npcY) <= self.controler.npcMeetDis then
	-- 	-- echo("相遇....self.isClickNpc=",self.isClickNpc,self.isMeetChar)
	-- 	if charX > npcX then
	-- 		self:setNpcActionDirection(self.walkDirection.RIGHT)
	-- 	else
	-- 		self:setNpcActionDirection(self.walkDirection.LEFT)
	-- 	end

	-- 	self:setNpcActionStatus(self.npcStatus.STAND)

	-- 	if not self.isMeetChar and self.isClickNpc then
	-- 		self.controler:onCharMeetNpc()
	-- 		self.isClickNpc = false
	-- 	end
	-- 	self.isMeetChar = true
	-- else
	-- 	self:setNpcActionStatus(self.npcStatus.WALK)
	-- 	self.isMeetChar = false
	-- end
end

--给场上英雄注册点击事件 点击后显示 明按
function WorldNpcModel:setClickFunc( )
	-- TODO 临时解决3d坐标导致的点击问题
	local scale = 1.1
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		scale = 1.3
	end
	
	local size = cc.size(self.mySize.width*scale,self.mySize.height*scale)
	local nd = display.newNode()
    nd:setContentSize(size)
    nd:pos(-size.width / 2,0)
	nd:addto(self.myView,1)

	--[[
	local color = color or cc.c4b(255,0,0,120)
	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(size)
	--]]
	self.touchNode = nd
	self.touchSize = size

	nd:setTouchedFunc(c_func(self.onClickNpc,self),nil,true,c_func(self.onClickNpcBegin,self),c_func(self.onClickNpcMove,self))
end

-- TODO 临时解决bug
-- NPC在左侧时，左半身点不中，点击区域偏右，同理在右侧也一样
function WorldNpcModel:updateTouchNodePos()
	if self.touchNode and self.touchSize then
		local offsetX = 0
		local worldPoint = self:getWorldPos()
		offsetX = (worldPoint.x - display.width/2) / display.width/2 * 500
		self.touchNode:setPositionX(-self.touchSize.width/2+offsetX)
	end
end

function WorldNpcModel:onTouchMap()
	self._isClickNpc = false
	self:setNpcActionStatus(self.npcStatus.WALK)
end

function WorldNpcModel:onClickNpcBegin()
	FilterTools.setFlashColor(self.myView,"worldHighLight")
end

function WorldNpcModel:onClickNpcMove()
	FilterTools.clearFilter(self.myView)
end

function WorldNpcModel:onClickNpc( )
	FilterTools.clearFilter(self.myView)
	if not self.controler._canClickNpc then
		return
	end
	-- 如果是序章衔接，点击npc时直接触发
	if PrologueUtils:showPrologueJoinAnim() then
		self.controler:onCharMeetNpc()
		return
	end

	-- TODO 修改为点击npc，立即停止运动
	self._isClickNpc = true
	self:setNpcActionStatus(self.npcStatus.STAND)
	self.controler:onClickNpc(self)
end

function WorldNpcModel:isClickNpc()
	return self._isClickNpc
end

function WorldNpcModel:setIsClickNpc(isClick)
	self._isClickNpc = isClick
end

function WorldNpcModel:getCenterWorldPos()
	local point 
	if self.viewCtn then
		point = self.viewCtn:convertToWorldSpaceAR(cc.p(self.pos.x,self.pos.y+self.mySize.height/2));
	else
		point = GameVars.emptyPoint
	end

	return point
end

--[[
	npc为序章衔接特效写死动作
]]
function WorldNpcModel:setScaleX(scaleX)
	if self.myView then
		self.myView.currentAni:setScaleX(scaleX)
	end
end

-- TODO 临时解决3d坐标转到导致的判断屏幕内不准确的问题
-- 获取view边界信息
function WorldNpcModel:getBorderInfo()
	local offsetX1 = GameVars.width * 0.21
	local offsetX2 = GameVars.width * 0.18

	local offsetY1 = GameVars.height * 0.21
	local offsetY2 = GameVars.height * 0.17

	local info = {}
	local minX = -self.mySize.width / 2 - GameVars.UIOffsetX + offsetX1
	local maxX = GameVars.width + self.mySize.width / 2 + GameVars.UIOffsetX - offsetX2

	local minY = -self.mySize.height - GameVars.UIOffsetY + offsetY1
	local maxY = GameVars.height + GameVars.UIOffsetY - offsetY2
 
	info.minX = minX
	info.maxX = maxX
	info.minY = minY
	info.maxY = maxY

	return info
end

return WorldNpcModel
