--[[
	guan
	2017.3.22
	创造服务器假冒数据 资源和道具 
]]
FakeServerDataHelper = FakeServerDataHelper or {}

--[[
	cost: 配表里读出来的形态 {"7,100", "8,100",} or nil
	reward: 配表里的读出来的形态 {"1,5012,10", "4,10"}
	
	--内容是随便构造的
	return: 
	{
		["_id"] = "dev_129",
		["finance"] = {
			["coin"] = 12,
			["arenaCoin"] = 11,
		},

		giftGold = 321,
		giftGoldTotal = 11,
		exp = 99,

		items = {
			["10004"] = {num=103},
			["10005"] = {num=10},
		},

	}
	
	eg:搜索 PVPServer:requestRankExchange -> PVPModel:getFakeRankExchangeServerData
]]
function FakeServerDataHelper:createFakeData(rewards, costs)
	costs = costs or {};
	local fakeData = nil;

	local rewardFakeData = self:getChangeData(rewards);
	local costFakeData = self:getChangeData(costs);
	
	local resultData = self:fakeDataSub(rewardFakeData, costFakeData);

	fakeData = self:fakeData(resultData);

	return fakeData;
end

--[[
	一键领取之类的
	packReward = {
		{"7,100", "8,100",},
		{"7,100", "8,100",},
		{"7,100", "8,100",},
	},

	packCost = {
		{"1,5012,10", "4,10"},
		{"1,5012,10", "4,10"},
	}
	
	eg: PVPModel:getFakeScoreRewardServerData();
]]
function FakeServerDataHelper:packFakeData(packReward, packCost)
	packCost = packCost or {};

	local totalReward = {};
	for _, reward in pairs(packReward) do
		local rewardFakeData = self:getChangeData(reward);
		totalReward = self:fakeDataSum(totalReward, rewardFakeData);
	end

	local totalCost = {};
	for _, cost in pairs(packCost) do
		local costFakeData = self:getChangeData(cost);
		totalCost = self:fakeDataSum(totalCost, costFakeData);
	end

	local resultData = self:fakeDataSub(totalReward, totalCost);

	fakeData = self:fakeData(resultData);
	return fakeData;
end
-----------=====================private method============================--------------
function FakeServerDataHelper:fakeData(resultData)
	local fakeData = {
		_id = UserModel:_id(),
		-- _id = "dev_1002",
	};

	for k, v in pairs(resultData) do
		if k == "finance" then  
			fakeData["finance"] = {};
			for financeName, itemNum in pairs(v) do
				fakeData["finance"][financeName] = (UserModel:finance()[financeName] or 0) + itemNum;
			end
		elseif k == "items" then 
			fakeData["items"] = {};
			for itemId, itemNum in pairs(v) do
				fakeData["items"][tostring(itemId)] = {num = ItemsModel:getItemNumById(itemId) + itemNum};
			end 
		elseif k == "giftGold" then
			fakeData.giftGoldTotal = (UserModel:giftGoldTotal() or 0) + v;
		elseif k == "giftGoldTotal" then
			fakeData.giftGold = (UserModel:giftGold() or 0) + v;
		elseif k == "exp" then
			fakeData.exp = (UserModel:exp() or 0) + v;
		else 
			echo("---!warning: createFakeData what is that!! ", tostring(k));
		end 
	end	

	return fakeData;
end
--[[
	return: 
	{
		["finance"] = {
			["coin"] = 12,
			["arenaCoin"] = 11,
		},

		giftGold = 321,
		giftGoldTotal = 11,
		exp = 99,

		items = {
			["10004"] = 3,
			["10005"] = 10,
		},

	}
]]
function FakeServerDataHelper:fakeDataSum(p1, p2)
	local ret = table.deepCopy(p1);
	for k, v in pairs(p2) do
		if type(v) == "table" then  
			if ret[k] == nil then 
				ret[k] = {};
			end 

			for i, j in pairs(v) do
				ret[k][i] = (ret[k][i] or 0) + j;
			end

		else
			ret[k] = (ret[k] or 0)  + v;
		end 
	end	
	return ret;
end

function FakeServerDataHelper:fakeDataSub(f1, f2)
	local ret = table.deepCopy(f1);
	for k, v in pairs(f2) do
		if type(v) == "table" then  
			if ret[k] == nil then 
				ret[k] = {};
			end 

			for i, j in pairs(v) do
				ret[k][i] = (ret[k][i] or 0) - j;
			end

		else
			ret[k] = (ret[k] or 0) - v;
		end 
		
	end	
	return ret;
end

--[[
	return: 
	{
		["finance"] = {
			["coin"] = 12,
			["arenaCoin"] = 11,
		},

		giftGold = 321,
		giftGoldTotal = 11,
		exp = 99,

		items = {
			["10004"] = 3,
			["10005"] = 10,
		},

	}
]]
function FakeServerDataHelper:getChangeData(resArray)
	local fakeData = {};
	--货币
	local financeArray = {};
	--道具
	local itemArray = {};
	--这是仙玉
	local gold = 0;
	local exp = 0;

	for k, v in pairs(resArray) do
		local reward = string.split(v, ",");
	    local itemType = nil;
	    local itemId = nil;
	    local itemNum = nil;

	    local reward = string.split(v, ",")
	    --是货币
	    if table.length(reward) == 2 then 
	        itemType = reward[1];
	        itemId = reward[1];
	        itemNum = reward[2];
	    else 
	        itemType = reward[1];
	        itemId = reward[2];
	        itemNum = reward[3];
	    end 

	    --是道具
	    if FuncDataResource.RES_TYPE.ITEM == itemType then 
		    table.insert(itemArray, {itemId = itemId, itemNum = itemNum});
	    else 
	    	--单独处理的货币类型
	    	if itemType == FuncDataResource.RES_TYPE.EXP then 
	    		exp = itemNum;
	    	elseif itemType == FuncDataResource.RES_TYPE.DIAMOND then
	    		gold = itemNum;
	    	else 
		    	table.insert(financeArray, {itemId = itemId, itemNum = itemNum});
	    	end
	    end 

	end

	local fakeItems = {}
	for k, v in pairs(itemArray) do
		fakeItems[tostring(v.itemId)] = ItemsModel:getItemNumById(itemId) + v.itemNum;
	end

	local fakeFinance = {};
	for k, v in pairs(financeArray) do
		local financeName = FuncDataResource.getResNameInEnglish(v.itemId);
		fakeFinance[financeName] = v.itemNum;
	end

	if table.length(fakeFinance) ~= 0 then 
		fakeData.finance = fakeFinance;
	end 

	if table.length(fakeItems) ~= 0 then 
		fakeData.items = fakeItems;
	end 

	if exp ~= 0 then 
		fakeData.exp = UserModel:exp() + exp;
	end 

	if gold ~= 0 then 
		fakeData.giftGold = gold;
		fakeData.giftGoldTotal = gold;
	end 	

	return fakeData;
end









































