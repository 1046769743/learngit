--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- PVP 数据类

local PVPModel = class("PVPModel",BaseModel)
function PVPModel:init(d)
	PVPModel.super.init(self, d)
	self.modelName = "pvp"
    local _default_pvp_rank =10001 --必须等于FuncPvp.DEFAULT_RANK
	self._datakeys = {
		pvpPeakRank = _default_pvp_rank, --历史最高排名
        exchangeIds = {}, --竞技场的排名兑换奖励
        scoreRewards = {},--已经领取过的积分奖励
        rankRewards = {}, --历史排名奖励
        scoreRewardExpireTime = 0,--积分奖励的过期时间
        firstTime = 0,
        challengeTimes = 0, --竞技场挑战总次数
	}
	

    local _server_time = TimeControler:getServerTime()
    if d.scoreRewardExpireTime and d.scoreRewardExpireTime < _server_time then
        self._data.scoreRewards = {}
    end
	self:createKeyFunc()
	self.fast_refresh_count = 0
	self.last_refresh_pvp_time = 0
    self._lastHistoryRank = self:pvpPeakRank()
	self:initData()
	-- 发送红点 需要获取登仙台第一数据后才能判断膜拜是否存在红点
	WindowControler:globalDelayCall(function ()
		self:getPvpFirstPlayerInfo()
	end, 1)
	
	EventControler:addEventListener(TimeEvent.TIMEEVENT_PVP_FAST_REFRESH_CD, self.onFastRefreshCdEnd, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, self.onPvpFightEnd, self)
	-- EventControler:addEventListener(BattleEvent.BATTLEEVENT_JJC_LOGIC_PRO, self.onPvpLogicResult, self)
	EventControler:addEventListener("notify_pvp_new_fight_resport_1116", self.onNewReport, self)
	-- EventControler:addEventListener(BattleEvent.BATTLEEVENT_REPLAY_GAME, self.onReplayEnd, self)
	EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onBattleClose, self)
	EventControler:addEventListener("COUNT_TYPE_BUY_PVP", self.resetData, self)
	EventControler:addEventListener("COUNT_TYPE_HONOR_COUNT", self.getPvpFirstPlayerInfo, self)

	self.last_pvp_peak_rank = self:pvpPeakRank() or _default_pvp_rank

	self:getRankExchangesDefaultTag() --初始化排名奖励tag
end

--获取登仙台第一数据
function PVPModel:getPvpFirstPlayerInfo()
	HomeServer:getDiaoestPlayer(c_func(self.getFirstPlayerInfoCallBack, self))
end

--获取登仙台第一的回调 将获得的数据存起来  因为该数据只会在22点的时候才会刷新 所以在上面需要监听 COUNT_TYPE_HONOR_COUNT 事件
function PVPModel:getFirstPlayerInfoCallBack(event)
	if event.result then
		local worship = event.result.data.worship
		if worship and table.length(worship) > 0 and worship.type ~= 2 then 
            PVPModel:setHonorData(worship)
        else
        	PVPModel:setHonorData(nil)
        end     
    else
    	echoWarn("获取膜拜数据失败")
	end

	self:sendRedStatusMsg()
	EventControler:dispatchEvent(HomeEvent.REFRESH_HONOR_EVENT)
end

-- 发送小红点状态消息
function PVPModel:sendRedStatusMsg()
	local isShow = self:isRedPointShow()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT
			, {redPointType = HomeModel.REDPOINT.DOWNBTN.PVP, isShow = isShow})  --竞技场发送到仙途按钮
end

--积分奖励过期时间
function PVPModel:processScoreReward()

end
--返回所有的已经领取的排名兑换奖励
function PVPModel:getAllRankExchanges()
    return self:exchangeIds()
end

--判断所有的奖励是否已兑换
function PVPModel:hasGetAllRankExchanges()
	local allRankExchanges = self:exchangeIds()
	if table.length(allRankExchanges) == table.length(FuncPvp.getAllRankExchanges()) then
		return true
	end
	return false
end

