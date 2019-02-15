FuncChallenge= FuncChallenge or {}

local config_challenge = nil
local config_pvp_challenge = nil



function FuncChallenge.init()
	config_challenge = require("challenge.Challenge")
	config_pvp_challenge = require("challenge.ChallengePvp")
end

function FuncChallenge.getDataByKey(itemId,key)
    local valueRow = config_challenge[itemId]
	if valueRow == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey id " ..  tostring(id) .. " is nil")
		return nil
	end 
	local value = valueRow[key]
	if value == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey key " ..  tostring(key) .. " is nil")
	end 
	return value
end
--通过itemId获得开启的条件
function FuncChallenge.getOpenLevelByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"condition")
end

--通过itemId获得daytime
function FuncChallenge.getDayTimeByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"dayTimes")
end

--通过itemId获得icon
function FuncChallenge.getIconByitemId(itemId)
	return FuncChallenge.getDataByKey(itemId,"icon")
end
function FuncChallenge.getPvpIconByitemId(itemId)
	local valueRow = config_pvp_challenge[itemId]
	if valueRow == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey id " ..  tostring(id) .. " is nil")
		return nil
	end 
	local value = valueRow["icon"]
	if value == nil then 
		echo("error: FuncChallenge.getAchievementValueByKey key " ..  tostring(key) .. " is nil")
	end 
	return value
end


---获取历练里面
function FuncChallenge.getPveSystemData()
	return config_challenge
end

function FuncChallenge:getPvpSystemData()
	return config_pvp_challenge or {}
end


