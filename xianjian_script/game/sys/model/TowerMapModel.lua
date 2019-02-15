--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔地图数据类
]]

local TowerMapModel = class("TowerMapModel")

function TowerMapModel:init()
	self:initData()
	self:registerEvent()
end

function TowerMapModel:initData()
	self.hasInited = true
	self.isInitCharPos = true
end

-- 加载地图数据
function TowerMapModel:loadMapData(towerFloor,reversal,curMapName)
	echo("当前地图层self.curTowerFloor-----------",towerFloor)
	self.curTowerFloor = towerFloor
	self.reversal = reversal
	self.curMapName = curMapName

	-- 生成地图数据
	self.curTowerMapData = self:generateTowerMapData(self.curMapName)
	self.maxXNum = table.length(self.curTowerMapData)
	self.maxYNum = table.length(self.curTowerMapData["1"])
end

-- 生成地图数据
function TowerMapModel:generateTowerMapData(mapName)
	local towerMapData = {}
	local reveralValue = TowerMainModel:getTowerMapReveral()

	-- 正常地图数据
	if reveralValue == 0 then
		towerMapData = table.deepCopy(FuncTowerMap.getTowerMapDataByMapName(mapName))
	-- Y轴反转地图数据
	elseif reveralValue == 1 then
		towerMapData = FuncTowerMap.getYReversalMapDataByMapName(mapName)
	end

	return towerMapData
end

function TowerMapModel:updateMapData() 
	if not self.hasInited then
		self:init()
	end

	-- 重写加载数据
	if self.curTowerFloor ~= TowerMainModel:getCurrentFloor() 
		or self.reversal ~= TowerMainModel:getTowerMapReveral() 
		or self.curMapName ~= TowerMainModel:getCurInUseMapName() then

		local curTowerFloor = TowerMainModel:getCurrentFloor()
		local reversal = TowerMainModel:getTowerMapReveral()
		local curMapName = TowerMainModel:getCurInUseMapName()
		self:loadMapData(curTowerFloor,reversal,curMapName)
		self.needUpdateRandomData = true
		echo("\n\n\n\n _____ 需要用服务器数据初始化本地地图表 ____",self.needUpdateRandomData)
	end

	if self.curTowerMapData then
		local cells = TowerMainModel:towerFloor().cells
		-- 更新格子状态
		TowerMapModel:updateCells(cells)
	end
end

