
local Fight = Fight


--地面高度
local groundLandHeigt = 0

local moveType_moveToTarget = 1 		--运动到某个点  
local moveType_moveByPosArr = 2 		--按照一系列运动点

local TowerBasicModel = require("game.sys.view.tower.model.TowerBasicModel")

local TowerMoveModel = class("TowerMoveModel",TowerBasicModel)


--[[-速度也变成{x=0,y=0,z=0}的格式 为了统一 ]]
TowerMoveModel.speed = nil
TowerMoveModel.addSpeed = nil 			--加速度
TowerMoveModel.myState = Fight.state_stand 	--状态 


TowerMoveModel.gravitiAble = true 	--能否受重力
 
 --运动类型
TowerMoveModel.moveType =  0 	--运动类型
TowerMoveModel.movePostion = nil 	 --运动到点的坐标
TowerMoveModel.movePointsInfo = nil 	-- 根据一系列点来运动

TowerMoveModel.viewMoving = false -- 视图移动控制

function TowerMoveModel:ctor( ... )
 	TowerMoveModel.super.ctor(self,...)
 	self.movePointsInfo = {}
 	self.speed = {x=0,y=0,z=0} 
 	self.addSpeed = {x=0,y=0,z=3}


 	--当前动作标签
 	self.label = nil
 	--当前方位 只分左右
 	self.way = 1
 	--当前角度
 	self.rotation = 0

 	if not self.mySize then
		self.mySize = {width = 0,height=0}
	end
end

function TowerMoveModel:initView(...)
	TowerMoveModel.super.initView(self,...)
end

--初始化状态
function TowerMoveModel:initStand( )
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

 	return self
end

function TowerMoveModel:initJump(jumpSpd )
	self.moveType=0
	self.speed.z = jumpSpd or 0
	if not jumpSpd then
		echoError("__没有给z速度")
	end
	self.myState = Fight.state_jump
	return self
end

function TowerMoveModel:initMove(xspd,yspd,minXSpd,minYSpd)
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
function TowerMoveModel:move( spd )
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
function TowerMoveModel:stand(  )
	if self.myState == Fight.state_jump then
		self.speed.x =0
		self.speed.y =0
		return
	end
	self:initStand()
end

--执行跳跃操作
function TowerMoveModel:jump( spd )
	if spd ~= 0 then
		self:initJump(spd)
	else
		echo("______________没有默认的跳跃速度")
		--self:initJump(self.data.jumpSpeed)
	end
end

-- 设置加速度
function TowerMoveModel:setAddSpeed(xspd ,yspd ,zspd  )
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
function TowerMoveModel:setGravity( gravity )
	self.addSpeed.z = gravity
end

--设置速度
function TowerMoveModel:setSpeed(xspd ,yspd ,zspd  )
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
function TowerMoveModel:controlEvent(  )
	TowerMoveModel.super.controlEvent(self)

	self:checkMoveType()	
end

-- 判断运动类型
function TowerMoveModel:checkMoveType(...)
	if self.moveType == 0 then
		return
	end

	if not self.movePostion then
		error("ModelMoveBasic没有运动到点..____s"..self.moveType.."___阵营"..self.camp.."__"..self.pos.x.."__"..self.pos.y)
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
		
		--如果只是单纯的运动到点
		if self.moveType == moveType_moveToTarget then
			self:overTargetPoint()
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

		elseif self.moveType == moveType_moveByPosArr then
			local index = self.movePointsInfo.step
			local leng = #self.movePointsInfo.point
			local repeateType = self.movePointsInfo.type
			--如果还没运动到最后一个点
			if index < leng then
				self.movePointsInfo.step = self.movePointsInfo.step + 1
				self:moveToPoint(self.movePointsInfo.point[index+1],self.movePointsInfo.speed,moveType_moveByPosArr)
				
				--如果有回调函数的
				if posInfo then
					if posInfo.call ~=nil then
						if posInfo.call[2] then
							--posInfo.call[1](unpack(posInfo.call[2]))
							self[posInfo.call[1]](self,false,unpack(posInfo.call[2]))
						else
							self[posInfo.call[1]](self,false)
						end
					end
				end	
			else
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

				-- 不重复
				if repeateType == 0 then
					self:overTargetPoint()
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

