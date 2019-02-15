local CompGoodItemView = class("CompGoodItemView", UIBase)

local COST_TO_MC_INDEX = {
	[FuncDataResource.RES_TYPE.COIN] = 1,
	[FuncDataResource.RES_TYPE.DIAMOND] = 2,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 3,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 5,
    [FuncDataResource.RES_TYPE.DIMENSITY] = 6,
    [FuncDataResource.RES_TYPE.CIMELIACOIN] = 7,
	[FuncDataResource.RES_TYPE.LINGSHI] = 8, 
	[FuncDataResource.RES_TYPE.GUILDCOIN] = 9,  
	[FuncDataResource.RES_TYPE.XIANFU] = 10,
}

function CompGoodItemView:ctor(winName, params)
	CompGoodItemView.super.ctor(self, winName)
	dump(params,"购买道具的结构",8)
	self:setParams(params)
end

function CompGoodItemView:setParams( params )
	self.params = params
	local itemId = params.itemId or ""	
	self.itemId = tostring(itemId)
	self.costInfo = params.costInfo
	self.viewType = params.viewType
	self.itemNum = params.itemNum
	self.okAction = params.okAction
	self.closeManual = params.closeManual -- 手动关闭

	---[[  新添加的类型 wk 是否解锁和商店的类型
	self.shopType = params.shopType
	self.isunlock = params.isunlock
	self.tipStr =	params.tipStr
	--]]

	self.resourceType = self.params.itemType

	--签到需要
	self.itemResType = params.itemResType
	self.desStr = params.desStr;
end

function CompGoodItemView:onSelfPop( params )
	self:setParams(params)
	self:initItemData()
	self:initItemInfoView()
	self:initCommonInfo()
	self:initBottomInfo()
end

function CompGoodItemView:loadUIComplete()
	self:registerEvent()
	self:initItemData()
	self:initItemInfoView()
	self:initCommonInfo()
	self:initBottomInfo()
end

function CompGoodItemView:updateUI()
	
end

function CompGoodItemView:createReward()
	if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
	    return string.format("1,%d,%d", self.itemId, self.itemNum);
	else 
		return string.format("%d,%d", self.itemResType, self.itemNum);
	end 	
end

function CompGoodItemView:initItemData()
	if self.resourceType and self.resourceType == FuncDataResource.RES_TYPE.USERHEADFRAME then
		self.notItem = true
	else
		self.notItem = false
	end

	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		if self.resourceType == nil then
			self.resourceType = FuncDataResource.RES_TYPE.ITEM
		end
		if self.notItem == true then
			if UserHeadModel:checkHeadFrameIsOwn(self.itemId) == true then
				self.hasNum = 1
			else
				self.hasNum = 0
			end

			self.des = FuncUserHead.getHeadFrameDes(self.itemId)
            self.itemName = FuncUserHead.getHeadFrameName(self.itemId)
		else
			self.hasNum = ItemsModel:getItemNumById(self.itemId);
			self.des = GameConfig.getLanguageWithSwap(FuncItem.getItemData(self.itemId).des 
				or "tid_shop_1002"), self.itemId;

			self.itemType = FuncItem.getItemType(self.itemId)
	    	self.itemName =FuncItem.getItemName(self.itemId)
		end
		

	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then

		if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
			self.hasNum = ItemsModel:getItemNumById(self.itemId);
		elseif self.itemResType == FuncDataResource.RES_TYPE.COIN then 
			self.hasNum = UserModel:getCoin();
		elseif self.itemResType == FuncDataResource.RES_TYPE.DIAMOND then 
			self.hasNum = UserModel:getGold();
		else 
			self.hasNum = 0;
		end 
		self.itemName = FuncDataResource.getResNameById(self.itemResType, self.itemId);
		self.des = FuncDataResource.getResDescrib(self.itemResType, self.itemId);
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		if self.itemResType == FuncDataResource.RES_TYPE.ITEM then 
			self.hasNum = ItemsModel:getItemNumById(self.itemId);
		elseif self.itemResType == FuncDataResource.RES_TYPE.COIN then 
			self.hasNum = UserModel:getCoin();
		elseif self.itemResType == FuncDataResource.RES_TYPE.DIAMOND then 
			self.hasNum = UserModel:getGold();
		else
			local financeName = FuncDataResource.getResNameInEnglish(self.itemId);
			self.hasNum = UserModel:finance()[financeName] or 0;
		end 
		self.itemName = FuncDataResource.getResNameById(self.itemResType, self.itemId);
		self.des = FuncDataResource.getResDescrib(self.itemResType, self.itemId);
	end
