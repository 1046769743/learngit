local ShopKaiqi = class("ShopKaiqi", UIBase)

--[[
    self.btn_close,
    self.mc_1,
    self.scale9_1,
]]

function ShopKaiqi:ctor(winName, shopIds)
    ShopKaiqi.super.ctor(self, winName)
    dump(shopIds, "\n\nshopIds====")
    if table.length(shopIds) == 2 then
    	self.shopId = shopIds[2]
    	self.shopId2 = shopIds[1]
    else
    	self.shopId = shopIds[1]
    end 
    echo("\n\nself.shopId===", self.shopId)  
end

function ShopKaiqi:loadUIComplete()
	--逻辑和ui的映射
	self.btnGotoShop = self.UI_1.mc_1.currentView.btn_1
	self.btnClose = self.UI_1.btn_close
	self.txtTitle = self.UI_1.txt_1
	self.txtDesTitle = self.txt_1
	self.txtDesDetail = self.txt_2
--	self.panel_shop_lock.btn_1:disabled(true)

	local shopName = FuncShop.getShopNameById(self.shopId)
    self.shopName=shopName;
 --   self.mc_duozhen.currentView.txt_1:setString(shopName);
    self.mc_duozhen:getViewByFrame(1).btn_1:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(2).btn_2:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(1).btn_1:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(2).btn_2:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
	self.txtTitle:setString(GameConfig.getLanguage("tid_shop_1013"))
	self.txtDesTitle:setString(GameConfig.getLanguageWithSwap("tid_shop_1016", shopName))
	self.txtDesDetail:setString(GameConfig.getLanguageWithSwap("tid_shop_1015", shopName))
	self.btnGotoShop:setBtnStr(GameConfig.getLanguage("tid_shop_1014"))

	self:hideItems()

	self:registerEvent()


	local function onJiefenAnimEnd()
		self:onShopJiefengAnimEnd()
	end
    self.panel_jiefeng:visible(false)
--	local anim = self:createUIArmature("UI_shop", "UI_shop_jiesuo", self.panel_shop_lock.ctn_1, false, GameVars.emptyFunc)
    local  anim=self:createUIArmature("UI_shopjiefeng", "UI_shopjiefeng",self.ctn_lock,false,GameVars.emptyFunc);
	anim:registerFrameEventCallFunc(33, 1, onJiefenAnimEnd)
end 

function ShopKaiqi:hideItems()
	self.txtDesDetail:visible(false)
	for i=1,4 do 
		local ui_item = self["UI_item_"..i]
		if ui_item then
			ui_item:visible(false)
		end
	end
end

function ShopKaiqi:onShopJiefengAnimEnd()
	self.txtDesDetail:visible(true)
    self.mc_duozhen:showFrame(2);
--	local shopName = FuncShop.getShopNameById(self.shopId)
 --   self.mc_duozhen.currentView.txt_1:setString(shopName);
	self:setItems()
end

function ShopKaiqi:gotoShop()
	local isTempShop = ShopModel:isTempShop(self.shopId)
	if isTempShop then
        local timeToShow = 0
		timeToShow = ShopModel:getTempShopLeftTime(self.shopId);
        if(timeToShow<=0)then
               WindowControler:showTips(GameConfig.getLanguage("tid_shop_has_close"):format(self.shopName));
               self:close();
               return;
        end
    end
	WindowControler:showWindow("ShopView", self.shopId)
	self:close()
end

function ShopKaiqi:setItems()
	local itemList = FuncShop.getShopKaiqiDisplayItems(self.shopId)
	for i=1,4 do 
		local itemId = itemList[i]
		local ui_item = self["UI_item_"..i]
		if ui_item then
			ui_item:visible(true)
			local data = {
				itemId = itemId,
				itemNum = 0,
			}
			ui_item:setItemData(data)
			ui_item:showResItemNum(false)
		end
	end
end

function ShopKaiqi:registerEvent()
	ShopKaiqi.super.registerEvent()
	self.btnClose:setTap(c_func(self.press_btn_close, self))
	self.btnGotoShop:setTap(c_func(self.gotoShop, self))
end


function ShopKaiqi:setShopId(shopId)
	self._shopId = shopId
	self:updateUI()
end

function ShopKaiqi:press_btn_close()
	if self.shopId2 then
		local shopIds = {}
		table.insert(shopIds, self.shopId2)
		self:close()
		WindowControler:showWindow("ShopKaiqi", shopIds)
	else
		self:close()
	end
	
end

function ShopKaiqi:close()
	ShopModel:clearCurrentNewOpenTempShop()
	self:startHide()
end


function ShopKaiqi:updateUI()
	
end


return ShopKaiqi
