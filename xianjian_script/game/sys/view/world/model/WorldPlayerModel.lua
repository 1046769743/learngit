--[[
	Author: ZhangYanguang
	Date: 2017-06-01
	六界第三方玩家model
]]

local WorldBaseCharModel = require("game.sys.view.world.model.WorldBaseCharModel")
WorldPlayerModel = class("WorldPlayerModel",WorldBaseCharModel)

function WorldPlayerModel:ctor( controler )
	WorldPlayerModel.super.ctor(self,controler)
	self.baseScale = controler.mapCreator.playerScale
	
	self.walkDirection = {
		LEFT = -1,
		RIGHT = 1
	}

    self._isLock = false
end

function WorldPlayerModel:registerEvent()
	WorldPlayerModel.super.registerEvent(self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_MAP_TOUCH,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_NPC,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_SPACE,self.onTouchMap,self)
	EventControler:addEventListener(WorldEvent.WORLDEVENT_CLICK_ONE_PLAYER,self.onClickOnePlayer,self)
end

function WorldPlayerModel:initView(...)
	WorldPlayerModel.super.initView(self,...)

	self:setClickFunc()
end

function WorldPlayerModel:setName(name)
	self.name = name
end

function WorldPlayerModel:getName()
	return self.name
end

function WorldPlayerModel:setNameView(nameView)
	self.nameView = nameView
	nameView:setScale(self.viewScale)
	self.myView:addChild(nameView)
end

function WorldPlayerModel:setIsLock(isLock)
	self._isLock = isLock
end

function WorldPlayerModel:isLock()
	return self._isLock
end

function WorldPlayerModel:getAbsSpeed()
	local speed = math.sqrt(self.speed.x*self.speed.x+self.speed.y*self.speed.y)
	return speed
end

function WorldPlayerModel:setIsRobot(isRobot)
	self._isRobot = isRobot
end

function WorldPlayerModel:isRobot()
	return self._isRobot
end

function WorldPlayerModel:setPlayerId(playerId)
	self.playerId = playerId
end

function WorldPlayerModel:getPlayerId()
	return self.playerId
end

function WorldPlayerModel:setTargetSpace(targetSpace)
	self.targetSpace = targetSpace
end

function WorldPlayerModel:getTargetSpace()
	return self.targetSpace
end

function WorldPlayerModel:setTargetPos(targetPos)
	self.targetPos = targetPos
	self:moveToPoint(targetPos)
end

function WorldPlayerModel:moveToPoint(targetPoint, speed,moveType )
	WorldPlayerModel.super.moveToPoint(self,targetPoint, speed,moveType)
	--映射view的视图
	self:mapViewAction(self.ang * 180/math.pi)

	local mySize = self.charActionSize[self.charFace]
	self:setViewSize(mySize)
end

--[[
function WorldPlayerModel:setActionDirection(direction)
	self.curActionDirection = direction
	if self.curActionDirection == self.walkDirection.LEFT then
		self.myView.currentAni:setRotationSkewY(180);
	else
		self.myView.currentAni:setRotationSkewY(0);
	end
end
]]

function WorldPlayerModel:onMoveToPointCallBack()
	-- echo("\nWorldPlayerModel onMoveEndCallBack....")
	-- self.myView:playLabel("stand");
	-- 玩家进入地标
	self.controler:onPlayerEnterSpace(self)
end

function WorldPlayerModel:setZOrder( zorder )
	WorldPlayerModel.super.setZOrder(self,zorder)
	if self.nameView then
		self.nameView:zorder(zorder)
	end
	if self.playerInfoCtn then
		self.playerInfoCtn:zorder(zorder)
	end
end

function WorldPlayerModel:getSortPos()
	self._sortPos.x = self.pos.x - self.mySize.width / 2
	self._sortPos.y = self.pos.y
	return self._sortPos
end

function WorldPlayerModel:dummyFrame()
	self:updateNamePos()
	self:updatePlayerInfoView()
end

