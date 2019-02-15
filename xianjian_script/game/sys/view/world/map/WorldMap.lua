--[[
	Author: 张燕广
	Date:2017-04-17
	Description: 六界新版大地图，动态创建与销毁地图瓦块
]]

local WorldMap  = class("WorldMap",function ()
	return display.newNode()
end)

function WorldMap:ctor(config,controler)
	self.mapConfig = config
	self.mapControler = controler
	self.mapUI = controler.mapUI

	self:initData()
	self:initMap()
end

function WorldMap:initData()
	self.isMapInit = true

	-- 所有瓦块列表
    self.allTileMapList = {}
    -- 缓存的瓦块列表
    self.tileMapObjCache = {}
    -- 将要创建的瓦块列表
    self.toCreateList = {}
    -- 将要销毁的瓦块列表
    self.toDestroyList = {}

    self.worldMoveSpeed = {}
end

function WorldMap:initMap(config)
	self:loadMapConfig()
	self.worldCtn = display.newNode():addTo(self)

	if self.mapControler.isMapLeftDown then
		self.worldCtn:pos(0,GameVars.height)
	end

	-- 3D透视设置整个地图世界的缩放
	if self.mapControler.openRotation3D then
		self.worldCtn:setScale(self.mapControler.mapScale)
	end

	-- UI层
	self.uiNode = display.newNode():addTo(self.mapUI,-1)

	self.worldNode = display.newNode():addTo(self.worldCtn)
	-- 世界根据主角坐标而移动
	-- self.worldNode:pos(0,GameVars.height)

	-- 地图世界各层级由下至上如下
	-- 地图层
	self.dragNode = display.newNode():addTo(self.worldNode)
	-- 地图山体层
	self.mapMontainNode = display.newNode():addTo(self.worldNode)
	-- 人物影子层(山体之下，地标之上)
	self.shadowNode = display.newNode():addTo(self.worldNode)

	-- 地标建筑层
	self.spaceNode = display.newNode():addTo(self.worldNode)

	-- 神界地图层
	self.godMapNode = display.newNode():addTo(self.worldNode)
	-- 神界山体层
	self.godMontainNode = display.newNode():addTo(self.worldNode)
	-- 神界地标层
	self.godSpaceNode = display.newNode():addTo(self.worldNode)

	-- 人物层(主角、npc、其他玩家等)
	self.charNode = display.newNode():addTo(self.worldNode)

	self:initWorldToucheNode()
	self:initMapToucheNode()
	self:setMapRotation3D()

    self:registerGestureEvent()

    echo("\n\n---------------------GameVars info---------------------")
    echo("GameVars width,height",GameVars.width,GameVars.height)
    echo("GameVars ui offset info ",GameVars.UIOffsetX,GameVars.UIOffsetY)
end

function WorldMap:setMapRotation3D()
	if self.mapControler.openRotation3D then
		self.mapControler:setViewRotation3D(self)
		-- self.mapControler:setViewRotation3DBack(self.uiNode)
	end
end

--[[
	初始化地图背景触摸层
	该层在地图上所有人物&地标之下
]]
function WorldMap:initMapToucheNode()
	local onTouchMapBegin = function(event)
		-- echo("\n地图map层 onTouchMapBegin name=",event.name,self.mapControler:isMapTouchEnable())
		if not self.mapControler:isMapTouchEnable() then
			return
		end
		EventControler:dispatchEvent(WorldEvent.WORLDEVENT_MAP_TOUCH)

		
	end

	local onTouchMapMove = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end
	end

	local onTouchMapEnd = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end

		-- 2017-07-20 修改该代码解决主角指引动画偶尔不显示bug
	    if not self:isWorldMoving() then
	    	local charTargetPos = nil
	    	
	    	-- TODO 临时解决坐标转换问题
	    	-- if device.platform == "ios" or device.platform == "android" then
	    	if true then
	    		-- charTargetPos = self.charNode:convertToNodeSpaceAR(event)
	    		charTargetPos = self:turnWorldPosOffset(event)
	    	else
	    		if self.mapControler.openRotation3D then
		    		charTargetPos = AppHelper:transform3DPoint(self.charNode,event.x,event.y)
		    	else
		    		charTargetPos = self.charNode:convertToNodeSpaceAR(event)
		    	end
	    	end

	    	-- local charTargetPos2 = self.charNode:convertToNodeSpaceAR(event)
	    	-- dump(charTargetPos,"111-----------------")

	    	-- dump(charTargetPos2,"2222-----------------")
		    self.mapControler:moveChar(charTargetPos)
	    	self:playGuildAnim(charTargetPos)
	    end
	end

	if self.mapControler.isMapLeftDown then
		-- 层级在UI层之下
		self.touchNode = display.newNode():addTo(self,-1)
		self.touchNode:pos(-300,0)
		self.touchNode:setContentSize(cc.size(GameVars.width*2,GameVars.height*2))
	else
		self.touchNode = display.newNode():addTo(self.mapUI,-2)
		self.touchNode:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
		self.touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
	end

    self.touchNode:setTouchedFunc(c_func(onTouchMapEnd), nil, true
    	, c_func(onTouchMapBegin), c_func(onTouchMapMove))
    
    self.touchNode:setTouchSwallowEnabled(false)
