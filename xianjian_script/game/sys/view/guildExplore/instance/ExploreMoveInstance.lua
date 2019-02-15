--
-- Author: xd
-- Date: 2018-07-03 11:45:05
-- 基础运动类,封装模块运动数据

local ExploreMoveInstance = class("ExploreMoveInstance", ExploreBaseInstance)


local Fight = Fight


--地面高度
local groundLandHeigt = 0

local moveType_moveToTarget = 1 		--运动到某个点  
local moveType_moveByPosArr = 2 		--按照一系列运动点

ExploreMoveInstance._isPauseMove = false 		--是否暂停move 

--[[-速度也变成{x=0,y=0,z=0}的格式 为了统一 ]]
ExploreMoveInstance.speed = nil
ExploreMoveInstance.addSpeed = nil 			--加速度
ExploreMoveInstance.myState = Fight.state_stand 	--状态 



ExploreMoveInstance.gravitiAble = true 	--能否受重力
 
 --运动类型
ExploreMoveInstance.moveType =  0 	--运动类型
ExploreMoveInstance.movePostion = nil 	 --运动到点的坐标
ExploreMoveInstance.movePointsInfo = nil 	-- 根据一系列点来运动

ExploreMoveInstance.viewMoving = false -- 视图移动控制

ExploreMoveInstance._willStop = false 	--是否将要停止运动

function ExploreMoveInstance:ctor( ... )
 	ExploreMoveInstance.super.ctor(self,...)
 	self.movePointsInfo = {}
 	self.speed = {x=0,y=0,z=0} 
 	self.addSpeed = {x=0,y=0,z=3}


 	--当前动作标签
 	self.label = nil
 	--当前方位 只分左右
 	self.way = 1
 	--当前角度
 	self.rotation = 0
 	self.gridPos = {x=0,y=0}
 	if not self.mySize then
		self.mySize = {width = 0,height=0}
	end
end

function ExploreMoveInstance:initView(...)
	ExploreMoveInstance.super.initView(self,...)
end

--初始化状态
function ExploreMoveInstance:initStand( )
 	if self.movePostion and self.moveType ~= 0 then
 		return
 	end

 	self.myState = Fight.state_stand
 	self:setSpeed(0,0,0)
 	self.moveType = 0

 	if self.speed.minx then
 		self.speed.minx = 0
 	end

 	if self.speed.miny then
 		self.speed.miny = 0
 	end
 	self:playStandAction()
 	return self
end


function ExploreMoveInstance:playStandAction(  )
	self.myView:playLabel(self.myView.actionArr.stand, true)
end

function ExploreMoveInstance:playMoveAction(  )
	self.myView:playLabel(self.myView.actionArr.walk, true)
end


function ExploreMoveInstance:initJump(jumpSpd )
	self.moveType=0
	self.speed.z = jumpSpd or 0
	if not jumpSpd then
		echoError("__没有给z速度")
	end
	self.myState = Fight.state_jump
	return self
end

function ExploreMoveInstance:initMove(xspd,yspd,minXSpd,minYSpd)
	if xspd then
		self.speed.x = xspd
	end
	if yspd then
		self.speed.y = yspd
	end
	if minXSpd then
		self.speed.minx = minXSpd
	end
	if minYSpd then
		self.speed.miny = minYSpd
	end

	self.moveType=0
	if self.myState ~= "jump" then
		self.myState =Fight.state_move
	end
	return self
end



--执行运动函数
function ExploreMoveInstance:move( spd )
	if self.myState == Fight.state_stand then
		self:initMove()
	end

	if spd then
		self.speed.x =  spd
	else
		self.speed.x =  self.walkSpeed
	end
end

--执行站立操作
function ExploreMoveInstance:stand(  )
	if self.myState == Fight.state_jump then
		self.speed.x =0
		self.speed.y =0
		return
	end
	self:initStand()
end

--执行跳跃操作
function ExploreMoveInstance:jump( spd )
	if spd ~= 0 then
		self:initJump(spd)
	else
		echo("______________没有默认的跳跃速度")
		--self:initJump(self.data.jumpSpeed)
	end
end

