--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:30:52
--Description: 精英场景 机关地图
--


local EliteMap  = class("EliteMap",function ()
	return display.newNode()
end)

function EliteMap:ctor(mapData,mapControler)
	self.mapData = mapData
	self.mapControler = mapControler

	self:initData()
end

-- 初始化地图数据
function EliteMap:initData()
	self.xNum = table.length(self.mapData)
	self.yNum = table.length(self.mapData["1"])

	local gridWidth = self.mapControler.gridWidth
	local gridHeight = self.mapControler.gridHeight

	self.rightDoorWidth = 320

	local mapTailOffsetX = 170
	self.minMapX = 0
	self.maxMapX = (self.xNum / 2) * gridWidth - (GameVars.width - self.rightDoorWidth) + mapTailOffsetX

	-- 地图格子皮肤
	self.mapGridSkin =  "UI_elite_jiguan" 
end

-- 初始化地图视图
function EliteMap:initMap()
	self:initLayers()
end

-- 初始化层级
function EliteMap:initLayers()
	-- 整个地图世界层
	self.worldLayer = display.newNode():addto(self)
	self.worldLayer:pos(0,0)
	-- 测试代码
	-- local ttf = display.newTTFLabel({text = "(0,0)", size = 18, color = cc.c3b(255,0,0)})
	-- ttf:zorder(100)
	-- ttf:pos(0,0)
	-- self:addChild(ttf,100)

	-- local ttf1 = display.newTTFLabel({text = "(GameVars.width,0)", size = 18, color = cc.c3b(255,0,0)})
	-- ttf1:zorder(100)
	-- ttf1:pos(GameVars.width/2,0)
	-- self:addChild(ttf1,100)

	-- local ttf2 = display.newTTFLabel({text = "(GameVars.gameResWidth,0)", size = 18, color = cc.c3b(255,0,0)})
	-- ttf2:zorder(100)
	-- ttf2:pos(GameVars.gameResWidth,0)
	-- -- ttf2:pos(0,-GameVars.height)
	-- self:addChild(ttf2,100)

	-- local ttf3 = display.newTTFLabel({text = "(GameVars.width,-GameVars.height)", size = 18, color = cc.c3b(255,0,0)})
	-- ttf3:zorder(100)
	-- ttf3:pos(GameVars.width,-GameVars.height)
	-- self:addChild(ttf3,100)


	-- 整个世界最底层背景层(锁妖塔地图后面的场景等在该层)
	self.backLayer = display.newNode():addto(self.worldLayer):pos(0,-GameVars.UIOffsetY )

	-- 整个世界中间tower地图层(锁妖塔地图中char monster grid npc box 等在该层)
	self.middleLayer = display.newNode():addto(self.worldLayer)

	-- 游戏前景层(grid 角色影子)
	self.gameBackLayer = display.newNode():addto(self.middleLayer)
	
	-- 游戏中间层(char monster npc box等)	
	self.gameMiddleLayer = display.newNode():addto(self.middleLayer)

	local middleLayerX = 0	
	local middleLayerY = -(GameVars.height - self.mapControler.gridHeight * self.yNum) + GameVars.UIOffsetY
	local offsetX = self.mapControler.gridWidth*0.5 + self.rightDoorWidth + GameVars.UIOffsetX

	self.gameMiddleLayer:pos(GameVars.width - offsetX,middleLayerY)

	-- 游戏前景层(迷雾等)
	self.gameFrontLayer = display.newNode():addto(self.middleLayer)

	-- 整个世界前景层
	self.frontLayer = display.newNode():addto(self.worldLayer):pos(0,-GameVars.UIOffsetY )

	-- self.touchNode = display.newNode():addTo(self,-1)
	-- self.touchNode:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
 --    self.touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
 --    self.touchNode:setTouchedFunc(c_func(self.onTouchMapEnd,self), nil, true, c_func(self.onTouchMapBegin,self), c_func(self.onTouchMapMove,self),true,c_func(self.onTouchGlobalEnd,self))
 --    self.touchNode:setTouchSwallowEnabled(true)
