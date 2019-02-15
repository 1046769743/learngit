--guan
--2016.3.26
--2017.1.18 
--2017.4.12 目标 原来的主线任务

local TargetQuestModel = class("DailyQuestModel", BaseModel)

TargetQuestModel.Type = {
	RAID = 1,  		--主线进度  
	RAID_ELITE = 2, --精英进度
	CHAR_TALENT = 3,   --主角天赋
	PARTNER_QUALITY = 4, --伙伴品质
	PARTNER_LVL = 5, --伙伴等级  
	PARTNER_STAR = 6, --伙伴星级 
	PARTNER_SKILL = 7, --伙伴技能 
	PARTNER_COLLECT = 9, --伙伴数量 
	PARTNER_EQUIP = 10, --伙伴装备 
	CHAR_QUALITY = 11, --主角品质 
	POWER = 13, --总战力 

	--没有14 15 ……
	TOWER = 16,  --爬塔

	TRIAL_HUAINANWANG = 17,    --淮南王
	TRIAL_CAISHEN = 18,     --财神
	TRIAL_XUE  = 19,    --雪妖试炼

	--不跳转
	COIN = 30, --累计消耗铜钱
	GOLD = 31, --累计消耗仙玉

	--下面都是 frequencies
	RAIN_NUM = 32, --主线通关次数
	ELITE_NUM = 33, --精英通关次数
	TRIAL_NUM = 34, --试炼通关次数 


	TREASURE_NUM = 35, --=法宝数量、 
	TREASURE_STAR = 36, --=法宝星级、
	ARTIFACT_ACT = 37, --=神器任意单件激活、
	ARTIFACT_ACT_NUM =38, --=神器激活数量、
	ARTIFACT_LEVEL = 39, --=神器等阶、
	LOVE_NUM = 40, --=激活情缘数量、
	WULIN_LEVEL = 41, --=五灵法阵等阶、
	CHAR_LEVEL =  42, --=主角等级、


	COLLECT_ITEM = 91, --收集道具
	COLLECT_PARTNER = 93, --收集伙伴
	FULL_BATTLE_NUM = 94, --满阵容参战
	GIVE_SP = 95, --首次送体力
	CHAT_PRIVATE = 96, --与好友私聊一次
	CHAT_GLOBAL = 97, --世界聊天
	BUY = 98, --第一次购买

	JOIN = 99, --第一次加入仙盟

	HONOR = 50,---六界第一
};

TargetQuestModel.TAB_KIND = {
	ALL = {1,2,3,4,5,6,7,8,9,10,11,12,13,16,17,18,19,30,31,32,33,34,35,36,37,38,39,40,41,42,91,93,94,95,96,97,98,99},
	TRAIN = {3,4,5,6,7,8,9,10,11,12,13},
	CHANELLAGE = {1,2,16,17,18,19,32,33,34},
	OTHER = {30,31,91,93,94,95,96,97,98,99},
};

TargetQuestModel.JUMP_VIEW = {
	--跳主线
	["1"] = {funName = function (questId)
				--关卡id
				local targetRaid = FuncQuest.readMainlineQuest(questId, "completeCondition")[1];
				-- echoError("=====targetRaid=======",targetRaid)
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN, targetRaid);
			end},
	--跳精英
	["2"] = {funName = function (questId)
				--关卡id
				local targetRaid = FuncQuest.readMainlineQuest(questId, "completeCondition")[1];
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_ELITE)
			end},
			
	["3"] = {viewName = "PartnerView",systemname = "partner"},
	["4"] = {viewName = "PartnerView",systemname = "partner"},
	["5"] = {viewName = "PartnerView",systemname = "partner"},
	["6"] = {viewName = "PartnerView",systemname = "partner"},
	["7"] = {viewName = "PartnerView",systemname = "partner"},
	["8"] = {viewName = "PartnerView",systemname = "partner"}, 
	["9"] = {viewName = "PartnerView",systemname = "partner"},
	["10"] = {viewName = "PartnerView",systemname = "partner"},
	["11"] = {viewName = "PartnerView",systemname = "partner"}, 
	["12"] = {viewName = "PartnerView",systemname = "partner"},
	["13"] = {viewName = "PartnerView",systemname = "partner"},

	["16"] = {funName = function (questId)
				TowerControler:enterTowerMainView()
			end},
	["17"] = {viewName = "TrialNewEntranceView",systemname = "trial"},
	["18"] = {viewName = "TrialNewEntranceView",systemname = "trial"},
	["19"] = {viewName = "TrialNewEntranceView",systemname = "trial"},
	["31"] =  {funName = function ()---消耗仙玉
				WindowControler:showTips(GameConfig.getLanguage("#tid_shop_1005")); 
			end},
	--主线
	["32"] = {funName = function ()
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN) 
			end},
	--精英
	["33"] = {funName = function ()
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_ELITE)  
			end},

	["34"] = {viewName = "TrialNewEntranceView",systemname = "trial"},



	["35"] = {viewName = "TreasureMainView",systemname = "treasureNatal"},
	["36"] = {viewName = "TreasureMainView",systemname = "treasureNatal"},
	["37"] = {viewName = "ArtifactMainView",systemname = "cimelia"},
	["38"] = {viewName = "ArtifactMainView",systemname = "cimelia"},
	["39"] = {viewName = "ArtifactMainView",systemname = "cimelia"},
	["40"] = {viewName = "NewLoveMainView",systemname = "love"},
	["41"] = {viewName = "WuLingMainView",systemname = "fivesoul"},
	["42"] = {viewName = "PartnerView",systemname = "partner"},



	["91"] = {funName = function (questId)
				--900002跳转到商店
				if tonumber(questId) == 900002 then
					WindowControler:showWindow("ShopView");
				else 
					--主线
					FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN);
				end 
			end}, 

	["93"] = {viewName = "PartnerView",systemname = "partner"}, 
	--主线
	["94"] = {funName = function ()
				FuncCommUI.showWorldView(WorldModel.stageType.TYPE_STAGE_MAIN) 
			end},

	["95"] = {funName = function ()
				FriendViewControler:forceShowFriendList();  
			end},
	["96"] = {funName = function ()
				FriendViewControler:forceShowFriendList(); 
			end},
			
	["97"] = {funName = function ()
				WindowControler:showWindow("ChatMainView", 1);
			end}, 

	["98"] = {viewName = "ShopView",systemname = "shop1"}, 

	["99"] = {viewName = "GuildCreateAndAddView",systemname = "guild"}, 

	["100"] = {viewName = "ArenaMainView",systemname = "pvp"}, 
};

