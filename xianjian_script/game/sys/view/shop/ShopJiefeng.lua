local ShopJiefeng = class("ShopJiefeng", UIBase)

function ShopJiefeng:ctor(winName, shopId)
    ShopJiefeng.super.ctor(self, winName)
    self.shopId = shopId
end

function ShopJiefeng:loadUIComplete()
--//隐藏解封图片
--    self.panel_jiefeng:setVisible(false);
	self:registerEvent()
	self:initTexts()
	self:showRewardAnim()
	--self:setItems()
	self:showSomeUIItems(false)
	self.txt_2:visible(false)
	self:setViewAlign()
end 

function ShopJiefeng:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1.ctn_1, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_3, UIAlignTypes.MiddleBottom)
end

function ShopJiefeng:showSomeUIItems(show)
	local alpha = 255
	if not show then
		alpha = 0
	end
	self.txt_4:runAction(act.fadeto(0, alpha))
	for i=1,4 do 
		self['UI_item_'..i]:runAction(act.fadeto(0, alpha))
	end
	self.txt_3:runAction(act.fadeto(0, alpha))
end

function ShopJiefeng:registerEvent()
	ShopJiefeng.super.registerEvent()
end

function ShopJiefeng:showRewardAnim()
	-- 黑色背景
	FuncCommUI.addBlackBg(self.widthScreenOffset,self._root)
    -- 开启动画
    local anim = FuncCommUI.playSuccessArmature(self.UI_1,FuncCommUI.SUCCESS_TYPE.OPEN,1,false)

    local delayFrame = anim.totalFrame
    if delayFrame > 30 then
    	delayFrame = 30
    end

    anim:registerFrameEventCallFunc(delayFrame, 1, c_func(self.onTitleAnimOk, self))
end

function ShopJiefeng:onTitleAnimOk()
	self:showShopJiefengAnim()
end

function ShopJiefeng:showShopJiefengAnim()
	local onJiefenAnimEnd = function()
		self:onShopJiefengAnimEnd()
	end
--	self.panel_1:visible(false)
--	local anim = self:createUIArmature("UI_shop", "UI_shop_jiesuo", self.ctn_lock, false, GameVars.emptyFunc)
   self.panel_jiefeng:setVisible(false);
   local  anim=self:createUIArmature("UI_shopjiefeng","UI_shopjiefeng",self.ctn_lock,false,GameVars.emptyFunc);
 --  FuncArmature.changeBoneDisplay(anim,"layer2");
	anim:registerFrameEventCallFunc(33, 1, c_func(onJiefenAnimEnd))
end

function ShopJiefeng:onShopJiefengAnimEnd()
	self:playJiefengTitleAnim()
end

function ShopJiefeng:playJiefengTitleAnim()
	local animEnd = function()
		self:onJiefenTitleAnimEnd()
	end
--//
    self.mc_duozhen:showFrame(2);
	local animJiefengTitle = self:createUIArmature("UI_common", "UI_common_ruchang", self.ctn_title_texiao, false,animEnd)
	local shopName = FuncShop.getShopNameById(self.shopId)
    --self.mc_duozhen.currentView.txt_1:setString(shopName);
    self.mc_duozhen.currentView.btn_2:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen.currentView.btn_2:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    -- self.mc_duozhen.currentView.mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
	local str = GameConfig.getLanguageWithSwap("tid_shop_1003", shopName)
	local label = UIBaseDef:cloneOneView(self.txt_2)  --TTFLabelExpand.new( { co = { text = str, color = 0x572B22, align = "center", valign = "left" }, w = 296, h = 68 })
	label:setString(str)
    local box = label:getContainerBox()
	label:pos(-box.width/2,box.height/2)
	FuncArmature.changeBoneDisplay(animJiefengTitle, "node", label)
	animJiefengTitle:getBoneDisplay("layer1"):visible(false)
	animJiefengTitle:startPlay(false)
end

function ShopJiefeng:onJiefenTitleAnimEnd()
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_SHOP_JIEFENG_END, self.shopId)
--	self.panel_1:visible(false)
	self:animShowSomeUIItems()
	self:setItems()
	self:registClickClose()
end

function ShopJiefeng:initTexts()
	local shopName = FuncShop.getShopNameById(self.shopId)
	local str = GameConfig.getLanguageWithSwap("tid_shop_1003", shopName)
	self.txt_2:setString(str)

	local str4 = GameConfig.getLanguageWithSwap('tid_shop_1015', shopName)
	self.txt_4:setString(str4)
--	self.txt_1:setString(shopName)
--    self.mc_duozhen.currentView.txt_1:setString(shopName);
	self.mc_duozhen:getViewByFrame(1).btn_1:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(2).btn_2:getUpPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(1).btn_1:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    self.mc_duozhen:getViewByFrame(2).btn_2:getDownPanel().mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
    -- self.mc_duozhen.currentView.mc_1:showFrame(FuncShop.ShopTitleMap[self.shopId])
end

function ShopJiefeng:setItems()
	local itemList = FuncShop.getShopKaiqiDisplayItems(self.shopId)
	for i=1,4 do 
		local itemId = itemList[i]
		local ui_item = self["UI_item_"..i]
		local data = {
			itemId = itemId,
			itemNum = 0,
		}
		ui_item:setItemData(data)
--//隐藏数目
        ui_item:showResItemNum(false);
	end
end


function ShopJiefeng:animShowSomeUIItems()
	local alpha = 255
	self.txt_4:runAction(act.fadeto(0.5, alpha))
	for i=1,4 do 
		self['UI_item_'..i]:runAction(act.fadeto(0.5, alpha))
	end
	self.txt_3:runAction(act.fadeto(0.5, alpha))
end

function ShopJiefeng:onHideCompData()
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_SHOP_JIEFENG_VIEW_CLOSE, self.shopId)
	return nil
end


return ShopJiefeng
