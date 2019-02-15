--guan
--2016.3.26
--2017.1.19

local DailyQuestModel = class("DailyQuestModel", BaseModel)

DailyQuestModel.Type = {
	Vigour = "1", --领体力
	NewDay = "2", --新的一天
	ELiteExchange = "3",  --奇缘npc兑换
	Lottery = "4", --赤铜抽
	PartnerLvlUp = "5", --伙伴升级
	PartnerSKillUp = "6", --伙伴技能升级
	PartnerUniqueSkillUp = "7", --伙伴绝技升级
	PartnerQualityUp = "8",   --伙伴升品
	Trial = "9",   --试炼
	Tower = "10",   --爬塔
	Arena = "11",   --竞技场
	BuyVigour = "12", --买体力
	BuyCoin = "13", --买铜钱

	CostGold = "14", --花钻石
	MonthCard = "15", --领月卡

	ShopBuy = "16",	-- 商店购买商品
	Mission = "17",   --六界轶事
	Entrust = "18",	--仙灵委托
	GuildDonation = "19",	--仙盟中捐献
	OldMemories = "20",   --旧的回忆
	Artifact = "21",		-- 神器抽卡
	WonderLand = "22",		--须臾仙境
	Smackdown = "23",    ---巅峰对决
	SendFriendSp = "24",    ---赠送好友体力
};

DailyQuestModel.JUMP_VIEW = {
	[DailyQuestModel.Type.Vigour] = {jumpFunc = function ()
		WindowControler:showTips(GameConfig.getLanguage("#tid_quest_001"));
	end},

	[DailyQuestModel.Type.Tower] =  {jumpFunc = function ()
		TowerControler:enterTowerMainView()
	end},

	[DailyQuestModel.Type.Trial] = {viewName = "TrialNewEntranceView"},
	[DailyQuestModel.Type.Arena] = {viewName = "ArenaMainView"},

	[DailyQuestModel.Type.BuyCoin] = {viewName = "CompBuyCoinMainView"},
	[DailyQuestModel.Type.Lottery] = {viewName = "GatherSoulMainView"},

	--精英
	[DailyQuestModel.Type.ELiteExchange] = {jumpFunc = function ()
			FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_ELITE) 
	end},


	[DailyQuestModel.Type.PartnerLvlUp]=  {jumpFunc = function ()
		local stageType = FuncPartner.PartnerIndex.PARTNER_QUALILITY
		FuncCommUI:showPartnerView(stageType)
	end},

	[DailyQuestModel.Type.PartnerSKillUp] =  {jumpFunc = function ()
        local  stageType = FuncPartner.PartnerIndex.PARTNER_SKILL
		local panerID =  PartnerModel:getFirstPartner( )
		-- local isopen = PartnerModel:isOpenByType(stageType,panerID)
		-- if isopen then
				WindowControler:showWindow("PartnerView",stageType,tostring(panerID.id))
		-- else
		-- 	WindowControler:showTips("功能暂未开启")
		-- end
	end},

	[DailyQuestModel.Type.PartnerUniqueSkillUp]=  {jumpFunc = function ()
		local  stageType = FuncPartner.PartnerIndex.PARTNER_JUEJI
		FuncCommUI:showPartnerView(stageType)
	end},

	[DailyQuestModel.Type.PartnerQualityUp] =  {jumpFunc = function ()
		local  stageType = FuncPartner.PartnerIndex.PARTNER_QUALILITY
		FuncCommUI:showPartnerView(stageType)
	end},

	[DailyQuestModel.Type.BuyVigour] = {viewName = "CompBuySpMainView"},
	[DailyQuestModel.Type.CostGold] = {jumpFunc = function ()
		-- WindowControler:showTips("消费不达标");
		-- WindowControler:showWindow("CompBuySpMainiew");
		WindowControler:showWindow("MallMainView",FuncShop.SHOP_TYPES.MALL_XINANDANG)
	end},

	[DailyQuestModel.Type.ShopBuy] = {jumpFunc = function ()
		 FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.SHOP_1)
	end},
	[DailyQuestModel.Type.Mission] = {jumpFunc = function ()
		local sysName = FuncCommon.SYSTEM_NAME.MISSION
		local isopen = FuncCommon.isSystemOpen(sysName)
		if isopen then
			WindowControler:showWindow("MissionMainView")
		else
			WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_007"))
		end
	end},
	[DailyQuestModel.Type.Entrust] = {jumpFunc = function ()
		-- WindowControler:showTips("等待康宁加");
		-- if AnimDialogControl:getIsInWorldMap() then
		-- 	AnimDialogControl:destoryDialog() 
		-- end
		-- WorldControler:openDelegateView()
		WindowControler:showWindow("DelegateMainView")
		
	end},
	[DailyQuestModel.Type.GuildDonation] = {jumpFunc = function ()
		GuildControler:getMemberList(3)
		local isaddGuild = GuildModel:isInGuild()
		if not isaddGuild then
			-- WindowControler:showTips("暂未加入仙盟");
			WindowControler:showWindow("GuildCreateAndAddView");
		end
	end},

	[DailyQuestModel.Type.OldMemories] = {jumpFunc = function ()
		WorldControler:showPVEListView()
	end},
	[DailyQuestModel.Type.Artifact] = {jumpFunc = function ()
		WindowControler:showWindow("ArtifactDrawCardView");
	end},


	[DailyQuestModel.Type.WonderLand] = {jumpFunc = function ()
		WindowControler:showWindow("WonderlandMainView");
	end},
	[DailyQuestModel.Type.Smackdown] = {jumpFunc = function ()
		-- WindowControler:showWindow("CrosspeakMainView")
		CrossPeakModel:openCrossPeakUI()
	end},

	[DailyQuestModel.Type.SendFriendSp] = {jumpFunc = function ()
		FriendViewControler:showView()
	end},



};