function TargetQuestModel:init(data)
	self.modelName = "TargetQuestModel"
    TargetQuestModel.super.init(self, data)

    --各个线任务的进度
    self._datakeys = {
   		mainlineQuests = {},
	};

	self._newAchievement = {};
	self.cacheerrorTable = {};

	self:createKeyFunc()
	self:mainQuestChangeCallBack()

    EventControler:addEventListener(InitEvent.INITEVENT_FUNC_INIT, 
    	self.onFuncInit, self)  

    --主线变化事件
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.mainQuestChangeCallBack, self);

    --升级事件
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,
        self.mainQuestChangeCallBack, self);

    --伙伴相关事件
    EventControler:addEventListener(PartnerEvent.PARTNER_STAR_LEVELUP_EVENT,
        self.sendMainLineChangeEvent, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_LEVELUP_EVENT,
        self.sendMainLineChangeEvent, self);
    EventControler:addEventListener(PartnerEvent.PARTNER_QUALITY_CHANGE_EVENT,
        self.sendMainLineChangeEvent, self);  
    EventControler:addEventListener(PartnerEvent.PARTNER_NUMBER_CHANGE_EVENT,
        self.sendMainLineChangeEvent, self);  

    --主角品质提升
    EventControler:addEventListener(UserEvent.USEREVENT_QUALITY_CHANGE,
        self.sendMainLineChangeEvent, self); 

    self:updateData(data)

end

function TargetQuestModel:sendMainLineChangeEvent()
	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {});
end

function TargetQuestModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname ~= "FuncQuest" then
		return
	end
	self:updateData(self._data);

end

--更新数据
--[[
	后端记录的是各线任务进度，空是第一个任务，否则是正在进行的任务
	{
		3001 = {3002 = 3002}
		4001 = {4004 = 4004}
	}
]]
function TargetQuestModel:updateData(data)
	TargetQuestModel.super.updateData(self,data);
	dump(data, "----!!!!!!!!TargetQuestModel:updateData!!!!!!!!-----");

	if data ~= nil then 
		for k, v in pairs(data) do
			self._datakeys.mainlineQuests[k] = v;
		end
	end
	self:mainQuestChangeCallBack()


	self:sendMainLineChangeEvent()

	--有完成的，就显示红点
	-- if self:isHaveFinishQuest() == true and 
	-- if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST) == true then 
		
	-- 	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
 --            {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = self:isHaveFinishQuest() or self:isHaveUpgradeReward() or self:isCurAchievementIndexFinish() or false});
	-- end

end

--删除数据
function TargetQuestModel:deleteData( keyData ) 
	-- dump(keyData, "---!!!!!TargetQuestModel:deleteData!!!---");
	for k, vt in pairs(keyData) do
		local preVt = self._datakeys.mainlineQuests[k];
		for k, v in pairs(vt) do
			preVt[k] = nil;
		end
	end

end

function TargetQuestModel:mainLineQuestOpenCheck(questId)
	local openCondition = FuncQuest.readMainlineQuest(questId, "openCondition", false);
	local isReachCondition = UserModel:checkCondition( openCondition );
	return isReachCondition == nil and true or false;
end

function TargetQuestModel:isHideQuest(id)
	local isHide = FuncQuest.readMainlineQuest(id, "Hide", false);
	return isHide == 1 and true or false;
	-- return false;
end

function TargetQuestModel:isNeedShow(id)
	local isHide = self:isHideQuest(id);
	local isFinish = self:isMainLineQuestFinish(id);

	if isHide == false then 
		return true;
	else
		if isFinish == true then 
			return true;
		else
			return false;
		end 
	end 
end

function TargetQuestModel:isConditionTypeIn(tabKind, conditionType)
	for _, v in pairs(tabKind) do
	 	if v == conditionType then 
	 		return true;
	 	end 
	end
	return false;
end

