FuncLoadingNew = FuncLoadingNew or {}

FuncLoadingNew.LOADING_TYPE = {
	TYPE_1 = 1,
	TYPE_2 = 2,
	TYPE_3 = 3,
	TYPE_4 = 4,
	TYPE_2 = 5,
	TYPE_3 = 6,
	TYPE_4 = 7,

}

FuncLoadingNew.GAME_TYPE = {
	[1] = "pve",
	[101] = "pve",
	[102] = "pve",
	[2] = "pvp",
	[3] = "trial",
	[4] = "trial",
	[5] = "trial",
	[201] = "trial",
	[202] = "trial",
	[203] = "trial",
	[6] = "tower",
	[7] = "tower",
	[8] = "tower",
	[11] = "love",
	[12] = "shareboss",
	[13] = "missionMonkey",
	[14] = "missionBattle",
	[15] = "guildGve",
	[16] = "crossPeakPvp",
	[17] = "wonderLandPve",
	[21] = "guildBossPve",
	[25] = "guildBossGve",
	[999] = "miniBattle",
}


local loadingData = nil;
local levelData = nil;

function FuncLoadingNew.init()
	if not DEBUG_SERVICES then
		loadingData = Tool:configRequire("loading.Loading")
		levelData = Tool:configRequire("level.Level");
	else
		loadingData = {}
		levelData = {}
	end
	
	-- config_dayRelation = Tool:configRequire("loading.DayRelation")
end

function FuncLoadingNew.getAllLoadingDatas()
	return loadingData
end

function FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	local data = loadingData[tostring(_loadingNumber)]
	if data then
		return data
	else
		echo("\n\nFuncLoadingNew.getDataByLoadingNumber  not found  _loadingNumber=", _loadingNumber)
		return
	end
end

function FuncLoadingNew.getLoadTypeByLoadingNumber(_loadingNumber)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data.loadType then
		return data.loadType
	else
		echo("\n\nFuncLoadingNew.getBackgroundByLoadingNumber  not found loadType  _loadingNumber=", _loadingNumber)
		return
	end
end

function FuncLoadingNew.getDataByLoadingType(_loadType)
	local datas = {}
	if loadingData and table.length(loadingData) > 0 then
		for k,v in pairs(loadingData) do
			if v.loadType == tostring(_loadType) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getDataByOnlineDays(_onlineDays, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do
			if v.onlineDays then
				if FuncLoadingNew.checkIsIntervalNumber(v.onlineDays, _onlineDays) then
					table.insert(datas, v)
				end
			end			
		end
	end
	return datas
end

function FuncLoadingNew.getBackgroundByLoadingNumber(_loadingNumber)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data.background then
		return data.background
	else
		echo("\n\nFuncLoadingNew.getBackgroundByLoadingNumber  not found Background  _loadingNumber=", _loadingNumber)
		return
	end
end

-- 需要使用#tid_loading_去和random得到的值拼接    901
function FuncLoadingNew.getRandomTipsByLoadingNumber(_loadingNumber)
	local tipsInterval = FuncLoadingNew.getTipsIntervalByLoadingNumber(_loadingNumber)
	local randomValue = RandomControl.getOneRandomInt(tonumber(tipsInterval[2] + 1), tonumber(tipsInterval[1]))
	local randomTips = "#tid_loading_"..randomValue
	return randomTips
end

function FuncLoadingNew.getTipsIntervalByLoadingNumber(_loadingNumber)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data.tips then
		return data.tips
	else
		echo("\n\nFuncLoadingNew.getBackgroundByLoadingNumber  not found tips  _loadingNumber=", _loadingNumber)
		return
	end
end

function FuncLoadingNew.getIntervalByLoadingNumber(_loadingNumber)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data.interval then
		return data.interval
	else
		echo("\n\nFuncLoadingNew.getIntervalByLoadingNumber  not found interval  _loadingNumber=", _loadingNumber)
		return
	end
end

function FuncLoadingNew.getPropByLoadingNumberAndKey(_loadingNumber, _key)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data[tostring(_key)] then
		return data[tostring(_key)]
	else
		echo("\n\nFuncLoadingNew.getPropByLoadingNumberAndKey not found _loadingNumber=", _loadingNumber, "_key=", _key)
		return 
	end
end

function FuncLoadingNew.getCopyByLoadingNumber(_loadingNumber)
	local data = FuncLoadingNew.getDataByLoadingNumber(_loadingNumber)
	if data.copy then
		return data.copy
	else
		echo("\n\n该loading图不与关卡关联")
		return
	end
end

function FuncLoadingNew.getLoadingNumberByLevelId(_copy, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do
			if v.copy and v.copy == tostring(_copy) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getLoadingNumberByNextLevel(_level, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do
			if v.nextLevel and FuncLoadingNew.checkIsIntervalNumber(v.nextLevel, _level) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getLoadingNumberByLevel(_level, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do
			if v.level and FuncLoadingNew.checkIsIntervalNumber(v.level, _level) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getLoadingNumberByVips(_vipLevel, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do

			if v.vip and FuncLoadingNew.checkIsIntervalNumber(v.vip, _vipLevel) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.checkIsIntervalNumber(_vector, _number)
	if _vector and table.length(_vector) > 0 then
		if table.length(_vector) == 1 then
			return tonumber(_number) == tonumber(_vector[1])
		else
            local num1 = tonumber(_vector[1])
            local num2 = tonumber(_vector[2])
            if (tonumber(_number) >= tonumber(_vector[1]) and tonumber(_number) <= tonumber(_vector[2])) or 
             (tonumber(_number) <= tonumber(_vector[1]) and tonumber(_number) >= tonumber(_vector[2])) then
            	return true
            end
		end
	end
	return false
end

function FuncLoadingNew.getLoadingNumberByKeyAndValue(_key, _value)
	local datas = {}
	if loadingData and table.length(loadingData) > 0 then
		for k,v in pairs(loadingData) do
			if v[tostring(_key)] and tostring(v[tostring(_key)]) == tostring(_value) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getLoadingNumberByGameType(_gameType, _loadingData)
	local datas = {}
	if _loadingData and table.length(_loadingData) > 0 then
		for k,v in pairs(_loadingData) do
			if v.game and tostring(v.game) == tostring(_gameType) then
				table.insert(datas, v)
			end
		end
	end
	return datas
end

function FuncLoadingNew.getGameTypeByBattleLabel(_battleLabel, _levelId)
	if not LoginControler:isLogin() then
		return "pve"
	end
	local _gameType
	echo("\n\nObjectLevel:getGameTypeByBattleLabel(tostring(_battleLabel))===", ObjectLevel:getGameTypeByBattleLabel(tonumber(_battleLabel)), "_battleLabel", _battleLabel)
	if _levelId and tonumber(_levelId) and tonumber(_levelId) > 20100 and tonumber(_levelId) < 29999 then
        _gameType = "elite"
    else
    	_gameType = ObjectLevel:getGameTypeByBattleLabel(tonumber(_battleLabel))
    end
    return _gameType
end

function FuncLoadingNew.getDefaultLoadingNumber(_allMemoryData)
	local defaultDatas = {}
	for k,v in ipairs(_allMemoryData) do
		if v.level == nil and v.copy == nil and v.vip == nil and v.nextLevel == nil then
			table.insert(defaultDatas, v)
		end
	end

	return defaultDatas
end


