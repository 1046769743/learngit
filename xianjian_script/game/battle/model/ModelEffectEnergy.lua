

--


ModelEffectEnergy = class("ModelEffectEnergy", ModelBasic)


ModelEffectEnergy.target = nil
ModelEffectEnergy._k = nil -- 斜率
ModelEffectEnergy._n = nil -- x的平方
ModelEffectEnergy.speed = nil

ModelEffectEnergy.motionStreak = nil

function ModelEffectEnergy:ctor( ... )
	ModelEffectEnergy.super.ctor(self,...)
	self.depthType = 9
	self.data = {}
	self.modelType = Fight.modelType_effect
	self.frameEvent = {}

	self.speed = {x=0,y=0,z=0}
end

--[[
设置 出发点 和目标对象
@params:targetHero 攻击hero
@fromPos:起始位置
]]
function ModelEffectEnergy:setTarget( targetHero,fromPos)
	self.hero = targetHero
	self.fromPos = fromPos
	self.controler = self.hero.controler
	self.myView = display.newNode():addto(self.controler.layer:getGameCtn(3)):pos(0,0)
end

--[[
创建第一段动画
]]
function ModelEffectEnergy:createFirstAni(  )
	local callBack
	callBack = function (  )
		if self.firstAni then
			self.firstAni:clear()
			self.firstAni = nil
		end		
	end

	-- 		if self.controler._mirrorPos == -1 then
-- 			xpos = GameVars.gameResWidth - xpos
-- 		end
-- 		self.motionStreak:pos(xpos * Fight.screenScaleX,-ypos)
-- 	end


	--echo("创建前段动画----1111111111111111111111")
	--local cnt = self.controler.layer:getGameCtn(3)
	self.firstAni = FuncArmature.createArmature("UI_jishajiangli_siwang",self.myView,false,GameVars.emptyFunc)
	self.firstAni:pos(self.fromPos.x * Fight.screenScaleX,-self.fromPos.y)
	self.firstAni:registerFrameEventCallFunc(46,false,callBack)
	--self:updateViewPlaySpeed()
end


--[[
创建第二段动画
]]
function ModelEffectEnergy:createSecondAni(  )
	local callBack
	callBack = function (  )
		if self.secondAni then
			self.secondAni:clear()
			self.secondAni = nil
		end
	end

	local posx,posy = self.hero.pos.x,self.hero.pos.y-self.hero.data.viewSize[2]/2
	self.scaleXFlag = math.abs( (posx-self.fromPos.x)/300 )
	local name = "UI_jishajiangli_guiji1" --self:getSecondAniName()
	self.nameTag = "1"
	-- if math.abs(posx-self.fromPos.x)<300 then
	-- 	-- name = "UI_jishajiangli_guiji2"
	-- 	self.scaleXFlag = math.abs( (posx-self.fromPos.x)/250 )
	-- 	self.nameTag = 2
	-- end

	 
	local flag = self.hero.camp == 1 and 1 or -1
	self.secondAni = FuncArmature.createArmature(name,self.myView,false,GameVars.emptyFunc)
	self.secondAni:pos(posx * Fight.screenScaleX,-posy)
	self.secondAni:registerFrameEventCallFunc(26,false,callBack)
	self.secondAni:setScaleX(self.scaleXFlag *self.controler._mirrorPos* Fight.wholeScale*flag)
	--self:setUpdateScale()
end

--[[
创建第三段动画
]]
function ModelEffectEnergy:createThirdAni(  )
	local callBack
	callBack = function (  )
		if self.thirdAni then
			self.thirdAni:clear()
			self.thirdAni= nil
		end
		self:deleteMe()
	end
	--echo("创建第三段动画------33333333333333333333333333333333333")
	local posx,posy = self.hero.pos.x,self.hero.pos.y --self.hero.data.viewSize[2]/2
	self.thirdAni = FuncArmature.createArmature("UI_jishajiangli_xishou",self.myView,false,GameVars.emptyFunc)
	self.thirdAni:pos(posx * Fight.screenScaleX,-posy)
	self.thirdAni:registerFrameEventCallFunc(28,false,callBack)
end