end


function WorldMap:turnWorldPosOffset(event  )
	
	local resultPos = self.charNode:convertToNodeSpaceAR(event)
	local offsetPos = Equation.adjust3Dpos(event)
	resultPos.x = resultPos.x + offsetPos.x
	resultPos.y = resultPos.y + offsetPos.y
	return resultPos

end


--[[
	初始化地图世界触摸层，整个地图世界的拖动
	该层在地图上所有人物&地标之上
]]
function WorldMap:initWorldToucheNode()
	local worldTouchNode = nil

	local onWorldTouchBegin = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end

		self.mapTouchState = event.name

		local mapX,mapY = self.worldNode:getPosition()
		self.downX = event.x - mapX
		self.downY = event.y - mapY

		-- self.lastX =  self.downX
		-- self.lastY = self.downY
		self.lastX =  event.x 
		self.lastY = event.y 

		--停止地图缓动
		EaseMapControler:stopEaseMap()

	end

	local onWorldTouchMove = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end

		self.mapTouchState = event.name

		local x = event.x
    	local y = event.y

    	if self.lastX and self.lastY and self.downX and self.downY then
	    	local absXDis = math.abs(x - self.lastX)
	    	local absYDis = math.abs(y - self.lastY)
	    	if absXDis >= 2 or absYDis >= 2 then
		    		-- self.mapControler.charModel:setIsLock(false)
	    		self.mapControler.lockPlayerModel:setIsLock(false)
				local worldX,worldY = self:getMapBorderPosition(event.x - self.downX,event.y - self.downY)
				self.worldNode:pos(worldX,worldY)

				-- 检查地图x是否已移动到边界
				if self:checkMapBorderPositionX(event.x - self.downX) then
					self.worldMoveSpeed.x = 0
				else
					self.worldMoveSpeed.x = x - self.lastX
				end

				-- 检查地图y是否已移动到边界
				if self:checkMapBorderPositionY(event.y - self.downY) then
					self.worldMoveSpeed.y = 0
				else
					self.worldMoveSpeed.y = y - self.lastY
				end
			end
			
			self.lastSpeed = {x =x - self.lastX,y = y - self.lastY }
			self.lastX = x
			self.lastY = y
	    end
	end

	local onWorldTouchEnd = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end

		self.mapTouchState = event.name
	end

	local onEaseMoveFunc = function (x,y  )
		local oldx,oldy = self.worldNode:getPosition()
		local worldX,worldY = self:getMapBorderPosition(oldx +x ,oldy + y)
		self.worldNode:pos(worldX,worldY)
	end

	local onWorldGlobalEnd = function(event)
		if not self.mapControler:isMapTouchEnable() then
			return
		end
		self.mapTouchState = event.name
		if not self.lastSpeed then
			return
		end
		--开始惯性缓动
		EaseMapControler:startEaseMap(worldTouchNode,onEaseMoveFunc ,nil,self.lastSpeed.x,self.lastSpeed.y,easeNum)
		self.lastSpeed.x = 0
		self.lastSpeed.y = 0
	end

	
	--[[
	local color = color or cc.c4b(255,255,255,120)
  	local layer = cc.LayerColor:create(color)
    layer:setContentSize(cc.size(GameVars.width,GameVars.height))
    layer:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
    layer:addTo(self.mapUI,2)
	]]
	if self.mapControler.isMapLeftDown then
		worldTouchNode = display.newNode():addTo(self,1)
		worldTouchNode:pos(-300,0)
		worldTouchNode:setContentSize(cc.size(GameVars.width*2,GameVars.height*2))
	else
		worldTouchNode = display.newNode():addTo(self.mapUI.ctn_mapNode,0)
		worldTouchNode:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
		worldTouchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
	end
	
    worldTouchNode:setTouchedFunc(c_func(onWorldTouchEnd), nil, true, c_func(onWorldTouchBegin), c_func(onWorldTouchMove),true,c_func(onWorldGlobalEnd))
    worldTouchNode:setTouchSwallowEnabled(false)
