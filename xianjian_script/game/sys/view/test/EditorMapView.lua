--[[
    Author: pangkangning
    Date:2018-07-02
    Description: 地形编辑器地图场景
]]
-- require("game.sys.view.guildExplore.controler.ExplorePosTools")
-- 键盘事件
local keyDatas = 
{
	["-"] = 73,["="]= 89,["ctrl"] = 14,
}
local colorKey = {
	cc.c3b(0,255,100),cc.c3b(0,255,180),cc.c3b(0,255,250),
	cc.c3b(0,100,255),cc.c3b(0,180,255),cc.c3b(200,200,200),
	cc.c3b(100,255,255),cc.c3b(150,255,255),cc.c3b(100,100,100),
	cc.c3b(100,255,0),cc.c3b(150,255,0),cc.c3b(250,255,0),
	cc.c3b(255,0,100),cc.c3b(200,0,180),cc.c3b(255,0,255),
	cc.c3b(255,0,255),cc.c3b(255,180,255),cc.c3b(180,180,180),
}
local EditorMapView  = class("EditorMapView",function ()
	return display.newNode()
end)
function EditorMapView:ctor( ... )
	self._viewArr = {} --编辑器内格子view(带格子状态数据)、grid信息、行走信息等
	self._itemArr = nil
	self._mapScale = 1.00 --地图大小(键盘-、= 号)
	self._isBrush = false --笔刷模式(摁住左ctrl)
	self:initLayers()
	self:registerKeyEvent()
    EventControler:addEventListener(EditorEvent.EDITOR_LOAD_COMP,self.updateMap,self)
    EventControler:addEventListener(EditorEvent.EDITOR_RESET_SIZE,self.resetMapSize,self)
    EventControler:addEventListener(EditorEvent.EDITOR_GRID_CHANGE,self.mapGridUpdate,self)
end
function EditorMapView:initLayers( )
	-- self:setContentSize(cc.size(GameVars.width,GameVars.height))
	-- 地图
	self.mapNd = display.newNode():addto(self)
	-- self.mapNd:setContentSize(cc.size(GameVars.width,GameVars.height))
	-- self.mapNd = display.newColorLayer(cc.c4b(0,0,200,255)):pos(100,0):addto(self)
	-- self.mapNd:setContentSize(cc.size(100,100))
	-- self.mapNd:anchor(1,1)
	-- self.mapNd:pos(400,400)
	self.mapNd:pos(GameVars.width-100,GameVars.height-100)
	self.nodeArr = {}
	-- 地形数据
	self.terrainNd = display.newNode():addto(self.mapNd)
	table.insert(self.nodeArr,self.terrainNd)
	-- 装饰数据
	self.coverNd = display.newNode():addto(self.mapNd)
	table.insert(self.nodeArr,self.coverNd)
	-- 事件层(可走不可走、区域label)
	self.eventNd = display.newNode():addto(self.mapNd)
	table.insert(self.nodeArr,self.eventNd)

	-- 触摸事件
	self.touchNode = display.newNode():addTo(self,-1)
    self.touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
    self.touchNode:setTouchedFunc(
    	c_func(self.onTouchMapEnd,self), nil, true, 
    	c_func(self.onTouchMapBegin,self),
    	c_func(self.onTouchMapMove,self),true,
    	c_func(self.onTouchGlobalEnd,self))
    self.touchNode:setTouchSwallowEnabled(true)
end
-- 格子数据刷新
function EditorMapView:mapGridUpdate(event )
	local x,y = event.params.x,event.params.y
	self:updateTileView(x,y)
	-- 此时此格子也是选中状态
	self:updateGridSelected(true,x,y)
end
-- 重置所有格子数据
function EditorMapView:resetView( )
	for k,v in pairs(self._viewArr) do
		for m,n in pairs(v) do
			self:clearGridItem(k,m)
		end
	end
	self._viewArr = {}
	self._itemArr = nil
end
-- 将一个格子置空
function EditorMapView:clearGridItem( x,y )
	if self._viewArr[tostring(x)] then
		local _viewArr = self._viewArr[tostring(x)][tostring(y)]
		if _viewArr then
			for k,v in pairs(_viewArr) do
				v:removeFromParent()
			end
			self._viewArr[tostring(x)][tostring(y)] = nil
			self._itemArr = nil
		end
	end
end
-- 重新格子尺寸
function EditorMapView:resetMapSize( event )
	self:updateMap()