--[[
获取第二段播放的名字
]]
function ModelEffectEnergy:getSecondAniName(  )
	
end




--[[
按照比例进行加速刷新
在10帧 播放第二段
在20真 播放第三段
]]
function ModelEffectEnergy:runBySpeedUpdate(  )
	--echo("runBySpeedUpdate-----------------------ModelEffecteNERGY")
	if self.updateCount == 0 then
		self:createFirstAni()
	elseif self.updateCount == 10 then
		self:createSecondAni()
	elseif self.updateCount == 31 then
		self:createThirdAni()
	end
	self.updateCount = self.updateCount + 1
	self:realPos()
end


--[[
改变播放速度
]]
function ModelEffectEnergy:setUpdateScale( scale,lastTime )

	local posx,posy = self.hero.pos.x,self.hero.pos.y-self.hero.data.viewSize[2]/2
	local baseWith = 300
	self.scaleXFlag = math.abs( (posx-self.fromPos.x)/300 )
	if self.nameTag == 2 then
		baseWith = 250
	end
	self.scaleXFlag = math.abs( (posx-self.fromPos.x)/baseWith)
	local flag = self.hero.camp == 1 and 1 or -1
	-- body
	--local scale = self.hero.camp ==1 and 1 or -1
	--scale = scale * self.scaleXFlag
	--echo("scale--------",scale,"=================")
	--self.controler._mirrorPos*way*self.viewScale * Fight.wholeScale
	if self.secondAni then
		self.secondAni:setScaleX(self.scaleXFlag *self.controler._mirrorPos* Fight.wholeScale*flag)
	end
	--self:updateViewPlaySpeed()
end

--[[
更新动画的播放速度
]]
-- function ModelEffectEnergy:updateViewPlaySpeed(  )
-- 	-- if self.firstAni and self.firstAni.setPlaySpeed then
-- 	-- 	self.firstAni:setPlaySpeed(self.updateScale*self.controler.updateScale)
-- 	-- end
-- 	-- if self.secondAni and self.secondAni.setPlaySpeed then
-- 	-- 	self.secondAni:setPlaySpeed(self.updateScale*self.controler.updateScale)
-- 	-- end
-- 	-- if self.thirdAni and self.thirdAni.setPlaySpeed then
-- 	-- 	self.thirdAni:setPlaySpeed(self.updateScale*self.controler.updateScale)
-- 	-- end
-- end

--[[
更新位置
]]
function ModelEffectEnergy:realPos(  )
	local posx,posy = self.hero.pos.x,self.hero.pos.y
	if self.secondAni then
		self.secondAni:pos(posx * Fight.screenScaleX,-posy+self.hero.data.viewSize[2]/2)
	end
	if self.thirdAni then
		self.thirdAni:pos(posx * Fight.screenScaleX,-posy)
	end	
end



--[[
这个应该不用传参数
]]
function ModelEffectEnergy:setWay( way )
	
end


--[[
播放完成删除
]]
function ModelEffectEnergy:deleteMe(  )
	if self.firstAni then
		self.firstAni:clear()
		self.firstAni = nil
	end
	if self.secondAni then
		self.secondAni:clear()
		self.secondAni = nil
	end
	if self.thirdAni then
		self.thirdAni:clear()
		self.thirdAni = nil
	end
	if self.myView then
		self.myView:clear()
		self.myView = nil
	end
	if self.controler then
		self.controler:clearOneObject(self)
	end
	self.fromPos = nil
	self.controler = nil
	self.targetHero = nil
end



-- 
-- function ModelEffectEnergy:createAni( armature,label,fromPos)
-- 	local sp = ViewSpine.new("eff_treasure0",nil,nil,"eff_treasure0")
--     sp:playLabel("eff_treasure0_hun")
--     sp:zorder(1)
--     return sp
-- end

-- function ModelEffectEnergy:createMotionStreakAni( image )
-- 	local path = FuncRes.iconOther( "other_icon_ChaPoint.png" )
-- 	local wid = 8
-- 	local time = 30/GameVars.GAMEFRAMERATE
-- 	local color = cc.c3b(247,40,19)
--     self.motionStreak = cc.MotionStreak:create(time,wid,wid,color,path)
--     self.motionStreak:addto(self.viewCtn)

