--
-- Author: ZhangYanguang
-- Date: 2015-12-18
--
--竞技场模块，网络服务类

local PVPServer = class("PVPServer")

--初始化
function PVPServer:init(  )
end

-- 购买PVP挑战次数
function PVPServer:buyPVP(callBack)
	local params = {}
	Server:sendRequest(params, MethodCode.pvp_buyPVP_1101, callBack,nil,nil,true )
end

-- 刷新PVP数据
function PVPServer:refreshPVP(callBack)
	local params = {
	}
	Server:sendRequest(params,MethodCode.pvp_refreshPVP_1103, callBack )
end

-- 开始pvp战斗
-- 返回数据：玩家法宝等数据及匹配敌方战斗属性和法宝数据
function PVPServer:startChallenge(rid, rank, callBack)
	local params = {
		opponentInfo = {
			rid = rid,
			rank = rank
		},
		userRank = PVPModel:getUserRank(),
	}
	Server:sendRequest(params,MethodCode.pvp_startChallenge_1105, callBack, nil, nil, true)
end

--[[
汇报战斗结果
battleResult:战斗结果:1,胜利；2，失败
battleId:pvp战斗id 
--userInfo:用户信息,用于校验
opponentInfo:对手信息,用于校验
battleInfo:战斗信息(法宝序列)
]]
function PVPServer:reportBattleResult(params, callBack)
	Server:sendRequest(params, MethodCode.pvp_reportBattleResult_1107, callBack )
end

-- 拉取战斗记录
function PVPServer:pullBattleRecord(callBack)
	local params = {}
	Server:sendRequest(params,MethodCode.pvp_pullBattleRecord_1109, callBack,nil,nil,true)
end

--记录获得的最高称号
function PVPServer:recordTitle(titleId, callBack)
	local params = {title = titleId}
	Server:sendRequest(params, MethodCode.pvp_recordTitle_1117, callBack)
end


--竞技场排名兑换
function PVPServer:requestRankExchange( _exgId, func)
    Server:sendRequest({exchangeId = _exgId},
    	MethodCode.pvp_rank_exchange_1127, func, nil, nil, true)

    -- local fakeData = PVPModel:getFakeRankExchangeServerData(_exgId);
    -- -- dump(fakeData, "-----_exgId----");
    -- Server:updateBaseData(fakeData);

    -- func();
end

--竞技场积分奖励
function PVPServer:requestScoreReward(_param,func)
	-- echo("-----requestScoreReward----");
 
 --    Server:sendRequest(_param,MethodCode.pvp_score_reward_1129, nil, true, true, true);

 --    local fakeData = PVPModel:getFakeScoreRewardServerData(_param.scoreIds);

 --    Server:updateBaseData(fakeData);

 --    func();
     Server:sendRequest(_param,MethodCode.pvp_score_reward_1129,func,nil,nil,true)
end

--竞技场排名奖励
function PVPServer:requestRankReward(_param,func)
	Server:sendRequest(_param,MethodCode.pvp_rank_reward_1131,func,nil,nil,true)
end

--查看角色的详情
function PVPServer:requestPlayerDetail(_playerId,_func )
    Server:sendRequest({opponentRid = _playerId},MethodCode.pvp_player_detail_1119,_func,nil,nil,true)
end
--挑战5次
function PVPServer:requestChallenge5Times(_param,_func)
    Server:sendRequest(_param,MethodCode.pvp_challenge5_times_1123,_func,nil,nil,true)
end
--挑战对手
function PVPServer:requestChallenge(_param,_func)
    Server:sendRequest(_param,MethodCode.pvp_challenge_player_1121,_func,nil,nil,true)
end
--获取战报详情
function PVPServer:requestPVPreport(_reportId,_func)
    Server:sendRequest({reportId = _reportId},MethodCode.pvp_get_pvp_report_1125,_func,nil,nil,true)
end
PVPServer:init()
return PVPServer

