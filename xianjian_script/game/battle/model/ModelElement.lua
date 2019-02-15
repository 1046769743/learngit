--[[
	五行元素实例
	2017.10.18
]]
local Fight = Fight
-- local BattleControler = BattleControler

ModelElement = class("ModelElement", ModelMoveBasic)

ModelElement._initPos = nil

function ModelElement:ctor( controler,element,pos ,dropView)
	ModelElement.super.ctor(self,controler)
	self.modelType = Fight.modelType_effect
	self.dropView = dropView
	self:initElement(element, pos)
end

function ModelElement:initElement(element, pos)
	-- self._initPos = pos
	self:setInitPos(pos)
	self.controler:insertOneObject(self,false)
	if Fight.isDummy then return end
	-- local ani = self:getAniByType(nil, true)
	self:initView(self.controler.layer.a122, self.dropView, pos.x,pos.y,0)
	self:setWay(Fight.myWay)
	self:setViewScale(2)
end
--[[
-- 创建特效类型
function ModelElement:getAniByType( animation ,isCycle)
	local ani = nil
	animation = animation and animation or "UI_zhandou_zhenwei_zhenxunhuan"

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
]]

-- 返回
function ModelElement:moveBack()
	if self._isDied then return end
	local speed = self:countSpeed(self._initPos.x, self._initPos.y, 10, 0)
	self:moveToPoint({
		x = self._initPos.x,
		y = self._initPos.y,
		z = 0,
		call = {"clearElement"},
		speed = speed,
	})
end

-- 销毁
function ModelElement:clearElement()
	-- 可能做一些其他事
	self:deleteMe()
end

-- 是否可移动
function ModelElement:canMove()
	return not self._isDied and self.myState == Fight.state_stand
end

return ModelElement