-- 设置加速度
function ExploreMoveInstance:setAddSpeed(xspd ,yspd ,zspd  )
	if xspd then
		self.addSpeed.x = xspd
	end
	if yspd then
		self.addSpeed.y = yspd
	end
	if zspd then
		self.addSpeed.z = zspd
	end
	if not self.addSpeed.z then
		error("__没有addzpsd__",xpsd,yspd,zspd)
	end
end

--设置重力加速度
function ExploreMoveInstance:setGravity( gravity )
	self.addSpeed.z = gravity
end

--设置速度
function ExploreMoveInstance:setSpeed(xspd ,yspd ,zspd  )
	-- if self.countId == 4 then
	-- 	echoError("44444",xspd ,yspd ,zspd )
	-- end
	if xspd then
		self.speed.x = xspd
	end
	if yspd then
		self.speed.y = yspd
	end

	if zspd then
		self.speed.z = zspd
	end
	if not self.speed.z then
		error("__没有addzpsd__",xspd,yspd,zspd)
	end
	return self
end

--重写控制事件
function ExploreMoveInstance:controlEvent(  )
	ExploreMoveInstance.super.controlEvent(self)

	self:checkMoveType()	
end

-- 判断运动类型
function ExploreMoveInstance:checkMoveType(...)
	if self.moveType == 0 then
		return
	end
	if self._isPauseMove then
		return
	end

	if not self.movePostion then
		echoError("ModelMoveBasic没有运动到点..____s"..self.moveType.."___阵营"..self.camp.."__"..self.pos.x.."__"..self.pos.y)
	end

	local dx = self.movePostion.x - self.pos.x
	local dy = self.movePostion.y - self.pos.y
	
	--如果x速度为0了 那么修正dx为0
	if math.abs( self.speed.x ) <= 0.1 then
		dx =0
	end
	--如果y速度为0了 那么修正dy为0
	if math.abs( self.speed.y ) <= 0.1 then
		dy =0
	end
	local posInfo = nil
	posInfo = self.movePostion

	--如果小于一个速度的距离了 那么表示到达目标点了
	local dis = dx*dx +dy*dy

	local whetherEnd =false

	--如果有摩擦力
	if posInfo.f then
		self.speed.x = self.speed.x * posInfo.f
		self.speed.y = self.speed.y * posInfo.f
	--如果有加速度
	elseif posInfo.a then
		self.speed.x = self.speed.x + posInfo.a 
	end

	if posInfo.frame then
		posInfo.frame = posInfo.frame - 1
		if posInfo.frame <= 0 then
			whetherEnd = true
		end
	else
		--如果有z速度 那么必须配z 只需判断z是否到达
		if posInfo.vz then
			local dz= posInfo.z- self.pos.z
			if  math.abs(dz) < 3 then
				posInfo.x = self.pos.x
				posInfo.y = self.pos.y
				whetherEnd = true
			end
		else
			local oneSpeedDis = (self.speed.x*self.speed.x + self.speed.y*self.speed.y) * 1.1 + 2
			-- echo("\n\noneSpeedDis====",oneSpeedDis)
			-- echo("dis===",dis)
			--如果小于一个速度的距离了 那么表示到达目标点了
			if dis <= oneSpeedDis then
				whetherEnd = true
			end
		end
	end

	if whetherEnd then
		self.pos.x = posInfo.x
		self.pos.y = posInfo.y
		--更新网格坐标
		if posInfo.gridX then
			local fromx,fromy = self.gridPos.x ,self.gridPos.y
			self.gridPos.x = posInfo.gridX
			self.gridPos.y = posInfo.gridY
			local leng = #self.movePointsInfo.point
			self:oneGridArrived(posInfo.gridX,posInfo.gridY, fromx,fromy,self.movePointsInfo.step,leng == self.movePointsInfo.step)
		end
		if self._willStop then
			--直接做回调
			self:overTargetPoint(false)
			self:doMoveCallBack(posInfo)
			
			return
		end
		--如果只是单纯的运动到点
		if self.moveType == moveType_moveToTarget then
			self:overTargetPoint(true)
			--如果有回调函数的
			self:doMoveCallBack(posInfo)

		elseif self.moveType == moveType_moveByPosArr then
			local index = self.movePointsInfo.step
			local leng = #self.movePointsInfo.point
			local repeateType = self.movePointsInfo.type
			--如果还没运动到最后一个点
			if index < leng then
				self.movePointsInfo.step = self.movePointsInfo.step + 1
				self:moveToPoint(self.movePointsInfo.point[index+1],self.movePointsInfo.speed,moveType_moveByPosArr)
				
				--如果有回调函数的
				self:doMoveCallBack(posInfo)
			else
				--如果有回调函数的
				self:doMoveCallBack(posInfo)

				-- 不重复
				if repeateType == 0 then
					self:overTargetPoint(true)
				-- 从头开始
				elseif repeateType == 1 then
					index = 1
					self.movePointsInfo.step = 1
					self:moveToPoint(self.movePointsInfo.point[index],self.movePointsInfo.speed,moveType_moveByPosArr)
				elseif repeateType == 2 then
					index = 1
					self.movePointsInfo.step = 1
					
					self.movePointsInfo.point = RandomControl.randomOneGroupArr(self.movePointsInfo.point)
					self:moveToPoint(self.movePointsInfo.point[index],self.movePointsInfo.speed,moveType_moveByPosArr)
				end
			end
		end

		
	end 
