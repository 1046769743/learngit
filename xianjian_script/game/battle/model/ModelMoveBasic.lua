
local Fight = Fight


--地面高度
local groundLandHeigt = 0

local moveType_moveToTarget = 1 		--运动到某个点  
local moveType_moveByPosArr = 2 		--按照一系列运动点
local moveType_moveByJump = 3             --跳跃、击飞


ModelMoveBasic = class("ModelMoveBasic",ModelBasic)


--[[-速度也变成{x=0,y=0,z=0}的格式 为了统一 ]]
ModelMoveBasic.speed = nil
ModelMoveBasic.addSpeed = nil 			--加速度
ModelMoveBasic.myState = Fight.state_stand 	--状态 


ModelMoveBasic.gravitiAble = true 	--能否受重力
 
 --运动类型
ModelMoveBasic.moveType =  0 	--运动类型
ModelMoveBasic.movePostion = nil 	 --运动到点的坐标
ModelMoveBasic.movePointsInfo = nil 	-- 根据一系列点来运动

ModelMoveBasic.viewMoving = false -- 视图移动控制


function ModelMoveBasic:ctor( ... )
 	ModelMoveBasic.super.ctor(self,...)
 	self.movePointsInfo = {}
 	self.speed = {x=0,y=0,z=0} 
 	self.addSpeed = {x=0,y=0,z=3}
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--初始化状态
function ModelMoveBasic:initStand( )
 	if self.movePostion and self.moveType ~= 0 then
 		return
 	end

 	self.myState =Fight.state_stand
 	self:setSpeed(0,0,0)
 	self.moveType=0

 	return self
end

function ModelMoveBasic:initJump(jumpSpd )
	self.moveType=moveType_moveByJump
	self.speed.z = jumpSpd or 0
	if not jumpSpd then
		echoError("__没有给z速度")
	end
	self.myState = Fight.state_jump
	return self
end

function ModelMoveBasic:initMove(xspd,yspd )
	if xspd then
		self.speed.x = xspd
	end
	if yspd then
		self.speed.y = yspd
	end
	self.moveType=0
	if self.myState ~= "jump" then
		self.myState =Fight.state_move
	end
	return self
end

--执行运动函数
function ModelMoveBasic:move( spd )
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
function ModelMoveBasic:stand(  )
	if self.myState == Fight.state_jump then
		self.speed.x =0
		self.speed.y =0
		return
	end
	self:initStand()
end

--执行跳跃操作
function ModelMoveBasic:jump( spd )
	if spd ~= 0 then
		self:initJump(spd)
	else
		echo("______________没有默认的跳跃速度")
		--self:initJump(self.data.jumpSpeed)
	end
end

-- 设置加速度
function ModelMoveBasic:setAddSpeed(xspd ,yspd ,zspd  )
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
function ModelMoveBasic:setGravity( gravity )
	self.addSpeed.z = gravity
end


--设置速度
function ModelMoveBasic:setSpeed(xspd ,yspd ,zspd  )
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


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--重写控制事件
function ModelMoveBasic:controlEvent(  )
	ModelMoveBasic.super.controlEvent(self)

	self:checkMoveType()	
end

