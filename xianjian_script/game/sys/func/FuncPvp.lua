--
-- Author: ZhangYanguang
-- Date: 2015-12-18
-- PVP相关数据表功能类

FuncPvp= FuncPvp or {}

FuncPvp.PVP_CD_LEVEL = 50
FuncPvp.PVP_CD_ID = {1, 2}
--弹出购买次数框UI类型
FuncPvp.UICountType = {
    BuyCountType = 1,--购买次数UI类型
    Challenge5Times = 2,--挑战5次UI类型
}
--最初进入竞技场的排名
FuncPvp.DEFAULT_RANK = 10001
--角色槽位的属性值
FuncPvp.ONESELE_VALUE = "1" --代表着角色自身
FuncPvp.INVALIDE_VALUE = "0" --代表着一个无效的值,该槽位代表着没有任何的东西占据着
--PVP战斗结果
FuncPvp.PVP_BATTLE_RESULT_WIN = 1 --赢了
FuncPvp.PVP_BATTLE_RESULT_FAILED = 2 --输了
--机器人
FuncPvp.PLAYER_TYPE_ROBOT = 2
--关于竞技场机器人的配置属性 down:为区间的起始rid,up为区间的上确界rid
FuncPvp.RobotAttr = {
    [1] = {
        down = 101,up =200, length =100,
    },
    [2] = {
        down=201,up = 500, length = 10,
    },
    [3] = {
        down = 501, up = 1000, length = 15,
    },
    [4] ={
        down = 1001,up = 2000, length =20,
    },
    [5] = {
        down=2001,up =5000,length = 25,
    },
    [6] ={
        down =5001,up =12000,length =30,
    },
}
FuncPvp.SHOW_SELF_MIN_RANK = 4
FuncPvp.MIN_REFRESH_INTERVAL = 3 --最小手动刷新间隔
FuncPvp.REFRESH_TO_FAST_CD = 30 --手动刷新过快之后的cd
FuncPvp.REFRESH_BTN_SHOW_MIN_LEVEL=11

local config_rank_reward = nil
local history_reward_ids = nil --历史最高排名奖励的id
--//PVP奖励
local  pvpRewardTable=nil;
local  _pvp_rank_reward 
local  _pvp_robot_datas --pvp机器人表
local _pvp_historical_reward = nil

--config/pvp/RankExchange.csv
--积分奖励
local _pvp_integral_reward 
-- config/pvp/BuyPvp
local _pvp_buy_pvp = nil
local config_pvp_buff_order = nil
local config_pvp_buff = nil
--根据配置过滤出来的排名区间表
local sortedRewardListByRankRange = {}
local maxRewardRank = 0

local sortByRank = function(a, b)
	return tonumber(a.rank) < tonumber(b.rank)
end

local sortByRankDesc = function(a, b)
	return tonumber(a.rank) > tonumber(b.rank)
end

local sortByCondition = function(a, b)
	return a.condition < b.condition
end

FuncPvp.FIGHT_ATTRS = {
	hp = "血量",
	atk = "攻击",
	def = "防御",
	crit = "暴击",
	resist = "免爆",
	dodge = "闪避",
	hit = "命中",
	critR = "暴倍"
}

function FuncPvp.init()
    pvpRewardTable=Tool:configRequire("pvp.PvpReward");
	config_rank_reward = Tool:configRequire("pvp.RankReward")
	config_pvp_talk = Tool:configRequire('pvp.PvpTalk')
	config_pvp_history_rank_reward = Tool:configRequire('pvp.HistoricalRank')
    _pvp_rank_reward = Tool:configRequire("pvp.RankExchange")
    _pvp_integral_reward = Tool:configRequire("pvp.IntegralReward")
    _pvp_robot_datas = Tool:configRequire("robot.PvpRobot")
    _pvp_buy_pvp = Tool:configRequire("pvp.BuyPvp")
    _pvp_historical_reward = Tool:configRequire("pvp.HistoricalReward")

    config_pvp_buff_order = Tool:configRequire("pvp.PvpBuffOrder")
    config_pvp_buff = Tool:configRequire("pvp.PvpBuff")

	history_reward_ids = table.sortedKeys(config_pvp_history_rank_reward, sortByRankDesc) 
