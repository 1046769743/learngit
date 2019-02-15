--[[
	Author: 张燕广
	Date:2017-10-25
	Description: 公会活动小游戏地图类
]]

local GuildGameMap  = class("GuildGameMap",function ()
	return display.newNode()
end)

function GuildGameMap:ctor(mapControler)
	self.mapControler = mapControler

	self:initData()
end

-- 初始化地图数据
function GuildGameMap:initData()

	-- self.minMapX = 0
	-- self.maxMapX = 682

	-- 地图可移动范围=场景长度减去屏幕分辨率宽度
	self.widthOfMap = 2680
	self.heightOfMap = GameVars.gameResHeight
	self.minMapX = 0
	self.maxMapX = self.widthOfMap - GameVars.width

	-- 怪位置的正弦振幅
	self._gridAmplitudeX = self.widthOfMap/2
	self._gridAmplitudeY = GameVars.height/3
	-- self._gridOffsetX =  -(self.widthOfMap - GameVars.width) - GameVars.gameResWidth/64
	self._gridOffsetX =  - (self.maxMapX + GameVars.UIOffsetX)
	self._gridOffsetY = -9*GameVars.height/10

	-- 人物走动到的点组成的正弦振幅
	self._playerAmplitudeX = self.widthOfMap/2
	self._playerAmplitudeY = GameVars.height/3
	-- self._playerOffsetX =  -(self.widthOfMap - GameVars.width) - GameVars.gameResWidth/16
	self._playerOffsetX =  - (self.maxMapX + GameVars.UIOffsetX)
	self._playerOffsetY = -11*GameVars.height/10

	-- 人物初识位置
	self.initCharPos = {x=-300,y=-470}
	self.initOtherPlayersPos = {
		{x=-400,y=-570},
		{x=-200,y=-570},
		{x=500,y=-570},
		{x=700,y=-570},
	}
	self.initCharPos.x,self.initCharPos.y = self:getPlayersSettlePoint( 3 )
	self.initOtherPlayersPos[1].x,self.initOtherPlayersPos[1].y = self:getPlayersSettlePoint( 5 )
	self.initOtherPlayersPos[2].x,self.initOtherPlayersPos[2].y = self:getPlayersSettlePoint( 7 )
	self.initOtherPlayersPos[3].x,self.initOtherPlayersPos[3].y = self:getPlayersSettlePoint( 13 )
	self.initOtherPlayersPos[4].x,self.initOtherPlayersPos[4].y = self:getPlayersSettlePoint( 15 )

	self._charLastPos = self.initCharPos

	-- 人物运动边界点
	local top2 = -150
	local bottom2 = -636
	self.borderPoint = {
		leftBottom = {x=-840,y=-635},
		leftTop = {x=-360,y=-200},
		middleBottom = {x=165,y=-635},
		rightTop = {x=655,y=-200},
		rightBottom = {x=1190,y=-635},
	} 
	-- 人物运动边界线
	self.borderLine = {
		line1 = Equation.creat_1_1_b(self.borderPoint.leftBottom,self.borderPoint.leftTop),
		line2 = Equation.creat_1_1_b(self.borderPoint.leftTop,self.borderPoint.middleBottom),
		line3 = Equation.creat_1_1_b(self.borderPoint.middleBottom,self.borderPoint.rightTop),
		line4 = Equation.creat_1_1_b(self.borderPoint.rightTop,self.borderPoint.rightBottom),
	}

	self:cachePanel()
end

-- 初始化地图视图
function GuildGameMap:initMap()
	self:initLayers()
end

-- 初始化层级
function GuildGameMap:initLayers()
	-- 整个地图世界层
	self.worldLayer = display.newNode():addto(self)
	self.worldLayer:pos(0,0)

	-- 整个世界最底层背景层(锁妖塔地图后面的场景等在该层)
	self.backLayer = display.newNode():addto(self.worldLayer):pos(0,-GameVars.UIOffsetY )

	-- 整个世界中间层(格子、小怪等在该层)
	self.middleLayer = display.newNode():addto(self.worldLayer)

	-- 游戏中间层 人物
	self.gameMiddleLayer = display.newNode():addto(self.middleLayer)
	self.gameFrontLayer = display.newNode():addto(self.middleLayer)

	-- 整个世界前景层
	self.frontLayer = display.newNode():addto(self.worldLayer):pos(0,-GameVars.UIOffsetY )

	self.touchNode = display.newNode():addTo(self,11)
	self.touchNode:pos(-GameVars.UIOffsetX,-GameVars.height+GameVars.UIOffsetY)
    self.touchNode:setContentSize(cc.size(GameVars.width,GameVars.height))
    self.touchNode:setTouchedFunc(c_func(self.onTouchMapEnd,self), nil, false, c_func(self.onTouchMapBegin,self), c_func(self.onTouchMapMove,self),true,c_func(self.onTouchGlobalEnd,self))

 --    for k,v in pairs(self.borderPoint) do
	-- 	-- -- 点击区域测试代码
	-- 	local node = display.newNode()	
	-- 	local color = color or cc.c4b(0,255,0,120)
	-- 	local layer = cc.LayerColor:create(color)
	-- 	node:addChild(layer)
	-- 	node:setTouchEnabled(true)
	-- 	node:setTouchSwallowEnabled(true)

	-- 	node:addto(self.middleLayer,1):size(10,30)
	-- 	node:anchor(0,0)
	-- 	node:pos(v.x,v.y)
	-- 	layer:setContentSize(node:getContentSize() )
	-- end
