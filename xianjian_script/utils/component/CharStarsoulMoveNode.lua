--主角星魂旋转模型 椭圆形轨迹
local CharStarsoulMoveNode  = class("CharStarsoulMoveNode",function ()
	return display.newNode()
end)
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
--[[
local configs = {
	
	--椭圆中心 
	EllipseCenter = {x = nil,y = nil}
    --椭圆的长轴
	EllipselengthA = nil,
	--椭圆的短轴
	EllipseshortB = nil,
	--逆转还是顺时针旋转
	DirectionRotation  = 1, ---1是顺时针 -1是逆时针
	--对象个数
	ObjectNumber = nil,
    --对象对应的角度
    angletable = ｛｝,
    --停止转动的回调
    moveEndCallBack = c_func()

}
--]]
local tlength = {}   ---每个对象的角度
local M_PI = 3.141596253    ---π 值



local huadongMaxJuli = 300
local angletable = {
	[1] = 0,
	[2] = 60,
	[3] = 120,
	[4] = 180,
	[5] = 240,
	[6] = 300,
}


--初始化设置
function CharStarsoulMoveNode:ctor(object,config)
	self.localPos = { x= 0 ,y = 0}
	self.maxscale = 1
	self.minsclale = 1

	if object == nil  then
		echo("object is nil")
		return false
	end 
	if config == nil  then
		echo("config is nil")
		return false
	end 


	self.movepoint = {x=nil,y=nil}
	self.firstobjectangle = 270 --第一个对象的角度
	self.EllipselengthA = config.EllipselengthA  
    self.EllipseshortB  = config.EllipseshortB
	self.ObjectNumber = config.ObjectNumber or 6 --默认6个
    self.angletable = config.angletable or angletable -- 对象初始的角度
    self.moveEndCallBack = config.moveEndCallBack

    self.selectObjectIndex = 1

	self.wirte = FuncRes.a_white( 170*4,36*9.5)
	self.wirte:setPosition(cc.p(55,-140))
	self:addChild(self.wirte,10)
	self.wirte:setTouchEnabled(true)
	self.wirte:setTouchSwallowEnabled(false)

	self.wirte:opacity(0)
	self.wirte:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
		local result = self:onTouch_(event)
        return result or false
	end)


	self:createEllipse(object)
	math.randomseed(os.time())
	self:addEventListeners()
end


--初始化椭圆
function CharStarsoulMoveNode:createEllipse(object)
	--椭圆函数 (x*x)/(a*a)+(y*y)/(b*b) = 1
	self:CloneObject(object)
	self:SetbjectPoint()

end

function CharStarsoulMoveNode:CloneObject(object)
	self.newObjectTable = {}
	for i=1,#object do
		local newobject = object[i]
		self.newObjectTable[i] = newobject
	end
end

--添加对象和设置坐标
function CharStarsoulMoveNode:SetbjectPoint()
	---从funcecilpse 中获取点的位置
	local point = self:AccordingAngleSetPoint()
	for i=1,#self.newObjectTable do
		self.newObjectTable[i]:setPosition(cc.p(0,0))
        local moveAnim = act.moveto(0.5,point[i].x,point[i].y)
        self.newObjectTable[i]:runAction(cc.EaseExponentialIn:create(moveAnim))
--        self.newObjectTable[i]:setPosition(cc.p(point[i].x,point[i].y))
		self.newObjectTable[i]:setAnchorPoint(cc.p(0.5,0.5))
		self:addChild(self.newObjectTable[i])
		self.newObjectTable[i]:setScale(self:getobjectScale(i))
		tlength[i] = self.angletable[i]
	end
end
function CharStarsoulMoveNode:getobjectScale(index)
	-- local maxscale = 0.8
	-- local minsclale = 0.4
	local scale = self.maxscale - (self.maxscale-self.minsclale)/2
	local Radian = self:angleToRadian(self.angletable[index]+180)
	local newscale = scale +  0.2 * math.sin(Radian)

	return 1
end

--根据角度设置位置
function CharStarsoulMoveNode:AccordingAngleSetPoint()
		--- y = b*sin() -- x = a * cos()
		local point = {}
		for i=1,#self.angletable do
			point[i] = {}
			local Angle = self.angletable[i]
			point[i].x = self:getEllipsePointX(Angle)
			point[i].y = self:getEllipsePointY(Angle)
		end
		return point
end


function CharStarsoulMoveNode:addEventListeners()

end


function CharStarsoulMoveNode:moveScales(angle)
	local scale = self.maxscale - (self.maxscale-self.minsclale)/2
	local Radian = self:angleToRadian(angle+180)
	local newscale = scale +  0.2 * math.sin(Radian)
	return 1
end


--获取椭圆的X点
function CharStarsoulMoveNode:getEllipsePointX(angle)
	local newangle = self:angleToRadian(angle)
	local x = self.EllipselengthA * math.cos(newangle)
	return  x
end

--获取椭圆的Y点
function CharStarsoulMoveNode:getEllipsePointY(angle)
	-- return self.EllipseshortB*math.sin(self:angleToRadian(angle))
	local newangle = self:angleToRadian(angle)
	local y = self.EllipseshortB* math.sin(newangle)

	return  y
end


function CharStarsoulMoveNode:onTouch_( event )

	if event.name == "began" then
        self.beganTouchAngle = self.firstobjectangle
        self.beganPoint = {x = event.x,y = event.y}
        return true
	elseif event.name == "moved" then
		self.movepoint.x = event.x - self.beganPoint.x
        self.movepoint.y = event.y - self.beganPoint.y
        self.beganPoint = {x = event.x,y = event.y}
        self:moveScroll(self.movepoint.x/4.0)

	elseif  event.name == "ended" then
        self.endTouchAngle = self.firstobjectangle
        local movedAngle = self.endTouchAngle - self.beganTouchAngle
        local index = self:getSelectedObjectIndex(movedAngle)
        self:easeMoveToIndex()

        self.moveEndCallBack(index)
	end
