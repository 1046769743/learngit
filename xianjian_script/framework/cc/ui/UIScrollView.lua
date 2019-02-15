
--[[

Copyright (c) 2011-2014 chukong-inc.com

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
THE SOFTWARE.

]]

--------------------------------
-- @module UIScrollViewExpand

--[[--

quick 滚动控件

]]

local UIScrollViewExpand = class("UIScrollViewExpand", function()
	return cc.ClippingRegionNode:create()
end)

UIScrollViewExpand.BG_ZORDER 				= -100
UIScrollViewExpand.TOUCH_ZORDER 			= -99

UIScrollViewExpand.DIRECTION_BOTH			= 0
UIScrollViewExpand.DIRECTION_VERTICAL		= 1
UIScrollViewExpand.DIRECTION_HORIZONTAL	= 2

UIScrollViewExpand.MAXMOVE = 200;


-- start --

--------------------------------
-- 滚动控件的构建函数
-- @function [parent=#UIScrollViewExpand] new
-- @param table params 参数表

--[[--

滚动控件的构建函数

可用参数有：

-   direction 滚动控件的滚动方向，默认为垂直与水平方向都可滚动
-   viewRect 列表控件的显示区域
-   scrollbarImgH 水平方向的滚动条
-   scrollbarImgV 垂直方向的滚动条
-   bgColor 背景色,nil表示无背景色
-   bgStartColor 渐变背景开始色,nil表示无背景色
-   bgEndColor 渐变背景结束色,nil表示无背景色
-   bg 背景图
-   bgScale9 背景图是否可缩放
-	capInsets 缩放区域

]]
-- end --

function UIScrollViewExpand:ctor(params)
	self.bBounce = true
	self.nShakeVal = 15
	self.direction = UIScrollViewExpand.DIRECTION_BOTH
	self.speed = {x = 0, y = 0}
	self.position_ = {x=0,y=0}
	self:setCascadeOpacityEnabled(true)
	self._bounceDis = 0 
	self._appearComplete =true;
	--滚动速度
	self._barBgWay = 1
	self.scrollSpeed = 2;
	self._scrollBorder = 0;
	-- self:setOpacityModifyRGB(true)
	self._drawScrollBar = true
	-- 保持滚动条永不显示
	self._keepScrollBar = false
	if not params then
		return
	end
	
	if params.viewRect then
		self:setViewRect(params.viewRect)
	end

	if params.direction then
		self:setDirection(params.direction)

		if self._bounceDis ==0 then
			if self.direction == UIScrollViewExpand.DIRECTION_VERTICAL then
				self._bounceDis = self.viewRect_.height/6
			else
				self._bounceDis = self.viewRect_.width/6
			end
		end

	end

	if params.scrollbarImgHbg then
		self.sbHbg = display.newScale9Sprite(params.scrollbarImgHbg, 0):addTo(self):visible(false)
	end
	if params.scrollbarImgH then
		self.sbH = display.newScale9Sprite(params.scrollbarImgH, 0):addTo(self):visible(false)
	end

	if params.scrollbarImgVbg then
		self.sbVbg = display.newScale9Sprite(params.scrollbarImgVbg, 0):addTo(self):visible(false)
	end
	if params.scrollbarImgV then
		self.sbV = display.newScale9Sprite(params.scrollbarImgV, 0):addTo(self):visible(false)
	end

	-- touchOnContent true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
	-- 当内容小于显示区域时，两者就有区别了
	self:setTouchType(params.touchOnContent or true)

	self:addBgColorIf(params)
	self:addBgGradientColorIf(params)
	self:addBgIf(params)

	self:addNodeEventListener(cc.NODE_ENTER_FRAME_EVENT, function(...)
			self:update_(...)
		end)
	self:scheduleUpdate()
end


--[[ speed 2是标准，越大越快 ]]
function UIScrollViewExpand:setScrollSpeed(speed)
	self.scrollSpeed = speed;
end

function UIScrollViewExpand:addBgColorIf(params)
	if not params.bgColor then
		return
	end

	-- display.newColorLayer(params.bgColor)
	cc.LayerColor:create(params.bgColor)
		:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x, params.viewRect.y)
		:addTo(self, UIScrollViewExpand.BG_ZORDER)
		:setTouchEnabled(false)
