--
-- Author: dou
-- Date: 2014-02-11 17:19:58
--
ModelPiece = class("ModelPiece", ModelHitBasic)


ModelPiece.target = nil
ModelPiece.effectObj = nil 
ModelPiece.effect = nil
ModelPiece.parcitle = nil


function ModelPiece:ctor( ... )
	self.modelType = Fight.modelType_piece
	ModelPiece.super.ctor(self,...)
	--影子的深度序号最低
	self.depthType = 0
	self.gravitiAble = true -- 地面检测

	self.data = {}
end

function ModelPiece:setTarget( target ,pianyiX,pianyiZ)
	self.player = target
	self.pianyiPos = {pianyiX and pianyiX or 0,pianyiZ and pianyiZ or 0}

	self:setWay(self.player.way)

	return self
end

function ModelPiece:hasArrive()
	if not self.defender then
		return
	end
	if self.defender.data:hp() > 0 and self.defender.selfPause then
		self.defender:playFrame()
	end
	self:deleteMe()
end

function ModelPiece:setMoveToPoint(dstx,dsty,speed,defender)
	self.defender = defender
	speed = speed and speed or 30
	local targetPoint ={
				x=dstx,
				y=dsty,
				--call={self.deleteMe,{self},
				call = {"hasArrive"}
			} 
	self:moveToPoint(targetPoint,speed)
end


-- 设置归属,有的残片需要有归属的
function ModelPiece:setBelongTo(target)
	self.belongto = target
end


--
function ModelPiece:controlEvent( )
	if self.belongto and self.belongto.data:hp() <= 0  then
		self:startDoDiedFunc()
	end
	
	ModelPiece.super.controlEvent(self)

	-- 一半的时候改变y的加速度
	if self.updateCount  == 10 then
		--self.speed ={x=0,y=0,z=0}
		self:setAddSpeed(self.addSpeedX,-self.addSpeedY,0)
		--echo("_____________向上运动到一半")
	end

	-- 运动到抛物线的最上方
	if self.updateCount  == 20 then
		--self:yunsuEnd()
		self:paowuxianEnd()
		--echo("_____________向上抛物线运动到点")
	end

	-- 碰到影响的对象
	if self.effectObj then
		local dis = math.abs(self.pos.x - self.effectObj.pos.x)
		if dis < 40 then
			
			self.speed = {x=0,y=0,z=0}
			self.effectObj[self.effect.call[1]](self.effectObj,self.effect.call[2])
			if self.parcitle then
				self.parcitle:stopSystem()
			end
			self:pushOneCallFunc(15, "startDoDiedFunc",nil)
		end
	end
end


function ModelPiece:setSpecialPos(x,y)
	self.specX = x
	self.specY = y
end

function ModelPiece:saveAddSpeed(addx,addy,sy)
	self.addSpeedX = addx
	self.addSpeedY = addy
	self.sy = sy
end


function ModelPiece:setEffectObj(effectObj,effect)
	self.effectObj = effectObj
	self.effect = effect 
end

function ModelPiece:paowuxianEnd()
	-- X 轴方向
	local sx = self.effectObj.pos.x - self.pos.x
	local vx = self.speed.x
	local ax = (sx-20*vx)*2/400

	-- Y 轴方向
	local sy = self.sy
	local ay = sy*2/400

end

function ModelPiece:yunsuEnd()
	---echo("________________匀速运动结束",self.pos.x,self.pos.y,self.pos.z,self.effectObj.pos.x,self.effectObj.pos.y,self.effectObj.pos.z,self.effectObj.pos.z-self.effectObj.data.viewSize[2]*Fight.hit_position)
	local s = {self.pos.x,self.pos.y,self.pos.z} -- 起点
	local e = {self.effectObj.pos.x,self.effectObj.pos.y,self.effectObj.pos.z-self.effectObj.data.viewSize[2]*Fight.hit_position} -- 终点
	local g = Fight.moveType_g -- 加速度
	local h = -63

	local speed = Equation.getSpeedBySEGH(s,e,g,h)

	local t = (self.effectObj.pos.y - self.pos.y )/speed[2]
	self:initMove(0,speed[2])
	
	--self:initMove(speed[1],speed[2])
	self:initJump(speed[3])
end



function ModelPiece:deleteMe(  )
	ModelPiece.super.deleteMe(self)
	--echo("_______________piece deleteMe")
	self.effectObj = nil
	self.effect = nil
	self.player = nil
end

return ModelPiece