function DailyQuestModel:init(data)

	self.modelName = "DailyQuestModel"
    DailyQuestModel.super.init(self, data)
    self.questIds = nil
    self._datakeys = {
    	--过期时间
   		expireTime = 0,
   		--[[
			3 = 441,
			4 = 1,
   		]]
   		todayEverydayQuestCounts = {},
   		--[[
			1005 = 1005,
			1006 = 1006,
   		]]
   		receiveStatus = {},
	};

	self:createKeyFunc()
    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, 
    	self.onFuncInit, self)  

    --仙玉发生变化
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, 
    	self.sendMainLineChangeEvent, self);
    --主角升级
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
    	self.sendMainLineChangeEvent, self);   

    self:updateData(data); 
end

function DailyQuestModel:sendMainLineChangeEvent()
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});
end

function DailyQuestModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname

	if funcname ~= "FuncQuest" then
		return
	end

	self:updateData(self._data);

	self:initSpQuestCheck();

	--接受cd到了的事件
    EventControler:addEventListener(QuestEvent.QUEST_CHECK_SP_EVENT,
        self.spCheckCallBack, self, 2);

	-- if self:isHaveFinishQuest() == true then 
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = self:isHaveFinishQuest() or false});
	-- end 

end


function DailyQuestModel:setInitData(data)
	if data.todayEverydayQuestCounts ~= nil then 
		for k, v in pairs(data.todayEverydayQuestCounts) do
			self._datakeys.todayEverydayQuestCounts[k] = v;
		end
	end
	if data.receiveStatus ~= nil then 
		for k, v in pairs(data.receiveStatus) do
			self._datakeys.receiveStatus[k] = v;
		end
	end 
end





