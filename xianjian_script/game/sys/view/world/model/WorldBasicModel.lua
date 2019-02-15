--
-- Author: dou
-- Date: 2014-02-28 16:59:55
--

--坐标系暂时采用cocos2d-x的坐标系
local WorldBasicModel = class("WorldBasicModel")

WorldBasicModel.controler =nil 		-- 游戏控制器
WorldBasicModel.myView = nil 		-- 视图  ViewBasic 对象
WorldBasicModel.shade = nil 			-- 影子 ModelShade对象

-- 游戏速度
WorldBasicModel.updateScale =1 		-- 刷新比率  如果scale>1 表示快动作  小于1 表示慢动作
WorldBasicModel.updateCount = 0 		-- 刷新计数 
WorldBasicModel.updateScaleCount = 0 -- 游戏速度
WorldBasicModel.lastScaleTime = -1   -- 加速时间计时

WorldBasicModel.viewScale =  1 		-- 试图的scale
WorldBasicModel.pos = nil 			--坐标 {x,y,z}
WorldBasicModel._isDied = false
WorldBasicModel.way = 1 				--x的运动方向 初始化默认为1 就是朝右的
WorldBasicModel.callFuncArr = nil 	

function WorldBasicModel:ctor( controler )
	--self.countId = 0
 	self.controler = controler
 	self.callFuncArr = {}
 	self.mySize = {width=0,height =0}
 	--现在坐标精简化 
 	self.pos = {x=0,y=0,z=0}	

 	self:registerEvent()
 	self._worldPos = {x=0,y=0}
 	self._sortPos = {x=0,y =0}
end

function WorldBasicModel:registerEvent()
	
end

function WorldBasicModel:initView(ctn,view,xpos,ypos,zpos,size)
	--容器层
	self.viewCtn = ctn
	self.myView = view
	ctn:addChild(self.myView)

	if not size then
		size = {width = 0,height=0}
	end

	self:setViewSize(size)

	if self.myView.doAfterInit then
		self.myView:doAfterInit()
	end
	if xpos and ypos and zpos then
		self:setPos(xpos,ypos,zpos)
	end

	self:updateViewPlaySpeed()
	self:setViewRotation3D()

	return self
end

--[[
	更新视图及size
]]
function WorldBasicModel:updateModelView(view,size)
	if self.myView then
		self:deleteMyView()
		local ctn = self.viewCtn
		self:initView(ctn,view,self.pos.x,self.pos.y,self.pos.y,size)
	end
end

-- 子类需要重写
function WorldBasicModel:checkRoation3DBack()
	return true
end

function WorldBasicModel:setViewRotation3D()
	if self:checkRoation3DBack() and self.controler then
		self.controler:setViewRotation3DBack(self.myView)
	end
end

--设置坐标
function WorldBasicModel:setPos(xpos ,ypos ,zpos  )
	if not xpos then xpos = 0 end
	if not ypos then ypos = 0 end
	if not zpos then zpos = 0 end
	self.pos.x= xpos
	self.pos.y = ypos
	self.pos.z = zpos
	self:realPos()
	return self
end

--设置刷新速度  比如快动作
function WorldBasicModel:setUpdateScale(scale,lastTime)

	lastTime = lastTime or -1

	self.updateScale = scale

	self.lastScaleTime = lastTime

	--初始化scale计数
	self.updateScaleCount = 0
	--更新播放速度
	self:updateViewPlaySpeed()
	
	return self
end

--更新视图速度
function WorldBasicModel:updateViewPlaySpeed( )
	
	if self.myView.setPlaySpeed then
		--让视图设置对应的播放速度
		self.myView:setPlaySpeed(self.updateScale)
	end
end

--设置方位
function WorldBasicModel:setWay( way )
	if not way then
		return
	end

	self.way = way
	if self.myView then
		self:setViewScale(self.viewScale)
	end
end

--设置viewscale
function WorldBasicModel:setViewScale( value )
	self.viewScale = value
	self.myView.currentAni:setScaleX(self.way*self.viewScale )
	self.myView.currentAni:setScaleY(self.viewScale)
end

function WorldBasicModel:setViewSize( viewSize )
	if not self.viewScale then
		self.viewScale = 1
	end
	self.mySize.width = viewSize.width * self.viewScale
	self.mySize.height = viewSize.height * self.viewScale
end

--停止播放动作
function WorldBasicModel:stopFrame(  )
	self.selfPause = true
	self:checkCanPlayView()
end

--恢复播放动作
function WorldBasicModel:playFrame(  )
	self.selfPause = false
	self:checkCanPlayView()
end

--游戏暂停或者播放
function WorldBasicModel:gamePlayOrPause( value )
	self:checkCanPlayView()
end

--场景暂停或者播放
function WorldBasicModel:scenePlayOrPause( value )
	self.scenePause = value
	self:checkCanPlayView()
end

function WorldBasicModel:checkCanPlayView( )

end

--刷新函数
function WorldBasicModel:updateFrame( )

	self:runBySpeedUpdate()
end


--按照加速比率进行刷新
function WorldBasicModel:runBySpeedUpdate( ... )
	if self.isPause then
		return
	end
	
	--更新世界坐标
	self:updateWorldPos()
	self.updateCount = self.updateCount + 1
	--帧事件的控制
	self:dummyFrame()
	self:controlEvent()
	self:updateSpeed()

	self:moveXYZPos()

	-- 回调
	self:updateCallFunc()

	--碰撞检测 碰撞类的重写
	self:checkHit()	
	-- 实现真实坐标body
	self:realPos()

end

function WorldBasicModel:updateWorldPos(  )
	if self.viewCtn then
		-- self._worldPos.x = self.pos.x  
		-- self._worldPos.x = self.pos.y  
		if self.updateCount % 2 ==0 then
			self._worldPos = self.viewCtn:convertToWorldSpaceAR(self.pos);
		end
		
	end
