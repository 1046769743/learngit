

--[[
-- Usage:
--      添加Sprite基础节点: d.sp("a.png"):pos(0,0):addto(self)
--      缩放+旋转: d.sp("a.png"):scale(2,1):rotation(10)
--      ...
]]

--[[
-- 格式: node:add(child [,z [,tag] ] )
-- 说明: 添加子节点
]]

local Node = cc.Node
local Sprite = cc.Sprite

--[[
-- 格式: node:addto(pr [,z [,tag] ] )
-- 说明: 添加至父节点
]]
Node.addto = Node.addTo
--[[
-- 格式: node:pos( [x [,y] ] )
-- 说明: 坐标相关
-- 用法:
--      local x,y = node:pos() --获取坐标
--      node:pos(0,0) --设定坐标(xy两个参数)
--      node:pos(CCPoint) --设定坐标(CCPoint对象)
 ]]
function Node:pos(x,y)
	if(x==nil) then                         -- pos() = getPosition() @return: x,y
		return self:getPosition()
	end
	if(y==nil) then                         -- pos(x) = setPosition(CCPoint)
		self:setPosition(x)
	else                                    -- pos(x,y)
		self:setPosition(x,y)
	end
	return self
end

--让 node偏移
function Node:offsetPos( ofx,ofy )
	ofx = ofx or 0
	ofy = ofy or 0
	local x,y = self:getPosition()
	self:pos(ofx + x,ofy + y)
end


--[[
-- 格式: node:scale( [x [,y] ] )
-- 说明: 缩放相关
-- 用法:
--      local x,y = node:scale() --获取当前缩放
--      node:scale(1,1) --设定缩放(xy两个不同值)
--      node:scale(1) --设定缩放(xy共用一个值)
 ]]

function Node:anchor(x,y)
	if(x==nil) then                         -- anchor() = getAnchorPoint() @return: x,y
		local tmp = self:getAnchorPoint()
		return tmp.x,tmp.y
	end
	if(y==nil) then                         -- anchor(CCPoint)
		self:setAnchorPoint(x)
	else                                    -- anchor(x,y)
		self:setAnchorPoint(cc.p(x,y))
	end
	return self
end
function Node:rotation(x,y)
	if x==nil then return self:getRotation() end    -- rotation() = getRotation()
	if y==nil then
		self:setRotation(x)                                     -- rotation(r) = setRotation(r)
	elseif x~=y then
		self:setRotationX(x)
		self:setRotationY(y)
	else
		self:setRotation(x)                             -- rotation(r) = setRotation(r)
	end
	return self
end

--[[
-- 格式: node:visible( [v] )
-- 说明: 可视状态相关
-- 用法:
--      local v = node:visible() --获取当前是否显示(true:当前为显示; false:当前在隐藏)
--      node:visible(true) --设定显示和隐藏(true或1为表示显示，false或0为表示隐藏)
 ]]
function Node:visible(v)
	if v==false or v==0 then self:setVisible(false) -- visible(false/0)
	else self:setVisible(true) end                  -- visible(true/1)
	return self
end


function Node:remove(v)
	if v==nil then                                  -- remove() = removeFromParentAndCleanup(false) = clear(false)
		self:removeFromParent()
	elseif type(v)=="number" then                   -- remove(int) = removeChildByTag(tag)
		self:removeChildByTag(v,true)
	else                                            -- remove(node) = removeChild(node)
		self:removeChild(v,true)
	end
	return self
end
--[[
-- 格式: node:parent(pr [,z [,tag] ])
-- 说明: 切换node的父节点
-- 使用:
--      local node = d.node():addto(aNode,nil,5) --node原父节点是aNode
--      node:parent(bNode) --将node移至父节点bNode下，并且沿用之前的tag
 ]]
function Node:parent(pr,z,tag)
	if pr==nil then return self:getParent() end     -- parent() = getParent()
	-- if self:parent()==pr then return end           
	if(tag==nil) then tag = self:getTag() end --参数tag为空则沿用之前的tag
	self:retain()
	if self:getParent() then
		self:removeFromParent(false)
	end
	self:addTo(pr,z,tag)
	self:release()
	return self