--更新数据
function DailyQuestModel:updateData(data)
	DailyQuestModel.super.updateData(self,data);
	-- dump(self._datakeys,"日常数据变化==1111=====")
	-- dump(data,"日常数据变化===2222====")
	local serverTime = TimeControler:getServerTime()
	if self._datakeys.expireTime == 0 then
		self:setInitData(data)
	else
		local expireTime = self._datakeys.expireTime 
		if serverTime >= expireTime then
			local todayEverydayQuestCounts = self._datakeys.todayEverydayQuestCounts
			local newdata = data.todayEverydayQuestCounts
			if  todayEverydayQuestCounts ~= nil then
				for k,v in pairs(todayEverydayQuestCounts) do
					local valuer = nil
					if newdata ~= nil then
					 	valuer = newdata[k]
					end
					if k == DailyQuestModel.Type.NewDay then
						self._datakeys.todayEverydayQuestCounts[k] = valuer or 1;
					elseif k == DailyQuestModel.Type.CostGold then
						self._datakeys.todayEverydayQuestCounts[k] = valuer or todayEverydayQuestCounts[k] or 0;
					else
						self._datakeys.todayEverydayQuestCounts[k] = nil
					end
				end
			end
			self._datakeys.receiveStatus = {};
		else
			self:setInitData(data)
		end
	end

	if data.expireTime ~= nil then 
		self._datakeys.expireTime = data.expireTime;
	end 

	--有变化就发个事件
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});

	-- if self:isHaveFinishQuest() == true then 
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = self:isHaveFinishQuest() or false});		
	-- end 
end

--获取每日任务的数量
function DailyQuestModel:getDailyQuestCount()
	
	return table.length(self._datakeys.receiveStatus)
end

--是否过期了 , 返回true就是过期了
function DailyQuestModel:isExpireTime()
	-- body
	local serverTime = TimeControler:getServerTime();
	if self._datakeys.expireTime < serverTime then 
		return true
	else 
		return false;
	end 
end

--删除数据
function DailyQuestModel:deleteData( keyData ) 
	DailyQuestModel.super.deleteData(self, keydata)

	if keyData.todayEverydayQuestCounts ~= nil then 
		for k, v in pairs(keyData.todayEverydayQuestCounts) do
			self._datakeys.todayEverydayQuestCounts[k] = nil;
		end
	end 


	if keyData.receiveStatus ~= nil then 
		if keyData.receiveStatus == 1 then 
			keyData.receiveStatus = {};
		else
			for k, v in pairs(keyData.receiveStatus) do
				self._datakeys.receiveStatus[k] = nil;
			end
		end 
	end 


	--有变化就发个事件
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, 
        {});
end

--[[
	吃鸡任务是否满足时间开启
]]
function DailyQuestModel:isSpQuestIdTimeInOpenRange(id)
    local serverTime = TimeControler:getServerTime();

    local dates = os.date("*t", serverTime);   
    local curHour = dates.hour;

    function isCurHourInRegion(from, to)
    	if curHour >= from and curHour < to then 
    		return true;
    	else 
    		return false;
    	end 
    end

	local spCondition = FuncQuest.readEverydayQuest(id, "spCondition");

	if isCurHourInRegion(spCondition[1], spCondition[2]) == true then 
		return true;
	else 
		return false;
	end 
end

--[[
	当前要显示的吃鸡任务
]]
function DailyQuestModel:getCurShowSpQuest()
    return nil;
end

function DailyQuestModel:isHideQuest(id)
	local isHide = FuncQuest.readEverydayQuest(id, "Hide", false);
	return isHide == 1 and true or false;
end

function DailyQuestModel:isNeedShow(id)
	local isHide = self:isHideQuest(id);
	local isFinish = self:isDailyQuestFinish(id);

	if isHide == false then 
		return true;
	else
		if isFinish == true and isHide == false then 
			return true;
		else
			return false;
		end 
	end 
end


function DailyQuestModel:isHaveReceiveReward(id)
	local isExpireTime = self:isExpireTime();

	if isExpireTime == true or self._datakeys.receiveStatus[tostring(id)] == nil then 
		return false;
	else 
		return true;
	end 
