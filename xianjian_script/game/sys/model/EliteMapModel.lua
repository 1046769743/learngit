--
--Author:      zhuguangyuan
--DateTime:    2018-02-01 15:19:24
--Description: 精英探索地图数据类
--


local EliteMapModel = class("EliteMapModel")

EliteMapModel.storageCode_exploredGridArr = "EliteMapModel_storageCode_exploredGridArr"
-- EliteMapModel.storageCode_exploredGridArr = "EliteMapModel_storageCode_exploredGridArr"


function EliteMapModel:init()
	self:initData()
	self:registerEvent()
end

function EliteMapModel:initData()
	self.hasInited = true
	self.isInitCharPos = true
end

-- 加载地图数据
function EliteMapModel:loadMapData(eliteChapter,reversal)
	echo("当前地图层 self.curEliteChapter-----------",eliteChapter)
	self.curEliteChapter = eliteChapter
	self.reversal = reversal

	-- 生成地图数据
	self.curEliteMapData = self:generateEliteMapData(self.curEliteChapter)
	-- dump(self.curEliteMapData, "=========== 配置的地图数据  self.curEliteMapData")

	-- 横坐标最大数量 纵坐标最大数量
	self.maxXNum = table.length(self.curEliteMapData)
	self.maxYNum = table.length(self.curEliteMapData["1"])
end

-- 生成地图数据
function EliteMapModel:generateEliteMapData(eliteChapter)
	local eliteMapData = {}
	local reveralValue = 0--EliteMainModel:getTowerMapReveral()

	-- 正常地图数据
	if reveralValue == 0 then
		eliteMapData = table.deepCopy(FuncEliteMap.getOneEliteMapData(eliteChapter))
	-- Y轴反转地图数据
	elseif reveralValue == 1 then
		eliteMapData = FuncEliteMap.getYReversalMapData(eliteChapter)
	end

	return eliteMapData
end

function EliteMapModel:updateMapData(_isForce) 
	if not self.hasInited then
		self:init()
	end
	local curChapter = EliteMainModel:getCurrentChapter()
	-- 重新加载数据
	if (self.curEliteChapter ~= curChapter) or _isForce then
		local curEliteChapter = curChapter
		local reversal = EliteMainModel:getTowerMapReveral()
		self:loadMapData(curEliteChapter,reversal)
	end

	if self.curEliteMapData then
		self:initMapCellsData(curChapter)
	end
	-- dump(self.curEliteMapData, "用历史数据 及 服务器数据更新后的 self.curEliteMapData")
end

--[[
	获取场景地图宝箱总数量
]]
function EliteMapModel:getMapBoxTotalNum(storyId)
	local data = FuncChapter.getStoryDataByStoryId(storyId)
	local eliteDiscoverBox = data.eliteDiscoverBox
	if eliteDiscoverBox then
		return #eliteDiscoverBox
	else
		return 0
	end
end

--[[
	获取场景地图宝箱已获取的数据
]]
function EliteMapModel:getMapBoxGotNum(storyId)
	local chapter = FuncChapter.getChapterByStoryId(storyId)
	local boxStatusData = WorldModel:data()
	local gotNum = 0
	if boxStatusData then
		local curChapterData = boxStatusData[tostring(storyId)]
		if curChapterData then
			local haveGotInt = curChapterData.rewardBit
			if haveGotInt then
				local haveGotBit = number.splitByNum( haveGotInt ,2)
				for k,v in pairs(haveGotBit) do
					if tonumber(v) == 1 then
						gotNum = gotNum + 1
					end
				end
			end
		end
	end

	return gotNum
end