end
--给定一个rid,生成相关的rid机器人
function FuncPvp.genRobotRid( _rid)
    local _now_rid= tonumber(_rid)
    local _new_rid =_now_rid
    for _index =1, # FuncPvp.RobotAttr do
        local _robot_interval = FuncPvp.RobotAttr[_index]
        if _now_rid>= _robot_interval.down and _now_rid <= _robot_interval.up then
            _new_rid = _robot_interval.down + _now_rid % _robot_interval.length
            break
        end
    end
    return tostring(_new_rid)
end
--所有的机器人表
function FuncPvp.getRobotById(_robotId)
    local _robotData  = _pvp_robot_datas[tostring(_robotId)]
    if not _robotData then
        echo("Warning!!!,---get robot data error,robot id is:",_robotId)
    end
    return _robotData
end
--获取所有的积分奖励项
function FuncPvp.getIntegralRewards()
    return _pvp_integral_reward
end

-- 获取历史排名奖励项目
function FuncPvp.getHistoricalRewards()
	return _pvp_historical_reward
end

--获取所有的积分奖励最大ID
function FuncPvp.getMaxIntegralId()
	local maxId = nil
	for k,v in pairs(_pvp_integral_reward) do
		if not maxId then
			maxId = k
		elseif tonumber(k) > tonumber(maxId) then
			maxId = k
		end
	end

	return maxId
end

--获取积分奖励中的某一项
function FuncPvp.getIntegralRewradData(_rewardId)
    local _reward_item = _pvp_integral_reward[tostring(_rewardId)]
    if not _reward_item then
        echo("Warning !!!,FuncPvp.getIntegralRewradData error :",_rewardId)
    end
    return _reward_item
end
--通过挑战次数获取积分奖励需要展示的物品
function FuncPvp.getIntegralRewardDisplayByCount(_count)
	local _reward_item = _pvp_integral_reward[tostring(_count)]
	if not _reward_item then
        echo("Warning !!!,FuncPvp.getIntegralRewradData error :",_rewardId)
    end
    return _reward_item.rewardDis
end

function FuncPvp.getPvpReward()
  return pvpRewardTable
end

--获取所有的排名奖励
function FuncPvp.getAllRankExchanges()
    return _pvp_rank_reward
end
--获取某一页签对应的排名奖励数据
function FuncPvp.getRankExchangesByTag(_tag)
	local allRankExchanges = FuncPvp.getAllRankExchanges()
	local table_rank = {}
	for k,v in pairs(allRankExchanges) do
		if tonumber(v.select) == tonumber(_tag) then
			table_rank[tostring(k)] = v
		end
	end
	return table_rank
end

--获取指定的排名兑换
function FuncPvp.getRankExchange( _rank_id)
    local _exchg_info = _pvp_rank_reward[tostring(_rank_id)]
    if not _exchg_info then
        echo("Warning ,-------FuncPvp.getRankExchange------error,input id is illegal,--->",_rank_id)
    end
    return _exchg_info
end

--通过历史最高排名获取下一阶段可以兑换的id
function FuncPvp.getNextExchangeIdByRnak(_rank)
	local rank_reward_length = table.length(_pvp_rank_reward)

	if tonumber(_rank) ==  1 then
		local next_id = rank_reward_length
		return next_id
	end
	for i = 1, rank_reward_length - 1, 1 do
		local _exchg_info1 = _pvp_rank_reward[tostring(i)]
		local _exchg_info2 = _pvp_rank_reward[tostring(i + 1)]
		if i == 1 and tonumber(_rank) > tonumber(_exchg_info1.condition) then
			local next_id = i
			return next_id
		elseif tonumber(_rank) <= tonumber(_exchg_info1.condition)  
			and tonumber(_rank) > tonumber(_exchg_info2.condition) then
			local next_id = i + 1
			return next_id
		end
	end
end

function FuncPvp.getRankRewardData()
    return config_rank_reward
end

