--[[
	Author: xd
	Date:2018-07-05
	Description: 寻路控制器
]]

local ExplorePathControler = class("ExplorePathControler")
ExplorePathControler.searchWay = -1 		--搜寻方向 1 就是从起点往终点搜索, -1就是从终点往起点收


function ExplorePathControler:ctor(gridControler)
	self.gridControler = gridControler
	self.surroundPoints = {
		{x=1,y=-1}, --左上
		{x=-1,y=-1},  --右上

		{x=2,y=0},	 --左
		{x=-2,y=0},	 --右

		{x=1,y=1},	 --左下
		{x=-1,y=1}    --右下
	}
	-- G最小单位，如果扩展不同方向不同的运动权重，可以为不同方向设置不同的G值
	self.unitG = 2
	self.initH = 0
	self.initF = 0
	self.countNums = 0
end

function ExplorePathControler:resetData()
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
function ExplorePathControler:findPath(startPoint,endPoint,isTryFindPath)
	
	

	self:resetData()


	if self.searchWay == -1 then
		startPoint,endPoint = endPoint, startPoint
	else
		
	end
	self.startPoint = startPoint
	self.endPoint = endPoint

	-- 如果是同一个点，直接返回空的路径信息
	if startPoint.x == endPoint.x and startPoint.y == endPoint.y then
		return false,{}
	end
	--如果终点周围一圈点都不可到达 直接返回false
	local surroundPoints =  self:getSurroundPoints(endPoint) 
	if #surroundPoints  ==0 then
		return false,{}
	end


	-- 初始化GHF
	startPoint.G = 0
	startPoint.H = 0
	startPoint.F = 0

	self:addToOpenList(startPoint)
	while #self.openList > 0 do
		local minFPoint =  self:getMinPoint(self.openList)
		-- 从openList删除
		self:deleteFromOpenList(minFPoint)
		-- 加入到closedList
		self:addToClosedList(minFPoint)

		-- echo("\n-----------------------------")
		-- echo("minFPoint=",minFPoint.x,minFPoint.y,minFPoint.G)
		-- 找到相邻的点
		local points = self:getSurroundPoints(minFPoint)
		-- dump(points,"__points")
		for i,point in ipairs(points) do
			-- closedList中不存在
			if not self:isExistsPoint(self.closedList,point) then
				-- 如果openList存在该点
				if self:isExistsPoint(self.openList,point) then
					self:foundPoint(minFPoint, point)
				else
					self:notFoundPoint(minFPoint, point)
				end
			end
			--如果已经找到了 那么直接return
			if point.x == endPoint.x and point.y == endPoint.y then
				return self:getformatPath(self.closedList,point)
			end

		end

		-- local findEndPoint = self:getPoint(self.openList,endPoint)
		-- if findEndPoint then
		-- 	-- echo(self.countNums,"___self.countNums1111")
		-- 	return self:getformatPath(self.closedList,findEndPoint)
		-- end
	end
	-- echo(self.countNums,"___self.countNums1111")
	return self:getformatPath(self.closedList)
end

-- 获取格式化路径
function ExplorePathControler:getformatPath(list,endPoint) 
	local pointPath = {}
	-- 如果找到了目标点
	if endPoint then
		local curPoint = endPoint
		if curPoint then
			while curPoint.parent ~= nil do
				table.insert(pointPath,1,curPoint)
				local oldPoint = curPoint
				curPoint.F =nil
				curPoint.G =nil
				curPoint.H =nil
				curPoint = curPoint.parent
				oldPoint.parent = nil
			end
		end
		pointPath = self:checkReversePath(pointPath)
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
		
		for i,v in ipairs(bestPath) do
			v.parent = nil
			v.F =nil
			v.G =nil
			v.H =nil
		end
		-- echo('bestPath------------')
		-- dump(bestPath)
		bestPath = self:checkReversePath(bestPath)
		return false,bestPath
	end
end

function ExplorePathControler:checkReversePath( arr )
	if #arr == 0 then
		return arr
	end
	if self.searchWay == -1 then
		arr = table.reverse(arr)
		table.insert(arr,self.startPoint)
		table.remove(arr,1,1)
	end
	-- dump(arr)
	return arr

end

function ExplorePathControler:getPathLength(path) 
	
	local getLength = function(pathPoint)
		if pathPoint.parent == nil then
			return 1
		else
			local curPoint
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
	for k,v in ipairs(path) do
		length = length + getLength(v)
	end

	return length
end

-- 从list中找到以endPoint为结束点的路径
function ExplorePathControler:findOnePath(endPoint) 
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
function ExplorePathControler:testPrintPath() 
	echo("找到的路径如下--------------------------")
	local pathStr = ""
	local count = 0
	for i,point in ipairs(self.closedList) do
		pathStr = pathStr .. "(" .. point.x .. "," .. point.y .. ")"
		if i ~= count then
			pathStr = pathStr .. "->"
		end
		count = i
	end
