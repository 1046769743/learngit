--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔地图配表数据类
]]

FuncEliteMap = FuncEliteMap or {}

local towerMapData = nil


local eliteMapDataList = nil   -- 所有章的地图数据
local eliteOrganMapDataList = nil   -- 所有机关的地图数据
local elitePoetryList = nil 		-- 题库数据

function FuncEliteMap.init()
	eliteMapDataList = {}
	eliteOrganMapDataList = {}
	elitePoetryList = Tool:configRequire("elite.EliteQuestion")

	-- 环绕点坐标偏移配置
	FuncEliteMap.surroundPoints = {
		{x=1,y=-1}, --左上
		{x=-1,y=-1},  --右上

		{x=2,y=0},	 --左
		{x=-2,y=0},	 --右

		{x=1,y=1},	 --左下
		{x=-1,y=1}    --右下
	}

	-- 左边3个环绕点
	FuncEliteMap.leftThreeSurroundPoints = {
		{x=1,y=-1}, --左上

		{x=2,y=0},	 --左

		{x=1,y=1},	 --左下
	}

	-- 格子显示状态
	FuncEliteMap.GRID_STATUS = {
		-- 不可探索
		CAN_NOT_EXPLORE = 1,
		-- 可以探索
		CAN_EXPLORE = 2,
		-- 已探索
		EXPLORED = 3,
		-- 警戒(该格子是警戒怪的临近格子)
		ALERT = 4,
		-- 障碍物(格子上有障碍物)
		OBSTRACLE = 5,
		-- 格式事件已被消耗
		EVENT_CLEAR = 6
	}

	FuncEliteMap.GRID_PANELS = {
		"panel_new1",
		"panel_new2",
		"panel_new3",
		"panel_4",
		"panel_5",
		-- 与已探索状态相同
		"panel_new3",
	}

	-- 网格数据位，每位含义
	FuncEliteMap.GRID_BIT = {
		-- 网格数据,第1位表示状态,0表示未探索(默认值),1表示已探索
		STATUS = 1,

		-- 第二位 网格类型 0没有任何东西(默认值) 1表示怪物,2表示宝箱,3表示道具,4表示NPC,5表示障碍物,6表示出生点,7表示终点
		TYPE = 2,

		-- 第三位 对应id,当网格类型0:0,网格类型1:怪物id, 2:宝箱id, 3:道具id, 4:npcId, 5:障碍物id
		TYPE_ID = 3,

		IS_BOX = 4,
	}
	-- 网格状态
	FuncEliteMap.GRID_BIT_STATUS = {
		-- 未探索
		NOT_EXPLORE = "0",
		EXPLORED = "1",
		CLEAR = "2"
	}
	-- 场景地图格子类型
	FuncEliteMap.GRID_BIT_TYPE = {
		EMPTY = "0", 		-- 空格子
		BIRTH = "1",		-- 出生点
		EXIT = "2",		-- 出口(通往下一章)
		MONSTER = "3",	-- 怪
		BOX = "4",		-- 宝箱
		ORGAN = '5',	-- 机关
		DEFAULT_OPENED = '6',	-- 默认打开
	}
	-- 怪的状态
	FuncEliteMap.MONSTER_STATUS = {
		NORMAL = 1,		-- 正常
		SLEEP = 2, 		-- 沉睡
		ALERT = 3, 		-- 警戒
		SKIPED  = 4, 	-- 被绕过
	}

	-- 机关地图类型
	FuncEliteMap.ORGAN_MAP_GRID_TYPE = {
		EMPTY = 0,		-- 空格子
		RECEIVER = 1,		-- 发射器
		SENDER = 2,   -- 接收器
		CUBE_SOLID = 3,	-- 实心cube
		CUBE_WS = 4,	-- 西南联通
		CUBE_ES = 5,	-- 东南联通
		CUBE_EN = 6,	-- 东北联通
		CUBE_WN = 7,	-- 西北连通
		CUBE_BORDER = 8,-- 边界cube
	}

	-- 光指针旋转角度
	-- 改变光路的cube 及 光cube用到
	FuncEliteMap.ROTATION_ANGLE = {
		NORTH = 0,
		SOUTH = 180,
		EAST = 90,
		WEST = 270,
		NONE = false,
	}
	FuncEliteMap.ROTATION_NAME = {
		["0"] 	= "北",
		["180"] = "南",
		["90"] 	= "东",
		["270"] = "西",
	}