--     --echo("-----------创建拖尾特效")
-- end

-- 参数 target目标, fromPos 其实点, toPos终止点, time次数
-- function ModelEffectEnergy:setTarget(target,fromPos,time)
-- 	self.target = target
-- 	local dx = math.abs(self.target.pos.x - fromPos.x)
-- 	local dy =  self.target.pos.y - self.target.data.viewSize[2]/2  - fromPos.y 
-- 	--local rand = BattleRandomControl.getOneRandomInt(5,1)/2
-- 	local yushu = time%3
-- 	if yushu == 0 then
-- 		self._n = 1.5
-- 	elseif yushu == 1 then
-- 		self._n = 1
-- 	elseif yushu == 2 then
-- 		self._n = 0.5
-- 	end

-- 	self.existFrame = 15
-- 	if dx ~= 0 then
-- 		self._k = dy/math.pow(dx,self._n)
-- 		self.speed.x = (self.target.pos.x - fromPos.x)/self.existFrame
-- 		-- 如果为零就想让他慢慢飞过去
-- 		if self.speed.x == 0 then
-- 			self.speed.x = self.target.speed.x*self.target.way
-- 		end
-- 	else
-- 		self._k = 0
-- 		self.speed.y = (self.target.pos.y - self.target.data.viewSize[2]/2 - fromPos.y)/self.existFrame
-- 		--echo("________________血玉 dx=====0",self.speed.x,self.speed.y)
-- 	end

-- 	--echo("______________斜率",dx,dy,self._n,self._k,self.speed.x)
-- end

-- function ModelEffectEnergy:bloodJadeEffPos()
-- 	self.pos.x = self.pos.x + self.speed.x

-- 	local dx =  math.abs(self.target.pos.x - self.pos.x)
-- 	if dx ~= 0 then
-- 		self.pos.y = self.target.pos.y - self.target.data.viewSize[2]/2  - self._k*math.pow(dx,self._n)
-- 	else
-- 		self.pos.y = self.pos.y - self.target.data.viewSize[2]/2 + self.speed.y
-- 	end

-- 	--echo("______________刷新特效",self.pos.x,self.pos.y,self.pos.z)
-- 	if self.motionStreak then
-- 		local xpos = self.pos.x
-- 		local ypos = self.pos.y + self.pos.z
-- 		if self.controler._mirrorPos == -1 then
-- 			xpos = GameVars.gameResWidth - xpos
-- 		end
-- 		self.motionStreak:pos(xpos * Fight.screenScaleX,-ypos)
-- 	end
-- end


-- function ModelEffectEnergy:realPos()
-- 	if self.target.data:hp() <=0 then
-- 		if self.motionStreak then
-- 			self.motionStreak:clear()
-- 		end
-- 		self:deleteMe()
-- 		return
-- 	end


-- 	self.pos.x = self.pos.x + self.speed.x

-- 	local dx =  math.abs(self.target.pos.x - self.pos.x)
-- 	if dx ~= 0 then
-- 		self.pos.y = self.target.pos.y - self.target.data.viewSize[2]/2  - self._k*math.pow(dx,self._n)
-- 	else
-- 		self.pos.y = self.pos.y - self.target.data.viewSize[2]/2 + self.speed.y
-- 	end

-- 	--echo("______________刷新特效",self.pos.x,self.pos.y,self.pos.z)
-- 	if self.motionStreak then
-- 		local xpos = self.pos.x
-- 		local ypos = self.pos.y + self.pos.z
-- 		if self.controler._mirrorPos == -1 then
-- 			xpos = GameVars.gameResWidth - xpos
-- 		end
-- 		self.motionStreak:pos(xpos * Fight.screenScaleX,-ypos)
-- 	end
	
-- 	ModelEffectEnergy.super.realPos(self)

-- 	if dx < math.abs(self.speed.x)   then

-- 		--self.controler:addEnergyToAllOnePlayers(self.target)

-- 		if self.motionStreak then
-- 			self.motionStreak:clear()
-- 		end
-- 		self:deleteMe()
-- 	end
-- end



return ModelEffectEnergy