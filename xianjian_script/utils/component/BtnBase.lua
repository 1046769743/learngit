
local BtnBase = class("BtnBase", function()
	--设置contentSize0,0 可以修复缩放的bug
    return display.newNode()
end)

BtnBase.TAP_THRESHOLD = 30 -- 超过该数值不响应tap
BtnBase.TOUCH_PRIORITY = 0 --touch优先级(兼容CCMenu改成-128，兼容CCControl改成1)
BtnBase.centerPos = nil
--[[
-- Usage: 按钮基类
-- 内部变量说明：
	self.__stat = nil -- 过程中的所有临时数值存在这里
	self._root = nil -- 根节点(唯一子节点)
	self.__rect = nil -- 用于判定点击范围的rect
	-- 外部设置的回调函数
	self.__tapFunc = nil
]]
function BtnBase:ctor()
    
    -- self:addTouchEventListener(touchFunc  )
    self.__enabled = true -- 是否有效(默认有效)
    self.__canClick = true  

    -- self:setTouchEnabled(true)
end

function BtnBase:getContainerBox()
    return self:_rect()
end


-- -- public functions
--enabledInWorldRect: 当btn点击点处于rect范围内才有效(用于屏蔽滚动条滚动到隐藏范围时)
function BtnBase:setTap(handler,enabledInWorldRect)
    if enabledInWorldRect then
        self:setRect(enabledInWorldRect)
    end
    self.__tapFunc = handler
    if handler ~= GameVars.emptyFunc then
        self._clickNode:setTouchedFunc(self.__tapFunc, self:_rect(), true, c_func(self.__onTouchBegan,self), 
            c_func(self.__onTouchMoved,self), true, c_func(self.__onTouchEnded,self) )
    else
        self._clickNode:setTouchedFunc(self.__tapFunc, self:_rect(), false, c_func(self.__onTouchBegan,self), 
            c_func(self.__onTouchMoved,self), false, c_func(self.__onTouchEnded,self) )
    end
    return self
end



function BtnBase:setBegan(handler)
	self.__beganFunc = handler
	return self
end
function BtnBase:setMoved(handler)
	self.__movedFunc = handler
	return self
end
function BtnBase:setEnded(handler)
	self.__endedFunc = handler
	return self
end
function BtnBase:setCancelled(handler)
	self.__cancelledFunc = handler
	return self
end
--设置tap时的音效函数
function BtnBase:setTapSound(handler)
	self.__tapSoundFunc = handler
	return self
end

--设置按钮是否可点
function BtnBase:enabled(v)
    if(v==nil) then return self.__enabled end -- enabled()
    if(v==true or v==1) then v = true
    else v = false end
    self.__enabled = v
    self._clickNode:setTouchEnabled(v)
    return self
end




--自定义响应区域
function BtnBase:setRect(rect)
	self._myRect = rect

    local clickNode = self._clickNode
    clickNode.x = rect.x
    clickNode.y = -rect.y
    clickNode:setContentSize(cc.size(rect.width,rect.height))
    clickNode:anchor(-rect.x/rect.width,-rect.y/rect.height)

    self:setCenterPos(cc.p(rect.x+rect.width/2,rect.y + rect.height /2) )
end

--设置按钮中心点
function BtnBase:setCenterPos( pos )
    self.centerPos = pos
end

--自定义不响应的区域
function BtnBase:setUnRect(_rect)
	if not self._myUnRects then
		self._myUnRects = {}
	end
	table.insert(self._myUnRects,_rect)
end
-- -- protect functions
function BtnBase:_setRoot(node)
    self._root = node
    self:addChild(self._root)
    return self
end
-- protect override functions 子类覆盖以下方法实现不同按钮效果
function BtnBase:_onBegan() 
    if self.__beganFunc then   self.__beganFunc()    end
end
function BtnBase:_onMoved() 
    if self.__movedFunc then   self.__movedFunc()    end
end
function BtnBase:_onCancelled() end
function BtnBase:_onEnded(x, y)
    if(self.__endedFunc) then self.__endedFunc(x,y) end --外部事件
end



-- 根节点_root是空node的时候需要覆盖该方法(有可能_root的sprite子节点anchor不是(0,0)点)
function BtnBase:_rect() 
    if self._myRect then return self._myRect end
    self._myRect = self:getContainerBox()
    return self._myRect
end



function BtnBase:__onTouchBegan(event)

    self.__stat = {
        startX = event.x,
        startY = event.y,
        isTap = true,
    }
    self:_onBegan(event.x,event.y) -- 子类继承方法
    if(self.__beganFunc) then self.__beganFunc(event.x,event.y) end --外部事件
    return true
end
function BtnBase:__onTouchMoved(event)
    local x,y = event.x,event.y
	if not self.__stat then return end
    -- 判断tap
    if (self.__stat.isTap) then
        self.__stat.isTap = false
        self:_onCancelled() -- 子类继承方法
        if(self.__cancelledFunc) then self.__cancelledFunc() end --外部事件
    end
    self:_onMoved(x,y) -- 子类继承方法
    if(self.__movedFunc) then self.__movedFunc(x,y) end --外部事件
end
function BtnBase:__onTouchEnded(event)
    self:_onEnded(event.x, event.y) -- 子类继承方法
end


function BtnBase:setClickPriority( value )
    self._clickPriority = value
    if self._clickNode then
        self._clickNode:setClickPriority(value)
    end
end


--矩形工具
rectEx= rectEx or {}
--是否包含一个点rect格式 x,y,w,h r = {x= x,y=y,w =w,h = h},    border 检测边界
function rectEx.contain(r,x,y ,border)
    border = border  and border or 0
    r.w = r.w or r.width
    r.h = r.h or r.height
    if x <r.x - border or x >r.x+r.w + border or y < r.y -border or y > r.y + r.h +border then
        return false
    end
    return true

end

return BtnBase