-- 用server数据更新格子状态
function TowerMapModel:updateCells(cells)
	if cells then
		for gridId,v in pairs(cells) do
			local x,y = self:gridIdToPos(gridId)


			if self:isValidGrid(x,y) then
				local gridData = self.curTowerMapData[tostring(x)][tostring(y)]
				local oldgridData = table.deepCopy(gridData)

				local cell = gridData.info
				-- 更新随机的数据
				if v.randomIndex and self.needUpdateRandomData then
					local randomGroupId = cell[FuncTowerMap.GRID_BIT.RAND_ID]
					local cellData = FuncTower.getCellDataByRandomId(randomGroupId,(v.randomIndex+1))
					cellData = string.split(cellData,",")
					if cellData and table.length(cellData)>0 then
						table.deepMerge(cell,cellData)
					end
				end
				-- 更新状态
				local status = tostring(v.status)
				if status ~= "nil" then
					cell[FuncTowerMap.GRID_BIT.STATUS] = status
				end

				-- 如果状态是clear，将ext清空
				if status == FuncTowerMap.GRID_BIT_STATUS.CLEAR then
					cell["ext"] = nil
				end

				--[[
					更新type,格子打开后,里边的事件类型发生变化时,要更新
					1.monster->shop
					2.monster->item
					3.法阵->box
				]]
				if v.type then
					cell[FuncTowerMap.GRID_BIT.TYPE] = tostring(v.type)
				end

				--[[
					更新param
					1.怪从沉睡变成被绕过状态
					2.怪从警戒变成正常状态
				]]
				if v.param then
					local param = tonumber(v.param)
					cell[FuncTowerMap.GRID_BIT.TYPE_PARAM] = param
				end

				--[[
					更新ext
					其他字段内容覆盖
				]]
				for k,value in pairs(v) do
					if k == "ext" then
						if value and value ~= "" then
							local extMap = json.decode(value)
							-- 怪物血量削减量
							local reduceNum = nil
							if extMap.hpPercentReduce then
								local oldData = cell[k]
								local oldHp = 0
								if oldData and oldData.hpPercentReduce then
									oldHp = oldData.hpPercentReduce
								end

								local newHp = tonumber(extMap.hpPercentReduce) 
								reduceNum = newHp - oldHp
							end

							cell[k] = extMap
							if reduceNum then
								cell[k]["reduceNum"] = reduceNum  -- 本次削减量
							end
							-- 更新变化后的道具ID
							if extMap.goodsId then
								cell[FuncTowerMap.GRID_BIT.TYPE_ID] = tostring(extMap.goodsId)
							elseif extMap.shopId then
								cell[FuncTowerMap.GRID_BIT.TYPE_ID] = tostring(extMap.shopId)
							end

							-- 聚灵格子
							if extMap.runeId then
								cell[FuncTowerMap.GRID_BIT.D4_TYPE_ID] = tostring(extMap.runeId)
							end
						end
					else
						cell[k] = value
					end
				end

				if TowerConfig.SHOW_TOWER_DATA then
					local isOk = false
					for k,v in pairs(gridData.info) do
						if oldgridData.info[k] then
							if tostring(oldgridData.info[k]) ~= tostring(v) then
								isOk = true
							end
						end
					end
					if gridData.info[9] == "0" then
						isOk = true
					end
					if not isOk then
						-- dump(oldgridData, "\n\n\n ======= 更新前 ================")
						-- dump(gridData, "======= 更新后 ================")
					end
				end

				if gridData.info[9] then 
					gridData.info[9] = "0"
				end
			else
				echoError("格子坐标非法,x,y=",x,y,self.maxXNum,self.maxYNum)
			end
		end
		self.needUpdateRandomData = false
		echo("\n\n\n\n _____ 每次重置只初始化一次地图 ____",self.needUpdateRandomData)
	end
	-- dump(self.curTowerMapData, "更新后的格子信息")
	-- local gridInfo = self.curTowerMapData[tostring(1)][tostring(2)]
end

function TowerMapModel:registerEvent()

end

