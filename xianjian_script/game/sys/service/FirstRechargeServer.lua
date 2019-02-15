

local FirstRechargeServer = class("FirstRechargeServer")

function FirstRechargeServer:getReward(callBack)
	local params = {

	}
    Server:sendRequest(params,
        MethodCode.get_recharge_reward_341, callBack);
end

return FirstRechargeServer











