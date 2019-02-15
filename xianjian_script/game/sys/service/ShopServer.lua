--
-- Author: xd
-- Date: 2016-01-15 14:40:22
--

local  ShopServer=ShopServer or {}

--刷新商店
function ShopServer:refreshShop( shopType ,call )
	Server:sendRequest({shopType = shopType}, MethodCode.shop_refresh_1603 ,call  )
end

--购买道具  商店类型 道具id ,key 第几个道具
function ShopServer:buyGoods(shopType,goodsId,key,call )
	echo(goodsId,"goodsId",key,"key",shopType,"shopType")
    Server:sendRequest({shopType = shopType,goodsId =goodsId,key= key }, MethodCode.shop_buyGoods_1607 ,call)
--	Server:sendRequest({shopType = shopType,goodsId =goodsId,key= key }, MethodCode.shop_buyGoods_1607 ,nil,true,true,true)
--    local data = ShopModel:getBuydataServerCallBack(shopType,goodsId,key)
--    Server:updateBaseData(data) 
--    call()
end

function ShopServer:noRandShopBuyGoods(shopType, goodsId, callBack)
    
	local params = {shopType = shopType, goodsId = goodsId}
    Server:sendRequest(params, MethodCode.norandshop_buygoods_3903, callBack)
--	Server:sendRequest(params, MethodCode.norandshop_buygoods_3903, nil,true,true,true)
--    local data = ShopModel:getNoRandBuydataServerCallBack(shopType,goodsId)
--    Server:updateBaseData(data) 
--    callBack()
end

function ShopServer:flushNoRandShop(shopType, callBack)
	Server:sendRequest({shopType=shopType}, MethodCode.norandshop_refresh_3901, callBack)
end

--获取商店信息
function ShopServer:getShopInfo( call )
	Server:sendRequest({}, MethodCode.shop_getInfo_1601  ,call  )
end

--解锁商店
function ShopServer:unlockShop( shopType,call )
	Server:sendRequest({shopType = shopType }, MethodCode.shop_unlockShop_1605 , call)
end

--出售道具
function ShopServer:sellItem(data,call)
    Server:sendRequest(data, MethodCode.shop_sell_item_803 , call)
end

return ShopServer