--更新速度
function TowerMoveModel:updateSpeed( ... )
	-- if math.abs(self.speed.x) < 0.05 then
	-- 	self.speed.x = 0
	-- end

	-- if math.abs(self.speed.y) < 0.05 then
	-- 	self.speed.y = 0
	-- end

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
function TowerMoveModel:moveXYZPos()
	-- echo("self.speed.x====",self.speed.x)
	self.pos.x = (self.pos.x + self.speed.x)
	self.pos.y = (self.pos.y + self.speed.y)
	self.pos.z = (self.pos.z + self.speed.z)
	if self.pos.z > groundLandHeigt then
		self.pos.z = groundLandHeigt
	end
end

--运动到目标了
function TowerMoveModel:overTargetPoint(  )
	self:initMoveType()
	self:initStand()
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
function TowerMoveModel:moveToPoint(targetPoint, speed,moveType )
	if not moveType  then
		moveType = moveType_moveToTarget
	end

	if targetPoint.speed then
		speed = targetPoint.speed
	end

	if not targetPoint.f then
		targetPoint.minSpeed = nil
	end

	targetPoint.call = {"onMoveToPointCallBack"}

	--修正速度
	local radian = self:calRadian(targetPoint)
	self.radian = radian
	self.angle = self:calAngle(targetPoint)
	
	local xspd = math.cos(radian) * speed
	local yspd = math.sin(radian) * speed
	
	local minXSpd = nil
	local minYSpd = nil
	if targetPoint.minSpeed then
		minXSpd = math.cos(radian) * targetPoint.minSpeed
		minYSpd = math.sin(radian) * targetPoint.minSpeed
	end

	--如果有重力
	if targetPoint.g then
		self:setGravity(targetPoint.g)
	end

	self:initMove(xspd,yspd,minXSpd,minYSpd)
	if targetPoint.vz then
		self:initJump(targetPoint.vz)
	end

	self.moveType = moveType
	self.movePostion = targetPoint
	--强制move一次
	self:checkMoveType()
end

function TowerMoveModel:calRadian(targetPoint)
	local dx = targetPoint.x - self.pos.x
	local dy = targetPoint.y - self.pos.y
	local radian = math.atan2(dy, dx)
	return radian
end

function TowerMoveModel:calAngle(targetPoint)
	local radian = self:calRadian(targetPoint)
	return radian * 180 / math.pi
end

function TowerMoveModel:onMoveToPointCallBack()
	echo("\nTowerMoveModel:onMoveToPointCallBack")
end

--运动函数  根据一系列点运动						重复类型 0 表示不重复 1表示重头开始 2表示随机点序列以后重复
function TowerMoveModel:moveByPointArr( pointArr,speed,repeateType )
	-- body
   if not repeateType  then repeateType = 0	end
   self.moveType = moveType_moveByPosArr
   self.movePointsInfo.point =  pointArr--clone( pointArr )
   self.movePointsInfo.step = 1
   self.movePointsInfo.type = repeateType
   self.movePointsInfo.speed= speed
   self:moveToPoint(pointArr[1],speed,moveType_moveByPosArr)
end

--映射到目标点 pos(x,y,z)
function TowerMoveModel:mapSpeedToTargetPos( pos,spd,viewRota )
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

	if viewRota then
		local rota = math.atan2(dz+dy,dx)
		--如果改变角度 那么 需要setWay 为1 
		--echo("____________rota==", rota) 
		self:setWay(1)

		if self.myView then
			self.myView:setRotation(rota *180/math.pi)
		end
	end
end

--初始化运动类型
function TowerMoveModel:initMoveType( ... )
	self.moveType =0
	self.movePostion=nil
end

--计算速度
function TowerMoveModel:countSpeed( targetX,targetY,frame ,minSpeed )
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

function TowerMoveModel:getWorldPos()
	local point = {x=0,y=0}
	if self.myView then
		point = self.myView:convertToWorldSpaceAR(cc.p(0,0));
	end

	return point
end

-- 是否在屏幕可见范围内
function TowerMoveModel:isInScreen(  )
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

return TowerMoveModel
