--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔寻路控制器
]]

TowerPathControler = class("TowerPathControler")

function TowerPathControler:ctor(controler)
	self.controler = controler

	self.maxXIdx = controler.xNum
	self.maxYIdx = controler.yNum

	-- 环绕点坐标偏移配置
	self.surroundOffsetCfg = FuncTowerMap.surroundPoints

	-- G最小单位，如果扩展不同方向不同的运动权重，可以为不同方向设置不同的G值
	self.unitG = 1
	self.initH = 0
	self.initF = 0
end

function TowerPathControler:resetData()
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
function TowerPathControler:findPath(startPoint,endPoint)
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
		local points = self:getSurroundPoints(minFPoint)

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
			return self:getformatPath(self.closedList,findEndPoint)
		end
	end

	return self:getformatPath(self.closedList)
end

-- 获取格式化路径
function TowerPathControler:getformatPath(list,endPoint) 
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
				if self:getPathLength(bestPath) > self:getPathLength(curPath) then
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

function TowerPathControler:getPathLength(path) 
	local getLength = function(pathPoint)
		if pathPoint.parent == nil then
			return 1
		else
			curPoint = pathPoint
			local count = 1
			while curPoint.parent ~= nil do
				count = count + 1
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
function TowerPathControler:findOnePath(endPoint) 
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
function TowerPathControler:testPrintPath() 
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
function TowerPathControler:getMinPoint(pointsList)  
	local minPoint = pointsList[1]
	for k,v in pairs(pointsList) do
		if minPoint.F > v.F then
			minPoint = v
		end	
	end

	return minPoint
end

-- 找到结束点周围的点
function TowerPathControler:getEndPointSurroundPoints(list)  
	local points = {}
	local sPoints = FuncTowerMap.getSurroundPoints(self.endPoint)

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
function TowerPathControler:getMinHPointList(pointsList)  
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
function TowerPathControler:isSurroundPoint(srcPoint,targetPoint)
	local points = FuncTowerMap.getSurroundPoints(srcPoint)
	for k, v in pairs(points) do
		if v.x == targetPoint.x and v.y == targetPoint.y then
			return true
		end
	end

	return false
end

-- 找出targetPoint的相邻节点
function TowerPathControler:getSurroundPoints(targetPoint)
	local x = targetPoint.x
	local y = targetPoint.y

	local pointsList = {}

	for k,v in pairs(self.surroundOffsetCfg) do
		local newX = x + v.x
		local newY = y + v.y

		-- 找到一个合法且没有阻碍的环绕点
		if self:isValidPoint(newX,newY) and not self:checkBlock(newX,newY) then
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

function TowerPathControler:isValidPoint(x,y)
	if x < 1 or x > self.maxXIdx then
		return false
	elseif y < 1 or y > self.maxYIdx then
		return false
	end 

	return true
end

-- 检查阻挡
function TowerPathControler:checkBlock(x,y)
	local canPass = self.controler:checkCanPass(x,y)
	if canPass then
		return false
	else
		return true
	end
end

function TowerPathControler:deleteMe()
	EventControler:clearOneObjEvent(self)
end

function TowerPathControler:addToOpenList(point) 
	self.openList[#self.openList+1] = point
end

function TowerPathControler:addToClosedList(point) 
	self.closedList[#self.closedList+1] = point
end

function TowerPathControler:deleteFromOpenList(value) 
	table.removebyvalue(self.openList,value,true)
end

function TowerPathControler:calcF(point)
	point.F = point.G + point.H
end

-- 列表中是否包含点  
function TowerPathControler:isExistsPoint(list,point)  
    for i, p in pairs(list) do  
        if (p.x == point.x) and (p.y == point.y) then  
            return true  
        end  
    end

    return false  
end  

-- 从list中
function TowerPathControler:getPoint(list,point)
	for i,p in pairs(list) do
		if p.x == point.x and p.y == point.y then
			return p
		end
	end

	return nil
end

function TowerPathControler:foundPoint(minFPoint,point)
	local G = self:calcG(point)
    if (minFPoint.G + self.unitG) > G then  
    	return
   	else
        point.parent = minFPoint  
        point.G = G  
        self:calcF(point)
    end
end

function TowerPathControler:notFoundPoint(minFPoint,point)  
	point.parent = minFPoint
	point.G = self:calcG(point)
	-- TODO
	point.H = self:calcH(point)
	self:calcF(point)

	-- 加入到openList中
	self:addToOpenList(point)
end

function TowerPathControler:calcH(point) 
	local H = math.max(math.abs(point.x - self.endPoint.x), math.abs(point.y - self.endPoint.y))
	-- local H = math.abs(point.x - self.endPoint.x) / 2 + math.abs(point.y - self.endPoint.y)
	return H
end

function TowerPathControler:calcG(point)
	local G = point.G

	local parentG = 0

	if point.parent then
		parentG = point.parent.G
	end

	return G + parentG
end

function TowerPathControler:deleteMe()
	self.controler = nil
	self.startPoint = nil
	self.endPoint = nil
end

return TowerPathControler
