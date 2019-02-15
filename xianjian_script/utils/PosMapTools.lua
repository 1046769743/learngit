--
-- Author: xd
-- Date: 2018-07-03 17:36:55
-- 子类可以根据需要继承这个类 并调用 PosMapTools:init函数 .传入pointArr
PosMapTools = class("PosMapTools")

--先定义六个点 相对与中心的坐标 A,B,C,D,E,F
--A 和D ,B和E, C和F 是相对中心对称点  
--所以只需要给 A B C 3个点相对于中心点的坐标, D,E,F是动态算出来的
PosMapTools.pointArr = {
	{x = -85,y = 20.5}, 		--A 	左上的顶点
	{x = -26, y = 41.5},		--B
	{x = 58, y = 20.5},			--C

	-- {x = 30,y = -13},		--D
	-- {x = -15, y = -26},		--E
	-- {x = -45, y = -13}		--F
}

--定义x的平铺方向
PosMapTools.xWay = 1
-- 格子视觉上的高度
PosMapTools.gridHeight = 20
--定义原点坐标. 这个需要子类重写
PosMapTools.originGridPos = {x=1,y =0}

function PosMapTools:init( pointArr )
	pointArr = pointArr  or self.pointArr
	self.pointArr = pointArr
	pointArr[4] = Equation.vectorMul(pointArr[1],-1)
	pointArr[5] = Equation.vectorMul(pointArr[2],-1)
	pointArr[6] = Equation.vectorMul(pointArr[3],-1)

	--记录minX ,maxX,minY,maxY
	local minX,maxX,minY,maxY = 10000,-10000,10000,-10000
	for i,v in ipairs(pointArr) do
		minX = math.min(v.x,minX)
		maxX = math.max(v.x,maxX)
		minY = math.min(v.y,minY)
		maxY = math.max(v.y,maxY)
	end

	--向量AC x方向的单位向量
	local vectorAC = Equation.vectorReduce(pointArr[3],pointArr[1])

	--向量AE y方向的单位向量
	local vectorAE = Equation.vectorReduce(pointArr[5],pointArr[1])
	self.minX,self.maxX,self.minY,self.maxY = minX,maxX,minY,maxY
	self.vectorAC = vectorAC
	self.vectorAE = vectorAE

end


--网格坐标就是N个AC 和N个AE向量的和

-- 获取网格的坐标
function PosMapTools:getGridPos( gridx,gridy )
	--目前 网格坐标 (1,1)是原点
	local disy = gridy - self.originGridPos.y
	local turnGirdx = gridx - disy*self.xWay- self.originGridPos.x 
	-- echo(gridx,gridx,turnGirdx,disy,"________aaaaaaaaaa")
	if turnGirdx % 2 ~= 0 then
		echoError("错误的网格数据:",gridx,gridy,turnGirdx)
		turnGirdx = turnGirdx +1
	end
	local a = Equation.vectorMul( self.vectorAE,disy * 1 )
	local b = Equation.vectorMul( self.vectorAC,turnGirdx/2 *self.xWay  ) 
	local resultVector =  Equation.vectorAdd(a,b)
	return resultVector
end

--判断地图一点是否落在某个格子上
function PosMapTools:checkPosInGrid(x,y,gridx,gridy )
	local gridPos = self:getGridPos( gridx,gridy )
	
	--把这个坐标平移到原点
	local turnPos = {x= x - gridPos.x,y = y - gridPos.y}
	--如果最小比较法没比过 那么直接返回false
	-- echo("turnPos.x=",turnPos.x,turnPos.y)	
	-- echo("gridPos,",gridPos.x,gridPos.y,pos.x,pos.y)
	-- echo("minX=",minX,maxX,minY,maxY)
	if turnPos.x < self.minX or turnPos.x > self.maxX or turnPos.y < self.minY or turnPos.y > self.maxY then
		return false
	end

	--取一条水平射线 判断这个射线和六边形交点数量 奇数 表示在六边形里面 偶数表示在多边形外边
	return Equation.checkPosInPolygon( turnPos,self.pointArr )
end


--周围一圈的格子
local roundPosArr = {
	{0,0},{1,-1},{-1,-1},{-2,0},
	{-1,1},{1,1},{2,0}
}
--判断某一点落在哪个格子上
-- pos 真实的视图坐标,这个不是相对显示屏坐标,而是相对于网格容器的坐标
-- gridArr 存放网格对象的数组, 网格对象
function PosMapTools:getGridPosByWordPos(posx,posy)
	-- 假设m * vectorAE * n *vectorAC = pos
	-- 通过公式x*a1 +y*b1 = c,  x*a2 +y*b2 = d .解二元一次方程组
	-- x = (b2*c-b1 * d)/(a1*b2 - a2* b1), y = (a2*c - a1*d)/(a2*b1 - a1*b2)
	--先计算x,y  可能为小数. 然后算出周边一圈的格子 是否符合条件
	local a1 = self.vectorAE.x
	local b1 = self.vectorAC.x
	local a2 = self.vectorAE.y
	local b2 = self.vectorAC.y
	local c = posx
	local d = posy
	local m = (b2*c-b1 * d)/(a1*b2 - a2* b1)
	local n = (a2*c - a1*d)/(a2*b1 - a1*b2)

	--然后倒推在具体是 是在哪个格子上,实际就是 getGridPos这个函数 的反推过程
	local disy = math.round( m)
	local turnGirdx =  n/self.xWay * 2
	local yus = turnGirdx %2
	if yus >= 1 then
		turnGirdx = math.round(turnGirdx-yus) +2
	else
		turnGirdx = math.round(turnGirdx-yus) 
	end
	--遍历这个点周围6个点 以及自身 如果 pos 在这7个grid里面 就返回对应的格子
	--临时的y
	local tempGridY = ( disy + self.originGridPos.y )
	local tempGridX = (turnGirdx+self.originGridPos.x  + disy * self.xWay)
	-- echo(tempGridX,tempGridY,turnGirdx,disy,"_getGridPosByWordPos_")
	for i,v in ipairs(roundPosArr) do
		local targetX = v[1] +tempGridX
		local targetY = v[2] + tempGridY
		local rt = self:checkPosInGrid(posx,posy,targetX ,targetY )
		if rt then
			-- echo(targetX,targetY,"_,targetX,getGridPosByWordPostargetY")
			return targetX,targetY
		end
	end
	echo("出界了---不应该走到这里来")
	--0,0表示出界了
	return nil
end


return PosMapTools