--
-- Author: lxh
-- Date: 2017-10-13
--

FuncGuildBoss = FuncGuildBoss or {}
local guildBossData = nil
local enemyLevelInfo = nil
local concertSkillCfg = nil

FuncGuildBoss.rankRange = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3,
	FORTH_LOWER = 4,
	FORTH_UPPER = 10,
	FIFTH_LOWER = 11,
	FIFTH_UPPER = 20,
	SIXTH = 21,
}
FuncGuildBoss.grade = {
	FIRST = 1,
	SECOND = 2,
	THIRD = 3,
	FORTH = 4,
	FIFTH = 5,
	SIXTH = 6,
}

-- 副本状态
FuncGuildBoss.ectypeStatus = {
	LOCK = 1,  ---没解锁
	UNLOCK = 2, ---解锁
	BATTLEING = 3, --战斗中
}

FuncGuildBoss.rewardType = {
	rankReward = 1,--排行奖励类型
	battleReward = 2,--参战奖励类型
	finalReward = 3,--尾刀奖励类型
}



FuncGuildBoss.isDebug = false
FuncGuildBoss.maxEctypeNum = 30


function FuncGuildBoss.init()
	guildBossData = Tool:configRequire("guildboss.GuildBoss")
	enemyLevelInfo = Tool:configRequire("level.Level")
	concertSkillCfg = Tool:configRequire("level.ConcertSkill")
end

-- 获取神力技能列表数据
function FuncGuildBoss.getConcertSkillDataById(_id)
	local csData = concertSkillCfg[tostring(_id)]
	if csData then
		return csData
	else
		echoWarn("Do not found ConcertSkill for this id ",_id)
	end
	return nil
end

function FuncGuildBoss.getBossDataById(_id)
	local bossData = guildBossData[tostring(_id)]
	if bossData then
		return bossData
	else
		echoWarn("Do not found bossData for this id ".._id)
	end
	return nil
end

function FuncGuildBoss.getBossPropByKey(_id, _key)
	local bossData = FuncGuildBoss.getBossDataById(_id)
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

function FuncGuildBoss.getBossNameById(_id)
	local name = FuncGuildBoss.getBossPropByKey(_id, "name")
	return name
end

function FuncGuildBoss.getBossStarById(_id)
	local star = FuncGuildBoss.getBossPropByKey(_id, "star")
	return star
end

function FuncGuildBoss.getLiveTimeById(_id)
	local liveTime = FuncGuildBoss.getBossPropByKey(_id, "liveTime")
	return liveTime	
end

function FuncGuildBoss.getLevelIdById(_id)
	local levelId = FuncGuildBoss.getBossPropByKey(_id, "levelId")
	return levelId	
end

-- function FuncGuildBoss.getBossHpById(_id)
-- 	local hp = FuncGuildBoss.getBossPropByKey(_id, "hp")
-- 	return hp	
-- end

function FuncGuildBoss.getFindRewardById(_id)
	local findRewards = FuncGuildBoss.getBossPropByKey(_id, "findReward")
	return findRewards	
end

function FuncGuildBoss.getBraveRewardById(_id)
	local braveRewards = FuncGuildBoss.getBossPropByKey(_id, "braveReward")
	return braveRewards	
end

function FuncGuildBoss.getRankRewardsById(_id)
	local rankRewards = {}
	for i = 1, 6 do
		local rankReward = FuncGuildBoss.getBossPropByKey(_id, "rankReward"..i)
		if rankReward == nil then
			rankReward = {}
		end
		table.insert(rankRewards, rankReward)
	end
	return rankRewards	
end

function FuncGuildBoss.getTotalHpById(_id)
	local totalHp = 0
	local hp_table = string.split(FuncGuildBoss.getBossPropByKey(_id, "hp"), ";")
	for k,v in pairs(hp_table) do
		if v == "" then
			v = 0
		end
		totalHp = totalHp + tonumber(v)
	end
	return totalHp
end

function FuncGuildBoss.getEnemyFactorByLevelId(_levelId)
	local enemyFactor = 100
	-- echoError("=======_levelId=======",_levelId)
	if enemyLevelInfo[_levelId] then
		local enemyLevelInfo = enemyLevelInfo[_levelId]["1"]
		if enemyLevelInfo.levelRevise and enemyLevelInfo.levelRevise[1] then
			enemyFactor = enemyLevelInfo.levelRevise[1]
		end
	end
	return enemyFactor
end

function FuncGuildBoss.getEnemyIdByLevelId(_levelId)
	local enemyIds = {}
	local enemyLevelInfo = enemyLevelInfo[_levelId]["1"]
	if not enemyLevelInfo then
		echo("\n\nlevel表中没有找到id".._levelId.."的关卡")
	else
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

function FuncGuildBoss.isBossById(_enemyId)
	-- body
end

function FuncGuildBoss.getMasterFactorById(_id)
	local masterFactor = FuncGuildBoss.getBossPropByKey(_id, "master")
	return masterFactor
end

function FuncGuildBoss.getBossFactorById(_id)
	local bossFactor = FuncGuildBoss.getBossPropByKey(_id, "boss")
	return bossFactor
end

function FuncGuildBoss.getMasterHpFactorById(_id)
	local masterFactor = FuncGuildBoss.getBossPropByKey(_id, "master")
	local factor = 0
	for k,v in pairs(masterFactor) do
		if v.key == 1 then
			factor = v.value
		end
	end
	return factor
end

function FuncGuildBoss.getBossHpFactorById(_id)
	local bossFactor = FuncGuildBoss.getBossPropByKey(_id, "boss")
	local factor = 0
	for k,v in pairs(bossFactor) do
		if v.key == 1 then
			factor = v.value
		end
	end
	return factor
end