-- 获取排名区间奖励
function FuncPvp.getRankReward()
	if next(sortedRewardListByRankRange) ~= nil then
		--只排序一次
		return sortedRewardListByRankRange
	end

	local rewardList = {}
	local rewardData = config_rank_reward
	local lastRank = nil
	local keys = {}

	local keys = table.sortedKeys(rewardData, sortByRank)
	maxRewardRank = rewardData[keys[#keys]].rank
	
	for i=1,#keys do
		local key = keys[i]
		local v = rewardData[key]
		local info = {}
		local rank = v.rank
		info.reward = v.reward
		if lastRank == nil then
			info.rank = rank
		else
			if tonumber(rank) - tonumber(lastRank) == 1 then
				info.rank = rank
			else
				info.rank = (lastRank + 1) .. "~" .. rank
			end
		end

		table.insert(rewardList, info)
		lastRank = rank
	end

	sortedRewardListByRankRange = rewardList
	return rewardList
end

-- 根据排名，获取奖励
function FuncPvp.getRewardByRank(targetRank)
	if targetRank == nil then
		echoError("FuncPvp.getRewardByRank targetRank is nil")
		return
	end
	targetRank = tonumber(targetRank)
	if targetRank > maxRewardRank then
		return 
	end

	local rewardList = {}
	local rewardData = FuncPvp.getRankRewardData()

	local keys = table.sortedKeys(rewardData, sortByRank)

	local preRank = -1
	local reward = nil
	for i,k in ipairs(keys) do
		local info = rewardData[k]
		if targetRank > preRank and targetRank <=info.rank then
			reward = info.reward
			break
		else
			preRank = info.rank
		end
	end
	return reward
end

-- 根据第几次购买获取购买花费
function FuncPvp.getBuyPVPCost()
    local _challenge_count = CountModel:getPVPBuyChallengeCount()
	local num = FuncPvp.getBuyTimesCost(_challenge_count,1)--FuncDataSetting.getDataByConstantName("ArenaBuyCost") or 0
	return num
end

function FuncPvp.getPVPChallengeMaxCount()
	return FuncDataSetting.getDataByConstantName("PvpFightNum") or 1
end

function FuncPvp.getPVPMaxBuyTimes()
	local vipLevel = UserModel:vip()
	return FuncCommon.getPVPBuyCount(vipLevel)
end

function FuncPvp.getMaxRewardRank()
	return maxRewardRank
end

-- 排行榜中玩家的信息
function FuncPvp.getPlayerRankInfo(rank)
	--TODO player 的avatar
	local ret = {
		ability = UserModel:getAbility(),
		avatar= UserModel:avatar(),
		state=1,
		name = UserModel:name(),
		rank = rank, 
		rid = UserModel:rid(),
		garmentId = UserExtModel:garmentId()
 --       pvpTreasureNatal = NatalModel:getNatalTreasure()["3"];
	}

	return ret
end

--[[
-- 格式化pvp战斗时间
格式化规则：
2) 不足1小时，显示：x分钟前
3) 不足天，显示：x小时前
4) 超过天，显示：x天前
]]
function FuncPvp.formatPvpBattleTime(seconds)
	local minuteSeconds = 60
	local hourSeconds = 60 * minuteSeconds
	local daySeconds = 24 * hourSeconds

	local isInvalid = false
	local battleTimeStr = ""
	if seconds < hourSeconds then
		local minute = seconds / 60
		if minute < 1 then
			minute = 1
		end
		battleTimeStr = GameConfig.getLanguageWithSwap("tid_pvp_1005", math.floor(minute))
	elseif seconds < daySeconds then
		local hour = seconds / hourSeconds
		battleTimeStr = GameConfig.getLanguageWithSwap("tid_pvp_1006", math.floor(hour))
	else
		local day = seconds / daySeconds
		battleTimeStr = GameConfig.getLanguageWithSwap("tid_pvp_1007", math.floor(day))
		if math.floor(day) >= 7 then
			isInvalid = true
		end
	end

	return battleTimeStr, isInvalid
end

function FuncPvp.getClearCdCost(leftCd)
	local level = UserModel:level()
	local cost = FuncCommon.getCdCostById(tostring(FuncPvp.PVP_CD_ID[1]), leftCd)
	if level >= FuncPvp.PVP_CD_LEVEL then
		cost = FuncCommon.getCdCostById(tostring(FuncPvp.PVP_CD_ID[2]), leftCd)
	end
	return cost
end

-- 获取PVP cd时间
function FuncPvp.getPVPConfigCdTime()
	local level = UserModel:level()
	local cdSecond = FuncCommon.getCdTimeById(FuncPvp.PVP_CD_ID[1])
	if tonumber(level) >= FuncPvp.PVP_CD_LEVEL then
		cdSecond = FuncCommon.getCdTimeById(FuncPvp.PVP_CD_ID[2])
	end
	return cdSecond
end

function FuncPvp.getPvpCdLeftTime()
	local _user_vip = UserModel:vip()
    --使用新版本的计时器
	--local cdId = CdModel.CD_ID.CD_ID_PVP_NEW_TIMER
