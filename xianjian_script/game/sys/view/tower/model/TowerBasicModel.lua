--
-- Author: dou
-- Date: 2014-02-28 16:59:55
--

--坐标系暂时采用cocos2d-x的坐标系

local TowerBasicModel = class("TowerBasicModel")


-- 指针数据
TowerBasicModel.controler =nil 		-- 游戏控制器
TowerBasicModel.myView = nil 		-- 视图  ViewBasic 对象
TowerBasicModel.shade = nil 			-- 影子 ModelShade对象
TowerBasicModel.effectArr = nil		-- 特效的数组
--[[
shakeInfo = {
		frame = frame, 			--震动帧数
		shakeType = shakeType , --震动类型
		range = 1,  			--震动半径
		
	}

]]
TowerBasicModel.shakeInfo = nil 		--自身震屏信息

TowerBasicModel.depthType = 0 		-- 深度排列的类型 	 同一y下的时候 根据这个决定深度 类型越高越在里面
TowerBasicModel.modelType = 0 		-- model类型 


-- 游戏速度
TowerBasicModel.updateScale =1 		-- 刷新比率  如果scale>1 表示快动作  小于1 表示慢动作
TowerBasicModel.updateCount = 0 		-- 刷新计数 
TowerBasicModel.updateScaleCount = 0 -- 游戏速度
TowerBasicModel.lastScaleTime = -1   -- 加速时间计时

--各种暂停
TowerBasicModel.skillPause = false 	-- 技能导致暂停  
TowerBasicModel.selfPause = false 	-- 代码暂停


--[[
	StillInfo = class("StillInfo")
	StillInfo.time =0
	StillInfo.type = 0    	-- 1是普通硬直 2是抖动硬直
	StillInfo.x =0 			-- 记录当前的硬直抖动x范围
	StillInfo.y = 0 		-- y范围
	StillInfo.r =1 			-- 如果是抖动硬直的 那么就有一个抖动半径 默认只x方向抖动

]]--
TowerBasicModel.viewScale =  1 		-- 试图的scale

--坐标和层级
TowerBasicModel.__zorder = 0 		-- zorder
TowerBasicModel.pos = nil 			--坐标 {x,y,z}

TowerBasicModel._isDied = false

--战队信息
TowerBasicModel.initCamp = nil  		--初始阵营,需要记录这个值 如果我方某个人被魅惑了 那么这个人是不能被攻击的 

TowerBasicModel.camp = 1 			--阵营
TowerBasicModel.way = 1 				--x的运动方向 初始化默认为1 就是朝右的

TowerBasicModel.campArr=nil 			--我的阵营队伍
TowerBasicModel.toArr = nil 			--敌人阵营数组  如果以后扩展多方阵营 那么会 扩展 更多toArr   和campArr 
TowerBasicModel.callFuncArr = nil 	

TowerBasicModel._viewScale = 1 		--视图缩放系数 

function TowerBasicModel:ctor( controler )
	--self.countId = 0
 	self.controler = controler
 	self.effectArr = {}
 	self.callFuncArr = {}
 	
 	self.stillInfo =  {time =0,type=0,x=0,y=0,r=1}    -- 初始化硬直信息
 	--现在坐标精简化 
 	self.pos = {x=0,y=0,z=0}	

 	self:registerEvent()
end

function TowerBasicModel:registerEvent()
	
end

function TowerBasicModel:initView(ctn,view,xpos,ypos,zpos,size)
	
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

	if self.modelType == Fight.modelType_heroes then
		if self.data.viewScale then
			local viewScale = self.data:viewScale() or 100
			self:setViewScale(viewScale/100)
		end
	end

	self:registerEvent()
	self:onInitViewComplete()
	
	return self
end

-- 当view创建完成
function TowerBasicModel:onInitViewComplete()

end

--设置坐标
function TowerBasicModel:setPos(xpos ,ypos ,zpos  )
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
function TowerBasicModel:setUpdateScale(scale,lastTime)

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
function TowerBasicModel:updateViewPlaySpeed( )
	
	if self.myView.setPlaySpeed then
		--让视图设置对应的播放速度
		self.myView:setPlaySpeed(self.updateScale)
	end
end

--设置方位
function TowerBasicModel:setWay( way )
	if not way then
		return
	end

	self.way = way
	if self.myView then
		self:setViewScale(self.viewScale)
	end
end

--设置viewscale
function TowerBasicModel:setViewScale( value )
	self.viewScale = value
	self.myView.currentAni:setScaleX(self.way*self.viewScale )
	self.myView.currentAni:setScaleY(self.viewScale)

	self:setViewSize(self.mySize)
end

function TowerBasicModel:getViewScale( )
	return self.viewScale or 1
end

function TowerBasicModel:setViewSize( viewSize )
	self.mySize = table.copy(viewSize)
	if not self.viewScale then
		self.viewScale = 1
	end

	self.mySize.width = self.mySize.width * self.viewScale
	self.mySize.height = self.mySize.height * self.viewScale
