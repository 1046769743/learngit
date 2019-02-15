--
-- Author: xd
-- Date: 2018-08-22 10:01:48
-- 地图控制器的扩展类 ,主要负责处理地图的一些特殊表现 

local ExploreMapControlerEx = class("ExploreMapControlerEx", ExploreMapControler)



function ExploreMapControlerEx:ctor( controler,gameLayers ,mapCells,width,height)
	ExploreMapControlerEx.super.ctor(self,controler,gameLayers ,mapCells,width,height)

	self:initCloudInfo()

end

function ExploreMapControlerEx:initCloudInfo(  )
	--存储云相关数据
	--[[
		{
			x = 101,		--真实坐标
			y = 200,				
			frame=100,			--运动帧数 
			way =1,				--运动方向
		}
	]]
	self.cloudMap = {
	}
	--云的速度 每帧
	self.cloudSpeed = 1
	self.cloudWayFrame =  1000		--云跑多少帧之后就开始掉头
	self.cloudWayFrameLoop = self.cloudWayFrame * 2 	--一个循环帧数
	--低端机不执行
	if  AppInformation:checkIsLowDevice(  ) then
		return
	end


	local mapId = GuildExploreModel:getMapId(  )
	
	local sceneCfgs = FuncGuildExplore.getCfgDatas( "ExploreSceneEffect",mapId )	
	-- dump(sceneCfgs,"__sceneCfgs")
	for k,v in pairs(sceneCfgs) do
		--如果有云
		if v.cloud then
			local frame = RandomControl.getOneRandomInt(self.cloudWayFrame * 2, 1)
			local gridX,gridY = FuncGuildExplore.getPosByKey(k)
			local worldPos = self.gridControler:getGridWorldPos( gridX,gridY )
			local speed = RandomControl.getOneRandomFromArea(0.5, 1)
			local info = {
				initX =  worldPos.x,
				initY = worldPos.y,
				x = worldPos.x + self:countXOffset(frame,speed),
				y = worldPos.y,
				frame = frame,
				index = v.cloud,
				speed = speed
			}
			table.insert(self.cloudMap,info)
		end
	end

end

--每帧刷新云的逻辑
function ExploreMapControlerEx:refreshCloud(  )
	local startX = self._rightTop.x + 200
	local startY = self._rightTop.y + 50
	local endX =  self._leftTop.x - 200
	local endY = self._rightDown.y - 50
	--计算网格坐标
	-- startX,startY =self.gridControler:turnWorldPosToRect(startX,startY  )	
	-- endX,endY =self.gridControler:turnWorldPosToRect(endX,endY  )	

	--先重置云的view
	for i,v in ipairs(self.cloudMap) do
		v.frame = v.frame +1
		if v.frame > self.cloudWayFrameLoop then
			v.frame =1
		end
		v.x = v.initX + self:countXOffset(v.frame,v.speed)
	end

	-- if self.controler.updateCount % 5 == 0 then
	--暂定每帧都刷新云 可能有点废性能
	if true then
		self:resetCacheIndex(self.specialCacheMap.cloud)
		for i,v in ipairs(self.cloudMap) do
			v.x = v.initX + self:countXOffset(v.frame,v.speed)
			if v.x <= startX and v.x >= endX and v.y <= startY and v.y >= endY  then
				local view = self:getOneCloudView(v.index)
				view:setPosition(v.x,v.y)
				view:setVisible(true)
			end
		end
	end

end

function ExploreMapControlerEx:getOneCloudView( index )
	local view = self:getOneCacheView(self.specialCacheMap.cloud,index)
	if not view then
		view = display.newSprite():addto(self.a22,FuncGuildExplore.zorderMap.effect+1000)
		self:insertOneCacheView( self.specialCacheMap.cloud,index,view )
		self:setTerrainTexture("panel_yun_"..index, view ,true)
	end
	
	return view

end



--计算需要的x偏移
function ExploreMapControlerEx:countXOffset(frame,speed)
	return  (self.cloudWayFrame - math.abs(frame- self.cloudWayFrame) ) * speed
end


--设置跟随主角
function ExploreMapControlerEx:setMapFollowPlayer(  )

	local player = self.controler.selfPlayer
	if not player then
		return
	end
	self:setFollowToTargetByPos(player.pos,false)
	
end