function WorldPlayerModel:updateNamePos()
	if self.nameView then
		-- local x,y = self.pos.x,self.pos.y
		-- self.nameView:pos(x,y+self.mySize.height+30)
		self.nameView:pos(15,self.mySize.height+80)
	end
end

function WorldPlayerModel:updatePlayerInfoView( )
	if self.playerInfoCtn then
		local x,y = self.pos.x,self.pos.y
		local viewX = x
		local viewY = y

		local ationDirection = self:getActionDirection()

		if ationDirection == 1 then
			viewX = x + 30
			viewY = y + self.mySize.height + 50
		else
			viewX = x - 140
			viewY = y + self.mySize.height + 50
		end

		self.playerInfoCtn:pos(viewX,viewY)
	end
end

--给场上英雄注册点击事件 点击后显示 明按
function WorldPlayerModel:setClickFunc( )
	local nd = display.newNode()
	local color = color or cc.c4b(255,0,0,120)
	
	--[[
	-- 测试代码
  	local layer = cc.LayerColor:create(color)
    nd:addChild(layer)
    nd:setTouchEnabled(true)
    nd:setTouchSwallowEnabled(true)
    layer:setContentSize(self.mySize)
	]]

    nd:setContentSize(self.mySize)
    nd:pos(-self.mySize.width / 2,self.mySize.height / 2)
	
	-- nd:setContentSize(cc.size(figure,figure) )
	nd:addto(self.myView,1)
	nd:setTouchedFunc(c_func(self.onClickPlayer,self),nil,true)
end

-- 点击了一个第三方玩家
function WorldPlayerModel:onClickOnePlayer(data)
	local playerObj = data.params.player
	if playerObj ~= self then
		self:onTouchMap()
	end
end

function WorldPlayerModel:onTouchMap()
	self:setIsLock(false)
	
	if self.isShowMenu then
		self:playPlayInfoViewAnim()
	end
end

function WorldPlayerModel:onClickPlayer(  )
	-- echo("onClickPlayer==",self:getPlayerId())
	-- 新手引导中屏蔽点击事件
	if TutorialManager.getInstance():isNpcInWorldHalt() then
		return
	end

	self:playPlayInfoViewAnim()
	self.controler:onClickPlayer(self)
end

-- 创建玩家详情信息
function WorldPlayerModel:createPlayerInfoView()
	if self.playerInfoCtn then
		-- self.playerInfoCtn:removeAllChildren()
		self.playerInfoCtn:setVisible(true)
	else
		self.playerInfoCtn = display.newNode()
		self.viewCtn:addChild(self.playerInfoCtn)

		local playerInfo = self.controler:getPlayerInfo(self:getPlayerId())
		local playerInfoView = WindowsTools:createWindow("CompPlayerInfoView")
	    playerInfoView:setPlayerInfo(playerInfo)
	    playerInfoView:setScale(0.85)
	    self.playerInfoCtn:addChild(playerInfoView)

	    local anim = self.controler.mapUI:createUIArmature("UI_common","UI_common_tubiaofeiru", 
	        	self.playerInfoCtn, false, GameVars.emptyFunc);
	    FuncArmature.changeBoneDisplay(anim, "layer2", playerInfoView);

	    local clickPlayerInfoView = function ()
	        FriendViewControler:showPlayer(self:getPlayerId(), playerInfo)
	    end

	    playerInfoView:setTouchedFunc(c_func(clickPlayerInfoView), nil,true);

	    -- 设置反旋转
	    self.controler:setViewRotation3DBack(self.playerInfoCtn)
	end
end

function WorldPlayerModel:playPlayInfoViewAnim()
	self.isShowMenu = not self.isShowMenu
	if self.isShowMenu then
		self:createPlayerInfoView()
	else
		-- self.playerInfoCtn:removeAllChildren()
		self.playerInfoCtn:setVisible(false)
	end
end

function WorldPlayerModel:deleteMe()
	WorldPlayerModel.super.deleteMe(self)
	if self.playerInfoCtn then
		self.playerInfoCtn:removeFromParent()
	end
end

return WorldPlayerModel
