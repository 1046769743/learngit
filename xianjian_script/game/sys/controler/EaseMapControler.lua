--
-- Author: Your Name
-- Date: 2018-01-03 15:28:33
--
local EaseMapControler = {}
local stateMap  = {
	stand = 0,
	move = 1,
}

--开始缓动一个node		
--dragNode 传入一个对象当这个对象被销毁时 会自动移除 跟踪拖拽事件. 
-- onPosChangeFunc 当坐标发生变化时 
--easeNums 缓动系数0.1-0.9之间 0是很快就停止 1是缓动非常快 默认0.75  适中 

EaseMapControler.tempNode = nil
EaseMapControler.moveState = 0

--缓动队列数组
function EaseMapControler:startEaseMap(dragNode,onPosChangeFunc ,onEaseEndFunc,disX,disY,easeNum)
	if not self.tempNode then
		local scene = WindowControler:getCurrScene()
		self.tempNode = display.newNode():addto(scene._topRoot)
	end
	self.disX = disX or 0
	self.disY = disY or 0
	--如果太慢了 就不缓动了
	if math.abs(self.disX) <= 10 and math.abs(self.disY) <= 10 then
		if onEaseEndFunc then
			onEaseEndFunc(0,0)
		end
		return
	end

	self:stopEaseMap()

	self.tempNode:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)

	self.lastNodeEventHandle = dragNode:addNodeEventListener(cc.NODE_EVENT, c_func(self.onNodeEvent,self))
	self.lastDragNode = dragNode
	--运动状态  1是
	self.moveState = stateMap.move
	self.onNodeMoveFunc = onPosChangeFunc
	self.onNodeMoveEndFunc = onEaseEndFunc

	self.easeNum = easeNum or 0.9
	if self.easeNum > 0.9	 then
		self.easeNum = 0.9
	elseif self.easeNum < 0.1 then
		self.easeNum = 0.1
	end

end


--开启缓动一个map,并添加拖拽功能 .
-- 只需要实现 onPosChangeFunc(changex,changey)这个函数 .这个是改变量,你需要让你的node当前坐标加上这个偏移量
--同时可以传入点击事件回调
function EaseMapControler:startEaseMapAndDrag(dragNode,onPosChangeFunc ,onEaseEndFunc,easeNum,onClickFunc,onGloablEndFunc,onMovedFunc,onTouchDownFunc )

	-- self:initStart(dragNode,onPosChangeFunc ,onEaseEndFunc,disX,disY,easeNum,true)

	--如果拖拽也交给控制器了
	local onClickEnd = function ( e )
		if onClickFunc then
			onClickFunc(e)
		end
	end
	dragNode._speed = {x=0,y=0}
	local onBegin = function (e  )
		--记录初始位置
		dragNode.__initpos = e
		dragNode.__currentPos = e
		dragNode.__isDragMoved = false
		self:stopEaseMap()
		if onTouchDownFunc then
			onTouchDownFunc(e)
		end
	end
	local onMoved = function (e  )
		local disx = e.x - dragNode.__currentPos.x
		local disy = e.y - dragNode.__currentPos.y
		dragNode._speed.x = disx
		dragNode._speed.y = disy
		onPosChangeFunc(disx,disy)
		dragNode.__currentPos = e
		if onMovedFunc then
			onMovedFunc(e)
		end
		dragNode.__isDragMoved = true
	end
	--点击结束的时候 就开始启动拖拽
	local onGlobalEnd = function ( e )
		local disx = e.x - dragNode.__currentPos.x
		local disy = e.y - dragNode.__currentPos.y
		dragNode.__currentPos = e
		if dragNode.__isDragMoved  then
			self:startEaseMap(dragNode,onPosChangeFunc ,onEaseEndFunc,dragNode._speed.x,dragNode._speed.y,easeNum)
		else
			if onEaseEndFunc then
				onEaseEndFunc(0,0)
			end
		end
		if onGloablEndFunc then
			onGloablEndFunc(e)
		end
		dragNode.__isDragMoved =false
	end

	dragNode:setTouchedFunc(onClickEnd, nil, false, onBegin, onMoved, false, onGlobalEnd)


end






function EaseMapControler:onNodeEvent( event )
	if event.name == "exit" then
		--当node退出的时候 停止缓动
		self:stopEaseMap()
	end
end


function EaseMapControler:updateFrame( )
	-- echo("1111111111111111111111111")
	self.disX = self.disX * self.easeNum
	self.disY = self.disY * self.easeNum
	if math.abs(self.disX) <= 1 and math.abs(self.disY) <= 1 then
		self.disX = 0
		self.disY = 0
		self:stopEaseMap()
		if self.onNodeMoveEndFunc then
			self.onNodeMoveEndFunc(self.disX,self.disY)
		end
	end
	self.onNodeMoveFunc(self.disX,self.disY)
end

function EaseMapControler:stopEaseMap(  )
	if self.tempNode then
		self.tempNode:unscheduleUpdate()
	end
	--停止
	self.moveState = stateMap.stand
	if self.lastDragNode and (not tolua.isnull(self.lastDragNode) ) then
		self.lastDragNode:removeNodeEventListener( self.lastNodeEventHandle)
		self.lastDragNode = nil
	end
end





return EaseMapControler