--[[	local eventKey = "CD_ID_PVP_DOWN_LEVEL"
	if tonumber(level) >= FuncPvp.PVP_CD_LEVEL then
		cdId = CdModel.CD_ID.PVP_UP_LEVEL
		eventKey = "CD_ID_PVP_UP_LEVEL"
	end
	local left = TimeControler:getCdLeftime(eventKey)
	if left < 0 then left = 0 end
	return left]]
    local _now_cdId = CdModel.CD_ID_PVP_UP_LEVEL
    if(_user_vip<6)then
        local   left=TimeControler:getCdLeftime("CD_ID_PVP_UP_LEVEL");
        left =  left<0 and 0 or left;
        return  left;
    end
    return 0;
end

function FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
	local max = FuncPvp.getPVPChallengeMaxCount()
	local currentTime = TimeControler:getServerTime()
	local oneDay = 24 * 60 * 60
	if firstTime == 0 then
		max = max + 1
	else
		local firstRefreshTime = FuncPvp.getRefreshTime(firstTime)
		if tonumber(currentTime) < tonumber(firstRefreshTime) then
			max = max + 1
		end
	end
	--每日免费-已经挑战的次数+购买的挑战次数
	local left = max - callengeCount + buyCount
	if left <=0 then left = 0 end
	return left
end

function FuncPvp.getRefreshTime(firstTime)
	-- 处理四点刷新的事
    local dates = os.date("*t", firstTime)
    -- 每天几点几分刷新    
    local targetH = FuncCount.getHour(FuncCount.COUNT_TYPE.COUNT_TYPE_PVPCHALLENGE)
    local targetM = FuncCount.getMinute(FuncCount.COUNT_TYPE.COUNT_TYPE_PVPCHALLENGE) or 0
    targetH = tonumber(targetH)
    targetM = tonumber(targetM)

    local oneDay = 24 * 60 * 60
    -- 当天对应时间的时间戳
    local todayTargetStamp = os.time({year=dates.year, month=dates.month, day=dates.day, hour=targetH, min = targetM})
    if tostring(firstTime) > tostring(todayTargetStamp) then
    	todayTargetStamp = todayTargetStamp + oneDay
    end
    return todayTargetStamp
end

function FuncPvp.canChallengeTop3(userRank, targetRank)
	targetRank = tonumber(targetRank)
	userRank = tonumber(userRank)
	if targetRank <= 3 then
		if userRank > 10 then 
			return false
		end
	end
	return true
end

function FuncPvp.getRandomTalk(rank)
	local max = 10
	rank = tonumber(rank)
	local keys = table.keys(config_pvp_talk)
	local randomseed = RandomControl.getOneRandomInt(os.time(),1)
	table.shuffle(keys, randomseed)
	local tid
	local count = 0
	--先随机获取
	for _, id in pairs(keys) do
		if count > max then
			break
		end
		local oneInfo = config_pvp_talk[id]
		local section = oneInfo.section
		if rank >= section[1] and rank <= section[2] then
			tid = oneInfo.tid
			break
		end
		count = count + 1
	end
	--没有随机到
	if not tid then
		for id, info in pairs(config_pvp_talk) do
			local section = info.section
			if rank >= section[1] and rank <= section[2] then
				tid = info.tid
				break
			end
		end
	end
	return GameConfig.getLanguage(tid)
end

function FuncPvp.getHistoryTopRankReward(historyTopRank)
	local config = config_pvp_history_rank_reward
	local rewards = nil
	for _, id in ipairs(history_reward_ids) do
		local info = config[id]
		if not info then break end
		local rank = info.rank
		if tonumber(historyTopRank) > rank then
			break
		end
		rewards = info.reward
	end
	return rewards
end
--档给定的对手玩家的排名比角色当前的排名较低时,连续挑战5次需要的花费
function FuncPvp.getChallenge5TimesCost()
    --挑战次数
    --购买的挑战次数
	local buyCount = CountModel:getPVPBuyChallengeCount()
	--已经挑战的次数
	local callengeCount = CountModel:getPVPChallengeCount()
	local firstTime = PVPModel:firstTime()
	local _own_count = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime) --剩余的挑战次数
    local _cool_down_cost = FuncCommon.getCdCostById("2") --获取冷却一次需要的花费
    local _need_cost = 0
    local _cd_times = _own_count > 0 and _own_count or 1
 --   local _every_buy_cost = FuncDataSetting.getDataByConstantName("ArenaBuyCost")
    if 5 >= _own_count then
        --如果是VIP6,则没有cd
        if UserModel:vip() >= 6 then 
            _cool_down_cost = 0
        end
        local _total_challenge_times = CountModel:getPVPBuyChallengeCount() --已经购买的次数
        _need_cost = (_cd_times-1) * _cool_down_cost +  FuncPvp.getBuyTimesCost(_total_challenge_times, 5 - _own_count) 
    end
    --另外,如果玩家目前处于CD中,则需要累加一次CD花费,目前已经加上了
    local _time_left = FuncPvp.getPvpCdLeftTime()
    if _time_left > 0 then
        _need_cost = _need_cost + _cool_down_cost
    end
    return _need_cost
