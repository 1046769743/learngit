--
-- Author: xd
-- Date: 2018-07-03 11:30:02
--

FuncGuildExplore = {}

--必须是有日志开关的
if DEBUG_LOGVIEW then
	--打开调试地图信息
	FuncGuildExplore.debugMapInfo = true
end


--调试网格类型 0 不调试 1 调试六边形网格 2调试迷雾
FuncGuildExplore.debugGrild = 0

--计算一格需要走多少帧  如果加速 可以这个值变很小 可以是小数
FuncGuildExplore.oneGridMoveFrame = 10


--移动不需要确认
FuncGuildExplore.moveWithOutSure = false
--是否是地图全开的
FuncGuildExplore.isAllMapOpen = false


--角色缩放比例
FuncGuildExplore.chapterScale = 0.7
FuncGuildExplore.monsterScale = 0.7
FuncGuildExplore.eliteScale = 1.0
--迷雾半径
FuncGuildExplore.mistRadio = 1



--zorder 分层定义
FuncGuildExplore.zorderMap = {
	mists = 300000,
	effect =  280000,		--场景特效 要在迷雾下面  
	events = 100000, 		-- 事件
	name = 200000,
	black = 400000,	--黑屏深度
	foot = 50000 ,			--脚下光环
}


--定义周围相邻的6个点
FuncGuildExplore.nearPoints = {
	{-1,-1},{-2,0},	{-1,1},{1,1},{2,0},	{1,-1},

}


local pointArr = { 
		{ x = -52.05, y =5.55 } ,
		{ x = -20.25, y =23 } ,
		{ x = 32.7, y =20.05 } ,
}






if not  ExploreGridControler then
	ExploreGridControler = require("game.sys.view.guildExplore.controler.ExploreGridControler")
end
require("game.sys.view.guildExplore.controler.ExplorePosTools")
ExplorePosTools:init(pointArr)
--一个网格的宽高 
FuncGuildExplore.gridWidth =  pointArr[3].x - pointArr[1].x
FuncGuildExplore.gridHeight = pointArr[2].y +pointArr[3].y
--

--迷雾网格宽高
FuncGuildExplore.mistsWidth = 50
FuncGuildExplore.mistsHeight = 50
FuncGuildExplore.gridToMistWidthNums = math.ceil(FuncGuildExplore.gridWidth/FuncGuildExplore.mistsWidth)
FuncGuildExplore.gridToMistHeightNums = math.ceil(FuncGuildExplore.gridHeight/FuncGuildExplore.mistsHeight)



-- FuncGuildExplore.widthGridsPerScreen = 16 
-- FuncGuildExplore.heightGridsPerScreen = 16 


--网格类型表
FuncGuildExplore.gridTypeMap = {
	empty = "0",	--空地
	res = "1", 		-- 资源
	enemy = "2", 	--小怪
	elite = "3", 	--精英
	mine = "4", 	--矿洞
	spring = "5", 	--灵泉 
	build = "6" 	--建筑
}



FuncGuildExplore.name_type = {
	[1] = "烈焰",
	[2] = "月幽",
	[3] = "炙焰",
}


--上阵类型
FuncGuildExplore.lineupType = {
  mining = 1, --采矿
  building = 2, --建筑
}

--任务类型
FuncGuildExplore.taskType = {
	single = 1, --单人
	manyPeople = 2, --多人
}

--排行类型
FuncGuildExplore.rankType = {
	resRank = 1, --资源榜
	mineRank = 2, --占领榜
}

--装备类型类型
FuncGuildExplore.equipmentType = {
	sword = 1,   --剑
	clothes = 2, --衣服
	shoes = 3,  --鞋子
}

FuncGuildExplore.eventType = {
	mine = 1,--=矿脉邀请、
	build = 2,--=大型建筑邀请、
	getRes = 3,--=大额资源拾取、
	eliteMonster = 4,--=精英怪邀请
	deathMonster = 5,--=怪物死亡
}


--事件任务类型
FuncGuildExplore.fileTaskType = {
	consumeVigor = 1,--=消耗精力、
	getRes = 2,--=拾取资源、
	occupationMineCount = 3,--=占领矿脉数量、
	occupationMineTime = 4,--=占领矿脉总时长、
	killMonster = 5,--=击杀怪物数量、
	eliteMonster = 6,--=挑战精英怪、
	drinkingHippocrene = 7,--=饮用灵泉、
	equipmentIntensify = 8,--=强化任意装备X次、
	killEliteMonsterCount = 9,--=击杀精英怪次数
}

FuncGuildExplore.buffType = 10  --精力类型
-- 出生点
FuncGuildExplore.birthPoint={x=1,y=1}

FuncGuildExplore.resType = {
	guildLiuli = 1,--琉璃
	guildTianhe = 2,--天河石
	guildZijing = 4,--紫晶石
	guildLingmeng = 3, --菱锰石
	coin = 5,--铜钱
	diamond = 6,--仙玉
	wood = 7,--灵木
	stone = 8,--星石
	jade = 9,--陨玉
	lingquan = 10,--灵泉
}

-- FuncGuildExplore.button_red_type = {
-- 	-- chat = 1


-- }


FuncGuildExplore.equipMaxLevel = 20 ---装备最大等级

FuncGuildExplore.chellengOrdinaryMonsterCount = 1  --挑战普通怪的次数
FuncGuildExplore.chellengEliteMonsterCount = 3 --挑战精英怪的次数


--用来判断仙盟探索新资源的类型
FuncGuildExplore.guildExploreResType = "41"


--发送邀请的CD
FuncGuildExplore.invitationCD = 5*60

--需要加载的配表map
local cfgsKeyArr = {
	"ExploreBuff","ExploreCity","ExploreDispatch","ExploreEquipment",
	"ExploreMapAppointRandom","ExploreMapChoose","ExploreMapDecorateMaterial",
	"ExploreMapDecorateRandom","ExploreMapNotRandom",
	"ExploreMapRegionRandom","ExploreMapSmallBlock","ExploreMine",
	"ExploreMonster","ExploreQuest","ExploreRecord","ExploreRes","ExploreResource",
	"ExploreSetting","ExploreMapChoose","ExploreSceneEffect"
}