end

function UIScrollViewExpand:_calMaxXY()
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
    	if self.__scrollNodeRect.height < self.viewRect_.height then
    		self._max = -self._scrollBorder
    	else
    		self._max = self.__scrollNodeRect.height - self.viewRect_.height - self._scrollBorder;
    	end
        
        self._min = self._scrollBorder;
        self._max = math.max(self._min,self._max);
    else 
        
    	self._max = -self._scrollBorder

        if self.__scrollNodeRect.width < self.viewRect_.width then
        	self._min =self._scrollBorder
        else
        	self._min = -(self.__scrollNodeRect.width - self.viewRect_.width) + self._scrollBorder;
        end
        self._min = math.min(self._min,self._max)
    end  
end

function UIScrollViewExpand:addBgGradientColorIf(params)
	if not params.bgStartColor or not params.bgEndColor then
		return
	end

	local layer = cc.LayerGradient:create(params.bgStartColor, params.bgEndColor)
		:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x, params.viewRect.y)
		:addTo(self, UIScrollViewExpand.BG_ZORDER)
		:setTouchEnabled(false)
	layer:setVector(params.bgVector)
end

function UIScrollViewExpand:addBgIf(params)
	if not params.bg then
		return
	end

	local bg
	if params.bgScale9 then
		bg = display.newScale9Sprite(params.bg, nil, nil, nil, params.capInsets)
	else
		bg = display.newSprite(params.bg)
	end

	bg:size(params.viewRect.width, params.viewRect.height)
		:pos(params.viewRect.x + params.viewRect.width/2,
			params.viewRect.y + params.viewRect.height/2)
		:addTo(self, UIScrollViewExpand.BG_ZORDER)
		:setTouchEnabled(false)
end

function UIScrollViewExpand:setViewRect(rect)
	self:setClippingRegion(rect)
	self.viewRect_ = rect
	return self
end

-- start --