end

--停止播放动作
function TowerBasicModel:stopFrame(  )
	self.selfPause = true
	self:checkCanPlayView()
end

--恢复播放动作
function TowerBasicModel:playFrame(  )
	self.selfPause = false
	self:checkCanPlayView()
end

--游戏暂停或者播放
function TowerBasicModel:gamePlayOrPause( value )
	self:checkCanPlayView()
end

--场景暂停或者播放
function TowerBasicModel:scenePlayOrPause( value )
	self.scenePause = value
	self:checkCanPlayView()
end



--震屏
--[[
	frame  震屏时间
	range 震屏力度
	shakeType 震屏类型 x震屏 y震屏 xy震屏
]]
function TowerBasicModel:shake( frame,range,shakeType  )
	
	self.controler.layer:shake(frame,range,shakeType)
end	


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


--刷新函数
function TowerBasicModel:updateFrame( )

	local lastCount

	if self.lastScaleTime > 0 then
		self.lastScaleTime = self.lastScaleTime -1
		if self.lastScaleTime ==0 then
			self:setUpdateScale(1, -1)
		end
	end


	if self.updateScale == 1 then
		self:runBySpeedUpdate()
	--如果是降速的
	elseif self.updateScale < 1 then
		--判断多少帧刷新一次函数
		lastCount = math.round(self.updateScaleCount)
		self.updateScaleCount = self.updateScaleCount + self.updateScale
		if math.round(self.updateScaleCount) > lastCount then
			--如果是达到一次计数了 那么就做一次刷新函数
			self:runBySpeedUpdate()
		end
	else
		--先计算需要刷新多少次
		local count = math.floor(self.updateScale)
		for i=1,count do
			self:runBySpeedUpdate()
		end

		local leftCount = self.updateScale - count
		self.updateScaleCount = self.updateScaleCount+ count
		--如果不是整数倍数加速
		if leftCount > 0 then
			lastCount = math.round(self.updateScaleCount)
			self.updateScaleCount = self.updateScaleCount + leftCount

			--如果四舍五入后达到一次计数了 那么就做一次刷新函数
			if math.round(self.updateScaleCount) > lastCount then
				self:runBySpeedUpdate()
			end
		end
	end
end


--按照加速比率进行刷新
function TowerBasicModel:runBySpeedUpdate( ... )

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

--硬直事件
function TowerBasicModel:myStillMoment( ... )
	if self.stillInfo.time <=0 then
		return
	end

	self.stillInfo.time = self.stillInfo.time-1
	if self.stillInfo.time> 0 then
		self:still()
	else
		self:outStill()
	end
end

--硬直事件
function TowerBasicModel:still()
	local stillInfo = self.stillInfo
	--如果硬直类型是0 也就是停止不动的 那么就不管
	if stillInfo.type == 0 then
		return
	end

	if stillInfo.type == 1 then
		stillInfo.x = (stillInfo.time %2 *2 -1) * stillInfo.r
	elseif stillInfo.type == 2 then
		stillInfo.y = (stillInfo.time %2 *2 -1) * stillInfo.r
	elseif stillInfo.type == 3 then
		stillInfo.x = (stillInfo.time %2 *2 -1) * stillInfo.r
		stillInfo.y = (stillInfo.time %2 *2 -1) * stillInfo.r
	end
end

--跳出硬直
function TowerBasicModel:outStill(  )
	self.stillInfo.time =0
	self:checkCanPlayView()
end

--设置硬直
--[[
	StillInfo = class("StillInfo")
	StillInfo.time =0
	StillInfo.type = 0    -- 0是普通硬直 1是x抖动硬直 2y抖动硬直 3xy抖动硬直
	StillInfo.x =0 	--记录当前的硬直抖动x范围
	StillInfo.y = 0 	--y范围
	StillInfo.r =1 			--如果是抖动硬直的 那么就有一个抖动半径 默认只x方向抖动

]]--
function TowerBasicModel:setStill(time,type,x,y,r )
	self.stillInfo.time = time or 0
	self.stillInfo.type = type or 0
	self.stillInfo.x = x or 0
	self.stillInfo.y = y or 0
	self.stillInfo.r = r or 0
	self:checkCanPlayView()
end

function TowerBasicModel:isStill(  )
	return  false
end

--抖动 	持续帧  力度    震屏方式 1,x 2,y 3 xy 方向震动
function TowerBasicModel:selfShake( frame,range,shakeType )
	
	range = range and range or 2
	frame = frame and frame or 6
	shakeType = shakeType and shakeType or "xy"
	self.shakeInfo = {
		frame = frame,
		shakeType = shakeType 
	}
	if shakeType == "x" then
		self.shakeInfo.range = {range,0}
	elseif shakeType == "y" then
		self.shakeInfo.range = {0,range}
	else
		self.shakeInfo.range = {range,range}
	end
