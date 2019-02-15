--[[
	Author: 张燕广
	Date:2017-07-27
	Description: 锁妖塔地图配表数据类
]]

FuncTowerMap= FuncTowerMap or {}

local towerMapData = nil
local towerMapDataList = nil
function FuncTowerMap.init()
	towerMapDataList = {}

	-- 环绕点坐标偏移配置
	-- 门 事件 配置为 以右上角为起点,顺时针绕格子一周
	-- 方位分别为 1,2,3,4,5,6
	FuncTowerMap.surroundPoints = {
		{x=-1,y=-1},  --右上
		{x=-2,y=0},	 --右
		{x=-1,y=1},    --右下
		{x=1,y=1},	 --左下
		{x=2,y=0},	 --左
		{x=1,y=-1}, --左上
	}
	-- FuncTowerMap.surroundPoints = {
	-- 	{x=1,y=-1}, --左上
	-- 	{x=-1,y=-1},  --右上

	-- 	{x=2,y=0},	 --左
	-- 	{x=-2,y=0},	 --右

	-- 	{x=1,y=1},	 --左下
	-- 	{x=-1,y=1}    --右下
	-- }

	-- 左边3个环绕点
	FuncTowerMap.leftThreeSurroundPoints = {
		{x=1,y=-1}, --左上

		{x=2,y=0},	 --左

		{x=1,y=1},	 --左下
	}

	-- 每层最多商店数量
	FuncTowerMap.MAX_SHOP_REWARD_ID = 3

	-- 普通障碍物ID
	FuncTowerMap.NORMAL_OBSTACLE_ID = "1"

	-- 解毒草
	FuncTowerMap.JIEDUCAO_ID = "1011"

	-------------------------------------------------------
	-------------------------------------------------------
	-- 网格数据位，每位含义
	FuncTowerMap.GRID_BIT = {
		-- 第一维度,格子探索状态
		-- 网格数据,第1位表示状态,0表示未探索(默认值),1表示已探索
		STATUS = 1,

		-- 第二维度,格子翻开后,待处理事件的类,id,参数
		-- 第二位 网格类型 0没有任何东西(默认值) 1表示怪物,2表示宝箱,3表示道具,4表示NPC,5表示障碍物,6表示出生点,7表示终点
		-- 第三位 对应id,当网格类型0:0,网格类型1:怪物id, 2:宝箱id, 3:道具id, 4:npcId, 5:障碍物id
		-- 对应网络类型的参数,目前只有当网格类型为1怪物时,配置参数,1正常怪物,2沉睡,3警戒状态,其他的网格类型参数配0
		TYPE = 2,
		TYPE_ID = 3,
		TYPE_PARAM = 4,

		-- 第三维度 0:无笼子，非0表示是笼子的ID
		CAGE = 5,

		-- 第四维度类型,默认值为0 表示没有任何东西,1 聚灵格子
		D4_TYPE = 6,
		D4_TYPE_ID = 7,
		D4_TYPE_PARAM = 8,

		-- 随机组id
		RAND_ID = 9,
	}

	-- 网格状态
	FuncTowerMap.GRID_BIT_STATUS = {
		-- 未探索
		NOT_EXPLORE = "0",
		EXPLORED = "1",
		CLEAR = "2"
	}

	--[[
		网格类型
		1表示怪物,2表示宝箱,3表示道具,4表示NPC,5表示障碍物,6表示出生点,7表示终点,8表示商店,9表示法阵
		10五灵池,11毒
		注意：新增格子或修改事件后，TowerGridModel:hasGridEvent需要修改
	]]
	FuncTowerMap.GRID_BIT_TYPE = {
		EMPTY = "0",
		MONSTER = "1",  -- 表示怪物
		BOX = "2",      -- 宝箱
		ITEM = "3",		-- 道具
		NPC = "4",		--npc
		OBSTACLE = "5", --障碍物
		BIRTH = "6",	--出生地
		ENDPOINT = "7",	--终结地
		SHOP = "8",		--商店
		MATRIXMETHOD = "9",--法阵
		SPRITPOOL = "10",--五灵池
		POISON = "11",	--药

		RUNE_TEMPLE = "12", -- 散灵法阵
		DOOR = "13",		-- 机关,单向门
	}

	-- 格子显示状态
	FuncTowerMap.GRID_STATUS = {
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

	-- 不同格子状态对应的格子panel资源名字
	FuncTowerMap.GRID_PANELS = {
		"panel_1",
		"panel_2",
		"panel_3",
		"panel_4",
		-- 障碍物与已探索状态相同
		"panel_3",
		-- 与已探索状态相同
		"panel_3",
	}

	-- 格子事件视图配置
	FuncTowerMap.GRID_EVENT_VIEW = {
		[FuncTowerMap.GRID_BIT_TYPE.OBSTACLE] = "panel_5"
	}

	-- 不同格子状态对应的 格子开启事件 图片资源名后缀
	FuncTowerMap.GRID_OPEN_EVENT_RES = {
		"1",
		"2",
	}

	-- 笼子的状态
	FuncTowerMap.GRID_BIT_CAGE = {
		NO_CAGE = "0"
	}

	-- 第四维度,开格子触发的机关类型
	FuncTowerMap.GRID_BIT_D4_TYPE = {
		RUNE = "1", -- 机关
	}
	-- 散灵法阵可以切换聚灵格子的类型
	FuncTowerMap.GRID_BIT_D4_TYPE_PARAM = {
		SWORD = "1",		-- 剑
		BLOOD_REGAIN = "2",		-- 回血
		ANGER_REGAIN = "3",		-- 回怒
	}

	-------------- 怪的类型-----------------------------------------
	-- 怪的状态
	FuncTowerMap.MONSTER_STATUS = {
		-- 正常
		NORMAL = 1,	
		-- 沉睡
		SLEEP = 2,
		-- 警戒
		ALERT = 3,
		-- 被绕过
		SKIPED  = 4,
	}
	-- 怪的种类
	FuncTowerMap.MONSTER_TYPE = {
		NORMAL = 1,
		BOSS = 2,
	}
	-- 怪的星种类
	FuncTowerMap.MONSTER_STAR_TYPE = {
		WILD = 1,
		STAR = 2,
	}

	-------------- 宝箱的类型----------------------------------
	FuncTowerMap.BOX_OPEN_CON_TYPE = {
		NEED_KEY = "1", -- 需要道具才能开启
		NONE = "2",		-- 不需要开启条件
	}


	-------------- 道具和商店的类型----------------------------------
	FuncTowerMap.ITEMANDSHOP_TYPE = {
		SKIPED  = 4,
	}
	-- 道具的状态
	FuncTowerMap.ITEM_STATUS = {
		-- 被绕过
		SKIPED  = 4,
	}

	-------------- npc的类型-----------------------------------------
	-- 代码中方便分类 跳转到相应的view
	FuncTowerMap.NPC_TYPE = {
		PRISONER = 1, 	-- 被囚的道友
		PAZZLER  = 2,	-- 困惑的道友 小游戏
		VAGRANT  = 3,	-- 无业流浪汉 可被雇佣为雇佣兵
		ROBBER	 = 4,	-- 劫匪 劫财或者劫色
	}

	-- NPC 事件的种类 依据TowerNpcEvent.csv
	FuncTowerMap.NPC_EVENT_TYPE = {
		CHALLENGE = 1,--挑战
		DECIPHER = 2,--解密
		PUZZLE = 3,--拼图
		MERCENARY = 4,--雇佣兵
		ROB_TREASURE = 5,--劫法宝
		ROB_WOMAN = 6,--劫色
		ROB_STONE = 7,--劫魔石
	}
end

-- 找出targetPoint的相邻六个点
function FuncTowerMap.getSurroundPoints(targetPoint)
	local pointsList = FuncTowerMap.getSurroundPointsList(targetPoint,FuncTowerMap.surroundPoints)
	return pointsList
end

-- 找出targetPoint左边3个点
function FuncTowerMap.getLeftThreeSurroundPoints(targetPoint)
	local pointsList = FuncTowerMap.getSurroundPointsList(targetPoint,FuncTowerMap.leftThreeSurroundPoints)
	return pointsList
end


function FuncTowerMap.getSurroundPointsList(targetPoint,surroundPoints)
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
function FuncTowerMap.getGuardMePoints(targetPoint)
	local x = targetPoint.x
	local y = targetPoint.y
	local pointsList = {}

	for k,v in pairs(FuncTowerMap.leftThreeSurroundPoints) do
		local newX = x - v.x
		local newY = y - v.y

		local point = {x=newX,y=newY}
		pointsList[#pointsList+1] = point
	end

	return pointsList
end

-- -- towerIndex第几层
-- function FuncTowerMap.getTowerMapData(towerIndex)
-- 	if towerIndex == nil or towerIndex == "" then
-- 		echoError("FuncTowerMap.getTowerMapData towerIndex is nil")
-- 		return nil
-- 	end

-- 	local towerData = towerMapDataList[towerIndex]
-- 	if not towerData then
-- 		towerData = Tool:configRequire("towerMap.TowerMap" .. towerIndex)
-- 		if towerData then
-- 			towerMapDataList[towerIndex] = towerData
-- 		else
-- 			echoError("FuncTowerMap.getTowerMapData towerIndex is ",towerIndex)
-- 		end
-- 	end

-- 	return towerData
-- end

-- -- 生成Y轴反转地图数据
-- function FuncTowerMap.getYReversalMapData(towerIndex)
-- 	local towerMapData = {}
-- 	local originMapData = FuncTowerMap.getTowerMapData(towerIndex)

-- 	for x,v1 in pairs(originMapData) do
-- 		towerMapData[x] = {}
-- 		for y,v2 in pairs(v1) do
-- 			local yNum = tonumber(y)
-- 			local originData = nil

-- 			-- 中间行保持原数据
-- 			if yNum == 3 then
-- 				originData = v2
-- 			else
-- 				-- 1/5 对换，2/4对换数据
-- 				originData = originMapData[x][tostring(6-yNum)]
-- 				originData.y = y
-- 			end
-- 			towerMapData[x][y] = table.deepCopy(originData)
-- 		end
-- 	end

-- 	return towerMapData
-- end


-- =====================================================================
-- 根据地图表名字获取地图
-- 
function FuncTowerMap.getTowerMapDataByMapName(mapName)
	if mapName == nil or mapName == "" then
		echoError("FuncTowerMap.getTowerMapDataByMapName mapName is nil")
		return nil
	end

	local towerData = towerMapDataList[mapName]
	if not towerData then
		towerData = Tool:configRequire("towerMap." .. mapName)
		if towerData then
			towerMapDataList[mapName] = towerData
		else
			echoError("FuncTowerMap.getTowerMapDataByMapName mapName is ",mapName)
		end
	end

	return towerData
end

-- 生成Y轴反转地图数据
function FuncTowerMap.getYReversalMapDataByMapName(mapName)
	local towerMapData = {}
	local originMapData = FuncTowerMap.getTowerMapDataByMapName(mapName)

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