end
--[[
-- 格式: node:clear([cleanup=true])
-- 说明: 将node移出父节点并彻底清除
-- 使用:
--      node:clear()
--      node = nil
 ]]
function Node:clear(cleanup)
	if cleanup==nil then cleanup = true end -- 默认cleanup=true
	self:removeFromParent(cleanup)

    local eventDispatcher = cc.Director:getInstance():getEventDispatcher();

    if self._touchlistener ~= nil then 
        eventDispatcher:removeEventListener(self._touchlistener);
        self._touchlistener = nil;
    end 

end
--[[
-- 格式: node:alignLT()
-- 说明: 快捷调设置锚点
--      L 代表left, R 代表right, 以此类推T=top,B=bottom,C=center, LT即为中国语言习惯的左上
 ]]
function Node:alignLT() self:align(display.LEFT_TOP) return self end
function Node:alignLB() self:align(display.LEFT_BOTTOM) return self end
function Node:alignRT() self:align(display.RIGHT_TOP) return self end
function Node:alignRB() self:align(display.RIGHT_BOTTOM) return self end
function Node:alignR() self:align(display.RIGHT_CENTER) return self end
function Node:alignL() self:align(display.LEFT_CENTER) return self end
function Node:alignC() self:align(display.CENTER) return self end
function Node:alignT() self:align(display.TOP_CENTER) return self end
function Node:alignB() self:align(display.BOTTOM_CENTER) return self end
--[[
-- 格式: node:size( [w [,h] ])
-- 说明: 尺寸相关(参数单位为像素，比scale直接计算百分比要方便的多)
-- 用户:
--      local w,h = xxx:size() --获取当前size
--      xxx:size(100,100) --像素值直接设定宽高
--      xxx:size(CCSize) --使用CCSize对象
--      (注意node、sprite及Scale9Srpite，用法意义各不相同)
--      当xxx为node时，size为cocos2d-x默认的ContentSize
--      当xxx为sprite时，size直接按照像素单位控制sp的缩放
--      当xxx为scale9sprite时，size可直接控制sp9的外围尺寸
-- todo 可以考虑将sprite/sprite9/node的size方法分开，放到各自的Extend中(需要检查有些new的地方继承的是否准确)
 ]]
function Node:size(w,h)
	local _cctype = tolua.type(self)
	if(_cctype=="cc.Sprite") then                --* sprite会按照scale比例计算和设置size
		local _oriSize = self:getContentSize()
		if(w==nil) then                             -- size() @return: w,h
			return _oriSize.width*self:getScaleX(),_oriSize.height*self:getScaleY()
		end
		if(h==nil) then                             -- size(CCSize)
			h = w.height
			w = w.width
		end                                         -- size(w,h)
		self:setScaleX(w/_oriSize.width)
		self:setScaleY(h/_oriSize.height)
	else -- node (目前CCScale9Sprite和ATScale3Sprite都在使用该代码，若有修改看是否需要单列出来)
		if(w==nil) then                             -- size() @return: w,h
			-- todo 看是否需要计算scale (CCLabelTTF是没有计算scale的)
			local _size = self:getContentSize()
			return _size.width,_size.height
		end
		if(h==nil) then                             -- size(CCSize)
			self:setContentSize(w)
		else                                        -- size(w,h)
			self:setContentSize(cc.size(w,h))
		end
	end
	return self
end
--[[
-- 格式: node:delayCall(func [,delay=0.001])
-- 说明: 设定延时动作
--      performWithDelay的别名，并增加默认时间，即 self:delayCall(func)时，表示下一帧执行
 ]]
function Node:delayCall(func,delay)
	return self:performWithDelay(func,delay or 0.001)
end


--按照帧延迟做什么事
function Node:delayCallByFrame(func,frame )
	local leftFrame = frame
	local listener = function (dt)
        leftFrame = leftFrame -1
        if leftFrame == 0 then
        	self:unscheduleUpdate()
        	func()
        end
    end

    self:scheduleUpdateWithPriorityLua(listener, 0) 
end