--绕某个instance缩放,
-- targetFocesPos 绝对坐标.相对于屏幕左下点. time 缓动时间, targetScale 缩放值
function ExploreMapControlerEx:scaleToTargetInstance( instance,targetFocesPos,time,targetScale )
	self.currentMoveState = 0
	self.currentScaleState = 1
	time = time or 0.3
	targetScale = targetScale or 2.5
	self.blackImage:setVisible(true)
	self:createFootView(instance._data.type,instance)
	local action
	self.a2scale:stopAllActions()
	self.currentScaleInstance = instance
	instance:setDepthHeight(FuncGuildExplore.zorderMap.black)
	if instance.myView and  instance.myView.clickBtn then
		instance.myView.clickBtn:setVisible(false)
	end
	--先把当前坐标	
	--先进行一下坐标转化,这个时候需要把这个屏幕拉到相对应位置 然后进行缩放
	--先判断这个instance离目标点有多少距离,那么先走moveCtn
	--只有小怪和精英怪 需要缩放到左边 其他的原地缩放

	--转化为世界坐标
	local worldPos = self.a22:convertToWorldSpaceAR(instance.pos )
	local localPos =  self.a22:convertLocalToNodeLocalPos(self.a2scale,instance.pos)
	targetFocesPos = targetFocesPos or {x = GameVars.width /2-200,y=230}
	if instance._data.type == FuncGuildExplore.gridTypeMap.enemy   then
		targetFocesPos = {x = GameVars.width /2-300,y=180}
	elseif instance._data.type == FuncGuildExplore.gridTypeMap.elite  then
		targetFocesPos = {x = GameVars.width /2-300,y=100}
	else
		time = 0.2
		targetFocesPos = {x = worldPos.x,y = worldPos.y }
		local borderX = 100 + GameVars.UIOffsetX 
		local borderY = 100 + GameVars.UIOffsetY 
		if targetFocesPos.x > GameVars.width - borderX then
			targetFocesPos.x = GameVars.width - borderX
		elseif targetFocesPos.x <  borderX then
			targetFocesPos.x = borderX
		end

		if targetFocesPos.y > GameVars.height - borderY then
			targetFocesPos.y = GameVars.height - borderY
		elseif targetFocesPos.y <  borderY then
			targetFocesPos.y = borderY
		end
	end

	local targetMovePos = {x= targetFocesPos.x -worldPos.x  ,y = targetFocesPos.y- worldPos.y }
	action = self.a2scale:getScaleAnimByPos(time, targetScale,targetScale,false,localPos,targetMovePos)
	self.a2scale:runAction(action)
	self:setWillRefreshCount(math.ceil(time*GameVars.GAMEFRAMERATE) +3 )
	
end

--复原缩放
function ExploreMapControlerEx:resumeScaleInstance(  )
	-- self.currentScaleState = 1
	if self.currentScaleInstance then
		self.currentScaleInstance:setDepthHeight(0)
		
		if self.currentScaleInstance.myView and  self.currentScaleInstance.myView.clickBtn then
			self.currentScaleInstance.myView.clickBtn:setVisible(true)
		end
		self.currentScaleInstance = nil
	end
	self.blackImage:setVisible(false)
	local time = 0.3
	local ctnX,ctnY = self.a2scale:getPosition()
	self.a2scale:stopAllActions()
	local action = self.a2scale:getScaleAnimByPos(time, 1,1,false,originPos,{x=-ctnX,y = -ctnY})
	local callFunc = function (  )
		self.currentScaleState = 0
		echo("恢复状态--------")
	end
	local actCall = act.callfunc(callFunc)
	local seq = act.sequence(action,actCall)
	self.a2scale:runAction(seq)
	self:setWillRefreshCount(math.ceil(time*GameVars.GAMEFRAMERATE) + 4 )
	--隐藏怪物底盘
	self:resetCacheIndex(self.specialCacheMap.enemyfoot)
end


--创建怪物底盘 
function ExploreMapControler:createFootView(t,instance )

	local panelName
	if t == FuncGuildExplore.gridTypeMap.enemy then
		panelName = "UI_xianmengtansuo_landi"
	elseif t == FuncGuildExplore.gridTypeMap.elite then
		panelName = "UI_xianmengtansuo_zidi"
	else
		return
	end
	
	local view = self:getOneCacheView(self.specialCacheMap.enemyfoot, t)
	if not view then
		view = self.controler.mainUI:createUIArmature("UI_xianmengtansuo", panelName, self.a22, true)
		-- view = display.newSprite():addto(self.a22,FuncGuildExplore.zorderMap.foot)
		
		self:insertOneCacheView(self.specialCacheMap.enemyfoot, t,view)
		view:setScale(0.4)
	end
	-- self:setTerrainTexture(panelName, view ,true)
	view:zorder(FuncGuildExplore.zorderMap.black)
	view:setPosition(instance.pos.x,instance.pos.y)
	view:setVisible(true)
	view:startPlay(true)
