
local PartnerSkinServer = class("PartnerSkinServer")
--MethodCode.skin_buy_4901 = 4901 --购买
--MethodCode.skin_on_4903 = 4903 --穿戴

--购买 
function PartnerSkinServer:buySkinServer(id,callBack)
	Server:sendRequest({ skinId = id }, MethodCode.skin_buy_4901, callBack );
end
--穿戴 
function PartnerSkinServer:skinOnServer(partnerId,skinId,callBack)
	Server:sendRequest({ partnerId = partnerId,skinId  = skinId }, MethodCode.skin_on_4903, callBack );
end

return PartnerSkinServer