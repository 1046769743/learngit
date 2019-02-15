local VipServer = class("VipServer")

function VipServer:bugGift(vipLevel, callBack)
	local params = {
		buyVipLevel = vipLevel
	}
	Server:sendRequest(params, MethodCode.vip_buy_gift_343, callBack)
end

return VipServer
