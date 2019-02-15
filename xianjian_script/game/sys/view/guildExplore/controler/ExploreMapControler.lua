--
-- Author: xd
-- Date: 2018-07-03 11:51:28
-- 地图控制器
local ExploreMapControler = class("ExploreMapControler")
--容器分层
--[[
	a1 -> 场景后层预留
		
	a2 -> 游戏层.
		a21,放地面元素,比如草,地面.
		a22, 放角色和建筑参与深度排列继承baseInstance
		a23, 放前层和迷雾
		a24,  备用扩展,

	a3 ->场景前层

]]

ExploreMapControler.miniMapWidth = 808
ExploreMapControler.miniMapHeight = 472

--需要做缓存的map. 为了以后的扩展维护.防止冗余代码.采用一套缓存结构
ExploreMapControler.cacheIdMap = {
	terrain = "terrain",
	decorate = "decorate",
	path = "path",		--路标
	mists = "mists",		--迷雾
	--地图上的 事件 包括所有的小怪 精英怪 矿洞. 
	enemy = "enemy",	 	--小怪
	res = "res", 			--资源
	mine = "mine",			--矿洞
	build = "build",		--建筑
	spring = "spring",		--灵泉
	effect  = "effect",			--场景特效

	

}
--特殊的缓存
ExploreMapControler.specialCacheMap = {
	cloud = "cloud",
	enemyfoot = "enemyfoot",	--底盘特效
}



local instanceResetFunc = function ( instance )
	instance:setVisible(false)
	if instance.stop then
		instance:stop()
	end
end

local viewResetFunc = function (instance  )
	instance:setVisible(false)
	if instance.debugTxt then
		instance.debugTxt:setVisible(false)
	end
end

local resetFuncMap = {
	terrain = viewResetFunc,

	mists = viewResetFunc,

	decorate = viewResetFunc,

	enemy = instanceResetFunc,
	res = instanceResetFunc,
	mine = instanceResetFunc,
	build = instanceResetFunc,
	spring = instanceResetFunc,
	effect = instanceResetFunc,
	cloud = viewResetFunc,
	enemyfoot = instanceResetFunc,
}




local originPos = {x=0,y=0}



--一屏容纳多少高度格子
ExploreMapControler.screenHeightNums = 24
ExploreMapControler.screenWidthNums = 33

--拖拽速度 默认是1 正常拖拽
ExploreMapControler.dragSpeed=  1


ExploreMapControler.updateCount = 0
--地图宽高
ExploreMapControler.mapWidth = 0
ExploreMapControler.mapHeight = 0

--当前缩放状态
ExploreMapControler.currentScaleState = 0
--所有对象的缓存
--[[
	{
		cacheId = {
			...
		}
		--地形缓存
		terrain = {
			index = 1, --当前拿缓存的进度
			viewArr = {view1,view2,view3,...}
		}
	}
]]
ExploreMapControler.allCacheMap = nil


--当前运动状态 0表示自由的 可以任意拖拽的, 1 表示 跟随主角
ExploreMapControler.currentMoveState = 0
ExploreMapControler.focusPos = nil
--初始化是否完成
ExploreMapControler.isInitComplete = false