end

--得到所有 每日任务
function DailyQuestModel:getAllShowDailyQuestId()
	local showIds = {};

	--没开启每日任务，返回空
	if DailyQuestModel:isOpen() == false then 
		return showIds;
	end 

	if self:getCurShowSpQuest() ~= nil then
		table.insert(showIds, self:getCurShowSpQuest());
	end 

	local isExpireTime = self:isExpireTime();
	local num = table.length(FuncQuest.EverydayQuestType)

	local idFinishMap = {

	}

	for i = 2, num do
		local ids = FuncQuest.getAllDailyByType(i);

		for k, v in pairs(ids) do
			if self:dailyQuestOpenCheck(k) == true and self:isNeedShow(k) == true then 
				if isExpireTime == true or self._datakeys.receiveStatus[tostring(k)] == nil then 
					table.insert(showIds, k);
				end 
			end 
		end

	end

	for i,v in ipairs(showIds) do
		idFinishMap[v] = self:isDailyQuestFinish(v);
	end

	local function sortFunc(id1, id2)
		local id1IsFinish = idFinishMap[id1];
		local id2IsFinish = idFinishMap[id2];
		local DisplayOrder1 = FuncQuest.readEverydayQuest(id1, "DisplayOrder") or 999
		local DisplayOrder2 = FuncQuest.readEverydayQuest(id2, "DisplayOrder") or 999

		id1IsFinish = id1IsFinish == true and 1 or 0;
		id2IsFinish = id2IsFinish == true and 1 or 0;

		if id1IsFinish > id2IsFinish then 
			return true
		elseif id1IsFinish == id2IsFinish then 
			if DisplayOrder1 < DisplayOrder2 then 
				return true  
			elseif DisplayOrder1 == DisplayOrder2 then
				if id1 < id2 then
					return true
				else
					return false;
				end
			else
				return false
			end 
		else
			return false;
		end 
	end
	table.sort(showIds, sortFunc);
	return showIds;
end

--追踪目标获取数据	
function DailyQuestModel:getTrackData()
	local data = self:getAllShowDailyQuestId()
	local newtable = {}
	for i=1,#data do
		local displayOrder1 = FuncQuest.readEverydayQuest(data[i], "DisplayOrder")
		if displayOrder1 ~= nil then
			table.insert(newtable,data[i])
		end
	end
	return newtable
end

--[[
	每日任务是否开启了
]]
function DailyQuestModel:dailyQuestOpenCheck(id)
	local openCondition = FuncQuest.readEverydayQuest(id, "openCondition");
	local isReachCondition = UserModel:checkCondition( openCondition )
	return isReachCondition == nil and true or false;
end

--[[今日花费的钻石数]]
function DailyQuestModel:todayCostGold()
	-- local totalCostGoldBeforeToday = self:finishCount(id);
	local totalCostGoldBeforeToday = self._datakeys.todayEverydayQuestCounts[DailyQuestModel.Type.CostGold] or 0;

	local totalCostGold = UserModel:totalCostGold();

	return totalCostGold - totalCostGoldBeforeToday;
end 

--[[
	花费钻石任务是否完成了
]]
function DailyQuestModel:isCostGoldQuestFinish(id)
	local todayCostGold = self:todayCostGold();
	local needCost = FuncQuest.readEverydayQuest(id, "completeCondition");
	return todayCostGold >= needCost and true or false;
end

--[[
	每日任务是否完成了
]]
function DailyQuestModel:isDailyQuestFinish(id)
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");
	local ret = nil;
	if questType == 1 then --吃鸡
		ret = self:isSpQuestIdTimeInOpenRange(id);
	elseif questType == 14 then
		ret = self:isCostGoldQuestFinish(id);
	else 
		local needCount = FuncQuest.readEverydayQuest(id, "completeCondition");
		local finishCount = self:finishCount(id);

		-- echo("needCount " .. tostring(needCount));
		-- echo("finishCount " .. tostring(finishCount));
		-- echo("id " .. tostring(id));

		if finishCount >= needCount then 
			ret = true;
		else 
			ret = false;
		end 
	end 

	return ret;