--将子节点bounding融合到父节点bounding
--合并两个rect(要求参照点必须相同，即同一个父节点)
local function _mergeRect(rect1,rect2)
	-- rect1宽高为0，直接返回rect2
	if not rect1 or rect1.size.width<=0 or rect1.size.height<=0 then
		return rect2
	end
	-- rect2宽高为0，直接返回rect1
	if not rect2 or rect2.size.width<=0 or rect2.size.height<=0 then
		return rect1
	end
	-- 都有宽高，合并之
	local _minx = math.min(rect1:getMinX(),rect2:getMinX())
	local _maxx = math.max(rect1:getMaxX(),rect2:getMaxX())
	local _miny = math.min(rect1:getMinY(),rect2:getMinY())
	local _maxy = math.max(rect1:getMaxY(),rect2:getMaxY())
	return cc.rect(_minx,_miny,_maxx-_minx, _maxy-_miny)
end

local function _mergeToPr(childBounding,prBounding)
	--echo("$$$$_____ merge _____",childBounding,prBounding)
	--echo("$$$$ c:",dumpRect(childBounding))
	--echo("$$$$ p:",dumpRect(prBounding))
	--子节点数据异常，直接返回父节点
	if not childBounding then
		return prBounding
	end
	--子节点宽高为0，则直接返回父节点
	if childBounding.size.width<=0 or childBounding.size.height<=0 then
		return prBounding
	end
	local _cOrigin = childBounding.origin
	--先将子节点bounding的参照点与父节点统一
	_cOrigin.x = _cOrigin.x + prBounding.origin.x
	_cOrigin.y = _cOrigin.y + prBounding.origin.y
	childBounding.origin = _cOrigin
	prBounding = _mergeRect(childBounding,prBounding)
	--echo("$$$$ r:",dumpRect(prBounding))
	return prBounding
end

local _RECT_ZERO_ = cc.rect(0,0,0,0)
function Node:boundingRect()
	echo("========",tolua.type(self),self)
	assert(not tolua.isnull(self),"@Node:boundingRect(). self is null.")
	local _cctype = tolua.type(self)
	if _cctype=="CCObject" then return _RECT_ZERO_ end
	--先计算自己的bounding
	local _rect = self:boundingBox()
	if _cctype=="CCNode" or _cctype=="CCLayer" or _cctype=="CCScene" then -- CCNode和CCLayer不计算本身宽高(有可能setContent设置的其他用途)
		_rect.size.width,_rect.size.height = 0, 0
		--echo("skip",_cctype,_rect.origin.x,_rect.origin.y,_rect.size.width,_rect.size.height)
	end
	--再计算子节点的bounding
	local _cCnt = self:getChildrenCount()
	echo("cccccc  children count",_cCnt)
	if _cCnt>0 then
		local ccarr = self:getChildren()
		local _cRect = _RECT_ZERO_
		for i=0,_cCnt-1,1 do
			local child = ccarr:objectAtIndex(i)
			_cRect = _mergeRect(child:boundingRect(),_cRect)
		end
		_rect = _mergeToPr(_cRect,_rect)
	end
	
	return _rect
end

--CCNode专用resize方法，用于计算包含子节点的整体尺寸，之后可以使用getContentSize()获取
function Node:resize()
	if(tolua.type(self)=="CCNode") then
		self:size(self:boundingRect().size)
	end
	return self
end


-- 让node绕某个点scale
function Node:scaleByPoint(pos, scaleX,scaleY)
	scaleY = scaleY or scaleX
	local xpos = math.round( pos.x - pos.x *scaleX )
    local ypos = math.round( pos.y - pos.y  * scaleY )
    local x,y = self:getPosition()
    self:pos(xpos + x,ypos + y)
    self:setScaleX(scaleX)
    self:setScaleY(scaleY)
end

-- 围绕中心点缩放
function Node:scaleByCenterPoint(scaleX,scaleY)
	local selfBox = self:getContainerBox()
	local pos = {x = selfBox.width/2 + selfBox.x , y = selfBox.height/2 + selfBox.y }

	scaleY = scaleY or scaleX
	local xpos = math.round( pos.x - pos.x * scaleX )
    local ypos = math.round( pos.y - pos.y  * scaleY )
    
    local x,y = self:getPosition()
    self:pos(xpos + x,ypos + y)

    self:setScaleX(scaleX)
    self:setScaleY(scaleY)