-- 读取配表数据 并进行转化处理
-- 登录游戏时或者进入新章时会调用
function EliteMapModel:initMapCellsData( curChapter )
	local storyId = FuncChapter.getStoryIdByChapter(FuncChapter.stageType.TYPE_STAGE_ELITE,curChapter)

	self.hasExploreGrids = self:getCellStatusData(curChapter)
	local chapterData = FuncChapter.getStoryDataByChapter(curChapter,FuncChapter.stageType.TYPE_STAGE_ELITE)

	local boxStatus = WorldModel:data()
	-- dump(boxStatus, "desciption")
	local haveGotBox = {}
	for k,v in pairs(boxStatus) do
		if k == chapterData.id and v.rewardBit then
			local haveGotInt = v.rewardBit
			local haveGotBit = number.splitByNum( haveGotInt ,2)
			if chapterData and chapterData.eliteDiscoverBox then
				dump(chapterData.eliteDiscoverBox, "###chapterData.eliteDiscoverBox")
				for k,boxId in pairs(chapterData.eliteDiscoverBox) do
					if tostring(haveGotBit[k]) == "1" then
						haveGotBox[boxId] = 1
					end
				end
			end
		end
	end

	-- 默认是否打开所有格子
	local isOpenAllGrid = false
	local radiList = {}
	local curRaidIndex = 1
	-- 判断是否通关全章
	if WorldModel:isPassStory(storyId) then
		isOpenAllGrid = true
		self.hasExploreGrids = {}
		radiList = FuncChapter.getOrderRaidList(storyId)
	else
		if not self.hasExploreGrids then
			self.hasExploreGrids = {}
		end
	end

	-- dump(self.curEliteMapData, "==== self.curEliteMapData vector")
	
	for k,v in pairs(self.curEliteMapData) do
		if type(v) == "table" then
			for kk,vv in pairs(v) do
				if self:isValidGrid(k,kk) then
					local eventType = vv.info[1]
					local infoArr = string.split(eventType,",")
					vv.info[FuncEliteMap.GRID_BIT.TYPE] = infoArr[1]
					if infoArr[1] == FuncEliteMap.GRID_BIT_TYPE.BOX 
						or infoArr[1] == FuncEliteMap.GRID_BIT_TYPE.ORGAN then
					end

					-- 已通关章，强制打开格子
					if isOpenAllGrid then
						vv.info[FuncEliteMap.GRID_BIT.STATUS] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED -- 探索
						if tostring(infoArr[1]) == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
							vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] = radiList[curRaidIndex]
							curRaidIndex = curRaidIndex + 1
						end

						-- dump(vv,"vv------------")
						-- echo("infoArr[2]==",infoArr[2])
					elseif self.hasExploreGrids[k.."_"..kk] then
						vv.info[FuncEliteMap.GRID_BIT.STATUS] = self.hasExploreGrids[k.."_"..kk].status -- 已探索/已清除
						vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] = self.hasExploreGrids[k.."_"..kk].typeId -- 怪id 或者宝箱id
					else
						-- 20180310 增加配置默认翻开格子的需求
						-- 当前配表格子状态不同于锁妖塔 后续如果还有大需求更改的话 要更改配表并修改处理代码
						if tostring(infoArr[1]) == FuncEliteMap.GRID_BIT_TYPE.DEFAULT_OPENED then
							vv.info[FuncEliteMap.GRID_BIT.STATUS] = FuncEliteMap.GRID_BIT_STATUS.EXPLORED -- 探索
							vv.info[FuncEliteMap.GRID_BIT.TYPE] = FuncEliteMap.GRID_BIT_TYPE.EMPTY
						else
							vv.info[FuncEliteMap.GRID_BIT.STATUS] = FuncEliteMap.GRID_BIT_STATUS.NOT_EXPLORE -- 未探索
						end
					end

					-- 已经领取宝箱,清理
					if haveGotBox[infoArr[2]] then 
						vv.info[FuncEliteMap.GRID_BIT.TYPE] = FuncEliteMap.GRID_BIT_TYPE.EMPTY -- 已经领取的宝箱不能再创建,处理为空格子
						vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] = nil -- 宝箱id置空
					end

					if infoArr[2] and (not haveGotBox[infoArr[2]]) then
						vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] = infoArr[2] 
					end
				end
			end
		end
	end
	-- dump(self.curEliteMapData, "==== 处理完成后的数据 self.curEliteMapData")
end

--[[
	判断精英宝箱是否被领取了
]]
function EliteMapModel:checkUsedBox(storyId,boxId)
	local chapterData = FuncChapter.getStoryDataByStoryId(storyId)
	local boxStatusMap = WorldModel:data()

	local hasUsed = false

	if boxStatusMap then
		local data = boxStatusMap[tostring(storyId)]
		if data and data.rewardBit then
			local haveGotInt = data.rewardBit
			local haveGotBit = number.splitByNum( haveGotInt ,2)
			if chapterData and chapterData.eliteDiscoverBox then
				for k,id in pairs(chapterData.eliteDiscoverBox) do
					if tostring(id) == tostring(boxId) and tostring(haveGotBit[k]) == "1" then
						hasUsed = true
						return hasUsed
					end
				end
			end
		else
			return hasUsed
		end
	end

	return hasUsed