-- 是否是睡眠怪
function TowerMapModel:isSleepMonster(monsterId)
	-- TODO 获取怪状态
	if not self.curTowerMapData then
		return false
	end

	for x=1,self.maxXNum do
		for y=1,self.maxYNum do
			if self:isValidGrid(x, y) then
				local gridInfo = self:getGridInfo(x, y)
				local eventType = gridInfo[FuncTowerMap.GRID_BIT.TYPE]
				if eventType == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
					local eventId = gridInfo[FuncTowerMap.GRID_BIT.TYPE_ID]
					if eventId == monsterId then
						local eventStatus = gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
						-- 沉睡或曾经被绕过
						if tonumber(eventStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP
							or tonumber(eventStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED then
							return true
						end
					end
				end
			end
		end
	end

	return false
end

-- 获取商店信息
function TowerMapModel:getShopInfo(x,y)
	local gridData = self.curTowerMapData[tostring(x)][tostring(y)]
	local cell = gridData.info

	local shopInfo = cell.ext
	return shopInfo
end

-- 获取grid数据
function TowerMapModel:getGridInfo(xIdx,yIdx)
	local gridData = self.curTowerMapData[tostring(xIdx)][tostring(yIdx)]
	local gridInfo = gridData.info
	return gridInfo
end

-- 获取地图数据
-- 并不是读取静态数据，还需要结合server返回的数据
function TowerMapModel:getTowerMapData(towerFloor)
	return self.curTowerMapData
end

-- 获取主角出生点格子坐标
function TowerMapModel:getCharBirthGridPos()
	local x = nil
	local y = nil
	local mapData = self.curTowerMapData
	for x,rowData in pairs(mapData) do
		for y,v in pairs(rowData) do
			local info = v.info
			if info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.BIRTH then
				return x,y
			end
		end
	end
end

-- 是否是主角出生地
function TowerMapModel:isCharBirthPos(xIdx,yIdx)
	local charX,charY = self:getCharBirthGridPos()
	if xIdx == charX and yIdx == charY then
		return true
	else
		return false
	end
end

-- 重置地图相关数据
-- function TowerMapModel:resetMapData()
-- 	self:clearCharGridPos()
--     self:resetMapPos()
--     self:clearLocalShopInfo()
-- end

-- 进下一层会清除当前地图数据
function TowerMapModel:clearMapData()
	self:clearCharGridPos()
	self:clearLocalShopInfo()
	self:resetMapPos()
end

-- 保存地图坐标
function TowerMapModel:saveMapPos(xIdx,yIdx)
	LS:prv():set(StorageCode.tower_map_pos,json.encode({x=xIdx,y=yIdx}))
end

-- 获取地图坐标
function TowerMapModel:getMapPos(xIdx,yIdx)
	local posJson = LS:prv():get(StorageCode.tower_map_pos,"")
	if posJson and posJson ~= "" then
		local pos = json.decode(posJson)
		return pos
	else
		return nil
	end
end

function TowerMapModel:resetMapPos()
	LS:prv():set(StorageCode.tower_map_pos,json.encode({x=0,y=0}))
end

-- 重置主角坐标
function TowerMapModel:resetCharGridPos()
	local xIdx,yIdx = self:getCharBirthGridPos()
	self:saveCharGridPos(xIdx,yIdx)
end

-- 保存主角坐标
function TowerMapModel:saveCharGridPos(xIdx,yIdx)
	LS:prv():set(StorageCode.tower_char_pos,json.encode({x=xIdx,y=yIdx}))
end

-- 清除主角坐标
function TowerMapModel:clearCharGridPos()
	LS:prv():set(StorageCode.tower_char_pos,"")
end

-- 获取主角坐标
function TowerMapModel:getCharGridPos()
	local posJson = LS:prv():get(StorageCode.tower_char_pos,"")
	if posJson and posJson ~= "" then
		local pos = json.decode(posJson)
		local xIdx = pos.x
		local yIdx = pos.y
		-- 判断当前坐标是否在已翻开的无事件的空格子上
		if self.isInitCharPos then
			self.isInitCharPos = false
			local isValid = self:isValidCharPos(xIdx,yIdx)
			if isValid then
				return xIdx,yIdx
			else
				return self:getCharBirthGridPos()
			end
		end
		return xIdx,yIdx
	else
		return self:getCharBirthGridPos()
	end
end

--[[
	是否是合法的主角坐标
	1.服务端不记录主角位置
	2.客户端记录主角位置
		如果获取的主角坐标非法，那么使用主角出生地坐标

	主角坐标合法条件
	1.位置所在格子为clear状态
	2.位置所在格子为已探索且事件满足如下条件
	  1).商店
	  2).道具
	  3).沉睡怪
	  4).毒
]]
function TowerMapModel:isValidCharPos(xIdx,yIdx)
	local isValid = false

	if not xIdx or not yIdx then
		return isValid
	end
	
	-- 不是合法的格子坐标
	if not self:isValidGrid(xIdx, yIdx) then
		return isValid
	end

	local validEventType = {
		FuncTowerMap.GRID_BIT_TYPE.EMPTY,
		FuncTowerMap.GRID_BIT_TYPE.ITEM,
		FuncTowerMap.GRID_BIT_TYPE.BIRTH,
		FuncTowerMap.GRID_BIT_TYPE.SHOP,
		FuncTowerMap.GRID_BIT_TYPE.POISON,
	}

	local gridInfo = self:getGridInfo(xIdx,yIdx)
	if gridInfo then
		local gridBitStatus = gridInfo[FuncTowerMap.GRID_BIT.STATUS]
		local gridType = gridInfo[FuncTowerMap.GRID_BIT.TYPE]

		-- 格子被清空或已开启的空格子
		if gridBitStatus == FuncTowerMap.GRID_BIT_STATUS.CLEAR then
			isValid = true
		-- 已探索的格子
		elseif gridBitStatus == FuncTowerMap.GRID_BIT_STATUS.EXPLORED then
			-- 如果是合法类型
			if table.find(validEventType,tostring(gridType)) then
				isValid = true
			-- 如果是怪
			elseif gridType == FuncTowerMap.GRID_BIT_TYPE.MONSTER then
				local eventStatus = gridInfo[FuncTowerMap.GRID_BIT.TYPE_PARAM]
				-- 如果是沉睡怪
				if tonumber(eventStatus) == FuncTowerMap.MONSTER_STATUS.SLEEP
					or tonumber(eventStatus) == FuncTowerMap.MONSTER_STATUS.SKIPED then
					isValid = true
				end
			end
		else
			local shopInfo = self:getShopInfo(xIdx,yIdx)
			if shopInfo ~= nil then
				isValid = true
				return isValid
			end
		end
	end

	return isValid