end

-- 围绕指定点pos创建缩放动画
-- 如果pos为nil，表示围绕中心点
function Node:getScaleAnimByPos(time, scaleX,scaleY,isBounnce,pos,offset)
	if not pos then
		local selfBox = self:getContainerBox()
		pos = {x = selfBox.width/2 + selfBox.x , y = selfBox.height/2 + selfBox.y }

	end
	local offset = offset or {x=0,y=0}

	scaleY = scaleY or scaleX
	local xpos = math.round( pos.x - pos.x * scaleX )
    local ypos = math.round( pos.y - pos.y * scaleY )

    local x,y = self:getPosition()

    local scaleAnim 
    if isBounnce then
    	scaleAnim = act.spawn(
            act.bouncein( act.scaleto(time,scaleX,scaleY) ), 
            act.bouncein( act.moveto(time,x+ xpos +offset.x,y + ypos+offset.y) )
        )
    else
    	scaleAnim = act.spawn(
            act.scaleto(time,scaleX,scaleY),
            act.moveto(time,x+ xpos+offset.x,y + ypos +offset.y)
        )
    end
    
    return scaleAnim
end

--让node从scale1 缩放到scale2 
--fromsx 初始scalex , tos 目标scaleX,  pos 缩放中心
function Node:getFromToScaleAction( time,fromsx,formsy ,tosx,tosy,isBounnce,pos )
	if not pos then
		local selfBox = self:getContainerBox()
		pos = {x = selfBox.width/2 + selfBox.x , y = selfBox.height/2 + selfBox.y }

	end
	tosy = tosy or tosx
	local xpos = math.round( pos.x - pos.x * tosx )
    local ypos = math.round( pos.y - pos.y * tosy )

    local x,y = self:getPosition()

    if fromsx  then
    	self:scaleByPoint(pos,fromsx,fromsy)
    end
    
    local scaleAnim 
    if isBounnce then
    	scaleAnim = act.spawn(
            act.bouncein( act.scaleto(time,tosx,tosy) ), 
            act.bouncein( act.moveto(time,x+ xpos,y + ypos) )
        )
    else
    	scaleAnim = act.spawn(
            act.scaleto(time,tosx,tosy),
            act.moveto(time,x+ xpos,y + ypos)
        )
    end
    
    return scaleAnim

end


-- 围绕指定点pos做缩放动画
function Node:scaleByPos(time, scaleX,scaleY,isBounnce,pos)
	local spawnAnim = self:getScaleAnimByPos(time, scaleX,scaleY,isBounnce,pos)
	self:runAction(spawnAnim)
end

--设置材质  主要是区分 带和不带#的  区别和原生的cocos2d  setTexture
function Sprite:setTextureName(textureName  )
	if not textureName then
		return
	end
	--如果是带#的
	if string.byte(textureName) == 35 then
		local frame = display.newSpriteFrame(string.sub(textureName, 2))
		self:setSpriteFrame(frame)
	else
		self:setTexture(textureName)
	end
	return self
end

-- alias
Node.timer = Node.schedule

display.newNode = function (  )
	local nd = cc.Node:create()
	nd:setCascadeOpacityEnabled(true)
	-- nd:setTouchEnabled(false)
	-- nd:ignoreAnchorPointForPosition(true)
	return nd
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


function Node:enablePriorityTouch()
	if self._touchlistener ~= nil then 
		-- self._touchlistener:setEnabled(true);
	end 
end

function Node:disablePriorityTouch()
	if self._touchlistener ~= nil then 
		-- self._touchlistener:setEnabled(false);
	end 
end

local globalUpTime = 0

