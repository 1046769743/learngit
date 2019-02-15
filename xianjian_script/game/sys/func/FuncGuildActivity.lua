--
--Author:      zhuguangyuan
--DateTime:    2017-10-21 10:58:47
--Description: 仙盟GVE活动静态函数
--
FuncGuildActivity= FuncGuildActivity or {}

local config_FoodActivity = nil
local config_FoodComposition = nil
local config_FoodItem = nil
local config_FoodFight = nil
local config_FoodLevel = nil
local config_FoodAccumulateAward = nil

-- 积分奖励领取状态
FuncGuildActivity.rewardStatus = {
	HAVE_GOT = 0,
	CAN_GET = 1,
	CAN_NOT_GET = 2
}

-- 食材量状态
FuncGuildActivity.ingredientStatus = {
	quiteLack = "十分缺乏",
	insufficient = "不足",
	almost = "差不多",
	enough = "足够"
}

-- 怪的类型
FuncGuildActivity.monsterType = {
	food = 1,
	red  = 2,
	blue = 3,
	gold = 4,
}

FuncGuildActivity.isDebug = false
FuncGuildActivity.maxMonsterNum = 20
FuncGuildActivity.minIndex = "0"
FuncGuildActivity.maxIndex = "21"

-- 食物最高星级
FuncGuildActivity.maxFoodStar = 5
-- 组队最大人数
FuncGuildActivity.maxTeamMemberNum = 3


-- 提示弹窗类型
-- 公用一个界面 只是提示不同
FuncGuildActivity.tipViewType = {
	quitTeam = 1,
	quitChallenge = 2,
}

FuncGuildActivity.mapOffsetMaxX = 1280
FuncGuildActivity.mapOffsetMinX = 0




function FuncGuildActivity.init()
	-- 活动配置
    config_FoodActivity = Tool:configRequire("food.FoodActivity")

    -- 活动可能出现的食物相关信息
	config_FoodComposition = Tool:configRequire("food.FoodInfo")

	-- 组成食物的食材
    config_FoodItem = Tool:configRequire("food.FoodItem")

    -- 活动中收集食材需要击杀的怪
    config_FoodFight = Tool:configRequire("food.FoodFight")

    -- 不同食材量决定的食物的品质及奖励
    config_FoodLevel = Tool:configRequire("food.FoodLevel")

    -- 累积奖励
    config_FoodAccumulateAward = Tool:configRequire("food.FoodAccumulateAward")
end



--------------------------------------------------------------------------
---------------------- 1、活动相关 		  --------------------------------
---------------------- FoodActivity    	  --------------------------------
--------------------------------------------------------------------------
function FuncGuildActivity.getActivityConfigData( _activityId )
	local activityConfigData = nil
	if not _activityId then
		activityConfigData = config_FoodActivity["1"]
	else
		activityConfigData = config_FoodActivity[tostring(_activityId)]
	end
	return activityConfigData