end

function WorldMap:getWorldMapLayer()
	return self.worldNode
end

function WorldMap:getPlayerLayer()
	return self.charNode
end

function WorldMap:getSpaceLayer()
	return self.spaceNode
end

function WorldMap:getPlayerShadowLayer()
	return self.shadowNode
end

function WorldMap:getUILayer()
	return self.uiNode
end

function WorldMap:setPreLoadTilesNum(preLoadTilesNum)
	self.preLoadTilesNum = preLoadTilesNum
end

-- 注册手势处理事件
function WorldMap:registerGestureEvent()
	local lastDis = nil
	local curDis = nil

	local function onTouchesBegan(touches, event)
		if #touches >= 2 then
			self.isSwitch = false
			local point1 = touches[1]:getLocationInView()
			local point2 = touches[2]:getLocationInView()

			lastDis = math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
			return true
		end
	end

	local function onTouchesMoved(touches, event)
		if #touches >= 2 then
			local point1 = touches[1]:getLocationInView()
			local point2 = touches[2]:getLocationInView()

			curDis = math.sqrt((point1.x - point2.x) * (point1.x - point2.x) + (point1.y - point2.y) * (point1.y - point2.y));
			if lastDis == nil then
				lastDis = curDis
			end

			if lastDis and curDis then
				if curDis > lastDis and curDis - lastDis > 30 then
					-- echo("手势放大")
				elseif lastDis > curDis and lastDis - curDis > 30 then
					echo("worldmap手势缩小")
					if not self.isSwitch then
						self.isSwitch = true
						self.mapControler:showAerialMap()
					end
				end
			end

			return true
		end
	end

	local function onTouchesEnded(touches, event)

		if #touches >= 2 then
			lastDis = nil
			curDis = nil
			return true
		end
	end

	local listener = cc.EventListenerTouchAllAtOnce:create()    
	self.touchListener = listener

    listener:registerScriptHandler(onTouchesBegan,cc.Handler.EVENT_TOUCHES_BEGAN )
    listener:registerScriptHandler(onTouchesMoved,cc.Handler.EVENT_TOUCHES_MOVED )
    listener:registerScriptHandler(onTouchesEnded,cc.Handler.EVENT_TOUCHES_ENDED )

    local eventDispatcher = self.touchNode:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, self.touchNode)
end

-- 解析地图配置
function WorldMap:loadMapConfig()
	self.spaceList = self.mapConfig.space

	self.tileWidth = self.mapConfig.perWidth
	self.tileHeight = self.mapConfig.perHeight

	self.mapRect = self.mapConfig.rect

	self.mapFromXIndex = self.mapConfig.fromX
	self.mapFromYIndex = self.mapConfig.fromY

	self.mapToXIndex = self.mapConfig.toX
	self.mapToYIndex = self.mapConfig.toY

	self.mapImgInfo = self.mapConfig.info

	self.minMapX = -(self.mapRect.width  - math.abs(self.mapRect.x) - GameVars.width)
	self.maxMapX = math.abs(self.mapRect.x)

	self.minMapY = self.mapRect.y
	self.maxMapY = self.mapRect.height - math.abs(self.mapRect.y) - GameVars.height
	
	-- 地图边界偏移值
	self.mapOffsetX = 400
	self.mapOffsetY = 200

	if self.mapControler.openRotation3D then
		self.maxMapY = self.maxMapY - self.mapOffsetY
		self.minMapX = self.minMapX + self.mapOffsetX
	end
	
	echo("\n\nx坐标范围===",self.minMapX,self.maxMapX)
	echo("y坐标范围===",self.minMapY,self.maxMapY,"\n\n")

	-- 地图上物体坐标范围
	self.mapInnterRect = {
		minX = 0,
		maxX = self.mapRect.width - self.mapOffsetX,
		minY = - self.mapRect.height + self.mapOffsetY,
		maxY = 0
	}