end

-- 获取通关终结点坐标
function TowerMapModel:getTowerEndPointPos()
	local x = nil
	local y = nil
	local mapData = self.curTowerMapData
	for x,rowData in pairs(mapData) do
		for y,v in pairs(rowData) do
			local info = v.info
			if info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.ENDPOINT then
				return cc.p(x,y)
			end
		end
	end

	return {}
end

-- grid坐标转Id
function TowerMapModel:gridPosToId(xIdx,yIdx)
	return xIdx .. "_" .. yIdx
end

-- grid Id转坐标
function TowerMapModel:gridIdToPos(gridId)
	local arr = string.split(gridId,"_")
	return arr[1],arr[2]
end

-- 获取格子数据
function TowerMapModel:getGridData(xIdx,yIdx)
	local gridData = self.curTowerMapData[tostring(xIdx)][tostring(yIdx)]
	return gridData
end

-- 是否是合法的格子
function TowerMapModel:isValidGrid(xIdx,yIdx)
	xIdx = tonumber(xIdx)
	yIdx = tonumber(yIdx)
	if xIdx < 1 or xIdx > self.maxXNum then
		return false
	elseif yIdx < 1 or yIdx > self.maxYNum then
		return false
	end 

	local gridData = self:getGridData(xIdx,yIdx)
	local gridInfo = gridData.info

	if #gridInfo == 1 then
		return false
	else
		return true
	end
end

-- 获取上次挑战的怪的等级
function TowerMapModel:getLastBattleStar(xIdx,yIdx)
	local star = nil
	local gridData = self:getGridData(xIdx,yIdx)
	if gridData ~= nil then
		local cell = gridData.info
		local extInfo = cell.ext
		if extInfo and extInfo.star then
			star = extInfo.star
		end
	else
		echoError("TowerMapModel:getLastBattleStar xIdx=",xIdx,yIdx)
	end

	return star
end

function TowerMapModel:isHasEventVisible()
	for k,v in pairs(self.curTowerMapData) do
		for m,n in pairs(v) do
			if n.info then
				if n.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.MONSTER 
					or n.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.BOX 
					or  n.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.ITEM then
					 	if n.info[FuncTowerMap.GRID_BIT.STATUS] ~= FuncTowerMap.GRID_BIT_STATUS.CLEAR then
					 		return true
					 	end
				end
			end	
		end	
	end
	return false
end

-- 获取场景格子皮肤
function TowerMapModel:getTowerMapGridSkin(towerFloor)
	local gridSkin = "UI_tower_grid"

	local sceneData = FuncTower.getTowerMapSkinData(towerFloor)

	if sceneData then
		gridSkin = sceneData.skin
	end

	return gridSkin
end

-- 获取场景动画皮肤
function TowerMapModel:getTowerMapSceneSkin(towerFloor)
	local sceneSkin = "map_suoyaotawanfa"

	local sceneData = FuncTower.getTowerMapSkinData(towerFloor)
	if sceneData then
		sceneSkin = sceneData.map
	end
	
	return sceneSkin