end

-- 获取列表中F值最小的点  
function ExplorePathControler:getMinPoint(pointsList)  
	local minPoint = pointsList[1]
	for k,v in ipairs(pointsList) do
		if minPoint.F > v.F then
			minPoint = v
		end	
	end

	return minPoint
end

-- 找到结束点周围的点
function ExplorePathControler:getEndPointSurroundPoints(list)  
	local points = {}
	local sPoints = self:getSurroundPoints(self.endPoint)

	for k,v in ipairs(list) do
		for index,p in ipairs(sPoints) do
			if v.x == p.x and v.y == p.y then
				points[#points+1] = v
			end
		end
	end


	return points
end

-- 获取列表中F值最小的点  
function ExplorePathControler:getMinHPointList(pointsList)  
	local findMinHPoint = function(list)
		local minPoint = list[#list]
		-- for k,v in pairs(list) do
		for i=#list,1,-1 do
			local v = list[i]
			if minPoint.H > v.H and v.H >0 then
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
	for k,v in ipairs(pointsList) do
		if minPoint.H == v.H then
			minHPointList[#minHPointList+1] = v
		end	
	end

	return minHPointList
end

-- targetPoint 是否是srcPoint的相邻点
function ExplorePathControler:isSurroundPoint(srcPoint,targetPoint)
	local points = self:getSurroundPoints(srcPoint)  --FuncEliteMap.getSurroundPoints(srcPoint)
	for k, v in ipairs(points) do
		if v.x == targetPoint.x and v.y == targetPoint.y then
			return true
		end
	end

	return false
end

-- 找出targetPoint的相邻节点 outBlock是否忽略阻挡
function ExplorePathControler:getSurroundPoints(targetPoint,outBlock)
	local x = targetPoint.x
	local y = targetPoint.y

	local pointsList = {}

	for k,v in ipairs(self.surroundPoints) do
		local newX = x + v.x
		local newY = y + v.y

		-- 找到一个合法且没有阻碍的环绕点
		if  outBlock or ( not self:checkBlock(newX,newY) )  then
			local point = {x=newX,y=newY,G=self.unitG}

			-- 只找临近点不找路径时，self.endPoint为nil
			-- if self.endPoint then
			point.H = self:calcH(point)
			-- end
			pointsList[#pointsList+1] = point
		end
	end

	return pointsList
end



-- 检查阻挡 如果是
function ExplorePathControler:checkBlock(x,y)
	-- if isTryFindPath then
	-- 	return false
	-- end
	if x == self.endPoint.x and y == self.endPoint.y then
		return false
	end
	return not self.gridControler:checkCanPass(x,y)
end



function ExplorePathControler:addToOpenList(point) 
	self.openList[#self.openList+1] = point
end

function ExplorePathControler:addToClosedList(point) 
	self.closedList[#self.closedList+1] = point
end

function ExplorePathControler:deleteFromOpenList(value) 
	table.removebyvalue(self.openList,value,true)
end



-- 列表中是否包含点  
function ExplorePathControler:isExistsPoint(list,point)  
    for i, p in ipairs(list) do  
        if (p.x == point.x) and (p.y == point.y) then  
            return true  
        end  
    end

    return false  
end  

-- 从list中
function ExplorePathControler:getPoint(list,point)
	for i,p in ipairs(list) do
		if p.x == point.x and p.y == point.y then
			return p
		end
	end

	return nil
end

function ExplorePathControler:foundPoint(minFPoint,point)
	local G = self:calcG(point)
    if (minFPoint.G + self.unitG) > G then  
    	return
   	else
        point.parent = minFPoint  
        point.G = G  
        self:calcF(point)
    end
end

function ExplorePathControler:notFoundPoint(minFPoint,point)  
	point.parent = minFPoint
	point.G = self:calcG(point)
	-- TODO
	point.H = self:calcH(point)
	self:calcF(point)

	-- 加入到openList中
	self:addToOpenList(point)
end

--找一个点周围可以走的点
function ExplorePathControler:findCanPassPoint( targetPoint,startPoint )
	local roundPoints = self:getSurroundPoints(targetPoint)
	--如果周围都不可走


end


function ExplorePathControler:calcF(point)
	point.F = point.G + point.H
end

function ExplorePathControler:calcH(point) 
	local H =(math.abs(point.x - self.endPoint.x) + math.abs(point.y - self.endPoint.y))
	-- local H = math.abs(point.x - self.endPoint.x) / 2 + math.abs(point.y - self.endPoint.y)
	return H
end

function ExplorePathControler:calcG(point)
	local G = point.G

	local parentG = 0

	if point.parent then
		parentG = point.parent.G
	end

	return G + parentG
end

function ExplorePathControler:deleteMe()
	self.gridControler = nil
	self.startPoint = nil
	self.endPoint = nil
end



return ExplorePathControler
