--
-- Author: dou
-- Date: 2014-01-13 18:42:57
--
local Fight = Fight
ModelHitBasic = class("ModelHitBasic",ModelMoveBasic)

--能否检测地形	-- 默认为false 

--[[
	self.data属性
	hitBorderAble 		--能否边界检测
	hitLandAble		--能否检测地面
]]

ModelHitBasic.hitBorderAble = false 
ModelHitBasic.hitLandAble =true

ModelHitBasic.groundHeight =0 	--地面高度 默认是0 考虑到有在空中的地形 


--  血条以及偏移
ModelHitBasic.healthBar = nil 		--生命条对象
ModelHitBasic.healthBarPos = nil	--生命条的相对坐标

-- 打击以及冲撞数组
ModelHitBasic.hitObjs = nil 		--打到了哪些人

-- 被打击的信息
ModelHitBasic.beHitedInfo = nil	--记录被打信息
ModelHitBasic.focusHit = false -- 固定打一个人不需要备份

function ModelHitBasic:ctor( ... )
	ModelHitBasic.super.ctor(self,...)
	self.hitObjs = {}
	--默认能够进行地形检测
	self.hitLandAble = true

	self.beHitedInfo = {}
end

function ModelHitBasic:checkHit( ... )
	if not self.hitBorderAble then
		return
	end
	ModelHitBasic.super.checkHit(self,...)
	--检测碰地面
	self:hitLand()
end

--边界检测
function ModelHitBasic:checkBorder( ... )
end

function ModelHitBasic:hitLand(  )
	if not self.hitLandAble then
		return
	end
	--跳跃状态才检测碰地
	if self.myState ~= Fight.state_jump  then
		return
	end
	--如果是向上运动的
	if self.speed.z < 0 then
		return
	end

	--如果碰到地面的高度
	if self.pos.z+self.speed.z >=self.groundHeight then
		--那么修正z坐标为地面高度
		self.pos.z=self.groundHeight
		--做着地操作
		self:fallLand()
	end
end

--着地
function ModelHitBasic:fallLand(  )
	self.speed.z = 0
	self:checkLandStopMove()
end

--判断着地后的状态是否应该停止运动
function ModelHitBasic:checkLandStopMove( ... )
	if self.myState == Fight.state_jump  then
		self:justFrame(Fight.actions.action_stand)
		self:initStand()
	end
end



--重写 realPos
function ModelHitBasic:realPos()
	if not self.myView then
		return
	end

	if self.healthBar  then
		--刷新healthBar显示
		self.healthBar:updateFrame() 
		local x,y = self.myView:getPosition()
		self.healthBar:setPosition( self.healthBarPos.x * self.way + x,self.healthBarPos.y + y)
		-- self.healthBar:setLocalZOrder(self.__zorder)
		if self.talkBubble then
			self.talkBubble:setPosition( self.healthBarPos.x * self.way + x,self.healthBarPos.y + y)
		end
	end
	
	ModelHitBasic.super.realPos(self)
end


--被大了
function ModelHitBasic:beHited(attacker,atkData,skill)
	table.insert(self.beHitedInfo, {attacker,atkData,skill})
end

--在 frame开始前所做的事情
function ModelHitBasic:updateFirst( )
end

--在frame结束后做的事情
function ModelHitBasic:updateLast(  )
	--主要是做一些挨打信息 这些信息在一定是在所有的 updateframe完成以后执行,为了保证顺序 ,由控制器调用
	--如果是非生命体
	if (not self.data.hp )or (not self.data:hp() )  then
		return
	end

	--local isHited = false
	--记录自己被打的信息
	for i,v in ipairs(self.beHitedInfo) do
		self:runBeHitedFunc(v[1], v[2],v[3])
	end
	self.beHitedInfo = {}
end

--执行被打函数
function ModelHitBasic:runBeHitedFunc( attacker,atkData,skill )	
end

--初始化 攻击打到人的信息
function ModelHitBasic:initHitObjs( )
	self.hitObjs = {}
end

--确定攻击到谁了
function ModelHitBasic:sureAttackObj( enemy,atkData,skill )
	--enemy:beHited(self,atkData,skill)	
	--攻击方发送攻击时机 防守方发送防守时机
	

	enemy:runBeHitedFunc(self, atkData, skill)
end

--判断能否攻击某个人
function ModelHitBasic:checkCanAttakEnemy( enemy ,area, canRepeat, rush)

	--如果已经打过这个人了
	if not canrepeat then
		if table.indexof(self.hitObjs, enemy) then
			return false
		end
	end

	--判断是否在攻击范围内
	if not self:checkInAttackArea( area,enemy ) then
		return false
	end
	return true
end

--判断是否在攻击区域内  
--[[
	disArr = { x左,x右,y左，y右边,z下,z上 }  是长度为6的数组 y的差值可以理解为攻击厚度 z的检测区域 默认为30-120 结合人物高度而定
	targetObj  是ObjectModelBasic对象
]]
function ModelHitBasic:checkInAttackArea( disArr,targetObj )
	--获取对方和我的距离
	
	local dx1 = numEncrypt:getNum(disArr[1])
	local dx2 = numEncrypt:getNum(disArr[2])
	if dx1 == -1 and dx2 ==-1 then
		return true
	end
	--先计算自己x方向的攻击区域
	local x11 = self.pos.x + dx1*self.way
	local x12= self.pos.x + dx2*self.way

	--local viewRect = targetObj.data.viewSize or {0,0}

	--local targtHalfW=viewRect[1]/2
	
	--在计算被攻击方 能被打到的区域  再判断2个区域是否有叠加 有叠加就判断打到了
	local x21 = targetObj.pos.x -- -targtHalfW
	local x22 = targetObj.pos.x -- +targtHalfW

	local xHit = ModelHitBasic.checkHitByDatas(x11,x12,x21,x22)

	--目前只检测x轴
	return xHit
end

--判断2条线段是否相交  判断p21或者p22是否在p11 和p12之间 
function ModelHitBasic.checkHitByDatas(p11,p12,p21,p22 )
	local result
	if p21 > p11 and p21 < p12 then
		return true
	elseif p21 < p11 and p21 > p12 then
		return true

	elseif p22 > p11 and p22 < p12 then
		return true
	elseif p22 < p11 and p22 > p12 then
		return true

	elseif p11 > p21  and p11 < p22 then
		return true

	elseif p11 < p21 and p11 > p22 then
		return true
	end
	return false
end
function ModelHitBasic:deleteMe()
	ModelHitBasic.super.deleteMe(self)
	if self.healthBar then
		self.healthBar:deleteMe()
		self.healthBar = nil
	end
end


return ModelHitBasic