end

function FuncPvp.getChallengeOneTimesCost(_buyTimes)
	--挑战次数
    --购买的挑战次数
	local buyCount = CountModel:getPVPBuyChallengeCount()
	--已经挑战的次数
	local callengeCount = CountModel:getPVPChallengeCount()
	local firstTime = PVPModel:firstTime()
	local _own_count = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime) --剩余的挑战次数
	local _need_cost = 0
	if _own_count > 0 then
		_need_cost = 0
	else
		_need_cost = FuncPvp.getBuyTimesCost(_buyTimes, 1)
	end
 	
 	return _need_cost
end

--购买N次需要的花费
--_base_times:已经购买的次数
--_now_times:需要购买的次数
function FuncPvp.getBuyTimesCost(_base_times,_now_times)
    local _total_cost = 0
    for _index = 1, _now_times do
        local _now_time = _base_times + _index
        _total_cost = _total_cost + FuncPvp.getPvpChallengeBuyCost(_now_time)
    end
    return _total_cost
end
--当竞技场挑战到底N次的时候,获取购买一次需要的花费
function FuncPvp.getPvpChallengeBuyCost( _times)
    local _cost_item = _pvp_buy_pvp[tostring(_times)]
    if not _cost_item then
        _cost_item = _pvp_buy_pvp["0"]
    end
    return _cost_item.cost
end
--竞技场挑战,调用这个函数之前,一定要先判断挑战次数是否足够
--否则会报错
--_playerInfo 为竞技场中竞争对手的详细信息,这个不需要自己构造
function FuncPvp.onChallengePlayerEvent(_playerInfo,formation,_callback)
    --构建数据结构
    --local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
    local _user_formation = table.deepCopy(formation)
    local energy = FuncTeamFormation.filterPvpFormation(_user_formation)
    _user_formation.energy = energy
    local _formation = {
        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
        energy = table.deepCopy(_user_formation.energy),
    }
    local _param = {
        opponentRid = _playerInfo.rid_back,   --对手的rid
        opponentRank = _playerInfo.rank ,       --对手的排名
        userRank = PVPModel:getUserRank(), --玩家自己的排名
        formation = _formation,                        --玩家自己的PVP阵列
    }
   	-- dump(_param,"---_param----")
	if TimeControler:getCdLeftime("CD_ID_PVP_UP_LEVEL") > 0 then
		WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1041"))
	else
		PVPServer:requestChallenge(_param,_callback)
	end
    
end
--关于竞技场挑战对手返回的数据的错误进行处理
--调用函数的前提是_event.error ~= nil
function FuncPvp.processChallengeErrorEvent(_event)
    if not _event.error then
        local _resultData = _event.result.data
        _resultData.historyRank = PVPModel:getLastHistoryRank() --玩家上次自己的历史最高排名
        return false
    end
    local _error = _event.error
	--战斗异常1.对手正在战斗 2. 对手排名变化 3 玩家排名变化
	local code_white_list = {110501, 110502, 110506}
    if _error.message=="user_pvprank_changed" then --对方排名发生了变化
        WindowControler:showTips(GameConfig.getLanguage("pvp_self_rank_changed_1001"));
    elseif _error.message=="opponent_rank_have_changed" then --自己的排名发生了变化
            WindowControler:showTip(GameConfig.getLanguage("pvp_enemy_rank_change_1002"));
    elseif _error.message == "opponent_in_challenge" then --对手正在处于挑战中
            WindowControler:showTips(GameConfig.getLanguage("pvp_enemy_fall_changing_1003"));
	end
    return true