end

function GuildGameMap:getMiddleLayer()
	return self.middleLayer
end

function GuildGameMap:getGameMiddleLayer()
	return self.gameMiddleLayer
end

function GuildGameMap:getGameFrontLayer()
	return self.gameFrontLayer
end

-- 移动整个地图
function GuildGameMap:moveMap(newX,newY)
	-- echo("\n\n\n\n\n ================================= 移动地图", newX,newY)
	if GuildActMainModel:isInNewGuide() then
		return
	end

	self.middleLayer:setPosition(newX,newY)
	if self.mapControler.sceneControler then
		self.mapControler.sceneControler:updatePos(newX,newY)
	end
end

function GuildGameMap:getMapPos()
	local posx,posy = self.middleLayer:getPosition()
	return {x=posx,y=posy}
end
-- 开始触摸地图
function GuildGameMap:onTouchMapBegin(event)
	local x,y = event.x,event.y
	if self.mapControler.mapTargetPos then
		self.mapControler.mapTargetPos = nil
	end

	local mapX,mapY = self.middleLayer:getPosition()
	self.downX = event.x - mapX
	self.downY = event.y - mapY

	self.lastX = self.downX
end

-- 移动中
function GuildGameMap:onTouchMapMove(event)
	local x = event.x
    local y = event.y

    if self.lastX and self.downX then
		local worldX = self:getMapBorderPositionX(event.x - self.downX)
		local worldY = self.worldLayer:getPositionY()
		self:moveMap(worldX,worldY)
    end
	
	self.lastX = x
end

-- 触摸结束
function GuildGameMap:onTouchMapEnd(event)
local x = event.x
	local y = event.y
	local targetPos = self:getGameMiddleLayer():convertToNodeSpaceAR(event)

	--修正坐标边界
	if targetPos.y > -300 then
		targetPos.y = -300
	end

	-- self.mapControler.charModel:moveToPoint(targetPos)
	-- GuildActMainModel:sentCurPosition( targetPos )
	local posArr = self:adjustMovingTargetPoint(self._charLastPos,targetPos)
	-- dump(posArr, "移动的点数组", 3)
	if posArr[1] then
		if (GuildActMainModel.frozenRid ~= UserModel:rid()) then
		-- if (self.mapControler.frozenRid ~= UserModel:rid()) then

			self.mapControler.charSpineNode:playLabel("run")
			self.mapControler.charModel:moveByPointArr(posArr)
		else 
			WindowControler:showTips(GameConfig.getLanguage("#tid_guild_088"))
		end
	end
end