function FuncGuildBoss.getBossHpById(_id, _bossId)
	local levelId = FuncGuildBoss.getLevelIdById(tostring(_bossId))
	-- local masterFactor = FuncGuildBoss.getMasterHpFactorById(tostring(_bossId))
	-- local bossFactor = FuncGuildBoss.getBossHpFactorById(tostring(_bossId))
	local enemyFactor = FuncGuildBoss.getEnemyFactorByLevelId(levelId)


	local enemyInfo = ObjectCommon.getPrototypeData("level.EnemyInfo", _id)
	-- dump(enemyInfo, "enemyInfo")
	local enemyHp = enemyInfo.hp
	-- if enemyInfo.boss == 1 then
		enemyHp = math.round(enemyInfo.hp * enemyFactor / 100)
	-- else
	-- 	enemyHp = math.round((enemyInfo.hp * enemyFactor / 100) * (1 + masterFactor / 10000))
	-- end
	return enemyHp
end

--获取系统开启的时间
function FuncGuildBoss.getGuildBossOpenTime()
	local data = FuncDataSetting.getDataByHid("GuildBossOpenTime")
	local arr = data.arr
	local opentime = {}
	for i=1,#arr do
		local objArr = string.split(arr[i],",")
		opentime[i] = {[1] = objArr[1],[2] = objArr[2]}
	end


	return opentime
end

--开启时间是否到了
function FuncGuildBoss.isOnTime()
	local allTime = FuncGuildBoss.getGuildBossOpenTime()
	local serveTime = TimeControler:getServerTime()

	local dataTime = os.date("*t",serveTime)

	local timestamps = {}
	for i=1,2 do
		timestamps[i] = {}
		for _x=1,2 do
			local _h = math.floor(allTime[i][_x]/3600)
			local _m = math.floor((allTime[i][_x] - _h * 3600)/60)
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




function FuncGuildBoss.getBossReward(bossID)
	local bossData = guildBossData[tostring(bossID)]
	local newData = {}

	--参战奖励
	local battleReward = bossData.battleReward
	local _index_1 = FuncGuildBoss.rewardType.battleReward
	-- for k,v in pairs(battleReward) do
	for i=1,#battleReward do
		local reward = {
			_type = _index_1,
			reward = battleReward[i],
		}
		table.insert(newData,reward)
	end


	--排行奖励
	local rankReward = bossData.rankReward1

	local _index_2 = FuncGuildBoss.rewardType.rankReward
	-- for k,v in pairs(rankReward) do
	for i=1,#rankReward do
		local reward = {
			_type = _index_2,
			reward = rankReward[i],
		}
		table.insert(newData,reward)
	end

	--尾刀奖励
	local finalReward = bossData.finalReward
	local _index_3 = FuncGuildBoss.rewardType.finalReward
	-- for k,v in pairs(finalReward) do
	for i=1,#finalReward do
		local reward = {
			_type = _index_3,
			reward = finalReward[i],
		}
		table.insert(newData,reward)
	end

	-- dump(newData,"共闯秘境的奖励数据")

	return newData
end


-- 计算血量
function FuncGuildBoss.calculateHp( _itemBaseData )

	-- 副本总血量等于关卡中的怪物的总血量
	local totalHp, curDamage = 0,0
	local levelId = FuncGuildBoss.getLevelIdById(_itemBaseData.id)
	local enemyIds = FuncGuildBoss.getEnemyIdByLevelId(levelId)
	for i, v in ipairs(enemyIds) do
		if v ~= "" then
			local oneEnemyHp = FuncGuildBoss.getBossHpById(v, _itemBaseData.id)
			totalHp = totalHp + tonumber(oneEnemyHp)
		end
	end
	-- echo("__总血量_____totalHp__________",totalHp)

	-- 当前伤害量
	local curDamage = 0
	if _itemBaseData.bossHp ~= nil and _itemBaseData.bossHp ~= {} then
		for k,v in pairs(_itemBaseData.bossHp) do
			local id_table = string.split(k, "_")
			-- 由于多人参战,服务器返回的血量可能会溢出(超出总血量),
			-- 此处做最低限定,防止显示异常
			local upperHp = FuncGuildBoss.getBossHpById(id_table[1], _itemBaseData.id)
			if tonumber(upperHp) < tonumber(v) then
				v = upperHp
			end
			curDamage = curDamage + tonumber(v)
		end
	end
	-- echo("___当前上海量____ curDamage __________",curDamage)
	local currentHp = totalHp - curDamage
	local percent = tonumber(string.format("%0.1f", tostring(currentHp * 100 / totalHp))) --math.ceil(currentHp * 100 / totalHp)
	return percent
end





--仙盟boss的挑战次数
function FuncGuildBoss.getBossAttackTimes()
	local count = FuncDataSetting.getDataByConstantName("GuildBossAttackTimes") or 2
	return count
end

-- 获取神力技能资源
function FuncGuildBoss.getSpiritResForBattle(id)
	local result = {}

	local csData = FuncGuildBoss.getConcertSkillDataById(id)
	if csData then
		if csData.effSpine then
			for _,eff in ipairs(csData.effSpine) do
				table.insert(result,eff)
			end
		end
		-- 找技能镜头相关资源
		local skill = ObjectCommon.getPrototypeData("battle.Skill",tostring(csData.mapSkill))
		if skill and skill.cameraSpineParams then
			local cameraSkilParams = skill.cameraSpineParams
			if cameraSkilParams.jingtou ~= "0" then
				table.insert(result, cameraSkilParams.jingtou)
			end
			if cameraSkilParams.wenzi ~= "0" then
				table.insert(result, cameraSkilParams.wenzi)
			end
			if cameraSkilParams.lihui ~= "0" then
				table.insert(result, cameraSkilParams.lihui)
			end
		end
	end

	return result
end