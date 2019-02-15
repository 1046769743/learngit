--
-- Author: dou
-- Date: 2014-02-28 16:59:55
--

--坐标系暂时采用cocos2d-x的坐标系
local Fight = Fight
local table = table

ModelBasic = class("ModelBasic")


-- 指针数据
ModelBasic.controler =nil 		-- 游戏控制器
ModelBasic.myView = nil 		-- 视图  ViewBasic 对象
ModelBasic.shade = nil 			-- 影子 ModelShade对象
ModelBasic.effectArr = nil		-- 特效的数组
--[[
shakeInfo = {
		frame = frame, 			--震动帧数
		shakeType = shakeType , --震动类型
		range = 1,  			--震动半径
		
	}

]]
ModelBasic.shakeInfo = nil 		--自身震屏信息

ModelBasic.depthType = 0 		-- 深度排列的类型 	 同一y下的时候 根据这个决定深度 类型越高越在里面
ModelBasic.modelType = 0 		-- model类型 
ModelBasic.initCamp = nil  		--初始阵营,需要记录这个值 如果我方某个人被魅惑了 那么这个人是不能被攻击的 

ModelBasic.protectTime = nil   	--保护值,在这个时间内 是不受任何打断影响 

-- 游戏速度
ModelBasic.updateScale =1 		-- 刷新比率  如果scale>1 表示快动作  小于1 表示慢动作
ModelBasic.updateCount = 0 		-- 刷新计数 
ModelBasic.updateScaleCount = 0 -- 游戏速度
ModelBasic.lastScaleTime = -1   -- 加速时间计时

--各种暂停
ModelBasic.skillPause = false 	-- 技能导致暂停  
ModelBasic.selfPause = false 	-- 代码暂停

--在队伍数组中的位置
ModelBasic._campIdx = nil -- 在队伍中的索引

--[[
	StillInfo = class("StillInfo")
	StillInfo.time =0
	StillInfo.type = 0    	-- 1是普通硬直 2是抖动硬直
	StillInfo.x =0 			-- 记录当前的硬直抖动x范围
	StillInfo.y = 0 		-- y范围
	StillInfo.r =1 			-- 如果是抖动硬直的 那么就有一个抖动半径 默认只x方向抖动

]]--
ModelBasic.diedInfo = nil 		-- 死亡信息
ModelBasic.viewScale =  1 		-- 试图的scale
ModelBasic.stillInfo = nil 		-- 初始化硬直信息

--坐标和层级
ModelBasic.__zorder = 0 		-- zorder
ModelBasic.pos = nil 			--坐标 {x,y,z}
ModelBasic._initPos = nil 		--初始位置

ModelBasic._isDied = false

--战队信息
ModelBasic.camp = 1 			--阵营
ModelBasic.way = 1 				--x的运动方向 初始化默认为1 就是朝右的

ModelBasic.campArr=nil 			--我的阵营队伍
ModelBasic.toArr = nil 			--敌人阵营数组  如果以后扩展多方阵营 那么会 扩展 更多toArr   和campArr 
ModelBasic.callFuncArr = nil 	

ModelBasic._viewScale = 1 		--视图缩放系数 

function ModelBasic:ctor( controler,obj )
	--self.countId = 0
 	self.controler = controler
 	self.logical = controler.logical
 	self.triggerSkillControler = controler.triggerSkillControler

 	if self.modelType == Fight.modelType_heroes or self.modelType == Fight.modelType_missle then
 		self.controler._countId = self.controler._countId + 1
 		self.countId = self.controler._countId
 	end

 	self.diedInfo = {t=Fight.diedType_disappear,canDo = false} --死亡方式  如果是透明度下降死亡 那么 在2秒内消失

 	self.effectArr = {}
 	self.callFuncArr = {}
 	
 	self.stillInfo =  {time =0,type=0,x=0,y=0,r=1}    -- 初始化硬直信息
 	--现在坐标精简化 
 	self.pos = {x=0,y=0,z=0}	
 	self._initPos = {x=0,y=0,z=0}
 	self._campIdx = 1


 	if obj then
	 	self:initData(obj)
 	end
end


function ModelBasic:getViewData(obj)
	if Fight.isDummy  then
		self.viewData = {}
		return
	end
	if self.modelType == Fight.modelType_summon then
		self.viewData  = FrameDatas.getSummonViewData(obj.curArmature)
	elseif self.modelType == Fight.modelType_heroes then
		if not obj.curArmature then
			echo("___________法宝没有配置spine名字",obj._curTreasureHid,obj.curArmature )
		end
		self.viewData =  FrameDatas.getViewData(true, obj.curArmature )
	else
		self.viewData =  FrameDatas.getViewData(false, obj.curArmature )
	end
	--dump(self.viewData)
end

--初始化数据
function ModelBasic:initData( obj )
	self.data = obj
	self:getViewData(obj)	
	return self
end