--[[
	isPlayComClick2Music 默认是true
]]
function Node:setTouchedFunc( func, rect, touchSwallowEnabled, beganCallback, movedCallback, isPlayComClick2Music,onGloadEnd)
	
	
	if isPlayComClick2Music == nil then
		isPlayComClick2Music = true
	end
	
	local errorStack = debug.traceback()

	if not func then
		echoError("传入了空函数")
		return
	end
	if self.__cname =="BtnExpand" then
		isPlayComClick2Music = true
		if beganCallback then
			self:setBegan(beganCallback)
		end
		if movedCallback then
			self:setMoved(movedCallback)
		end

		if onGloadEnd then
			self:setEnded(onGloadEnd)
		end

		self:setTap(func)
		return
	end
	self.isPlayComClick2Music = isPlayComClick2Music
	touchSwallowEnabled = touchSwallowEnabled or false
	
	self.__canClick = true

    local touchFunc = function ( event )
		rect = rect or self:getContainerBox()

    	local point = self:convertToNodeSpaceAR(cc.p(event.x, event.y))
    	local chk = rectEx.contain(rect, point.x, point.y)

        if(event.name == "began") then
        	local clockTime = os.clock()
        	-- if clockTime - globalUpTime < 0.1  and clockTime- globalUpTime > 0 then
        	-- 	return false
        	-- end
        	self.__hasClickBegan = false
        	--这里做一个时差屏蔽 防止因为延迟一帧期间做很多点击事件造成bug
        	-- echo (os.clock(),os.clock() - globalUpTime,"______点击")
        	

             self.__touch_moved=false      
             self.__lastClickPoint = event 
             Tool:printNodeRect(self,rect,event)
             Tool:drawNodeRect(self,rect,event)
             --如果点击优先级是高于引导的 那么不需要判断是否在新手引导内
             if self:checkCanClickOnGuide() then
             else
             	--新手引导阶段，点击开始和结束必须都在引导区内，否则move时会有bug
		        if (LoginControler:isStartPlay() == true or PrologueUtils:isInPrologue()) and 
		    		TutorialManager.getInstance():isAllFinish() == false and 
		    		 TutorialManager.getInstance():isTutoring() == true and
		    		  TutorialManager.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
		    		return false;
			    elseif BattleTutorialLayer.getInstance():isInTuroring() and 
			            BattleTutorialLayer.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
			        return false;
			    end

             end
            

        	if chk == true then
        		-- 点击开始回调
        		if self.__touchbeganFunc then
        			-- self:delayCall(c_func(self.__touchbeganFunc, event), 0.001)
        			self.__touchbeganFunc(event)
        		end
        		self.__hasClickBegan = true
        	end


        	return chk
	    elseif(event.name == "moved") then
	    	if not self.__hasClickBegan then
	    		return
	    	end
	    	local disx = math.abs(self.__lastClickPoint.x - event.x )
	    	local disy = math.abs(self.__lastClickPoint.y - event.y )
	    	if disx  > 30 or disy > 30    then
	    		self.__touch_moved=true
        	end
        	-- 移动回调
	        if self.__touchMoveFunc and self.__touch_moved  then
				self.__touchMoveFunc(event)
	        end
	    elseif(event.name == "ended") then
	   		--过滤掉点击任意地方的事件
	    	-- if rect.width < 700 or rect.height < 400 then
	    		
	    	-- end
	    	
	    	if not self.__hasClickBegan then
	    		return
	    	end
	    	if self.__touchGlobalEnd then
	    		self.__touchGlobalEnd(event)
	    		-- self:delayCall(c_func(self.__touchGlobalEnd, event),0.001)
	    		if tolua.isnull(self ) then 
	    			echoWarn("在__touchGlobalEnd的时候干掉了自己,后面的不应该执行了")
	    			return
	    		end
	    	end

	    	Tool:hideDrawNodeRect(self)
	    	
	        if chk == true and not self.__touch_moved then
	        	-- if not self.__canClick then
	        	-- 	return 
	        	-- end
	        	 if self:checkCanClickOnGuide() then
	        	 else
	        	 	if (LoginControler:isStartPlay() == true or PrologueUtils:isInPrologue() ) and 
		        		TutorialManager.getInstance():isAllFinish() == false and 
		        		 TutorialManager.getInstance():isTutoring() == true and
		        		  TutorialManager.getInstance():isInSetTouchClickArea(event.x, event.y,self) == false then 
		        		return
				    elseif BattleTutorialLayer.getInstance():isInTuroring() and 
				            BattleTutorialLayer.getInstance():isInSetTouchClickArea(event.x, event.y,self) == false then 
				        return false;
				    end
	        	 end
	        	

	        	local tempFunc = function ()
		            self.__canClick = true
		        end
		        -- self.__canClick =false
		        self:delayCall(tempFunc, 0.2)
		        
	        	-- self:delayCall(c_func(self.__touchFunc, event), 0.001)
        		--不定什么音效呢
        		if self.isPlayComClick2Music then 
        			local curT = os.clock()
        			--间隔必须超过0.1秒
        			if curT - globalUpTime > 0.1 then
        				AudioModel:playSound(MusicConfig.s_com_click2);
        				globalUpTime = curT
        			end
        			
    				
    			end
    			self.__touchFunc(event)
        	end
            self.__touch_moved=false
	    end
    end

    
    -- 只注册一次点击事件
    if not self.__touchFunc then
    	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, touchFunc, nil)
    end

    self:setTouchEnabled(true)
    self:setTouchSwallowEnabled(touchSwallowEnabled)
    

    self.__touchFunc = func
	self.__touchbeganFunc = beganCallback
	self.__touchMoveFunc = movedCallback
	self.__touchGlobalEnd = onGloadEnd

