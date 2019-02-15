local ShopOpenConfirm = class("ShopOpenConfirm", UIBase)

function ShopOpenConfirm:ctor(winName, shopId)
	ShopOpenConfirm.super.ctor(self, winName)
	self.shopId = shopId
end

function ShopOpenConfirm:loadUIComplete()
	self:registerEvent()
	self.txt_1:setString(GameConfig.getLanguage('tid_shop_1026'))
	local shopId = self.shopId
    local cost = FuncShop.getShopOpenCost(shopId )
	local shopName = FuncShop.getShopNameById(shopId)
	local cost_tid = "tid_shop_1027"
	if cost > UserModel:getGold() then
		cost_tid = "tid_shop_1031"
	end
	self.rich_2:setString(GameConfig.getLanguageWithSwap(cost_tid, cost, shopName))
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_shop_1028"))
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("tid_shop_1029"), "txt_1")
end

function ShopOpenConfirm:registerEvent()
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.unlockShop, self))
	self.UI_1.btn_close:setTap(c_func(self.startHide, self))
	self:registClickClose("out")
end

--解封某个商店
function ShopOpenConfirm:unlockShop()
	local shopId = self.shopId
    --判断是否花费不够
    local cost = FuncShop.getShopOpenCost(shopId )
	if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, cost, true) then
		self:startHide()
		return
	end
    --
    ShopServer:unlockShop(shopId,c_func(self.onUnlockShopOk, self,shopId) )
end

--解锁商店返回
function ShopOpenConfirm:onUnlockShopOk(shopId, result)
	WindowControler:showWindow("ShopJiefeng", shopId)
	self:startHide()
end

return ShopOpenConfirm