--偏移系数.每4格向右偏移一格
FuncGuildExplore.offsetPerNums = 5
--偏移系数2,每4格向上偏移一格
FuncGuildExplore.offsetPerNumsUp = 3
--存储所有的配表
local allCfgs = {}

--初始化 
function FuncGuildExplore.init( ... )
	local packageName = "explore."
	--初始化 所有的配表 动态存入 allCfgs里面去 ,避免重复写N多相同的方法
	for i,v in ipairs(cfgsKeyArr) do
		allCfgs[v] = Tool:configRequire(packageName..v)
	end

	local costTime = FuncGuildExplore.getSettingDataValue("ExploreGridCostTime","num") or 300 
	FuncGuildExplore.oneGridMoveFrame = math.ceil( costTime * GameVars.GAMEFRAMERATE /1000 ) + 1

end

--获取某一个配表数据 传入配表名称, 和对应的id字段
function FuncGuildExplore.getCfgDatas( cfgsName,id )
	-- echo("=======cfgsName======",cfgsName,id)
	local cfgData = allCfgs[cfgsName]
	local data = cfgData[tostring(id)]
	if not data then
		echoError("Explore没有找到表对应id为数据",cfgsName,id)
		return {}
	end
	return data
end
-- 获取地图配表数据
function FuncGuildExplore.getMapDataByMapName( mapId)
	local fileName = string.format("exploreMap.ExploreMap%s",mapId)
	if IS_EDITER then
		fileName = string.format("exploreMap.%s",LS:pub():get("EDITOR_FILE_NAME"))
		echo("预览编辑的地图",fileName)
	end
	local mapData = Tool:configRequire(fileName)
	if mapData then
		return table.deepCopy(mapData)
	end
	echoError ("未找到指定地图 id:",mapId)
	return {{}}
end


--获取某个配表的 key数据
--示例: 获取小怪表 id为101的,key为name,  FuncGuildExplore.getCfgDatasByKey("ExploreMonster","101","name")
function FuncGuildExplore.getCfgDatasByKey( cfgsName,id ,key)
	local data = FuncGuildExplore.getCfgDatas( cfgsName,id )
	if not data[key] then
		-- echo("没有找到%s表id为%s,key:为%s的数据",cfgsName,id,key)
		return nil
	end
	return data[key]
end

--获取某个配表对应多层key的数据
function FuncGuildExplore.getCfgDatasByMultyKey( cfgsName,id ,key1,key2)
	local data = FuncGuildExplore.getCfgDatas( cfgsName,id )
	if not data[key1] then
		echoError("没有找到%s表id为%s,key:为 %s的数据",cfgsName,id,key1)
		return nil
	end
	local rt = data[key1][key2]
	if rt == nil then
		echoError("没有找到%s表id为%s,key1:为 %s,key2为%s的数据",cfgsName,id,key1,key2)
	end
	return rt
end

--剩下的接口根据需要封装


--生成一个随机地图 . 原始配表数据结构:
--地形;地形id;是否可走;类型;类型id;类型参数占位符;事件类型;事件id;事件参数预留;
-- 类型定义
-- 类型 1=资源、2=怪物、3=精英怪、4=矿脉、5=灵泉、6=大型建筑）

--[[
生成后的数据 前后端保持统一
	mapCfg = {
		[x*10000+y] = {	terrain = 101, 	--地形 如果没有就是0, 这个值不可被更怪
					block = 0, 		--是否可走, 0或者空可走,1不可走.
					type = 1,		--类型 ,0表示空格子. 如果这个格子的怪物被击杀后 需要把type置空为0 
					tid = 101,		--对应类型的id ,这里不用id的原因是 防止和系统默认id冲突
					params = {},	--对应的网格参数扩展 比如 怪物剩余血量. 矿脉的属性 等等
				}
	}
]]


--获取拼接的key
function FuncGuildExplore.getKeyByPos( x,y )
	return (x *10000 + y)
end


--根据key 反向获取 网格坐标 
function FuncGuildExplore.getPosByKey( key )
	key= tonumber(key)
	local x = math.floor(key/10000)
	local y = key % 10000
	--如果出现网格负数的时候 
	if y > 2000 then
		y = y-10000
		x = x +1
	end
	return x,y
end


-- print("-5,-15", FuncGuildExplore.getPosByKey((-5)*10000 - 15  ))
-- print("-6,-15", FuncGuildExplore.getPosByKey((-6)*10000 - 15  ))
-- print("-7,15", FuncGuildExplore.getPosByKey((-7)*10000 + 15  ))
-- print("-1,15", FuncGuildExplore.getPosByKey((-1)*10000 + 15  ))
-- print("2,-10", FuncGuildExplore.getPosByKey((2)*10000 -10  ))

-- 资源和小怪不遮挡行走区域
function FuncGuildExplore.chkCanWalk(gridType)
	local tm = FuncGuildExplore.gridTypeMap
	if gridType == tm.empty or gridType == tm.res or 
		gridType == tm.enemy then
		return true
	end
	return false
end