end

function ExploreMoveInstance:doMoveCallBack( posInfo )
	--如果有回调函数的
	if posInfo then
		if posInfo.call ~=nil then
			if posInfo.call[2] then
				--posInfo.call[1](unpack(posInfo.call[2]))
				self[posInfo.call[1]](self,true,unpack(posInfo.call[2]))
			else
				self[posInfo.call[1]](self,true)
			end
		end
	end
end

--更新速度
function ExploreMoveInstance:updateSpeed( ... )
	-- if math.abs(self.speed.x) < 0.05 then
	-- 	self.speed.x = 0
	-- end

	-- if math.abs(self.speed.y) < 0.05 then
	-- 	self.speed.y = 0
	-- end
	if self._isPauseMove then
		return
	end
	if self.speed.minx then
		if math.abs(self.speed.x) <= math.abs(self.speed.minx) then
			self.speed.x = self.speed.minx
		end
	else
		if math.abs(self.speed.x) < 0.05 then
			self.speed.x = 0
		end
	end

	if self.speed.miny then
		if math.abs(self.speed.y) <= math.abs(self.speed.miny) then
			self.speed.y = self.speed.miny
		end
	else
		if math.abs(self.speed.y) < 0.05 then
			self.speed.y = 0
		end
	end

	--如果不受重力
	if not self.gravitiAble then
		return
	end

	--只有跳跃状态才改变速度
	if self.myState ~= Fight.state_jump then
		return
	end
	
	self.speed.z = self.speed.z + self.addSpeed.z 

	if math.abs(self.speed.z ) < 0.005 then
		self.speed.z =0
	end
end

--移动坐标
function ExploreMoveInstance:moveXYZPos()
	if self._isPauseMove then
		return
	end
	-- echo("self.speed.x====",self.speed.x)
	self.pos.x = (self.pos.x + self.speed.x)
	self.pos.y = (self.pos.y + self.speed.y)
	self.pos.z = (self.pos.z + self.speed.z)

	local mapControler = self.controler.mapControler
	--判断边界
	if self.speed.x~= 0 or self.speed.y ~= 0 or mapControler:checkMapIsMoved()  then
		mapControler:checkInstanceIsOut(self)
	end

end

--运动到目标了
function ExploreMoveInstance:overTargetPoint(isEnd  )
	self:initMoveType()
	self:initStand()
	
end

--紧紧一个格子到达了
function ExploreMoveInstance:oneGridArrived( gridx,gridy,fromx,fromy,index )
	--判断是否需要


end
 
