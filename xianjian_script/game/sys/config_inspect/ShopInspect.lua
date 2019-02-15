local BaseInspect = require("game.sys.config_inspect.BaseInspect")
local ShopInspect = class("ShopInspect", BaseInspect)

function ShopInspect:ctor()
	self.configs = {
		"items.Item",
		"shop.Shop",
		"shop.Goods",
	}
end

function ShopInspect:getConfigItems()
	return self.configs
end

function ShopInspect:run_check_normal_shop_items()
	local goods = self.config_Goods
	local items = self.config_Item
	for id, goodsInfo in pairs(goods) do
		local itemId = goodsInfo.itemId..''
		if items[itemId] == nil then
			self:log(string.format("shop.Goods.csv id:%s 中itemId%s 在item.Item.csv中不存在", id, itemId))
		end
	end
end

return ShopInspect