end
--调用前提,给定的机器人ID是服务器传过来的
--这个ID可以通过 FuncPvp.genRobotId生成
function FuncPvp.getRobotDataById(_robot_id)
    local _rid = FuncPvp.genRobotRid(_robot_id)
   --读取表格 config/robot/
    local _robot_item = FuncPvp.getRobotById(_rid)
    --所携带的法宝,以及和法宝相关的槽位
    local _treasureInfos = {
    }
    local _treasureFormation = {}
    for _key,_value in pairs( _robot_item.treasures) do
        _treasureInfos[tostring(_value.id)] = _value
        if table.length(_treasureFormation) < 2 then
            _treasureFormation["p"..(table.length(_treasureFormation)+1)] = tostring(_value.id)
        end
    end
    --伙伴以及伙伴的阵型
    local _partners = {
    }
    local _partnerFormation={}
    for _index=1,6 do
        local _partnerInfo = _robot_item["showPart".._index]
        if _partnerInfo ~=nil then
            _partners[_partnerInfo[1] ] ={
                id = tonumber(_partnerInfo[1]),
                level = tonumber(_partnerInfo[2]),
                star = tonumber(_partnerInfo[3]),
                quality = tonumber(_partnerInfo[4]),
                position = 0
            }
            _partnerFormation["p".._index] = _partnerInfo[1]
        end
    end
    --有关伙伴,法宝的槽位
    local _formations ={
        partnerFormation = _partnerFormation,
        treasureFormation = _treasureFormation,
    }
    local _char_item = FuncChar.getHeroData(_robot_item.avatar)
    --数据的整合
    local _playerInfo = {
        rid = _rid,
        name = FuncAccountUtil.getRobotName(_rid, _robot_id),
        level = _robot_item.lv,
        avatar = _robot_item.avatar,
        ability = _robot_item.ability,
        vip = 0,    --vip统一为0
        guildName = "",--没有公会名字
        charPos = _robot_item.charPos,
        garmentId = _robot_item.garmentId or "",
        treasures = _treasureInfos,
        partners = _partners,
        formation = _formations,
        userBattleType = FuncPvp.PLAYER_TYPE_ROBOT,
        _id = _robot_id
    }
    return _playerInfo
end


-- TODO 需要重构调用主角系统提供的方法
function FuncPvp.getCharSpine(avatar)
	local charSpine = nil
	if tonumber(avatar) == 101 then
		charSpine = ViewSpine.new("art_treasure_a1")
	elseif tonumber(avatar) == 104 then
		charSpine = ViewSpine.new("art_treasure_b1")
	end

	charSpine:playLabel("stand_login",true)
	return charSpine
end

function FuncPvp.getBuffOrderLength()
	return table.length(config_pvp_buff_order)
end

function FuncPvp.getBuffIdByOrder(_order)
	return config_pvp_buff_order[tostring(_order)].buffId
end

function FuncPvp.getBuffDataByBuffId(_buffId)
	local buffData = config_pvp_buff[tostring(_buffId)]
	if not buffData then
		echoError("This Buff not exit buffId===", _buffId)
	end
	return buffData
end

--通过pvpBuff数据获取当前有加成的tags
function FuncPvp.getBuffTagsByBuffData(_buffData)
	local buffData = _buffData
	local pvpBuffTags = {}
	if buffData.attackTeam then
		for i,v in ipairs(buffData.attackTeam) do
			table.insert(pvpBuffTags, v)
		end
	end

	if buffData.defendTeam then
		for i,v in ipairs(buffData.defendTeam) do
			if not FuncPvp.isInTable(pvpBuffTags, v) then
				table.insert(pvpBuffTags, v)
			end			
		end
	end

	return pvpBuffTags
end

function FuncPvp.isInTable(_table, _item)
	for i,v in ipairs(_table) do
		if v.key == _item.key and v.value == _item.value then
			return true
		end
	end
	return false
end

--通过pvpBuff数据获取当前有加成的特定奇侠
function FuncPvp.getBuffPartnersByBuffData(_buffData)
	local buffData = _buffData
	local pvpBuffPartners = {}
	if buffData.attackPatnerProperty then
		for i,v in ipairs(buffData.attackPatnerProperty) do
			table.insert(pvpBuffPartners, v.patner)
		end
	end

	if buffData.defendPatnerProperty then
		for i,v in ipairs(buffData.defendPatnerProperty) do
			if not table.indexof(pvpBuffPartners, v.patner) then
				table.insert(pvpBuffPartners, v.patner)
			end			
		end
	end

	return pvpBuffPartners

end