--运动函数  运动到点  targetPoint 的属性  x,y, z(z坐标默认空), vz(z速度，默认空),speed(xy平面的速度大小,默认空),
--[[
{
	x,
	y,
	speed, 水平速度
	vz, --z速度, 当有z速度的时候  那么只判定dz 是否小于某个值
	z,如果有vz 那么必须配z坐标
	f, -- 摩擦力  -- 减速运动  用x速度 * f ,当速度为0的时候判定到达
	minSpeed,	--水平和垂直方向,最小速度，与f配合使用

	a,	-- 水平方向加速度 ,和摩擦力有所区别, 这个是 用速度 +a,
	g, -- 重力 ,手动传递重力加速度,
	frame, -- 运动的帧数 ,当帧数为0的时候判定到达
	call= {func,params }  --到达回调 func 必须是自身的某个函数字符串,params 必须是可被json化的
}
]]
function ExploreMoveInstance:moveToPoint(targetPoint, speed,moveType )
	if not moveType  then
		moveType = moveType_moveToTarget
	end

	--只要有运动行为就探开迷雾
	ExploreGridControler:updateOneGridMists(targetPoint.gridX,targetPoint.gridY,0)
	-- ExploreGridControler:updateOneEventMists(targetPoint.gridX,targetPoint.gridY,true)
	-- local nearPoints = FuncGuildExplore.nearPoints
	-- for i,v in ipairs(nearPoints) do
	-- 	local nearX,nearY = targetPoint.gridX + v[1],targetPoint.gridY+ v[2]
	-- 	-- echo("_222222222220",nearX,nearY,GuildExploreModel:getSubGridEvent(nearX,nearY,true))
	-- 	if GuildExploreModel:getSubGridEvent(nearX,nearY,true) then
	-- 		ExploreGridControler:updateOneEventMists(nearX,nearY,true)
	-- 	end

	-- end


	self.controler:checkShowMiniView(targetPoint.gridX,targetPoint.gridY  )
	self.controler.mapControler:setWillRefreshCount(1)
	-- targetPoint.call = {"onMoveToPointCallBack"}

	--修正速度
	local radian = self:calRadian(targetPoint)
	self.radian = radian
	local distance = self:calDistance(targetPoint)

	speed= self._data.userInfo.speed or 10000
	speed = 10000/ speed *FuncGuildExplore.oneGridMoveFrame
	speed = distance / speed

	-- self.angle = self:calAngle(targetPoint)
	
	local xspd = math.cos(radian) * speed
	local yspd = math.sin(radian) * speed
	self:initMove(xspd,yspd,minXSpd,minYSpd)
	self.moveType = moveType
	self.movePostion = targetPoint

	local oldGirdX,oldGridY = self.gridPos.x,self.gridPos.y
	self.gridPos.x = self.movePostion.gridX
	self.gridPos.y = self.movePostion.gridY
	self.controler:checkOnePosPlayer(oldGirdX,oldGridY )
	self.controler:checkOnePosPlayer(targetPoint.gridX,targetPoint.gridY)
	--速度大于0 朝右
	if self.speed.x > 0 then
		self:setWay(1)
	else
		self:setWay(-1)
	end
	self:playMoveAction()
	if self._isSelf then
		--本地扣除一点精力值
		if not self._isRecentMove then
			GuildExploreModel:changeEnegry(-1 )
		end
		
	end
	--强制move一次
	self:checkMoveType()
end

function ExploreMoveInstance:calRadian(targetPoint)
	local dx = targetPoint.x - self.pos.x
	local dy = targetPoint.y - self.pos.y
	local radian = math.atan2(dy, dx)
	return radian
end

--计算距离
function ExploreMoveInstance:calDistance(targetPoint)
	local dx = targetPoint.x - self.pos.x
	local dy = targetPoint.y - self.pos.y
	return math.sqrt(dx*dx+dy*dy)
end

function ExploreMoveInstance:calAngle(targetPoint)
	local radian = self:calRadian(targetPoint)
	return radian * 180 / math.pi
end

function ExploreMoveInstance:onMoveToPointCallBack()
	-- echo("\nExploreMoveInstance:onMoveToPointCallBack")
end