function ExploreMapControler:ctor( controler,gameLayers ,mapCells,width,height)
	self.controler = controler
	self.gridControler = controler.gridControler
	self.a = gameLayers
	self.allCacheMap = {}
	self.focusPos = {x=0,y=0}
	self.followPos = {x=0,y =0}
	for k,v in pairs(self.cacheIdMap) do
		self.allCacheMap[v] = {
		}
	end

	for k,v in pairs(self.specialCacheMap) do
		self.allCacheMap[v] = {
		}
	end
	
	self.mapCells = mapCells
	self.curentTerrainNodeArr = {}
	--缓存icon图标数组
	self.cacheGuideIconArr = {frontArr = {}}

	local uiCfg = UIBaseDef:getUIChildCfgs( "UI_explore_grid" )
	self._gridUICfgs = {}

	--缓存ui配置.方便读取时 提高读取速度
	for i,v in ipairs(uiCfg.ch) do
		if v.ch  and v.ch[1].img then
			local img = v.ch[1].img 
			local texture 
			local size 
			if CONFIG_USEDISPERSED then
				texture = cc.Director:getInstance():getTextureCache():addImage("uipng/"..img);
				if not texture then
					echoError("没找到这个uipng图片:",img)
				else
					size = texture:getContentSize()
				end
				
		    else
		    	texture = cc.SpriteFrameCache:getInstance():getSpriteFrame(img)
		        -- sp:setSpriteFrame(pngName)
		    end
			self._gridUICfgs[v.na] = {cfg =v.ch[1],texture = texture,size = size}

		end
	end

	self.screenWidthNums = math.ceil(GameVars.width /FuncGuildExplore.gridWidth) +2
	self.screenHeightNums = math.ceil(GameVars.height /FuncGuildExplore.gridHeight) +1

	--定义当前四个角落坐标
	self._leftTop = {x=0,y=0}
	self._rightTop = {x=0,y=0}
	self._rightDown = {x=0,y=0}
	self._leftDown = {x=0,y=0}
	self._lastRefreshCount = 0
	self._willRefreshCount = 0
	--直接定义原点为右上角,方便坐标计算
	local layer
	for i=1,3 do
		layer = display.newNode()
		--layer:setAnchorPoint(yuandian)
		gameLayers:addChild(layer)
		self["a"..i] = layer
	end
	--游戏层添加一层 缩放层
	self.a2scale = display.newNode():addto(self.a2)
	-- self.a2move = display.newNode():addto(self.a2scale)
	
	--把游戏层a2offset直接放到右上角. 定义为游戏原点
	self.a2offset = display.newNode():addto(self.a2scale)
	self.a2offset:setPosition(GameVars.width - GameVars.UIOffsetX , GameVars.UIOffsetY)
	for i=1,4 do
		layer = display.newNode():addto(self.a2offset)
		--layer:setAnchorPoint(yuandian)
		-- gameLayers:addChild(layer)
		self["a2"..i] = layer
	end
	self:createBlackImage()
	self:createTopEffect()
	self.currentPos = {x=0,y =0}
	self.willArrivePos = {x=0,y =0}

	-- 通过mapData构建
	--先创建地形
	local index = 1

	if FuncGuildExplore.debugGrild ~= 0 then
		self.debugTxtCfg ={co={fontName="gameFont1",fontSize=12,text="20,20",	},
			h=21.95,
			m={[1]=-144.8,[2]=47.65,[3]=1,[4]=1,[5]=0,[6]=0,}
			,na="txt_1",t="txt",w=61.95,
		}
	end

	--计算地图宽高 通过最大的网格算的
	local targetPos = self.controler.gridControler:getGridWorldPos( width,height )
	self.mapWidth = math.abs(targetPos.x)
	self.mapHeight = math.abs(targetPos.y)
	self.minX = 0
	self.minY = FuncGuildExplore.gridHeight/2
	self.maxX = self.mapWidth-self.minX  - GameVars.width 
	self.maxY = self.mapHeight-self.minY - GameVars.height - FuncGuildExplore.gridHeight
	if self.maxX < 1 then
	  	self.maxX = 1
	end
	if self.maxY < 1 then
	  	self.maxY = 1
	end
	self.miniScaleX = self.miniMapWidth/self.mapWidth
	self.miniScaleY = self.miniMapHeight/self.mapHeight

	self:registerEvent()
	self:initMiniMap()
	
end

--创建半透黑屏
function ExploreMapControler:createBlackImage(  )
	self.blackImage =FuncRes.a_black( GameVars.width * 2 ,GameVars.height *2 ,200 )
	self.blackImage:setLockTransform(true)
	self.blackImage:pos(GameVars.width/2,GameVars.height/2)
	self.blackImage:visible(false)
	self.blackImage:addto(self.a22,FuncGuildExplore.zorderMap.black)
end


--初始化坐标
function ExploreMapControler:initMapPos(  )
	local rolesPos = GuildExploreModel:getSelfGridPos(  )
	local x,y = FuncGuildExplore.getPosByKey(rolesPos)
	local worldPos = self.gridControler:getGridWorldPos( x,y )
	self.focusPos.x = worldPos.x
	self.focusPos.y = worldPos.y
	self:updatePos(-self.focusPos.x - GameVars.width /2, -self.focusPos.y -   GameVars.height /2,true)
	self:refreshTerrain()
end

--注册拖拽事件
function ExploreMapControler:registerEvent()
	--添加一个触摸层
	local touchNode = display.newNode():addto(self.a1)
	touchNode:setContentSize(cc.size(GameVars.width *4,GameVars.height *4))
	touchNode:pos(-GameVars.width,-GameVars.height )

	self.touchNode = touchNode
	EaseMapControler:startEaseMapAndDrag(touchNode,c_func(self.onPosChange,self) ,c_func(self.onPosChangeEnd,self),nil,c_func(self.onClickMap,self),c_func(self.onGlobalEnd,self),c_func(self.onMoveFunc,self),c_func(self.onTouchDownFunc,self) )

	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLORE_CLOSEMAPPATH,self.hideCurrentPath,self)
	EventControler:addEventListener(GuildExploreEvent.GUILDEXPLORE_RESUMESCALE,self.resumeScaleInstance,self)

end

--点击按下
function ExploreMapControler:onTouchDownFunc( e )
	if self.currentScaleState == 1 then
		return
	end
	self:onTouchInstanceStart(e)
	self.currentMoveState = 0

end


--开始触摸实例效果
function ExploreMapControler:onTouchInstanceStart( e )
	local eventInstance = self:getEventInstanceByWorldPos( e )
	if eventInstance and eventInstance.myView then
		self._currentEventView = eventInstance.myView  
		local scale = 1.1 
		self._currentEventView:stopAllActions()
		self._currentEventView:runAction(act.bouncein( act.scaleto(3/GameVars.GAMEFRAMERATE ,scale,scale) ) )
		FilterTools.flash_easeBetween(self._currentEventView,3,nil,"oldFt","btnlight")
	end
end

--取消触摸效果
function ExploreMapControler:cancleViewTouchEff(  )
	if not self._currentEventView then
		return 
	end
	
	self._currentEventView:setScale(1)
	self._currentEventView:stopAllActions()
	FilterTools.clearFilter(self._currentEventView)
	self._currentEventView = nil