function TargetQuestModel:getAllShowQuestWithoutSort(tabKind)
	local tabKind = tabKind or TargetQuestModel.TAB_KIND.ALL;
	local allShowQuests = {};
	--从后端得到要显示的任务
	for k, v in pairs(self._datakeys.mainlineQuests) do
		--每个线路
		for i, j in pairs(v) do
			--都完成了
			if i == "1" and j == 1 then 
				break;
			end 		
			--开启了 并且 需要显示
			if self:mainLineQuestOpenCheck(i) == true and 
					self:isNeedShow(i) == true then

				local conditionType = FuncQuest.readMainlineQuest(i, "conditionType");
				if self:isConditionTypeIn(tabKind, conditionType) then 
					table.insert(allShowQuests, i);
				end 

			end   	
		end

	end
	--需要单独判断的rootId
	local rootIds = FuncDataSetting.getQuestOpenArray();

	for _, v in pairs(rootIds) do
		--没有完成过才继续
		if self._datakeys.mainlineQuests[v] == nil then 
			-- if tonumber(30001) == 30001 then
				if self:mainLineQuestOpenCheck(v) == true and self:isNeedShow(v) == true then
					local conditionType = FuncQuest.readMainlineQuest(v, "conditionType");
					if self:isConditionTypeIn(tabKind, conditionType) then 
						table.insert(allShowQuests, v);
					end 
				end 
			-- end
		end 
	end

	local ret = array.toSet(allShowQuests);

	return ret;
end

--****** 注意：只能是datasetting里配置的任务 *****--
function TargetQuestModel:isQuestAlreadyGet(questId)
	local isIn = self:isQuestComplete(questId);
	if isIn == true then 
		--是否已经完成
		local isFinsh = LS:prv():get(tostring(questId), false);
		if isFinsh ~= false then 
			return true;
		else 
			return false;
		end 
	else 
		return false;
	end 
end

--是不是需要单独记录是否完的任务
function TargetQuestModel:isQuestComplete(questId)
	local array = FuncDataSetting.getQuestCompleteIds();
	for _, v in pairs(array) do
		if tostring(questId) == tostring(v) then 
			return true;
		end 
	end
	return false;
end


function TargetQuestModel:getPostQuest(questId)
	local questIds = {};
	local postIds = FuncQuest.readMainlineQuest(questId, "postTask", false);
	--没有postId了，直接返回
	if postIds == nil then 
		return questIds;
	end

	for _, v in pairs(postIds) do
		if self:isMainLineQuestFinish(v) then 
			local ids = self:getPostQuest(v);
			for k, v in pairs(ids) do
				table.insert(questIds, v);
			end
		end 
		table.insert(questIds, v);
	end

	return questIds;
end

--完成的放到前面
local function sortFunc(id1, id2)
	local id1IsFinish = TargetQuestModel:isMainLineQuestFinish(id1);
	local id2IsFinish = TargetQuestModel:isMainLineQuestFinish(id2);

	id1IsFinish = id1IsFinish == true and 1 or 0;
	id2IsFinish = id2IsFinish == true and 1 or 0;

	if id1IsFinish > id2IsFinish then 
		return true
	elseif id1IsFinish == id2IsFinish then 
		--得到难度类型
		local easyType1 = FuncQuest.readMainlineQuest(id1, "EasyType") or 1;
		local easyType2 = FuncQuest.readMainlineQuest(id2, "EasyType") or 1;

		if easyType1 < easyType2 then 
			return true;
		elseif easyType1 == easyType2 then 
			--id顺序
			if tonumber(id1) < tonumber(id2) then 
				return true  
			else 
				return false;
			end 
		else 
			return false;
		end 
	else
		return false;
	end 
end

--[[
	所有显示的主线任务
	从后端的完成任务，找 postTask 
]]
function TargetQuestModel:getAllShowMainQuestId(tabKind)

	local tabKind = tabKind or TargetQuestModel.TAB_KIND.ALL;

	local allShowQuests = self:getAllShowQuestWithoutSort(tabKind)

	local recommendQuestId = self:getRecommendQuestId();

	table.sort(allShowQuests, sortFunc);

	local conditionType = FuncQuest.readMainlineQuest(recommendQuestId, "conditionType");

	if self:isConditionTypeIn(tabKind, conditionType) then 
		--把推荐任务放到第一个，不管完没完成
		for k, v in pairs(allShowQuests) do
			if v == recommendQuestId then 
				table.remove(allShowQuests, k);
				break;
			end 
		end

		if recommendQuestId ~= nil then 
			table.insert(allShowQuests, 1, recommendQuestId);
		end 
	end 

	return allShowQuests;
end

---任务是否领取
function TargetQuestModel:getQuestIsGetReward(questid)
	
	local _datakeys = self._datakeys.mainlineQuests

	-- dump(_datakeys,"2222222222",9)

	local rootId = FuncQuest.readMainlineQuest(questid,"rootId")
	-- local  FuncQuest:getAllmainQuest()
	if rootId ~= nil then
		local d_data =  _datakeys[tostring(rootId)]
		if d_data ~= nil then
			if d_data["1"] ~= nil and  d_data["1"] == 1 then
				return true
			else
				local postTaskid = FuncQuest.readMainlineQuest(questid,"postTask")
				if postTaskid ~= nil then
					for k,v in pairs(d_data) do
						if tonumber(questid) < v then
							return true
						else
							return false
						end
					end
					
				else
					return false
				end
			end
		else
			return false
		end
	else
		return true
	end
end