end

function CompGoodItemView:registerEvent()
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.close, self))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onOkTap, self))
--//注册事件监听,主角的资源产生了变化
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE,self.initBuyInfo,self);
--//监听商店刷新事件
    EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END,self.close,self);
end

function CompGoodItemView:onOkTap()
	if self.okAction then
		self.okAction()
	end
	if not self.closeManual then
		self:close()
	end
end

function CompGoodItemView:initBottomInfo()
	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		self.mc_2:showFrame(1)
		self:initBuyInfo()
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
		self.mc_2:showFrame(2)
		self:initSignInfo();
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		--self.mc_2:showFrame(2)
		self.mc_2:visible(false)
	end
end

function CompGoodItemView:initSignInfo()
	echo("self.desStr", tostring(self.desStr));
	self.mc_2.currentView.txt_1:setString(self.desStr);
end

function CompGoodItemView:initBuyInfo()

	if self.shopType == FuncShop.SHOP_TYPES.GUILD_SHOP and not self.isunlock  then
		self:setGuildButton()
	elseif self.shopType == FuncShop.SHOP_TYPES.PVP_SHOP and not self.isunlock then
		self:setPvpShopItemButton()
	elseif self.shopType == FuncShop.SHOP_TYPES.TOWER_SHOP and not self.isunlock  then
		self:setTowerButton()
	elseif self.shopType == FuncShop.SHOP_TYPES.WONDER_SHOP and not self.isunlock then
		self:setWonderShopItemButton()
	else
	    local costInfo = self.costInfo
	    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
	    local infoView = self.mc_2.currentView.panel_1

		local index = COST_TO_MC_INDEX[resType]
		if index then
			infoView.panel_1.mc_1:showFrame(index)
		end

	    infoView.panel_1.txt_1:setString(needNums)
	    if not isEnough then
			infoView.panel_1.txt_1:setColor(FuncCommUI.COLORS.TEXT_RED)
	    else
	        infoView.panel_1.txt_1:setColor(cc.c3b(0x01,0xbb,0x47));
		end
	end
end

function CompGoodItemView:setGuildButton()
	self.mc_2:showFrame(2)
	local txt  = self.mc_2.currentView.txt_1
	txt:setString(self.tipStr)
	txt:setColor(FuncCommUI.COLORS.TEXT_RED)
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("#tid_shop_lock_003"))--GameConfig.getLanguageWithSwap("tid_shop_1010"))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.gotoLevel, self))
end

function CompGoodItemView:setPvpShopItemButton()
	self.mc_2:showFrame(2)
	local txt  = self.mc_2.currentView.txt_1
	echo("self.tipStr===", self.tipStr)
	txt:setString(self.tipStr)
	txt:setColor(FuncCommUI.COLORS.TEXT_RED)
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("#tid_shop_lock_004"))--GameConfig.getLanguageWithSwap("tid_shop_1010"))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.gotoPvp, self))
end

function CompGoodItemView:setWonderShopItemButton()
	self.mc_2:showFrame(2)
	local txt  = self.mc_2.currentView.txt_1
	echo("self.tipStr===", self.tipStr)
	txt:setString(self.tipStr)
	txt:setColor(FuncCommUI.COLORS.TEXT_RED)
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("#tid_shop_lock_004"))--GameConfig.getLanguageWithSwap("tid_shop_1010"))
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.gotoWonderLand, self))
end

function CompGoodItemView:gotoPvp()
	WindowControler:showWindow("ArenaMainView")
	self:delayCall(function()
		self:close()
	end, 0.1)
end

function CompGoodItemView:gotoLevel()
	WindowControler:showWindow("GuildMainBuildView",2)
	self:delayCall(function()
		self:close()
	end, 0.1)	
end

function CompGoodItemView:gotoWonderLand()
	WindowControler:showWindow("WonderlandMainView")
	self:delayCall(function()
		self:close()
	end, 0.1)
end