end



-- 当触摸事件放开---
function ExploreMapControler:onGlobalEnd(e )
	self:cancleViewTouchEff()
end

function ExploreMapControler:onMoveFunc( e )
	self:cancleViewTouchEff()
end

--触发点击事件-  
function ExploreMapControler:onClickMap( e,gridX,gridY )
	--如果是缩放场景期间不允许点击 
	if self.currentScaleState == 1 then
		return
	end
	--这个时候 就需要取消跟随主角
 	self.currentMoveState = 0
	--把直接坐标转成相对坐标
	
	

	local x,y 
	if gridX and gridY then
		x,y =  gridX , gridY
	else
		local turnPos = self.a21:convertToNodeSpaceAR(e)
		x,y = ExplorePosTools:getGridPosByWordPos(turnPos.x,turnPos.y)
	end

	--如果没有这个格子数据 直接renturn
	local data = self.gridControler:getGridData(x,y)
	
	-- self:refreshTerrain()
	if not data then
		return
	end

	

	--如果是调试地图信息的
	if FuncGuildExplore.debugMapInfo then
		self:dumpGridInfo(x,y)
	end


	if self.controler.selfPlayer then
		self.controler.selfPlayer:onClickMap(x,y)
	end
	self._isMoved =false
end




function ExploreMapControler:onPosChange( disx,disy )
	--如果是正在缩放期间是不能拖拽地图的
	if self.currentScaleState == 1 then
		return
	end

	if self.currentMoveState== 1 then
		return
	end

	--为了减轻压力 2帧做一次刷新
	disx = disx * self.dragSpeed
	disy = disy * self.dragSpeed
	if math.abs(disx) > 1 or math.abs(disy) > 1  then
		self._isMoved = true
	end
	--
	self.currentMoveState = 0
	--因为在触摸事件的onmove 频率比 update频率会高很多.所以为了减少刷新压力.需要先缓存移动的坐标
	self:updatePos(self.willArrivePos.x +disx,self.willArrivePos.y + disy)

end

--设置将要刷新
function ExploreMapControler:setWillRefreshCount( value )
	self._willRefreshCount = value
end


function ExploreMapControler:updateFrame(  )

	-- local t1= os.clock()
	if self.controler.updateCount == 20 then
		self.isInitComplete = true
		GuildExploreServer:hideLoadingView( true )
		if self._willRefreshCount ==0 then
			self:setWillRefreshCount(1)
		end
	end

	--刷新云, 云的逻辑和其他的不一样
	self:refreshCloud()

	-- local t1 = os.clock()
	--先做缓动运动
	self:easeFollowTarget()
	--如果是将要刷新的 ,比如 当拖拽事件停留在画面的时候 这个时候需要做一次强制刷新
	if self._willRefreshCount > 0 then
		self._willRefreshCount = self._willRefreshCount -1
		self:refreshTerrain()
		return
	end
	--真实开始运动
	if self.currentPos.x ~= self.willArrivePos.x or self.currentPos.y  ~= self.willArrivePos.y  then
		
		-- local t1 = os.clock()
		self:refreshTerrain()
		-- echo(os.clock() -t1,"______-----------------")
	end



end


function ExploreMapControler:onPosChangeEnd( disx,disy )
	disx = disx * self.dragSpeed
	disy = disy * self.dragSpeed
	self:updatePos(self.willArrivePos.x +disx,self.willArrivePos.y + disy)
	self._isMoved =false
end


--更新坐标
function ExploreMapControler:updatePos(xpos,ypos ,refresh )
	--判断边界
	-- echo(xpos,"____111111",ypos,self.maxX,self.maxY)
	if xpos > self.maxX then
		xpos = self.maxX
	elseif xpos < self.minX then
		xpos = self.minX
	end

	if ypos > self.maxY then
		ypos = self.maxY
	elseif ypos < self.minY then
		ypos = self.minY
	end

	self.willArrivePos.x = xpos
	self.willArrivePos.y = ypos

	if refresh then
		self:setWillRefreshCount(1)
	end

end


