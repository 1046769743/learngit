--
-- Author: dou
-- Date: 2014-02-11 17:19:58
--
ModelShade = class("ModelShade", ModelBasic)


ModelShade.target =nil

function ModelShade:ctor( ... )
	
	ModelShade.super.ctor(self,...)
	--影子的深度序号最低
	self.depthType = 0
	self.modelType = Fight.modelType_shade 
end

function ModelShade:setFollowTarget( target ,pianyiX,pianyiY,isAni)
	self.target = target
	self.pianyiPos = {pianyiX and pianyiX or 0,pianyiY and pianyiY or 0}

	--因为影子 的大小根据人而异 默认影子的宽度跟随人的宽度 厚度保持一直
	local size = nil
	if isAni then
		size = self.myView.currentAni:getBoundingBox()
	else
		size = self.myView.imageView:getContentSize()
	end

	size.width = 50
	--初始化计算一个 视图scale\
	local targetScale = self.target.data:viewScale()/100
	local targetViewSize = self.target.data.viewSize[1]
	self.viewScale = math.floor(targetViewSize*targetScale/ size.width)

	self:setWay(self.target.way)

	-- 直接确认位置
	self.pos.x = self.target.pos.x + self.pianyiPos[1] 
	self.pos.y = self.target.pos.y + self.pianyiPos[2] 
	self.pos.z = 0
	
	self:realPos()

	return self
end


function ModelShade:setWay( way )
	if not way then
		return
	end
	self.way = way
	self.myView:scale(way*self.viewScale, 1)
end



function ModelShade:controlEvent( )
	if not self.target then
		return
	end	
	self.pos.x = self.target.pos.x + self.pianyiPos[1] + self.target._footRootPos.x
	self.pos.y = self.target.pos.y + self.pianyiPos[2] + self.target._footRootPos.y

	if self.target.shadePosyOff then
		self.pos.y = self.pos.y  - self.target.shadePosyOff
	end

	
	self.pos.z = 0

	-- if self.way == 1 then
 -- 		echo("___________dddddddddddddddddd",self.target.data.hid,self.target.pos.x,self.pos.x,self.way)
 -- 	end
end

function ModelShade:deleteMe(  )
	ModelShade.super.deleteMe(self)
	self.target = nil
end

return ModelShade