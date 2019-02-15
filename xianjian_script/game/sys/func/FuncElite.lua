--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 20:54:58
--Description: 精英探索 静态方法
--


FuncElite = FuncElite or {}

local config_EliteBox = nil
local config_sceneSkin = nil

FuncElite.isDebug = true


-- 打开宝箱的条件类型
FuncElite.BOX_TYPE = {
	ORGAN = 1, 			-- 破除机关
	NO_CONDITION = 2,	-- 无条件
	POETRY = 3, 		-- 答题正确
	GUESS = 4,			-- 猜人
}


FuncElite.TIPS_VIEW_TYPE = {
	ENTER_SCENE = 1, 	-- 进入场景
	ENTER_NEXT_CHAPTER = 2,	-- 进入下一章
}


FuncElite.numMap = {
    "一","二","三","四","五",
    "六","七","八","九","十",
    "十一","十二","十三","十四","十五",
    "十六","十七","十八","十九","二十",
}


function FuncElite.init()
	config_EliteBox = Tool:configRequire("elite.EliteBox")
end

-- 获取宝箱的配置信息
function FuncElite.getBoxProperty( _boxId )
	local data = config_EliteBox[tostring(_boxId)]
	if data then
		return data
	else
		echoError("___EliteBox表中找不到宝箱的值,_boxId = ",_boxId)
	end
end

-- 根据字段获取宝箱的配置信息
function FuncElite.getBoxPropertyByKey( _boxId,_key )
	local data = config_EliteBox[tostring(_boxId)]
	if data and data[tostring(_key)] then
		return data[tostring(_key)]
	else
		echoError("___EliteBox表中找不到字段_key的值,_key = ",_key)
	end
end

-- 获取开启宝箱的条件类型
function FuncElite.getOpenBoxConditionType( _boxId )
	local type1 =  FuncElite.getBoxPropertyByKey( _boxId,"type" )
	if not type1 then
		type1 = 2
	end
	return type1
end

-- 获取开启宝箱的条件类型
function FuncElite.getOpenBoxConditionParams( _boxId )
	local type1 = FuncElite.getOpenBoxConditionType( _boxId )
	if type1 == FuncElite.BOX_TYPE.ORGAN then
		return FuncElite.getBoxPropertyByKey( _boxId,"organ" )
	elseif type1 == FuncElite.BOX_TYPE.NO_CONDITION then
		return ""
	elseif type1 == FuncElite.BOX_TYPE.POETRY then
		return FuncElite.getBoxPropertyByKey( _boxId,"question" )
	end
end

-- 获取宝箱奖励
function FuncElite.getBoxReward( _boxId )
	local rewardData = FuncElite.getBoxPropertyByKey( _boxId,"reward" )
	return rewardData
end

-- 通过eliteFloor，获取场景皮肤数据
function FuncElite.getEliteMapSkinData(eliteFloor)
    local sceneId = tonumber(eliteFloor)%2
    if sceneId == 0 then
    	sceneId = 2
    end
    if sceneId then
       sceneData = FuncElite.getEliteSceneData(sceneId)
    else
        echoError("FuncElite.getEliteMapSkinData eliteIndex=",eliteIndex)
    end

    return sceneData
end

function FuncElite.getEliteSceneData( sceneId )
	-- 精英只有一种皮肤
	local data = {
		["id"] = 1,
		["skin"] = "UI_elite_grid",
		["map"] = "map_suoyaotawanfa",
		["starAnim"] = "UI_suoyatazhuanchang_lanjinru",
	}
	return data
end