--分帧刷新地形
function ExploreMapControler:refreshTerrain(  )
	self.currentPos.x = self.willArrivePos.x
	self.currentPos.y = self.willArrivePos.y
	self.a2:setPosition(self.currentPos.x,self.currentPos.y)
	self._leftDown = self.a21:convertToNodeSpaceAR(originPos)

	if self.controler.mainUI then
		self.controler.mainUI:updateMiniPos()
	end
	

	-- echo(self._leftDown.x,self._leftDown.y,"__skfd_leftDowns")
	if self.currentScaleState == 1 then
		local rightPos = {x= GameVars.width ,y = GameVars.height }
		self._rightTop = self.a21:convertToNodeSpaceAR(rightPos)
	else
		self._rightTop.x = self._leftDown.x + GameVars.width
		self._rightTop.y = self._leftDown.y  + GameVars.height
	end

	self._leftTop.x = self._leftDown.x
	self._leftTop.y = self._rightTop.y

	self._rightDown.x = self._rightTop.x
	self._rightDown.y = self._leftDown.y 
	
	--分别计算这几个点落在哪个grid
	-- a b c d 代表四边形顶点
	local a1,a2,b1,b2,c1,c2 
	b1,b2 = ExplorePosTools:getGridPosByWordPos(self._rightTop.x,self._rightTop.y)
	b1 = b1 - 2
	b2 = b2 - 0

	local startX = b1
	local startY = b2 -1
	
	local endX = b1 + self.screenWidthNums * 2 +1
	local endY = b2 + self.screenHeightNums  + 1
	--如果是缩放过程中  那么添加一个边长
	if self.currentScaleState == 1 then
		startX = startX-1
		endX = endX +1
		startY = startY -1
		endY = endY +1
	end

	--startX和 startY 必须同奇 同偶
	if startX % 2 ~= startY %2 then
		startX = startX -1
	end



	local offsetPerNums = FuncGuildExplore.offsetPerNums
	local xOffsetPerNums = FuncGuildExplore.offsetPerNumsUp
	local xLength = 50
	local yLength  =50

	self.a2:stopAllActions()
	--先重置地形index
	self:resetAllCache()
	self:refreshMist()
	local disX = endX-startX

	local nums = 0
	local delayNums = 0
	local offsetIndex =0
	local yushu= 0;

	local hasCreateMap = {}
	local eventDelayNums= 0

	local mistNums = 0

	for y=startY,endY,1 do
		offsetIndex = offsetIndex +1
		local offset = math.ceil(offsetIndex/offsetPerNums)
		local xStart = startX+offsetIndex-1 - (offset-1)*2 
		local index = 0
		yushu = offsetIndex % offsetPerNums
		for x=xStart,disX + xStart  ,2 do
			index = index +1
			local xOffsetGrid =  math.floor(index/xOffsetPerNums)
			local xoff = -xOffsetGrid
			local yoff = -xOffsetGrid 
			local gridX = x + xoff
			local gridY = y + yoff
			local k1 = FuncGuildExplore.getKeyByPos(gridX,gridY)
			local mapData = self.mapCells[k1]
			--这种算法会有重复的点.是不需要创建的
			if index % xOffsetPerNums ==0 and yushu ==1  then
				mapData = nil
			end

			if not mapData then
				-- echo(gridX,gridY,"这个地形没有-",xoff,yoff)
			else
				local isDelay = self:createOneTerrain(mapData,gridX,gridY,delayNums)

				local event 
				local originX,originY = self.gridControler:getGridOriginPos( gridX,gridY )
				local key = FuncGuildExplore.getKeyByPos(originX,originY)
				if not hasCreateMap[key] then
					--必须不是子格子
					event =  GuildExploreModel:getGridEvent( originX,originY )
					hasCreateMap[key] = true

					--刷新事件
					if event then
						local eventDelay = self:updateOneEvent(mapData,originX,originY,event,key,eventDelayNums)
						if eventDelay then
							eventDelayNums =  eventDelayNums +1
						end
					end
				end
				
				if isDelay then
					delayNums = delayNums +1
				end
				nums = nums+1
			end
			
		end
	end

	-- echo(t1-os.clock(),"____刷新时间22222222222 ")
end

--判断地图是否是运动中
function ExploreMapControler:checkMapIsMoved(  )
	if self._isMoved then
		return true
	end
	if self.currentMoveState == 1 then
		return true
	end
	return false
end

--判断一个instance是否出界了
function ExploreMapControler:checkInstanceIsOut( instance )
	local size = instance:getContentSize()

	local halfWidth = size.width/2
	local halfHeight =size.height
	if instance.pos.x + halfWidth < self._leftTop.x or instance.pos.x - halfWidth  > self._rightTop.x
		or instance.pos.y  >self._leftTop.y or instance.pos.y + halfHeight < self._leftDown.y

	   then
		instance:setIsOut(true)
	else
		instance:setIsOut(false)
	end
end


--创建一个地形数据
function ExploreMapControler:createOneTerrain(data,x,y,delayNums  )
	local terrain = data.terrain
	--如果是装饰直接返回false
	if data.decorate  then
		self:createOneDecorate(data,x,y)
	end

	if data.anim then
		self:updateOneSceneEffect(data, x, y)
	end

	--先从缓存取
	local sp = self:getOneCacheView(self.cacheIdMap.terrain,1)
	local mistSp = self:getOneCacheView(self.cacheIdMap.mists,1)
	--如果没有迷雾

	if  not sp then
		--那么每帧创建5个
		local perNums = 30
		local delayFrame =  math.floor(delayNums/perNums)
		if delayFrame > 0 then
			self.a2:delayCall(c_func(self.delayCreateTerrain,self,data,x,y), delayFrame/GameVars.GAMEFRAMERATE)
		else
			self:delayCreateTerrain(data,x,y)
		end
		-- echo("____is nerw ",x,y)
		return true
	end
	self:updateOneTerrain(data,sp,x,y)
	return false
end

local colorRed = {r = 255,g=0,b=0}
local colorBlack = {r = 255,g=255,b=255}