--[[
	任务是否完成
]]
function TargetQuestModel:isMainLineQuestFinish(id,_type,t)
	-- echo("===========称号ID===============",id,t)
	if t == UserModel.CONDITION_TYPE.QUEST_GET then
		local isfinish = self:getQuestIsGetReward(id)
		return isfinish
	end
	--主线是否完成
	local function isFinishRaid(id)
		local curRaid = UserExtModel:getMainStageId();
		local targetRaid = nil
		if _type == FuncTitle.titlettype.title_limit then 
			targetRaid = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			targetRaid = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end


		return tonumber(curRaid) >= tonumber(targetRaid) and true or false;
	end

	--精英副本是否完成
	local function isFinishElite( id )
		local curRaid = UserExtModel:getEliteStageId();
		local targetRaid = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		if _type == FuncTitle.titlettype.title_limit then 
			targetRaid = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			targetRaid = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end

		return tonumber(curRaid) >= tonumber(targetRaid) and true or false;
	end

	--爬塔是否完成
	local function isFinishTower(id)
		local needMaxfloor = nil
		if _type == FuncTitle.titlettype.title_limit then 
			needMaxfloor = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			needMaxfloor = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end
		local isok = TowerMainModel:checkIsPerfectPass( needMaxfloor )

        return isok;
	end

	--主角品质
	local function isFinishCharQuality(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end

		local quality = UserModel:quality();
		return quality >= tonumber(target) and true or false;
	end 

	--伙伴等级
	local function isFinishPartnerLvl(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")--[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")--[1];
		end


		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);

		--获得有几个大于level参数级别的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamLvl(level - 1); 

		return haveNum >= needNum and true or false;
	end

	--伙伴品质
	local function isFinishPartnerQuality(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")--[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")--[1];
		end

		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local quality = tonumber(target[2]);

		--获得有几个大于quality参数品质的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamQuality(quality - 1);
		local isgreater = self:getUserQuiltIsOk(quality)
		if haveNum >= needNum and isgreater then
			return true
		end
		return false;
	end

	--伙伴
	local function isFinishPartnerStar(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")--[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")--[1];
		end

		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local star = tonumber(target[2]);


		--获得有几个大于star参数星级的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamStar(star-1); 
		local isgreater = self:getUserStarIsOk(star)
		if haveNum >= needNum and isgreater then
			return true
		end
		return  false;

	end

	local function isFinishPartnerNum(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end
		local cur = PartnerModel:getPartnerNum()
		return cur >= tonumber(target) and true or false;
	end

	--技能
	local function isFinishPartnerSkill(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")--[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")--[1];
		end
		-- local tables = string.split(target, ",");

		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);
		
		--获得有几个所有技能都大于 level 的伙伴
		local haveNum = PartnerModel:partnerSkillLevelGreaterThenParamLevel(level -1); 

		return haveNum >= needNum and true or false;
	end

	local function isFinishPartnerEquip(id)
		local target = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")--[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")--[1];
		end
		-- local tables = string.split(target, ",");

		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);
		
		--获得有几个所有装备等级 大于 level 的伙伴
		local haveNum = PartnerModel:partnerEquipLevelGreaterThenParamLevel(level-1);
		local isgreater =  self:getAllequipsLevel(level)
		if haveNum >= needNum and isgreater then
			return true
		end
		return false;
	end

	local function isFinisPower(id)
		local need = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			need = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			need = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end
		local have = UserModel:getcharSumAbility();
		if tonumber(have) >= tonumber(need) then 
			return true;
		else 
			return false;
		end 
	end

	local function isTrailFinish(id)
		local target = nil
		if _type == FuncTitle.titlettype.title_limit then 
			target = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			target = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end
		local ret = TrailModel:TrailCustomsClearance(target);
		return ret;
	end

	local function isItemCollectFinish(id)
		local itemId = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		if _type == FuncTitle.titlettype.title_limit then 
			itemId = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			itemId = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end


		if UserModel:isOwnItemEver(itemId) == false then 
			return false;
		else 
			return true;
		end 
	end

	local function isPartnerCollectFinish(id)
		local partnerId = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			partnerId = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			partnerId = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end


		if PartnerModel:isPartnerExist(partnerId) == false then 
			return false;
		else 
			return true;
		end 
	end

	--累计消耗铜钱 30
	local function isConiCostFinish(id)
		local costNeed = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		if _type == FuncTitle.titlettype.title_limit then 
			costNeed = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			costNeed = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end

		local cost = UserModel:getCoinTotal() - UserModel:getCoin();

		if tonumber(cost) >= tonumber(costNeed) then 
			return true;
		else 
			return false;
		end 
	end

	local function isGoldCostFinish(id)
		local costNeed = nil--FuncQuest.readMainlineQuest(id, "completeCondition")[1];

		if _type == FuncTitle.titlettype.title_limit then 
			costNeed = FuncTitle.gettitletype(id, "completeCondition")[1];
		else
			costNeed = FuncQuest.readMainlineQuest(id, "completeCondition")[1];
		end

		local cost = UserModel:totalCostGold();

		if tonumber( cost) >= tonumber(costNeed) then 
			return true;
		else 
			return false;
		end 
	end


	local function isFrequencyFinish(id, kind)
		local costNeed = nil--tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		if _type == FuncTitle.titlettype.title_limit then 
			costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		end
		local num =  UserModel:getFrequencyByKey(kind);

		if tonumber(num) >= tonumber(costNeed) then
			return true;
		else 
			return false;
		end		
	end

	--法宝数量
	local function isTreasureNumFinish(id)
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		end
		-- TreasureNewModel:getEnoughStarNum

		local allTreasure = TreasureNewModel:getOwnTreasures()
		local num = table.length(allTreasure)
		if num >= costNeed then
			return true;
		else
			return false;
		end
	end

	--获得法宝星级的数量
	local function isTreasureStarFinish(id)
		local costNeed = 0
		local _star = 1
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
			_star = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[2] );
		end
		local num = TreasureNewModel:getEnoughStarNum(_star)
		if num >= costNeed then
			return true;
		else
			return false;
		end
	end


	local function isArtifactSingNumFinish(id)
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		end
		local sumnum,signnum = ArtifactModel:activeArtifactNum()
		if signnum >= costNeed then
			return true;
		else
			return false;
		end
	end


	local function isArtifactNumFinish(id)
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		end
		local sumnum,signnum = ArtifactModel:activeArtifactNum()
		if sumnum >= costNeed then
			return true;
		else
			return false;
		end
	end

	local function isArtifactLevelNum(id)
		local costNeed = 0
		local quility = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
			quility = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[2]);
		end
		local num =  ArtifactModel:artifactQuilityNum(quility)
		if num >= costNeed then
			return true;
		else
			return false;
		end
	end

	local function isLoveNumFinish(id)
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
		end
		if NewLoveModel ~= nil then 
			local num =    NewLoveModel:getActivateLoveNum()  --  --ArtifactModel:artifactQuilityNum(quility)
			if num >= costNeed then
				return true;
			else
				return false;
			end
		else
			return false
		end
	end

	local function isWuLingNumFinish(id)
		local level = 0
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] );
			level = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[2] );
		end
		local num =  WuLingModel:getWuLingNumByLevel(level)
		if num >= costNeed then
			return true;
		else
			return false;
		end

	end


	local function isCharLevelFinish(id)
		local costNeed = 0
		if _type == FuncTitle.titlettype.title_limit then 
			-- costNeed = tonumber(FuncTitle.gettitletype(id, "completeCondition")[1]);
		else
			costNeed = tonumber( FuncQuest.readMainlineQuest(id, "completeCondition")[1] or 0);
		end
		local num =  UserModel:level()
		if num >= costNeed then
			return true;
		else
			return false;
		end
	end




	--32 主线通关次数
	local function isRainNumFinish(id)
		return isFrequencyFinish(id, 1);
	end

	--33 精英通关次数
	local function isEliteNumFinish(id)
		return isFrequencyFinish(id, 2);
	end

	local function isTrailNumFinish(id)
		return isFrequencyFinish(id, 3);
	end

	local function isFullPartnerFinish(id)
		local ret = isFrequencyFinish(id, 4);
		return ret;
	end

	local function isGiveSpFinish(id)
		return isFrequencyFinish(id, 6);
	end

	local function isChatPrivateFinish(id)
		return isFrequencyFinish(id, 5);
	end

	local function isChatGlobalFinish(id)
		return isFrequencyFinish(id, 7);
	end

	local function isBuyNumFinish(id)
		return isFrequencyFinish(id, 8);
	end





	local function isJoinGuildFinish(id)
		local isadd = false
		if  UserModel:guildId() ~= "" then
			isadd = true
		end
		return isadd
	end

	local questType = nil
	if _type == FuncTitle.titlettype.title_limit then 

		questType = FuncTitle.gettitletype(id,"conditionType")
		-- echo("========id=============",id,questType)
	else
		questType = FuncQuest.readMainlineQuest(id, "conditionType");
	end


	--分19个类型分别判断是否完成
	if questType == TargetQuestModel.Type.RAID then --主线剧情1
		return isFinishRaid(id);
	elseif questType == TargetQuestModel.Type.RAID_ELITE then --精英剧情2
		return isFinishElite(id);
	elseif questType == TargetQuestModel.Type.PARTNER_QUALITY then --伙伴品质4 
		return isFinishPartnerQuality(id); 
	elseif questType == TargetQuestModel.Type.PARTNER_LVL then --伙伴等级 5 
		return isFinishPartnerLvl(id);
	elseif questType == TargetQuestModel.Type.PARTNER_STAR then --伙伴星级 6 
		return isFinishPartnerStar(id); 
	elseif questType == TargetQuestModel.Type.PARTNER_SKILL then --伙伴等级 7
		return isFinishPartnerSkill(id);		
	elseif questType == TargetQuestModel.Type.PARTNER_COLLECT then --伙伴数量 9
		return isFinishPartnerNum(id);
	elseif questType == TargetQuestModel.Type.PARTNER_EQUIP then --伙伴装备 10
		return isFinishPartnerEquip(id);
	elseif questType == TargetQuestModel.Type.CHAR_QUALITY then --主角品质 11
		return isFinishCharQuality(id);
	elseif questType == TargetQuestModel.Type.POWER then --总战力 13
		return isFinisPower(id);
	elseif questType == TargetQuestModel.Type.TOWER then --爬塔 16
		return isFinishTower(id);
	elseif questType == TargetQuestModel.Type.TRIAL_HUAINANWANG then --淮南王 17
		return isTrailFinish(id);
	elseif questType == TargetQuestModel.Type.TRIAL_CAISHEN then --财神 18 
		return isTrailFinish(id);
	elseif questType == TargetQuestModel.Type.TRIAL_XUE then --雪妖 19
		return isTrailFinish(id);

	elseif questType == TargetQuestModel.Type.COIN then --累计消耗铜钱 30
		return isConiCostFinish(id);
	elseif questType == TargetQuestModel.Type.GOLD then --累计消耗仙玉 31
		return isGoldCostFinish(id);
	elseif questType == TargetQuestModel.Type.RAIN_NUM then --主线通关次数 32
		return isRainNumFinish(id);
	elseif questType == TargetQuestModel.Type.ELITE_NUM then --精英通关次数 33
		return isEliteNumFinish(id);
	elseif questType == TargetQuestModel.Type.TRIAL_NUM then --试炼通关次数 34
		return isTrailNumFinish(id);
	elseif questType == TargetQuestModel.Type.TREASURE_NUM then  --=法宝数量 35
		return isTreasureNumFinish(id);
	elseif questType == TargetQuestModel.Type.TREASURE_STAR then --=法宝星级、36 
		return isTreasureStarFinish(id);
	elseif questType == TargetQuestModel.Type.ARTIFACT_ACT then --=神器任意单件激活、37
		return isArtifactSingNumFinish(id);
	elseif questType == TargetQuestModel.Type.ARTIFACT_ACT_NUM then --=神器激活数量、38
		return isArtifactNumFinish(id);
	elseif questType == TargetQuestModel.Type.ARTIFACT_LEVEL then   --=神器等阶、39
		return isArtifactLevelNum(id);
	elseif questType == TargetQuestModel.Type.LOVE_NUM then  --=激活情缘数量、40
		return isLoveNumFinish(id);
	elseif questType == TargetQuestModel.Type.WULIN_LEVEL then --=五灵法阵等阶、41
		return isWuLingNumFinish(id);
	elseif questType == TargetQuestModel.Type.CHAR_LEVEL then   --=主角等级、42
		return isCharLevelFinish(id);
	elseif questType == TargetQuestModel.Type.COLLECT_ITEM then --道具收集 91 
		return isItemCollectFinish(id);
	elseif questType == TargetQuestModel.Type.COLLECT_PARTNER then --伙伴收集 93
		return isPartnerCollectFinish(id);
	elseif questType == TargetQuestModel.Type.FULL_BATTLE_NUM then --满阵容参战 94
		return isFullPartnerFinish(id);
	elseif questType == TargetQuestModel.Type.GIVE_SP then --首次送体力 95
		return isGiveSpFinish(id);
	elseif questType == TargetQuestModel.Type.CHAT_PRIVATE then --与好友私聊一次 96
		return isChatPrivateFinish(id);
	elseif questType == TargetQuestModel.Type.CHAT_GLOBAL then --世界聊天 97
		return isChatGlobalFinish(id);
	elseif questType == TargetQuestModel.Type.BUY then --进行一次购买 98
		return isBuyNumFinish(id);
	elseif questType == TargetQuestModel.Type.JOIN then --加入一个仙盟 99		
		return isJoinGuildFinish(id);
	else 
		if id ~= nil then
			if self.cacheerrorTable[id] == nil then
				self.cacheerrorTable[id] = true
				echoWarn("---no this quest type, questId is---" .. tostring(id));
			end
		end
		return false;
	end 