end





--跟随主角行为
function ExploreMapControlerEx:easeFollowTarget(  )
	if self.currentMoveState ~= 1 then
		return
	end

	
	local targetPos = self.followPos
	if not  targetPos then
		return
	end
	local disx = targetPos.x - self.focusPos.x
	local disy = targetPos.y - self.focusPos.y
	local dis = math.sqrt(disx*disx + disy* disy)
	if disx == 0 and disy ==0 then
		return
	end

	--最大速度给50
	local maxSpeed = 80
	--最小速度给5
	local minSpeed = 7
	local easeNums = 0.08
	if dis <= minSpeed then
		self.focusPos.x = targetPos.x
		self.focusPos.y = targetPos.y
		self:onArriveTargetPos()
	else
		local targetSpeed = dis * easeNums
		if targetSpeed < minSpeed then
			targetSpeed = minSpeed
		elseif targetSpeed > maxSpeed then
			targetSpeed = maxSpeed
		end
		local ang = math.atan2(disy,disx)
		self.focusPos.x = self.focusPos.x +math.cos(ang) * targetSpeed
		self.focusPos.y = self.focusPos.y +math.sin(ang) *targetSpeed
		
	end
	self:updatePos(-self.focusPos.x - GameVars.width /2, -self.focusPos.y -   GameVars.height /2)

end


--设置运动到某个点
--gridX,gridY 网格坐标,  isDoClick 是否运动到了之后需要执行一次点击地图事件
function ExploreMapControlerEx:setFollowToTargetByGrid( gridX,gridY ,isDoClick)
	local worldPos  = self.gridControler:getGridWorldPos(gridX,gridY)
	self:setFollowToTargetByPos(worldPos,isDoClick)
end


function ExploreMapControlerEx:setFollowToTargetByPos( pos, isDoClick)
	if self.currentScaleState == 1 then
		return
	end

	-- 如果是显示路径的 那么跟随主角
 	self.currentMoveState = 1
 	-- (-self.focusPos.x - GameVars.width /2, -self.focusPos.x -   GameVars.height /2)
 	self.focusPos.x = -self.currentPos.x -GameVars.width /2
 	self.focusPos.y = -self.currentPos.y -GameVars.height /2
 	self.followPos = pos
 	self.needClickMap = isDoClick
end



--到达目标点 
function ExploreMapControlerEx:onArriveTargetPos(  )

	-- echo("onArriveTargetPos")
	if self.needClickMap then
		local gridX,gridY = ExplorePosTools:getGridPosByWordPos(self.followPos.x,self.followPos.y)
		self:onClickMap( nil,gridX,gridY)
		self.needClickMap = false
		-- echoError("_______",self.followPos.x,self.followPos.y)
		self.currentMoveState = 0 
	else
	end
	
end

--创建阳光特效
function ExploreMapControlerEx:createTopEffect(  )
	--创建顶层阳光特效
	local ani = self.controler.mainUI:createUIArmature("UI_xianmengtansuo_a", "UI_xianmengtansuo_a_g1", self.a3, true)
	ani:pos(GameVars.width - GameVars.UIOffsetX , GameVars.UIOffsetY)
	ani:setRotation(50)
	local ani = self.controler.mainUI:createUIArmature("UI_xianmengtansuo_a", "UI_xianmengtansuo_a_g2", self.a3, true)
	ani:pos(GameVars.width - GameVars.UIOffsetX +200 , GameVars.UIOffsetY+200 )
	ani:setRotation(50)
	
	-- --创建云
	-- local lineNums = 6
	-- local perHeight = math.round(GameVars.height  / (lineNums+1) )
	-- local wayArr = {1,1,1,-1,-1,-1}

	-- local indexArr1 = {1,2,3,4}
	-- local indexArr2 = {1,2,3,4}

	-- --随机打乱数组
	-- wayArr = RandomControl.randomOneGroupArr(wayArr)
	-- indexArr1 = RandomControl.randomOneGroupArr(indexArr1, index)
	-- indexArr2 = RandomControl.randomOneGroupArr(indexArr2, index)
	-- local middleX = GameVars.width /2
	-- local offsetX = middleX
	-- for i,v in ipairs(wayArr) do
	-- 	local xpos = middleX + offsetX * v
	-- 	local ypos = i * perHeight 
	-- 	--随机一个动画
	-- 	local aniIndex = i
	-- 	if aniIndex > 3 then
	-- 		aniIndex = aniIndex - 3
	-- 	end
	-- 	if v <0 then
	-- 		aniIndex = indexArr2[aniIndex]
	-- 	else
	-- 		aniIndex = indexArr1[aniIndex]
	-- 	end
	-- 	local ani =  self.controler.mainUI:createUIArmature("UI_xianmengtansuo_a", "UI_xianmengtansuo_a_yun0"..aniIndex, self.a22, true)
	-- 	ani:setScaleX(v)
	-- 	ani:pos(xpos,ypos)
	-- 	--这个动画
	-- 	ani:setLockTransform(true)
	-- 	ani:zorder(FuncGuildExplore.zorderMap.effect+1000)
	-- 	local randomFrame = RandomControl.getOneRandomInt(500, 1)
	-- 	ani:gotoAndPlay(randomFrame)

	-- end


