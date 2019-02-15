--[[
	子弹实例
	2017.7.15
]]
local Fight = Fight

ModelBullet = class("ModelBullet", ModelMoveBasic)

function ModelBullet:ctor( ... )
	ModelBullet.super.ctor(self, ...)
	self.modelType = Fight.modelType_effect
	self.targetPos = nil -- 移动参数
	self.lastPos = {x=0,y=0,z=0} -- 记录上一个位置
end

--[[
	@@bulletParams = {
		eff -- 子弹特效
		mType -- 子弹类型
		moveFrame -- 运动帧数
		height -- 运动高点（0为直线）
		fixFromPos -- 修正出手位置
		fixToPos -- 修正受击位置
		attacker -- 攻击者
		defender -- 受击者
	}

	z 负数为向上
]]
function ModelBullet:initBullet( bulletParams )
	local ani = self:getAniByType(bulletParams.eff, true)

	local attacker = bulletParams.attacker
	local defender = bulletParams.defender

	local fromPos = attacker.pos
	local toPos = defender._initPos
	local fixFromPos = bulletParams.fixFromPos
	local fixToPos = bulletParams.fixToPos

	-- 修正位置
	local fromX = fromPos.x + (-attacker.way * fixFromPos.w)
	local fromY = fromPos.y + 1 -- +1为了深度排序用
	local fromZ = fromPos.z - fixFromPos.h
	fromPos = {x = fromX, y = fromY, z = fromZ}

	local toX = toPos.x
	local toY = toPos.y + 1
	local toZ = toPos.z - defender.data.viewSize[2] * fixToPos.h / 100
	toPos = {x = toX, y = toY, z = toZ}

	-- 如果是反向子弹交换一下起点和终点
	if bulletParams.mType == Fight.bulletType_backward then
		fromPos,toPos = toPos,fromPos
	end

	self:initView(self.controler.layer:getGameCtn(2), ani, fromPos.x, fromPos.y, fromPos.z)

	self:setWay(attacker.way)

	local speed = self:countSpeed(toPos.x, toPos.y, bulletParams.moveFrame, 0)
	local height = bulletParams.height or 0

	local vz = nil
	local g = 0

	-- 算一个竖直速度，这个速度在抛物线运动时会被覆盖
	local dz = toPos.z - fromPos.z
	vz = dz / bulletParams.moveFrame

	if height ~= 0 then
		local h = math.max(fromPos.z, toPos.z) + height
		vz,g = Equation.countSpeedZBySEH(fromPos.x,fromPos.z,toPos.x,toPos.z,speed,h )
	end

	self.targetPos = {
		x = toPos.x,
		y = toPos.y,
		z = toPos.z,
		-- frame = bulletParams.moveFrame,
		call = {"clearBullet"},
		vz = vz,
		g = g,
		speed = speed,
	}
end

-- 子弹运动
function ModelBullet:startMove()
	-- dump(self.targetPos, "self.targetPos")
	self.controler:insertOneObject(self,false)
	self:moveToPoint(self.targetPos)
end

-- 销毁子弹
function ModelBullet:clearBullet( ... )
	-- 可能做一些其他事
	-- self.controler:clearOneObject(self)
	self:deleteMe()

	-- self:startDoDiedFunc()
end

-- 创建特效类型
function ModelBullet:getAniByType( animation ,isCycle)
	local ani = nil
	animation = animation and animation or "effect_1_behit"

	-- 可能是spine动画
	local spineName = FuncArmature.getSpineName(animation)
	if spineName then
		if not isCycle then
			isCyle =false
		end
		ani = ViewSpine.new(spineName,nil,nil,spineName,true)
		ani:playLabel(animation,isCycle)
		--一定是从第一帧开始播放
		ani:gotoAndPlay(1)
	else
		ani = ViewArmature.new(animation)
	end
	self.animation = animation

	return ani
end

-- 重写方法
function ModelBullet:moveXYZPos()
	self.lastPos.x = self.pos.x
	self.lastPos.y = self.pos.y
	self.lastPos.z = self.pos.z

	ModelBullet.super.moveXYZPos(self)

	self:updateRotation()
end

--[[
	更新角度
]]
function ModelBullet:updateRotation()
	local disY = (self.lastPos.y + self.lastPos.z) - (self.targetPos.y + self.targetPos.z)
	local disX = self.lastPos.x - self.targetPos.x
	local rotation = math.deg(math.atan(disY/disX))

	if self.myView then
		self.myView:setRotation(rotation)
	end
end

function ModelBullet:setWay( way )
	self.way = way
	self:countScale()
end

return ModelBullet