--设置死亡方式
function ModelBasic:setDiedType( t )
	self.diedInfo.t = t
	if t == Fight.diedType_alpha  then
		self.diedInfo.lastFrame = 20
		self.diedInfo.count = self.diedInfo.lastFrame 
		self.diedInfo.zhenfu = 0.1
	elseif t == Fight.diedType_alphades  then
		self.diedInfo.lastFrame = 20
		self.diedInfo.count = self.diedInfo.lastFrame 
	elseif t == Fight.diedType_delayalphades then
		self.diedInfo.t = Fight.diedType_alphades -- 实际死亡方式和 Fight.diedType_alphades 一致
		self.diedInfo.lastFrame = 20 + Fight.dieDelayFrame
		self.diedInfo.count = self.diedInfo.lastFrame 
	else
		self.diedInfo.lastFrame = 1
		self.diedInfo.count = self.diedInfo.lastFrame 
	end
end

--设置阵营-   isInit 是否是初始化阵营 
function ModelBasic:setCamp( value,isInit )
	if isInit then
		self.initCamp = value
	end
	self.camp = value
	local controler = self.controler
	if value ==1 then
		self.toCamp = 2
		self.campArr = controler.campArr_1
		self.toArr  = controler.campArr_2
		self.way = 1
		self.diedArr = controler.diedArr_1
		self.toDiedArr = controler.diedArr_2
	elseif value ==2 then
		self.toCamp = 1
		self.campArr = controler.campArr_2
		self.toArr  = controler.campArr_1
		self.diedArr = controler.diedArr_2
		self.toDiedArr = controler.diedArr_1
		self.way = -1
	end
	-- 设置方向
	self:setWay(self.way)
end

function ModelBasic:changeView(viewName)
	if Fight.isDummy then
		return
	end

	if not self.myView or tolua.isnull(self.myView) then
		return
	end

	local spbName = viewName
	if viewName == "0" then
		viewName = self.data.defArmature
		spbName = self.data.defSpbName
	end

	
		
	local oldZorder = self.myView:getLocalZOrder()

	--因为换视图需要重新获取一下动作的帧数据
	self.viewData =  FrameDatas.getViewData(true, viewName )
	-- 快速跳过时并不真正创建资源
	if not (self.controler and self.controler:isQuickRunGame()) then

		if self._viewName ~= viewName then
			-- echoError("changeVew",viewName,self._viewName)
			local view = ViewSpine.new(spbName,{},nil,viewName)
			local old = self.myView 
			self.myView = view

			self.viewCtn:addChild(view)
			view:zorder(oldZorder)
			self:setViewScale(self.viewScale)
			-- 继续当前的动作,
			view:playLabel(self.data.sourceData.stand)
			view:gotoAndPlay(1)
			self:updateViewPlaySpeed()
			-- 透明度同步
			view:opacity(old:getOpacity())
			old:deleteMe()
			self._viewName = viewName
		end
		
	end
	

	-- 更新一下大小和朝向
	self:countScale()
	self:realPos()
end


function ModelBasic:initView(ctn,view,xpos,ypos,zpos )
	if Fight.isDummy then
		return
	end
	--容器层
	self.viewCtn = ctn
	self.myView = view
	ctn:addChild(self.myView)

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
			self._viewScale = self.viewScale
		end
		self._viewName = self.data.curSpbName
	end

	return self
end

-- 设置初始坐标
function ModelBasic:setInitPos(initPos)
	if not initPos then return end
	self._initPos.x = initPos.x or self._initPos.x
	self._initPos.y = initPos.y or self._initPos.y
	self._initPos.z = initPos.z or self._initPos.z
end

-- 当前是否在初始位置
function ModelBasic:isAtInitPos()
	return self.pos.x == self._initPos.x and self.pos.y == self._initPos.y and self.pos.z == self._initPos.z
end

--设置坐标
function ModelBasic:setPos(xpos ,ypos ,zpos  )
	if Fight.isDummy then
		return
	end
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
function ModelBasic:setUpdateScale(scale,lastTime)

	lastTime = lastTime or -1

	self.updateScale = scale

	self.lastScaleTime = lastTime

	--初始化scale计数
	self.updateScaleCount = 0
	--更新播放速度
	self:updateViewPlaySpeed()
	--更新特效播放速度
	self:updateEffPlaySpeed()

	return self
end

-- 获取刷新速度
function ModelBasic:getUpdateScale()
	return self.updateScale
end

--更新视图速度
function ModelBasic:updateViewPlaySpeed( )
	if Fight.isDummy then
		return self
	end
	if not self.myView then
		echo(self.__cname,"___aaaaaa")
		echo(self.data.hid,"__dathid")
		return
	end

	--如果是快进的
	if self.controler:isQuickRunGame() then
		return
	end

	if self.myView.setPlaySpeed then
		--让视图设置对应的播放速度
		self.myView:setPlaySpeed(self.updateScale*self.controler.updateScale)
	end
end

-- 更新特效速度
function ModelBasic:updateEffPlaySpeed()
	if Fight.isDummy then
		return
	end
	if self.effectArr then
		for animName,eff in pairs(self.effectArr) do
			if not self._isDied and eff.setPlaySpeed then
				eff:setPlaySpeed(self.updateScale)
			end
		end
	end