--更新一个地形
function ExploreMapControler:updateOneTerrain( terrainData,view,x,y )
	view:visible(true)
	self:setTerrainTexture("panel_".. terrainData.terrain,view)
	local pos =   self.gridControler:getGridWorldPos(x,y) -- ExplorePosTools:getGridPos( x,y)
	local canPass = self.gridControler:checkCanPass(x,y)
	view:setPosition(pos.x +view.posOffset[1],pos.y+view.posOffset[2])
	if view.debugTxt then
		view.debugTxt:setString(x..";"..y)
		view.debugTxt:setPosition(pos.x - 30,pos.y+8)
		view.debugTxt:setVisible(true)
		-- view.debugTxt:setVisible(false)
		-- view.debugTxt:setPosition(pos.x,pos.y)
		if canPass then
			view.debugTxt:setTextColor(colorBlack)
		else
			view.debugTxt:setTextColor(colorRed)
		end
	end
	view:zorder(10000-pos.y)
	--如果是不可走的那么文本给红色
end


--更新下迷雾
function ExploreMapControler:refreshMist(  )

	local startX = self._rightTop.x + FuncGuildExplore.mistsWidth
	local startY = self._rightTop.y + FuncGuildExplore.mistsHeight
	local endX =  self._leftTop.x - FuncGuildExplore.mistsWidth
	local endY = self._rightDown.y - FuncGuildExplore.mistsHeight
	--计算网格坐标
	startX,startY =self.gridControler:turnWorldPosToRect(startX,startY  )	
	endX,endY =self.gridControler:turnWorldPosToRect(endX,endY  )	
	if self.currentScaleState == 1 then
		startX = startX -1
		endX = endX + 1
		startY = startY -1
		endY = endY +1
	end


	local nums= 0
	for i=startX,endX do
		for j=startY,endY do
			self:updateOneMists(i,j)
			nums = nums +1
		end
	end

end


--更新一个迷雾
function ExploreMapControler:updateOneMists(  x,y)
	
	local panelName,rotation,rotationY
	-- if self.isInitComplete then
	-- 	--如果目标点不是迷雾
	-- 	if not self.gridControler:checkRectPosIsMists(x,y ) then
	-- 		return
	-- 	end
	-- 	panelName,rotation,rotationY = self.gridControler:getMistsView( x,y )
	-- else
	-- 	panelName,rotation,rotationY = "panel_yun_0_0",0
	-- end

	--如果目标点不是迷雾
	if not self.gridControler:checkRectPosIsMists(x,y ) then
		return
	end
	panelName,rotation,rotationY = self.gridControler:getMistsView( x,y )
	-- if true then
	-- 	return
	-- end
	local groupId = 1
	local view = self:getOneCacheView(self.cacheIdMap.mists,groupId)
	local isCache = true
	if not view then
		isCache =false
		view = display.newSprite():addto(self.a22,FuncGuildExplore.zorderMap.mists)
		self:insertOneCacheView(self.cacheIdMap.mists,groupId,view)

		if FuncGuildExplore.debugGrild == 2 then
			-- if x % 5 ==0 and y%5 ==0 then
			local txt = UIBaseDef:get_txt(self.debugTxtCfg)
			txt:addto(self.a23,1000)
			-- end
			view.debugTxt =txt
		end
	end

	local posx,posy = self.gridControler:turnRectToWorld(x, y)
	
	if panelName then
		view:visible(true)
		self:setTerrainTexture( panelName,view,true)
		if rotationY then
			view:setRotationSkewX(rotation)
			view:setRotationSkewY(rotationY)
		else
			view:setRotationSkewX(rotation)
			view:setRotationSkewY(rotation)
		end
		
		view:setPosition(posx,posy)
	else
		view:setVisible(false)
	end
	
	
	
	if view.debugTxt then
		view.debugTxt:setVisible(true)
		view.debugTxt:setString(x.."_"..y)
		view.debugTxt:setPosition(posx-30,posy+10)
	end

end


function ExploreMapControler:delayCreateTerrain(data,x,y  )
	local terrain = data.terrain
	local sp = display.newSprite()
	sp:anchor(0,1)
	sp:addto(self.a21,10000-y)	
	self:insertOneCacheView(self.cacheIdMap.terrain, 1, sp)
	if FuncGuildExplore.debugGrild == 1 then
		-- if x % 5 ==0 and y%5 ==0 then
		local txt = UIBaseDef:get_txt(self.debugTxtCfg)
		txt:addto(self.a23,1000)
		-- end
		sp.debugTxt =txt

	end

	self:updateOneTerrain(data,sp,x,y)
	
end


function ExploreMapControler:setTerrainTexture(panelName, sp ,autoAnchor)
	local uicfg = self._gridUICfgs[panelName]
	if not uicfg then
		echoError("没有这个地形配置",panelName)
		uicfg = self._gridUICfgs["panel_1"]
	end
	local pngName = uicfg.cfg.img
	local transform = uicfg.cfg.m
	--拿到图片名册和transform
	--如果是用散图的
    if CONFIG_USEDISPERSED then
        -- sp:setTexture("uipng/"..pngName)
        --注意 必须要这样写性能才高. 如果传字符串进去 .那么在c端会频繁遍历寻找对应的texture纹理导致浪费大量的cpu计算
        sp:setTexture(uicfg.texture)
        local size = uicfg.size
        size.x =0
        size.y =0
        sp:setTextureRect(size)
    else
        sp:setSpriteFrame(uicfg.texture)
    end
    -- sp:setPosition(transform[1],transform[2])
    --记录sp的坐标偏移
    sp.posOffset = transform
    if not uicfg.an then
    	local size = sp:getContentSize()
    	--记录描点
    	uicfg.an = {x= (-transform[1])/size.width,y = (size.height -transform[2] ) / size.height  }
    end
    sp.anchorPos = uicfg.an
    if autoAnchor then
    	sp:setAnchorPoint(uicfg.an.x,uicfg.an.y)
    end

