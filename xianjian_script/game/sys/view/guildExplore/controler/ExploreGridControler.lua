--
-- Author: xd
-- Date: 2018-07-03 14:41:30
-- 网格数据
local FuncGuildExplore = FuncGuildExplore
local ExploreGridControler = class("ExploreGridControler")

--所有的方形迷雾数组
ExploreGridControler._rectMistMap = nil

local mistRadio = FuncGuildExplore.mistRadio

local mistOffset = 2


local borderToPos = {
	{0,-1},{-1,0},{0,1},{1,0},
}

local vecToPos = {
	{1,-1},{-1,-1},{-1,1},{1,1},
}

--周围一圈8个点
local rectNearPoints = {
	{1,-1},{0,-1},{-1,-1},{-1,0},{-1,1},{0,1},{1,1} ,{1,0}
}


--网格数据控制器 
function ExploreGridControler:init( allGridDatas )
	self._originDatas = allGridDatas
	self._rectMistMap = {}

	local startX = -mistRadio
	local startY = -mistRadio-mistOffset
	local endX = mistRadio
	local endY = mistRadio -mistOffset +1
	local t1 = os.clock()

	--初始化给所有地图都设置成迷雾
	local t1 = os.clock()
	if  FuncGuildExplore.isAllMapOpen then
		for k,v in pairs(allGridDatas) do
			v.mists  = 0
		end
	end 
	self:updateBuildMist()
	for k,v in pairs(allGridDatas) do
		if v.mists ==  0 then
			local worldPos = self:getGridWorldPos(v.x,v.y)
			local rectX,recyY = self:turnWorldPosToRect( worldPos.x,worldPos.y )
			for i=startX,endX do
				for j=startY,endY do
					local x = rectX + i 
					local y = recyY + j 
					local key = FuncGuildExplore.getKeyByPos(x,y)
					--比如是迷雾区域才需要赋值, 防止 探索区域被覆盖
					self._rectMistMap[key] = v.mists
				end
			end
		end

		--如果有child
		if v.child then
			for ii,vv in ipairs(v.child) do
				--那么反向代理sub
				if allGridDatas[tonumber(vv)] then
					allGridDatas[tonumber(vv)].sub = k
				end
				
			end
		end

	end

	--如果判断是低端机 直接return
	if  AppInformation:checkIsLowDevice(  ) then
		return
	end


	local mapId = GuildExploreModel:getMapId(  )

	
	local sceneCfgs = FuncGuildExplore.getCfgDatas( "ExploreSceneEffect",mapId )	
	-- dump(sceneCfgs,"__sceneCfgs")
	for k,v in pairs(sceneCfgs) do
		if not allGridDatas[tonumber(k)] then
			echoError("这个场景没有这个坐标:",k,"mapId:",mapId)
		else
			allGridDatas[tonumber(k)].anim = v.anim
		end
		
	end



end

--判断一个网格能否可走
function ExploreGridControler:checkCanPass( x,y )
	local key =  FuncGuildExplore.getKeyByPos( x,y )
	local gridData = self._originDatas[key]
	--如果没有数据 直接返回false
	if not gridData then
		return false
	end
	if gridData.block == 1 then
		return false
	end
	if gridData.eventList then
		local data = GuildExploreModel:getEventData( gridData.eventList[1] )
		if data.visible == 1 then
			return false
		end
		return true
	end
	-- --如果是有类型的 那么不可走
	-- -- echo("ss===",gridData.sub,gridData.type,gridData.type ~= "0")
	-- if not FuncGuildExplore.chkCanWalk(gridData.type) then
	-- 	return false
	-- end
	--如果有 父节点的
	if gridData.sub then
		local subx,suby = FuncGuildExplore.getPosByKey( gridData.sub )
		-- echo("父节点",subx,suby)
		return self:checkCanPass(subx,suby)
	end
	
	return true
end

function ExploreGridControler:getGridData( x,y )
	local key =  FuncGuildExplore.getKeyByPos( x,y )
	return self._originDatas[key]
end

function ExploreGridControler:getGridDataByKey( key )
	return self._originDatas[key]
end