end

--设置方位
function ModelBasic:setWay( way )
	if not way then
		return
	end

	self.way = way
	if self.myView then
		self:setViewScale(self.viewScale)
	end
end

--设置viewscale
function ModelBasic:setViewScale( value, dur )
	if self.viewScale == value then return end
	self.viewScale = value
	if Fight.isDummy  then
		return
	end
	if not self.myView then
		return
	end
	if self.isWholeEff then
		return
	end
	-- self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * Fight.wholeScale)
	-- self.myView:setScaleY(value* Fight.wholeScale)

	local dur = dur or 0

	local tSX = self.controler._mirrorPos*self.way*self.viewScale * Fight.wholeScale
	local tSY = value* Fight.wholeScale

	if dur == 0 then
		self.myView:stopAllActions()
		self.myView:setScale(tSX, tSY)
		
		if self.effectArr and not self._isDied then
			for animName,eff in pairs(self.effectArr) do
				eff:setViewScale(value)
			end
		end
	else
		local time = dur / GameVars.GAMEFRAMERATE
		self.myView:stopAllActions()
		self.myView:runAction(cc.ScaleTo:create(time, tSX, tSY))

		if self.effectArr and not self._isDied then
			for animName,eff in pairs(self.effectArr) do
				eff:stopAllActions()
				eff:runAction(cc.ScaleTo:create(time, tSX, tSY))
			end
		end
	end
end


--停止播放动作
function ModelBasic:stopFrame(  )
	self.selfPause = true
	self:checkCanPlayView()
end

--恢复播放动作
function ModelBasic:playFrame(  )
	self.selfPause = false
	self:checkCanPlayView()
end

--游戏暂停或者播放
function ModelBasic:gamePlayOrPause( value )
	self:checkCanPlayView()
end

--场景暂停或者播放
function ModelBasic:scenePlayOrPause( value )
	self.scenePause = value
	self:checkCanPlayView()
end

--设置技能导致暂停
function ModelBasic:setSkillPause(value  )
	self.skillPause = value
	self:checkCanPlayView()
end

--能否播放动画
function ModelBasic:checkCanPlayView( outAction  )
	
	if not self.myView then
		return false
	end
	if self.controler:isQuickRunGame() then
		return false
	end
	local result = true
	--如果是硬直期间
	if self.stillInfo.time ~= 0 then
		result = false
	end

	--如果是游戏暂停的
	if self.controler._gamePause  then
		result = false
	end
	--如果是技能播放暂停的
	if self.skillPause then
		result = false
	end

	--如果是代码控制暂停
	if self.selfPause then
		result =false
	end

	--如果是场景暂停
	if self.controler.scenePause then
		result =false
	end

	if not self.myView.play then
		return result
	end
	
	if outAction then
		return result
	end
	
	if result then
		self.myView:play()
	else
		self.myView:stop()
	end
	

	return result
end

--震屏
--[[
	frame  震屏时间
	range 震屏力度
	shakeType 震屏类型 x震屏 y震屏 xy震屏
]]
function ModelBasic:shake( frame,range,shakeType  )
	if Fight.isDummy  then
		return
	end
	self.controler.layer:shake(frame,range,shakeType)
end	

--播放声音
function ModelBasic:sound( soundName )	
end


----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------


--刷新函数
function ModelBasic:updateFrame( )
	--如果是正常速度
	--如果是 技能暂停
	if self.skillPause then
		return
	end



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
			if not self._isDied then
				self:runBySpeedUpdate()
			else
				break
			end
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
function ModelBasic:runBySpeedUpdate( ... )

	self.updateCount = self.updateCount + 1

	if not self.diedInfo.canDo and not Fight.isDummy then
		local stillInfo = self.stillInfo
		if(stillInfo.time ~= 0) then self:myStillMoment() end

		--判断帧事件 ----
		--以下很多事件都必须是在非硬直状态下执行的
		
		--帧事件的控制
		-- if (stillInfo.time ==0) then	self:dummyFrame()end
		self:dummyFrame()

		----先是自我控制 
		-- if (stillInfo.time ==0) then self:controlEvent() end
		self:controlEvent()

		--更新速度
		-- if (stillInfo.time ==0) then self:updateSpeed() end
		self:updateSpeed()

		--碰撞检测 碰撞类的重写
		self:checkHit()	
		
		self:moveXYZPos()

		-- 回调
		--更新透明度状态
		-- self:updateOpacity()

		-- 实现真实坐标body
		if self.controler and not self.controler:isQuickRunGame() then 
			self:realPos()
		end
		
		
	end

	-- self:updateCallFunc()

	-- if self.ttttt == true then
	-- 	echo("____pos__222____________",self.controler.updateCount,self.pos.x,self.speed.x)
	-- 	self.ttttt = false
	-- end

	

	--做死亡函数
	self:doDiedFunc()
	
end