--------------------------------
-- 得到滚动控件的显示区域
-- @function [parent=#UIScrollViewExpand] getViewRect
-- @return Rect#Rect 

-- end --

function UIScrollViewExpand:getViewRect()
	return self.viewRect_
end




--------------------------------
-- 设置滚动方向
-- @function [parent=#UIScrollViewExpand] setDirection
-- @param number dir 滚动方向
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:setDirection(dir)
	self.direction = dir

	return self
end

-- start --

--------------------------------
-- 获取滚动方向
-- @function [parent=#UIScrollViewExpand] getDirection
-- @return number#number 

-- end --

function UIScrollViewExpand:getDirection()
	return self.direction
end

-- start --

--------------------------------
-- 设置滚动控件是否开启回弹功能
-- @function [parent=#UIScrollViewExpand] setBounceable
-- @param boolean bBounceable 是否开启回弹
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:setBounceable(bBounceable)
	self.bBounce = bBounceable

	return self
end

-- start --

--------------------------------
-- 设置触摸响应方式
-- true:当触摸在滚动内容上才有效 false:当触摸在显示区域(viewRect_)就有效
-- 内容大于显示区域时，两者无差别
-- 内容小于显示区域时，true:在空白区域触摸无效,false:在空白区域触摸也可滚动内容
-- @function [parent=#UIScrollViewExpand] setTouchType
-- @param boolean bTouchOnContent 是否触控到滚动内容上才有效
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:setTouchType(bTouchOnContent)
	self.touchOnContent = bTouchOnContent

	return self
end

--[[--

重置位置,主要用在纵向滚动时

]]
function UIScrollViewExpand:resetPosition()
	if UIScrollViewExpand.DIRECTION_VERTICAL ~= self.direction then
		return
	end

	local x, y = self.scrollNode:getPosition()
	local bound = self:getScrollNodeRect()
	local disY = self.viewRect_.y + self.viewRect_.height - bound.y - bound.height
	y = y + disY
	self.scrollNode:setPosition(x, -bound.height - bound.y)
end

-- start --

--------------------------------
-- 设置scrollview可触摸
-- @function [parent=#UIScrollViewExpand] setTouchEnabled
-- @param boolean bEnabled 是否开启触摸
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:setTouchEnabled(bEnabled)
	if not self.scrollNode then
		return
	end
	self.scrollNode:setTouchEnabled(bEnabled)

	return self
end

-- start --

--------------------------------
-- 将要显示的node加到scrollview中,scrollView只支持滚动一个node
-- @function [parent=#UIScrollViewExpand] addScrollNode
-- @param node node 要显示的项
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:addScrollNode(node)
	self:addChild(node)
	self.scrollNode = node

	if not self.viewRect_ then
		self.viewRect_ = self:getScrollNodeRect()
		self:setViewRect(self.viewRect_)
	end
	node:setTouchSwallowEnabled(false)
	node:setTouchEnabled(true)

	node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
        local result = self:onTouchCapture_(event)
        return result 
    end,nil,1)
    
	self:addTouchNode()

    return self
end

-- start --

--------------------------------
-- 返回scrollView中的滚动node
-- @function [parent=#UIScrollViewExpand] getScrollNode
-- @return node#node  滚动node

-- end --

function UIScrollViewExpand:getScrollNode()
	return self.scrollNode
end

-- start --

--------------------------------
-- 注册滚动控件的监听函数
-- @function [parent=#UIScrollViewExpand] onScroll
-- @param function listener 监听函数
-- @return UIScrollViewExpand#UIScrollViewExpand 

-- end --

function UIScrollViewExpand:onScroll(listener)
	self.scrollListener_ = listener

    return self
end


function UIScrollViewExpand:update_(dt)
	self:drawScrollBar()
	if self.onUpdate then
		self.onUpdate()
	end
end

function UIScrollViewExpand:onTouchCapture_(event)
	if ("began" == event.name or "moved" == event.name or "ended" == event.name)
		and self:isTouchInViewRect(event) then
		return true
	else
		return false
	end
end

local globelDisableScroll = false

function UIScrollViewExpand:setDiableScroll( ... )
	self.isDiableOtherScroll = true
end

function UIScrollViewExpand:onTouch_(event)
	if "began" == event.name then
		if not self:isTouchInViewRect(event)  then
			if self.isDiableOtherScroll then
				globelDisableScroll = false
			end
			return false
		else
			if self.isDiableOtherScroll then
				globelDisableScroll = true
			end
		end
		printInfo("UIScrollViewExpand - touch didn't in viewRect")
		
	end


	local localPos = self:convertToNodeSpace(cc.p(event.x, event.y))

	if not self._appearComplete then
		return
	end

	if "began" == event.name and self.touchOnContent then
		local cascadeBound = self:getScrollNodeToParentRect()
		if not cc.rectContainsPoint(cascadeBound, localPos) then
			return false
		end
	end

	if globelDisableScroll and (not self.isDiableOtherScroll) then
		return
	end

	if "began" == event.name then
		
		self:stopScrolling();

		self.prevX_ = localPos.x
		self.prevY_ = localPos.y
		local x,y = self.scrollNode:getPosition()
		self.position_ = {x = x, y = y}

		self:callListener_{name = "began", x = localPos.x, y = localPos.y}

		self:enableScrollBar()


		--临时记录 一个属性是否拖到地步
		self._isOnEnd= false

		return true
	elseif "moved" == event.name then
		if self:isShake(localPos) then
			return
		end

		if not self:checkCanClickOnGuide() then
			if UIScrollViewExpand._isEnableScroll == false then
				return
			end
		end
		

		self.bDrag_ = true

		local prevPos = self:convertToNodeSpace(cc.p(event.prevX, event.prevY))

		self.speed.x = localPos.x - prevPos.x
		self.speed.y = localPos.y - prevPos.y

		if self.direction == UIScrollViewExpand.DIRECTION_VERTICAL then
			self.speed.x = 0
		elseif self.direction == UIScrollViewExpand.DIRECTION_HORIZONTAL then
			self.speed.y = 0
		else
			-- do nothing
		end

		self:scrollBy(self.speed.x, self.speed.y)
		self:callListener_{name = "moved", x = event.x, y = event.y}
	elseif "ended" == event.name then
		if self.bDrag_ then
			self:scrollAuto()
			
			if self._isScrolling == nil or self._isScrolling == false then 
				self.bDrag_ = false;
				self:disableScrollBar()
			end 
			
			self:callListener_{name = "ended", x = localPos.x, y = localPos.y}

		else
			self:callListener_{name = "clicked", x = localPos.x, y = localPos.y}
		end
	end
end

function UIScrollViewExpand:setRectTouchedOffset(_rectTouchedOffset)
	-- self.touchedViewRect = {x = self.viewRect_.x, y = self.viewRect_.y,
	-- 						width = self.viewRect_.width - _rectTouchedOffset.offsetX,
	-- 						height = self.viewRect_.height - _rectTouchedOffset.offsetY}
	self._touchBg:setContentSize(self.viewRect_.width - _rectTouchedOffset.offsetX, self.viewRect_.height - _rectTouchedOffset.offsetY)
	-- self._touchBg:visible(false)
end

function UIScrollViewExpand:isTouchInViewRect(event)
	local point = self:convertToNodeSpace(cc.p(event.x, event.y))
	return cc.rectContainsPoint(self.viewRect_, point )
end

function UIScrollViewExpand:isTouchInScrollNode(event)
	local cascadeBound = self:getScrollNodeRect()
	return cc.rectContainsPoint(cascadeBound, cc.p(event.x, event.y))
end

function UIScrollViewExpand:scrollTo(p, y)
	local x_, y_
	if "table" == type(p) then
		x_ = p.x or 0
		y_ = p.y or 0
	else
		x_ = p
		y_ = y
	end

	self.position_.x = x_
	self.position_.y = y_
	self.scrollNode:setPosition(self.position_)
end

function UIScrollViewExpand:moveXY(orgX, orgY, speedX, speedY)
	if self.bBounce and  self._bounceDis ==0 then
		-- bounce enable
		return orgX + speedX, orgY + speedY
	end

	local x, y = orgX, orgY
	local disX, disY

	--如果是
	if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then
		if speedY > 0 then
			if orgY + speedY > self._max + self._bounceDis then
				speedY = self._max + self._bounceDis - orgY
			end
		else
			if orgY + speedY < self._min - self._bounceDis then
				speedY = self._min - self._bounceDis - orgY
			end

		end
		speedX =0

	elseif self.direction == cc.ui.UIScrollView.DIRECTION_HORIZONTAL then
		if speedX > 0 then
			if speedX + orgX > self._max + self._bounceDis then
				speedX = self._max + self._bounceDis- orgX
			end

		else
			if speedX + orgX < self._min - self._bounceDis then
				speedX = self._min - self._bounceDis - orgX
			end

		end
		speedY =0
	end
	return  orgX + speedX, orgY + speedY
end

function UIScrollViewExpand:scrollBy(x, y)
	self.position_.x, self.position_.y = self:moveXY(self.position_.x, self.position_.y, x, y)
	-- self.position_.x = self.position_.x + x
	-- self.position_.y = self.position_.y + y
	self.scrollNode:setPosition(self.position_)

end

function UIScrollViewExpand:scrollAuto()


	--如果是按照pageview显示的
	if self._pageType then
		-- echo("_______11111111")
		self:scrollByPageType()
		return
	end

	--禁止自动缓动
	if not self._canAutoScroll then
	else
		if self:twiningScroll() then
			return
		end
	end
	--bounce 
	self:elasticScroll()
end

-- fast drag
function UIScrollViewExpand:twiningScroll()
	if self:isSideShow() then
		return false
	end

	-- echo("aaaaaaaaaaaaa",self._pageType)
	

	if math.abs(self.speed.x) < 10 and math.abs(self.speed.y) < 10 then
		return false
	end
	local disX, disY = self:moveXY(0, 0, self.speed.x * self.scrollSpeed, 
		self.speed.y*self.scrollSpeed)

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        self._scrollDistance = disY;
    else 
        self._scrollDistance = disX;
    end 

    self:enableScrollBar();
    self.bDrag_ = true;
    self._isScrolling = true;

    self.scrollNode:scheduleUpdateWithPriorityLua(handler(self, 
        self.deaccelerateScrolling), 0);
    return true
end

--按照pageType 方式运动
function UIScrollViewExpand:scrollByPageType(  )
	
end

function UIScrollViewExpand:deaccelerateScrolling()
    local curDis = nil;
    if UIScrollViewExpand.MAXMOVE < math.abs(self._scrollDistance) then 
        if self._scrollDistance > 0 then 
            curDis = UIScrollViewExpand.MAXMOVE;
        else 
            curDis = -UIScrollViewExpand.MAXMOVE;
        end 
    else 
        curDis = self._scrollDistance;
    end 
    
    local newPosXorY = nil;

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        newPosXorY = self.position_.y + curDis;
    else 
        newPosXorY = self.position_.x + curDis;
    end 

    if (newPosXorY > self._max) or (newPosXorY < self._min) or (math.abs(curDis) < 1) then 
        if newPosXorY > self._max then 
            if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
                self.position_.y = self._max;
            else 
                self.position_.x = self._max;
            end 
        end 

        if newPosXorY < self._min then 
            if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
                self.position_.y = self._min;
            else 
                self.position_.x = self._min;
            end 
        end 

        self.scrollNode:setPosition(self.position_);
        self:stopScrolling();
        self:callListener_{name = "scrollEnd"}
        return;
    end 

    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        self.position_.y = newPosXorY;  
    else 
        self.position_.x = newPosXorY;  
    end 

    self.scrollNode:setPosition(self.position_);

    self._scrollDistance = self._scrollDistance * 0.8;
end

function UIScrollViewExpand:elasticScroll()
	local cascadeBound = self:getScrollNodeToParentRect()
	local disX, disY = 0, 0

	local xpos,ypos = self.scrollNode:getPosition()



	--如果是纵向的
	if self.direction ==UIScrollViewExpand.DIRECTION_VERTICAL then
		disX = 0
		if ypos > self._max then
			disY = self._max - ypos
		elseif ypos < self._min then
			disY = self._min - ypos
		end

	elseif self.direction ==UIScrollViewExpand.DIRECTION_HORIZONTAL  then
		disY = 0
		if xpos > self._max then
			disX = self._max - xpos
		elseif xpos < self._min then
			disX = self._min - xpos
		end
	end


	if 0 == disX and 0 == disY then
		self:callListener_{name = "scrollEnd"}
		return
	end

	transition.moveBy(self.scrollNode,
		{x = disX, y = disY, time = 0.3,
		easing = "backout",
		onComplete = function()
			self:callListener_{name = "scrollEnd"}
		end})
end


--重写 获取node的rect 因为rect应该是外部传进来的
function UIScrollViewExpand:getScrollNodeRect()
	if not self.__scrollNodeRect then
		self.__scrollNodeRect = self.scrollNode:getContainerBox()
	end
	return self.__scrollNodeRect
end

function UIScrollViewExpand:getScrollNodeToParentRect(  )
	local bound = self:getScrollNodeRect()
	local xpos,ypos = self.scrollNode:getPosition()
	return {x = bound.x + xpos,y = bound.y + ypos,width = bound.width, height = bound.height}
end


function UIScrollViewExpand:getViewRectInWorldSpace()
	local rect =  self.viewRect_
	return rect
end

-- 是否显示到边缘
function UIScrollViewExpand:isSideShow()
	local xpos,ypos = self.scrollNode:getPosition()

	if self.direction == UIScrollViewExpand.DIRECTION_VERTICAL then
		if ypos > self._max then
			self:callListener_{name = "scrollHead", x = xpos, y = ypos}
			return true
		elseif ypos < self._min then
			self:callListener_{name = "scrollTail", x = xpos, y = ypos}
			return true
		end

	else
		if xpos > self._max then
			self:callListener_{name = "scrollHead", x = xpos, y = ypos}
			return true
		elseif xpos < self._min then
			self:callListener_{name = "scrollTail", x = xpos, y = ypos}
			return true
		end
	end

	-- if bound.x > self.viewRect_.x
	-- 	or bound.y > self.viewRect_.y
	-- 	or bound.x + bound.width < self.viewRect_.x + self.viewRect_.width
	-- 	or bound.y + bound.height < self.viewRect_.y + self.viewRect_.height then

	-- 	if bound.x > self.viewRect_.x or bound.y > self.viewRect_.y then
	-- 		self:callListener_{name = "scrollHead", x = self.position_.x, y = self.position_.y}
	-- 	else
	-- 		self:callListener_{name = "scrollTail", x = self.position_.x, y = self.position_.y}
	-- 	end
	-- 	return true
	-- end

	return false
end

function UIScrollViewExpand:callListener_(event)
	if not self.scrollListener_ then
		return
	end
	event.scrollView = self

	self.scrollListener_(event)
end

function UIScrollViewExpand:enableScrollBar()
	if not self._drawScrollBar then
		return
	end
	local bound = self:getScrollNodeRect()
	if self.sbV then
		self.sbV:setVisible(false)
		transition.stopTarget(self.sbV)
		self.sbV:setOpacity(128)
		local size = self.sbV:getContentSize()
		if self.viewRect_.height < bound.height then
			local barH = self.viewRect_.height*self.viewRect_.height/bound.height
			if barH < size.width then
				-- 保证bar不会太小
				barH = size.width
			end
			self.sbV:setContentSize(size.width, barH)
			self.sbV:setPosition(
				self.viewRect_.x + self.viewRect_.width/2*(1+self._barBgWay) - size.width/2*self._barBgWay, 
				self.viewRect_.y + barH/2)


			if self.sbVbg then
				transition.stopTarget(self.sbVbg)
				self.sbVbg:setOpacity(255)
				self.sbVbg:setVisible(true)
				self.sbVbg:setContentSize(size.width,self.viewRect_.height)
				self.sbVbg:pos(1+self.viewRect_.x + self.viewRect_.width/2*(1+self._barBgWay) - size.width/2*self._barBgWay,-self.viewRect_.height/2)
			end
			-- echo(barH,self.viewRect_.height,"___111")
		else
			-- 隐藏滚动条
			self._drawScrollBar = false
		end
	end
	if self.sbH then
		self.sbH:setVisible(false)
		transition.stopTarget(self.sbH)
		self.sbH:setOpacity(128)
		local size = self.sbH:getContentSize()
		if self.viewRect_.width < bound.width then
			local barW = self.viewRect_.width*self.viewRect_.width/bound.width
			if barW < size.height then
				barW = size.height
			end
			self.sbH:setContentSize(barW, size.height)
			self.sbH:setPosition(self.viewRect_.x + barW/2,
				self.viewRect_.y/2*(1+self._barBgWay) + size.height/2 * self._barBgWay )
			-- echo(self.viewRect_.y, self.viewRect_.y/2*(1+self._barBgWay),size.height/2,'___11111')
			if self.sbHbg then
				transition.stopTarget(self.sbHbg)
				self.sbHbg:setVisible(true)
				self.sbHbg:setOpacity(255)
				self.sbHbg:setContentSize(self.viewRect_.width,size.height)
				self.sbHbg:pos(self.viewRect_.width/2,self.viewRect_.y/2*(1+self._barBgWay) +size.height/2 * self._barBgWay )
			end
		else
			-- 隐藏滚动条
			self._drawScrollBar = false
		end
	end
end

function UIScrollViewExpand:disableScrollBar()
	if not self._drawScrollBar then
		return
	end

	if self._keepScrollBar then
		return
	end

	if self.sbV then
		transition.fadeOut(self.sbV,
			{time = 0.3,
			onComplete = function()
				self.sbV:setOpacity(128)
				self.sbV:setVisible(false)

			end})
		if self.sbVbg then
			transition.fadeOut(self.sbVbg,{time = 1.5,
				onComplete = function()
					self.sbVbg:setOpacity(255)
					self.sbVbg:setVisible(false)
				end

				} )
		end
	end
	if self.sbH then
		transition.fadeOut(self.sbH,
			{time = 1.5,
			onComplete = function()
				self.sbH:setOpacity(128)
				self.sbH:setVisible(false)
			end})
		if self.sbHbg then
			transition.fadeOut(self.sbHbg,{time = 1.5,
				onComplete = function()
					self.sbHbg:setOpacity(255)
					self.sbHbg:setVisible(false)
				end

				} )
		end
	end
end

function UIScrollViewExpand:drawScrollBar()

	if not self._drawScrollBar then
		return
	end

	if not self.bDrag_ then
		return
	end
	if not self.sbV and not self.sbH then
		return
	end

	local bound = self:getScrollNodeToParentRect()
	if self.sbV then
		self.sbV:setVisible(true)
		if self.sbVbg then
			self.sbVbg:setVisible(true)
		end

		local size = self.sbV:getContentSize()

		local posY = (self.viewRect_.y - bound.y)*(self.viewRect_.height - size.height)/(bound.height - self.viewRect_.height)
			+ self.viewRect_.y + size.height/2
		local x, y = self.sbV:getPosition()
		self.sbV:setPosition(x, posY)
	end
	if self.sbH then
		self.sbH:setVisible(true)
		if self.sbHbg then
			self.sbHbg:setVisible(true)
		end
		local size = self.sbH:getContentSize()

		local posX = (self.viewRect_.x - bound.x)*(self.viewRect_.width - size.width)/(bound.width - self.viewRect_.width)
			+ self.viewRect_.x + size.width/2
		local x, y = self.sbH:getPosition()
		self.sbH:setPosition(posX, y)
	end
end

function UIScrollViewExpand:addScrollBarIf()

	if not self.sb then
		self.sb = cc.DrawNode:create():addTo(self)
	end

	drawNode = cc.DrawNode:create()
    drawNode:drawSegment(points[1], points[2], radius, borderColor)
end


function UIScrollViewExpand:isShake(event)
	if math.abs(event.x - self.prevX_) < self.nShakeVal
		and math.abs(event.y - self.prevY_) < self.nShakeVal then
		return true
	end
end



--[[--

加一个大小为viewRect的touch node

]]
function UIScrollViewExpand:addTouchNode()
	local node

	if self.touchNode_ then
		node = self.touchNode_
	else
		node = display.newNode()
		self.touchNode_ = node

		local bg = display.newNode()
		--让自己不穿透
		bg:setTouchSwallowEnabled(true)
		bg:setTouchEnabled(true)


		bg:setContentSize(self.viewRect_.width, self.viewRect_.height)
		bg:setPosition(self.viewRect_.x, self.viewRect_.y)
		bg:addto(self,-99)
		-- node:setLocalZOrder(UIScrollViewExpand.TOUCH_ZORDER)
		node:setTouchSwallowEnabled(false)
		node:setTouchEnabled(true)

		node:anchor(0,1)
		node:setContentSize(self.viewRect_.width,self.viewRect_.height)
		node:pos(0,0 )
		self._touchBg = bg
		-- node:addNodeEventListener(cc.NODE_TOUCH_CAPTURE_EVENT, function (event)
	 --    	local result = self:onTouchCapture_(event)
	 --        return result
	 --    end)


		node:addNodeEventListener(cc.NODE_TOUCH_EVENT, function (event)
			local result = self:onTouch_(event)

	        return result or false
	    end)

	    self:addChild(node)
	end

	-- node:setContentSize(self.viewRect_.width, self.viewRect_.height)
	-- node:setPosition(self.viewRect_.x, self.viewRect_.y)

    return self
end


--停止scrolling
function UIScrollViewExpand:stopScrolling()
    self.scrollNode:unscheduleUpdate();
    -- self.scrollNode:stopAllActions()
    self.bDrag_ = false
    self:disableScrollBar();
    self._isScrolling = false;	
end




--更新尺寸 
function UIScrollViewExpand:setScrollNodeRect(rect)
	self.__scrollNodeRect = rect or self.scrollNode:getContainerBox()
	self:_calMaxXY();
	--同时更新下边界判断
	local posx,posy = self:getCurrentPos()
    posx,posy = self:checkBorderPos(posx, posy)
    self:scrollTo(posx,posy)

end


--checkBorderPos
function UIScrollViewExpand:checkBorderPos( xpos,ypos )
	--边界判断
    if self.direction == cc.ui.UIScrollView.DIRECTION_VERTICAL then 
        if ypos < self._min then
            ypos = self._min
        elseif ypos > self._max then
            ypos = self._max
        end
    else 
        if xpos < self._min then
            xpos = self._min
        elseif xpos > self._max then
            xpos =self._max
        end
    end   
    return xpos,ypos 
end




return UIScrollViewExpand