-- 判断运动类型
function ModelMoveBasic:checkMoveType( ... )

	if self.moveType == 0 then
		return
	end
	if self.moveType == 3 then
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
	local dis2 = dx*dx +dy*dy

	local whetherEnd =false

	

	--如果有摩擦力
	if posInfo.f then
		self.speed.x = self.speed.x * posInfo.f
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
		if posInfo.vz and false then
			local dz= posInfo.z- self.pos.z
			--
			if  math.abs(dz) < 3 then
				posInfo.x = self.pos.x
				posInfo.y = self.pos.y
				whetherEnd = true
			end
		else

			if dis2 <= (self.speed.x*self.speed.x + self.speed.y*self.speed.y) *1.1 +2 then
				whetherEnd = true
			end

		end
	end

	

	if  whetherEnd then
		self.pos.x = posInfo.x
		self.pos.y = posInfo.y
		
		--如果只是单纯的运动到点
		if self.moveType == moveType_moveToTarget then
			self:overTargetPoint()
			--echo("11111111111111111________________________",self.controler.updateCount )
		elseif self.moveType == moveType_moveByPosArr then
			local index = self.movePointsInfo.step
			local leng = #self.movePointsInfo.point
			local repeateType = self.movePointsInfo.type
			--如果还没运动到最后一个点
			if index < leng then
				self.movePointsInfo.step = self.movePointsInfo.step + 1
				self:moveToPoint(self.movePointsInfo.point[index+1],self.movePointsInfo.speed,moveType_moveByPosArr)
			else
				if repeateType == 0 then
					self:overTargetPoint()
				--	
				elseif repeateType == 1 then
					index = 1
					self.movePointsInfo.step =1
					self:moveToPoint(self.movePointsInfo.point[index],self.movePointsInfo.speed,moveType_moveByPosArr)
				elseif repeateType == 2 then
					index = 1
					self.movePointsInfo.step =1
					
					self.movePointsInfo.point = BattleRandomControl.randomOneGroupArr(self.movePointsInfo.point)
					self:moveToPoint(self.movePointsInfo.point[index],self.movePointsInfo.speed,moveType_moveByPosArr)
				end
			end
		end

		--如果有回调函数的
		-- if posInfo then
			-- if posInfo.call ~=nil then
				-- posInfo.call = nil
				-- 执行操作是通过 pushOneCallFunc处理的，这里只做置空，下面注掉
				-- if posInfo.call[2] then
				-- 	--posInfo.call[1](unpack(posInfo.call[2]))
				-- 	self[posInfo.call[1]](self,unpack(posInfo.call[2]))
				-- else
				-- 	self[posInfo.call[1]](self)
				-- end
			-- end
		-- end	
	end 
end

-- function ModelMoveBasic:doMoveEndFunc(moveInfo)
-- 	if posInfo.call ~=nil then
-- 		if posInfo.call[2] then
-- 			--posInfo.call[1](unpack(posInfo.call[2]))
-- 			self[posInfo.call[1]](self,unpack(posInfo.call[2]))
-- 		else
-- 			self[posInfo.call[1]](self,moveSpeed)
-- 		end
-- 	end
-- end


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--更新速度
function ModelMoveBasic:updateSpeed( ... )
	if math.abs(self.speed.x) < 0.05 then
		self.speed.x =0
	end
	if math.abs(self.speed.y) < 0.05 then
		self.speed.y = 0
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

	if self.data and self.data.changeRota then

		local rota = math.atan2(self.speed.z,self.speed.x)
		--如果改变角度 那么 需要setWay 为1  
		self:setWay(1)
		if self.myView then
			self.myView:setRotation(rota *Fight.radian_angle)
		end

	end

	if math.abs(self.speed.z )<0.005 then
		self.speed.z =0
	end
end

--移动坐标
function ModelMoveBasic:moveXYZPos()
	self.pos.x = (self.pos.x + self.speed.x)
	self.pos.y = (self.pos.y + self.speed.y)
	self.pos.z = (self.pos.z + self.speed.z)
	if self.pos.z > groundLandHeigt then
		self.pos.z = groundLandHeigt
	end
end


--运动到目标了
function ModelMoveBasic:overTargetPoint(  )
	self:initMoveType()
	self:initStand()
end
 