--硬直事件
function ModelBasic:myStillMoment( ... )
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
function ModelBasic:still()
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
function ModelBasic:outStill(  )
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
function ModelBasic:setStill(time,type,x,y,r )
	self.stillInfo.time = time or 0
	self.stillInfo.type = type or 0
	self.stillInfo.x = x or 0
	self.stillInfo.y = y or 0
	self.stillInfo.r = r or 0
	self:checkCanPlayView()
end

function ModelBasic:isStill(  )
	return  false
end

--抖动 	持续帧  力度    震屏方式 1,x 2,y 3 xy 方向震动
function ModelBasic:selfShake( frame,range,shakeType )
	
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
function ModelBasic:dummyFrame( ... )
end

--一些控制事件 --供子类重写
function ModelBasic:controlEvent(  )
end

--更新速度
function ModelBasic:updateSpeed( ... )
end

--碰撞检测
function ModelBasic:checkHit( ... )
end

--移动坐标
function ModelBasic:moveXYZPos( ... )
end




--转换真实坐标
function ModelBasic:realPos( )

	local xpos = self.pos.x
	local ypos = self.pos.y + self.pos.z


	-- if self.stillInfo.type ~= 0 then
	-- 	xpos = xpos + self.stillInfo.x
	-- 	ypos = ypos + self.stillInfo.y
	-- end

	-- 如果是镜像站位就要计算位置
	if self.controler and self.controler._mirrorPos == -1 then
		xpos = GameVars.gameResWidth - xpos
	end

	if self.shakeInfo then
		self.shakeInfo.frame = self.shakeInfo.frame-1

		local pianyi = (self.shakeInfo.frame %2 *2 -1 )
		xpos = xpos + pianyi*self.shakeInfo.range[1]
		ypos = ypos + pianyi*self.shakeInfo.range[2]

		if self.shakeInfo.frame == 0 then
			self.shakeInfo = nil
		end
	end

	--因为这里的坐标系是 参考flash坐标系
	if self.myView then
		self.myView:setPosition(math.round(xpos * Fight.screenScaleX),math.round(-ypos) )
	end 

	-- 需要影子配合
	if self.shade then
		self.shade:updateFrame()
	end
end

--开始死亡
function ModelBasic:startDoDiedFunc( diedType )
	if Fight.isDummy  then
		self:deleteMe()
		return
	end
	self:stopFrame()

	diedType = diedType or Fight.diedType_disappear 
	self:setDiedType(diedType)
	self.diedInfo.canDo = true
	
	--FilterTools.setViewFilter(self.myView,FilterTools.colorMatrix_gray)
end

--开始执行死亡方式
function ModelBasic:doDiedFunc(  )	
	--如果是透明度下降死亡
	if not self.diedInfo.canDo  then
		return
	end
	if Fight.isDummy then
		self:deleteMe()
		return
	end

	--如果是 闪现透明度下降死亡
	if self.diedInfo.t == Fight.diedType_alpha  then
		if self.myView then
			local targetAlpha= self.diedInfo.count/self.diedInfo.lastFrame
			if self.diedInfo.count %4 == 0 then
				self.myView:opacity ((targetAlpha + self.diedInfo.zhenfu)*255 )
			elseif self.diedInfo.count %4 == 2 then
				self.myView:opacity((targetAlpha - self.diedInfo.zhenfu) *255)
			end
		end
	elseif self.diedInfo.t == Fight.diedType_alphades  then
		if self.myView then
			local targetAlpha= self.diedInfo.count/self.diedInfo.lastFrame
			if self.diedInfo.count %4 == 0 then 
				self.myView:opacity(targetAlpha *255)
				
				-- 影子也需要渐隐消息
				if self.shade then
					self.shade.myView:opacity(targetAlpha *255)
				end
			end
		end
	-- else
	-- 	self:deleteMe()
	end

	self.diedInfo.count = self.diedInfo.count -1

	--如果为0了  那么消失
	if self.diedInfo.count <=0 then
		self:deleteMe()
	end

end

--[[
	设置透明度的方法
	targetOpacity 目标透明度
	dur 持续时间frame
]]
function ModelBasic:setOpacity( targetOpacity, dur)
	if Fight.isDummy or not self.myView then return end
	local dur = dur or 0

	if dur == 0 then
		self.myView:stopAllActions()
		self.myView:opacity(targetOpacity)
		if self.effectArr and not self._isDied then
			for animName,eff in pairs(self.effectArr) do
				eff:setOpacity(targetOpacity)
			end
		end
	else
		local time = dur / GameVars.GAMEFRAMERATE
		self.myView:stopAllActions()
		self.myView:runAction(cc.FadeTo:create(time, targetOpacity))
		if self.effectArr and not self._isDied then
			for animName,eff in pairs(self.effectArr) do
				eff:stopAllActions()
				eff:runAction(cc.FadeTo:create(time, targetOpacity))
			end
		end
	end
end

--重写一个 runAction方法
function ModelBasic:runAction( ... )
	if not self._isDied then
		if self.myView then
			self.myView:runAction(...)
		end
	end
end