end
-- 更新地形数据
function EditorMapView:updateTileView( i,j,count)
	local allCfgs = FuncGuildExplore.getAllDecorateMaterials()
	if not self._viewArr[tostring(i)]  then
		self._viewArr[tostring(i)] = {}
	end
	-- 先移除原先的格子数据
	self:clearGridItem(i,j)
	local tempFunc = function( )
		local tmpArr = self:createGridItem(i,j)
		if not tmpArr then
			return
		end
		self._viewArr[tostring(i)][tostring(j)] = tmpArr
		for k,view in pairs(tmpArr) do
			local pos = ExplorePosTools:getGridPos(i,j)
			if k == 1  then
				-- if view._data and view._data.info[2] then
					--如果是装饰 标记是装饰
				if allCfgs[tostring(view._data.info[2])] and 
					allCfgs[tostring(view._data.info[2])].decorate  then
					self.nodeArr[2]:addChild(view)
				else
					self.nodeArr[1]:addChild(view)
				end
			else
				-- 可走的区域
				if k == 2 then
					pos.x = pos.x -30
				end
				self.nodeArr[3]:addChild(view)
			end
			view:setPosition(pos.x,pos.y)
			view:zorder(i+j+200)
		end
	end
	if count then
		self:delayCall(tempFunc,count/50)
	else
		tempFunc()
	end
end
-- 更新地形数据
function EditorMapView:updateMap( )
	self:resetView()
	local count = 1
	for x,yArr in pairs(EditorControler.mapData) do
		count = count + 1
		for y,v in pairs(yArr) do
			if v and v.info then
				self:updateTileView(v.x,v.y,count)
			end
		end
	end
	echo("地图创建完成",EditorControler.max.x,EditorControler.max.y)
	-- TODO:将地图原点归位

	self:delayCall(function( )
		self:updateAppointData()
	end,count/50)
end

-- ################ 地图的触摸事件 ############
function EditorMapView:onTouchMapBegin(event)
	local mapX,mapY = self.mapNd:getPosition()
	self.starPos = event
	self.mapStarPos = cc.p(mapX,mapY)
	-- --停止地图缓动
	-- EaseMapControler:stopEaseMap()
end

-- 移动中
function EditorMapView:onTouchMapMove(event)
	if self._isBrush then
		self.isMove = false
		-- 笔刷模式，直接调用点击时间即可(TODO:优化)
		self:onTouchGlobalEnd(event)
		return
	end
	if (not self.starPos) or (not self.mapStarPos) then
		return
	end
	local tmpPos = cc.pSub(self.starPos,event)
	if not self.isMove then
		if math.abs(tmpPos.x) > 3 or math.abs(tmpPos.y) > 3 then
			self.isMove = true
		end
	end
	if self.isMove then
		local newPos = cc.pSub(self.mapStarPos,tmpPos)
		self.mapNd:setPosition(newPos)
	end
end

-- 触摸结束
function EditorMapView:onTouchMapEnd(event)
	self.starPos = nil
	self.mapStarPos = nil
	self.isMove = false
end

-- 全局触摸结束
function EditorMapView:onTouchGlobalEnd(event)
	if self.isMove then
		self.isMove = false
		return
	end
	local pos = self.mapNd:convertToNodeSpaceAR(event)
	local gridPos = self:getGridPosByMapPos(pos)
	self:updateGridSelected(false)
	-- echo("pppp===",event.x,event.y)
	if gridPos then
		echo("格子坐标",gridPos.x,gridPos.y)
		-- 选中效果
		self:updateGridSelected(true,gridPos.x,gridPos.y)
		-- 修改格子的数据
		EditorControler:updateGridData(gridPos.x,gridPos.y)
	else
		gridPos = {x = 0 ,y = 0}
	end
	EventControler:dispatchEvent(EditorEvent.EDITOR_GRID_CLICK,{s = self._mapScale,x=gridPos.x,y=gridPos.y})
end
-- 更新格子的选中与否
function EditorMapView:updateGridSelected(b,x,y )
	if self._itemArr then
		for k,v in pairs(self._itemArr.view) do
			FilterTools.clearFilter(v)
		end
	end
	self._itemArr = nil
	if b then
		if not self._viewArr[tostring(x)] then
			return
		end
		local viewArr = self._viewArr[tostring(x)][tostring(y)]
		if not viewArr then
			return
		end
		self._itemArr = {x=x,y=y,view = viewArr}
		for k,v in pairs(self._itemArr.view) do
			FilterTools.setViewFilter(v,FilterTools.colorTransform_red)
		end
	end
	self:updateAppointData()