-- 判定取消移动状态（慎用）
function ModelMoveBasic:cancelMove()
	-- 如果在移动才停止移动
	if self.moveType == moveType_moveToTarget then
		-- 如果还没有移动到位置就被拉去做其他的事情，那么之前注册的callBack要清除
		if self.movePostion and self.movePostion.call then
			self:clearOneCallFunc(self.movePostion.call[1])
			self.movePostion.call = nil
		end
		
		self:overTargetPoint()
	end
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
	a,	-- 水平方向加速度 ,和摩擦力有所区别, 这个是 用速度 +a,
	g, -- 重力 ,手动传递重力加速度,
	frame, -- 运动的帧数 ,当帧数为0的时候判定到达
	call= {func,params }  --到达回调 func 必须是自身的某个函数字符串,params 必须是可被json化的
}
]]
function ModelMoveBasic:moveToPoint(targetPoint, speed,moveType )
	-- 如果还没有移动到位置就被拉去做其他的事情，那么之前注册的callBack要清除
	if self.movePostion and self.movePostion.call then
		self:clearOneCallFunc(self.movePostion.call[1])
		self.movePostion.call = nil
	end

	--快速跑游戏 是不需要走这里的 只做回调
	if self.controler:isQuickRunGame() then
		self:initMoveType()
		self:initStand()
		if targetPoint.call then
			self:pushOneCallFunc(1,targetPoint.call[1] , targetPoint.call[2])
		end
		return
	end

	if not moveType  then
		moveType = moveType_moveToTarget
	end

	if targetPoint.speed then
		speed =targetPoint.speed
	end

	speed = speed or self.data.speed

	--修正速度
	local dx = targetPoint.x - self.pos.x
	local dy = targetPoint.y - self.pos.y
	local ang = math.atan2(dy, dx)
	local xspd = math.cos(ang) * speed
	local yspd = math.sin(ang)* speed
	local dis = dx*dx+dy*dy

	--如果有重力
	if targetPoint.g then
		self:setGravity(targetPoint.g)
	end

	self:initMove(xspd,yspd)

	if targetPoint.vz then
		self:initJump(targetPoint.vz)
	end

	self.moveType = moveType
	self.movePostion = targetPoint
	--强制move一次
	self:checkMoveType()

	local time = math.ceil(math.sqrt(dis)/speed) + 1 -- 实际移动会晚一帧
	if targetPoint.call then
		self:pushOneCallFunc(time,targetPoint.call[1] , targetPoint.call[2])
		-- 不马上置空，在到达位置后或者清除回调后置空
		-- targetPoint.call = nil
	end
end


--运动函数  根据一系列点运动						重复类型 0 表示不重复 1表示重头开始 2表示随机点序列以后重复
function ModelMoveBasic:moveByPointArr( pointArr,speed,repeateType )
	-- body
   if not repeateType  then repeateType = 0	end
   self.moveType = moveType_moveByPosArr
   self.movePointsInfo.point =  pointArr--clone( pointArr )
   self.movePointsInfo.step = 1
   self.movePointsInfo.type = repeateType
   self.movePointsInfo.speed= speed
   self:moveToPoint(pointArr[1],speed,moveType_moveByPosArr)
end

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------

--映射到目标点 pos(x,y,z)
function ModelMoveBasic:mapSpeedToTargetPos( pos,spd,viewRota )
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
			self.myView:setRotation(rota *Fight.radian_angle)
		end
	end
end

--减速
function ModelMoveBasic:reduceSpeed( fx,fy,jumpFAble )
	if self.myState ==Fight.state_stand then
		return
	end

	if not fx then		fx = 0.95	end
	if not fy then		fy = 0.95	end

	--如果跳跃状态不受减速影响
	if not jumpFAble then
		if self.myState == Fight.state_jump  then return  end
	end

	self.speed.x=self.speed.x *fx

	if math.abs(self.speed.x) <= 0.04 then
		self.speed.x= 0
	end

	self.speed.y=self.speed.y *fy
	if math.abs(self.speed.y) <= 0.04 then
		self.speed.y= 0
	end

	if self.myState ==Fight.state_move  then
		if self.speed.x == 0  and self.speed.y ==0 then
			self:initStand()
		end
	end
end

--初始化运动类型
function ModelMoveBasic:initMoveType( ... )
	self.moveType =0
	self.movePostion=nil
end



--计算速度
function ModelMoveBasic:countSpeed( targetX,targetY,frame ,minSpeed )
	frame  =  frame or Fight.moveFrame
	local dx = targetX - self.pos.x
	local dy = targetY - self.pos.y
	local speed = math.round( math.sqrt( dx*dx + dy*dy ) /frame )
	minSpeed = minSpeed or Fight.moveMinSpeed
	if speed < minSpeed then
		speed = minSpeed
	end
	return speed
end