--运动函数  根据一系列点运动						重复类型 0 表示不重复 1表示重头开始 2表示随机点序列以后重复
function ExploreMoveInstance:moveByPointArr( pointArr,speed,repeateType )
	-- body
   if not repeateType  then repeateType = 0	end
   self:setWillStop(false)
   self.moveType = moveType_moveByPosArr
   self.movePointsInfo.point =  pointArr--clone( pointArr )
   self.movePointsInfo.step = 1
   self.movePointsInfo.type = repeateType
   self.movePointsInfo.speed= speed
   self:moveToPoint(pointArr[1],speed,moveType_moveByPosArr)

end


--根据一系列grid 运动
function ExploreMoveInstance:moveByGridPointArr( pointArr,speed )
	
	if #pointArr == 0 then
		return
	end

	if self._isSelf then
		self.controler.mainUI:showOrHideWalkCue(true)
	end

	for i,v in ipairs(pointArr) do
		local gamePos =  self.gridControler:getGridWorldPos( v.x,v.y )
		v.gridX = v.x
		v.gridY = v.y
		v.x = gamePos.x
		v.y = gamePos.y
	end
	self:moveByPointArr(pointArr,speed)
end




--映射到目标点 pos(x,y,z)
function ExploreMoveInstance:mapSpeedToTargetPos( pos,spd )
	local dx = pos.x - self.pos.x
	local dy = pos.y - self.pos.y
	local dz = pos.z - self.pos.z

	local dis = dx*dx+ dy*dy + dz*dz
	dis = math.sqrt(dis)
	if dis ==0 then
		return
	end
	local value = spd /dis
	
	self:setSpeed(dx * value,dy*value,dz *value)

end

--初始化运动类型
function ExploreMoveInstance:initMoveType( ... )
	self.moveType =0
	self.movePostion=nil
end

--计算速度
function ExploreMoveInstance:countSpeed( targetX,targetY,frame ,minSpeed )
	frame  =  frame or 10
	local dx = targetX - self.pos.x
	local dy = targetY - self.pos.y
	local speed = math.round( math.sqrt( dx*dx + dy*dy ) /frame )
	minSpeed = minSpeed or Fight.moveMinSpeed
	if speed < minSpeed then
		speed = minSpeed
	end
	return speed
end

function ExploreMoveInstance:getWorldPos()
	local point = {x=0,y=0}
	if self.myView then
		point = self.myView:convertToWorldSpaceAR(cc.p(0,0));
	end

	return point
end


function ExploreMoveInstance:setWillStop( value )
	self._willStop = value
end

-- 是否在屏幕可见范围内
function ExploreMoveInstance:isInScreen(  )
	local targetPoint = self:getWorldPos()

	local minX = -self.mySize.width / 2
	local maxX = GameVars.width + self.mySize.width / 2
	local minY = -self.mySize.height
	local maxY = GameVars.height

	if targetPoint.x < minX or targetPoint.x > maxX 
		or targetPoint.y < minY or targetPoint.y > maxY then
		return false
	end

	return true
end


--播放动作
function ExploreMoveInstance:changeAction( label )
	self.label = label
	if self.myView then
		self.myView:playLabel(label, true)
	end
	--如果是出界的 那么需要stopframe
	if self._isOut then
		self:stopFrame()
	end
end

