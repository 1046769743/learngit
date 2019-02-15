--
-- Author: xd
-- Date: 2018-07-04 16:11:37
--
ExplorePosTools = class("ExplorePosTools", PosMapTools)
ExplorePosTools.xWay = -1
--初始位置
ExplorePosTools.originGridPos = {x=1,y =1}



--视野半径
local _fieldRadio = 3
--能够看到的视野
local _fieldPoints ={}
--一个点周围应该半透的点范围
local _alphaPoints = {}

--初始化视野
local initFieldFunc = function (  )
	local area = _fieldRadio
	local x= 0
	local y =0
	--和服务器保持一致
	local minX = x - 2 * area
	local maxX = x + 2 * area

	--这里 minY 和maxY 不能乘以2
	local minY = y - 1* area
	local maxY = y + 1* area
	for i=minX,maxX do
		for j=minY,maxY do
			if i%2 == j%2 then
				local abs1 = math.abs(i-x)
				local abs2 = math.abs(j-y)
				if abs1+ abs2 <= area * 2  then
					local key = tostring(i *10000 + j)
					table.insert(_fieldPoints, {i,j})
				end
			end
		end
	end

	--定义外围更大一圈的点为半透 区域

	local nearPoints = FuncGuildExplore.nearPoints
	for i=1,#nearPoints do
		local curPoint = nearPoints[i]
		local nextPoint = nearPoints[i+1]
		if not nextPoint then
			nextPoint = nearPoints[1]
		end
		local addVec = {nextPoint[1]-curPoint[1],nextPoint[2]-curPoint[2]}

		local startPoint = {curPoint[1]*_fieldRadio,curPoint[2]*_fieldRadio}
		for ii=1,_fieldRadio do
			local targetPoint = {startPoint[1]+addVec[1]*(ii-1), startPoint[2]+addVec[2]*(ii-1) }
			table.insert(_alphaPoints, targetPoint)
		end


	end



end

initFieldFunc()



--计算周边N半径范围的点 ,传入一个点数组
--posArr = {"100001","20000",...	}
-- resultMap  就是本地的mapInfo.cells[key].mists =1
function ExplorePosTools:countRadioPoints(posArr,mapCells )
	if true then
		return
	end
	local hasChange
	for i,v in ipairs(posArr) do
		local x,y = FuncGuildExplore.getPosByKey(v)
		--遍历视野范围
		for ii,vv in ipairs(_fieldPoints) do
			local tempX = x+ vv[1]
			local tempY = y + vv[2]
			local newKey = FuncGuildExplore.getKeyByPos(tempX,tempY)
			if  mapCells[newKey] then
				if not  mapCells[newKey].mists or mapCells[newKey].mists ==1 then
					mapCells[newKey].mists = 0
				end
			end
		end

		--标记哪些为半透区域的,如果更外围一圈 是迷雾. 那么设置 他为半透迷雾. 这样可以节省遍历消耗
		-- for ii,vv in ipairs(_alphaPoints) do
		-- 	local tempX = x+ vv[1]
		-- 	local tempY = y + vv[2]
		-- 	local newKey = FuncGuildExplore.getKeyByPos(tempX,tempY)
		-- 	if  mapCells[newKey] then
		-- 		--如果这个地方是迷雾, 那么设置这个地方为半透迷雾状态
		-- 		if  mapCells[newKey].mists  == 1 then
		-- 			mapCells[newKey].alpha = 1
		-- 		end
		-- 	end
		-- end

	end
end

--初始化计算所有半透迷雾
function ExplorePosTools:initCountAlphaMistsPoints(mapCells )
	local nearPoints = FuncGuildExplore.nearPoints
	for k,v in pairs(mapCells) do
		--如果是非迷雾状态,遍历周围一圈 设置他为半透迷雾
		local x,y = FuncGuildExplore.getPosByKey( k )
		if v.mists and  v.mists == 0 then
			for i,v in ipairs(nearPoints) do
				local targetX,targetY = x + v[1],y + v[2]
				local newKey = FuncGuildExplore.getKeyByPos(targetX,targetY )
				local newCellInfo = mapCells[newKey]
				--如果是有迷雾的 那么设置 他的状态为半透
				if newCellInfo and newCellInfo.mists == 1 then
					newCellInfo.alpha = 1
				end
			end
		end

	end

end