--判断大招屏幕镜头
function ModelMoveBasic:checkScreenCameraMax( skill )
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame() then
		return
	end

	local cameraUIArr = skill:sta_cameraUIArr()
	if cameraUIArr then
		-- dump(cameraUIArr,"___cameraUIArr")
		-- self:createEffGroup(cameraUIArr, false,true)
		for i,v in ipairs(cameraUIArr) do
			self:createCenterSpineEff(v.spn,v.texn,v.n,v.l)
		end
	end

	local cameraSkilParams = skill:sta_cameraSpineParams()
	local cameraEx = skill:sta_cameraSpineExpand()
	if cameraSkilParams then
		cameraSkilParams = cameraSkilParams[1]
		if cameraSkilParams.jingtou ~= "0" then
			local offsetPos = {x=0,y =0}
			local appearType = skill:sta_appear()
			--如果是 出现在第一个人的前面 那么需要根据人的位置进行偏移
			if appearType == Fight.skill_appear_normal or appearType == Fight.skill_appear_ymiddle 
				or appearType == Fight.skill_appear_myFirst or appearType == Fight.skill_appear_myyMiddle 
			 then
				
				local firstHero = skill.firstHeroModel
				if firstHero then
					--计算一下坐标偏差
					local x,y = self.controler.reFreshControler:turnPosition(firstHero.camp,2 ,1 ,self.controler.middlePos )
					local dx = firstHero._initPos.x - x
					local dy = firstHero._initPos.y - y
					offsetPos.x = dx  * (-1)
					offsetPos.y = dy

					local xRange = skill.xRange
					-- 是否偏移，如果根据攻击范围位置有偏移，则镜头不做偏移
					if skill.startXIndex ~= 1 and math.abs(skill.startXIndex - 1) < xRange then
						offsetPos.x = 0
					end

					--如果是y方向中间  那么offsetY 为0
					if appearType == Fight.skill_appear_ymiddle or appearType == Fight.skill_appear_myyMiddle   then
						offsetPos.y = 0
					end

				end
			end
			local bone = "jingtou"
			if cameraEx and cameraEx[1] ~= "0" then
				bone = cameraEx[1]
			end
			self.controler.camera:scaleBySpineAction(cameraSkilParams.jingtou ,bone,bone,self.way,offsetPos)
		end

		--立绘动画
		if cameraSkilParams.lihui ~= "0" then
			local ani = "skill"
			if cameraEx and cameraEx[2] ~= "0" then
				ani = cameraEx[2]
			end
			self:createCenterSpineEff(cameraSkilParams.lihui,nil,ani,3)
		end

		--文字动画
		if cameraSkilParams.wenzi ~= "0" then
			local ani = "wenzi"
			if cameraEx and cameraEx[3] ~= "0" then
				ani = cameraEx[3]
			end
			if self.way == 1 then
				ani = ani .. "2"
				self:createCenterSpineEff(cameraSkilParams.wenzi,nil,ani,4,true)
			else
				self:createCenterSpineEff(cameraSkilParams.wenzi,nil,ani,4,true)
			end
		end

	end
end

-- 更新屏幕大招镜头（更新位置）
function ModelMoveBasic:updateScreenCameraMax( skill )
	if Fight.isDummy then return end

	local cameraSkilParams = skill:sta_cameraSpineParams()
	if cameraSkilParams then
		cameraSkilParams = cameraSkilParams[1]
		if cameraSkilParams.jingtou ~= "0" then
			local appearType = skill:sta_appear()
			if appearType == Fight.skill_appear_normal or appearType == Fight.skill_appear_ymiddle 
				or appearType == Fight.skill_appear_myFirst or appearType == Fight.skill_appear_myyMiddle 
			then
				local offsetPos = {x=0,y =0}
				local firstHero = skill.firstHeroModel
				if firstHero then
					--计算一下坐标偏差
					local x,y = self.controler.reFreshControler:turnPosition(firstHero.camp,2 ,1 ,self.controler.middlePos )
					local dx = firstHero._initPos.x - x
					local dy = firstHero._initPos.y - y
					offsetPos.x = dx  * (-1)
					offsetPos.y = dy

					--如果是y方向中间  那么offsetY 为0
					if appearType == Fight.skill_appear_ymiddle or appearType == Fight.skill_appear_myyMiddle   then
						offsetPos.y = 0
					end

					self.controler.camera:setOffsetPos(offsetPos)
				end
			end
		end
	end
end


--判断屏幕 和 镜头
function ModelMoveBasic:checkScreenCamera( skill ,xpos,ypos,speed)
	if Fight.isDummy then
		return
	end
	-- 2017.7.21小技能会有镜头（重楼）
	if true then
		return
	end

	local cameraSkilParams = skill:sta_cameraSpineParams()
	--如果配置了镜头参数了 那么不走这里
	if cameraSkilParams then
		return
	end

	if not	self.controler.levelInfo:checkCampCamera(self.camp,self.controler.__currentWave) then
		return
	end

	if not skill.showTotalDamage then
		return
	end

	--
	local appearType = skill:sta_appear()
	if appearType == Fight.skill_appear_toMiddle or appearType == Fight.skill_appear_myMiddle  then
		self:doCenterSkillScreenCamera(skill,xpos,ypos,speed)
	else
		self:doNearSkillScreenCamera(skill ,xpos,ypos,speed )
	end