-- 去升级锁妖塔
function CompGoodItemView:setTowerButton()
	self.mc_2:showFrame(2)
	local txt  = self.mc_2.currentView.txt_1
	txt:setString(self.tipStr)
	txt:setColor(FuncCommUI.COLORS.TEXT_RED)
	local tips = "去爬塔"
	tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_097")
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(tips)
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.gotoTower, self))
end

function CompGoodItemView:gotoTower()
	TowerControler:enterTowerMainView()
	self:delayCall(function()
		self:close()
	end,0.1)
end

function CompGoodItemView:initItemInfoView()

	local itemType = self.itemResType or self.resourceType
    --商品名字
    if self.notItem == true then
    	local quality = FuncDataResource.getQualityById(itemType) or 1
 		self.mc_zi:showFrame(quality)   
    else
    	if itemType == FuncDataResource.RES_TYPE.ITEM then
    		self.mc_zi:showFrame(tonumber(FuncItem.getItemQuality(self.itemId)))
    	else
    		self.mc_zi:showFrame(tonumber(FuncDataResource.getQualityById(itemType)))
    	end    	
    end
    
	self.mc_zi.currentView.txt_daojuming:setString(string.format("%s x %d", self.itemName, self.itemNum))
    --拥有数量
    if itemType == FuncDataResource.RES_TYPE.ITEM and FuncItem.checkCharSoulId(self.itemId) then
		local _id = UserModel:avatar()
		local _curStar = UserModel:star()
		local _starPoint = UserModel:starPoint()
		local needCount = FuncPartner.getNeedDebrisByPartnerId(_id, _curStar, _starPoint)
		if needCount == 0 then			
			self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum))
		else
			self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum.."/"..needCount))
		end
	elseif itemType == FuncDataResource.RES_TYPE.ITEM and FuncItem.checkPartnerId(self.itemId) then
		local _id = self.itemId
		local partnerData = PartnerModel:getPartnerDataById(_id)
		-- dump(partnerData, "\n\npartnerData===")
		if partnerData and table.length(partnerData) > 0 then
			local _curStar = partnerData.star
			local _starPoint = partnerData.starPoint
			local needCount = FuncPartner.getNeedDebrisByPartnerId(_id, _curStar, _starPoint)
			if needCount == 0 then
				self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum))
			else
				self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum.."/"..needCount))
			end
		else
			local needCount = FuncPartner.getCombineNeedDebrisById(_id)
			self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum.."/"..needCount))
		end

		self.UI_2:setTouchedFunc(c_func(self.showPartnerInfo, self, self.itemId))	
	else
		self.rich_2:setString(GameConfig.getLanguageWithSwap("tid_shop_1001", self.hasNum))
	end
    --商品描述
	self.txt_3:setString(self.des);

	self:setIconAndQuality()
end

--设置按钮和标题
function CompGoodItemView:initCommonInfo()
	local titleView = self.UI_1.txt_1
	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("tid_shop_1009"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_shop_1010"))
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
		--TODO 签到处理
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("sign_detail_title"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("sign_detail_ok"))
	elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		self.UI_1.txt_1:setString(GameConfig.getLanguageWithSwap("tid_shop_1009"))
		self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_common_2007"))
	end
end

function CompGoodItemView:setIconAndQuality()

	if self.viewType == FuncItem.ITEM_VIEW_TYPE.SHOP then
		if self.notItem == true then
			local data = {
	            itemId = self.params.itemId,
	            itemNum = self.params.num,
	            itemType = self.params.itemType
	        }
        	self.UI_2:setItemData(data)
		else
			local str = string.format("1,%d,%d", self.itemId, self.itemNum);
	    	self.UI_2:setResItemData({reward = str});			
		end
    elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.SIGN then
    	local str = self:createReward();
    	self.UI_2:setResItemData({reward = str});
    elseif self.viewType == FuncItem.ITEM_VIEW_TYPE.ONLYDETAIL then
		local str = self:createReward()
    	self.UI_2:setResItemData({reward = str});
    end 
	self.UI_2:showResItemNum(false)

end

function CompGoodItemView:showPartnerInfo(itemId)
	if FuncItem.checkPartnerId(itemId) then
		-- WindowControler:showWindow("WuXingPartnerDetailView", itemId)
	end	
end

function CompGoodItemView:close()
	self:startHide()
end

return CompGoodItemView