--获取所有达到条件可领取的排行兑换id
function PVPModel:getRankExchangesCanReceived()
	local historyTopRank = self:getHistoryTopRank()
	local allRankExchangesData = FuncPvp.getAllRankExchanges()
	local canReceived_table = {}
	local _user_money = UserModel:getArenaCoin()
	for k,v in pairs(allRankExchangesData) do
		local _cost_data = string.split(v.cost[1], ",")
		if tonumber(historyTopRank) <= tonumber(v.condition) and _user_money >= tonumber(_cost_data[2]) then
			table.insert(canReceived_table, v.id)
		end
	end
	return canReceived_table	
end

--获取剩余的达到条件还未领取的排行兑换id
function PVPModel:getRankExchangesUnreceivedNum()
	local allRankExchanges = self:exchangeIds()
	local allCanReceived = self:getRankExchangesCanReceived()
	local leftCount = #allCanReceived
	for k,v in pairs(allCanReceived) do
		if allRankExchanges[tostring(v)] then
			leftCount = leftCount - 1
		end
	end

	return leftCount
end

--根据tag返回已经领取的排名兑换奖励
function PVPModel:getRankExchangesByTag(_tag)
	local allRankExchanges = self:getAllRankExchanges()
	local table_rank = {}
	for k,v in pairs(allRankExchanges) do
		local rank_data = FuncPvp.getRankExchange(v)
		if tonumber(rank_data.select) == tonumber(_tag) then
			table_rank[tostring(k)] = v
		end
	end
	return table_rank
end
--获取默认的排行奖励tag
function PVPModel:getRankExchangesDefaultTag()
	local historyRank = self:getHistoryTopRank()
	local allRankExchangesData = FuncPvp.getAllRankExchanges()
	local tag = 0
	for k,v in pairs(allRankExchangesData) do
		if historyRank <= v.condition and tonumber(v.select) > tag then
			tag = tonumber(v.select)
		end
	end

	--当前页签所有的排名兑换奖励数据
    _rank_data = FuncPvp.getRankExchangesByTag(tag)
    --当前页签中已经获得的排名兑换数据
    _now_ranks = self:getRankExchangesByTag(tag) 
	if table.length(_rank_data) == table.length(_now_ranks) and tag < 5 then
		tag = tag + 1
	end

	self.selectedTag = tag

	return self.selectedTag
end

function PVPModel:setRankExchangesTag(_tag)
	self.selectedTag = _tag
end

function PVPModel:getRankExchangesTag()
	return self.selectedTag
end

--返回所有的已经领取的积分奖励
function PVPModel:getAllScoreRewards()
    return self:scoreRewards()
end

-- 返回已领取的历史排名奖励
function PVPModel:getRankRewards()
    return self:rankRewards()
end

function PVPModel:onNewReport(e)
    local data = e.params.params.data
    self.new_reports_ids = data
	self:checkNewReport()
end

function PVPModel:onFuncInit(event)
	local params = event.params
	local funcname = params.funcname
	if funcname == "FuncPvp" then
	end
end

--当战斗关闭
function PVPModel:onBattleClose(  )
	if BattleControler:checkIsPVP() then
		self:clearReplayData()

		local curPvpBattleInfo = self:getCurrentPvpBattleInfo()
		local battleResult = curPvpBattleInfo.result

		if battleResult and tonumber(battleResult) == tonumber(Fight.result_win) then
			EventControler:dispatchEvent(PvpEvent.PVP_BATTLE_WIN)
		end

		self:setCurrentPvpBattleInfo(nil)
	end
end

--重播结束
function PVPModel:onReplayEnd(e)

	if not BattleControler:checkIsPVP() then
		return
	end

	--目前正在播放的战报数据
	local data = self:getCurrentReplayBattleData()
	if not data then
		return
	end
	--local result = Fight.result_win
	--if self:isUserSuccess(data) then
	--    result = Fight.result_lose
	--end
	WindowControler:showBattleWindow("ArenaBattleReplayResult")
	echo("ArenaBattlePlayBackView:onReplayEnd--------------------------------------------------")
end