end

--判断主角品质是否达标
function TargetQuestModel:getUserQuiltIsOk(target)
	local quality = UserModel:quality();
	return quality >= tonumber(target) and true or false;
end

--主角星级
function TargetQuestModel:getUserStarIsOk(target)
	local userstar =  UserModel:star()
	-- echo("=======userstar=========",userstar)
	return userstar >= tonumber(target) and true or false;
end

--获取所有装备的数据
function TargetQuestModel:getAllequipsLevel(levles)
	local allequips = UserModel:equips()
	for k,v in pairs(allequips) do
		if v.level < levles then
			return false
		end
	end
	return true
end



--[[
	是否有完成的任务
]]
function TargetQuestModel:isHaveFinishQuest()
	local allShowQuests = self:getAllShowMainQuestId();
	for k, v in pairs(allShowQuests) do
		if self:isMainLineQuestFinish(v) == true then 
			return true;
		end 
	end
	return false;
end

--[[
	是否显示右边的进度和前往
]]
function TargetQuestModel:isShowNumInfo(id)
	local num = FuncQuest.readMainlineQuest(id, "num", false);
	return (num ~= 0 and num ~= nil) and true or false;	
end

--[[
	需要数量
]]
function TargetQuestModel:needCount(questId)
	local num = FuncQuest.readMainlineQuest(questId, "num", false);
	return num or 5000;