end


--帧事件
function TowerBasicModel:dummyFrame( ... )
end

--一些控制事件 --供子类重写
function TowerBasicModel:controlEvent(  )
end

--更新速度
function TowerBasicModel:updateSpeed( ... )
end

--碰撞检测
function TowerBasicModel:checkHit( ... )
end

--移动坐标
function TowerBasicModel:moveXYZPos( ... )
end




--转换真实坐标
function TowerBasicModel:realPos( )

	local xpos = self.pos.x
	local ypos = self.pos.y + self.pos.z

	if self.shakeInfo then
		self.shakeInfo.frame = self.shakeInfo.frame-1

		local pianyi = (self.shakeInfo.frame %2 *2 -1 )
		xpos = xpos + pianyi*self.shakeInfo.range[1]
		ypos = ypos + pianyi*self.shakeInfo.range[2]

		if self.shakeInfo.frame == 0 then
			self.shakeInfo = nil
		end
	end

	--因为这里的坐标系是 暂时用cocos坐标系  和战斗不一样
	if self.myView then
		self.myView:setPosition(math.round(xpos),math.round(ypos) )
	end 

end


function TowerBasicModel:deleteMe( ... )
	self._isDied = true


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

	EventControler:clearOneObjEvent(self)
	-- if self.controler then
	-- 	self.controler:clearOneObject(self)
	-- end

	--清除自身的所有计时效果
	-- TimeUtils.clearTimeByObject(self)
	-- self.controler = nil
	-- self.viewCtn = nil
	self.callFuncArr = nil
end



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------





function TowerBasicModel:pushOneCallFunc( delayFrame,func,params )
	


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


function TowerBasicModel:updateCallFunc(  )
	if not self.callFuncArr then
		return
	end

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

----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
--重新计算view的scale
function TowerBasicModel:countScale( )
	
	local ypos =self.pos.y 
	local scale = (ypos - Fight.initYpos_2)/ Fight.initScaleSlope + 1 
	self.myView:setScaleY(scale*self.viewScale * Fight.wholeScale)
	self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * scale* Fight.wholeScale)

	--在initYpos2 上的scale是1   initYpos1上的是0.8
end




--闪光
function TowerBasicModel:flash(time,interval, color  )
	
	--如果身上有滤镜样式  不执行
	if self:checkHasFilterStyle() then
		return 
	end

	time = time or 10
	interval = interval or 3
	color = "red"
	FilterTools.flash_colorTransform(self.myView,time,interval,color)
end

--判断是否有滤镜样式 供子类重写
function TowerBasicModel:checkHasFilterStyle(  )
	return false
end


--创建残影 组
function TowerBasicModel:createGhostGroup(times,interval, offset, zorder,ctn ,alpha, lastTime)
	if not self.myView then
		return
	end

	local tempFunc = function (  )
		local node = self:createGhost(self.pos.x+30*offset,-self.pos.y,zorder,ctn,alpha, lastTime)
		node:setScaleX(self.controler._mirrorPos*self.way)
	end

	for i=1,times do	
		self.myView:delayCall(tempFunc,interval*i)
	end
	tempFunc()
end


--创建残影
function TowerBasicModel:createGhost( x, y, zorder,ctn ,alpha, lastTime)
	alpha = alpha or 0.3
	lastTime = lastTime or 0.2
	x = x or self.pos.x-30*self.way
	y = y or -self.pos.y
	local ghostNode = pc.PCNode2Sprite:getInstance():spriteCreate(self.myView.currentAni)
	ghostNode:pos(x,y)
    ghostNode:setCascadeOpacityEnabled(true)
    ghostNode:setOpacity(alpha *  255)
    ghostNode:anchor(0.5,0)
    ghostNode:addto(ctn):zorder(zorder or 0)

    local call = function (  )
        ghostNode:removeFromParent(true)
    end

    --
    local act_alpha = cc.FadeTo:create(lastTime,0)
    local act_call = cc.CallFunc:create(call)

    local seq = cc.Sequence:create({act_alpha,act_call})
    ghostNode:runAction(seq)

    return ghostNode
end

--显示或者隐藏view
function TowerBasicModel:setVisible( value )
	self.myView:visible(value)
	if value then
		self:playFrame()
	else
		self:stopFrame()
	end
end

function TowerBasicModel:setZOrder( zorder )
	self.zorder = zorder
	if self.myView then
		self.myView:zorder(zorder)
	end
end

function TowerBasicModel:getZOrder( )
	return self.zorder
end

function TowerBasicModel:getSortPos()
	return self.pos
end

function TowerBasicModel:getContentSize()
	return self.mySize
end

function TowerBasicModel:tostring(  )
	return "className:"..self.__cname .."_pos:"..self.pos.x.."_"..self.pos.y.."_"..self.pos.z
end

return TowerBasicModel