-- 重写一个 stopAllActions方法
function ModelBasic:stopAllActions( ... )
	if not self._isDied then
		if self.myView then
			self.myView:stopAllActions(...)
		end
	end
end

function ModelBasic:deleteMe( ... )
	if self._isDied then
		echoError("_为什么还走到这里来了")
		return
	end
	self._isDied = true

	if self.data and self.data.clear then
		self.data:clear()
	end

	if self.talkBubble then
		self.talkBubble:deleteMe()
		self.talkBubble = nil
	end
	-- 清除大招激活的周身特效
	if self.followActionAniObj then
		for k,aniArr in pairs(self.followActionAniObj) do
			for i,v in pairs(aniArr) do
				if not v._isDied then
					v:deleteMe()
				end
			end
		end
	end

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

	if self.controler then
		self.controler:clearOneObject(self)
	end

	FightEvent:clearOneObjEvent(self)
	--清除自身的所有计时效果
	-- TimeUtils.clearTimeByObject(self)
	self.controler = nil
	self.campArr = nil
	self.toArr = nil
	self.viewCtn =nil
	self.callFuncArr = nil
end



----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------
----------------------------------------------------------------------------------



--创建生命条
function ModelBasic:createHealthBar(x,y ,ctn,kind)
	kind = kind  or 2
	local _x = x and x or 0
	local _y = y and y or 0
	self.healthBar = ViewHealthBar.new( kind ):addto(ctn)
	self.healthBarPos = {x=_x,y = _y,z= Fight.zorder_health}
	self.healthBar:setTarget(self,kind)
	
	-- 创建战斗内弹框用(可以借用在这里创建)
	self.talkBubble = ViewTalkBubble.new(kind):addto(ctn)
	self.talkBubble:setTarget(self,kind)
end


--创建特效数组 effArr,配表特效数组格式 	isCycle是否循环  effArr target
function ModelBasic:createEffGroup( effArr,isCycle ,isBeUsed,target)
	local arr = {}
	local eff 
	if Fight.isDummy  then
		return
	end
	if not effArr then
		return
	end
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame()  then
		return
	end


	local isDebug = DEBUG 

	for i,v in ipairs(effArr) do

		--进行错误检查
		if isDebug then
			if v.l ~= -1 and v.l ~= -2 and v.l ~= 1 and v.l ~= 2 then
				echoWarn("特效层次配置错误,effName:%s,_layer:%d,hid:%s",tostring(v.name),v.l,self.data.hid)
			end
		end

		if isCycle then
			eff  = self:createEff(v.n,tonumber(v.x),tonumber(v.y),v.l,nil,true,v.f,isCycle,v.b,isBeUsed,target)
		else
			eff  = self:createEff(v.n,tonumber(v.x),tonumber(v.y),v.l,nil,nil,v.f,isCycle,v.b,isBeUsed,target)
		end
		
		table.insert(arr, eff)
	end

	return arr

end