function FuncGuildExplore.getOneRandomMap(mapId, randomSeed )
	echo ("mapId----",mapId)
	randomSeed = randomSeed or 871871343
	RandomControl.setOneRandomYinzi(randomSeed)
	--暂时定义为固定的
	mapId = mapId or 1 -- 默认给第一张地图
	local mapCfg,resultX,resultY,key,maxX,minY,maxY = {},nil,nil,nil,0,0,0
	-- 可随机的坐标点、分三个区域、343形式
	local putArr = {{},{},{}}
	-- 预先获取不可摆放的坐标点
	local unPutArr = {}
	-- 出生点
	local tmpP = FuncGuildExplore.birthPoint
	key = FuncGuildExplore.getKeyByPos(tmpP.x,tmpP.y)
	unPutArr[key] = true


	-- local dData = FuncGuildExplore.getAllDecorate()
	-- local areaData = allCfgs.ExploreMapSmallBlock
	local rdmTerrainArr = {walk={},unWalk={}} --随机地形的数组(随机固定值用)

	-- 载入地图
	local mapData = FuncGuildExplore.getMapDataByMapName(mapId)
	for x,yArr in pairs(mapData) do
		for k,v in pairs(yArr) do
			resultX,resultY = tonumber(v.x),tonumber(v.y)
			minY = math.min(resultY,minY)
			maxY = math.max(resultY,maxY)
			maxX = math.max(resultX,maxX)
			key =  FuncGuildExplore.getKeyByPos(resultX,resultY)
			if not mapCfg[key] then
				local terrain = tostring(v.info[2])
				if terrain == "1" then
					local areaIdx = FuncGuildExplore.getAreaIdxByPos(resultX,resultY)
					if v.info[3] and (tostring(v.info[3]) == "1" or tostring(v.info[3]) == "3") then
						if not rdmTerrainArr.unWalk[areaIdx] then
							rdmTerrainArr.unWalk[areaIdx] = {}
						end
						table.insert(rdmTerrainArr.unWalk[areaIdx],{key=key,x=resultX,y=resultY})
					else
						if not rdmTerrainArr.walk[areaIdx] then
							rdmTerrainArr.walk[areaIdx] = {}
						end
						table.insert(rdmTerrainArr.walk[areaIdx],{key=key,x=resultX,y=resultY})
					end
				end
				-- echo("key---ddd",key,terrain)
				mapCfg[key] = {terrain = terrain,block =0,x=resultX,y =resultY,mists = 1}

				-- if  FuncGuildExplore.isAllMapOpen then
				-- mapCfg[key].mists =0
				-- end 

				if terrain ~= "1" then
					FuncGuildExplore._updateTerrainDec(mapCfg,key,terrain)
				end
				if v.info[3] then
					-- 纯遮挡
					if tostring(v.info[3]) == "1" then
						mapCfg[key].block = 1
						unPutArr[key] = true
					elseif tostring(v.info[3]) == "2" then -- 不遮挡无迷雾
						mapCfg[key].mists = 0
						unPutArr[key] = true
					elseif tostring(v.info[3]) == "3"  then -- 遮挡无迷雾
						mapCfg[key].mists = 0
						mapCfg[key].block = 1
						unPutArr[key] = true
					end
				end
			end
		end
	end
	-- 出生点和复活点不能随事件
	FuncGuildExplore.excludeBirthPoint(mapId,unPutArr)
	-- 随机地形
	FuncGuildExplore.randomAreaTerrain(mapCfg,rdmTerrainArr)
	-- 指定位置加载大体型建筑
	FuncGuildExplore.loadNotRandomEvent(mapCfg,unPutArr)
	local tmpArr = {}
	for i=1,7 do
		local dMapCfg = table.deepCopy(mapCfg) --需要深度拷贝
		local dUnPutArr = table.deepCopy(unPutArr) --需要深度拷贝
		-- 指定位置内随机事件
		local aArr = FuncGuildExplore.randomAppointEvent(dMapCfg,dUnPutArr)
		-- 随机位置事件
		local bArr = FuncGuildExplore.randomAreaEvent(dMapCfg,dUnPutArr)
		if not tmpArr[i] then
			tmpArr[i] = {}
		end
		for k,v in pairs(aArr) do
			tmpArr[i][k] = v
		end
		for k,v in pairs(bArr) do
			tmpArr[i][k] = v
		end
	end

	--定义几个随机事件
	-- 2个小怪,一个灵泉
	-- mapCfg["p5_5"]= {type = FuncGuildExplore.gridTypeMap.enemy,id = "101",terrain = "101",block =0,x= 5,y=5}
	-- mapCfg["p7_7"]= {type = FuncGuildExplore.gridTypeMap.enemy,id = "101",terrain = "102",block =0,x=7,y =7}
	-- mapCfg["p9_9"]= {type = FuncGuildExplore.gridTypeMap.spring,id = "1",terrain = "103",block =0,x=9,y=9}
	-- dump(tmpArr,"s===",2)
	--网格宽高
	local _x,_y = FuncGuildExplore.getMapSize(maxX,minY,maxY)
	echo("地图大小",_x,_y)
	_x = _x + FuncGuildExplore.getStartX(_y)
	local offSet = FuncGuildExplore.getOffSet(_x/2)
	_x = _x + offSet
	_y = _y + offSet
	if _y%2 ~= _x%2 then
		_y = _y -1
	end
	echo("左下角地图,",_x,_y)
	local rt = {cells = mapCfg,width = _x,height = _y,eventArr = tmpArr}
	return rt
end
function FuncGuildExplore._updateTerrainDec(mapCfg,key,terrain)
	mapCfg[key].terrain = terrain
	--判断是否是 装饰地形
	local terrainCfg = allCfgs.ExploreMapDecorateMaterial[terrain]
	--如果是装饰 标记是装饰
	if terrainCfg and terrainCfg.decorate  then
		--那这样需要交换一下 地形和装饰数据
		mapCfg[key].decorate = terrain
		mapCfg[key].block = 1
		mapCfg[key].terrain = tostring(terrainCfg.decorate)
	end
end
-- 排除出生点复活点
function FuncGuildExplore.excludeBirthPoint(mapId,unPutArr)
	local _addUnPutArr = function(posStr )
		local tmpArr = string.split(posStr,",")
		local x,y = tonumber(tmpArr[1]),tonumber(tmpArr[2])
		-- dump(tmpArr,"s===")
		local posArr = FuncGuildExplore.getSubChildGridOffset("birth")
		for k,v in pairs(posArr) do
			local key = FuncGuildExplore.getKeyByPos(x+v[1],y+v[2])
			unPutArr[key] = true
		end
	end
	local cfgData = allCfgs["ExploreMapChoose"][tostring(mapId)]
	if cfgData then
		for k,v in pairs(cfgData.start) do
			_addUnPutArr(v)
		end
		for k,v in pairs(cfgData.resurrection) do
			_addUnPutArr(v)
		end
	end
