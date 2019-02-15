-- ArtifactServer
--神器发送到服务器
local ArtifactServer = class("ArtifactServer")

---神器抽奖购买发送协议
function ArtifactServer:LotteryBuyOneAndFive(params, callBack)
	Server:sendRequest(params,MethodCode.cimelia_lottery_5305, callBack)
end
---神器单件进阶发送协议
function ArtifactServer:SingleAdvanced(params, callBack)
	Server:sendRequest(params,MethodCode.cimelia_cimeliaUpgrade_5301, callBack)
end
---神器组合进阶发送协议
function ArtifactServer:CombinationAdvanced(params, callBack)
	Server:sendRequest(params,MethodCode.cimelia_cimeliaGroupUpgrade_5303, callBack)
end
---神器分解发送协议
function ArtifactServer:decompositionSever(params, callBack)
	Server:sendRequest(params,MethodCode.cimelia_decompose_5307, callBack)
end

return ArtifactServer




