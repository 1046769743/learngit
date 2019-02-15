--
-- Author: dou
-- Date: 2014-02-11 17:19:58
--
ModelPhantom = class("ModelPhantom", ModelBasic)

--残影的model

ModelPhantom.target =nil

function ModelPhantom:ctor( ... )
	
	ModelPhantom.super.ctor(self,...)
	--幻象的深度排列坐标和人一直
	self.depthType = 1
end


--alpha  0-1  默认 0.7 
function ModelPhantom:setTarget( target,ctn, alpha,time)
	self.target = target

	self.myView = display.sp(nil, nil, nil):addto(ctn)
	self.myView:setCascadeOpacityEnabled(true)

	local targetView = target.myView

	local texture = targetView:getSpriteFrame()
	--echo(texture:getDescription(),"-dsadsad")
	--self.myView:setTexture(texture)
	self.myView:setSpriteFrame(texture)

	local anchorPos = targetView:getAnchorPoint()
	self.myView:anchor(anchorPos.x,anchorPos.y)


	self.lastTime = time or self.data.time
	alpha = alpha or self.data.alpha
	self.myView:opacity(alpha *255)
	self:setWay(target.way)
	--计算每帧透明度减少两
	self.initAlpha = alpha
 
	self:setPos(self.target.pos.x,self.target.pos.y,self.target.pos.z)
	return self
end


function ModelPhantom:controlEvent( )
	if not self.target then
		return
	end
	
	--根据时间计算透明度
	local targetAlpha =self.initAlpha -   self.initAlpha/self.lastTime *self.updateCount

	self.myView:opacity(targetAlpha*255)

	if self.updateCount >= self.lastTime then
		self:startDoDiedFunc()
	end

	--self:setPos(self.target.pos.x,self.target.pos.y,0)
end

function ModelPhantom:deleteMe(  )
	ModelPhantom.super.deleteMe(self)
	self.target = nil
end

return ModelPhantom