end
-- 如果地形为1，随机皮肤
function FuncGuildExplore.randomAreaTerrain(mapCfg,rdmTerrainArr)
	local dData = FuncGuildExplore.getAllDecorate()
	for i,v in ipairs(dData) do
		local walkAreaArr = rdmTerrainArr.walk[tonumber(v.id)] or {}
		-- 随机固定个数的可行走的区域
		local expArr = {}
		if v.walkNum then
			local tmpCount = 0
			for m,n in pairs(v.walkNum) do
				tmpCount = tmpCount + n.num
			end
			expArr = RandomControl.getNumsByGroup(walkAreaArr,tmpCount)
			-- dump(walkAreaArr,"whatz?")
			-- echo("tmpCount",tmpCount)
			-- dump(expArr,"====")
			local idx = 1
			local tmpIdx = 0
			for j=1,#expArr do
				tmpIdx = tmpIdx + 1
				if tmpIdx > v.walkNum[idx].num then
					idx = idx + 1
					tmpIdx = 1
				end
				-- echo("===ss",idx,j)
				FuncGuildExplore._updateTerrainDec(mapCfg,expArr[j].key,
												tostring(v.walkNum[idx].key))
			end
		end
		-- 随机可行走区域(权重)
		if v.walkAble then
			for j=1,#walkAreaArr do
				local tmp = walkAreaArr[j]
				if not table.isValueIn(expArr,tmp) then
					local tmpRnd = RandomControl.getOneIndexByGroup(v.walkAble,"weight")
					FuncGuildExplore._updateTerrainDec(mapCfg,tmp.key,
												tostring(v.walkAble[tmpRnd].key))
				end
			end
		end
		local unWalkAreaArr = rdmTerrainArr.unWalk[tonumber(v.id)] or {}
		-- 随机固定个数的不可行走的区域
		local expArr = {}
		if v.notWalkNum then
			local tmpCount = 0
			for m,n in pairs(v.notWalkNum) do
				tmpCount = tmpCount + n.num
			end
			expArr = RandomControl.getNumsByGroup(unWalkAreaArr,tmpCount)
			local idx = 1
			for j=1,#expArr do
				if j > v.notWalkNum[idx].num then
					idx = idx + 1
				end
				FuncGuildExplore._updateTerrainDec(mapCfg,expArr[j].key,
												tostring(v.notWalkNum[idx].key))
			end
		end
		-- 随机不可行走区域(权重)
		if v.notWalk then
			for j=1,#unWalkAreaArr do
				local tmp = unWalkAreaArr[j]
				if not table.isValueIn(expArr,tmp) then
					local tmpRnd = RandomControl.getOneIndexByGroup(v.notWalk,"weight")
					FuncGuildExplore._updateTerrainDec(mapCfg,tmp.key,
												tostring(v.notWalk[tmpRnd].key))
				end
			end
		end
	end
end
function FuncGuildExplore._changeMapValue(mapCfg,unPutArr,db,x,y,subKey)
	local key = FuncGuildExplore.getKeyByPos(x,y)
	local tmpData = mapCfg[key]
	if not tmpData then
		-- echoError ("坐标不在地图中",x,y)
		return
	end
	if subKey then
		-- if tmpData.sub then
		-- 	echoError ("这个位置已经有从属格子了",db.id,x,y,tmpData.sub)
		-- end
		-- tmpData.sub = subKey --从属与那个格子的数据

		-- 在父节点存此子节点的坐标
		local subData = mapCfg[subKey]
		if subData then
			if not subData.child then
				subData.child = {}
			end
			table.insert(subData.child,key)
		end
		-- echo ("====",key,n.x,n.y)
	else
		tmpData.block = 1
		if db.events then
			-- 随机事件
			local randomInt = RandomControl.getOneIndexByGroup(db.events,"weight")
			FuncGuildExplore.updateMapEventData(mapCfg,x,y,tostring(db.type),
														tostring(db.events[randomInt].id))
		elseif db.parameter then
			-- 指定事件
			FuncGuildExplore.updateMapEventData(mapCfg,x,y,tostring(db.eventType),
														tostring(db.parameter))
		end
	end
	-- 不论是主格子还是随从格子，都不能再随机事件了
	unPutArr[key] = true
end
-- 加载指定位置事件
function FuncGuildExplore.loadNotRandomEvent(mapCfg,unPutArr)
	for k,v in pairs(allCfgs["ExploreMapNotRandom"]) do
		if v.coordinate then
			-- 获取主坐标
			local x,y = v.coordinate[1],v.coordinate[2]
			local subKey = FuncGuildExplore.getKeyByPos(x,y)
			FuncGuildExplore._changeMapValue(mapCfg,unPutArr,v,x,y) --先设置怪物所在格子

			if v.ptype then
				local posArr = FuncGuildExplore.getSubChildGridOffset(v.ptype)
				for i=2,#posArr do
					local _x,_y = x+posArr[i][1],y+posArr[i][2]
					FuncGuildExplore._changeMapValue(mapCfg,unPutArr,v,_x,_y,subKey) --设置周边格子的重属于格子
				end
			end
		end
	end