end

-- 设置一步到位移动世界
function WorldMap:setOneStepMove()
	self.isOneStepMove = true
end

-- 每帧刷新方法
function WorldMap:updateFrame(dt)
	if self.isMapInit then
		self.isOneStepMove = true
	end

	self:updateWorld(dt)
	self:checkMapBorder()
	self:updateTileMap(dt)
	self:updateGuildAnim()

	if self.isMapInit then
		self.isMapInit = false
	end
end

-- 更新地图背景,mapNode层内容
function WorldMap:updateTileMap()
	self:updateTileIndex()

	-- if self.isChangeIndex and self.isMapInit then
	if self.isChangeIndex then
		self:updateToCreateList()
		self:updateToDestroyList()
		self:refreshTileMap()
	end
end

-- 更新整个地图世界
function WorldMap:updateWorld()
	if self.isMoveWorld then
		return
	end

	if not self.mapControler.lockPlayerModel then
		return
	end

	if not self.mapControler.lockPlayerModel:isLock() then
		return
	end

	local playerModel = self.mapControler.lockPlayerModel
    local x1,y1 = playerModel.pos.x,playerModel.pos.y

    -- TODO 3D透视缩小了整个地图世界，导致角色无法居中对齐
    -- x1 = GameVars.width / 2 - x1 + GameVars.width * 0.126
    x1 = GameVars.width / 2 - x1 + (GameVars.width / 2 * (1-self.mapControler.mapScale))

    -- 加偏移值，主角中心放置在屏幕中心
    y1 = -(GameVars.UIOffsetY + GameVars.height / 2 + self.mapControler.charCenterOffsetY) - y1

    if self.isOneStepMove then
    	self.worldNode:pos(x1,y1)
    	EaseMapControler:stopEaseMap()
    	self.isOneStepMove = false
	  	return
    end

    local x2,y2 = self.worldNode:getPosition()
    local dx = x1 - x2
    local dy = y1 - y2
    local ang = math.atan2(dy, dx)
    --缓动运动过去
    local dis = math.sqrt( dx*dx+ dy*dy )
    local minSpeed = 15
    local speed = dis * 0.1
    if speed > 30 then
        speed = 30
    end
    if speed < 15 then
        x2 = x1
        y2 = y1
    else
        x2 = x2 + speed*math.cos(ang)
        y2 = y2 +speed*math.sin(ang)
    end

    self.worldNode:pos(x2,y2)
end

-- 更新瓦块起始xy索引
function WorldMap:updateTileIndex()
	self.isChangeIndex = false

	local x,y = self.worldNode:getPosition()

	if x >= 0 then
		self.fromXIndex = - math.ceil((x / self.tileWidth))
	else
		self.fromXIndex = math.floor((math.abs(x) / self.tileWidth))
	end

	if y >= 0 then
		self.fromYIndex = math.floor((y / self.tileHeight))
	else
		self.fromYIndex = - math.ceil((math.abs(y) / self.tileHeight))
	end
		
	-- fromTileMap 在屏幕可视区域内的宽和高
	local fromTileMapVisWidth = self.tileWidth - math.abs(x) % self.tileWidth
	local fromTileMapVisHeight = math.abs(y) % self.tileHeight
	if self.fromXIndex < 0 then
		fromTileMapVisWidth = self.tileWidth - fromTileMapVisWidth
	end

	if self.fromYIndex >= 0 then
		fromTileMapVisHeight = self.tileHeight - fromTileMapVisHeight
	end

	-- echo("fromTileMapVisWidth=",fromTileMapVisWidth)
	-- echo("fromTileMapVisHeight=",fromTileMapVisHeight)

	self.toXIndex = self.fromXIndex + math.ceil( (GameVars.width - fromTileMapVisWidth ) / self.tileWidth)
	self.toYIndex = self.fromYIndex + math.ceil( (GameVars.height - fromTileMapVisHeight ) / self.tileHeight)

	if self.fromXIndex == -0 then
		self.fromXIndex = 0
	end

	if self.toXIndex == -0 then
		self.toXIndex = 0
	end

	if self.fromYIndex == -0 then
		self.fromYIndex = 0
	end

	if self.toYIndex == -0 then
		self.toYIndex = 0
	end

	local preLoadTilesNum = self.preLoadTilesNum or 0
	self.fromXIndex = self.fromXIndex - preLoadTilesNum
	self.toXIndex = self.toXIndex + preLoadTilesNum

	self.fromYIndex = self.fromYIndex - preLoadTilesNum
	self.toYIndex = self.toYIndex + preLoadTilesNum

	self.fromXIndex = math.max(self.fromXIndex,self.mapFromXIndex)
	self.toXIndex = math.min(self.toXIndex,self.mapToXIndex)

	self.fromYIndex = math.max(self.fromYIndex,self.mapFromYIndex)
	self.toYIndex = math.min(self.toYIndex,self.mapToYIndex)

	if self.fromXIndex ~= self.lastFromXIndex or self.toXIndex ~= self.lastToXIndex
		or self.fromYIndex ~= self.lastFromYIndex or self.toYIndex ~= self.lastToYIndex then
		self.isChangeIndex = true

		-- echo("\n--------------预加载 preLoadTilesNum=",preLoadTilesNum)
		-- echo("x index 可视范围=",self.fromXIndex,self.toXIndex)
		-- echo("y index 可视范围=",self.fromYIndex,self.toYIndex)

		self.lastFromXIndex = self.fromXIndex
		self.lastToXIndex = self.toXIndex

		self.lastFromYIndex = self.fromYIndex
		self.lastToYIndex = self.toYIndex
	end