local xxcount = 0
--创建打击特效  coeffX,coeffY 比例系数
--isBeUsed 是否是被作用的特效  
function ModelBasic:createEff( animation,coeffX, coeffY, showZorder, way, canRepeat,isFollow,isCycle,boneName,isBeUsed,target)
	if Fight.isDummy then
		return
	end
	
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame()  then
		return
	end

	if self._isDied then
		return
	end
	
	showZorder= showZorder or 1

	if not canRepeat then
		if self.effectArr[animation] then
			self.effectArr[animation].myView:gotoAndPlay(1)	
			self.effectArr[animation].updateCount = 1
			-- 更新一下位置
			self:_updateEffPos(self.effectArr[animation], true)

			return self.effectArr[animation]
		end
	end

	local ani = nil
	local pery = coeffY and coeffY/100 or Fight.hit_position
	coeffX = coeffX and coeffX/100 or 0
	local eff 
	eff = ModelEffectBasic.new(self.controler,nil)
	way = way or self.way

	eff:setIsCycle(isCycle,nil)
	--如果是有跟随骨头的
	if boneName and boneName ~= "n" then
		eff:setFollowBoneName(boneName)
	else
		-- boneName = "foot"
	end

	

	ani = eff:getAniByType(animation,isCycle,target)
	local xpos = self.pos.x + self.data.viewSize[1]*coeffX * (-way)
	local ypos = self.pos.y  
	local zpos = self.pos.z - self.data.viewSize[2]*pery 
	
	-- 特殊判定  -2 表示是放在全屏中心的特效
	if coeffY  == -2 then
		local focusPos = self.controler.screen.focusPos
		xpos = focusPos.x
		ypos =focusPos.y 
		zpos = 0
		isFollow =false
		echo("__创建在屏幕中心的特效")
		--判断是全屏特效的
		eff.isWholeEff = true
	end
	eff:setFollow(isFollow)
	local ctn
	local zorder= 0
	local pianyiY = 0
	--如果是在所有人后面
	if showZorder == -2 then
		ctn = self.controler.layer:getGameCtn(2)
		zorder = - Fight.zorder_front
		pianyiY =  -2
	--如果是在自己后面
	elseif showZorder == -1 then
		ctn = self.viewCtn
		zorder = -1
		pianyiY =  -1
	elseif showZorder == 1 then
		zorder = 1
		ctn = self.viewCtn
		pianyiY =  1
	--显示在最前面 
	elseif showZorder == 2 then
		zorder = Fight.zorder_front
		ctn =  self.controler.layer:getGameCtn(3) --self.viewCtn
		pianyiY =  2
	end
	eff:setTarget(self,self.data.viewSize[1]*coeffX,pianyiY,-self.data.viewSize[2]*pery ,zorder)
	eff:initView(ctn,ani,xpos,ypos + pianyiY ,zpos)
	-- 记录必要变量，用于可能用到的位置修正
	eff.__fixInfo = {
		coeffY = coeffY,
		coeffX = coeffX,
		pery = pery,
		pianyiY = pianyiY,
		zorder = zorder,
		isFollow = (boneName and boneName ~= "n"),
	}
	eff:checkCanPlayView()

	-- eff.myView:zorder(zorder + self.__zorder)
	
	eff:setWay(way)
	if isBeUsed then
		if coeffY ~= -2 then
			eff:setViewScale(self.data:beusedScale() /100  )
		else
			--镜头永远正
			-- eff.myView:setScaleX(1 )
		end
		
	else
		eff:setViewScale(self.viewScale)
	end
	
	--如果不是全屏特效 那么得计算scale
	if coeffY ~= -2 then
		eff:countScale()
	end

	-- ani:setScaleX(self.controler._mirrorPos*way * Fight.wholeScale )
	-- ani:setScaleY(Fight.wholeScale)
 	self.controler:insertOneObject(eff,false)
 	if not canRepeat then
 		self.effectArr[animation] = eff
 	end

 	if self.controler.skillPauseInfo.left == 0 then
		self.controler.sortControler:sortDepth(true)
	end
 	
	--如果是黑屏期间
	if self.controler.skillPauseInfo.left > 0 then
		eff.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
	else
		eff.myView:zorder(zorder + self.__zorder)
	end
	-- echo(animation,"___特效层级zorder",zorder,showZorder,isCycle,self.data.hid,self.__zorder,eff._zorderAdd)
	-- 设置特效播放速度与自己一致
	-- eff:setUpdateScale(2)
	eff:setUpdateScale(self:getUpdateScale())

	return eff
end

-- 更新特效位置
function ModelBasic:updateEffPos()
	-- 子类重写
end

-- 根据信息更新位置
function ModelBasic:_updatePosByEff(eff)
	if not eff._isDied then
		local fixInfo = eff.__fixInfo
		if fixInfo 
			and fixInfo.coeffY ~= -2 
			and not fixInfo.isFollow -- 不跟随特效才需要手动刷新位置
		then -- -2 中心特效不需要修正
			-- 计算方法来自创建时候的计算方法
			local coeffX = fixInfo.coeffX
			local coeffY = fixInfo.coeffY
			local pianyiY = fixInfo.pianyiY
			local pery = fixInfo.pery
			local zorder = fixInfo.zorder

			local xpos = self.pos.x + self.data.viewSize[1]*coeffX
			local ypos = self.pos.y + pianyiY
			local zpos = self.pos.z - self.data.viewSize[2]*pery
			eff:setPos(xpos,ypos,zpos)

			--如果是黑屏期间
			if self.controler.skillPauseInfo.left > 0 then
				eff.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
			else
				eff.myView:zorder(zorder + self.__zorder)
			end
		end
	end
end
-- 更新一组使用通用方法创建的特效的位置的方法
function ModelBasic:_updateEffPos(arr,notarr)
	if empty(arr) then return end
	if not Fight.isDummy and not self.controler:isQuickRunGame() then
		if notarr then
			self:_updatePosByEff(arr)
		else
			for _,eff in ipairs(arr) do
				self:_updatePosByEff(eff)
			end
		end
	end
end