end

--[[
	完成数量
]]
function TargetQuestModel:finishCount(questId)
-- 	PARTNER_QUALITY
-- PARTNER_STAR
-- PARTNER_EQUIP
	local sumnumner = 0 
	local questType = FuncQuest.readMainlineQuest(questId, "conditionType");

	if questType == TargetQuestModel.Type.PARTNER_QUALITY then --4 伙伴品质
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")--[1];

		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local quality = tonumber(target[2]);
		local userquality = UserModel:quality();
		--获得有几个大于quality参数品质的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamQuality(quality - 1);
		sumnumner = haveNum
		if haveNum >= needNum then
			sumnumner = needNum
		end
		if userquality >= quality then
			sumnumner = sumnumner + 1
		end
		return sumnumner;
	elseif questType == TargetQuestModel.Type.PARTNER_LVL then --5 伙伴等级
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")--[1];

		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);

		--获得有几个大于level参数级别的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamLvl(level - 1); 
		return haveNum;

	elseif questType == TargetQuestModel.Type.PARTNER_STAR then --6伙伴星级 
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")--[1];

		-- local tables = string.split(target, ",");
		local needNum = tonumber(target[1]);
		local star = tonumber(target[2]);
		local userstar =  UserModel:star()
		--获得有几个大于star参数星级的伙伴
		local haveNum = PartnerModel:partnerNumGreaterThenParamStar(star - 1);

		sumnumner = haveNum
		if haveNum >= needNum then
			sumnumner = needNum
		end
		if tonumber(userstar) >= star then
			sumnumner = haveNum + 1
		end

		return sumnumner;
	elseif questType == TargetQuestModel.Type.PARTNER_SKILL then  --7伙伴技能
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")--[1];
		-- local tables = string.split(target, ",");

		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);
		
		--获得有几个所有技能都大于 level 的伙伴
		local haveNum = PartnerModel:partnerSkillLevelGreaterThenParamLevel(level - 1); 
		return haveNum;
	elseif questType == TargetQuestModel.Type.PARTNER_COLLECT then  --9伙伴技能
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")[1];
		local cur = PartnerModel:getPartnerNum()
		return cur;
	elseif questType == TargetQuestModel.Type.PARTNER_EQUIP then  --10伙伴技能
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition")--[1];
		-- local tables = string.split(target, ",");

		local needNum = tonumber(target[1]);
		local level = tonumber(target[2]);
		
		--获得有几个所有装备等级 大于 level 的伙伴
		local haveNum = PartnerModel:partnerEquipLevelGreaterThenParamLevel(level - 1); 
		local userquillevel =  self:getAllequipsLevel(level)
		sumnumner = haveNum
		if haveNum >= needNum then
			sumnumner = needNum
		end
		if userquillevel then
			sumnumner = sumnumner + 1
		end

		return sumnumner;
	elseif questType == TargetQuestModel.Type.POWER then  --13总战力
		local cur = UserModel:getcharSumAbility();
		return cur;
	elseif questType == TargetQuestModel.Type.RAIN_NUM then  --32 主线通关次数
		local num =  UserModel:getFrequencyByKey(1);
		return num;

	elseif questType == TargetQuestModel.Type.ELITE_NUM then  --33 精英通关次数
		local num =  UserModel:getFrequencyByKey(2);
		return num;

	elseif questType == TargetQuestModel.Type.TRIAL_NUM then  --34 试炼通关次数
		local num =  UserModel:getFrequencyByKey(3);
		return num;
	elseif questType == TargetQuestModel.Type.COIN then  --30 累计消耗铜钱
		local cost = UserModel:getCoinTotal() - UserModel:getCoin();
		return cost;

	elseif questType == TargetQuestModel.Type.GOLD then  --31 累计消耗仙玉
		local cost = UserModel:totalCostGold();
		return cost;
	elseif questType == TargetQuestModel.Type.WULIN_LEVEL then   --41 五灵法阵
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition");
		local neednum = tonumber(target[1]);
		local level = tonumber(target[2]);
		sumnumner = WuLingModel:getWuLingNumByLevel(level)
		if sumnumner >= neednum then
			sumnumner = neednum
		end
		return sumnumner
	elseif  questType == TargetQuestModel.Type.LOVE_NUM then
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition");
		local neednum = tonumber(target[1]);
		sumnumner = NewLoveModel:getActivateLoveNum()
		if sumnumner >= neednum then
			sumnumner = neednum
		end
		return sumnumner
	elseif  questType == TargetQuestModel.Type.ARTIFACT_ACT then
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition");
		local neednum = tonumber(target[1]);
		local sum ,sinsum = ArtifactModel:activeArtifactNum()
		sumnumner = sinsum
		if sumnumner >= neednum then
			sumnumner = neednum
		end
		return sumnumner

	elseif  questType == TargetQuestModel.Type.ARTIFACT_ACT_NUM then
		local target = FuncQuest.readMainlineQuest(questId, "completeCondition");
		local neednum = tonumber(target[1]);
		local sum ,sinsum = ArtifactModel:activeArtifactNum()
		sumnumner = sum
		if sumnumner >= neednum then
			sumnumner = neednum
		end
		return sumnumner
	else 
		return 0;
	end 