--获取网格原始数据
function ExploreGridControler:getGridOriginData( x,y )
	local data = self:getGridData(x,y)
	if data.sub then
		x,y = FuncGuildExplore.getPosByKey( data.sub )
		return self:getGridData(x,y)
	end
	return data
end

--获取网格原始key
function ExploreGridControler:getGridOriginKey( x,y )
	local data = self:getGridData(x,y)
	if data.sub then
		return tonumber(data.sub)
	end
	return FuncGuildExplore.getKeyByPos(x, y)
end


--获取网格原始数据
function ExploreGridControler:getGridOriginPos( x,y )
	local data = self:getGridData(x,y)
	if not data then
		return x,y
	end
	if data.sub then
		x,y = FuncGuildExplore.getPosByKey( data.sub )
		return x,y
	end
	return x,y
end


---获取一个网格的真实坐标 注意做缓存.减少计算量
function ExploreGridControler:getGridWorldPos( x,y )
	local gridData = self:getGridData(x,y)
	if not gridData then
		return ExplorePosTools:getGridPos(x,y)
	end
	if not gridData.worldPos then
		gridData.worldPos = ExplorePosTools:getGridPos(x,y)
	end
	return gridData.worldPos
end


function ExploreGridControler:getGridWorldPosByKey( key )
	
end


--判断一个2个点是否相邻
function ExploreGridControler:checkPosIsNear( x1,y1,x2,y2 )
	local nearPoints = FuncGuildExplore.nearPoints
	for i,v in ipairs(nearPoints) do
		if (x1-x2 == v[1]) and (y1-y2 == v[2]) then
			return true
		end
	end
	return false

end



--判断矩形坐标是否是迷雾
function ExploreGridControler:checkRectPosIsMists( x,y )
	local key = FuncGuildExplore.getKeyByPos(x, y)

	return self._rectMistMap[key] ~= 0 
end

--判断矩形坐标是否是迷雾
function ExploreGridControler:checkRectPosIsMistsByKey( key )
	return self._rectMistMap[key] ~= 0 
end

--判断网格是否是迷雾
function ExploreGridControler:checkOneGridAllMists( x,y )
	local originData = self:getGridOriginData( x,y )
	if originData.child then
		for i,v in ipairs(originData.child) do
			local x1,y1 = FuncGuildExplore.getPosByKey(v)
			local rt = self:checkGridIsMists(x1,y1)
			if not rt then
				return false
			end
		end
	end

	return self:checkGridIsMists( x,y )

end


--判断某一格是否是迷雾
function ExploreGridControler:checkGridIsMists( x,y )
	local rectX,rectY = self:turnGridToRect(x,y )

	--遍历周围一圈 只要有点探开了 那么判定为探开
	for i,v in ipairs(rectNearPoints) do
		if not self:checkRectPosIsMists( rectX+v[1],rectY+v[2] ) then
			return false
		end
	end
	return true
	-- return self:checkRectPosIsMists( rectX,rectY )
end


--转化网格坐标为 矩形坐标
function ExploreGridControler:turnGridToRect( gridX,gridY )
	local worldPos = self:getGridWorldPos(gridX,gridY)
	return self:turnWorldPosToRect(worldPos.x,worldPos.y)
end

--转化世界坐标为矩形坐标
function ExploreGridControler:turnWorldPosToRect( posx,posy )
	local rectX = math.ceil(-posx/FuncGuildExplore.mistsWidth)
	local rectY = math.ceil(-posy/FuncGuildExplore.mistsHeight)
	return rectX,rectY
end

--转化矩形坐标为世界坐标
function ExploreGridControler:turnRectToWorld( rectX,rectY )
	return -rectX*FuncGuildExplore.mistsWidth,-rectY*FuncGuildExplore.mistsHeight
end



--让大型建筑网格探开
function ExploreGridControler:updateBuildMist(  )
	local data = GuildExploreModel:getAllMapData(  )
	--遍历所有事件 如果是大型建筑 那么让他的格子全部探开
	for k,v in pairs(data.mapInfo.events) do
		--如果是建筑
		local pos = tonumber(v.pos)
		local x,y = FuncGuildExplore.getPosByKey(pos)
		if v.type == FuncGuildExplore.gridTypeMap.build then
			local isShow = FuncGuildExplore.getCfgDatasByKey( "ExploreCity",v.tid ,"isShow")
			if isShow == 1 then
				self:updateOneEventMists( x,y ,false)
			else
				-- self:checkOneEventMists( x,y ,false)
			end
		else
			-- self:checkOneEventMists( x,y ,false)
		end
	end