end
-- 更新固定格子的坐标
function EditorMapView:updateAppointData( ... )
	if not self._appointData then
		self._appointData = Tool:configRequire("explore.ExploreMapAppointRandom")
	end
	for k,v in pairs(self._appointData) do
		if v.coordinate then
			local x,y = v.coordinate[1],v.coordinate[2]
			if self._viewArr[tostring(x)] then
				local viewArr = self._viewArr[tostring(x)][tostring(y)]
				if viewArr then
					for m,n in pairs(viewArr) do
						FilterTools.setViewFilter(n,FilterTools.colorTransform_red)
					end
				end
			end
		end
	end
end
--判断某一点落在哪个格子上
function EditorMapView:getGridPosByMapPos(pos)
	for x,yArr in pairs(EditorControler.mapData) do
		for y,v in pairs(yArr) do
			if v and v.info then
				local x,y = pos.x,pos.y
				if ExplorePosTools:checkPosInGrid(x,y,v.x,v.y) then
					return v
				end
			end
		end
	end
	return nil
end
-- ********************  ###########  键盘监听事件 ###############
function EditorMapView:registerKeyEvent()
    --必须是windows平台
	if device.platform ~= "mac" and device.platform ~= "windows" then
		return
	end

	local listener = cc.EventListenerKeyboard:create()
    listener:registerScriptHandler(c_func(self.pressKeyDown,self), cc.Handler.EVENT_KEYBOARD_PRESSED)
    listener:registerScriptHandler(c_func(self.pressKeyUp,self), cc.Handler.EVENT_KEYBOARD_RELEASED)
    cc.Director:getInstance():getEventDispatcher():addEventListenerWithFixedPriority(listener, 1)
    
    self.keyListener = listener
end
function EditorMapView:pressKeyDown(keyCode)
	if keyDatas.ctrl == keyDatas["ctrl"] then
		self._isBrush = true
	end
end
-- 键盘事件监听
function EditorMapView:pressKeyUp(keyCode)
	if keyCode == keyDatas["-"] then
		self._mapScale = self._mapScale - 0.1
		self._mapScale = math.max(self._mapScale,0.5)
		self:updateMapScale()
	elseif keyCode == keyDatas["="] then
		self._mapScale = self._mapScale + 0.1
		self._mapScale = math.min(self._mapScale,3)
		self:updateMapScale()
	elseif keyDatas.ctrl == keyDatas["ctrl"] then
		self._isBrush = false
	end
end
function EditorMapView:updateMapScale( )
	self.mapNd:scale(self._mapScale)
	local x,y = 0,0
	if self._itemArr then
		x,y = self._itemArr.x,self._itemArr.y
	end
	EventControler:dispatchEvent(EditorEvent.EDITOR_GRID_CLICK,{s = self._mapScale,x=x,y=y})
end
-- #############

-- ******************* ############ 以下是格子相关数据  ############## **************
function EditorMapView:createGridItem(x,y)
	-- 获取对应的数据
	if not EditorControler.mapData[tostring(x)] then
		-- echoError ("数据异常=",x,y)
		return nil
	end
	local data = EditorControler.mapData[tostring(x)][tostring(y)]
	if not data then
		-- echoError ("数据异常",x,y)
		return nil
	end
	if data.info then
		local tmpArr = {}
		if tonumber(data.info[1]) == 1 then
			local panelStr = string.format("panel_%s",data.info[2]) --地形对应的数据
			local view = UIBaseDef:createPublicComponent( "UI_explore_grid",panelStr)
			if not view then
				echoError ("地形数据不存在，请检查UI_Explore_grid 中是否存在",panelStr,"原件")
				return nil
			end
			view._data = data
			table.insert(tmpArr,view)
			-- view._infoTxt = display.newTTFLabel({text = string.format("(%s,%s)",x,y), size = 18, 
			-- 	color = cc.c3b(255,0,0)}):addTo(view)
			-- return view
		end
		-- dump(data,"====")
		if #data.info >= 3 and tonumber(data.info[3]) > 0 then
			local txtView = display.newTTFLabel({text = data.info[3], size = 18,color = cc.c3b(255,0,0)})
			tmpArr[2] = txtView
		end
		-- 初始化地形所属块区
		for k,v in pairs(EditorControler.areaData) do
			local key = FuncGuildExplore.getKeyByPos(x,y)
			if v.areaPos[key] then
				local color = colorKey[tonumber(k)] or cc.c3b(0,255,255)
				local txtView = display.newTTFLabel({text = "a_"..k, size = 18,color = color})
				tmpArr[3] = txtView
				break
			end
		end
		if #tmpArr == 0 then
			return 
		end
		return tmpArr
	end
	return nil
end

return EditorMapView