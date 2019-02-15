--
-- Author: ZhangYanguang
-- Date: 2015-12-08
--
--道具模块，网络服务类
local ItemServer = class("ItemServer")

-- 使用道具
function ItemServer:customItems(itemId, itemNum, callBack, index)
	echo("···ItemServer:customItems")
	local params = {
		itemId = itemId,
		num = itemNum,
		index = index,
	}
	Server:sendRequest(params,MethodCode.item_customItem_801, callBack ,false,false,true)
end

-- 购买钥匙
function ItemServer:buyKeys(itemId,itemNum,callBack)
	local params = {
		itemId = itemId,
		num = itemNum
	}
	Server:sendRequest(params,MethodCode.item_buyKey_803, callBack)
end

-- 道具碎片合成 单个道具合成
function ItemServer:composeItemPieces(itemId,num,callBack)
	local items = {}
	items[itemId] = num
	local params = {
		items = items
	}
	Server:sendRequest(params,MethodCode.item_piece_compose_805, callBack)
end
-- 道具碎片合成 多个道具合成
function ItemServer:composeItemsPieces(param,callBack)
	local params = {
		items = param
	}
	Server:sendRequest(params,MethodCode.item_piece_compose_805, callBack)
end

-- 快捷购买道具
function ItemServer:quickBuyItem( id,itemNum,callBack )
	local params = {
		itemId = id,
		num = itemNum,
	}
	Server:sendRequest(params,MethodCode.item_quick_buy_807, callBack)
end

--快捷越买越贵道具
function ItemServer:quickBuyItemByCount( countId,buyNums,callBack )
	local params = {
		countId  = countId,
		times  = buyNums,
	}
	Server:sendRequest(params,MethodCode.item_buyCount_809, callBack)
end

return ItemServer