end

-- 找出targetPoint的相邻六个点
function FuncEliteMap.getSurroundPoints(targetPoint)
	local pointsList = FuncEliteMap.getSurroundPointsList(targetPoint,FuncEliteMap.surroundPoints)
	return pointsList
end

-- 找出targetPoint左边3个点
function FuncEliteMap.getLeftThreeSurroundPoints(targetPoint)
	local pointsList = FuncEliteMap.getSurroundPointsList(targetPoint,FuncEliteMap.leftThreeSurroundPoints)
	return pointsList
end

function FuncEliteMap.getSurroundPointsList(targetPoint,surroundPoints)
	local x = targetPoint.x
	local y = targetPoint.y
	local pointsList = {}

	for k,v in pairs(surroundPoints) do
		local newX = x + v.x
		local newY = y + v.y

		local point = {x=newX,y=newY}
		pointsList[#pointsList+1] = point
	end

	return pointsList
end

-- 获取可能会守卫targetPoint的点,targetPoint可能会被哪些点守卫(这些点上有怪)
function FuncEliteMap.getGuardMePoints(targetPoint)
	local x = targetPoint.x
	local y = targetPoint.y
	local pointsList = {}

	for k,v in pairs(FuncEliteMap.leftThreeSurroundPoints) do
		local newX = x - v.x
		local newY = y - v.y

		local point = {x=newX,y=newY}
		pointsList[#pointsList+1] = point
	end

	return pointsList
end

-- 获取精英 第eliteChapterIndex章 的地图数据
function FuncEliteMap.getOneEliteMapData(eliteChapterIndex)
	if eliteChapterIndex == nil or eliteChapterIndex == "" then
		echoError("FuncEliteMap.getOneEliteMapData eliteChapterIndex is nil")
		return nil
	end

	local eliteData = eliteMapDataList[tostring(eliteChapterIndex)]
	if not eliteData then
		eliteData = Tool:configRequire("elite.EliteMap" .. eliteChapterIndex)
		if eliteData then
			eliteMapDataList[tostring(eliteChapterIndex)] = eliteData
		else
			echoError("FuncEliteMap.getOneEliteMapData eliteChapterIndex is ",eliteChapterIndex)
		end
	end
	return eliteData
end

-- 获取机关数据 organIndex
function FuncEliteMap.getOneEliteOrganMapData(_organIndex)
	local organIndex = _organIndex
	if organIndex == nil or organIndex == "" then
		-- echoError("FuncEliteMap.getOneEliteMapData organIndex is nil")
		-- return nil
		organIndex = 1
	end

	local organData = eliteOrganMapDataList[tostring(organIndex)]
	if not organData then
		organData = Tool:configRequire("elite.EliteOrgan" .. organIndex)
		if organData then
			eliteOrganMapDataList[tostring(organIndex)] = organData
		else
			echoError("FuncEliteMap.getOneEliteOrganMapData organIndex is ",organIndex)
		end
	end

	return organData
end


-- 生成Y轴反转地图数据
function FuncEliteMap.getYReversalMapData(towerIndex)
	local towerMapData = {}
	local originMapData = FuncEliteMap.getTowerMapData(towerIndex)

	for x,v1 in pairs(originMapData) do
		towerMapData[x] = {}
		for y,v2 in pairs(v1) do
			local yNum = tonumber(y)
			local originData = nil

			-- 中间行保持原数据
			if yNum == 3 then
				originData = v2
			else
				-- 1/5 对换，2/4对换数据
				originData = originMapData[x][tostring(6-yNum)]
				originData.y = y
			end
			towerMapData[x][y] = table.deepCopy(originData)
		end
	end

	return towerMapData
end


-- ========================================
-- 题库
function FuncEliteMap:getAllConfigQuestions()
	return elitePoetryList
end