end

-- 获取地图探索状态
function EliteMapModel:getCellStatusData(_chapter)
	local encodeData = LS:prv():get(EliteMapModel.storageCode_exploredGridArr..UserModel:rid().."__".._chapter,"null")
	local _chapterTable = json.decode(encodeData)
	echo("______ _chapter ______",_chapter)
	dump(_chapterTable, "_____ 取本章已探索信息 ____", 5)

	if not _chapterTable or _chapterTable == "null" then
		return {}
	else
		return _chapterTable
	end
end

-- 保存地图探索状态
function EliteMapModel:saveCellStatusData( _chapter,_chapterTable,_callBack )
	echo("_______________ _chapter ______________________",_chapter) 
	dump(_chapterTable, "_____ 存本章已探索信息 ____", 5)
	local encodeData = json.encode(_chapterTable)
	LS:prv():set(EliteMapModel.storageCode_exploredGridArr..UserModel:rid().."__".._chapter,encodeData)

	if _callBack then
		_callBack()
	end
end

-- 用server数据更新格子状态
function EliteMapModel:updateCells(cells)
	local _chapter = EliteMainModel:getCurrentChapter()
	-- dump(cells, "========= cells")
	if cells then
		if not self.hasExploreGrids then
			self.hasExploreGrids = self:getCellStatusData(_chapter)
		end

		for gridId,v in pairs(cells) do
			self.hasExploreGrids[gridId] = v
			local x,y = self:gridIdToPos(gridId)

			if self:isValidGrid(x,y) then
				if not self.curEliteMapData then
					self:updateMapData() 
				end
				local gridData = self.curEliteMapData[tostring(x)][tostring(y)]
				local cell = gridData.info

				-- 更新状态
				local status = tostring(v.status)
				cell[FuncEliteMap.GRID_BIT.STATUS] = status

				-- 如果状态是clear，将ext清空
				if v.status == FuncEliteMap.GRID_BIT_STATUS.CLEAR then
					-- cell["ext"] = nil
					-- -- 更新剩余宝箱的数量
					-- if cell[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.BOX 
					-- 	or cell[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.ORGAN 
					-- then
					-- 	self.leftBoxNum = self.leftBoxNum - 1
					-- 	echoWarn("_________ self.leftBoxNum - 1 ___________",self.leftBoxNum)
					-- end
				end

				--[[
					更新type
					1.monster->shop
					2.monster->item
					3.法阵->box
				]]
				if v.type then
					cell[FuncEliteMap.GRID_BIT.TYPE] = tostring(v.type)
				end

				--[[
					更新param
					1.怪从沉睡变成被绕过状态
					2.怪从警戒变成正常状态
				]]
				if v.typeId then
					cell[FuncEliteMap.GRID_BIT.TYPE_ID] = v.typeId
				end

			else
				echoError("格子坐标非法,x,y=",x,y,self.maxXNum,self.maxYNum)
			end
		end
	end
end

-- 关闭界面的时候或者更换章节的时候需要保存数据到本地
function EliteMapModel:onCloseMapView( _chapter,charGridPos )
	-- 保存数据到本地
	self:saveCellStatusData(_chapter,self.hasExploreGrids, nil)
	EliteMapModel:saveCharGridPos(charGridPos.x,charGridPos.y,_chapter)
end

function EliteMapModel:quickSetData( perfectData )
	if perfectData and table.length(perfectData)>0 then
		for gridId,v in pairs(perfectData) do
			self.hasExploreGrids[gridId] = v
		end
	end
end
-- 获取场景中剩余宝箱数量
function EliteMapModel:getLeftBoxNumber()
	self.leftBoxNum = 0
	for k,v in pairs(self.curEliteMapData) do
		for m,n in pairs(v) do
			if n.info then
				if n.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.ORGAN 
					or n.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.BOX then
					 	if n.info[FuncEliteMap.GRID_BIT.STATUS] ~= FuncEliteMap.GRID_BIT_STATUS.CLEAR then
					 		self.leftBoxNum = self.leftBoxNum + 1
					 		-- return true,n.info[FuncEliteMap.GRID_BIT.TYPE]
					 	end
				end
			end	
		end	
	end
	return self.leftBoxNum
end

-- 判断是否还有未完成的宝箱
function EliteMapModel:isHasEventVisible()
	if self:getLeftBoxNumber() > 0 then
		return true
	else
		return false
	end
	-- for k,v in pairs(self.curEliteMapData) do
	-- 	for m,n in pairs(v) do
	-- 		if n.info then
	-- 			if n.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.ORGAN 
	-- 				or n.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.BOX then
	-- 				 	if n.info[FuncEliteMap.GRID_BIT.STATUS] ~= FuncEliteMap.GRID_BIT_STATUS.CLEAR then
	-- 				 		self.leftBoxNum = self.leftBoxNum + 1
	-- 				 		return true,n.info[FuncEliteMap.GRID_BIT.TYPE]
	-- 				 	end
	-- 			end
	-- 		end	
	-- 	end	
	-- end
	-- return false
end

-- 重置某章的探索状态
function EliteMapModel:resetExploreStatus( _chapter)
	local data = {} 
	echo("_________chapter______",_chapter)
	dump(data, "重置本章数据")

	self.hasExploreGrids = nil
	self:saveCellStatusData(_chapter,self.hasExploreGrids, nil)
	self:clearCharGridPos(_chapter)
	self.leftBoxNum = nil
end

-- 获取刚翻开的格子的怪 对应本章的section
function EliteMapModel:getNextSectionByChapter()
	local num = 1
	local _chapter = EliteMainModel:getCurrentChapter()
	local data = self.curEliteMapData --self:getCellStatusData(_chapter)
	for k,v in pairs(data) do
		for kk,vv in pairs(v) do
			if vv.info 
				and vv.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.MONSTER 
				and vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] 
			then
				num = num + 1
			end
		end
	end
	return num
end

-- 获取待探索的格子数组
-- 用于新手引导路径特效,寻找下一个有怪的格子
function EliteMapModel:getAllToExploreGrids()
	local gridArr = {}
	local data = self.curEliteMapData 
	for k,v in pairs(data) do
		for kk,vv in pairs(v) do
			if vv.info 
				and vv.info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.MONSTER 
				and not vv.info[FuncEliteMap.GRID_BIT.TYPE_ID] 
				then
				gridArr[#gridArr +1] = {x=vv.x,y=vv.y}
			end 
		end
	end
	-- dump(gridArr, "获取待探索的格子数组", nesting)
	return gridArr
end

function EliteMapModel:registerEvent()

end

-- 是否是睡眠怪
function EliteMapModel:isSleepMonster(monsterId)
	-- TODO 获取怪状态
	if not self.curEliteMapData then
		return false
	end

	for x=1,self.maxXNum do
		for y=1,self.maxYNum do
			if self:isValidGrid(x, y) then
				local gridInfo = self:getGridInfo(x, y)
				local eventType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]
				if eventType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
					local eventId = gridInfo[FuncEliteMap.GRID_BIT.TYPE_ID]
					if eventId == monsterId then
						local eventStatus = gridInfo[FuncEliteMap.GRID_BIT.TYPE_PARAM]
						-- 沉睡或曾经被绕过
						if tonumber(eventStatus) == FuncEliteMap.MONSTER_STATUS.SLEEP
							or tonumber(eventStatus) == FuncEliteMap.MONSTER_STATUS.SKIPED then
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
function EliteMapModel:getShopInfo(x,y)
	local gridData = self.curEliteMapData[tostring(x)][tostring(y)]
	local cell = gridData.info

	local shopInfo = cell.ext
	return shopInfo
end

-- 获取grid数据
function EliteMapModel:getGridInfo(xIdx,yIdx)
	local gridData = self.curEliteMapData[tostring(xIdx)][tostring(yIdx)]
	local gridInfo = gridData.info
	return gridInfo
end

-- 获取地图数据
-- 并不是读取静态数据，还需要结合server返回的数据
function EliteMapModel:getEliteMapData(eliteChapter)
	if not self.curEliteMapData then
		EliteMapModel:updateMapData() 
		return self.curEliteMapData
	else
		return self.curEliteMapData
	end
end

-- 获取主角出生点格子坐标
function EliteMapModel:getCharBirthGridPos()
	local x = nil
	local y = nil
	local mapData = self.curEliteMapData
	for x,rowData in pairs(mapData) do
		for y,v in pairs(rowData) do
			local info = v.info
			if info and (info[FuncEliteMap.GRID_BIT.TYPE] == tostring(FuncEliteMap.GRID_BIT_TYPE.BIRTH)) then
				return x,y
			end
		end
	end
end

-- 是否是主角出生地
function EliteMapModel:isCharBirthPos(xIdx,yIdx)
	local charX,charY = self:getCharBirthGridPos()
	if tostring(xIdx) == tostring(charX) and tostring(yIdx) == tostring(charY) then
		return true
	else
		return false
	end
end

-- 重置地图相关数据
-- function EliteMapModel:resetMapData()
-- 	self:clearCharGridPos()
--     self:resetMapPos()
--     self:clearLocalShopInfo()
-- end

-- 进下一层会清除当前地图数据
function EliteMapModel:clearMapData(_chapter)
	self:clearCharGridPos(_chapter)
	-- self:clearLocalShopInfo()
	-- self:resetMapPos()
end

-- 保存地图坐标
function EliteMapModel:saveMapPos(xIdx,yIdx)
	LS:prv():set(StorageCode.elite_map_pos,json.encode({x=xIdx,y=yIdx}))
end

-- 获取地图坐标
function EliteMapModel:getMapPos(xIdx,yIdx)
	local posJson = LS:prv():get(StorageCode.elite_map_pos,"")
	if posJson and posJson ~= "" then
		local pos = json.decode(posJson)
		return pos
	else
		return nil
	end
end

-- function EliteMapModel:resetMapPos()
-- 	LS:prv():set(StorageCode.elite_map_pos,json.encode({x=0,y=0}))
-- end

-- 重置主角坐标
function EliteMapModel:resetCharGridPos(_chapter)
	local xIdx,yIdx = self:getCharBirthGridPos()
	self:saveCharGridPos(xIdx,yIdx,_chapter)
end

-- 保存主角坐标
-- 每一章
function EliteMapModel:saveCharGridPos(xIdx,yIdx,_chapter)
	LS:prv():set(StorageCode.elite_char_pos.._chapter,json.encode({x=xIdx,y=yIdx}))
end

-- 清除主角坐标
function EliteMapModel:clearCharGridPos(_chapter)
	LS:prv():set(StorageCode.elite_char_pos.._chapter,"")
end

-- 获取主角坐标
function EliteMapModel:getCharGridPos(_chapter)
	local posJson = LS:prv():get(StorageCode.elite_char_pos.._chapter,"")
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
function EliteMapModel:isValidCharPos(xIdx,yIdx)
	local isValid = false

	if not xIdx or not yIdx then
		return isValid
	end
	
	-- 不是合法的格子坐标
	if not self:isValidGrid(xIdx, yIdx) then
		return isValid
	end

	local validEventType = {
		FuncEliteMap.GRID_BIT_TYPE.EMPTY,
		FuncEliteMap.GRID_BIT_TYPE.ITEM,
		FuncEliteMap.GRID_BIT_TYPE.BIRTH,
		FuncEliteMap.GRID_BIT_TYPE.SHOP,
		FuncEliteMap.GRID_BIT_TYPE.POISON,
	}

	local gridInfo = self:getGridInfo(xIdx,yIdx)
	if gridInfo then
		local gridBitStatus = gridInfo[FuncEliteMap.GRID_BIT.STATUS]
		local gridType = gridInfo[FuncEliteMap.GRID_BIT.TYPE]

		-- 格子被清空或已开启的空格子
		if gridBitStatus == FuncEliteMap.GRID_BIT_STATUS.CLEAR then
			isValid = true
		-- 已探索的格子
		elseif gridBitStatus == FuncEliteMap.GRID_BIT_STATUS.EXPLORED then
			-- 如果是合法类型
			if table.find(validEventType,tostring(gridType)) then
				isValid = true
			-- 如果是怪
			elseif gridType == FuncEliteMap.GRID_BIT_TYPE.MONSTER then
				local eventStatus = gridInfo[FuncEliteMap.GRID_BIT.TYPE_PARAM]
				-- 如果是沉睡怪
				if tonumber(eventStatus) == FuncEliteMap.MONSTER_STATUS.SLEEP
					or tonumber(eventStatus) == FuncEliteMap.MONSTER_STATUS.SKIPED then
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
function EliteMapModel:getTowerEndPointPos()
	local x = nil
	local y = nil
	local mapData = self.curEliteMapData
	for x,rowData in pairs(mapData) do
		for y,v in pairs(rowData) do
			local info = v.info
			if info[FuncEliteMap.GRID_BIT.TYPE] == FuncEliteMap.GRID_BIT_TYPE.ENDPOINT then
				return cc.p(x,y)
			end
		end
	end

	return {}
end

-- grid坐标转Id
function EliteMapModel:gridPosToId(xIdx,yIdx)
	return xIdx .. "_" .. yIdx
end

-- grid Id转坐标
function EliteMapModel:gridIdToPos(gridId)
	local arr = string.split(gridId,"_")
	return arr[1],arr[2]
end

-- 获取格子数据
function EliteMapModel:getGridData(xIdx,yIdx)
	local gridData = self.curEliteMapData[tostring(xIdx)][tostring(yIdx)]
	return gridData
end

-- 是否是合法的格子
function EliteMapModel:isValidGrid(xIdx,yIdx)
	xIdx = tonumber(xIdx)
	yIdx = tonumber(yIdx)
	if xIdx < 1 or xIdx > self.maxXNum then
		return false
	elseif yIdx < 1 or yIdx > self.maxYNum then
		return false
	end 

	local gridData = self:getGridData(xIdx,yIdx)
	local gridInfo = gridData.info

	if not gridInfo then
		return false
	else
		return true
	end
end

-- 获取上次挑战的怪的等级
function EliteMapModel:getLastBattleStar(xIdx,yIdx)
	local star = nil
	local gridData = self:getGridData(xIdx,yIdx)
	if gridData ~= nil then
		local cell = gridData.info
		local extInfo = cell.ext
		if extInfo and extInfo.star then
			star = extInfo.star
		end
	else
		echoError("EliteMapModel:getLastBattleStar xIdx=",xIdx,yIdx)
	end

	return star
end

-- 获取场景格子皮肤
function EliteMapModel:getEliteMapGridSkin(eliteChapter)
	local gridSkin = "UI_elite_grid"
	local sceneData = FuncElite.getEliteMapSkinData(eliteChapter)

	if sceneData then
		gridSkin = sceneData.skin
	end

	return gridSkin
end

-- 获取场景动画皮肤
function EliteMapModel:getTowerMapSceneSkin(eliteChapter)
	local sceneSkin = "map_suoyaotawanfa"
	local sceneData = FuncElite.getEliteMapSkinData(eliteChapter)
	if sceneData then
		sceneSkin = sceneData.map
	end
	
	return sceneSkin
end

function EliteMapModel:saveOnClick(eventModel)
	self.eventTempModel = eventModel
end

function EliteMapModel:getOnClick()
	return self.eventTempModel
end

-- 本地保存商店信息，解决打开商店后重启游戏问题
function EliteMapModel:saveLocalShopInfo(xIdx,yIdx)
	local shopInfo = EliteMapModel:getShopInfo(xIdx,yIdx)
	if shopInfo then
		shopInfo.x = xIdx
		shopInfo.y = yIdx
	end
	LS:prv():set(StorageCode.tower_shop_info,json.encode(shopInfo))
end

function EliteMapModel:getLocalShopInfo()
	local jsonStr = LS:prv():get(StorageCode.tower_shop_info)
	local shopInfo = nil
	if jsonStr and jsonStr ~= "" then
		shopInfo = json.decode(jsonStr)
	end

	return shopInfo
end

-- 清除本地商店信息
function EliteMapModel:clearLocalShopInfo()
	LS:prv():set(StorageCode.tower_shop_info,"")
end

return EliteMapModel

