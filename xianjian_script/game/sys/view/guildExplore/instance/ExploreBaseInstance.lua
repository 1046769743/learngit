--
-- Author: Your Name
-- Date: 2018-07-03 11:41:55
--
local ExploreBaseInstance = class("ExploreBaseInstance")
-- 指针数据
ExploreBaseInstance.controler =nil 		-- 游戏控制器
ExploreBaseInstance.myView = nil 		-- 视图  ViewBasic 对象
ExploreBaseInstance.shade = nil 			-- 影子 ModelShade对象
--[[
shakeInfo = {
		frame = frame, 			--震动帧数
		shakeType = shakeType , --震动类型
		range = 1,  			--震动半径
		
	}

]]
ExploreBaseInstance.shakeInfo = nil 		--自身震屏信息

ExploreBaseInstance.depthHeigt = 0 		-- 深度排列的高度. 
ExploreBaseInstance._initDepthHeight = 0 	--初始深度
ExploreBaseInstance.modelType = 0 		-- model类型 


-- 游戏速度
ExploreBaseInstance.updateScale =1 		-- 刷新比率  如果scale>1 表示快动作  小于1 表示慢动作
ExploreBaseInstance.updateCount = 0 		-- 刷新计数 

ExploreBaseInstance.selfPause = false 	-- 代码暂停

ExploreBaseInstance.viewScale =  1 		-- 试图的scale

--坐标和层级
ExploreBaseInstance.__zorder = 0 		-- zorder
ExploreBaseInstance.pos = nil 			--坐标 {x,y,z}
ExploreBaseInstance.gridPos = nil 		--网格坐标
ExploreBaseInstance._isDied = false 	--是否已经销毁了

--战队信息
ExploreBaseInstance.initCamp = nil  		--初始阵营,

ExploreBaseInstance.camp = 1 			--阵营
ExploreBaseInstance.way = 1 				--x的运动方向 初始化默认为1 就是朝右的

ExploreBaseInstance.campArr=nil 			--我的阵营队伍
ExploreBaseInstance.toArr = nil 			--敌人阵营数组  如果以后扩展多方阵营 那么会 扩展 更多toArr   和campArr 
ExploreBaseInstance.callFuncArr = nil 	

ExploreBaseInstance._isOut = false 	--是否是出界的.	如果某个对象出界.那么不计算他视图相关信息
ExploreBaseInstance.data = data
function ExploreBaseInstance:ctor( controler,data )
	--self.countId = 0
 	self.controler = controler
 	self.gridControler = controler.gridControler
 	self.callFuncArr = {}
 	self.gridPos = {x=0,y=0}
 	self.stillInfo =  {time =0,type=0,x=0,y=0,r=1}    -- 初始化硬直信息
 	--现在坐标精简化 
 	self.pos = {x=0,y=0,z=0}	
 	self.lastCachePos = {x=-999,y = -999,z= -9999}
 	self._data = data
 	self:initViewSize()
end

--设置材质名称 
function ExploreBaseInstance:setTexturePanelName( textureName,namePanelName )
	self.texturePanelName = textureName
	self.namePanelName = namePanelName
end

function ExploreBaseInstance:getData(  )
	return self._data
end
--当数据发生变化
function ExploreBaseInstance:onDataChange( changeData )
	--给子类重写
	

end

--设置miniview
function ExploreBaseInstance:setMiniView( miniView )
	self.miniView = miniView
	miniView:pos(0,0)
	miniView:addto(self.controler.mainUI.panel_map.ctn_1,1000)
	--初始化隐藏迷雾
	self.miniView:visible(false)
end

--判断是否显示小地图
function ExploreBaseInstance:checkShowMiniView(  )
	if self._isShowMiniView then
		return
	end
	--如果没有miniview
	if not self.miniView then
		return
	end
	--如果是迷雾u
	if not self.gridControler:checkGridIsMists( self.gridPos.x,self.gridPos.y ) then
		self._isShowMiniView = true
		self.miniView:visible(true)
		self:realPos()
	end

end


function ExploreBaseInstance:initView(ctn,view,xpos,ypos,zpos,size)
	
	--容器层
	self.viewCtn = ctn
	self.myView = view
	ctn:addChild(self.myView)

	if not size then
		size = {width = 0,height=0}
	end

	if self.myView.doAfterInit then
		self.myView:doAfterInit()
	end
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end
	self:updateViewPlaySpeed()

	-- self:onInitViewComplete()
	
	return self
end

--重新赋予视图 给子类重写 一般是需要做自己的刷新显示
function ExploreBaseInstance:onRefreshView( view)
	self.myView = view
	view:setVisible(true)
	--反向拿到这个view的model
	view._currentInstance = self
	self:playFrame()
	self:realPos()
	
	self:onDataChange()

end





--失去某个view的引用
function ExploreBaseInstance:loseView(  )
	if self.myView then
		self.myView:setVisible(false)
		if self.myView.stop then
			self.myView:stop()
		end
		self.myView._currentInstance = nil
		self.myView = nil
	end
	
	
end


function ExploreBaseInstance:setGridPos( gridX,gridY )
	self.gridPos.x = gridX
	self.gridPos.y = gridY
	local worldPos = self.gridControler:getGridWorldPos(gridX,gridY)
	self:setPos(worldPos.x,worldPos.y,0)