end

function CharStarsoulMoveNode:moveScroll(length)
	
	--长度转换成角度 偏移角度
	local angle = self:getAngleFromOffset(length)
	-- -- --传入角度
	self:RotatePosition(length)
end

--获得偏移角
function CharStarsoulMoveNode:getAngleFromOffset(offset)
	if (offset ~= 0)  then
		return self:radianToAngle(math.atan(offset/self.EllipseshortB*0.1)) --//偏移角  
    else 
    	return 0; 
    end
end

--移动旋转位置
function CharStarsoulMoveNode:RotatePosition(angle)
	self.firstobjectangle = self.firstobjectangle  + angle
	for i=1,#self.newObjectTable do
		local x = self:getEllipsePointX((360/self.ObjectNumber) * (i-1) + self.firstobjectangle ) 
		local y = self:getEllipsePointY((360/self.ObjectNumber) * (i-1) + self.firstobjectangle )
		self.newObjectTable[i]:setPosition(cc.p(x  ,y ))
		self.newObjectTable[i]:setScale(self:moveScales((360/self.ObjectNumber) * (i-1) + self.firstobjectangle))

		local x = self.newObjectTable[i]:getPositionX()
		local y = self.newObjectTable[i]:getPositionY()
		if y < 0 then
			self.newObjectTable[i]:setLocalZOrder(20)--setLocalZOrder
		else
			self.newObjectTable[i]:setLocalZOrder(-10)
		end
	end
end

--移动到第几个
function CharStarsoulMoveNode:moveToIndex(index)
    if index > 0 then
        local _angle = 360/self.ObjectNumber
        self:RotatePosition(-_angle*(index-1))
        self.moveEndCallBack(index)
        self.selectObjectIndex = index
    end
end
--缓动移动到第几个 
function CharStarsoulMoveNode:easeMoveToIndex(_addIndex)
    if _addIndex == 0 then
        return 
    end
    self.wirte:setTouchEnabled(false)

    --每帧移动的角度
    local angleFrame = 8
    if _addIndex then
        local _angle = 360/self.ObjectNumber
        self.selectAngle = self.firstobjectangle - _angle*_addIndex
        self.endTouchAngle = self.firstobjectangle
        echo("self.selectObjectIndex 111 = "..self.selectObjectIndex)
        if _addIndex > 0  then
            self.selectObjectIndex = self.selectObjectIndex + _addIndex
            if self.selectObjectIndex > self.ObjectNumber then
                self.selectObjectIndex = self.selectObjectIndex - self.ObjectNumber
            end 
        elseif index < 0  then
            self.selectObjectIndex =  self.selectObjectIndex - _addIndex
            if self.selectObjectIndex == 0 then
                self.selectObjectIndex = self.ObjectNumber
            end
        end
        echo("PPPPPPPPPPPPPPPPPPP == "..self.selectObjectIndex)
        self.moveEndCallBack(self.selectObjectIndex)
    end
    
    
    local rpFunc1 = function ()
        if angleFrame >= math.abs(self.firstobjectangle - self.selectAngle) then
            self:RotatePosition(self.selectAngle - self.firstobjectangle )
            self:unscheduleUpdate()
            self.firstobjectangle = self.selectAngle
            self.wirte:setTouchEnabled(true)
        elseif self.selectAngle < self.firstobjectangle then
            self:RotatePosition(-angleFrame)
        end
    end
    local rpFunc2 = function ()
        if angleFrame >= math.abs(self.firstobjectangle - self.selectAngle) then
            self:RotatePosition(self.selectAngle - self.firstobjectangle)
            self.firstobjectangle = self.selectAngle
            self:unscheduleUpdate()
            self.wirte:setTouchEnabled(true)
        elseif self.selectAngle > self.firstobjectangle then
            self:RotatePosition(angleFrame)
        end
    end
    if (self.selectAngle - self.endTouchAngle) > 0 then
        self:scheduleUpdateWithPriorityLua(rpFunc2,0);
    else
        self:scheduleUpdateWithPriorityLua(rpFunc1,0);
    end
end
--刷新object显示状态
function CharStarsoulMoveNode:refreshObjectShowState(index,frame)
    return self.newObjectTable[index]:showFrame(frame)
end

--获取选中的index
function CharStarsoulMoveNode:getSelectedObjectIndex(movedAngle)
    local index = 0
    local _index = 0
    local _angle = 360/self.ObjectNumber
    if movedAngle > 0 then
        if movedAngle > 30 then
            index = index + 1
        end
    else
        if movedAngle < -30 then
            index = index - 1
        end
    end
    self.selectAngle = self.beganTouchAngle + _angle*index
    if index > 0  then
        self.selectObjectIndex =  self.selectObjectIndex - index
        if self.selectObjectIndex == 0 then
            self.selectObjectIndex = self.ObjectNumber
        end
    elseif index < 0  then
        self.selectObjectIndex = self.selectObjectIndex + 1
        if self.selectObjectIndex > self.ObjectNumber then
            self.selectObjectIndex = 1
        end 
    end
    echo("选中的index == "..self.selectObjectIndex)
    return self.selectObjectIndex

end
-- 弧度转换到角度  
function CharStarsoulMoveNode:radianToAngle(radian) 
	return radian * 180 / M_PI; 
end
-- 角度转换到弧度
function CharStarsoulMoveNode:angleToRadian(angle)
	return angle * M_PI / 180;
end
return CharStarsoulMoveNode