end

--[[
	需要完成几次
]]
function DailyQuestModel:needCount( id )
	local needCount = FuncQuest.readEverydayQuest(id, "completeCondition");
	return needCount;
end

--[[
	已经完成了几次
]]
function DailyQuestModel:finishCount( id )
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");

	if questType == tonumber(DailyQuestModel.Type.CostGold) then 
		return self:todayCostGold();
	else 

		if self:isExpireTime() == true then 
			return 0;
		end 

		local finishCount = self._datakeys.todayEverydayQuestCounts[tostring(questType)] or 0;	
		return finishCount;

	end 
end

--[[
	是否是买体力任务
]]
function DailyQuestModel:isSpQuest(id)
	local questType = FuncQuest.readEverydayQuest(id, "conditionType");
	return questType == 1 and true or false;
end

--[[
	是否有完成的任务
]]
function DailyQuestModel:isHaveFinishQuest()
	if self:isOpen() == false then 
		return false;
	end 

	local allShowQuests = self:getAllShowDailyQuestId();
	for k, v in pairs(allShowQuests) do
		if self:isDailyQuestFinish(v) == true then 
			return true;
		end 
	end
	return false;
end

function DailyQuestModel:isHaveMainFinishQuest()
	if self:isOpen() == false then 
		return false;
	end 

	local allShowQuests = self:getAllShowDailyQuestId();
	for k, v in pairs(allShowQuests) do
		local DisplayOrder2 = FuncQuest.readEverydayQuest(v, "DisplayOrder")
		if DisplayOrder2 ~= nil then
			if self:isDailyQuestFinish(v) == true then 
				return true;
			end 
		end
	end
	return false;
end




--[[
	是否开启了
]]
function DailyQuestModel:isOpen()
    local isOpen, needLvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST);
	return isOpen, needLvl;
end

--[[
	sp任务的事件
]]
function DailyQuestModel:initSpQuestCheck()

	function getLeftTime(date, targetHour)
		local curHour = date.hour;
		local curMin = date.min;
		local curSec = date.sec;
		--+10是为了预留10s
		return targetHour * 60 * 60 - (curHour * 60 * 60 + curMin * 60 + curSec) + 10;
		-- return 20;
	end

	local curSpQuest = self:getCurShowSpQuest();
	-- echo("curSpQuest " .. tostring(curSpQuest));
	if curSpQuest ~= nil then 

		local spCondition = FuncQuest.readEverydayQuest(curSpQuest, "spCondition");
		local leftTime = 0;
		local curTime = TimeControler:getServerTime();
		local dates = os.date("*t", curTime);
		-- dump(dates, "--dates");
		if self:isDailyQuestFinish(curSpQuest) == true then 
			--结束时刷新
			leftTime = getLeftTime(dates, spCondition[2]);
		else 
			--开始时刷新
			leftTime = getLeftTime(dates, spCondition[1]);
		end 

		TimeControler:startOneCd(QuestEvent.QUEST_CHECK_SP_EVENT, leftTime);
	end 	
end

function DailyQuestModel:getDailyRecommandId()
	local allQuest = self:getAllShowDailyQuestId();

	local sortFunc = function (id1, id2)
		local order1 = FuncQuest.readEverydayQuest(id1, "DisplayOrder", false) or 999;
		local order2 = FuncQuest.readEverydayQuest(id2, "DisplayOrder", false) or 999;

		if order1 < order2 then 
			return true;
		else 
			return false;
		end 
	end

	table.sort(allQuest, sortFunc);

	local recommandId = allQuest[1];

	if FuncQuest.readEverydayQuest(recommandId, "DisplayOrder", false) == nil then 
		return nil;
	else 
		return recommandId;
	end 
