--
-- Author: ZhangYanguang
-- Date: 2015-12-25
--
--排行榜系统，网络服务类

local RankServer = class("RankServer")

-- 获取排名数据
function RankServer:getRankList(rankType,beginRank,endRank,callBack)
	local params = {
		type = rankType,
		rank = beginRank,
		rankEnd = endRank,
	}
	Server:sendRequest(params,MethodCode.rank_getRankList_1701, callBack )
end

-- 根据玩家id获取玩家信息
function RankServer:getPlayInfo(playerId,callBack)
	local params = {
		id = playerId,
	}
	Server:sendRequest(params,MethodCode.rank_getPlayerInfo_1703, callBack )
end

-- 根据公会id获取公会信息
function RankServer:getGuildInfo(guildId,callBack)
	local params = {
		id = guildId,
	}
	Server:sendRequest(params,MethodCode.rank_getGuildInfo_1705, callBack,false,false,true)
end

return RankServer