end

--探开一个事件的所有相关的格子
function ExploreGridControler:updateOneEventMists( x,y ,needSetRectMists)
	local cell = self:getGridData(x, y)
	local subCell

	if (not cell.sub )  and (not cell.child) then
		cell.mists = 0
		if needSetRectMists then
			self:updateOneGridMists(x,y,0)
		end
		
		return
	end
	if cell.child then
		subCell = cell
	else
		subCell = self:getGridDataByKey( cell.sub)
	end
	
	--如果已经探开了那么不需要在处理了
	if subCell.hasCheck == 1  then
		return
	end
	subCell.hasCheck = 1
	subCell.mists = 0
	
	if subCell.child then
		for ii,vv in ipairs(subCell.child) do
			local childCell = self:getGridDataByKey(tonumber(vv))
			local childX,childY = FuncGuildExplore.getPosByKey(vv)
			childCell.mists = 0
			if needSetRectMists then
				self:updateOneGridMists(childX,childY,0)
			end
		end
	end
end

--检查一个事件是否有子格子被探开 如果有 就全部 探开
function ExploreGridControler:checkOneEventMists( x,y,needSetRectMists )
	local cell = self:getGridData(x, y)
	local subCell
	if not cell.child then
		return
	end
	subCell = cell
	if subCell.child then
		for ii,vv in ipairs(subCell.child) do
			local childCell = self:getGridDataByKey(tonumber(vv))
			if childCell.mists == 0 then
				--只要有一个child 被探开了 那么判定这个网格全部被探开
				self:updateOneEventMists(x,y,needSetRectMists)
				break
			end
		end
	end
end


--检查一个事件是否有子格子被探开 如果有 就全部 探开
function ExploreGridControler:checkOneEventNearMists( x,y,needSetRectMists )
	local cell = self:getGridData(x, y)
	local subCell
	if not cell.child then
		return
	end
	subCell = cell

	--外围一圈相邻的点
	local outNearPoints = { }
	local nearPoints = FuncGuildExplore.nearPoints
	

	if subCell.child then
		for ii,vv in ipairs(subCell.child) do

			for iii,vvvv in ipairs(nearPoints) do
				local nearPos = vv + 10000*vvv[1] + vvv[2]
				outNearPoints[nearPos] = true
			end


			local childCell = self:getGridDataByKey(tonumber(vv))
			if childCell.mists == 0 then
				--只要有一个child 被探开了 那么判定这个网格全部被探开
				self:updateOneEventMists(x,y,needSetRectMists)
				break
			end
		end
	end
	--如果周边有一点迷雾是开的 那么就让这个事件开启
	for k,v in pairs(outNearPoints) do
		local childCell = self:getGridDataByKey(tonumber(vv))
		if childCell.mists == 0 then
			--只要有一个child 被探开了 那么判定这个网格全部被探开
			self:updateOneEventMists(x,y,needSetRectMists)
			break
		end
	end

end



--更新一个网格相关所有的迷雾点
function ExploreGridControler:updateOneGridMists( gridX,gridY,mists )

	local startX = -mistRadio
	local startY = -mistRadio -mistOffset
	local endX = mistRadio
	local endY = mistRadio -mistOffset +1

	local worldPos = self:getGridWorldPos(gridX,gridY)
	
	local rectX,recyY = self:turnWorldPosToRect( worldPos.x,worldPos.y )
	for i=startX,endX do
		for j=startY,endY do
			local x = rectX + i 
			local y = recyY + j 

			local key = FuncGuildExplore.getKeyByPos(x,y)
			--比如是迷雾区域才需要赋值, 防止 探索区域被覆盖
			if self._rectMistMap[key] ~= 0 then
				self._rectMistMap[key] = mists
			end

		end
	end
	
end