end


--创建一个装饰品
function ExploreMapControler:createOneDecorate( data,x,y )
	local decorateId = data.decorate
	-- echo(decorateId,"_____decorateId")
	local instance = self:getOneCacheView(self.cacheIdMap.decorate,1)
	local isCache = true
	if not instance then
		instance = ExploreBaseInstance.new(self.controler,{})
		local sp = display.newSprite()
		
		instance:initView(self.a22, sp)
		isCache = false
		self:insertOneCacheView(self.cacheIdMap.decorate,1, instance)
	end
	local view = instance.myView
	view:setVisible(true)

	-- instance.mySize.width = 
	self:setTerrainTexture("panel_".. decorateId,view,true)

	local pos =  self.gridControler:getGridWorldPos(x,y) -- ExplorePosTools:getGridPos( x,y)
	instance:setPos(pos.x ,pos.y)
end


--更新一个场景特效
function ExploreMapControler:updateOneSceneEffect( data,x,y )
	if not data.anim then
		return
	end
	
	local groupId = data.anim[1].name

	local instance = self:getOneCacheView(self.cacheIdMap.effect, groupId)
	if not instance then
		instance = self:createSceneEff(data.anim)
		instance:addto(self.a22,FuncGuildExplore.zorderMap.effect)
		self:insertOneCacheView(self.cacheIdMap.effect,groupId, instance)
	end

	local pos =  self.gridControler:getGridWorldPos(x,y) -- ExplorePosTools:getGridPos( x,y)
	instance:setPosition(pos.x ,pos.y)
	instance:setVisible(true)

end

--创建一个场景特效 
function ExploreMapControler:createSceneEff(animArr )
	local nd = display.newNode ()
	--
	local ui = self.controler.mainUI
	for i,v in ipairs(animArr) do
		local ani = ui:createUIArmature("UI_xianmengtansuo_a",v.name,nd,true)
		ani:setRotation(v.r)
	end
	return nd

end


--刷新一个地形事件
function ExploreMapControler:updateOneEvent( data,x,y,gridEvent,key, delayFrame )

	if self.gridControler:checkOneGridAllMists( x,y ) then
		return
	end

	local t = gridEvent.type
	local tid = gridEvent.tid
	local cacheId
	local groupId = 1
	local needUpdateTexture =true
	if t == FuncGuildExplore.gridTypeMap.enemy  then
		cacheId = self.cacheIdMap.enemy
		groupId = tonumber(t)*10000 + tonumber(tid)
		needUpdateTexture = false
	elseif t == FuncGuildExplore.gridTypeMap.elite  then
		cacheId = self.cacheIdMap.enemy
		groupId = tonumber(t)*10000 + tonumber(tid)
		needUpdateTexture = false
	elseif t == FuncGuildExplore.gridTypeMap.mine  then
		cacheId = self.cacheIdMap.mine
		groupId = tonumber(t)*10000 + tonumber(tid)
	elseif t == FuncGuildExplore.gridTypeMap.res  then
		cacheId = self.cacheIdMap.res
	elseif t == FuncGuildExplore.gridTypeMap.spring  then
		cacheId = self.cacheIdMap.spring
	elseif t == FuncGuildExplore.gridTypeMap.build  then
		cacheId = self.cacheIdMap.build
		groupId = tonumber(t)*10000 + tonumber(tid)
	end
	-- echo("刷新事件--",x,y,t,tid)
	local eventView = self:getOneCacheView(cacheId,groupId)
	local instance = self.controler:getEventInstance(key)
	if not instance then
		echoError("_--------",x,y,key,"没有找到事件实例")
		return
	end
	if eventView then
		-- echo("拿的是缓存-")
		if eventView.clickBtn then
			if self.currentScaleState == 1 then
				eventView.clickBtn:setVisible(false)
			else
				eventView.clickBtn:setVisible(true)
			end
		end
	else
		eventView = self:createEventView(t,tid)
		eventView:parent(self.a22)
		self:insertOneCacheView( cacheId,groupId,eventView )
	end
	instance:onRefreshView( eventView )
	if needUpdateTexture then
		local targetview = eventView.mainView
		if t == FuncGuildExplore.gridTypeMap.mine then
			-- self:setTerrainTexture(instance.namePanelName,eventView.nameView)
		elseif t == FuncGuildExplore.gridTypeMap.build then
		else
			self:setTerrainTexture(instance.texturePanelName,targetview,true)
		end
	end
end