--清除当前缓存的数据
function PVPModel:clearCurrentFightReports()
	self.new_reports_ids = nil
end

-- 初始化数据
function PVPModel:initData()
	-- PVP系统，cd等级分割值
	self.PVP_CD_LEVEL = 50
	-- PVP系统CD的id，小于PVP_CD_LEVEL的CD为1，大于的为2
	self.PVP_CD_ID = {1,2} 
	self.forceRefresh = false
end

-- --逻辑结果出来了
-- function PVPModel:onPvpLogicResult(event)
-- 	local battleInfo = self:getCurrentPvpBattleInfo()
-- 	if not battleInfo then
-- 		return
-- 	end
-- 	--echo("onPvpLogicResult==================================================")
-- 	if self.battleResult == nil then
-- 		local battleResult = event.params
-- 		self.battleResult = battleResult
-- 		self:setLastFightResult(battleResult.rt)
-- 		local battleUsers = battleInfo.battleUsers
-- 		local params = {
-- 			result = battleResult.rt,
-- 			pvpBattleId = battleInfo.battleId,
-- 			battleInfo = { treasures = battleResult.usedTreasures },
-- 			resultInfo = event.params.resultInfo
-- 		}
-- 		PVPServer:reportBattleResult(params, c_func(self.reportBattleResultOk, self, battleResult))
-- 	end
-- end


function PVPModel:setLastFightResult(rt)
	self._last_fight_result = rt
end

function PVPModel:isLastFightWin()
	return self._last_fight_result == Fight.result_win
end

-- 展示PVP战斗结果
function PVPModel:onPvpFightEnd(event)
	if not BattleControler:checkIsPVP() then
		return
	end
	local battleInfo = self:getCurrentPvpBattleInfo()
	if not battleInfo then
		return
	end

	local result = battleInfo.result

	local battleResultData = {
		result = result,
		star = battleInfo.battleStar,
		reward = battleInfo.rewards
	}

	local historyTopRank = battleInfo._historyTopRank 
	--胜利
	if result == Fight.result_win then
		local pvpRankChangeInfo = {
			currentRank = self:getUserRank(),
			rankDelta = math.abs(self.userLastRank - self:getUserRank()), --排名变化
		}
        --//有关历史排名的数据
        local   historyRank={
            historyRank=self.last_pvp_peak_rank,
            rankDelta=self.last_pvp_peak_rank-self:getUserRank(),
        };
        
		if historyTopRank then
			pvpRankChangeInfo.historyTopRank = historyTopRank
			pvpRankChangeInfo.historyTopRankDelta = math.abs(self:pvpPeakRank() - self.last_pvp_peak_rank)
		end
		battleResultData.pvpRankChangeInfo = pvpRankChangeInfo
        battleResultData.historyRank=historyRank;
	end

	if historyTopRank and not battleResultData.rewards then
		local historyTopReward = FuncPvp.getHistoryTopRankReward(tonumber(historyTopRank))
		battleResultData.reward = historyTopReward
	end

	dump(battleResultData, "\n\nbattleResultData===")
	BattleControler:showReward(battleResultData)
end

--更新data数据
function PVPModel:updateData(data)
    self._lastHistoryRank = self:pvpPeakRank()
	for k,v in pairs(data) do
		if k == "pvpPeakRank" then
			self.last_pvp_peak_rank = self:pvpPeakRank()
		end
	end
    PVPModel.super.updateData(self, data)
    --积分兑换发生变化
    if data.exchangeIds ~=nil then
        EventControler:dispatchEvent(PvpEvent.RANK_EXCHANGE_CHANGED_EVENT, data.exchangeIds)
    end
    --积分奖励发生变化
    if data.scoreRewards ~= nil then
        EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_CHANGED_EVENT, data.scoreRewards)
    end
    --积分奖励过期时间
    if data.scoreRewardExpireTime then
        EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_EXPIRE_TIME_CHANGED_EVENT, data.scoreRewardExpireTime)
    end

    --排名奖励发生变化
    if data.rankRewards ~= nil then
        EventControler:dispatchEvent(PvpEvent.RANK_REWARD_CHANGED_EVENT, data.rankRewards)
    end

    if CountModel:getPVPChallengeCount() == 0 then
    	-- echoError("\n\nCountModel:getPVPChallengeCount()===", CountModel:getPVPChallengeCount())
    	self:resetData()
    end

    if data.challengeTimes ~= nil then
    	EventControler:dispatchEvent(PvpEvent.CHALLENGE_TIMES_CHANGED_EVENT, {currentShopId = FuncShop.SHOP_TYPES.PVP_SHOP})
    end