end
-- 取活动背景图
function FuncGuildActivity.getActivityBg(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.foodScene then
		echoError("配表中：活动 _activityId 的 foodScene 不存在 ______ ",_activityId)
	end
	return activityConfigData.foodScene
end
-- 取活动开启日
function FuncGuildActivity.getActivityOpenDay(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.openDay then
		echoError("配表中：活动 _activityId 的 openDay 不存在 ______ ",_activityId)
	end
	return activityConfigData.openDay
end
-- 取活动开启时间
function FuncGuildActivity.getActivityOpenTime(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.openTime then
		echoError("配表中：活动 _activityId 的 openTime 不存在 ______ ",_activityId)
	end
	return activityConfigData.openTime
end
-- 取活动开启的最低仙盟等级
function FuncGuildActivity.getActivityOpenMinLevel(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.openBangLv then
		echoError("配表中：活动 _activityId 的 openBangLv 不存在 ______ ",_activityId)
	end
	return activityConfigData.openBangLv
end

-- 取活动说明文本
function FuncGuildActivity.getActivityText(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.foodTxt then
		echoError("配表中：活动 _activityId 的 foodTxt 不存在 ______ ",_activityId)
	end
	return activityConfigData.foodTxt
end
-- 取活动可能出现的菜品序列
function FuncGuildActivity.getActivityFoodSequence(_activityId)
	local activityConfigData = FuncGuildActivity.getActivityConfigData( _activityId )

	if not activityConfigData.foodSequence then
		echoError("配表中：活动 _activityId 的 foodSequence 不存在 ______ ",_activityId)
	end
	return activityConfigData.foodSequence
end



--------------------------------------------------------------------------
---------------------- 2、食物相关 		  --------------------------------
---------------------- FoodComposition    --------------------------------
--------------------------------------------------------------------------
-- 取菜名
function FuncGuildActivity.getFoodName(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].foodName then
		echoError("配表中：菜 _foodId 的 foodName 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].foodName
end

-- 取菜图标
function FuncGuildActivity.getFoodIcon(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].foodIcon then
		echoError("配表中：菜 _foodId 的 foodIcon 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].foodIcon
end

-- 取点菜的NPC
function FuncGuildActivity.getFoodNPC(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].foodNpc then
		echoError("配表中：菜 _foodId 的 foodNpc 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].foodNpc
end

-- 取点菜的NPC的话
function FuncGuildActivity.getFoodNPCBubble(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].npcBubble then
		echoError("配表中：菜 _foodId 的 npcBubble 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].npcBubble
end

-- 取菜的食材组成
function FuncGuildActivity.getFoodMaterial(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].foodComposition then
		echoError("配表中：菜 _foodId 的 foodComposition 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].foodComposition
end

-- 取菜的guaiwu组成
function FuncGuildActivity.getFoodMonster(_foodId)
	if not config_FoodComposition[tostring(_foodId)] then
		echoError("配表中：菜id不存在____ _foodId _______ ",_foodId)
	end
	if not config_FoodComposition[tostring(_foodId)].monsterComposition then
		echoError("配表中：菜 _foodId 的 monsterComposition 不存在 ______ ",_foodId)
	end
	return config_FoodComposition[tostring(_foodId)].monsterComposition
end



--------------------------------------------------------------------------
---------------------- 3、食材相关 		  --------------------------------
---------------------- FoodItem    	      --------------------------------
--------------------------------------------------------------------------
-- 取食材名
function FuncGuildActivity.getMaterialName(_materialId)
	if not config_FoodItem[tostring(_materialId)] then
		echoError("配表中：食材id不存在____ _materialId _______ ",_materialId)
		return
	end
	if not config_FoodItem[tostring(_materialId)].foodItemItemName then
		echoError("配表中：食材 _materialId 的 foodItemItemName 不存在 ______ ",_materialId)
		return
	end
	return config_FoodItem[tostring(_materialId)].foodItemItemName
end

-- 取食材图标
function FuncGuildActivity.getMaterialIcon(_materialId)
	if not config_FoodItem[tostring(_materialId)] then
		echoError("配表中：食材id不存在____ _materialId _______ ",_materialId)
		return
	end
	if not config_FoodItem[tostring(_materialId)].foodItemIcon then
		echoError("配表中：食材 _materialId 的 foodItemIcon 不存在 ______ ",_materialId)
		return
	end
	return config_FoodItem[tostring(_materialId)].foodItemIcon
end

-- -- 取得每投入一份可获得的奖励及概率
-- function FuncGuildActivity.getMaterialProbablyReward(_materialId)
-- 	if not config_FoodItem[tostring(_materialId)] then
-- 		echoError("配表中：食材id不存在____ _materialId _______ ",_materialId)
-- 		return
-- 	end
-- 	if not config_FoodItem[tostring(_materialId)].foodItemReward then
-- 		echoError("配表中：食材 _materialId 的 foodItemReward 不存在 ______ ",_materialId)
-- 		return
-- 	end
-- 	return config_FoodItem[tostring(_materialId)].foodItemReward
-- end

-- 获取食材的每次活动投放上限
function FuncGuildActivity.getMaterialCanPutInMaxNum(_materialId)
	if not config_FoodItem[tostring(_materialId)] then
		echoError("配表中：食材id不存在____ _materialId _______ ",_materialId)
		return
	end
	if not config_FoodItem[tostring(_materialId)].foodItemMax then
		echoError("配表中：食材 _materialId 的 foodItemMax 不存在 ______ ",_materialId)
		return
	end
	return config_FoodItem[tostring(_materialId)].foodItemMax
end




--------------------------------------------------------------------------
---------------------- 4、怪相关 		  --------------------------------
---------------------- FoodFight    	  --------------------------------
--------------------------------------------------------------------------
-- 取怪物 击杀获得的食材和数量
function FuncGuildActivity.getMonsterMaterialList(_monsterId)
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if config_FoodFight[tostring(_monsterId)].monsterType then
		if tonumber(config_FoodFight[tostring(_monsterId)].monsterType) ~= FuncGuildActivity.monsterType.food then
			return
		end
	end
	if not config_FoodFight[tostring(_monsterId)].beatFoodItem then
		echoError("配表中：怪物 _monsterId 的 beatFoodItem 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].beatFoodItem
end

-- 取怪物 击杀获得的积分
function FuncGuildActivity.getMonsterScore(_monsterId)
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if config_FoodFight[tostring(_monsterId)].monsterType then
		if tonumber(config_FoodFight[tostring(_monsterId)].monsterType) ~= FuncGuildActivity.monsterType.food then
			return
		end
	end
	if not config_FoodFight[tostring(_monsterId)].beatScore then
		echoError("配表中：怪物 _monsterId 的 beatScore 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].beatScore
end

-- 取怪物 战斗强度修正
function FuncGuildActivity.getMonsterFightDiff(_monsterId)
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if not config_FoodFight[tostring(_monsterId)].fightDiff then
		echoError("配表中：怪物 _monsterId 的 fightDiff 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].fightDiff
end

function FuncGuildActivity.getFoodFightByMonsterId( _monsterId )
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("FoodFight表中没有对应的monsterId,使用默认id：10001",_monsterId)
		return config_FoodFight["10001"]
	end
	return config_FoodFight[tostring(_monsterId)]
end

-- 获取怪物的类型
-- 食材怪还是特殊怪
function FuncGuildActivity.getMonsterTypeByMonsterId( _monsterId )
	echo("_monsterId====",_monsterId)
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if not config_FoodFight[tostring(_monsterId)].monsterType then
		echoError("配表中：怪物 _monsterId 的 monsterType 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].monsterType
end

-- 获取特殊怪物的话
function FuncGuildActivity.getMonsterBubbleByMonsterId( _monsterId )
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if not config_FoodFight[tostring(_monsterId)].monsterBubble then
		echoError("配表中：怪物 _monsterId 的 monsterBubble 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].monsterBubble
end

-- 获取特殊怪物的击杀奖励(进背包)
function FuncGuildActivity.getMonsterItemRewardByMonsterId( _monsterId )
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if not config_FoodFight[tostring(_monsterId)].foodMonsterReward then
		echoError("配表中：怪物 _monsterId 的 foodMonsterReward 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].foodMonsterReward
end

-- 获取怪对应level
function FuncGuildActivity.getMonsterLevelIdByMonsterId( _monsterId )
	if not config_FoodFight[tostring(_monsterId)] then
		echoError("配表中：怪物id不存在____ _monsterId _______ ",_monsterId)
	end
	if not config_FoodFight[tostring(_monsterId)].foodLevelId then
		echoError("配表中：怪物 _monsterId 的 foodLevelId 不存在 ______ ",_monsterId)
	end
	return config_FoodFight[tostring(_monsterId)].foodLevelId
end


--------------------------------------------------------------------------
---------------------- 5、食物等级相关 	  --------------------------------
---------------------- FoodLevel    	  --------------------------------
--------------------------------------------------------------------------
-- 获取食物品质的一条数据
function FuncGuildActivity.getFoodLevelData( _foodId,_level )
	for k,v in pairs(config_FoodLevel) do
		-- dump(v,"食物等级的一条信息")
		if v["1"].foodId == tostring(_foodId) then
			if v[tostring(_level)] then
				return v[tostring(_level)]
			end
		end
	end
	echoError("配表中：食物等级 _foodId 的 _level 不存在 ______ ",_foodId,_level)
end

-- 获取某品质的食物的食材要求
function FuncGuildActivity.getXXFoodMaterialDemand( _foodId,_level )
	local data = FuncGuildActivity.getFoodLevelData( _foodId,_level )
	if data and data.foodCompsitionMin then
		return data.foodCompsitionMin
	end
	echoError("配表中：食物等级 _foodId 的 foodCompsitionMin 不存在 ______ ",_foodId)
end

-- 获取某品质的食物的奖励信息
function FuncGuildActivity.getXXFoodLevelReward( _foodId,_level )
	local data = FuncGuildActivity.getFoodLevelData( _foodId,_level )
	if data and data.foodLevelReward then
		return data.foodLevelReward
	end
	echoError("配表中：食物等级 _foodId 的 foodLevelReward 不存在 ______ ",_foodId)
end

-- 获取当前已经投入食材能得到的对应的食物等级
function FuncGuildActivity.getFoodStar( _foodId,_materialArr )
	-- dump(_materialArr,"__ FuncGuildActivity.getFoodStar __传进来的数据")
	-- echo("_foodId==",_foodId)

	local maxStar = 5

	local foodStar = 0
	local materialStarArr = {}
	for level = 1,maxStar do
		local data = FuncGuildActivity.getXXFoodMaterialDemand( _foodId,level )
		-- echo("_foodId=====",_foodId)
		-- dump(data,"------------data-----------")
		-- 计算每一个食材能达到的最大等级
		for k,v in pairs(data) do
			if not materialStarArr[v.id] then
				materialStarArr[v.id] = 0
			end

			local haveNum = 0
			if _materialArr[v.id] then
				haveNum = _materialArr[v.id].curNum
				if haveNum >= tonumber(v.num) then
					materialStarArr[v.id] = level
				end
			end
		end
	end

	-- dump(materialStarArr,"materialStarArr---------")
	foodStar = 0
	
	if table.length(materialStarArr) > 0 then
		foodStar = maxStar
		for k,v in pairs(materialStarArr) do
			if tonumber(v) < foodStar then
				foodStar = tonumber(v)
			end
		end
	end

	return foodStar
end

--------------------------------------------------------------------------
---------------------- 6、累积奖励 	  ------------------------------------
---------------------- FoodAccumulateAward--------------------------------
--------------------------------------------------------------------------
-- 获取累积奖励做展示
function FuncGuildActivity.getAccumulateReward( )
	return config_FoodAccumulateAward
end

--------------------------------------------------------------------------
-- 其他函数
--------------------------------------------------------------------------
-- 根据百分比获取其对应的状态文字
function FuncGuildActivity.getMaterialNumStatus( _percent )
	local numStatus = ""
	local percent = _percent or 0
    if percent < 20 then
    	numStatus = FuncGuildActivity.ingredientStatus.quiteLack
    elseif percent < 40 then
    	numStatus = FuncGuildActivity.ingredientStatus.insufficient
   	elseif percent < 60 then
   		numStatus = FuncGuildActivity.ingredientStatus.almost
    else -- if percent < 80 then
    	numStatus = FuncGuildActivity.ingredientStatus.enough
    end
    return numStatus
end 


function FuncGuildActivity.getComboScore( _monsterId,_comboNum )
	local getIngredientsNum = 0
	local getScoreNum = 0
	local multiple = FuncDataSetting.getComboTimesMultiple( _comboNum )

	local ingredientRewardList = table.deepCopy(FuncGuildActivity.getMonsterMaterialList(_monsterId))
	if ingredientRewardList then
		for k,v in pairs(ingredientRewardList) do
			dump(v,"击杀怪物获得的奖励"..k)
			v.num = v.num * _comboNum * multiple
		end
	end

	-- dump(ingredientRewardList,"_____ 奖励食材数据")

	local score = FuncGuildActivity.getMonsterScore(_monsterId)
	if score then
		score = score * _comboNum * multiple 
	end
	-- echo("_________ score __________",score)
	return ingredientRewardList,score
end

