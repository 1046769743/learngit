

local RechargeServer = class("RechargeServer")

function RechargeServer:recharge(productId, callBack)
	local params = {
		productId = productId
	}
    Server:sendRequest(params,
        MethodCode.recharge_2205, callBack);
end

return RechargeServer