end

--[[
	初始化地图上各种视图panel，格子、上边缘砖块、下边缘砖块
	缓存格子panel到self.gridPanelCacheList
]]
function EliteMap:initGridPanels()
	-- self.gridPanelCacheList = {}
	-- for k, v in pairs(FuncEliteMap.ORGAN_MAP_GRID_TYPE) do
	-- 	local panelName = self.mapControler.GRID_PANELS[v]
	-- 	local panel = UIBaseDef:createPublicComponent(self.mapGridSkin,panelName)
	-- 	panel:addto(self)
	-- 	panel:setVisible(false)
	-- 	self.gridPanelCacheList[v] = panel
	-- end

	-- -- 地图边界砖块
	-- self.upBrickPanel = UIBaseDef:createPublicComponent(self.mapGridSkin,"panel_6")
	-- self.downBrickPanel = UIBaseDef:createPublicComponent(self.mapGridSkin,"panel_7")

	-- self.upBrickPanel:addto(self)
	-- self.upBrickPanel:setVisible(false)

	-- self.downBrickPanel:addto(self)
	-- self.downBrickPanel:setVisible(false)
end

-- 分帧创建上边缘的地砖
function EliteMap:initUpBricks()
	-- local offsetX = -42
	-- local offsetY = 92

	-- local createOneBrick = function(xIdx,yIdx)
	-- 	local pos = EliteMapTools:getGridPos(xIdx,yIdx)
	-- 	local brickPanel = UIBaseDef:cloneOneView(self.upBrickPanel)
	-- 	brickPanel:pos(pos.x+offsetX,pos.y+offsetY)
	-- 	brickPanel:addto(self.gameMiddleLayer)
	-- end

	-- local yIdx = 1
	-- local count = 1
	-- local numPerFrame = 2
	-- for i=1,self.xNum+4 do
	-- 	if i % 2 == 0 then
	-- 		local xIdx = i
	-- 		self:delayCall(c_func(createOneBrick,xIdx,yIdx), count / GameVars.GAMEFRAMERATE)
	-- 		if i % numPerFrame == 0 then
	-- 			count = count + 1
	-- 		end
	-- 	end
	-- end
end

-- 分帧创建下边缘的地砖
function EliteMap:initDownBricks()
	-- local offsetX = 25
	-- local offsetY = -20
	-- local yIdx = self.yNum

	-- local createOneBrick = function(xIdx,yIdx)
	-- 	local pos = EliteMapTools:getGridPos(xIdx,yIdx)
	-- 	local brickPanel = UIBaseDef:cloneOneView(self.downBrickPanel)
	-- 	brickPanel:pos(pos.x+offsetX,pos.y+offsetY)
	-- 	brickPanel:zorder(1)
	-- 	brickPanel:addto(self.gameMiddleLayer)
	-- end

	-- local count = 1
	-- local numPerFrame = 2
	-- for i=1,self.xNum+2 do
	-- 	if i % 2 == 0 then
	-- 		local xIdx = i
	-- 		self:delayCall(c_func(createOneBrick,xIdx,yIdx), count / GameVars.GAMEFRAMERATE)
	-- 		if i % numPerFrame == 0 then
	-- 			count = count + 1
	-- 		end
	-- 	end
	-- end
end

-- 创建地图尾部建筑
function EliteMap:initMapTailBuilding()
	-- if not self.mapTailBuilding then
	-- 	self.mapTailBuilding = UIBaseDef:createPublicComponent(self.mapGridSkin,"panel_8")
	-- 	self.mapTailBuilding:addto(self.gameMiddleLayer)
	-- 	self.mapTailBuilding:anchor(0.5,0.5)
	-- 	self.mapTailBuilding:zorder(1)
	-- 	local width = self.mapTailBuilding:getContentSize().width

	-- 	local pos = EliteMapTools:getGridPos(self.xNum,1)
	-- 	local x = pos.x - width - 343
	-- 	local y = 90

	-- 	self.mapTailBuilding:pos(x,y)
	-- end