--创建屏幕中心动画
--spName spine文件名,texName 材质名, animation动画名,showZorder显示层级,way 如果为true 表示始终是正向的
function ModelBasic:createCenterSpineEff( spName,texName,animation,showZorder ,way)
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame() then
		return
	end
	texName = texName and texName or spName
	local ani = ViewSpine.new(spName,nil,nil,texName,true)
	ani:playLabel(animation,true)

	local eff = ModelEffectBasic.new(self.controler)
	eff.animation = animation
	local focusPos = self.controler.screen.focusPos
	local xpos = focusPos.x

	local ctn
	local zorder= 0
	local pianyiY = 0
	--如果是在所有人后面
	if showZorder == -2 then
		ctn = self.controler.layer:getGameCtn(2)
		zorder = - Fight.zorder_front
		pianyiY =  -1
	--如果是在自己后面
	elseif showZorder == -1 then
		ctn = self.viewCtn
		zorder = -1
		pianyiY =  -1
	elseif showZorder == 1 then
		zorder = 1
		ctn = self.viewCtn
		pianyiY =  1
	--显示在最前面 
	elseif showZorder == 2 then
		zorder = Fight.zorder_front
		ctn =  self.controler.layer:getGameCtn(3) --self.viewCtn
		pianyiY =  1
	elseif showZorder >= 3 then
		zorder = Fight.zorder_front + showZorder
		xpos = GameVars.halfResWidth  
		ctn =  self.controler.layer.a3 
		pianyiY =  1
	elseif showZorder == -3 then
		
		ctn = self.controler.layer:getGameCtn(2)
		zorder = - Fight.zorder_front
		pianyiY =  -1
	end
	
	eff:setTarget(self,self.data.viewSize[1],pianyiY,-self.data.viewSize[2],zorder)
	eff:initView(ctn,ani,xpos,focusPos.y,0)
	
	if showZorder == -3 or showZorder>= 3 then
		
		if way then
			-- eff.myView:setScaleX(Fight.cameraWay )
		else
			--这里要根据自身的方向去判断怎么反向 而不能根据 camp去判断
			local sx = self.way == 1 and Fight.cameraWay  or -Fight.cameraWay
			eff.myView:setScaleX(sx)
		end
		--锁定屏幕中心
		eff:setLockInCenter()
	else
		if way then
			eff.myView:setScaleX(Fight.cameraWay )
		else
			local sx = self.camp == 1 and -Fight.cameraWay  or Fight.cameraWay
			eff.myView:setScaleX(sx)
		end

	end

	--如果是黑屏期间
	if self.controler.skillPauseInfo.left > 0 then
		eff.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
	end

	

	eff:checkCanPlayView()
	self.controler:insertOneObject(eff,true)
	return eff
end


function ModelBasic:removeOneEffect(aniName)
	if self.effectArr[aniName] then
		self.effectArr[aniName] = nil
	end
end



--创建影子
function ModelBasic:createShade( textureName, isAni )
	if Fight.isDummy then
		return
	end

	local ctn = self.controler.layer:getGameCtn(3)
	self.shade = ModelShade.new(self.controler)

	local view = nil
	if not isAni then
		view = ViewBasic.new(textureName)
	else
		view = ViewArmature.new(textureName)
	end

	self.shade:initView(self.viewCtn,view)
	self.shade:setFollowTarget(self,0,0,isAni)
	view:zorder(self.__zorder-1)
	--self.shade:updateFrame()

	return self
end


--创建数字特效
function ModelBasic:createNumEff( type,num,showZorder )
	--模拟计算的时候  是不需要创建特效的
	if Fight.isDummy then
		return
	end
	--如果是游戏加速的 不创建特效
	if self.controler:isQuickRunGame() then
		return
	end
	--如果
	if math.round(num) ==0 then
		return
	end

    if self:getHeroProfession() == Fight.profession_obstacle then
        -- echo("障碍物不创建伤害飘字")
        return
    end

	local eff = ModelEffectNum.new(self.controler)
	--eff:setInfo(self, self.controler.layer:getGameCtn(3),type,num)
	eff:setInfo(self, self.controler.layer:getGameCtn(3),type,num)
	eff.myView:zorder(9999)
	-- if showZorder ~= 2 then
	-- 	showZorder = showZorder or 1
	-- 	eff.myView:zorder(self.__zorder+showZorder)
	-- else
	-- 	local ctn = self.controler.layer:getGameCtn(3)
	-- 	eff.myView:parent(ctn)
	-- end

	self.controler:insertOneObject(eff,true)
end


--添加残影
function ModelBasic:addPhantom( alpha,time )
	local phantom = ModelPhantom.new(self.controler,{})

	local ctn = self.controler.layer:getGameCtn(2)

	phantom:setTarget(self,ctn)
	
	self.controler:insertOneObject(phantom)

end


--创建子弹 初始位置偏移
--carrier 载体 因为有可能是在missle的基础上创建载体,所以出现点应该是从载体出发
function ModelBasic:createMissle( missleObj,skill,atkTarget,carrier)

	-- if skill.hid == "40901" or skill.hid == "50601" then
	-- 	echo("___@@@@@_______ddd",missleObj.hid,missleObj:sta_showFront())
	-- end
	--如果敌方阵营已经全部挂彩了
	if Fight.isDummy or self.controler:isQuickRunGame()  then
		return
	end

	if #self.toArr ==0 then
		return nil
	end


	local bullet = ModelMissle.new(self.controler,missleObj,skill)
	--dump(bullet.viewData)
	local ctn
	local zorder= 0
	local pianyiY = 0

	
	if true then
		local view 
		if bullet.viewData.spine then
			view = ViewSpine.new(bullet.viewData.spine,nil)
			view:playLabel(bullet.viewData.image, true)
		else
			view = ViewArmature.new(bullet.viewData.image)
		end

		if not Fight.isDummy  then
			-- 子弹是最上层
			local offsetY = 0
			local showZorder = missleObj:sta_showFront() or 1
			local zorderAdd = 0

			--如果是在所有人后面
			if showZorder == -2 then
				ctn = self.controler.layer:getGameCtn(1)
				zorder = - Fight.zorder_front
				pianyiY =  -1
			--如果是在自己后面
			elseif showZorder == -1 then
				ctn = self.controler.layer:getGameCtn(2)
				zorder = -1
				pianyiY =  -1
			elseif showZorder == 1 then
				zorder = 1
				ctn = self.controler.layer:getGameCtn(2)
				pianyiY =  1
			--显示在最前面 
			elseif showZorder == 2 then
				zorder = Fight.zorder_front
				ctn =  self.controler.layer:getGameCtn(3) --self.viewCtn
				pianyiY =  1
			else
				echoWarn("___showZorder配置错误:%s,showZorder:%d",missleObj.hid,showZorder)
			end
			bullet:initView(ctn, view)
			bullet._zorderAdd = zorderAdd

			if self.controler.skillPauseInfo.left > 0 then
				bullet.myView:zorder(zorder + self.__zorder + Fight.zorder_blackChar)
			end

		end
	end
	
	bullet:setCamp(self.camp,true)
	bullet:setTarget(self,atkTarget,carrier,pianyiY)	
	self.controler:insertOneObject(bullet)
	return bullet
