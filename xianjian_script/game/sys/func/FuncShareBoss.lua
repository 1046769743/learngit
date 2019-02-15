--
-- Author: lxh
-- Date: 2017-10-13
--

FuncShareBoss = FuncShareBoss or {}
local shareBossData = nil
local shareBossStar = nil
local shareBossBuff = nil
local enemyLevelInfo = nil

FuncShareBoss.rankRange = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3,
	FORTH_LOWER = 4,
	FORTH_UPPER = 10,
	FIFTH_LOWER = 11,
	FIFTH_UPPER = 20,
	SIXTH = 21,
}
FuncShareBoss.grade = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3,
	FORTH = 4,
	FIFTH = 5,
	SIXTH = 6,
}

function FuncShareBoss.init()
	shareBossData = Tool:configRequire("shareboss.ShareBoss")
	shareBossStar = Tool:configRequire("shareboss.ShareBossStar")
	shareBossBuff = Tool:configRequire("shareboss.ShareBossBuff")
	enemyLevelInfo = Tool:configRequire("level.Level")
end

function FuncShareBoss.getBossDataById(_id)
	local bossData = shareBossData[tostring(_id)]
	if bossData then
		return bossData
	else
		echoWarn("Do not found bossData for this id ".._id)
	end
	return nil
end

function FuncShareBoss.getBossPropByKey(_id, _key)
	local bossData = FuncShareBoss.getBossDataById(_id)
	if bossData then
		local value = bossData[tostring(_key)]
		if value then
			return value
		else
			echoWarn("Do not found value in bossData for this key ".._key)
		end
	else
		echoWarn("Do not found bossData for this id ".._id)
	end
	return nil
end

function FuncShareBoss.getBossNameById(_id)
	local name = FuncShareBoss.getBossPropByKey(_id, "name")
	return name
end

function FuncShareBoss.getBossStarById(_id)
	local star = FuncShareBoss.getBossPropByKey(_id, "star")
	return star
end

function FuncShareBoss.getLiveTimeById(_id)
	local liveTime = FuncShareBoss.getBossPropByKey(_id, "liveTime")
	return liveTime	
end

function FuncShareBoss.getLevelIdById(_id)
	local levelId = FuncShareBoss.getBossPropByKey(_id, "levelId")
	return levelId	
end

-- function FuncShareBoss.getBossHpById(_id)
-- 	local hp = FuncShareBoss.getBossPropByKey(_id, "hp")
-- 	return hp	
-- end

function FuncShareBoss.getFindRewardById(_id)
	local findRewards = FuncShareBoss.getBossPropByKey(_id, "findReward")
	return findRewards	
end

function FuncShareBoss.getBraveRewardById(_id)
	local braveRewards = FuncShareBoss.getBossPropByKey(_id, "braveReward")
	return braveRewards	
end

function FuncShareBoss.getRankRewardsById(_id)
	local rankRewards = {}
	for i = 1, 6 do
		local rankReward = FuncShareBoss.getBossPropByKey(_id, "rankReward"..i)
		if rankReward == nil then
			rankReward = {}
		end
		table.insert(rankRewards, rankReward)
	end
	return rankRewards	
end

function FuncShareBoss.getTotalHpById(_id)
	local totalHp = 0
	local hp_table = string.split(FuncShareBoss.getBossPropByKey(_id, "hp"), ";")
	for k,v in pairs(hp_table) do
		if v == "" then
			v = 0
		end
		totalHp = totalHp + tonumber(v)
	end
	return totalHp
end

function FuncShareBoss.getBuffDesByBuffId(_buffId)
	return shareBossBuff[_buffId].word
end

function FuncShareBoss.getBuffAttrByBuffId(_buffId)
	return shareBossBuff[_buffId].attr
end

-- 获取buff数据
function FuncShareBoss.getBuffByBuffId(_buffId)
	if not shareBossBuff[_buffId] then
		echoError("找侯震----buffId",_buffId," 在ShareBossBuff表中找不到，使用默认id 1 代替")
		return shareBossBuff["1"]
	end
	return shareBossBuff[_buffId]
end

function FuncShareBoss.getEnemyFactorByLevelId(_levelId)
	local enemyFactor = 100
	local enemyLevelInfo = enemyLevelInfo[_levelId]["1"]
	if enemyLevelInfo.levelRevise and enemyLevelInfo.levelRevise[1] then
		enemyFactor = enemyLevelInfo.levelRevise[1]
	end
	return enemyFactor
end

function FuncShareBoss.getEnemyIdByLevelId(_levelId)
	local enemyIds = {}
	local enemyLevelInfo = enemyLevelInfo[_levelId]
	if not enemyLevelInfo then
		echo("\n\nlevel表中没有找到id".._levelId.."的关卡")
	else
		enemyLevelInfo = enemyLevelInfo["1"]
		for i = 1, 6 do
			local enemyId = enemyLevelInfo["e"..i]
			if enemyId then
				table.insert(enemyIds, enemyId)
			else
				enemyId = ""
				table.insert(enemyIds, enemyId)
			end
		end
	end
	
	return enemyIds
end

function FuncShareBoss.isBossById(_enemyId)
	-- body
end

function FuncShareBoss.getMasterFactorById(_id)
	local masterFactor = FuncShareBoss.getBossPropByKey(_id, "master")
	return masterFactor
end

function FuncShareBoss.getBossFactorById(_id)
	local bossFactor = FuncShareBoss.getBossPropByKey(_id, "boss")
	return bossFactor
end

function FuncShareBoss.getMasterHpFactorById(_id)
	local masterFactor = FuncShareBoss.getBossPropByKey(_id, "master")
	local factor = 0
	for k,v in pairs(masterFactor) do
		if v.key == 1 then
			factor = v.value
		end
	end
	return factor
end

function FuncShareBoss.getBossHpFactorById(_id)
	local bossFactor = FuncShareBoss.getBossPropByKey(_id, "boss")
	local factor = 0
	for k,v in pairs(bossFactor) do
		if v.key == 1 then
			factor = v.value
		end
	end
	return factor
end

function FuncShareBoss.getBossHpById(_id, _bossId)
	local levelId = FuncShareBoss.getLevelIdById(tostring(_bossId))
	local masterFactor = FuncShareBoss.getMasterHpFactorById(tostring(_bossId))
	local bossFactor = FuncShareBoss.getBossHpFactorById(tostring(_bossId))
	local enemyFactor = FuncShareBoss.getEnemyFactorByLevelId(levelId)


	local enemyInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", _id)
	local enemyHp = 0
	if enemyInfo.boss == 1 then
		enemyHp = math.round((enemyInfo.hp * enemyFactor / 100) * (1 + bossFactor / 10000))
	else
		enemyHp = math.round((enemyInfo.hp * enemyFactor / 100) * (1 + masterFactor / 10000))
	end
	return enemyHp
end

-- 根据tagsStr获得buff加成描述
function FuncShareBoss.getBuffDescription(_tagsStr)
	local tags = FuncCommon.splitStringIntoTable(_tagsStr)
	local name_table = {}
	for i,v in ipairs(tags) do
		local name = FuncCommon.getTagNameByTypeAndId(v[1], v[2])
		table.insert(name_table, name)
	end
	return name_table
end