function ExploreGridControler:updateMists(posArr )
	local hasChange
	for i,v in ipairs(posArr) do
		self._originDatas[tonumber(v)].mists = 0
	end
end




--单边 rotation映射
local borderToRotation = {
	-90,0,90,180
}

--边对应1个点的情况 稍微复杂点 ,暂时换一种方案
-- local borderToVecMap = {
-- 	[1] = {
-- 		[1] = {pos=3,rotationX = 90,rotationY =-90},
-- 		[2] = {pos = 4,rotationX = -90,rotationY =-90},
-- 	},
-- 	[2] = {
-- 		[1] = {pos=4,rotationX = 180,rotationY =0},
-- 		[2] = {pos = 1,rotationX = 0,rotationY =0},
-- 	},

-- 	[3] = {
-- 		[1] = {pos=1,rotationX = -90,rotationY =90},
-- 		[2] = {pos = 2,rotationX = 90,rotationY =90},
-- 	},
-- 	[4] = {
-- 		[1] = {pos= 2,rotationX = 0,rotationY =180},
-- 		[2] = {pos =3,rotationX = 180,rotationY =180},
-- 	},
-- }


--边对应1个点的情况 稍微复杂点
local borderToVecMap = {
	[1] = {
		[1] = {pos=3,rotationX = -90,},
		[2] = {pos = 4,rotationX = -180},
	},
	[2] = {
		[1] = {pos=4,rotationX = 0,},
		[2] = {pos = 1,rotationX = -90},
	},

	[3] = {
		[1] = {pos=1,rotationX = 90},
		[2] = {pos = 2,rotationX = 0},
	},
	[4] = {
		[1] = {pos= 2,rotationX = 180},
		[2] = {pos =3,rotationX = 90},
	},
}


--2边 rotation 映射 
local border2ToRotation = {
	-90,0,90,180,
}

-- 单点对用rotation
local vecToRotation = {
	0,90,180,270,
}
--三点对应rotation
local vec3ToRotation = {
	0,90,180,270,
}

--对点对应rotation
local vec2ToRotation = {
	 0, 90, 180, 270,
}

--相邻2点对应rotation
local vec2NearToRotation = borderToRotation

local borderToPos = {
	{0,-1},{-1,0},{0,1},{1,0},
}

local vecToPos = {
	{1,-1},{-1,-1},{-1,1},{1,1},
}


--先判断相邻四边  上右下左
local borderResultArr = {
	false,false,false,false
}

local vecResultArr = {
	false,false,false,false
}