end

--[[
	得到推荐任务
]]
function TargetQuestModel:getRecommendQuestId()
	local allShowQuests = self:getAllShowQuestWithoutSort()

	local function sortFunc(id1, id2)
		--得到难度类型
		local easyType1 = FuncQuest.readMainlineQuest(id1, "EasyType") or 1;
		local easyType2 = FuncQuest.readMainlineQuest(id2, "EasyType") or 1;

		if easyType1 < easyType2 then 
			return true;
		elseif easyType1 == easyType2 then 
			--id顺序
			if tonumber(id1) < tonumber(id2) then 
				return true  
			else 
				return false;
			end 
		else 
			return false;
		end 
	end

	--不考虑完美完成了
	table.sort(allShowQuests, sortFunc);

	return allShowQuests[1];
end

--[[
	是否是推荐任务
]]
function TargetQuestModel:isRecommendQuest(questId)
	local recommandId = self:getRecommendQuestId();
	if tonumber(recommandId) == tonumber(questId) then 
		return true;
	else 
		return false;
	end 
end

--任务发生变化 todo 待调整
function TargetQuestModel:mainQuestChangeCallBack()
	-- echo("-----TargetQuestModel:mainQuestChangeCallBack----");
	local isShow = false;

	if self:isHaveFinishQuest() == true then 
		isShow = true 
	else 
		if DailyQuestModel ~= nil and DailyQuestModel:isHaveFinishQuest() == true then 
			isShow = true;
		end 
	end 
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = self:isHaveFinishQuest() or DailyQuestModel:isHaveFinishQuest() or  self:isHaveUpgradeReward() or self:ishasAchieveCanGet() or false});
end