end

function PVPModel:checkNewReport()
	local show = self:hasNewReport()
	-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT, {redPointType=HomeModel.REDPOINT.NAVIGATION.ARENA, isShow = show})
	EventControler:dispatchEvent(PvpEvent.PVPEVENT_PVP_REPORT_RED_POINT, show)
	EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PVP_RED_POINT_UPDATE , show)
end

function PVPModel:hasNewReport()
	return self.new_reports_ids ~= nil
end

function PVPModel:setUserRank(rank)
   if (rank and rank ~= self.userRank) then
	   self.userLastRank = self.userRank or FuncPvp.DEFAULT_RANK
	   self.userRank = rank

	   EventControler:dispatchEvent(PvpEvent.PVP_RANK_CHANGED)
    end
end

function PVPModel:cacheRankList(data)
	self.rank_list = data
end

function PVPModel:getCacheRankList()
	return self.rank_list
end

--获得用户当前的排名
function PVPModel:getUserRank()
	return self.userRank or FuncPvp.DEFAULT_RANK
end

function PVPModel:getHistoryTopRank()
	return self:pvpPeakRank() or FuncPvp.DEFAULT_RANK
end
--获取上次历史最高排名
function PVPModel:getLastHistoryRank()
    return self._lastHistoryRank or FuncPvp.DEFAULT_RANK
end
function PVPModel:onFastRefreshCdEnd()
	self.fast_refresh_count = 0
end

function PVPModel:recordManulRefresh()
	local now = TimeControler:getServerTime()
	local delta = now - self.last_refresh_pvp_time
	if delta < FuncPvp.MIN_REFRESH_INTERVAL then
		self.fast_refresh_count = self.fast_refresh_count + 1
	end
	if self.fast_refresh_count >= 3 then
		return false
	end
	self.last_refresh_pvp_time = now
	return true
end

-- 获得下次购买消费
function PVPModel:getNextBuyCost()
	local buyCost = FuncPvp.getBuyPVPCost()
	return buyCost
end

function PVPModel:composeBattleInfoForReplay(battleData)
    local _attackInfo = json.decode(battleData.attackerInfo)
    local _defenderInfo = json.decode(battleData.defenderInfo)
    if _attackInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _attackInfo = FuncPvp.getRobotDataById(_attackInfo._id)
    end
    if _defenderInfo.userBattleType == FuncPvp.PLAYER_TYPE_ROBOT then
        _defenderInfo = FuncPvp.getRobotDataById(_defenderInfo._id)
    end
	--攻击在前
	local playerCamp = _attackInfo
	playerCamp.rank = battleData.attackerRank
	playerCamp.team = 1
	local enemyCamp = _defenderInfo
	enemyCamp.rank = battleData.defenderRank
	enemyCamp.team = 2
	if enemyCamp.userBattleType == Fight.people_type_robot then
		enemyCamp.name = GameConfig.getLanguage(enemyCamp.name)
		local t = {}
		local enemyTreasures = enemyCamp.treasures
		if #enemyTreasures ~= 0 then
			for _, info in pairs(enemyTreasures) do
				t[info.id] = info
			end
			enemyCamp.treasures = t
		end
	end

	local battleInfo = {
		battleUsers = {
			playerCamp,
			enemyCamp,
		},
		randomSeed = battleData.randomSeed,
		battleId = battleData.battleId,
		gameMode = Fight.gameMode_pvp,
		battleLabel = GameVars.battleLabels.pvp,
	}
	return battleInfo
end

