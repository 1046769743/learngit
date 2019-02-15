
FuncLoading = FuncLoading or {}

FuncLoading.LOADING_TYPE = {
	TYPE_1 = 1,
	TYPE_2 = 2,
}

local levelData = nil;
local config_dayRelation = nil
function FuncLoading.init()
	levelData = Tool:configRequire("level.Level");
	config_dayRelation = Tool:configRequire("loading.DayRelation")
end

function FuncLoading.getLoadingDataByKey(id,key)
	local data = FuncLoading.getLoadingData(tostring(id))
	if data ~= nil then
		return data[tostring(key)]
	else
		echoError("FuncLoading.getLoadingDataByKey id=",id,",key=",key)
	end
end

function FuncLoading.getLoadingId(levelId,wave)
	local wave = wave or 1

	if levelData == nil then
		echoError ("levelData is nil")
	else
		local data = levelData[tostring(levelId)][tostring(wave)]
		if data == nil then
			echoError ("FuncLoading.getLoadingId levelId=",levelId)
		else
			if data.loadId == nil then
				echoError ("loadingData is ")
				dump(data)
			end

			return data.loadId
		end
	end
end

function FuncLoading.getResLoadingType(targetDay, hitSex)
	local sortByDay = function(a, b)
		return a.day < b.day
	end
	local ids = table.sortedKeys(config_dayRelation, sortByDay)
	local preDay = 0
	local targetConfig = nil
	for _, id in ipairs(ids) do
		local config = config_dayRelation[id]
		targetConfig = config
		if targetDay > preDay and targetDay <= config.day then
			break
		else
			preDay = config.day
		end
	end
	local weight = targetConfig.weight
	local index = FuncLoading.getProbKeyIndex(weight)
	local bgImage = targetConfig[hitSex][index]

	return bgImage
end

function FuncLoading.getKeyValueInfo(config, key, keyValue)
	keyValue = tonumber(keyValue)
	local sortByKey = function(a, b)
		return tonumber(a[key]) < tonumber(b[key])
	end
	local ids = table.sortedKeys(config, sortByKey)
	local last = -1
	local targetInfo = nil
	for _,id in ipairs(ids) do
		local info = config[id]
		targetInfo = info
		if keyValue > last and keyValue <= tonumber(info[key]) then
			break
		else
			last = tonumber(info[key])
		end
	end
	return targetInfo
end

function FuncLoading.getProbKeyIndex(probInfo)
	local total = 0
	for index, probValue in ipairs(probInfo) do
		total = total + probValue
	end
	local randomValue = FuncLoading.getRandomInt(0, total)
	local count = 0
	local targetIndex = 1
	for index, probValue in ipairs(probInfo) do
		if randomValue < count then
			break
		else
			count = count + probValue
		end
		targetIndex = index
	end
	return targetIndex
end

--range:[m,n]
function FuncLoading.getRandomInt(m, n)
	local t = {1,3,5,7,8}
	table.shuffle(t)
	local randomseed = tonumber(tostring(os.time()):reverse():sub(1,6) + table.concat(t))
	math.randomseed(randomseed)
	local randomValue = math.random(m, n)
	return randomValue
end

function FuncLoading.getRandomTips()
	local index = FuncLoading.getRandomInt(901, 1000)
	local tid = "#tid_loading_"..index
	return GameConfig.getLanguage(tid)
end