end

-- 获取格子panel缓存列表
function EliteMap:getGridPanelCacheList()
	return self.gridPanelCacheList
end

function EliteMap:getFrontLayer()
	return self.frontLayer
end

function EliteMap:getGameBackLayer()
	return self.gameBackLayer
end

function EliteMap:getGameMiddleLayer()
	return self.gameMiddleLayer
end

-- 移动整个地图到指定点
function EliteMap:moveMap(newX,newY)
	self.middleLayer:setPosition(newX,newY)
	-- self.mapControler.sceneControler:updatePos(newX,newY)
end

-- 开始触摸地图
function EliteMap:onTouchMapBegin(event)
	local x,y = event.x,event.y

	local mapX,mapY = self.middleLayer:getPosition()
	self.downX = event.x - mapX
	self.downY = event.y - mapY

	self.lastX = self.downX

	local pos = self.gameMiddleLayer:convertToNodeSpaceAR(cc.p(x,y))
	self.mapControler:onClickMapBegin(pos)

	--停止地图缓动
	EaseMapControler:stopEaseMap()
end

-- 移动中
function EliteMap:onTouchMapMove(event)
	local x = event.x
    local y = event.y

    if self.lastX and self.downX then
		local worldX = self:getMapBorderPositionX(event.x - self.downX)
		local worldY = self.middleLayer:getPositionY()
		self:moveMap(worldX,worldY)

		self.lastSpeed = {x =x - self.lastX,y = 0 }
    end
	
	self.lastX = x

	self.mapControler:onClickMapMove(pos)
end

-- 触摸结束
function EliteMap:onTouchMapEnd(event)
	local x = event.x
	local y = event.y

	local pos = self.gameMiddleLayer:convertToNodeSpaceAR(cc.p(x,y))
	self.mapControler:onClickMapEnd(pos)
end

-- 全局触摸结束
function EliteMap:onTouchGlobalEnd(event)
	local x = event.x
	local y = event.y

	local worldX = self:getMapBorderPositionX(event.x - self.downX)
	local worldY = self.middleLayer:getPositionY()

	EliteMapModel:saveMapPos(worldX,worldY)

	if not self.lastSpeed then
		return
	end
	--开始惯性缓动
	EaseMapControler:startEaseMap(self.middleLayer,c_func(self.onEaseMoveFunc,self) ,c_func(self.onEaseMoveEndFunc,self) ,self.lastSpeed.x,self.lastSpeed.y,easeNum)
	self.lastSpeed.x = 0
	self.lastSpeed.y = 0
end

function EliteMap:onEaseMoveFunc(x,y)
	local curX,curY = self.middleLayer:getPosition()
	local newX = self:getMapBorderPositionX(curX + x)
	self:moveMap(newX,curY)
end

function EliteMap:onEaseMoveEndFunc(x,y)
	local curX,curY = self.middleLayer:getPosition()
	-- EliteMapModel:saveMapPos(curX,curY)
end

-- 检查地图边界
function EliteMap:getMapBorderPositionX(_x)
	local x = _x
	local y = _y

	if x <= self.minMapX then
		x = self.minMapX
	elseif x >= self.maxMapX then
		x = self.maxMapX
	end

	return x
end

-- 初始化格子对象模型,只有Model数据,没有视图
function EliteMap:initGridModels()
	for y=1,self.yNum do
		for x=1,self.xNum do
			-- if EliteMapModel:isValidGrid(x,y) then
			-- 	self.mapControler:createGridModel(x,y)
			-- end
		end
	end
end

function EliteMap:deleteMe()
	EventControler:clearOneObjEvent(self)
end

return EliteMap