--获取一个点对应的view名称 和 角度
function ExploreGridControler:getMistsView( x,y )
	

	borderResultArr[1] = self:checkRectPosIsMists(x,y-1 ) 	
	borderResultArr[2] = self:checkRectPosIsMists(x-1,y ) 	
	borderResultArr[3] = self:checkRectPosIsMists(x,y+1 ) 	
	borderResultArr[4] = self:checkRectPosIsMists(x+1,y ) 	

	vecResultArr[1] = self:checkRectPosIsMists(x+1,y-1 ) 	
	vecResultArr[2] = self:checkRectPosIsMists(x-1,y-1 ) 	
	vecResultArr[3] = self:checkRectPosIsMists(x-1,y+1 ) 
	vecResultArr[4] = self:checkRectPosIsMists(x+1,y+1 ) 

	local borderNums = 0
	local borderArr = {}
	local vecArr = {}
	local vecNums = 0
	--先找只有一边的 探开的
	for i,v in ipairs(borderResultArr) do
		if  v ==false then
			borderNums = borderNums + 1
			table.insert(borderArr, i)
		end
	end

	--如果3边探开了 那么判定为探开了
	-- if borderNums >= 3 then
	-- 	return 
	-- end

	for i,v in ipairs(vecResultArr) do
		if not v then
			vecNums = vecNums + 1
			table.insert(vecArr, i)
		end
	end

	local panelName
	local rotation =0
	local rotationY = nil
	local scaleX

	local borderIndex
	--如果只有一边
	if (borderNums == 1)  then
		borderIndex = borderArr[1]
		--遍历 顶点,判断是否有不相连的
		-- 如果对边顶点是有渐变的 那么 得用另外2种形态

		local borderVecInfo = borderToVecMap[borderIndex]
 		local nums = 0
 		local info  =nil
		for i,v in ipairs(vecArr) do
			if v == borderVecInfo[1].pos  then
				nums = nums +1
				info = borderVecInfo[1]
			elseif v == borderVecInfo[2].pos  then
				nums = nums +1
				info = borderVecInfo[2]
			end
		end
		--如果是对应2个点了 那么就是边对双点
		if nums == 2 then
			--废弃2-2
			-- panelName = "panel_yun_2_2"
			panelName = false
			if borderIndex ==1 or borderIndex == 3 then
				rotation = 90
			end
		elseif nums == 1 then
			--暂时废弃panel_yun_2_1,废弃了panel_yun_2_2
			-- panelName = "panel_yun_2_1"
			panelName = "panel_yun_1_0"
			-- rotationY = info.rotationY
			rotation = info.rotationX

			

		else
			panelName = "panel_yun_2_0"
			rotation = borderToRotation[borderIndex]
		end
	elseif borderNums == 2 then
		--如果是2边 
		borderIndex =  borderArr[1]
		local borderIndex2 =  borderArr[2]
		local borderOffeset1 = borderToPos[borderIndex]
		local borderOffeset2 = borderToPos[borderIndex2]
		--如果是相邻的边
		if borderOffeset1[1] ~= borderOffeset2[1] and borderOffeset1[2] ~= borderOffeset2[2] then
			panelName = "panel_yun_1_0"
			if borderIndex2 - borderIndex == 1 then
				rotation = border2ToRotation[borderIndex]

			else
				rotation = border2ToRotation[4]
			end

			local targetMacthVec
			--如果是2边加对角的 那么就直接不显示了
			if borderIndex == 1 and borderIndex2 ==4 then
				targetMacthVec = 3 
			else
				targetMacthVec = borderIndex-1
				if targetMacthVec ==0 then
					targetMacthVec =4
				end
			end

			for i,v in ipairs(vecArr) do
				if v == targetMacthVec then
					panelName = nil
					break
				end

			end

		else
			-- --那么就走对边
			--暂时废弃 panel_yun_2_2
			-- panelName = "panel_yun_2_2"
			-- --如果是上下对边渐变 那么就旋转90
			-- if borderIndex == 1 then
			-- 	rotation = 90
			-- end
			panelName = false
			return
		end

	elseif borderNums >= 3 then
		panelName = false
	else
		--在单独判断顶点

		if vecNums == 0 then
			panelName = "panel_yun_0_0"
		elseif vecNums == 2 then
			panelName = "panel_yun_1_1"
			--如果是相邻的边
			local vecIndex1 = vecArr[1]
			local vecIndex2 = vecArr[2]
			local vecOffset1 = vecToPos[vecIndex1]
			local vecOffset2 = vecToPos[vecIndex2]
			--如果是相邻的2个顶点
			if vecOffset1[1] ==vecOffset2[1] or vecOffset1[2] ==vecOffset2[2]  then
				panelName = "panel_yun_2_0"
				if vecIndex2 ==4 and vecIndex1 ==1 then
					rotation = vec2NearToRotation[4]
				else
					rotation = vec2NearToRotation[vecIndex1]
				end
				
			else
				panelName = "panel_yun_1_1"
				rotation = vec2ToRotation[vecIndex1]
			end
		elseif vecNums == 4 then
			panelName = false
		else
			--只有一个顶点探开
			if vecNums == 1 then
				local vecIndex = vecArr[1]
				rotation = vecToRotation[vecIndex]
				panelName = "panel_yun_3_0"
			else
				local vecIndex = 4
				if vecArr[1] == 2 then
					vecIndex = 1
				else
					for i,v in ipairs(vecArr) do
						if i ~= v then
							vecIndex = i
						end
					end
				end
				
				rotation = vec3ToRotation[vecIndex]
				panelName = "panel_yun_1_0"
			end
		end
	end
	return panelName,rotation,rotationY
end

function ExploreGridControler:checkIsChildGird( x,y )
	local data = self:getGridData(x, y)
	if data.sub then
		return true
	end
	return false
end


return ExploreGridControler