end


function ModelBasic:pushOneCallFunc( delayFrame,func,params )
	if Fight.isDummy  then
		echo(debug.traceback("___dumy should run rightway") )
		delayFrame = 0
	end

	params = params or {}
	if type(func) == "string" then
		func = self[func]
		params = Tool:getTableNoNil(params)
		table.insert(params, 1,self)
	end
	
	self.controler:pushOneCallFunc(delayFrame, func, params)
end


--清除一个回调
function ModelBasic:clearOneCallFunc( func )
	local length = #self.callFuncArr
	if type(func) == "string" then
		func = self[func]
		self.controler:clearOneCallFunc(func,self)
	else
		self.controler:clearOneCallFunc(func,self)
	end
	
	
end


function ModelBasic:updateCallFunc(  )
	if not self.callFuncArr then return end
	local callInfo
	for i=#self.callFuncArr,1,-1 do
		callInfo = self.callFuncArr[i]
		--@测试
		if not callInfo then
			dump(self.callFuncArr)
			echo("____________________ddd",i,self.data.hid,#self.callFuncArr)
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
function ModelBasic:countScale( )
	if Fight.isDummy  then
		return
	end
	local ypos =self.pos.y 
	local scale = (ypos - Fight.initYpos_2)/ Fight.initScaleSlope + 1 
	self.myView:setScaleY(scale*self.viewScale * Fight.wholeScale)
	self.myView:setScaleX(self.controler._mirrorPos*self.way*self.viewScale * scale* Fight.wholeScale)

	--在initYpos2 上的scale是1   initYpos1上的是0.8
end




--闪光
function ModelBasic:flash(time,interval, color  )
	if Fight.isDummy then
		return
	end
	if self.controler:isQuickRunGame() then
		return
	end
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
function ModelBasic:checkHasFilterStyle(  )
	return false
end


--创建残影 组
function ModelBasic:createGhostGroup(times,interval, offset, zorder,ctn ,alpha, lastTime)
	if not self.myView then
		return
	end

	local tempFunc = function (  )
		local curHp = self.data:hp()
		if  curHp > 0 then
			local node = self:createGhost(self.pos.x+30*offset,-self.pos.y,zorder,ctn,alpha, lastTime)
			node:setScaleX(self.controler._mirrorPos*self.way)
		end
	end

	for i=1,times do	
		self.myView:delayCall(tempFunc,interval*i)
	end
	tempFunc()
end


--创建残影
function ModelBasic:createGhost( x, y, zorder,ctn ,alpha, lastTime)
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
function ModelBasic:setVisible( value )
	self.myView:visible(value)
	-- if value then
	-- 	self:playFrame()
	-- else
	-- 	self:stopFrame()
	-- end
end


function ModelBasic:tostring(  )
	if self.data.tostring then
		return self.data:tostring()
	end
	return "className:"..self.__cname.."_id:"..tostring(self.data.id) .."_pos:"..self.pos.x.."_"..self.pos.y.."_"..self.pos.z
end

-- 播放音效
function ModelBasic:playAudio( key, isLoop )
	-- 纯跑逻辑时不播放音效
	if Fight.isDummy then return end
	-- 快速播放不播音效
	if self.controler and self.controler:isQuickRunGame() then return end

	AudioModel:playSound(key, isLoop)
end
-- 设置视图转身(锁妖塔用到)
function ModelBasic:turnRound(value)
	if Fight.isDummy then return end
	if self.myView then
		if value then
			if not self._oldScaleX then
				self._oldScaleX = self.myView:getScaleX()
			end
			self.myView:setScaleX(-1 * self._oldScaleX)
		else
			if not self._oldScaleX then
				return
			end
			local tmp = self.myView:getScaleX()
			-- 说明已经转过身了
			if tmp * self._oldScaleX < 0 then
				self.myView:setScaleX(-1 * tmp)
			end
			self._oldScaleX = nil
		end
	end
end

return ModelBasic