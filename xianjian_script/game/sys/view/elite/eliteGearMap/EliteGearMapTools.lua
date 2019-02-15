--
--Author:      zhuguangyuan
--DateTime:    2018-02-08 11:31:18
--Description: 机关相关计算类
--


EliteGearMapTools = {}

--固定写死的配置，定义原点pos
local originGridPos = {x=2,y =1}
--定义x的平铺方向
local xWay = -1
-- 格子视觉上的高度
local gridHeight = 20

--先定义六个点 相对与中心的坐标 A,B,C,D,E,F
--A 和D ,B和E, C和F 是相对中心对称点  
--所以只需要给 A B C 3个点相对于中心点的坐标, D,E,F是动态算出来的

local pointArr = {
	{x = -85,y = 20.5}, 		--A 	左上的顶点
	{x = -26, y = 41.5},		--B
	{x = 58, y = 20.5},			--C

	-- {x = 30,y = -13},		--D
	-- {x = -15, y = -26},		--E
	-- {x = -45, y = -13}		--F
}

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

--网格坐标就是N个AC 和N个AE向量的和


-- 获取网格的坐标
function EliteGearMapTools:getGridPos( gridx,gridy )
	--目前 网格坐标 (1,1)是原点
	local disy = gridy - originGridPos.y
	local turnGirdx = gridx - disy*xWay- originGridPos.x 
	-- echo(gridx,gridx,turnGirdx,disy,"________aaaaaaaaaa")
	if turnGirdx % 2 ~= 0 then
		echoError("错误的网格数据:",gridx,gridy,turnGirdx)
		turnGirdx = turnGirdx +1
	end
	local a = Equation.vectorMul( vectorAE,disy * 1 )
	local b = Equation.vectorMul( vectorAC,turnGirdx/2 *xWay  ) 
	local resultVector =  Equation.vectorAdd(a,b)
	return resultVector
end

--判断地图一点是否落在某个格子上
function EliteGearMapTools:checkPosInGrid(x,y,gridx,gridy )
	local gridPos = self:getGridPos( gridx,gridy )
	
	--把这个坐标平移到原点
	local turnPos = {x= x - gridPos.x,y = y - gridPos.y}
	--如果最小比较法没比过 那么直接返回false
	-- echo("turnPos.x=",turnPos.x,turnPos.y)	
	-- echo("gridPos,",gridPos.x,gridPos.y,pos.x,pos.y)
	-- echo("minX=",minX,maxX,minY,maxY)
	if turnPos.x < minX or turnPos.x > maxX or turnPos.y < minY or turnPos.y > maxY then
		return false
	end

	--取一条水平射线 判断这个射线和六边形交点数量 奇数 表示在六边形里面 偶数表示在多边形外边
	return Equation.checkPosInPolygon( turnPos,pointArr )
end

--判断某一点落在哪个格子上
-- pos 真实的视图坐标
-- gridArr 存放网格对象的数组
function EliteGearMapTools:getGridPosByWordPos(pos,gridArr)
	for i,v in ipairs(gridArr) do
		local x,y = pos.x,pos.y

		if not v:hasExplored() then
			y = y - gridHeight
		end

		if self:checkPosInGrid(x,y,v.xIdx,v.yIdx) then
			return v
		end
	end
	return nil
end



-- 根据当前idx,idy 和光运动方向获取下一个光 cube
function EliteGearMapTools:getNextCubeByDirection( Idx,Idy,_direction,_cubeArr )
	if FuncEliteMap.ROTATION_ANGLE.NORTH then

	elseif FuncEliteMap.ROTATION_ANGLE.SOUTH then
	elseif FuncEliteMap.ROTATION_ANGLE.EAST then
	elseif FuncEliteMap.ROTATION_ANGLE.WEST then
	end

	return 
end

return EliteGearMapTools

--[[
	--测试代码
	function Window_test:resetPrologue()
    -- PrologueUtils:resetPrologue()
    -- TutorialManager:resetPologueTurtoailStep()
    -- local sp = ViewSpine.new("eff_30014_linyueru"):addto(self)
    -- sp:playLabel("eff_30014_linyueru_attack2")
    require("game.sys.view.tower.map.EliteGearMapTools")
    local nd = display.newNode():addto(self):pos(100,GameVars.height-100)
    local gridArr = {}
    for i=2,10,2 do
        for j=1,5,2 do
            local sp = display.newSprite("test/aaa1.png"):addto(nd)
            local pos = EliteGearMapTools:getGridPos(i,j)
            sp:pos(pos.x,pos.y)
            table.insert(gridArr, {x = i,y = j,view = sp})
            local sp = display.newSprite("test/aaa1.png"):addto(nd)
            local pos = EliteGearMapTools:getGridPos(i+1,j+1)
            sp:pos(pos.x,pos.y)
            table.insert(gridArr, {x = i+1,y = j+1,view = sp})
        end

    end

    local tempFunc = function (e  )
        local pos = nd:convertToNodeSpaceAR(e)
        local targetGrid = EliteGearMapTools:getGridPosByWordPos( pos,gridArr )
        if self.lastGrid then
            self.lastGrid.view:setScale(1)
        end
        if targetGrid then
            echo(targetGrid.x,targetGrid.y,"__当前在 这个各自")
            targetGrid.view:setScale(1.2)
        else
            echo("_没有选中各自")
        end
        self.lastGrid = targetGrid
    end

    nd:setTouchedFunc(tempFunc, nil, true)

end

]]