--根据数据获取视图
function ExploreMapControler:createEventView( t,tid )
	--创建一个视图
	if t == FuncGuildExplore.gridTypeMap.enemy    then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreMonster",tid ,"spineId")
		local view = FuncRes.getSpineViewBySourceId(sourceId,1,false )
		local scale = FuncGuildExplore.getCfgDatasByKey( "ExploreMonster",tid ,"scale") or 10000
		view.currentAni:setScale(scale / 10000)
		self:createClickBtn(view,"btn_2",0,0 )
		return view
	elseif  t == FuncGuildExplore.gridTypeMap.elite   then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreMonster",tid ,"spineId")
		local view = FuncRes.getSpineViewBySourceId(sourceId,1,false )
		-- view.currentAni:setScale(FuncGuildExplore.eliteScale)
		local scale = FuncGuildExplore.getCfgDatasByKey( "ExploreMonster",tid ,"scale") or 10000
		view.currentAni:setScale(scale / 10000)
		self:createClickBtn(view,"btn_2",0,0 )

		local tagHeight = FuncGuildExplore.getCfgDatasByKey( "ExploreMonster",tid ,"tag") or 0

		--需要创建血条
		local panel_xuetiao = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_elite" )
		panel_xuetiao:addto(view):pos(0,tagHeight)
		view.panel_xuetiao = panel_xuetiao

		return view
	elseif t == FuncGuildExplore.gridTypeMap.mine  then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreMine",tid ,"anim")
		local mineType = FuncGuildExplore.getCfgDatasByKey( "ExploreMine",tid ,"mineType")
		--创建矿洞 暂时没有图片 随便用一个资源代替
		local nd = display.newNode()
		local view =  self:createViewByAnim(sourceId)
		view:addto(nd)

		--创建名字sp
		

		self:createClickBtn(nd,"btn_1",-45,-5 )


		--需要创建倒计时 暂时不要倒计时
		-- local panel_time = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_time" )
		-- panel_time:addto(nd):pos(-45,150)
		-- nd.panel_time = panel_time

		local panel_player = UIBaseDef:createPublicComponent( "UI_explore_grid","panel_player" )
		panel_player:addto(nd):pos(-120,-18)

		local nameSp = display.newSprite():addto(panel_player):anchor(0.5,0.5):pos(0,0)
		self:setTerrainTexture("panel_mine_"..mineType, nameSp ,true)

		nd.panel_player = panel_player

		nd.mainView = view 
		nd.nameView = nameSp
		return nd

	elseif t == FuncGuildExplore.gridTypeMap.res  then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreRes",tid ,"img")
		local nd = display.newNode()
		local view =  self:createViewBySourceId(sourceId):addto(nd)
		nd.mainView = view
		local ani = self:createViewByAnim("UI_xianmengtansuo_shanxing"):addto(nd)
		return nd
	elseif t == FuncGuildExplore.gridTypeMap.spring  then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreBuff",tid ,"img")
		local view =  self:createViewBySourceId(sourceId)
		local nd = display.newNode()
		local view =  self:createViewBySourceId(sourceId):addto(nd)
		nd.mainView = view
		local ani = self:createViewByAnim("UI_xianmengtansuo_shui01"):addto(nd)
		ani:pos(-5,10)
		return nd
	elseif t == FuncGuildExplore.gridTypeMap.build  then
		local sourceId = FuncGuildExplore.getCfgDatasByKey( "ExploreCity",tid ,"anim")
		local ani = self:createViewByAnim(sourceId)
		return ani
	end
end

function ExploreMapControler:createViewBySourceId( sourceId )
	local view =   display.newSprite()
	self:setTerrainTexture("panel_"..sourceId, view,true)
	return view
end

function ExploreMapControler:createViewByAnim( animName )
	animName = animName or "UI_xianmengtansuo_zijingshi"
	local ani = self.controler.mainUI:createUIArmature("UI_xianmengtansuo",animName,nil,true)
	return ani
end



function ExploreMapControler:createClickBtn( view,cfgName,x,y )
	local btn = UIBaseDef:createPublicComponent( "UI_explore_grid",cfgName )
	btn:pos(x,y)
	btn:addto(view)
	btn:setTap(c_func(self.onClickEventBtn,self,view))
	view.clickBtn = btn

	if self.currentScaleState == 1 then
		btn:setVisible(false)
	else
		btn:setVisible(true)
	end
end

--给按钮注册点击事件
function ExploreMapControler:onClickEventBtn( view )
	local instance = view._currentInstance
	if not instance then
		return
	end
	self:onClickMap(nil,instance.gridPos.x,instance.gridPos.y)

end


--获取一个缓存的视图
function ExploreMapControler:getOneCacheView(cacheId,groupId)
	local groupData = self:getOneCacheArr(cacheId,groupId)
	local arr = groupData.viewArr
	local index=  groupData.index
	if #arr == 0 then
		return nil
	end
	local info = arr[index +1]
	if info then
		groupData.index = groupData.index +1
		return info
	end
	return nil
end

--获取缓存数据
function ExploreMapControler:getOneCacheArr(cacheId, groupId )
	local chacheMap = self.allCacheMap[cacheId]
	if not  chacheMap[groupId] then
		chacheMap[groupId] = {index = 0,viewArr = {}}
	end
	return chacheMap[groupId]
end


function ExploreMapControler:resetAllCache(  )
	for k,v in pairs(self.cacheIdMap) do
		self:resetCacheIndex(k)
	end
end