end

-- 生成需要创建的的瓦块地图列表
function WorldMap:updateToCreateList()
	self.allTileMapList = {}
	self.toCreateList = {}

	for i=self.fromXIndex,self.toXIndex do
		for j=self.fromYIndex,self.toYIndex do
			local key = self:indexNum2Key(i, j)
			self.allTileMapList[key] = true

			if self.tileMapObjCache[key] == nil then
				self.toCreateList[#self.toCreateList+1] = key
			end
		end
	end
end

-- 生成需要销毁的瓦块地图列表
function WorldMap:updateToDestroyList()
	for k,v in pairs(self.tileMapObjCache) do
		if self.allTileMapList[k] == nil then
			self.toDestroyList[k] = true
		end
	end
end

-- 刷新地图
function WorldMap:refreshTileMap()
	-- 创建新的地图瓦块
	for i=1,#self.toCreateList do
		local key = self.toCreateList[i]
		self:createTileMapByKey(key,i)
	end

	-- TODO 后期优化可以根据不可见距离进行销毁
	for k,v in pairs(self.toDestroyList) do
		self:drestoryTileMapByKey(k)
		if self.toDestroyList[k] then
			self.toDestroyList[k] = nil
		end

		if self.tileMapObjCache[k] then
			self.tileMapObjCache[k] = nil
		end
	end
end

-- 播放指引动画
function WorldMap:playGuildAnim(targetPos)
	self.charTargetPos = targetPos

	local x = targetPos.x
	local y = targetPos.y

    local callBack = function()
        self.guildAnim:setVisible(false)
    end

    if not self.guildAnim then
        self.guildAnim = self.mapUI:createUIArmature("UI_shijieditu","UI_shijieditu_zhishi",nil, false, GameVars.emptyFunc)
        self.spaceNode:addChild(self.guildAnim,2)

        self.mapControler:setViewRotation3DBack(self.guildAnim)
    end

    self.guildAnim:pos(x,y)
    self:showGuildAnim(true)
    self.guildAnim:startPlay(true)
end

function WorldMap:updateGuildAnim()
	if self.guildAnim and self.charTargetPos then
		local x = self.mapControler.charModel.pos.x
		local y = self.mapControler.charModel.pos.y

		local disX = math.abs(x - self.charTargetPos.x)
		local disY = math.abs(y - self.charTargetPos.y)

		if disX <= 1 and disY <= 1 then
			self:showGuildAnim(false)
		end
	end
end

function WorldMap:showGuildAnim(visible)
	if self.guildAnim then
		self.guildAnim:setVisible(visible)
	end
end

function WorldMap:getCharLayerVisRect()
	local mapX,mapY = self.worldNode:getPosition()
	local rect = {minX=-mapX,maxX= GameVars.width-mapX,minY=-mapY-GameVars.height,maxY=-mapY}
	-- echo("mapX,mapY===",mapX,mapY)
	-- dump(rect)
	return rect
end

-- 获取地图可见区域
function WorldMap:getMapVisRect()
	local mapX,mapY = self.worldNode:getPosition()
	local rect = {minX=-mapX,maxX=GameVars.width-mapX,minY=mapY,maxY=GameVars.height+mapY}
	-- echo("mapX,mapY===",mapX,mapY)
	-- dump(rect)
	return rect
end

function WorldMap:checkMapBorderPositionX(_x)
	local x = _x
	if x <= self.minMapX or x >= self.maxMapX then
		return true
	end

	return false
end

function WorldMap:checkMapBorderPositionY(_y)
	local y = _y
	if y <= self.minMapY or y >= self.maxMapY then
		return true
	end

	return false
end

function WorldMap:getMapBorderPosition(_x,_y)
	local x = _x
	local y = _y
	if x <= self.minMapX then
		x = self.minMapX
	elseif x >= self.maxMapX then
		x = self.maxMapX
	end

	if y <= self.minMapY then
		y = self.minMapY
	elseif y >= self.maxMapY then
		y = self.maxMapY
	end

	-- echo("y范围====",self.minMapY,self.maxMapY)

	return x,y
end

-- 检查地图边界
function WorldMap:checkMapBorder()
	local x,y = self:getMapBorderPosition(self.worldNode:getPosition())
	-- echo("check boarder x=",x)
	-- echo("x范围====",self.minMapX,self.maxMapX)
	self.worldNode:pos(x,y)
end

function WorldMap:isWorldMoving()
	return self.mapTouchState == "moved"
end

function WorldMap:getWorldMoveSpeed()
	return self.worldMoveSpeed
end

function WorldMap:gertTargetCharPoint()
	return self.charTargetPos
end

function WorldMap:playMoveWorldAnim(frame,targetPos)
	EaseMapControler:stopEaseMap()
	self.worldNode:stopAllActions()
	local actMove = act.moveto(frame, targetPos.x, targetPos.y)
    self.worldNode:runAction(actMove)
end

-- 移动整个世界,worldNode层移动
function WorldMap:moveWorld(moveX,moveY,moveCallBack,timeSec)
	EaseMapControler:stopEaseMap()
	self.isMoveWorld = true

	local targetX = self.worldNode:getPositionX() + moveX
	local targetY = self.worldNode:getPositionY() + moveY

	local worldX,worldY = self:getMapBorderPosition(targetX,targetY)
	local frame = 20
	if not timeSec then
		timeSec = frame/40
	end
	local act_move = act.moveto(timeSec, worldX, worldY)

	local callBack = function()
		self.isMoveWorld = false
		if moveCallBack then
			moveCallBack()
		end
	end

	local acts = cc.Sequence:create(
		act_move,
		act.callfunc(callBack),nil
	)

	self.worldNode:stopAllActions()
    self.worldNode:runAction(acts)
end

function WorldMap:moveObj(obj,moveX,moveY)
	local targetX = obj:getPositionX() + moveX
	local targetY = obj:getPositionY() + moveY

	obj:stopAllActions()

	local frame = 20
	local act_move = act.moveto(frame/40, targetX, targetY)
    obj:runAction(act_move)
end

-- 同步创建瓦块地图
function WorldMap:createTileMapSyn(xIndex,yIndex)
	local tileImgPath = self:getTileImagePath(xIndex,yIndex)
	local tilePos = self:getTileImagePos(xIndex,yIndex)

	local tileMap = display.newSprite(tileImgPath)

	tileMap:anchor(0,1)
	tileMap:pos(tilePos.x,tilePos.y)

	self.dragNode:addChild(tileMap)

	-- 缓存
	local key = self:indexNum2Key(xIndex, yIndex)
	self.tileMapObjCache[key] = {obj=tileMap,visibleDist=0}
	self.toCreateList[key] = nil
end

-- 异步创建瓦块地图
function WorldMap:createTileMap(xIndex,yIndex)
	if self.isMapInit then
		self:createTileMapSyn(xIndex,yIndex)
		return
	end

	local tileImgPath = self:getTileImagePath(xIndex,yIndex)
	local tilePos = self:getTileImagePos(xIndex,yIndex)

	local callBack = function(tileMap,params)
		-- TODO 日志平台出现self.dragNode为nil的情况，暂未找到原因
		if not self.dragNode then
			return
		end

		tileMap:anchor(0,1)
		tileMap:pos(tilePos.x,tilePos.y)
		self.dragNode:addChild(tileMap,1)

		-- 缓存
		local key = self:indexNum2Key(xIndex, yIndex)
		self.tileMapObjCache[key] = {obj=tileMap,visibleDist=0}
		self.toCreateList[key] = nil
	end

	-- 强制同步创建
	local forceSync = true
	if forceSync then
		local tileMap = display.newSprite(tileImgPath)
		tileMap:anchor(0,1)
		tileMap:pos(tilePos.x,tilePos.y)
		self.dragNode:addChild(tileMap,1)

		-- 缓存
		local key = self:indexNum2Key(xIndex, yIndex)
		self.tileMapObjCache[key] = {obj=tileMap,visibleDist=0}
		self.toCreateList[key] = nil
	else
		display.newSpriteAsync(tileImgPath,callBack)
	end
end

function WorldMap:createTileMapByKey(key,frameIndex)
	local arr = string.split(key,"_")
	local xIndex,yIndex = self:indexKey2Num(arr[1],arr[2])
	self:createTileMap(xIndex,yIndex)
	-- self:delayCall(c_func(self.createTileMap,self,xIndex,yIndex), frameIndex%2 /30)
end

function WorldMap:drestoryTileMapByKey(key)
	local cache = self.tileMapObjCache[key]
	if cache then
		local tileMap = cache.obj
		if not tolua.isnull(tileMap) then
			tileMap:removeFromParent()
		end
	end
end

function WorldMap:indexKey2Num(xKeyIndex,yKeyIndex)
	local convert = function(keyIndex)
		local flag = string.sub(keyIndex,1,1)
		local num = tonumber(string.sub(keyIndex,2,string.len(keyIndex)))

		if flag == "z" then
			num = num
		elseif flag == "f" then
			num = -num
		end

		return num
	end

	if xKeyIndex and not yKeyIndex then
		return convert(xKeyIndex)
	elseif xKeyIndex and yKeyIndex then
		return convert(xKeyIndex),convert(yKeyIndex)
	end
end

function WorldMap:indexNum2Key(xNumIndex,yNumIndex)
	if xNumIndex then
		xNumIndex = tonumber(xNumIndex)
	end
	
	if yNumIndex then
		yNumIndex = tonumber(yNumIndex)
	end

	local convert = function(numIndex)
		local key = ""
		if numIndex >= 0 then
			key = "z" .. numIndex
		else
			key = "f" .. math.abs(numIndex)
		end

		return key
	end

	if xNumIndex and not yNumIndex then
		return convert(xNumIndex)
	elseif xNumIndex and yNumIndex then
		return convert(xNumIndex) .. "_" .. convert(yNumIndex)
	end
end

-- 获取瓦块图片坐标
function WorldMap:getTileImagePos(xIndex,yIndex)
	local x = xIndex * self.tileWidth
	local y = -(yIndex * self.tileHeight)

	-- echo("瓦片地图坐标(",xIndex,yIndex,")==",x,y)
	return cc.p(x,y)
end

-- 获取瓦块图片的路径
function WorldMap:getTileImagePath(xIndex,yIndex)
	local key = self:indexNum2Key(xIndex,yIndex)
	local imageName = self.mapImgInfo[key].tex

	return FuncRes.getWorldMapImagePath(imageName)
end

function WorldMap:deleteMe()
	self:unscheduleUpdate()
	self.touchNode:getEventDispatcher():removeEventListener(self.touchListener);
end

--[[
	整个地图世界播放动画
]]
function WorldMap:playWorldMapScaleAnim(moveX,moveY,fromScale,toScale,timeSec,callBack)
	local mapCtn = self.worldCtn
	local posx,posy = mapCtn:getPosition()
	local difScale = toScale - self.mapControler.mapScale

	moveX =   moveX + (- GameVars.width /2 * difScale)
	moveY =   moveY + GameVars.height /2 * difScale 

	local actCallBack = nil
	if callBack then
		actCallBack = act.callfunc(callBack)
	end

	local act = act.spawn(
			act.scaleto(timeSec,fromScale,toScale)
			,act.moveto(timeSec,moveX,moveY)
		,actCallBack,nil)

	mapCtn:stopAllActions()
	mapCtn:runAction(act)
end

function WorldMap:restWorldMap()
	local mapCtn = self.worldCtn
	mapCtn:setScale(self.mapControler.mapScale)
	mapCtn:pos(0,0)
end

return WorldMap