end

function DailyQuestModel:spCheckCallBack()
	-- echo("---spCheckCallBack-----");

	self:initSpQuestCheck();
	local isShow = false;

	TargetQuestModel:mainQuestChangeCallBack()

	-- if self:isHaveFinishQuest() == true then 
	-- 	isShow = true 
	-- else
	-- 	if TargetQuestModel == nil or TargetQuestModel:isHaveFinishQuest() == false then 
	-- 		isShow = false;
	--     else 
	--     	if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST) == true then 
	--     		isShow = true;
	--     	end 
	--     end 		
	-- end 

	-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
 --        {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = isShow});
end

--[[
	假冒的fakedata
]]
function DailyQuestModel:getFakeServerData(questId)
	local rewards = FuncQuest.getQuestReward(2, questId);
	--货币
	local financeArray = {};
	--道具
	local itemArray = {};
	local exp = 0;
	local gold = 0;
	local sp = 0;

	for k, v in pairs(rewards) do
		local reward = string.split(v, ",");
	    local itemType = nil;
	    local itemId = nil;
	    local itemNum = nil;

	    local reward = string.split(v, ",")

	    local isCurrency = false;
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

	    if FuncDataResource.RES_TYPE.ITEM ~= itemType then 
	        isCurrency = true;
	    else 
	        isCurrency = false;
	    end 

	    --经验单独处理
	    if isCurrency == true and itemId == FuncDataResource.RES_TYPE.EXP then 
	    	exp = itemNum;
	    elseif isCurrency == true and itemId == FuncDataResource.RES_TYPE.DIAMOND then
	    	gold = itemNum;
	    elseif isCurrency == true and itemId == FuncDataResource.RES_TYPE.SP then
	    	sp = itemNum;
	    else
		    if isCurrency == true then 
		    	table.insert(financeArray, {itemId = itemId, itemNum = itemNum});
		    else 
		    	table.insert(itemArray, {itemId = itemId, itemNum = itemNum});
		    end
		end 
	end

	-- dump(itemArray, "----itemArray---");

	local fakeItems = {}
	for k, v in pairs(itemArray) do
		fakeItems[tostring(v.itemId)] = {num = ItemsModel:getItemNumById(itemId) + v.itemNum};
	end


	-- dump(financeArray, "----financeArray---");

	local fakeFinance = {};
	for k, v in pairs(financeArray) do
		local financeName = FuncDataResource.getResNameInEnglish(v.itemId);
		fakeFinance[financeName] = UserModel:finance()[financeName] + v.itemNum;
	end

	local fakeData = {
		u = {
			_id = UserModel:_id(),
		}
	};

	if table.length(fakeFinance) ~= 0 then 
		fakeData.u.finance = fakeFinance;
	end 

	if table.length(fakeItems) ~= 0 then 
		fakeData.u.items = fakeItems;
	end 

	if exp ~= 0 then 
		fakeData.u.exp = UserModel:exp() + exp;
	end 

	if sp ~= 0 then 
		fakeData.u.sp = UserExtModel:sp() + sp;
	end 

	if gold ~= 0 then 
		fakeData.u.giftGold = UserModel:giftGold() + gold;
		fakeData.u.giftGoldTotal = UserModel:giftGoldTotal() + gold;
	end 

	fakeData.u.everydayQuest = {
		receiveStatus = {
			[tostring(questId)] = tonumber(questId);
		}
	}

	return fakeData;
end
function DailyQuestModel:setquestId(questId)
	self.questIds = questId
end
function DailyQuestModel:getquestId()
	return self.questIds
end
function DailyQuestModel:setJumToquestId(questId)
	self.jumToquestIds = questId
end
function DailyQuestModel:getJumToquestId()
	return self.jumToquestIds
end


function DailyQuestModel:setJumToquestId(questId)
	self.jumToquestId = questId
end

return DailyQuestModel