function TargetQuestModel:curAchievementIndex()
	local default = 1;
	local receiveAchievementIds = UserModel:receiveAchievementIds();

	if table.length(receiveAchievementIds) == 0 then 
		return default;
	end 

	local achievementLen = FuncQuest:getAchievementLen();
	for i = 1, achievementLen do
		if receiveAchievementIds[tostring(i)] == nil then 
			return i;
		end 
	end
	-- 全都有返回最后一个
	return achievementLen;
end

-- 是否已领取
function TargetQuestModel:hasAchieveGet(idx)
	local receiveAchievementIds = UserModel:receiveAchievementIds()
	return receiveAchievementIds[tostring(idx)] ~= nil
end

function TargetQuestModel:isCurAchievementIndexFinish()
	local curIndex = TargetQuestModel:curAchievementIndex();
	if curIndex == nil then 
		return false;
	end 

	local needPoint = FuncQuest:readAchiment(curIndex, "condition");
	local havePoint = UserModel:getAchievementPoint();
	if havePoint >= needPoint then 
		return true;
	else 
		return false;
	end 

end

-- 有任务可领
function TargetQuestModel:ishasAchieveCanGet()
	local receiveAchievementIds = UserModel:receiveAchievementIds()
	local havePoint = UserModel:getAchievementPoint()

	local achievementLen = FuncQuest:getAchievementLen();
	for i = 1, achievementLen do
		-- 已经不满足条件了
		if havePoint < FuncQuest:readAchiment(i, "condition") then
			return false
		end
		-- 有可领的
		if not self:hasAchieveGet(i) then
			return true
		end
	end

	return false
end

function TargetQuestModel:addNewAchievementQuestId(questId)
	self._newAchievement[questId] = true;
end


function TargetQuestModel:defNewAchievementQuestId(questId)
	self._newAchievement[questId] = nil;
end

function TargetQuestModel:isNewAchievementQuestId(questId)
	return self._newAchievement[questId];
end

--[[
	return { 
		{date = "2013.3.15", achievedId={1,23,4,5} },
		{date = "2013.3.13", achievedId={1} },
		{date = "2013.3.11", achievedId={1,23,4,5,3} },
		{date = "2013.3.10", achievedId={1,5} },
		{date = "2013.3.5", achievedId={1,23} },
	};
]]
function TargetQuestModel:getAchievementData()
	local map = {};
	local achievementData = UserModel:achievements();

	local array = {};
	for questId, timeStamp in pairs(achievementData) do
		table.insert(array, { date = timeStamp, questId = questId } );
	end

	local function sortFunc(p1, p2)
		local timeStamp1 = p1.date;
		local timeStamp2 = p2.date;

		if tonumber(timeStamp1) > tonumber(timeStamp2) then 
			return true;
		else 
			return false;
		end 
	end

	table.sort(array, sortFunc);

	for _, v in pairs(array) do
		local dateStr = os.date("%Y-%m-%d", tonumber(v.date));
		if map[dateStr] == nil then 
			map[dateStr] = {};
		end 
		table.insert(map[dateStr], v.questId);
	end

	

	local array = {};
	for dateStr, ids in pairs(map) do
		local data = {date = tostring(dateStr), achievedId = ids };
		table.insert(array, data);
	end

	--超过5个成就，拆开
	local retArray = {};
	for _, v in pairs(array) do
		local item5 = {};
		local index = 1;
		for _, j in pairs(v.achievedId) do
			table.insert(item5, j);

			if index % 4 == 0 then 
				table.insert(retArray,  {date = tostring(v.date), achievedId = item5} );
				item5 = {};
			end  

			index = index + 1;
		end

		if table.length(item5) ~= 0 then 
			table.insert(retArray,  {date = tostring(v.date), achievedId = item5} );
		end 
	end


	local function sortFunc(p1, p2)
		local timeStamp1 = p1.date;
		local timeStamp2 = p2.date;

		if timeStamp1 > timeStamp2 then 
			return true;
		else 
			return false;
		end 
	end

	table.sort(retArray, sortFunc);

	--后面的data和前面一样，就删除
	local preData = nil;
	for _, v in pairs(retArray) do
		if preData == nil then 
			preData = v.date;
		else 
			if preData == v.date then 
				v.date = "";
			else 
				preData = v.date;
			end 
		end 
	end

	return retArray;
end

function TargetQuestModel:isHaveUpgradeReward()
	local scrollData = FuncQuest:getUpgradeArray();

	for id, _ in pairs(scrollData) do
		local lvl = FuncQuest:readUpgradeQuest(id, "condition");
		local curLvl = UserModel:level();
		if curLvl >= lvl and self:isRewardAlreadyGet(id) == false then 
			return true;
		end 
	end
	return false;
end

function TargetQuestModel:isRewardAlreadyGet(lvlIndex)
	if UserModel:receiveLevelRewards()[ tostring(lvlIndex) ] ~= nil then 
		return true;
	else 
		return false;
	end 

end

function TargetQuestModel:setSelectIndex(questId)
	self.selectIndex = questId
end

function TargetQuestModel:selectQuestType(_type)
	self.selectQuestIndex = _type
end

return TargetQuestModel



