function PVPModel:tryShowBuyPvpView()
	if CountModel:canBuyPVPSn() then	
		local buyCost = PVPModel:getNextBuyCost()
		if UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, buyCost) then
			WindowControler:showWindow("ArenaBuyCountView",FuncPvp.UICountType.BuyCountType)		
		end
	else
        --现在购买次数限制已经解除了,只要有钱就可以购买
--		local maxVipLevel = FuncCommon.getMaxVipLevel()
--		if maxVipLevel >= UserModel:vip() then
--			--local maxBuyTimes = FuncPvp.getPVPMaxBuyTimes()
--			--WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_common_1012", maxBuyTimes))
--			WindowControler:showTips(GameConfig.getLanguage("tid_common_1017")) --  今日已达购买次数上限
--		else
			WindowControler:showWindow("CompVipToChargeView", {tip=GameConfig.getLanguage("tid_pvp_1047"), title="购买次数"})
--		end

	end
end

function PVPModel:setCurrentPvpBattleInfo(info)
	self.currentBattleInfo = info
end

function PVPModel:getCurrentPvpBattleInfo()
	return self.currentBattleInfo
end

function PVPModel:setCurrentReplayBattleData(data)
	self.currentReplayData = data
end

function PVPModel:getCurrentReplayBattleData()
	return self.currentReplayData
end

function PVPModel:clearReplayData()
	self.currentReplayData = nil
end

function PVPModel:reportBattleResultOk(battleResult, serverData)
	EventControler:dispatchEvent(PvpEvent.PVPEVENT_REPORT_RESULT_OK, serverData)
	local data = serverData.result.data
	local result = data.result
	--历史最高排名
	if data.isPeakRank == 1 then
		battleInfo._historyTopRank = data.userRank
	end
--//记录玩家的竞技场排名变化
    self:setUserRank(data.userRank);
	self.server_check_pvp_fight_result = result

	--test 这个事件应该由结果界面dispatch ,目前先放在这里
	--FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD )
end

function PVPModel:getLatestAchievedTitle()
	return self._data.title
end

function PVPModel:onRecordNewTitleOk()
--	EventControler:dispatchEvent(PvpEvent.PVPEVENT_RECORD_NEW_TITLE_OK)
end

--num 得到竞技场机器人排名前几名的玩家
function PVPModel:getTopestRobotByParam(num)
	local retTable = {};
	for i = 1, num do
		local robotInfo = FuncPvp.getRobotById(i);
		table.insert(retTable, robotInfo);
	end
	return retTable;
end