end

function Node:_sureRegistTouchedFunc(targetNode, func, rect, touchSwallowEnabled, beganCallback, movedCallback, isPlayComClick2Music,onGloadEnd )
	
end


--长按事件
--funcs: endFunc, 和repeatFunc 必须有一个
----beganFunc, 
----endFunc, 相当于点击func
----moveFunc,
----repeatFunc, 长按调用
----repeatCount, 重复调用次数 <0为 无限次, 
--repeatInterval 每隔多久调用一次 repeatFunc
--如果点按时长没有超过repeatInterval,触发点击操作
function Node:setLongTouchFunc(funcs, rect, touchSwallowEnabled, repeatInterval, repeatCount, firstDelayTime)
	if not funcs or (not funcs.endFunc and not funcs.repeatFunc) then
		error("传入了空函数列表")
	end

	if not firstDelayTime then
		firstDelayTime = repeatInterval
	end
	echo("___________")
    self.__canLongClick = true

	repeatInterval = repeatInterval or 0.5
	repeatCount = repeatCount or 0
	
	--是否无限次调用
	local isInfiniteRepeat = repeatCount <=0

	touchSwallowEnabled = touchSwallowEnabled or false
	rect = rect or self:getContainerBox()

	self._longTouchPressed = false
	self._longTouchMoved = false
	self._longTouchEnded = false
	self._longTouchOriginRepeatCount = repeatCount
	local offsetX =0
	local offsetY = 0

	local anchor = self:getAnchorPoint()
	local size = self:getContentSize()

	offsetX = -anchor.x  * size.width
	offsetY = -anchor.y * size.height

	self.__innerRepeatAction = function()
		--如果移动或者touch已经结束，那么结束delay递归
		--echo('innerRepeatAction---1')
		if self._longTouchMoved or self._longTouchEnded then
			return
		end
		--echo('innerRepeatAction---2', repeatCount)
		--重复调用次数消耗完
		if not isInfiniteRepeat and repeatCount <= 0 then return end

		if not isInfiniteRepeat then
			--echo('innerRepeatAction---3')
			repeatCount = repeatCount - 1
		end
		self.__longTouchRepeatFunc()
		self._delayAction1 = self:delayCall(c_func(self.__innerRepeatAction, self), self._longTouchRepeatInterval)
	end

	local longTouchFunc = function (event )
		local point = self:convertToNodeSpaceAR(cc.p(event.x,event.y))
		point.x = point.x + offsetX
		point.y = point.y + offsetY

		local chk = rectEx.contain(rect,point.x,point.y)

		if(event.name == "began") then 


            --新手引导阶段，点击开始和结束必须都在引导区内，否则move时会有bug
	        if (LoginControler:isStartPlay() == true or PrologueUtils:isInPrologue()) and 
	    		TutorialManager.getInstance():isAllFinish() == false and 
	    		 TutorialManager.getInstance():isTutoring() == true and
	    		  TutorialManager.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
	    		return false;
		    elseif BattleTutorialLayer.getInstance():isInTuroring() and 
		            BattleTutorialLayer.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
		        return false;
		    end


			if chk == true then
				self._longTouchPressed = true
				self._longTouchMoved = false
				self._longTouchEnded = false
				-- 点击开始回调
				if self.__longTouchBeganFunc then
					self.__longTouchBeganFunc(event)
				end
				if self.__longTouchRepeatFunc then
					self._delayAction2 =self:delayCall(c_func(self.__innerRepeatAction, self), firstDelayTime)
				end
			end
			return chk
		elseif(event.name == "moved") then
			if chk == false then
				self._longTouchPressed = false
			end
			self._longTouchMoved = false
			-- 移动回调
			if self.__longTouchMoveFunc  then
				self.__longTouchMoveFunc(event)
			end
		elseif(event.name == "ended") then
			self._longTouchEnded = true
			repeatCount = self._longTouchOriginRepeatCount

			--这里必须把2个延时的delayaction干掉 否则 快点的时候 还是会多执行一次 longaction
			if self._delayAction1 then 
				self:stopAction(self._delayAction1)
			end

			if self._delayAction2 then 
				self:stopAction(self._delayAction2)
			end
			
			--新手引导阶段，点击开始和结束必须都在引导区内，否则move时会有bug
	        if (LoginControler:isStartPlay() == true or PrologueUtils:isInPrologue()) and 
	    		TutorialManager.getInstance():isAllFinish() == false and 
	    		 TutorialManager.getInstance():isTutoring() == true and
	    		  TutorialManager.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
	    		return false;
		    elseif BattleTutorialLayer.getInstance():isInTuroring() and 
		            BattleTutorialLayer.getInstance():isInSetTouchClickArea(event.x, event.y, self) == false then 
		        return false;
		    end

			if chk == true and self._longTouchPressed== true then
                if not self.__canLongClick then
                    return 
                end
				
                local tempFunc = function ()
		            self.__canLongClick = true
		        end
		        self.__canLongClick =false
	        	self:delayCall(tempFunc, 0.2)
	        	if self.__longTouchEndFunc then
					self.__longTouchEndFunc(event)
				end

			end
		end
	end

	--只注册一次点击长按事件
	if not (self.__longTouchRepeatFunc or self.__longTouchEndFunc) then
		self.__longTouchBeganFunc = funcs.beganFunc
		self.__longTouchMoveFunc = funcs.moveFunc
		self.__longTouchEndFunc = funcs.endFunc
		self.__longTouchRepeatFunc = funcs.repeatFunc
		self._longTouchRepeatInterval = repeatInterval

		self:addNodeEventListener(cc.NODE_TOUCH_EVENT, longTouchFunc,nil)
		self:setTouchEnabled(true)
		self:setTouchSwallowEnabled(touchSwallowEnabled)
	end

	
