-- WonderlandServer
--须臾仙境发送到服务器
local WonderlandServer = class("WonderlandServer")

--挑战
function WonderlandServer:challengeWonderLand(params, callBack)

	Server:sendRequest(params,MethodCode.challenge_WonderLand_5801, callBack)
end

--完成挑战
function WonderlandServer:finishWonderLand(params, callBack)
	Server:sendRequest(params,MethodCode.finish_WonderLand_5803, callBack)
end

---扫荡
function WonderlandServer:sweepWonderLand(params, callBack)
	Server:sendRequest(params,MethodCode.sweep_WonderLand_5805, callBack)
end
---排行榜
function WonderlandServer:getPowerLuRenData(params,callBack)
	Server:sendRequest(params, MethodCode.rank_getRankList_1701, callBack);
end


return WonderlandServer