end

--做近战的技能 屏幕运动
function ModelMoveBasic:doNearSkillScreenCamera( skill ,xpos,ypos,speed )
	--如果技能的appear出现方式是5  就是我方屏幕正中心 
	if true then
		return
	end

	local campArr
	local way = self.way * self.controler._mirrorPos
	local appearType = skill:sta_appear()
	if appearType == Fight.skill_appear_myMiddle then
		campArr = self.campArr
		way = -way
	else
		campArr = self.toArr
	end

	local firstHero = campArr[1]
	local endHero = campArr[#campArr]

	local targetPos = self.controler.middlePos + way * 150   --(firstHero._initPos.x +endHero._initPos.x)/2 -way * 150
	
	self.controler.screen:setFollowType(2,{x= targetPos,y = GameVars.halfResHeight + (ypos -Fight.initYpos_2) * 0.7 } )
	local screenParams = {120,0,120}
	local scale2 = screenParams[3] / 100
	--让镜头也适当缩放一下
	self.controler.camera:setScaleTo({10,scale2},{x=targetPos,y = Fight.initYpos_3 })
end

--做屏幕中心的屏幕运动
function ModelMoveBasic:doCenterSkillScreenCamera(skill ,xpos,ypos ,speed )
	local campArr
	local way = self.way * self.controler._mirrorPos
	local appearType = skill:sta_appear()
	if appearType == Fight.skill_appear_myMiddle then
		campArr = self.campArr
		way = -way
	else
		campArr = self.toArr
	end

	local firstHero = campArr[1]
	local endHero = campArr[#campArr]

	-- local targetPos = self.controler.middlePos + way * 150   
	local targetPos = self.controler.middlePos 

	local screenParams = {120,0,120}

	local scale1 =screenParams[1] / 100

	local scale2 = screenParams[3] / 100

	--延迟的帧数 这里还要加上运动过去的帧数
	local delayFrame = screenParams[2]
	local moveFrame = 0
	local dx = xpos - self.pos.x
	local dy = ypos - self.pos.y
	moveFrame = math.ceil( math.sqrt(dx*dx + dy*dy) / speed )

	




	local onshifanEnd = function (  )
		self.controler.screen:setFollowType(2,{x= targetPos + way * 150  ,y = GameVars.halfResHeight + (ypos -Fight.initYpos_2) * 0.7 } )
		--让镜头也适当缩放一下
		self.controler.camera:setScaleTo({10,scale2},{x=targetPos + way * 150,y = Fight.initYpos_3 })
	end


	if delayFrame == 0 then
		onshifanEnd()
	else
		--先把镜头和人都锁定到屏幕中心去
		self.controler.screen:setFollowType(2,{x= targetPos,y = GameVars.halfResHeight + (ypos -Fight.initYpos_2) * 0.7 } )
		--让镜头也适当缩放一下
		self.controler.camera:setScaleTo({10,scale1},{x=targetPos,y = Fight.initYpos_3 })
		self:pushOneCallFunc(delayFrame +  moveFrame, onshifanEnd)
	end

	

end





function ModelMoveBasic:getWayByPos( x )
	local dx = x - self.pos.x
	if dx > 0  then
		return 1
	elseif dx == 0 then
		if self.camp == 1 then
			return 1
		else
			return -1
		end
	else
		return -1
	end
end
-- 怪物被收集起来=====(六界轶事夺宝怪物用到)
function ModelMoveBasic:toColletMonkey(toIdx,isCollet)
	self.controler.logical:changeMonsterPos(self,toIdx,isCollet)
	self:standAction()
end
-- 六界轶事、刷怪物完成回调
function ModelMoveBasic:onRefreshMoveComplete( )
	self.controler.logical:onMoveComplete()
	self:standAction()
end

function ModelMoveBasic:isMove()
	return self.myState ~= Fight.state_stand
end

return ModelMoveBasic