end

local angleToPi = math.pi*2 / 360
--获取包含的box区域  是相对于自身的rect
function Node:getContainerBox()
	local size = self:getContentSize()
	local anchor = self:getAnchorPoint()
	local x = -anchor.x *size.width 

	local y = -anchor.y * size.height  
	-- local x = 0
	-- local y = 0
	

	local rect = cc.rect(x,y,size.width,size.height)

	--普通文本单独处理就可以了
	if self.__cname == "TTFLabelExpand" or self.__cname =="RichTextExpand" or self.__cname =="InputExpand"   then
		return rect
	end

	local childArr = self:getChildren()
	for i,v in ipairs(childArr) do

		if v:isVisible() then
			local chldRect = v:getContainerBoxToParent()
			if chldRect.width > 0 and chldRect.height > 0 then
				if rect.width ==0  or rect.height ==0 then
					rect = chldRect
				else
					rect = cc.rectUnion(rect,chldRect)
				end
			end
		end

		
	end
	return rect
end

--获取相对于parent的ContainerBox
function Node:getContainerBoxToParent()
	local rect = rectEx.rectApplyTransform(self:getContainerBox(), self:getParentTransform() ) 
	return rect
end


--获取相对一个node的中心点 
function Node:getCenterPos( )
	local rect = self:getContainerBox()
	return {x = rect.x + rect.width /2,y = rect.y + rect.height/2 }
