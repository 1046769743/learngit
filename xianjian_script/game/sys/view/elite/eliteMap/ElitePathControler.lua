--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔寻路控制器
]]

ElitePathControler = class("ElitePathControler")

function ElitePathControler:ctor(controler)
	self.controler = controler

	self.maxXIdx = controler.xNum
	self.maxYIdx = controler.yNum

	-- 环绕点坐标偏移配置
	self.surroundOffsetCfg = FuncEliteMap.surroundPoints

	-- G最小单位，如果扩展不同方向不同的运动权重，可以为不同方向设置不同的G值
	self.unitG = 1
	self.initH = 0
	self.initF = 0
end

function ElitePathControler:resetData()
	self.openList = {}
	self.closedList = {}
end

--[[
	G:S(起点)到当前节点的成本
	H:当前节点到D(终点)的估算成本
	F:F=G+H
]]
-- startPoint = {x=1 ,y=1}
-- 返回值：是否找到 路径数组
function ElitePathControler:findPath(startPoint,endPoint,isTryFindPath)
	if not self.controler then
		return false,{}
	end
	self:resetData()

	self.startPoint = startPoint
	self.endPoint = endPoint

	-- 如果是同一个点，直接返回空的路径信息
	if startPoint.x == endPoint.x and startPoint.y == endPoint.y then
		return false,{}
	end

	if self:isSurroundPoint(startPoint,endPoint) then
		local endGrid = self.controler:findGridModel(endPoint.x,endPoint.y)
		if not endGrid:canStand() then
			return true,{}
		end
	end

	-- 初始化GHF
	startPoint.G = 0
	startPoint.H = 0
	startPoint.F = 0

	self:addToOpenList(startPoint)
	while #self.openList > 0 do
		local minFPoint = self:getMinPoint(self.openList)
		-- 从openList删除
		self:deleteFromOpenList(minFPoint)
		-- 加入到closedList
		self:addToClosedList(minFPoint)

		-- echo("\n-----------------------------")
		-- echo("minFPoint=",minFPoint.x,minFPoint.y,minFPoint.G)
		-- 找到相邻的点
		local points = self:getSurroundPoints(minFPoint,isTryFindPath)

		for i,point in pairs(points) do
			-- closedList中不存在
			if not self:isExistsPoint(self.closedList,point) then
				-- 如果openList存在该点
				if self:isExistsPoint(self.openList,point) then
					self:foundPoint(minFPoint, point)
				else
					self:notFoundPoint(minFPoint, point)
				end
			end
		end

		local findEndPoint = self:getPoint(self.openList,endPoint)
		if findEndPoint then
			-- dump(self.closedList)
			-- self:testPrintPath()
			-- self:addToClosedList(endPoint)
			return self:getformatPath(self.closedList,findEndPoint,isTryFindPath)
		end
	end

	return self:getformatPath(self.closedList)
end

