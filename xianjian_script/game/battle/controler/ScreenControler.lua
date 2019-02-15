--
-- Author: Your Name
-- Date: 2014-01-13 14:32:08
--

--人物视野版边
local BattleCameraPlayerDistanceLeft = 380 --180  380
local BattleCameraPlayerDistanceRight = 560 --366 560
local BattleCameraScreenDistance = 56
local BattleCameraMinDis =  800


ScreenControler = class("ScreenControler")

--abcd分辨对应 4个点  左下角坐标和右上角坐标
ScreenControler.a =0
ScreenControler.b =0
ScreenControler.c =0
ScreenControler.d =0

local easeNum = 0.1	--缓动系数-- 屏幕锁定应该是缓动过去 而不是瞬间移动过去

ScreenControler.halfWidth =0
ScreenControler.halfHeight =0

ScreenControler.focusPos= nil
ScreenControler.lastFocusPos = nil
ScreenControler.realPos = nil
	
ScreenControler.followType =nil
ScreenControler.followTarget = nil
ScreenControler.moveCtn =nil

ScreenControler.movePostion = nil

ScreenControler.whetherMove = true

ScreenControler._keepDistance = nil

--设置屏幕运动类型
ScreenControler.moveType = 0 		--运动类型

ScreenControler.followPos = nil 		--跟随的主角坐标pos

ScreenControler.leftborder = 0 			--左边版边
ScreenControler.rightborder= 0 			--右边版边  会根据当前场中的敌人数量动态判断 每1秒更新一下版边
ScreenControler._canMove = true 		--是否能运动 默认是能的

function ScreenControler:ctor(controler,ctn)
	self.controler = controler
	self.movePointsInfo = {}
	self.moveCtn = ctn
	self._keepDistance = 0
	
	-- self.halfWidth = GameVars.gameResWidth/2 --GameVars.width/2
	self.halfWidth = GameVars.width/2
	self.halfHeight = GameVars.halfResHeight  
	self.focusPos = cc.p(GameVars.gameResWidth/2,self.halfHeight)
	self.realPos = cc.p(0,0)
	self.lastFocusPos = cc.p(GameVars.gameResWidth/2,self.halfHeight)

	self:moveView()
end



--设置跟随类型 目前就2种  一种是 跟随我方最前面的那一个人 另外一种是移动到点
function ScreenControler:setFollowType( value,params )
	self.followType = value
	self.lastFocusPos.x = self.focusPos.x
	self.lastFocusPos.y = self.focusPos.y


	-- 如果是跟随某个人  
	if self.followType ==1 then

	elseif self.followType == 2 then
		self:moveToPoint(params)

	--如果是跟随主角的
	elseif self.followType == 3 then

	end
end

--改变初始坐标
function ScreenControler:setFocus( x,y )
	self.focusPos.x = x
	self.focusPos.y = y
	self.whetherMove = true
	self:moveView()
end

--因为容器的坐标远点在左上角  所以所有坐标都要反向
function ScreenControler:limitFocusRange( ... )
end

function ScreenControler:moveFocus( ... )
	-- body
	if self.movePostion then
		self:checkMoveType()
		return
	end
end

function ScreenControler:moveView( )
	-- if true then
	-- 	return
	-- end

	if self.whetherMove  then
		self.realPos.x =  self.halfWidth-self.focusPos.x  * Fight.screenScaleX
		self.realPos.y=  -( self.halfHeight-self.focusPos.y) 
		-- echo(self.halfWidth,"___self.halfWidth",self.focusPos.x,self.realPos.x)
		self.moveCtn:setPosition(self.realPos.x + self.controler.layer.ctnOffsetX,self.realPos.y)

		if not Fight.isDummy then
			if self.controler.map then
				self.controler.map:updatePos(self.realPos.x,self.realPos.y)
			end
		end
	end
end

function ScreenControler:setPos(x,y)
	self.moveCtn:setPosition(self.realPos)
end

--刷新函数
function ScreenControler:updateFrame(  )
	if not self.followType then
		return
	end


	if  self._canMove then
		if not  self:doFollowFunc() then
			return
		end
	end

	-- if self.focusPos.x < GameVars.halfResWidth  then
	-- 	--echo("================================",self.focusPos.x,targetPos)
	-- 	self.focusPos.x = GameVars.halfResWidth
	-- end

	self:moveView()

end

--执行跟随函数
function ScreenControler:doFollowFunc(  )

	if self.followType == 1 then

		--找人群的中点
		local model1 = self.controler.campArr_1[1]
		if not model1 then
			return false
		end

		local targetPos = model1.pos.x 

		targetPos = model1.pos.x + self._keepDistance

		local dx = targetPos - self.focusPos.x
		local minDis = 2
		if math.abs(dx) < minDis then
			--目前让焦点缓动跟随
			self.focusPos.x = targetPos 
		else
			dx = dx * easeNum
			if dx ~= 0 then
				local absDx = math.abs(dx)
				if absDx < minDis then
					dx = minDis * absDx/dx
				end
			else
				--todo
			end
			self.focusPos.x= self.focusPos.x +  dx
		end


		
	elseif self.followType ==2 then
		if self.moveType ==0 then
			return false
		end
		--如果是运动到点
		self:checkMoveType()

	elseif self.followType ==3 then
	end

	return true
end




function ScreenControler:moveToPoint( targetPoint, speed,moveType )

	self.movePostion = targetPoint
	self.moveType = 1
end

-- 判断运动类型
function ScreenControler:checkMoveType( ... )
	-- body
	if self.moveType ==0  then
		return
	end

	local dx = self.movePostion.x - self.focusPos.x
	local dy = self.movePostion.y - self.focusPos.y
	local dis = math.sqrt(dx*dx+dy*dy)

	local f = self.movePostion.f or 0.1

	local minSpeed = self.movePostion.minSpeed or 5
	if dis < minSpeed then
		self.focusPos.x = self.movePostion.x
		self.focusPos.y = self.movePostion.y
		self:doMoveEndFunc()
	else
		local speed = dis * f
		if speed < minSpeed then
			speed = minSpeed
		end
		local ang = math.atan2(dy, dx) 
		local vx =  math.cos(ang) * speed
		local vy =  math.sin(ang) * speed

		self.focusPos.x = self.focusPos.x + vx
		self.focusPos.y = self.focusPos.y + vy
	end

end

--做运动到点后的逻辑
function ScreenControler:doMoveEndFunc(  )
	local posInfo =nil
	posInfo = self.movePostion
	self.focusPos.x = posInfo.x
	self.focusPos.y = posInfo.y

	self:initMoveType()

end

--初始化运动类型
function ScreenControler:initMoveType( ... )
	-- body
	self.moveType =0
	self.movePostion=nil
end

function ScreenControler:deleteMe( ... )
	self.followTarget = nil
	self.moveCtn = nil
end

function ScreenControler:lockScreen(  )
	self._canMove =false
end

function ScreenControler:unLockScreen( )
	self._canMove = true
end


return ScreenControler
--