end

function TowerMapModel:saveOnClick(eventModel)
	self.eventTempModel = eventModel
end

function TowerMapModel:getOnClick()
	return self.eventTempModel
end

-- 本地保存商店信息，解决打开商店后重启游戏问题
function TowerMapModel:saveLocalShopInfo(xIdx,yIdx)
	local shopInfo = TowerMapModel:getShopInfo(xIdx,yIdx)
	if shopInfo then
		shopInfo.x = xIdx
		shopInfo.y = yIdx
	end
	LS:prv():set(StorageCode.tower_shop_info,json.encode(shopInfo))
end

function TowerMapModel:getLocalShopInfo()
	local jsonStr = LS:prv():get(StorageCode.tower_shop_info)
	local shopInfo = nil
	if jsonStr and jsonStr ~= "" then
		shopInfo = json.decode(jsonStr)
	end

	return shopInfo
end

-- 清除本地商店信息
function TowerMapModel:clearLocalShopInfo()
	LS:prv():set(StorageCode.tower_shop_info,"")
end


-- 四测后这个函数名和他的意义已不对应
-- 之前获取该层的boss的id只是为了标记该层的评论数据和弹幕数据
-- 四测需求改为 每一层的地图数据可能会变化 导致该层的怪也可能变化
-- 所以采用层来标记 而不是之前的该层怪的id作为标记
function TowerMapModel:findBossMonsterId( _floor )
	-- local bossId = nil
	-- local floor = _floor
	-- if not _floor then
	-- 	floor = TowerMainModel:getCurrentFloor()
	-- end
	-- local curMapData = FuncTowerMap.getTowerMapData(floor)
	-- for k,v in pairs(curMapData) do
	-- 	for kk,vv in pairs(v) do
	-- 		-- dump(vv.info,"vv.info")
	-- 		if vv.info[FuncTowerMap.GRID_BIT.TYPE] 
	-- 			and vv.info[FuncTowerMap.GRID_BIT.TYPE] == FuncTowerMap.GRID_BIT_TYPE.MONSTER 
	-- 		then
	-- 			local monsterId = vv.info[FuncTowerMap.GRID_BIT.TYPE_ID]
	-- 			-- echo("_______monsterId_______",monsterId)
	-- 			local data = FuncTower.getMonsterData(monsterId)
	-- 			if data and data.type then
	-- 				if data.type == FuncTowerMap.MONSTER_TYPE.BOSS then
	-- 					bossId = monsterId
	-- 					return bossId
	-- 				end
	-- 			end
	-- 		end
	-- 	end

	-- end
	-- return bossId
	return _floor
end

-- 判断是否有回血格子
function TowerMapModel:checkIsHasRecoverGrid()
	for k,v in pairs(self.curTowerMapData) do
		for kk,vv in pairs(v) do

			if vv.info then
				-- dump(vv.info, "++++++++++++++++++++++++++++++++++++++++++++++++")
				local status = vv.info[FuncTowerMap.GRID_BIT.STATUS]
				local typeId = vv.info[FuncTowerMap.GRID_BIT.D4_TYPE]
				local runeId = vv.info[FuncTowerMap.GRID_BIT.D4_TYPE_ID]
				if status == FuncTowerMap.GRID_BIT_STATUS.NOT_EXPLORE then
					if runeId and (runeId == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN
						or runeId == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.ANGER_REGAIN)
					then
						return runeId
					end

					-- if typeId and runeId then
					-- 	local runeData = FuncTower.getRuneDataByID(runeId)
					-- 	if runeData and 
					-- 		(runeData.runeEventType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.BLOOD_REGAIN
					-- 		or runeData.runeEventType == FuncTowerMap.GRID_BIT_D4_TYPE_PARAM.ANGER_REGAIN)
					-- 	then
					-- 		return true
					-- 	end
					-- end
				end
			end

		end

	end
	return false
end

return TowerMapModel

