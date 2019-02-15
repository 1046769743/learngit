local ShopNavBtn = class("ShopNavBtn", UIBase)
function ShopNavBtn:ctor(winName)
	ShopNavBtn.super.ctor(self, winName)
end

function ShopNavBtn:loadUIComplete()
	self:registerEvent()
end

function ShopNavBtn:setBtnNavView(navView)
	self.navView = navView
end

function ShopNavBtn:setShopId(shopId)
	self.shopId = shopId
end

function ShopNavBtn:updateUI()
	local shopId = self.shopId
	local shopName = FuncShop.getShopNameById(shopId)
--	self.mc_1:getViewByFrame(1).btn_1:setBtnStr(shopName)
--	self.mc_1:getViewByFrame(2).btn_2:setBtnStr(shopName)
    self.mc_1:getViewByFrame(1).btn_1:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[shopId])
    self.mc_1:getViewByFrame(1).btn_1:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[shopId])

    self.mc_1:getViewByFrame(2).btn_2:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[shopId])
    self.mc_1:getViewByFrame(2).btn_2:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[shopId])
	-- self:setLock()
	if FuncShop.isVipShop(shopId) and not ShopModel:checkIsOpen(shopId) then
		self.mc_1:getViewByFrame(1).btn_1:disabled()
	end

	if self.mc_1:getCurFrame() == 1 then
		local showAnim = ShopModel:showShopBtnAnimById(self.shopId)
		self:showShopAinm(showAnim)
	end
end

function ShopNavBtn:setLock()
	local shopId = self.shopId
	local lockHide = false
	if not FuncShop.isVipShop(shopId) then
		lockHide = true
	else
		if ShopModel:checkIsOpen(shopId) then
			lockHide = true
		end
	end
	self.mc_1:getViewByFrame(1).panel_1:visible(not lockHide)
	self.mc_1:getViewByFrame(2).panel_1:visible(not lockHide)
end

function ShopNavBtn:setSelected(selected)
	if selected then
		self.mc_1:showFrame(2)
		self.mc_1.currentView.btn_2:getUpPanel().mc_1.currentView.mc_1:showFrame(2)
		ShopModel:setShopAnimStatus(self.shopId)
		self:showShopAinm(false)
	else
		self.mc_1:showFrame(1)
		self.mc_1.currentView.btn_1:getUpPanel().mc_1.currentView.mc_1:showFrame(1)
	end
end

function ShopNavBtn:registerEvent()
	self.mc_1:setTouchedFunc(c_func(self.onBtnMcTouched, self))
    self.mc_1:setTouchSwallowEnabled(true);
end

function ShopNavBtn:onBtnMcTouched()
	local shopId = self.shopId
	if not shopId or not self.navView then
		return
	end
	if self.navView.scroll_1:isMoving() then
		return
	end
	if FuncShop.isVipShop(shopId) and not ShopModel:checkIsOpen(shopId) then
		self:actionOnShopNotOpened(shopId)
		return
	end
	self:dispatchTouchEvent()
	-- self.navView:selectShop(self.shopId,true)
end

function ShopNavBtn:dispatchTouchEvent()
	EventControler:dispatchEvent(ShopEvent.SHOP_REFRESH_BTNS, self.shopId)
end

function ShopNavBtn:actionOnShopNotOpened(shopId)
	local canOpen = FuncShop.checkVipShopCanOpen(shopId)
	--vip 级别达到，但是未解封
	if canOpen then
		--显示解封
		-- WindowControler:showWindow("ShopOpenConfirm", shopId)
	end
end

function ShopNavBtn:showShopAinm(showShop)
	if showShop then
		self.panel_new:setVisible(true)
		-- if not self.shopAnim then
		-- 	self.shopAnim = self:createUIArmature("UI_ketisheng", "UI_ketisheng", self.ctn_anim, true)
	 --        local textAnim = self.shopAnim:getBoneDisplay("layer1")
	 --        textAnim:playWithIndex(1)
	 --        self.shopAnim:pos(0, 20)
		-- end
		-- self.shopAnim:setVisible(true)
		-- self.shopAnim:startPlay(true, false)
	else
		-- if self.shopAnim then
		-- 	self.shopAnim:setVisible(false)
		-- end
		self.panel_new:setVisible(false)
	end
end

function ShopNavBtn:close()
	self:startHide()
end

return ShopNavBtn