--重置缓存数据
function ExploreMapControler:resetCacheIndex(cacheId )
	local chacheMap = self.allCacheMap[cacheId]
	if not chacheMap then
		return
	end
	local resetFunc = resetFuncMap[cacheId]
	for k,v in pairs(chacheMap) do
		v.index =0
		if resetFunc then
			for ii,vv in ipairs(v.viewArr) do
				resetFunc(vv)
			end
		else
			echoError("_没有func",k,"cacheId",cacheId)
		end
	end
end

--插入一条数据
function ExploreMapControler:insertOneCacheView( cacheId,groupId,data )
	local groupData = self:getOneCacheArr(cacheId, groupId )
	groupData.index = groupData.index +1
	table.insert(groupData.viewArr, data)
	if groupData.index ~=  #groupData.viewArr then
		echoError(cacheId,groupId,"拿取缓存数据序列错了",groupData.index,#groupData.viewArr)
	end
end


--显示一条路径
function ExploreMapControler:showOnePath( pathArr,fromX,fromY )
 	self:hideCurrentPath()	
 	self.currentPathArr = pathArr
 	for i=1,#pathArr do
 		local grid = pathArr[i]

 		if i ==#pathArr then
 			self:createOneIcon(grid.x,grid.y,i,0,0,true)
 		else
 			if i == 1 then
 				self:createOneIcon(grid.x,grid.y,i,fromX,fromY,false)
 			else
 				local fromGrid = pathArr[i]
 				self:createOneIcon(grid.x,grid.y,i,fromGrid.x,fromGrid.y,false)
 			end

 		end
 	end

 	-- self:setMapFollowPlayer()

 	
end




--走完一格路径 因为路径随着角色走过的时候 是会隐藏的的
function ExploreMapControler:hideOnePathPos( x,y,index ,isFinal)
	local icon1,icon2 =self:getOneGuideIcon( x,y,index ,isFinal)
	if icon1 then
		icon1:visible(false)
	end
	if icon2 then
		icon2:visible(false)
	end
end 


 --隐藏路径
 function ExploreMapControler:hideCurrentPath(  )
 	
 	if self.currentPathArr then
 		for i=1,#self.cacheGuideIconArr.frontArr do
 			self.cacheGuideIconArr.frontArr[i]:visible(false)
 			-- self.cacheGuideIconArr.frontArr[i][2]:visible(false)
 		end
 		if self.cacheGuideIconArr.final then
 			self.cacheGuideIconArr.final:visible(false)
 		end
 		
 	end
 	self.currentPathArr = nil
 end


--创建一个引导icon
function ExploreMapControler:createOneIcon( gridx,gridy,index ,fromx,fromy, isFinal )
	-- if fromy == gridy and fromx == gridx then
	-- 	return
	-- end
	local sp1 = self:getOneGuideIcon(gridx,gridy,index,isFinal)
	if not sp1 then
		sp1 = display.newSprite()
		
		if not isFinal then
			if self.cacheGuideIconArr.frontArr[index] then
				echoError("___为什么会有这个--",index)
			end
			self.cacheGuideIconArr.frontArr[index] = sp1
			self:setTerrainTexture("panel_yuandian", sp1,true )
			sp1:parent(self.a22,3000 )
		else
			self.cacheGuideIconArr.final = sp1
			self:setTerrainTexture("panel_mubiao", sp1,true )
			sp1:parent(self.a22,3000 )
			
		end
	end
	local worldPos = self.controler.gridControler:getGridWorldPos(gridx,gridy)
	sp1:visible(true)
	sp1:pos(worldPos.x,worldPos.y)
	sp1:setLocalZOrder(100000-worldPos.y*10+5  )

end


--获取一个引导路径显示对象数组 坐标. index是第几个
function ExploreMapControler:getOneGuideIcon(gridx,gridy,index,isFinal )
	local nd 
	if isFinal then
		nd =  self.cacheGuideIconArr.final
		return nd
	else
		return self.cacheGuideIconArr.frontArr[index]
		
	end
	
	return nil
end


--根据世界坐标获取是事件instance
function ExploreMapControler:getEventInstanceByWorldPos( worldPos )
	local gridX,gridY = self:turnWorldPosToGrid(worldPos)
	local originX,originY = self.controler.gridControler:getGridOriginPos( gridX,gridY)
	local key =  FuncGuildExplore.getKeyByPos( originX,originY )
	local eventInstance = self.controler:getEventInstance( key )
	return eventInstance
end

--转化世界坐标为网格坐标
function ExploreMapControler:turnWorldPosToGrid( worldPos )
	local targetPos = self.a21:convertToNodeSpaceAR(worldPos)
	local gridX,gridY = ExplorePosTools:getGridPosByWordPos(targetPos.x,targetPos.y)
	return gridX,gridY
end


function ExploreMapControler:deleteMe(  )
	self.mapCells = nil
	for k,v in pairs(self.allCacheMap) do
		for kk,vv in pairs(v) do
			v[kk] = nil
		end
		self.allCacheMap[k] = nil
	end
	--直接删除所有的map
	self.allCacheMap = nil
	self._gridUICfgs = nil
	self._currentEventView = nil
	EventControler:clearOneObjEvent(self)
end


return ExploreMapControler