-- 获取格式化路径
function ElitePathControler:getformatPath(list,endPoint,isTryFindPath) 
	local pointPath = {}
	-- 如果找到了目标点
	if endPoint then
		local curPoint = endPoint
		if curPoint then
			while curPoint.parent ~= nil do
				table.insert(pointPath,1,curPoint)
				curPoint = curPoint.parent
			end
		end

		return true,pointPath
	else
		-- 找到离目标点最近的那些点
		-- local minHPointList = self:getMinHPointList(list)
		local minHPointList = self:getEndPointSurroundPoints(list)
		
		local allPathArr = {}

		for i=#minHPointList,1,-1 do
			local endPoint = minHPointList[i]

			local path = self:findOnePath(endPoint)
			if path and #path > 0 then
				if path[1].parent and path[1].parent == self.startPoint then
					allPathArr[#allPathArr+1] = path
				elseif path[1].x == self.startPoint.x and path[1].y == self.startPoint.y then
					allPathArr[#allPathArr+1] = path
				end
			end
		end

		-- 找到最短的那条路径
		local bestPath = {}
		if #allPathArr > 0 then
			bestPath = allPathArr[1]
			for i=1,#allPathArr do
				local curPath = allPathArr[i]
				if self:getPathLength(bestPath,isTryFindPath) > self:getPathLength(curPath,isTryFindPath) then
					bestPath = curPath
				end
			end
		end

		-- echo("所有路径》。。。。。。。。。。")
		-- dump(allPathArr,"---------",10)

		-- echo("最近路径----------")
		-- dump(bestPath)

		-- 如果只有一个点，说明只有起点
		-- if #bestPath == 1 then
		-- 	bestPath = {}
		-- end
		
		-- echo('bestPath------------')
		-- dump(bestPath)
		return false,bestPath
	end
end

function ElitePathControler:getPathLength(path,isTryFindPath) 
	if not self.controler then
		return 0
	end
	local getLength = function(pathPoint)
		if pathPoint.parent == nil then
			return 1
		else
			curPoint = pathPoint
			local count = 1
			while curPoint.parent ~= nil do
				-- 如果是新手引导寻路,优先寻找需再次翻开的格子数最少的路径
				-- 即能通过的格子不算入路径长度
				local isCanPass,hasNotExplore = self.controler:checkCanPass(curPoint.x,curPoint.y,isTryFindPath)
				if isCanPass then
					count = count + 1
					if hasNotExplore then
						count = count + 2
					end
				else
					count = count + 20 
				end
				curPoint = curPoint.parent
			end
			return count
		end	
	end

	local length = 0
	for k,v in pairs(path) do
		length = length + getLength(v)
	end

	return length
end

-- 从list中找到以endPoint为结束点的路径
function ElitePathControler:findOnePath(endPoint) 
	local pointPath = {}

	local curPoint = endPoint
	if curPoint then
		if curPoint.parent then
			while curPoint.parent ~= nil do
				table.insert(pointPath,1,curPoint)
				curPoint = curPoint.parent
			end
		else
			table.insert(pointPath,1,curPoint)
		end
	end

	return pointPath
end

-- test 打印路径信息
function ElitePathControler:testPrintPath() 
	echo("找到的路径如下--------------------------")
	local pathStr = ""
	local count = 0
	for i,point in pairs(self.closedList) do
		pathStr = pathStr .. "(" .. point.x .. "," .. point.y .. ")"
		if i ~= count then
			pathStr = pathStr .. "->"
		end
		count = i
	end
end

-- 获取列表中F值最小的点  
function ElitePathControler:getMinPoint(pointsList)  
	local minPoint = pointsList[1]
	for k,v in pairs(pointsList) do
		if minPoint.F > v.F then
			minPoint = v
		end	
	end

	return minPoint
end

-- 找到结束点周围的点
function ElitePathControler:getEndPointSurroundPoints(list)  
	local points = {}
	local sPoints = FuncEliteMap.getSurroundPoints(self.endPoint)

	for k,v in pairs(list) do
		for index,p in pairs(sPoints) do
			if v.x == p.x and v.y == p.y then
				points[#points+1] = v
			end
		end
	end

	-- echo("路径点。。。。。。")
	-- for k, v in pairs(points) do
	-- 	echo("v-------",v.x,v.y)
	-- end

	return points
end

-- 获取列表中F值最小的点  
function ElitePathControler:getMinHPointList(pointsList)  
	local findMinHPoint = function(list)
		local minPoint = list[#list]
		-- for k,v in pairs(list) do
		for i=#list,1,-1 do
			local v = list[i]
			-- >0 起始点的H为0
			if minPoint.H > v.H and v.H >0 then
			-- if minPoint.H > v.H then
				minPoint = v
			end	
		end

		return minPoint
	end

	local minHPointList = {}
	if pointsList == nil or #pointsList == 0 then
		return minHPointList
	end
	
	local minPoint = findMinHPoint(pointsList)
	for k,v in pairs(pointsList) do
		if minPoint.H == v.H then
			minHPointList[#minHPointList+1] = v
		end	
	end

	return minHPointList
end

-- targetPoint 是否是srcPoint的相邻点
function ElitePathControler:isSurroundPoint(srcPoint,targetPoint)
	local points = FuncEliteMap.getSurroundPoints(srcPoint)
	for k, v in pairs(points) do
		if v.x == targetPoint.x and v.y == targetPoint.y then
			return true
		end
	end

	return false
end

-- 找出targetPoint的相邻节点
function ElitePathControler:getSurroundPoints(targetPoint,isTryFindPath)
	local x = targetPoint.x
	local y = targetPoint.y

	local pointsList = {}

	for k,v in pairs(self.surroundOffsetCfg) do
		local newX = x + v.x
		local newY = y + v.y

		-- 找到一个合法且没有阻碍的环绕点
		if self:isValidPoint(newX,newY) and not self:checkBlock(newX,newY,isTryFindPath) then
			local point = {x=newX,y=newY,G=self.unitG}

			-- 只找临近点不找路径时，self.endPoint为nil
			if self.endPoint then
				point.H = self:calcH(point)
			end
			pointsList[#pointsList+1] = point
		end
	end

	return pointsList
end

function ElitePathControler:isValidPoint(x,y)
	if x < 1 or x > self.maxXIdx then
		return false
	elseif y < 1 or y > self.maxYIdx then
		return false
	end 

	return true
end

-- 检查阻挡
function ElitePathControler:checkBlock(x,y,isTryFindPath)
	-- if isTryFindPath then
	-- 	return false
	-- end
	if not self.controler then
		return
	end
	local canPass = self.controler:checkCanPass(x,y,isTryFindPath)
	if canPass then
		return false
	else
		return true
	end
end

function ElitePathControler:deleteMe()
	EventControler:clearOneObjEvent(self)
end

function ElitePathControler:addToOpenList(point) 
	self.openList[#self.openList+1] = point
end

function ElitePathControler:addToClosedList(point) 
	self.closedList[#self.closedList+1] = point
end

function ElitePathControler:deleteFromOpenList(value) 
	table.removebyvalue(self.openList,value,true)
end

function ElitePathControler:calcF(point)
	point.F = point.G + point.H
end

-- 列表中是否包含点  
function ElitePathControler:isExistsPoint(list,point)  
    for i, p in pairs(list) do  
        if (p.x == point.x) and (p.y == point.y) then  
            return true  
        end  
    end

    return false  
end  

-- 从list中
function ElitePathControler:getPoint(list,point)
	for i,p in pairs(list) do
		if p.x == point.x and p.y == point.y then
			return p
		end
	end

	return nil
end

function ElitePathControler:foundPoint(minFPoint,point)
	local G = self:calcG(point)
    if (minFPoint.G + self.unitG) > G then  
    	return
   	else
        point.parent = minFPoint  
        point.G = G  
        self:calcF(point)
    end
end

function ElitePathControler:notFoundPoint(minFPoint,point)  
	point.parent = minFPoint
	point.G = self:calcG(point)
	-- TODO
	point.H = self:calcH(point)
	self:calcF(point)

	-- 加入到openList中
	self:addToOpenList(point)
end

function ElitePathControler:calcH(point) 
	local H = math.max(math.abs(point.x - self.endPoint.x), math.abs(point.y - self.endPoint.y))
	-- local H = math.abs(point.x - self.endPoint.x) / 2 + math.abs(point.y - self.endPoint.y)
	return H
end

function ElitePathControler:calcG(point)
	local G = point.G

	local parentG = 0

	if point.parent then
		parentG = point.parent.G
	end

	return G + parentG
end

function ElitePathControler:deleteMe()
	self.controler = nil
	self.startPoint = nil
	self.endPoint = nil
end

return ElitePathControler