--排名兑换红点是否显示
function PVPModel:isRankRedPointShow(_tag)
    --所有的排名兑换奖励数据
    local _rank_data = FuncPvp.getAllRankExchanges()
    local _now_ranks = PVPModel:getAllRankExchanges() --已经获得的排名兑换数据
    --如果是页签上红点的显示
    if _tag then
    	--当前页签所有的排名兑换奖励数据
	    _rank_data = FuncPvp.getRankExchangesByTag(_tag)
	    --当前页签中已经获得的排名兑换数据
	    _now_ranks = self:getRankExchangesByTag(_tag) 
    end
    
    local _rank = PVPModel:getHistoryTopRank()
    local _real_count = 0
    --兑换时需要花费的资源`
    local _user_money = UserModel:getArenaCoin()
    
    for _key,_value in pairs(_rank_data)do
        local _cost_data = string.split(_value.cost[1],",")
        --没有获取奖励,且满足排名要求,并且金钱足够
        if not _now_ranks[_key] and _rank <= _value.condition and _user_money >= tonumber(_cost_data[2]) then --如果已经达到条件
            _real_count = _real_count + 1
        end
    end	

    if _real_count > 0 then
    	return true;
    else 
    	return false;
    end
end

--积分奖励是否显示红点
function PVPModel:isScoreRewardRedPointShow()
    local _scoreReward = PVPModel:getAllScoreRewards()
    --统计当前在竞技场中已经打过的战斗的数目
    --检测是否还有没有领取的奖励
    local _now_count = CountModel:getPVPChallengeCount()
    --逐个遍历
    local _real_count = 0
    local _integral_score = FuncPvp.getIntegralRewards()
    for _key,_value in pairs(_integral_score) do
        --如果达到了次数限制,并且还没有领取
        if _now_count >= _value.condition and not _scoreReward[_value.id] then
            _real_count = _real_count +1
        end
    end	

    if _real_count > 0 then 
    	return true, _real_count;
    else 
    	return false;
    end 
end

-- 排名奖励是否显示红点
function PVPModel:isRankRewardRedPointShow()
	local rankRewards = FuncPvp.getHistoricalRewards()
	local userRank = PVPModel:getHistoryTopRank()
	local getedRewards = PVPModel:getRankRewards()

	for k,v in pairs(rankRewards) do
		local rankMin = v.rankMin
		local rankMax = v.rankMax

		if userRank >= rankMin and userRank <= rankMax 
			and getedRewards[k] == nil then
			return true
		end
	end

	return false
end

--战斗回放的红点显示
function PVPModel:isReportRedPointShow()
	local show = self:hasNewReport()
	-- return show;
	return false;
end

--挑战次数红点
function PVPModel:isLeftCountRedPointShow()
	--购买的挑战次数
	local buyCount = CountModel:getPVPBuyChallengeCount()
	--已经挑战的次数
	local callengeCount = CountModel:getPVPChallengeCount()
	local firstTime = PVPModel:firstTime()
	local left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
	local cdLeftTime =  FuncPvp.getPvpCdLeftTime() 
	if left > 0 and cdLeftTime == 0 then 
		return true;
	else 
		return false;
	end 
end

function PVPModel:isRedPointShow()
	local isCountRedShow = false --self:isLeftCountRedPointShow();
	local isReportRedPointShow = self:isReportRedPointShow();
	local isScoreRewardRedShow = self:isScoreRewardRedPointShow();
	local isRankRedShow = self:isRankRedPointShow();
	local isHonorRedShow = self:isHonorRedPointShow()

	echo("----isCountRedShow---", tostring(isCountRedShow));
	echo("---isReportRedPointShow----", tostring(isReportRedPointShow));
	echo("---isScoreRewardRedShow----", tostring(isScoreRewardRedShow));
	echo("---isRankRedShow----", tostring(isRankRedShow));
	echo("---isHonorRedShow----", tostring(isHonorRedShow));

	if isReportRedPointShow or isCountRedShow or
			isScoreRewardRedShow or isRankRedShow or isHonorRedShow then 
		return true;
	else 
		return false;
	end

end

function PVPModel:isHonorRedPointShow()
	if self.honorData and self.honorData.type ~= 2 and CountModel:getHonorCountTime() == 0 then
		return true
	end

	return false
end

function PVPModel:getFakeRankExchangeServerData(exgId)
	local reward = FuncPvp.getRankExchange(exgId)["reward"];
	local cost = FuncPvp.getRankExchange(exgId)["cost"];

	local fakeData = FakeServerDataHelper:createFakeData(reward, cost);

	fakeData["pvpExt"] = {};
	fakeData["pvpExt"]["exchangeIds"] = {};
	fakeData["pvpExt"]["exchangeIds"][tostring(exgId)] = tostring(exgId);

	local ret = {
		u = fakeData,
	};

	return ret;
end

function PVPModel:getFakeScoreRewardServerData(scoreIds)
	local packReward = {};
	for _, v in pairs(scoreIds) do
		local reward = 
			FuncPvp.getIntegralRewradData(tostring(v))["reward"];
		table.insert(packReward, reward);
	end

	local fakeData = FakeServerDataHelper:packFakeData(packReward);
	local fakeIds = {};
	for k,v in pairs(scoreIds) do
		fakeIds[v] = v;
	end
	fakeData["pvpExt"] = {};
	fakeData["pvpExt"]["scoreRewards"] = fakeIds;

	local ret = {
		u = fakeData,
	};

	return ret;
end

-- function PVPModel:disptchRefreshEvent(data)
--     local todayRefreshStamp = self:scoreRewardExpireTime()
--     local expireTimes = todayRefreshStamp - self.initTime
--     echo("\n\nexpireTimes", expireTimes)
--     if tonumber(expireTimes) > 0 then
--     	TimeControler:startOneCd(TimeEvent.TIMEEVENT_ARENA_SCOREREWARD_REFRESH_EVENT, expireTimes)
--         -- WindowControler:globalDelayCall(function ()
--         --         echo("\n\n\n------------------发送消息-------------------") 
--         --         self._data.scoreRewards = {}
--         --         EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_REFRESH_EVENT)
--         --         end, expireTimes)
--     end        
-- end

function PVPModel:resetData()
	echo("\n\n\n------------------发送重置奖励数据消息-------------------") 
	self._data.scoreRewards = {}
	-- 发送消息刷新界面
	EventControler:dispatchEvent(PvpEvent.SCORE_REWARD_REFRESH_EVENT)
	-- 刷新时间到了 需要通知布阵界面更新buff数据
	EventControler:dispatchEvent(PvpEvent.PVP_BUFF_REFRESH_EVENT)
end

function PVPModel:setForceRefresh(_bool)
	if _bool == nil then
		_bool = false
	end
	self.forceRefresh = _bool
end

function PVPModel:getForceRefresh()
	return self.forceRefresh
end

--设置扫荡后刷新的状态 true为不回到前三名的状态
function PVPModel:setRefreshType(_type)
	self.refreshType = _type
end

function PVPModel:getRefreshType()
	return self.refreshType
end

function  PVPModel:getBuffIdByServerTime()
	local serverInfo = LoginControler:getServerInfo()
	local openTime = serverInfo.openTime
	local openRefreshTime = self:getNextMondayRefreshTime(openTime)
	local currentTime = TimeControler:getServerTime()
	local nextRefreshTime = self:getNextMondayRefreshTime(currentTime)
	local buffOrder = math.floor((nextRefreshTime - openRefreshTime) / (7 * 86400)) + 1
	buffOrder = buffOrder % FuncPvp.getBuffOrderLength()
	if buffOrder == 0 then
	 	buffOrder = FuncPvp.getBuffOrderLength()
	end 
	local buffId = FuncPvp.getBuffIdByOrder(buffOrder)
	return buffId
end

function PVPModel:getNextMondayRefreshTime(_time)	
	local time = _time
	local date_info = os.date("*t", time)
	-- echo("\n\n_time===", _time)
	-- dump(date_info, "\n\ndate_info")
    -- local year = tonumber(os.date("%Y",time))
    -- local month = os.date("%m",time)
    -- local day = os.date("%d",time)
    local hour = date_info.hour
    local wday = date_info.wday
    local returnsecond = 0
    date_info.hour = 4
	date_info.min = 0
	date_info.sec = 0
	local time_refresh  = os.time(date_info)
	if wday == 1 then
		returnsecond = time_refresh + (2 - wday) * 86400
    elseif wday == 2 and hour < 4 then
    	returnsecond = time_refresh      
    else    	
        returnsecond =  time_refresh + (9 - wday) * 86400
    end
    -- echo("\n\nreturnsecond==", returnsecond)
    -- dump(os.date("*t", returnsecond), "\n\nreturnsecond")
    return returnsecond
end

function PVPModel:setHonorData(data)	
	self.honorData = data
end

function PVPModel:getHonorData()
	return self.honorData
end

-- 获取历史排名奖品数据
function PVPModel:getSortedRankRewards()
	if self.sortedHistoricalRewards then
		return self.sortedHistoricalRewards
	end

	local rewards = {}

	local tempRewards = FuncPvp.getHistoricalRewards()
	local keys = {}

	for k,v in pairs(tempRewards) do
		keys[#keys+1] = k
	end

	table.sort(keys, function (a,b)
		return tonumber(a) > tonumber(b)
	end)

	dump(keys,"keys--------------")

	for i=1,#keys do
		rewards[#rewards+1] = tempRewards[keys[i]]
	end

	self.sortedHistoricalRewards = rewards

	return rewards
end

return PVPModel



















