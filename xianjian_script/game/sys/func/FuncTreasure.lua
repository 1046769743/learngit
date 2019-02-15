
FuncTreasure = FuncTreasure or {}

local treasureData = nil

local FeatureBuffData = nil
local sourceData = nil

local TREASURE_QUALITY_NAMES = {
	[1] = "人品",
	[2] = "地品",
	[3] = "天品",
	[4] = "通天品",
	[5] = "玄天品"
}

function FuncTreasure.getName(id)
	local tid = FuncTreasure.getValueByKeyTD(id, "name");
	return GameConfig.getLanguage(tid);
end

function FuncTreasure.init(  )
	treasureData = Tool:configRequire("treasure.TreasureNew");
	sourceData = Tool:configRequire("level.Source");
 	FeatureBuffData = Tool:configRequire("battle.Buff");
end

-- function FuncTreasure.getSourceDataById(id)
-- 	local t = sourceData[tostring(id)];
-- 	if id == nil or t == nil then
-- 		echoError("FuncTreasure.getSourceDataByKeyTD id not found " .. id)
-- 		return nil
-- 	end

-- 	return t;
-- end


function FuncTreasure.getSourceDataById(id)
	local data = sourceData[tostring(id)]
	if data ~= nil then
		return data
	else
		echoError("FuncTreasure.getSourceDataById id not dound:  ", id, "  _insteadof char 1")
		return  sourceData[tostring("1")]
	end
end

-- 获取法宝对应战斗内要显示的气泡
function FuncTreasure.getSourceTalkById( id )
	local data = sourceData[tostring(id)]
	if data and data.talk then
		return data.talk
	end
	return nil
end

--获取source 对应的spine文件
-- sex  "a" 或者1 或者空  是男 ,其他是女
function FuncTreasure.getSourceSpine( id,sex )
	local sourceData = FuncTreasure.getSourceDataById(id)
	if sex == "a" or  sex == 1 or not sex then
		return sourceData.spine
	end
	return sourceData.spineFormale
end


function FuncTreasure.getSourceDataByKeyTD(id, key)
	local t = sourceData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasure.getSourceDataByKeyTD id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasure.getSourceDataByKeyTD key not found " .. key)
		return nil
	end 

	return ret;
end


function FuncTreasure.getQualityName(quality)
	quality = tonumber(quality)
	name = TREASURE_QUALITY_NAMES[quality] or ""
	return name
end

function FuncTreasure.getValueByKeyTD(id, key)
	local t = treasureData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasure.getValueByKeyTD id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasure.getValueByKeyTD key not found " .. key)
		return nil
	end 

	return ret;
end

function FuncTreasure.getTreasureAllConfig()
	return treasureData;
end

function FuncTreasure.getTreasureById(_id)
    local _treasure = treasureData[tostring(_id)]
    if not _treasure then
        echo("Warning!!! jianjianjian,error,",_id)
    end
    return _treasure
end

function FuncTreasure.getValueByKeyBD(id, key)

	local t = FeatureBuffData[tostring(id)];

	if t == nil then 
		echo("FuncTreasure.getValueByKeyBD id not found " .. id);
		return nil
	end 

	local value = t[tostring(key)]

	if value == nil then 
		echo("FuncTreasure.getValueByKeyBD key not found " .. key);
		return nil
	end 

	return value;
end

function FuncTreasure.getIconPathById(id)
	return FuncTreasure.getValueByKeyTD(id, "icon")
end

function FuncTreasure.isCanCombine( id )
   local _state =  treasureData[tostring(id)]["combine"] or 0  
  return  _yuan3(_state == 1,true,false)
end 

function FuncTreasure.getTreasureDes(id)
    local translateId = FuncTreasure.getValueByKeyTD(
        id, "treasureDes");
    local str = GameConfig.getLanguage(translateId)
    return str;
end

--得到label转换后的字符串
function FuncTreasure.getLabel3(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "label3");
	local str = GameConfig.getLanguage(translateId);
	return str;
end

function FuncTreasure.getUseDes(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "uesDes");
	local str = GameConfig.getLanguage(translateId);
	return str;
end

function FuncTreasure.getLabel4(id)
	local translateId = FuncTreasure.getValueByKeyTD(
        id, "label4");
	local str = GameConfig.getLanguage(translateId);
	return str;
end