--转化信息
function ExploreMoveInstance:turnMoveInfoToServer(startX,startY,endX,endY,movePathArr  )
	local source = FuncGuildExplore.getKeyByPos(startX,startY)
	local target = FuncGuildExplore.getKeyByPos(endX,endY)
	local posArr = {
	}

	if movePathArr[1].x ~= startX or  movePathArr[1].y ~= startY then
		table.insert(posArr,source)
	end

	for i,v in ipairs(movePathArr) do
		table.insert(posArr,FuncGuildExplore.getKeyByPos(v.x,v.y) )
	end
	local tb = {
		source = source,
		target = posArr[#posArr],
		positionList = posArr
	}
	return tb
end





--当数据发生变化
function ExploreMoveInstance:onDataChange(changeData )
	--如果是坐标发生变化
	if changeData.pos then
		
		self:updatePosInfo(changeData.pos )

	end

end



--更新坐标 根据位置信息
function ExploreMoveInstance:updatePosInfo( posInfo )
	if self._isSelf then
		self.controler.mainUI:showOrHideWalkCue(false)
	end
	-- 计算服务器当前时间和 这个坐标的运动时间 
	local distime = TimeControler:getServerTime() - math.floor(posInfo.moveTime/1000) - 1
	--计算走一格需要的时间
	local needMoveGridNums = math.ceil(distime/FuncGuildExplore.oneGridMoveFrame *30)
	local gridX ,gridY = FuncGuildExplore.getPosByKey(posInfo.source)
	if not posInfo.positionList or #posInfo.positionList <=1 then
		-- echo(gridX,gridY,"gridX,gridY---------",self.gridPos.x,self.gridPos.y)
		-- if self.moveType ~= 0 then
		-- 	echo(self.movePostion.gridX ,self.movePostion.gridY,"____self.movePosition.gridX ")
		-- end
		
		if self.gridPos.x == 0 and self.gridPos.y == 0 then
			self:setGridPos(gridX, gridY)
			self.controler:checkOnePosPlayer(gridX, gridY)
		else
			if self.moveType ~= 0 and self.movePostion.gridX == gridX and  self.movePostion.gridY  == gridY then
				return
			end
			-- self:setGridPos(gridX, gridY)
			self.controler:checkOnePosPlayer(gridX, gridY)
			if self._willStop then
				self._willStop =false
				self:initMoveType()
				self:initStand()
			end

		end
	else
		local posList = posInfo.positionList
		local length = #posList
		--这里需要做一下边界兼容
		if needMoveGridNums > length then
			needMoveGridNums = length
		end
		if needMoveGridNums < 1 then
			needMoveGridNums = 1
		end

		--如果是还没设置过坐标 那么直接设置到那里去
		if self.gridPos.x == 0 and self.gridPos.y == 0 then
			-- self.gridPos.x ,self.gridPos.y = FuncGuildExplore.getPosByKey(posList[needMoveGridNums])
			self:setGridPos(FuncGuildExplore.getPosByKey(posList[needMoveGridNums]))
			self.controler:checkOnePosPlayer(gridX, gridY)
			--标记是否是 上一次为完成的移动 这个是不需要消耗能量的
			self._isRecentMove = true
		else
			self._isRecentMove =false
			-- echo("____这是初始化----",self.gridPos.x,self.gridPos.y)
		end

		--判断当前点 在哪个位置
		local key = FuncGuildExplore.getKeyByPos(self.gridPos.x, self.gridPos.y)

		local currentIndex = 1
		for i,v in ipairs(posList) do
			if tonumber(v) == tonumber(key) then
				currentIndex = i
				break
			end
		end
		echo(currentIndex,"__currentIndex",needMoveGridNums,"needMoveGridNums")
		--如果小于4格 那么 那么判定 接着走 
		if needMoveGridNums - currentIndex <= 4 then
			needMoveGridNums = currentIndex
		end

		local indexNums =0;
		local pathArr = {}
		for i=needMoveGridNums,length do
			local gridpos = posList[i]
			local x,y =  FuncGuildExplore.getPosByKey( gridpos )
			indexNums = indexNums +1
			if indexNums > 1 then
				table.insert(pathArr,{x=x,y=y} )
			end
		end

		for i=1,needMoveGridNums -1 do
			local gridpos = posList[i]
			local x,y =  FuncGuildExplore.getPosByKey( gridpos )
			self.gridControler:updateOneGridMists( x,y ,0 )
		end


		if self._isSelf then
			self.controler.mapControler:showOnePath(pathArr,self.gridPos.x,self.gridPos.y)
			self.controler.mapControler:setMapFollowPlayer()
		end
		--如果直接是最后一步了 那么发送确认消息 
		if #pathArr ==0 then
			GuildExploreServer:sureArrive(  )	
		end
		self:moveByGridPointArr(pathArr,5)


	end

end


--设置网格坐标
function ExploreMoveInstance:setGridPos( gridX,gridY )
	ExploreMoveInstance.super.setGridPos(self, gridX,gridY )
	self.controler.mapControler:checkInstanceIsOut(self)
end


function ExploreMoveInstance:setIsPauseMove( value )
	self._isPauseMove = value
	if value then
		-- self:playStandAction()
	else
		-- self:playMoveAction()
	end
end



return ExploreMoveInstance