end
-- 随机指定位置的事件
function FuncGuildExplore.randomAppointEvent(mapCfg,unPutArr)
	local result = {}
	-- 根据ExploreAppointNum 配置表随机出指定个数的随机位置(初始化随机事件)
	local tmpArr = {}
	for k,v in pairs(allCfgs["ExploreMapAppointRandom"]) do
		if v.coordinate then
			local tmp = table.deepCopy(v)
			tmp.id = tonumber(k)
			table.insert(tmpArr,tmp)
		end
	end
	table.sort(tmpArr,function( a,b )
		return a.id < b.id
	end)
	local tmpDB = FuncGuildExplore.getCfgDatas("ExploreSetting","ExploreAppointNum")
	if not tmpDB or #tmpArr < tmpDB.num then
		echoError ("固定刷随机事件的数据不对，",#tmpArr,tmpDB.num)
		return {}
	end
	local _tmpMapChange = function(db,x,y,subKey)
		local key = FuncGuildExplore.getKeyByPos(x,y)
		local tmpData = mapCfg[key]
		if not tmpData then
			-- echoError ("坐标不在地图中",x,y)
			return
		end
		if not result[tostring(subKey)] then
			result[tostring(subKey)] = {eventIdList={}}
		end
		local _rArr = result[tostring(subKey)]
		if subKey ~= key then
			if not _rArr.child then
				_rArr.child = {}
			end
			-- 从属格子
			table.insert(_rArr.child,key)
		else
			-- 随机事件
			local randomInt = RandomControl.getOneIndexByGroup(db.events,"weight")
			table.insert(_rArr.eventIdList,{type=tostring(db.type),
											tid=tostring(db.events[randomInt].id)})
		end
		-- 不论是主格子还是随从格子，都不能再随机事件了
		unPutArr[key] = true
	end
	local appointArr = RandomControl.getNumsByGroup(tmpArr,tmpDB.num)
	for k,v in ipairs(appointArr) do
		if v.coordinate then
			-- 获取主坐标
			local x,y = v.coordinate[1],v.coordinate[2]
			local subKey = FuncGuildExplore.getKeyByPos(x,y)
			_tmpMapChange(v,x,y,subKey)--先设置怪物所在格子

			if v.ptype then
				local posArr = FuncGuildExplore.getSubChildGridOffset(v.ptype)
				for i=2,#posArr do
					local _x,_y = x+posArr[i][1],y+posArr[i][2]
					_tmpMapChange(v,_x,_y,subKey)
				end
			end
		end
	end
	-- dump(result,"s====")
	return result
end
-- 随机事件
function FuncGuildExplore.randomAreaEvent(mapCfg,unPutArr)
	local result = {}
	echo("随机区域事件")
	local areaData = FuncGuildExplore.getAllArea()
	for k,v in pairs(areaData) do
		-- 临时存储，用于剔除数据用
		if not v.tmpArea then
			v.tmpArea = {}
		end
		if v.areaPos then
			for kk,vv in pairs(v.areaPos) do
				local key = FuncGuildExplore.getKeyByPos(vv.x,vv.y)
				if not unPutArr[key] then
					v.tmpArea[key] = {x = vv.x,y = vv.y}
				end
			end
		end
	end
	-- 开始随机事件
	local randomData = FuncGuildExplore.getAllRegionRadom()
	for i,v in ipairs(randomData) do
		if v.type then
			local count = RandomControl.getOneRandomInt(v.num[2]+1,v.num[1])
			for j=1,count do
				-- 获取随机事件的区域
				local areaIdx = RandomControl.getOneRandomInt(#v.area+1,1)
				local areaPosArr = areaData[tostring(v.area[areaIdx])]
				-- 如果区域内没有可选的位置了，则需要重新取一个区域
				if table.length(areaPosArr.tmpArea) == 0 then
					areaPosArr = nil
					for k=1,#v.area do
						local tmpArr = areaData[tostring(k)]
						if table.length(tmpArr.tmpArea) > 0 then
							areaPosArr = tmpArr
							break
						end
					end
				end
				if areaPosArr then
					-- 区域内随机一个位置
					local randomTmpArr = {}
					for m,n in pairs(areaPosArr.tmpArea) do
						if n then
							table.insert(randomTmpArr,n)
						end
					end
					local randomArrIdx = RandomControl.getOneRandomInt(#randomTmpArr+1,1)
					local _x,_y = randomTmpArr[randomArrIdx].x,randomTmpArr[randomArrIdx].y
					local posKey = FuncGuildExplore.getKeyByPos(_x,_y)
					-- 根据权重随机一个事件
					local randomInt = RandomControl.getOneIndexByGroup(v.parameter,"w")
					local tmpData = mapCfg[posKey]
					if tmpData then
						local rArr = FuncGuildExplore.updateMapEventData(mapCfg,_x,_y,tostring(v.type),
															tostring(v.parameter[randomInt].id))
						if rArr then
							local eArr = {type=rArr.type,tid=rArr.tid}
							if not result[rArr.key] then
								result[rArr.key] = {eventIdList = {}}
							end
							table.insert(result[rArr.key].eventIdList,eArr)
						end
						-- 随机完事件后，该点及周围的点不可以再被随机到
						local tmpArr = FuncGuildExplore.getExGridPos(_x,_y)
						for m,n in ipairs(tmpArr) do
							local key = FuncGuildExplore.getKeyByPos(n[1],n[2])
							areaPosArr.tmpArea[key] = nil
							unPutArr[key] = true
						end
					end
				end
			end
		end
	end
	return result
end
-- 更新事件对应的数据
function FuncGuildExplore.updateMapEventData(mapCfg,x,y,_type,tid)
	local posKey = FuncGuildExplore.getKeyByPos(x,y)
	local tmpData = mapCfg[posKey]
	if tmpData then
		if not tmpData.eventIdList then
			tmpData.eventIdList = {}
		else
			echoError("这个位置有过事件===",x,y,_type,tid,posKey)
		end
		table.insert(tmpData.eventIdList,{type=_type,tid=tid} )
		-- echo("随机位置事件",x,y,_type,tid,posKey)
		return {key = posKey,type=_type,tid=tid}
	end
	return nil
end
-- 获取地形尺寸(其中x=2 和x=3的地图宽度其实是一样的)
function FuncGuildExplore.getMapSize(maxX,minY,maxY) --地图中y坐标的最小值最大值
	echo("maxX,minY,maxY:",maxX,minY,maxY)
	local x,y =maxX, math.ceil(maxY*10/9)
	-- 这里要把起始的给减掉才能
	local xStart = FuncGuildExplore.getStartX(minY)
	-- 再减去偏差
	local offset = FuncGuildExplore.getOffSet((x - xStart)/2)
	local xEnd = FuncGuildExplore.getStartX(maxY)
	echo("xStart,offset,xEnd:",xStart,offset,xEnd)
	x = x - xEnd - offset - 2
	return x,y
end
-- 根据Y轴获取x的起始位置
function FuncGuildExplore.getStartX(y)
	local offsetPerNums = FuncGuildExplore.offsetPerNums
	local offset = math.ceil(y/offsetPerNums)
	local xStart = y - (offset-1)*2
	return xStart
end
-- 获取获取偏移
function FuncGuildExplore.getOffSet(x)
	local offsetPerNums = FuncGuildExplore.offsetPerNumsUp
	local offset = -math.floor(x/offsetPerNums)
	return offset
end

-- 编辑器用
function FuncGuildExplore.getAllDecorateMaterials( )
	local cfgData = allCfgs["ExploreMapDecorateMaterial"]
	return table.deepCopy(cfgData)
end
-- 判断一个点在哪个区域
function FuncGuildExplore.getAreaIdxByPos(x,y)
	local areaData = allCfgs.ExploreMapSmallBlock
	if not FuncGuildExplore._areaData then
		-- 优化key、value值为index下标判断
		FuncGuildExplore._areaData = {}
		local key,areaIdx
		for k,v in pairs(areaData) do
			areaIdx = tonumber(v.id)
			if v.areaPos then
				if not FuncGuildExplore._areaData[areaIdx] then
					FuncGuildExplore._areaData[areaIdx] = {}
				end
				for m,n in pairs(v.areaPos) do
					key = FuncGuildExplore.getKeyByPos(n.x,n.y)
					FuncGuildExplore._areaData[areaIdx][key] = true
					-- table.insert(FuncGuildExplore._areaData[areaIdx],key)
				end
			end
		end
	end
	local key = FuncGuildExplore.getKeyByPos(x,y)
	for k,v in pairs(FuncGuildExplore._areaData) do
		if v[key] then
			return k
		end
	end
	return 1
end
-- 获取所有地区块信息
function FuncGuildExplore.getAllArea( ... )
	local cfgData = allCfgs["ExploreMapSmallBlock"]
	return table.deepCopy(cfgData)
end
-- 获取所有随机事件
function FuncGuildExplore.getAllRegionRadom( ... )
	local cfgData = allCfgs["ExploreMapRegionRandom"]
	local tmpData = {}
	for i,v in pairs(cfgData) do
		table.insert(tmpData,v)
	end
	table.sort(tmpData,function( a,b )
		return tonumber(a.id) < tonumber(b.id)
	end)
	return tmpData
end
-- 获取随机地形皮肤
function FuncGuildExplore.getAllDecorate( )
	local cfgData = allCfgs["ExploreMapDecorateRandom"]
	local tmpData = {}
	for i,v in pairs(cfgData) do
		table.insert(tmpData,v)
	end
	table.sort(tmpData,function( a,b )
		return tonumber(a.id) < tonumber(b.id)
	end)
	return tmpData
end



--获取仙盟探索的任务数据
function FuncGuildExplore.getQuestData()
	local allData = allCfgs["ExploreQuest"]
	-- dump(allData,"所有任务数据=====")

	local singleData = {}
	local manyPeopleData = {}
	for k,v in pairs(allData) do
		if v.type == FuncGuildExplore.taskType.single then
			table.insert(singleData,v)
		elseif v.type == FuncGuildExplore.taskType.manyPeople then
			table.insert(manyPeopleData,v)
		end
	end

	return singleData,manyPeopleData
end
--获取某个setting配置
function FuncGuildExplore.getSettingDataValue( id,key )
	return FuncGuildExplore.getCfgDatasByKey("ExploreSetting",id,key)
end


--根据grid 获取所在的格子.数组坐标偏移
local bigGridMap = {
	t3 = {
		{0,0},
		{1,-1},
		{2,0},	
	},
	t6 = {
		{0,0},
		{0,-2},
		{1,-1},	{-1,-1},
		{2,0},			{-2,0},
	},
	t10 = {
		{0,0},
		{1,-3},
		{2,-2},	{0,-2}, 
		{3,-1},	{1,-1},{-1,-1},
		{4,0},	{2,0},			{-2,0},
	},

	t15 = {
		{0,0},
		{0,-4},
		{1,-3},	{-1,-3},
		{2,-2},	{0,-2},	{-2,-2},
		{3,-1},	{1,-1},	{-1,-1},	{-3,-1},
		{4,0},	{2,0},				{-2,0},	{-4,0}
	},

	--对应大宝剑 50
	q4 = {
		{0,0},
		{1,-1},{-1,-1},
		{2,0},	
	},

	--这个和q4区别是倾斜方式不一样
	f4 = {
		{0,0},
		{1,-1},	{-1,-1},
				{-2,0},	--{0,0}		
	},

	-- 池塘52
	r10 = {
		{0,0},
		{0,-2},	{-2,-2},
		{1,-1},	{-1,-1},{-3,-1},
						{-2,0},	{-4,0},
						{-1,1},	{-3,1},		
				
	},
	-- 池塘53
	k10 = {
		{ 0, 0},
		{ 1,-3},	{-1,-3},
		{ 2,-2},	{ 0,-2},	{-2,-2},
		{ 3,-1},	{ 1,-1},	{-1,-1},
					{ 2, 0},	

	},
	-- 建筑1  神龙庙
	k16 = {
		{ 0, 0},
							{-3,-5},	{-5,-5},
			{ 0,-4},	{-2,-4},	{-4,-4},	
		{ 1,-3},	{-1,-3},	{-3,-3},	{-5,-3},
				{ 0,-2},	{-2,-2},	{-4,-2},
						{-1,-1},	{-3,-1},	{-5,-1},
								 {-2, 0},	{-4, 0}

	},
	-- 建筑2
	m18 = {
		{ 0, 0},
							{-2,-4},	{-4,-4},	{-6,-4},
						{-1,-3},	{-3,-3},	{-5,-3},
		{ 2,-2},	{ 0,-2},	{-2,-2},	{-4,-2},	{-6,-2},
						{-1,-1},	{-3,-1},	{-5,-1},	{-7,-1},
								{-2, 0},	{-4, 0}
	},


	-- 出生点(圆形的,包括原点)
	birth = {
				{1,-1},{-1,-1},
			{2,0},{0,0},{-2,0},
				{1,1},{-1,1},
	}
}

--获取一个大体型格子周围一圈的坐标偏移. 默认一个点是相对自身.没有偏移.
function FuncGuildExplore.getSubChildGridOffset(t  )
	if not t then
		return nil
	end
	local arr = bigGridMap[t]
	if not arr then
		echoError("没有这个体形:",t)
	end
	return arr
end


-- 获取格子周边六个格子的坐标,及它本身
function FuncGuildExplore.getExGridPos(x,y)
	local exArr = {{1,-1},{-1,-1},{-2,0},{-1,1},{1,1},{2,0}}
	for i,v in ipairs(exArr) do
		v[1] = v[1] + x
		v[2] = v[2] + y
	end
	table.insert(exArr,{x,y})
	return exArr
end


--根据资源类型获取资源ID
function FuncGuildExplore.getResStrIdByType(resType)
	local _type = ""
	local resId = ""
	resType = tonumber(resType)
	if resType  == FuncGuildExplore.resType.guildLiuli then --琉璃
		_type = FuncGuildExplore.guildExploreResType..","
		resId = FuncGuildExplore.resType.guildLiuli
	elseif resType  == FuncGuildExplore.resType.guildLingmeng then --天河石
		_type = FuncGuildExplore.guildExploreResType..","
		resId = FuncGuildExplore.resType.guildLingmeng
	elseif resType  == FuncGuildExplore.resType.guildZijing then --紫晶石
		resId = FuncGuildExplore.resType.guildZijing
		_type = FuncGuildExplore.guildExploreResType..","
	elseif resType  == FuncGuildExplore.resType.guildTianhe then --菱锰石
		resId = FuncGuildExplore.resType.guildTianhe
		_type = FuncGuildExplore.guildExploreResType..","
	elseif resType  == FuncGuildExplore.resType.lingquan then
		resId = FuncGuildExplore.resType.guildTianhe
		_type = FuncGuildExplore.guildExploreResType..","
	elseif resType  == FuncGuildExplore.resType.coin then
		resType = FuncDataResource.RES_TYPE.COIN
	elseif resType  == FuncGuildExplore.resType.diamond then
		resType = FuncDataResource.RES_TYPE.DIAMOND
	elseif resType  == FuncGuildExplore.resType.wood then
		resType = FuncDataResource.RES_TYPE.WOOD
	elseif resType  == FuncGuildExplore.resType.stone then
		resType = FuncDataResource.RES_TYPE.GUILD_STONE
	elseif resType  == FuncGuildExplore.resType.jade then
		resType = FuncDataResource.RES_TYPE.GUILD_JADE
	end

	echo("========resType===========",resType)
	return _type..resType
end



function FuncGuildExplore.getFuncData( cfgsName,id,key )
	local cfgsName = cfgsName
	local id = id
	local keyData 
	if key == nil then
		keyData = FuncGuildExplore.getCfgDatas( cfgsName,id )
	else
		keyData = FuncGuildExplore.getCfgDatasByKey(cfgsName,id,key)
	end
	
	return keyData
end



function FuncGuildExplore.getMonsterReward(monsterId)
	local data = FuncGuildExplore.getFuncData( "ExploreMonster",monsterId )
 	local exhibition = data.exhibition
 	-- local exhibition2 = data.exhibition2
 	-- local reward = data.reward
 	-- local reward2 = data.reward2
 	local newRewardArr  = {}
 	if exhibition then
 		for k,v in pairs(exhibition) do
 			local _type = FuncGuildExplore.guildExploreResType
 			local str = _type..","..v
 			table.insert(newRewardArr,str)
 		end
 	end

 	-- if exhibition2 then
 	-- 	for k,v in pairs(exhibition2) do
 	-- 		table.insert(newRewardArr,v)
 	-- 	end
 	-- end

 	-- if reward then
 	-- 	for k,v in pairs(reward) do
 	-- 		local _type = FuncGuildExplore.guildExploreResType
 	-- 		local str = _type..","..v
 	-- 		table.insert(newRewardArr,str)
 	-- 	end
 	-- end

 	-- if reward2 then
 	-- 	for k,v in pairs(reward2) do
 	-- 		table.insert(newRewardArr,v)
 	-- 	end
 	-- end
 	return exhibition
end


function FuncGuildExplore.getEventIcon( icon )
	return display.newSprite("icon/explore/"..icon..".png")
end
-- 根据类型获取战斗对应的levelId
function FuncGuildExplore.getBattleLevelIdByType(battleParams)
	local eType,gtMap = battleParams.eventType,FuncGuildExplore.gridTypeMap
	local levelId,levelRevise = "10101",nil
	if eType == gtMap.enemy or eType == gtMap.elite then
		local tmpData = allCfgs.ExploreMonster[battleParams.eventTid]
		if not tmpData then
			echoError ("没有找到对应的怪物id",battleParams.eventTid)
		else
			local tmpId = tmpData.level
			if not tmpId then
				echoError ("没有找到对应的怪物levelId")
			else
				levelId = tmpId
				levelRevise = tmpData.increase
			end
		end
	elseif eType == gtMap.mine then
		local tmpData = allCfgs.ExploreMine[battleParams.eventTid]
		if not tmpData then
			echoError ("没有找到对应的矿洞id",battleParams.eventTid)
		else
			local tmpId = tmpData.level[tonumber(battleParams.index)]
			if not tmpId then
				echoError ("没有找到对应的矿洞levelId",battleParams.index)
			else
				levelId = tmpId
			end
		end
	elseif eType == gtMap.build then
		local tmpData = allCfgs.ExploreCity[battleParams.eventTid]
		if not tmpData then
			echoError ("没有找到对应的建筑id",battleParams.eventTid)
		else
			local tmpId = tmpData.level[tonumber(battleParams.group)]
			if not tmpId then
				echoError ("没有找到对应的建筑levelId",battleParams.group)
			else
				levelId = tmpId
				levelRevise = tmpData.increase
			end
		end
	end
	return levelId,levelRevise
end

-- 根据ability(可能是玩家战力、也可能是仙盟战力)、玩家level获取对应的怪物修正系数
function FuncGuildExplore.getLevelRevise(ability,level)
	local DB_dlr = ObjectCommon.getPrototypeData("level.DynamicLevelRevise",level )
	if not DB_dlr then
		echoError ("没有找到对应的动态关卡系数,请检查配表DynamicLevelReviseCfg :",level)
		return
	end
	-- local tmpRevise = math.round(ability/DB_dlr.standardPower * DB_dlr.standardLevelRevise)
	local a,b,c,x = ability,DB_dlr.standardPower,DB_dlr.standardLevelRevise,DB_dlr.deviationRatio
	-- echo("aa===ddd",a,b,c,x)
	-- 修改修正系数
	local tmpRevise = math.round((a/b * c - c) * x/100 + c)
	-- echo("========111111======",ability,DB_dlr.standardPower,DB_dlr.standardLevelRevise,tmpRevise,ability/DB_dlr.standardPower * DB_dlr.standardLevelRevise)
	return tmpRevise
end

function FuncGuildExplore.getServerMap( mapId,randomSeed )
	local data = nil
    local tempFunc =function (  )
        echo("___start get getExploreMap,id,randomSeed,",mapId,randomSeed)
        local tempData  = FuncGuildExplore.getOneRandomMap(mapId, randomSeed )
        data = {mapInfo = {},eventArr = {}}
        local length = 0
        local tmp  ={}
        for k,v in pairs(tempData.cells) do
            v.terrain =nil
            v.decorate = nil
            tmp[tostring(k)] = v
            length = length +1
        end

        echo("___end get getExploreMap,length",length)
        data.mapInfo = tmp
        data.eventArr = tempData.eventArr
    end
    tempFunc()
    if not json then
        echo("this run time has no json ")
    end
    local rt = json.encode(data)
    if data then
    	rt = json.encode(data)
    else
    	rt = ""
    end
    
    return rt
end



--开启时间是否到了
function FuncGuildExplore.isOnTime()
	local allTime = FuncGuildExplore.getCfgDatas( "ExploreSetting","ExploreOpenTime")
	local serveTime = TimeControler:getServerTime()

	local dataTime = os.date("*t",serveTime)

	local timestamps = {}
	for i=1,2 do
		timestamps[i] = {}
		for _x=1,2 do
			local timeStr = allTime.arr[_x]
			local timeArr = string.split(timeStr, ",")
			local _h = timeArr[1]--math.floor(allTime[i][_x]/3600)
			local _m = timeArr[2] --math.floor((allTime[i][_x] - _h * 3600)/60)
			local timeArr = {
				day= dataTime.day, 
				month=dataTime.month,
				year=dataTime.year, 
				hour=_h, 
				min=_m, 
				second=0
			}

			local tamps = os.time(timeArr)
			timestamps[i][_x] = tamps
		end
	end
	local timesArr = {}
	for i=1,2 do
		if serveTime >= timestamps[i][1] and serveTime < timestamps[i][2] then
			table.insert(timesArr,timestamps[i][2] - serveTime)
			return true,timesArr
		end
		local times = timestamps[i][1] - serveTime
		table.insert(timesArr,times)
	end

	return false,timesArr

end


--[[

动态修正系数调整: （自身战力/标准战力*标准修正系数-标准修正系数）*X+标准修正系数
标准战力：standardPower@lua[int]
标准修正系数：standardLevelRevise@lua[int]
X：deviationRatio@lua[int]
都在DymamicLevelRevise表

原战力算法：读取对应等级行，取标准战力
新战力算法: 读取服务器给定 当日最大战力。
计算： （（玩家最大战力 - 标准战力）*X+标准战力）*外部系数

]]
--更具等级获取战力
function FuncGuildExplore.getPowerByLevel(_type,level,id,ability)
	local sourceEx = require("level.DynamicLevelRevise")
	local DB_dlr = sourceEx[tostring(level)]
	local power = 0
	local data = nil
	local deviationRatio = DB_dlr.deviationRatio or 1
	if _type == FuncGuildExplore.gridTypeMap.build then
		data = FuncGuildExplore.getCfgDatas( "ExploreCity",id )
		-- power = ((ability-DB_dlr.standardPower)*(deviationRatio/100) + DB_dlr.standardPower) * (data.increase/100)
	elseif _type == FuncGuildExplore.gridTypeMap.elite then
		data = FuncGuildExplore.getCfgDatas( "ExploreMonster",id )
		-- power = ((ability-DB_dlr.standardPower)*(deviationRatio/100) + DB_dlr.standardPower) * (data.increase/100)
	elseif _type == FuncGuildExplore.gridTypeMap.enemy then
		data = FuncGuildExplore.getCfgDatas( "ExploreMonster",id )
		-- power = ((ability-DB_dlr.standardPower)*(deviationRatio/100) + DB_dlr.standardPower) * (data.increase/100)
 	elseif _type == FuncGuildExplore.gridTypeMap.mine then  
 		data = FuncGuildExplore.getCfgDatas( "ExploreMine",id )
 		
	end
	power = ((ability-DB_dlr.standardPower)*(deviationRatio/100) + DB_dlr.standardPower) * (data.increase/100)
	echo("====传入的战力==ability=====",ability)
	echo("====standardPower=====",DB_dlr.standardPower)
	echo("====deviationRatio=====",deviationRatio/100)
	echo("====DB_dlr.standardPower=====",DB_dlr.standardPower)
	echo("====increase=表中系数值===",data.increase/100)
	echo("====(a*b+c)*d===(a*b+c)==",(ability-DB_dlr.standardPower)*(deviationRatio/100))
	return math.floor(power)
end


function FuncGuildExplore.calculateTime(_finishTime)
    local times = _finishTime - TimeControler:getServerTime()
    if times > 0 then
        times = TimeControler:turnTimeSec(times, TimeControler.timeType_mmss)
    else
        times = ""
    end
    return times
end

--获取场景配置
function FuncGuildExplore.getMapSceneEff( mapId )
	return { ["200010"] = {"UI_xianmengtansuo_a_lvye"}	}

end