end


--创建一个椭圆  大致方法和 创建圆类似 参数一样 除了半径不一样
display.newEllipse = function (a,b,params )
	params = checktable(params)

    local function makeVertexs(a,b)
        local segments = params.segments or 180
        local startRadian = 0
        local endRadian = math.pi * 2
        local posX = params.x or 0
        local posY = params.y or 0
        if params.startAngle then
            startRadian = math.angle2radian(params.startAngle)
        end
        if params.endAngle then
            endRadian = startRadian + math.angle2radian(params.endAngle)
        end
        local radianPerSegm = 2 * math.pi / segments
        local points = {}
        for i = 1, segments do
            local radii = startRadian + i * radianPerSegm
            if radii > endRadian then break end
            points[#points + 1] = {posX + a * math.cos(radii), posY + b * math.sin(radii)}
        end
        return points
    end

    local points = makeVertexs(a,b)
    local ellipse = display.newPolygon(points, params)
    if ellipse then
        ellipse.radius_a = a
        ellipse.radius_b = b
        ellipse.params = params

        function ellipse:setRadius(a,b)
            self:clear()
            local points = makeVertexs(a,b)
            display.newPolygon(points, params, self)
        end

        function ellipse:setLineColor(color)
            self:clear()
            local points = makeVertexs(a,b)
            params.borderColor = color
            display.newPolygon(points, params, self)
        end
    end
    return ellipse
end



--转化相对自身某个坐标相对于另外一个node的坐标
function Node:convertLocalToNodeLocalPos(targetNode,pos )
	pos =pos or {x=0,y = 0}
	pos = self:convertToWorldSpaceAR(pos)
	pos = targetNode:convertToNodeSpaceAR(pos)
	return pos
end


--获取相对父亲的 transform
function Node:getParentTransform(  )
	return pc.PCUtils:getNodeToParentTransform(self)
end


--给node注入按钮效果 t 类型  空或者1是 正常按下放大 2是 按下变小 空是没有
-- 同时重写了这个node的 getChildren 和addChild函数
-- 因为层级反生变化,所以 把这个node的所有子对象都显示到 self._childNode里面去了 
-- 但是还是可以链式访问  比如 self.panel_aa.txt_1 ...
function Node:registerBtnEff( t )
	if self.__cname == "BtnExpand" then
		return
	end
	local childNode = display.newNode()
	local rect = self:getContainerBox() 
	self._childNode = childNode

	local childrenArr = self:getChildren()
	for i=1,#childrenArr do
		local childView = childrenArr[i]
		childView:parent(childNode,i)
	end
	

	self.__cname = "BtnExpand"
	
	--属性赋值
	for k,v in pairs(BtnExpand) do
		self[k] = v
	end
	BtnExpand.ctor(self,childNode,nil,nil,rect)
	BtnExpand.setBtnClickEff(self,1)

	--重写addChild 函数 因为层级变了
	self.addChild = function (self,child,zorder, tag   )
		self._childNode:addChild(child,zorder or child:getLocalZOrder(), tag or child:getTag())
	end
	--重写getChildren
	self.getChildren =function ( self )
		return self._childNode:getChildren()
	end

	-- self:setTap(GameVars.emptyFunc)

end


-- 设置点击优先级 或者滚动优先级 非空或者 > 5 表示是可以超过新手引导优先级的
--这个方法原则上不允许使用,特殊情况才能使用,比如日志功能和网络中断
function Node:setClickPriority( value )
	self._clickPriority = value
end

function Node:checkCanClickOnGuide(  )
	if not self._clickPriority then
		return  false
	end
	if self._clickPriority > GameVars.clickPriorityMap.guide then
		return true
	else
		return false
	end

end