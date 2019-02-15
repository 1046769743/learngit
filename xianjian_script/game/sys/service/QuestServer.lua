--
-- Author: ZhangYanguang
-- Date: 2015-11-28
--
--主角模块，网络服务类
local QuestServer = class("QuestServer")

--完成每日任务
function QuestServer:getEveryQuestReward(everydayQuestId, callBack)
	echo("getEveryQuestReward " .. tostring(everydayQuestId));
	UserModel:cacheUserData();

	local params = {
		everydayQuestId = everydayQuestId
	}
	Server:sendRequest(params, 
		MethodCode.quest_getDailyQuest_reward_2503, callBack)

	-- local fakeData = DailyQuestModel:getFakeServerData(everydayQuestId);
	-- -- dump(fakeData, "----fakeData----");
	-- Server:updateBaseData(fakeData);
	-- callBack();

end


--完成主线任务
function QuestServer:getMainQuestReward(mainQuestId, callBack)
	echo("getMainQuestReward " .. tostring(mainQuestId));
	UserModel:cacheUserData();
	
	local params = {
		mainlineQuestId = mainQuestId
	}

	Server:sendRequest(params, 
		MethodCode.quest_getMainLineQuest_reward_2501, callBack);
	-- Server:sendRequest(params, 
	-- 	MethodCode.quest_getMainLineQuest_reward_2501, 
	-- 		nil, true, true, true);

	-- -- --打印出伪造数据看看
	-- local fakeData = TargetQuestModel:getFakeServerData(mainQuestId);
	-- -- dump(fakeData, "----fakeData---");
 --    Server:updateBaseData(fakeData);

	-- callBack();

	TargetQuestModel:addNewAchievementQuestId(mainQuestId);
end

function QuestServer:getLvlQuestReward(lvlIndex, callBack)
	echo("getLvlQuestReward " .. tostring(lvlIndex));
	
	local params = {
		levelRewardId = lvlIndex
	};

	Server:sendRequest(params, 
		MethodCode.quest_lvl_reward_2505, callBack);
end


function QuestServer:getAchievementReward(rewardIndex, callBack)
	echo("getAchievementReward " .. tostring(rewardIndex));
	
	local params = {
		achievementRewardId = rewardIndex,
	};

	Server:sendRequest(params, 
		MethodCode.quest_achievement_reward_2507, callBack);
end

return QuestServer




