function GuildGameMap:adjustMovingTargetPoint(_currentPos,_targetPoint)
	local pointArr = {}
	local currentPos = _currentPos
	local targetPoint = _targetPoint
	dump(_currentPos, "_currentPos")
	dump(_targetPoint, "_targetPoint")

	-- -- 判断当前点和目标点是否在同一个区域
	-- local currentPosZone = self:checkZone( currentPos )
	-- local targetPointZone = self:checkZone( targetPoint )
	-- echo("\n\n________ currentPosZone, targetPointZone ___ ",currentPosZone, targetPointZone)

	-- -- 在同一个区域则直接移动过去
	-- -- 在不同区域 则先通过区域联通点  再移动过去
	-- if (currentPosZone>2 and targetPointZone<3) or (currentPosZone<3 and targetPointZone>2) then
	-- 	local targetPoint1 = {}
	-- 	targetPoint1.x = self.borderPoint.middleBottom.x + (targetPointZone-currentPosZone)*20
	-- 	targetPoint1.y = self.borderPoint.middleBottom.y -20
	-- 	targetPoint1.speed = 10
	-- 	pointArr[#pointArr+1] = targetPoint1
	-- 	-- self.mapControler.charModel:moveToPoint(targetPoint1)
	-- 	-- GuildActMainModel:sentCurPosition( targetPoint1 )
	-- 	currentPos = targetPoint1
	-- 	currentPosZone = self:checkZone( currentPos )
	-- 	targetPointZone = self:checkZone( targetPoint )
	-- 	echo("\n\n________ currentPosZone, targetPointZone ___ ",currentPosZone, targetPointZone)
	-- end

	-- local point = nil
	-- if (currentPosZone<3 and targetPointZone<3) then
	-- 	local inOrOut1 = self:checkInOrOut( targetPoint,self.borderLine.line1 ) 
	-- 	local inOrOut2 = self:checkInOrOut( targetPoint,self.borderLine.line2 ) 
	-- 	echo("______ inOrOut1,inOrOut2 _____ ",inOrOut1,inOrOut2)

	-- 	if (inOrOut1 == "in" or inOrOut1 == "at") and (inOrOut2 == "in" or inOrOut2 == "at") then
	-- 	elseif inOrOut1 == "out" then
	-- 		if self:checkInOrOut( currentPos,self.borderLine.line1 ) == "at" then
	-- 			point = currentPos
	-- 		else
	-- 			local lineTemp = Equation.creat_1_1_b(currentPos,targetPoint)
	-- 			point = Equation.pointOf(self.borderLine.line1,lineTemp)
	-- 		end
	-- 	elseif inOrOut2 == "out" then
	-- 		if self:checkInOrOut( currentPos,self.borderLine.line2 ) == "at" then
	-- 			point = currentPos
	-- 		else
	-- 			local lineTemp = Equation.creat_1_1_b(currentPos,targetPoint)
	-- 			point = Equation.pointOf(self.borderLine.line2,lineTemp)
	-- 		end
	-- 	end
	-- 	-- dump(point, "交点")
	-- elseif (currentPosZone>2 and targetPointZone>2) then
	-- 	local inOrOut3 = self:checkInOrOut( targetPoint,self.borderLine.line3 ) 
	-- 	local inOrOut4 = self:checkInOrOut( targetPoint,self.borderLine.line4 ) 
	-- 	echo("______ inOrOut3,inOrOut4 _____ ",inOrOut3,inOrOut4)

	-- 	if (inOrOut3 == "in" or inOrOut3 == "at") and (inOrOut4 == "in" or inOrOut4 == "at") then
	-- 	elseif inOrOut3 == "out" then
	-- 		if self:checkInOrOut( currentPos,self.borderLine.line3 ) == "at" then
	-- 			point = currentPos
	-- 		else			
	-- 			local lineTemp = Equation.creat_1_1_b(currentPos,targetPoint)
	-- 			point = Equation.pointOf(self.borderLine.line3,lineTemp)
	-- 		end
	-- 	elseif inOrOut4 == "out" then
	-- 		if self:checkInOrOut( currentPos,self.borderLine.line4 ) == "at" then
	-- 			point = currentPos
	-- 		else			
	-- 			local lineTemp = Equation.creat_1_1_b(currentPos,targetPoint)
	-- 			point = Equation.pointOf(self.borderLine.line4,lineTemp)
	-- 		end
	-- 	end
	-- 	-- dump(point, "交点")

	-- end
	-- if point then
	-- 	targetPoint.x = point.x
	-- 	targetPoint.y = point.y
	-- end
	
	-- dump(currentPos, "检查重点和当前点是否重合\ncurrentPos")
	-- dump(targetPoint, "targetPoint")

	-- if (currentPos.x ~= targetPoint.x) or (currentPos.y ~= targetPoint.y) then

		-- self.mapControler.charModel:moveToPoint(targetPoint)
		-- 判断点击区域落在某个怪的区域,将目标点换成其区域外的某点A
		-- 让人运动到A,从而防止人与怪重叠
		local leftMap = {"1","2","3","4","5","11","12","13","14","15"}
		local topMap = {"1","20","10","11"}
		for i=1,20 do
			if not self.gridZoneArr[tostring(i)] then
				self:getGridPoint( i )
			end
			local oneZone = self.gridZoneArr[tostring(i)]
			if (targetPoint.x > oneZone.xmin and targetPoint.x < oneZone.xmax)
				and (targetPoint.y > oneZone.ymin and targetPoint.y < oneZone.ymax) then
				-- echo("_____ 点击了 _______",i)
				if table.isValueIn(leftMap,tostring(i)) then
					targetPoint.x = oneZone.xmin
					targetPoint.y = oneZone.ymin - 90
					if table.isValueIn(topMap,tostring(i)) then
						targetPoint.y = oneZone.ymax
						targetPoint.x = oneZone.xmax
					end
				else
					targetPoint.x = oneZone.xmax
					targetPoint.y = oneZone.ymin - 90
					if table.isValueIn(topMap,tostring(i)) then
						targetPoint.y = oneZone.ymax
						targetPoint.x = oneZone.xmin
					end
				end
				break
			end
		end
		local xDis = (targetPoint.x - _currentPos.x)
		local yDis = (targetPoint.y - _currentPos.y)
		-- echo("_______ xDis,yDis ___________",xDis,yDis)
		if (math.abs(xDis) > 15) or (math.abs(xDis) > 15) then
				targetPoint.speed = 10
				pointArr[#pointArr+1] = targetPoint
				self._charLastPos.x = targetPoint.x
				self._charLastPos.y = targetPoint.y
				if (GuildActMainModel.frozenRid ~= UserModel:rid()) then
					GuildActMainModel:sentCurPosition( targetPoint )
				end
		end
	-- end
	return pointArr
end

function GuildGameMap:checkZone( pos )
 	local zone = pos.x < self.borderPoint.middleBottom.x and 
			(pos.x <= self.borderPoint.leftTop.x and 1 or 2) or 
			(pos.x <= self.borderPoint.rightTop.x and 3 or 4)
	return zone
end
function GuildGameMap:checkInOrOut( pos,line )
	local lineY = Equation.lineXtoY(line,pos.x )
	if pos.y > lineY then
		return "out"
	elseif pos.y == lineY then
		return "at"
	else
		return "in"
	end
end
-- 全局触摸结束
function GuildGameMap:onTouchGlobalEnd(event)
	local x = event.x
	local y = event.y
end

-- 检查地图边界
function GuildGameMap:getMapBorderPositionX(_x)
	local x = _x
	local y = _y

	if x <= self.minMapX then
		x = self.minMapX
	elseif x >= self.maxMapX then
		x = self.maxMapX
	end

	return x
end

--
--Author:      zhuguangyuan
--DateTime:    2017-12-05 21:09:53
--Description: 
--
-- 检查点击的点是否超出可点击范围 
-- 若超出 则玩家不做运动
function GuildGameMap:checkIsClickPointOutOfBound( _point )
	-- body
end

-- 获得玩家运动的数组
function GuildGameMap:getPlayersMoveArr( _beginPoint,_endPoint )
	-- body
end



--
--Author:      zhuguangyuan
--DateTime:    2017-12-08 17:56:29
--Description: 场景怪的坐标及人物可走动区域限制
--

-- 获取正弦0~π 之间的10个点
-- _index 从左到右第几个点,
-- _xamplitude x轴的幅度,像素
-- _yamplitude y轴的幅度,像素
function GuildGameMap:getOneSIN( _index,_xamplitude,_yamplitude )
	local index = _index or 1
	local xamplitude = _xamplitude or 800
	local yamplitude = _yamplitude or 350

	local PAI = 3.14

	-- 微调
	-- local dis = (_index > 5) and (11 - _index) or _index 
	-- dis = dis%5
	-- if dis == 0 then
	-- 	dis = 5
	-- end
	-- local offset = (6 - dis) * ((_xamplitude/11)*1/10)
	local offset = 0
	if _index < 6 then
		offset = 0 - offset 
	end
	echo("___________index, offset _______________ ",_index,offset)

	local xpos = index * (_xamplitude/11) + offset
	local ypos = math.sin(xpos*PAI/xamplitude) * yamplitude
	if ypos < 0 then
		ypos = 0 - ypos 
	end
	-- ypos = ypos + (6-dis)*20
	return xpos,ypos 
end

-- 获取怪所在index的格子坐标
function GuildGameMap:getGridPoint( _index )
	if not self.gridPosArr then
		self.gridPosArr = {}
		self.gridZoneArr = {}
	end
	if self.gridPosArr[tostring(_index)] then
		return self.gridPosArr[tostring(_index)].x,self.gridPosArr[tostring(_index)].y
	else
		local index = _index
		local _xpos = 0
		if tonumber(_index) > 20 then
			index = tonumber(_index) - 20
			_xpos = 1 * (self._gridAmplitudeX/11)  - index*100 
		else
			index = tonumber(20 - _index + 1)
			if index > 10 then
				index = index + 1 
			end
			_xpos = index * (self._gridAmplitudeX/11) 
		end
		-- echo("_______ getGridPoint _xpos___________",_xpos)
		local xpos,ypos = self:getSequentialSIN( self._gridAmplitudeX,self._gridAmplitudeY,_xpos )
		xpos = xpos + self._gridOffsetX -- 1 * (self._gridAmplitudeX/11)
		if tonumber(_index) > 10 then
			xpos = xpos + 70
		end
		ypos = ypos + self._gridOffsetY
		self:createOneVisiblePoint( xpos,ypos,255,0,0,self.middleLayer)
		self.gridPosArr[tostring(_index)] = {x=xpos, y=ypos} 
		local offsetx = 70
		local offsety = 70
		self.gridZoneArr[tostring(_index)] = {
			xmin=xpos-offsetx, xmax=xpos+offsetx,
			ymin=ypos-offsety/2, ymax=ypos+offsety*7/4,
		} 
		return xpos,ypos 
	end
end

-- 获取点击位置为index时人物应该走动到目的坐标点
function GuildGameMap:getPlayersSettlePoint( _index )
	local index = tonumber(20 - _index + 1)
	local _xpos = index * (self._playerAmplitudeX/11) --+ offset
	local xpos,ypos = self:getSequentialSIN( self._playerAmplitudeX,self._playerAmplitudeY,_xpos )
	xpos = xpos + self._playerOffsetX
	ypos = ypos + self._playerOffsetY
	self:createOneVisiblePoint( xpos,ypos,255,0,0)
	return xpos,ypos 
end

-- 创建一个可视的点
-- 用于测试
function GuildGameMap:createOneVisiblePoint( _xpos,_ypos,_r,_g,_b,_parentCtn,_sizeWith,_sizeHeight )
	if not self.middleLayer then
		return 
	end
	local node = display.newNode()	
	local r = _r or 255
	local g = _g or 0
	local b = _b or 20
	local color = cc.c4b(0, r, g, b)
	local layer = cc.LayerColor:create(color)
	node:addChild(layer)
	node:setTouchEnabled(true)
	node:setTouchSwallowEnabled(true)
	local parentCtn = _parentCtn or self.middleLayer
	local sizeWith = _sizeWith or 10
	local sizeHeight = _sizeHeight or 30

	node:addto(parentCtn,1):size(_sizeWith,_sizeHeight)
	node:anchor(0,0)
	node:pos(_xpos,_ypos)
	layer:setContentSize(node:getContentSize() )
end

-- 获取连续的sin
-- 根据宽度振幅及高度振幅 及x轴坐标xpos获取点xpos,ypos
function GuildGameMap:getSequentialSIN( _xamplitude,_yamplitude,_xpos )
	local xamplitude = _xamplitude 
	local yamplitude = _yamplitude 
	local PAI = 3.14

	local xpos = _xpos
	local ypos = math.sin(xpos*PAI/xamplitude) * yamplitude
	if ypos < 0 then
		ypos = 0 - ypos 
	end
	return xpos,ypos 
end


function GuildGameMap:cachePanel(  )
	self.cachePanelList = {}
	local panel = UIBaseDef:createPublicComponent( "UI_guildwanfa_zhandou","panel_guai")
	panel:addto(self)
	panel:setVisible(false)
	table.insert(self.cachePanelList, panel)
	-- self.cachePanelList["1"] = panel

	local ctn_guo = UIBaseDef:createPublicComponent( "UI_guildwanfa_zhandou","ctn_guo")
	ctn_guo:addto(self)
	ctn_guo:setVisible(false)
	table.insert(self.cachePanelList, ctn_guo)
	-- self.cachePanelList["1"] = panel


	-- 非食材怪的弹话框
	local panel_bubble = UIBaseDef:createPublicComponent( "UI_guildwanfa_zhandou","panel_bubble")
	panel_bubble:addto(self)
	panel_bubble:setVisible(false)
	table.insert(self.cachePanelList, panel_bubble)
	-- self.cachePanelList["1"] = panel

	local panel_playerTitle = UIBaseDef:createPublicComponent( "UI_guildwanfa_zhandou","panel_playerTitle")
	panel_playerTitle:addto(self)
	panel_playerTitle:setVisible(false)
	table.insert(self.cachePanelList, panel_playerTitle)
	-- self.cachePanelList["1"] = panel

	local txt_monsterName = UIBaseDef:createPublicComponent( "UI_guildwanfa_zhandou","txt_monsterName")
	txt_monsterName:addto(self)
	txt_monsterName:setVisible(false)
	table.insert(self.cachePanelList, txt_monsterName)
	
	-- self.cachePanelList["2"] = ctn_guo
	-- dump(self.cachePanelList,"缓存的panel数据")
end

function GuildGameMap:getCachePanel(  )
	return self.cachePanelList
end

function GuildGameMap:deleteMe()
	EventControler:clearOneObjEvent(self)
end

return GuildGameMap