end

--帧事件
function WorldBasicModel:dummyFrame( ... )
end

--一些控制事件 --供子类重写
function WorldBasicModel:controlEvent(  )
end

--更新速度
function WorldBasicModel:updateSpeed( ... )
end

--碰撞检测
function WorldBasicModel:checkHit( ... )
end

--移动坐标
function WorldBasicModel:moveXYZPos( ... )
end




--转换真实坐标
function WorldBasicModel:realPos( )

	--因为这里的坐标系是 暂时用cocos坐标系  和战斗不一样
	if self.myView then
		local xpos = self.pos.x
		local ypos = self.pos.y + self.pos.z
		self.myView:setPosition(xpos,ypos )
	end 

end

function WorldBasicModel:deleteMyView()
	if self.myView and  (not tolua.isnull(self.myView) ) then
		FilterTools.clearFilter( self.myView  )
		if self.myView.deleteMe then
			self.myView:deleteMe()
		else
			self.myView:clear()
		end

		self.myView = nil
	end

	if self.shade then
		self.shade:deleteMe()
	end
end

function WorldBasicModel:deleteMe( ... )
	self._isDied = true
	self:deleteMyView()

	EventControler:clearOneObjEvent(self)
	-- if self.controler then
	-- 	self.controler:clearOneObject(self)
	-- end

	--清除自身的所有计时效果
	-- TimeUtils.clearTimeByObject(self)
	self.controler = nil
	self.viewCtn =nil
	self.callFuncArr = nil
end

function WorldBasicModel:pushOneCallFunc( delayFrame,func,params )
	


	if delayFrame ==0 then
		if type(func) == "string" then
			if params then
				self[func](self,unpack(params))
			else
				self[func](self)
			end
		else
			if params then
				func(unpack(params))
			else
				func()
			end
		end
		
		return
	end

	local info = {
		left = delayFrame,
		func = func,
		params = params,
	}

	--插入到最前面
	table.insert(self.callFuncArr,1, info)
end


function WorldBasicModel:updateCallFunc(  )
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		--@测试
		if not callInfo then
			dump(self.callFuncArr)
			return
		end
		if callInfo.left > 0 then
			callInfo.left = callInfo.left - 1
			
			if callInfo.left ==0 then			
				--必须先移除这个回调信息 因为回调函数里面可能继续有回调
				table.remove(self.callFuncArr,i)
				if type(callInfo.func) == "string" then
					if callInfo.params then
						self[callInfo.func](self,unpack(callInfo.params))
					else
						self[callInfo.func](self)
					end
				else
					if callInfo.params then
						callInfo.func(unpack(callInfo.params))
					else
						callInfo.func()
					end
				end
				
				
			end
		end
	end
end

--重新计算view的scale
function WorldBasicModel:countScale( )
	
	local ypos =self.pos.y 
	local scale = (ypos - Fight.initYpos_2)/ Fight.initScaleSlope + 1 
	self.myView:setScaleY(scale*self.viewScale * Fight.wholeScale)
	self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * scale* Fight.wholeScale)

	--在initYpos2 上的scale是1   initYpos1上的是0.8
end

--判断是否有滤镜样式 供子类重写
function WorldBasicModel:checkHasFilterStyle(  )
	return false
end

--显示或者隐藏view
function WorldBasicModel:setVisible( value )
	self.myView:visible(value)
	if value then
		self:playFrame()
	else
		self:stopFrame()
	end
end

function WorldBasicModel:setZOrder( zorder )
	self.zorder = zorder
	if self.myView then
		self.myView:zorder(zorder)
	end
end

function WorldBasicModel:getZOrder()
	return self.zorder or 0
end

function WorldBasicModel:getSortPos()
	if not self._sortPos then
		self._sortPos = {x= self.pos.x,y = self.pos.y}
	end

	return self._sortPos
end

function WorldBasicModel:getContentSize()
	return self.mySize
end

function WorldBasicModel:setViewZOrder(zorder)
	if self.myView then
		self.myView:zorder(zorder)
	end
end

function WorldBasicModel:getWorldPos()
	
	return self._worldPos
end

function WorldBasicModel:convertToLocalPos(worldPoint)
	local point 
	if self.viewCtn then
		point = self.viewCtn:convertToNodeSpaceAR(worldPoint);
	else 
		point = GameVars.emptyPoint
	end

	return point
end

-- 获取view边界信息
-- 子类需要重写
function WorldBasicModel:getBorderInfo()

	if self._borderInfo then
		return self._borderInfo
	end

	local info = {}
	local minX = -self.mySize.width / 2 - GameVars.UIOffsetX
	local maxX = GameVars.width + self.mySize.width / 2 + GameVars.UIOffsetX
	local minY = -self.mySize.height - GameVars.UIOffsetY
	local maxY = GameVars.height + GameVars.UIOffsetY

	info.minX = minX
	info.maxX = maxX
	info.minY = minY
	info.maxY = maxY
	self._borderInfo = info
	return info
end

-- 是否在屏幕可见范围内
function WorldBasicModel:isInScreen()
	local targetPoint = self:getWorldPos()

	local borderInfo = self:getBorderInfo()

	local minX = borderInfo.minX
	local maxX = borderInfo.maxX
	local minY = borderInfo.minY
	local maxY = borderInfo.maxY

	if targetPoint.x <= minX or targetPoint.x >= maxX 
		or targetPoint.y <= minY or targetPoint.y >= maxY then
		return false
	end

	return true
end

function WorldBasicModel:tostring(  )
	return "className:"..self.__cname .."_pos:"..self.pos.x.."_"..self.pos.y.."_"..self.pos.z
end

return WorldBasicModel