end



--初始化minimap
function ExploreMapControlerEx:initMiniMap(  )
	local mapNode = self.controler.mainUI.panel_map
	--暂时屏蔽蜘蛛网格
	if true then
		return
	end
	if not mapNode then
		return
	end
	--创建一个node 
	local nd = display.newNode()
	local black = FuncRes.a_black(self.miniMapWidth, self.miniMapHeight,255):anchor(1,1)
	local maskNode = FuncCommUI.getMaskCan(black, nd)
	maskNode:addto(mapNode.ctn_1)
	
	local xOffset1 = -122
	local yOffset1 = 4

	local xOffset2 = -7
	local yOffset2 = -104

	local leftTopX,leftTopY =  ExplorePosTools:getGridPosByWordPos(-self.mapWidth,0)
	local rightDownX,rightDownY = ExplorePosTools:getGridPosByWordPos(0,-self.mapHeight)

	local xnums = math.ceil(leftTopX/5)
	local ynums =  math.ceil(rightDownY/5)

	local size 
	local texture

	--需要计算scale
	local tempWidth = math.abs( (xnums-2) * xOffset1 + (ynums-2) * xOffset2 )
	local tempHeight =math.abs( (xnums-2) * yOffset1 + (ynums-2) * yOffset2 )
	local scaleX = self.miniMapWidth/tempWidth
	local scaleY = self.miniMapHeight/tempHeight
	nd:setScaleX(scaleX)
	nd:setScaleY(scaleX)
	-- echo(scaleX,scaleY,"___kashdksajdsa",tempWidth,"__")

	local uiCfg = self.controler.mainUI.panel_map6.__uiCfg.ch[1]
	local box = self.controler.mainUI.panel_map6:getContainerBox()

	local img = uiCfg.img
	if CONFIG_USEDISPERSED then
		texture = cc.Director:getInstance():getTextureCache():addImage("uipng/"..img);
		if not texture then
			echoError("没找到这个uipng图片:",img)
		end
		size = texture:getContentSize()
    else
    	texture = cc.SpriteFrameCache:getInstance():getSpriteFrame(img)
    end

    local createView = function ( x,y )
    	local sp = display.newSprite()
    	if CONFIG_USEDISPERSED then
    		sp:setTexture(texture)
        	sp:setTextureRect(size)
    	else
    		sp:setSpriteFrame(texture)
    	end
    	sp:anchor(box.x/box.width,box.y/box.height)
    	sp:addto(nd)
    	sp:setPosition(x,y)
    end

	for i=1,xnums do
		for j=1,ynums do
			local x = (i-1) * xOffset1 + (j-1) * xOffset2
			local y = (i-1) * yOffset1 + (j-1) * yOffset2
			createView(x,y)
		end
	end

end




--转化真实坐标为 小地图坐标
function ExploreMapControlerEx:turnWorldPosToMiniMap( x,y )
	return self.miniScaleX * x,self.miniScaleY * y
end


--转化小地图坐标为 真实坐标
function ExploreMapControlerEx:turnMiniToWorldPos( x,y )
	return x/self.miniScaleX,y/self.miniScaleY 
end


function ExploreMapControlerEx:dumpGridInfo( x,y )
	local gridData = self.gridControler:getGridData(x,y)
	dump(gridData,"_网格数据,pos:"..x.."_"..y)
	if gridData.sub then
		x,y = FuncGuildExplore.getPosByKey(gridData.sub)
	end
	local eventData = GuildExploreModel:getGridEvent( x,y,true ) 
	if eventData then
		dump(eventData,"_网格事件数据")
	else
		echo("这个网格没有数据")
	end
	echo("这个网格是否是迷雾:",self.gridControler:checkGridIsMists( x,y ))

end

return ExploreMapControlerEx