end



--设置坐标
function ExploreBaseInstance:setPos(xpos ,ypos ,zpos  )
	if not xpos then xpos = 0 end
	if not ypos then ypos = 0 end
	if not zpos then zpos = 0 end
	self.pos.x= xpos
	self.pos.y = ypos
	self.pos.z = zpos
	self:realPos()
	return self
end

--更新视图速度
function ExploreBaseInstance:updateViewPlaySpeed( )
	
	if self.myView.setPlaySpeed then
		--让视图设置对应的播放速度
		self.myView:setPlaySpeed(self.updateScale)
	end
end

--设置方位
function ExploreBaseInstance:setWay( way )
	if not way then
		return
	end

	self.way = way
	if self.myView then
		self:setViewScale(self.viewScale)
	end
end

--设置viewscale
function ExploreBaseInstance:setViewScale( value )
	self.viewScale = value
	self.myView.currentAni:setScaleX(self.way*self.viewScale )
	self.myView.currentAni:setScaleY(self.viewScale)

end

function ExploreBaseInstance:getViewScale( )
	return self.viewScale or 1
end

function ExploreBaseInstance:initViewSize(  )
	self.mySize = {width=FuncGuildExplore.gridWidth,height =FuncGuildExplore.gridHeight}
end

function ExploreBaseInstance:getContentSize()
	return self.mySize
end

--停止播放动作
function ExploreBaseInstance:stopFrame(  )
	if not self.myView then
		return
	end
	if self.myView.stop then
		self.myView:stop()
	end
	
end

--恢复播放动作
function ExploreBaseInstance:playFrame(  )
	if not self.myView then
		return
	end
	if self.myView.play then
		self.myView:play()
	end
end




----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


--刷新函数
function ExploreBaseInstance:updateFrame( )

	self:runBySpeedUpdate()
end


--按照加速比率进行刷新
function ExploreBaseInstance:runBySpeedUpdate( ... )

	self.updateCount = self.updateCount + 1
	self:controlEvent()
	self:updateSpeed()

	self:moveXYZPos()


	--碰撞检测 碰撞类的重写
	self:checkHit()	
	-- 实现真实坐标body
	self:realPos()

end


--帧事件
function ExploreBaseInstance:dummyFrame( ... )
end

--一些控制事件 --供子类重写
function ExploreBaseInstance:controlEvent(  )
end

--更新速度
function ExploreBaseInstance:updateSpeed( ... )
end

--碰撞检测
function ExploreBaseInstance:checkHit( ... )
end

--移动坐标
function ExploreBaseInstance:moveXYZPos( ... )
end




--转换真实坐标
function ExploreBaseInstance:realPos( )

	local xpos = self.pos.x
	local ypos = self.pos.y + self.pos.z
	-- if xpos == self.lastCachePos.x and ypos == self.lastCachePos.y then
	-- 	return
	-- end
	-- self.lastCachePos.x = xpos
	-- self.lastCachePos.y = ypos
	if self.myView then
		self.myView:setPosition(xpos,ypos )
		ypos = math.round(ypos)
		--主角要挡住别人 如果在同一格子上
		self.myView:setLocalZOrder(100000-ypos*10 + self.depthHeigt  )
		
		if self.namePanel then
			self.namePanel:setPosition(xpos,ypos + 130 )
			self.namePanel:setLocalZOrder(200000-ypos )
		end
		
	end 
	if self.miniView then
		local miniX,miniY = self.controler.mapControler:turnWorldPosToMiniMap( self.pos.x,self.pos.y )
		self.miniView:pos(miniX,miniY)
	end
end


--设置深度
function ExploreBaseInstance:setDepthHeight( value )
	if value == 0 then
		self.depthHeigt = self._initDepthHeight
	else
		self.depthHeigt = value
	end
	
	self:realPos()
end


--显示或者隐藏view
function ExploreBaseInstance:setVisible( value )
	self.myView:visible(value)
	if value then
		self:playFrame()
	else
		self:stopFrame()
	end
end

--设置是否出界
function ExploreBaseInstance:setIsOut(value )
	if self._isOut == value then
		return
	end
	self._isOut = value
	--如果是出界的
	if value then
		self:setVisible(false)
	else
		self:setVisible(true)
	end
end



--只销毁数据
function ExploreBaseInstance:destoryData(  )
	self._data = nil
	self.callFuncArr = nil
	self:loseView()
	EventControler:clearOneObjEvent(self)
	self.controler = nil
	self.gridControler = nil
	self._isDied = true

	if  self.miniView  then
		self.miniView:clear()
		self.miniView  = nil
	end
	
end



function ExploreBaseInstance:deleteMe(  )
	if self._isDied then
		return
	end
	self._isDied = true
	if self.myView and  (not tolua.isnull(self.myView) ) then
		FilterTools.clearFilter( self.myView  )
		if self.myView.deleteMe then
			self.myView:deleteMe()
		else
			self.myView:clear()
		end
		self.myView = nil
	end

	if  self.miniView  then
		self.miniView:clear()
		self.miniView  = nil
	end

	if self.shade then
		self.shade:deleteMe()
	end

	EventControler:clearOneObjEvent(self)
	self.callFuncArr = nil
	self.gridControler = nil
end



return ExploreBaseInstance