--guan
--2016.03.26
--2017.04.10 加入升级和目标

FuncQuest = FuncQuest or {}

local dailyQuest = nil;
local mainQuest = nil;
local Upgrade = nil;
local Achievement = nil;
FuncQuest.systemName = {
	[1] = "mainlineQuest",
	[2] = "everydayQuest",
}

FuncQuest.EverydayQuestType = {1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24}

FuncQuest.QUEST_TYPE = {
	ACHIEVEMENT = 3, --以前是成就，现在是传记
	TARGET = 1,  --目标
	EVERYDAY = 2, --每日
	UPGRAGE = 4, --升级
}

--初始化
function FuncQuest.init(  )
	if DEBUG_SERVICES then
		dailyQuest = {}
		mainQuest = {}

		Achievement = {}
		Upgrade = {}
	else
		dailyQuest = Tool:configRequire("quest.EverydayQuest")
		mainQuest = Tool:configRequire("quest.MainlineQuest")

		Achievement = Tool:configRequire("quest.Achievement")
		Upgrade = Tool:configRequire("quest.Upgrade")

	end
	
	-- Title = Tool:configRequire("quest.Title")

end

function FuncQuest:getUpgradeConfig()
	return Upgrade;
end

function FuncQuest:getUpgradeArray()
	local array = {};

	for k, v in pairs(Upgrade) do
		v.id = tonumber(k);
		table.insert(array, v);
	end

	--排序	
	local sortFunc = function (a, b)
		if a.condition < b.condition then 
			return true;
		else 
			return false;
		end 
	end

	table.sort(array, sortFunc);

	return array;
end

function FuncQuest:getUpdateArrayLen()
	return table.length( self:getUpgradeArray() );
end

function FuncQuest:getAchievementLen()
	return table.length(Achievement);
end

function FuncQuest:readAchiment(id, key)
	local data = Achievement[tostring(id)];
	if data == nil then 
		if isShowWarning ~= false then 
			echo("FuncQuest.readAchiment id " .. tostring(id) .. " is nil.");
		end 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			if isShowWarning ~= false then 
				echo("FuncQuest.readAchiment id " 
					.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
			end 
			return nil;
		else 
			return ret;
		end 
	end 
end

-- function FuncQuest:readTitleQuest(id, key)
-- 	local data = Title[tostring(id)];
-- 	if data == nil then 
-- 		if isShowWarning ~= false then 
-- 			echo("FuncQuest.readTitleQuest id " .. tostring(id) .. " is nil.");
-- 		end 
-- 		return nil;
-- 	else 	
-- 		local ret = data[key];
-- 		if ret == nil then 
-- 			if isShowWarning ~= false then 
-- 				echo("FuncQuest.readTitleQuest id " 
-- 					.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
-- 			end 
-- 			return nil;
-- 		else 
-- 			return ret;
-- 		end 
-- 	end 
-- end

function FuncQuest:readUpgradeQuest(id, key)
	local data = Upgrade[tostring(id)];
	if data == nil then 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			return nil;
		else 
			return ret;
		end 
	end 
end

--读表
function FuncQuest.readEverydayQuest(id, key, isShowWarning)
	local data = dailyQuest[tostring(id)];
	if data == nil then 
		-- if isShowWarning ~= false then 
		-- 	echo("FuncQuest.readEverydayQuest id " .. tostring(id) .. " is nil.");
		-- end 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			-- if isShowWarning ~= false then 
			-- 	echo("FuncQuest.readEverydayQuest id " 
			-- 		.. tostring(id) .. " key " .. tostring(key) .. " is nil.");
			-- end 
			return nil;
		else 
			return ret;
		end 
	end 
end
local cacheErrorTable = {} --缓存错误信息
function FuncQuest.readMainlineQuest(id, key, isShowWarning)
	-- echo("==============21111111============",id)
	local data = mainQuest[tostring(id)];
	if data == nil then 
		if cacheErrorTable[id] then
			return 
		end
		if isShowWarning ~= false then 
			if id ~= nil then
				cacheErrorTable[id] = true
				echo("FuncQuest.readMainlineQuest id ",tostring(id), " is nil.");
			end
		end 
		return nil;
	else 	
		local ret = data[key];
		if ret == nil then 
			if isShowWarning ~= false then 
				echo("FuncQuest.readMainlineQuest id ==",tostring(id)," key  == ",tostring(key)," is nil.");
			end 
			return nil;
		else 
			return ret;
		end 
	end
end

--[[
	所有每日任务id获得
]]
function FuncQuest.getAllDailyQuestIds()
	local ids = {};
	for k, v in pairs(dailyQuest) do
		ids[k] = k;
	end
	return ids;
end

--[[
	得到某类型的所有任务
]]
function FuncQuest.getAllDailyByType(questType)
	local allDailyQuestIds = FuncQuest.getAllDailyQuestIds();
	local ids = {};

	for k, v in pairs(allDailyQuestIds) do
		if FuncQuest.readEverydayQuest(k, "conditionType") == questType then 
			ids[k] = k;
		end 
	end

	return ids;
end

--任务名字
function FuncQuest.getQuestName(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "name");
	else 
		return FuncQuest.readEverydayQuest(questId, "name");
	end 
end

--任务描述
function FuncQuest.getQuestDes(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "taskDescription");
	else 
		return FuncQuest.readEverydayQuest(questId, "taskDescription");
	end 
end

--任务奖励
function FuncQuest.getQuestReward(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "taskReward");
	else 
		return FuncQuest.readEverydayQuest(questId, "taskReward");
	end 
end

--任务icon
function FuncQuest.getQuestIcon(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "icon");
	else 
		return FuncQuest.readEverydayQuest(questId, "icon");
	end 
end

--任务icon边框
function FuncQuest.getQuestColor(questType, questId)
	if questType == 1 then 
		return FuncQuest.readMainlineQuest(questId, "color");
	else 
		return FuncQuest.readEverydayQuest(questId, "color");
	end 
end

function FuncQuest.getPostTask(questId)
	return FuncQuest.readMainlineQuest(questId, "postTask") or {};
end

function FuncQuest.isLastTast(questId)
	local ret = FuncQuest.readMainlineQuest(questId, "postTask", false);
	if ret == nil then 
		return true;
	else 
		return false;
	end 
end


function FuncQuest:getAllmainQuest()
	return mainQuest
end













