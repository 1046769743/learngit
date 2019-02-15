local ShopRefreshView = class("ShopRefreshView", UIBase)

function ShopRefreshView:ctor(winName, shopId)
	ShopRefreshView.super.ctor(self, winName)
	self.shopId = shopId
	self.constantName = "RefreshNum1"
    if self.shopId == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
    	self.constantName = "RefreshNum3"
    elseif self.shopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
    	self.constantName = "MonthCardShopFlushTime"
    end
end

function ShopRefreshView:loadUIComplete()
	self:registerEvent()
	local refreshTimes = CountModel:getShopRefresh(self.shopId) or 0
	local needMoneyInfo = FuncShop.getRefreshCost(self.shopId, refreshTimes+1)
	dump(needMoneyInfo, 'needMoneyInfo')
	local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
	self:setResIcon(resType)

	local title = GameConfig.getLanguageWithSwap("#tid_shop_1002")
	self.UI_1.txt_1:setString(title)

	self.txt_1:setString(GameConfig.getLanguage("tid_shop_1006"))

	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguageWithSwap("tid_shop_1012"))

	-- 仙盟无极阁加成
	local shopToTypeMap = {
		[FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = FuncCommon.additionType.decrement_refreshShop_1,
		[FuncShop.SHOP_TYPES.PVP_SHOP] = FuncCommon.additionType.decrement_refreshShop_pvp,
		[FuncShop.SHOP_TYPES.CHAR_SHOP] = FuncCommon.additionType.decrement_refreshShop_trial,
		[FuncShop.SHOP_TYPES.ARTIFACT_SHOP] = FuncCommon.additionType.decrement_refreshShop_artifact,
		[FuncShop.SHOP_TYPES.TOWER_SHOP] = FuncCommon.additionType.decrement_refreshShop_tower,
		[FuncShop.SHOP_TYPES.WONDER_SHOP] = FuncCommon.additionType.decrement_refreshShop_wonder,
		[FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP] = FuncCommon.additionType.decrement_refreshShop_stone,
	}

	echo("__________shopToTypeMap[self.shopId] ",shopToTypeMap[self.shopId])
	-- local isHas,value,subType = GuildModel:checkIsHaveAdditionByZone( shopToTypeMap[self.shopId] )
	local privilegeData = UserModel:privileges() 
    local additionType = shopToTypeMap[self.shopId]
    local curTime = TimeControler:getServerTime()
    local fromSys = FuncCommon.additionFromType.GUILD
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,fromSys )

	if isHas then
		local valueStr = value -- 默认固定值
		if subType == 1 then  -- 万分比
			valueStr = (math.ceil(value/100)) --.."%"
		end
		echo("__________needNum ,valueStr+________________",needNum,valueStr)
		needNum = needNum - valueStr
		self.txt_5:visible(true)
		self.txt_5:setString(GameConfig.getLanguageWithSwap("#tid_guild_skill_14",valueStr))
	else
		self.txt_5:visible(false)
	end

	self.txt_2:setString(needNum)
	if not isEnough then
		self.txt_2:setColor(FuncCommUI.COLORS.TEXT_RED)
	end
	self.txt_3:setString(GameConfig.getLanguage("tid_shop_1025"))
    local maxRefreshNum = FuncDataSetting.getDataByConstantName(self.constantName);
	local refreshTimesStr = GameConfig.getLanguageWithSwap("tid_shop_1011", refreshTimes.."/"..maxRefreshNum)
	self.txt_4:setString(refreshTimesStr)

	self:updateLoginAttention()
end

function ShopRefreshView:setResIcon(resType)
	local mcFrame = FuncShop.RES_MC_MAP[resType]
	if mcFrame == nil then mcFrame = 1 end
	self.mc_1:showFrame(mcFrame)
end

function ShopRefreshView:onBtnRefreshTap()
    local refreshTimes = CountModel:getShopRefresh(self.shopId) or 0
    --判断刷新次数是否超过最大值
    local maxRefreshNum = FuncDataSetting.getDataByConstantName(self.constantName);
    if maxRefreshNum <= refreshTimes then
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2058")) 
        self:startHide()
        return
    end
    --每次都需要+1
    local needMoneyInfo = FuncShop.getRefreshCost(self.shopId, refreshTimes+ 1)
    local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
    local shopId = self.shopId
	if not UserModel:tryCost(resType, needNum, true, FuncCommon.CostType.REFRESH) then
		self:startHide()
	else
		if FuncShop.isNoRandShop(shopId) then
			ShopServer:flushNoRandShop(shopId, c_func(self.onRefreshOk, self))
		else
			--刷新
			ShopServer:refreshShop(shopId, c_func(self.onRefreshOk, self))
		end
	end
end

function ShopRefreshView:onRefreshOk()
	if self then  -- 不知道self 为什么为nil
        self:startHide()
    end
	WindowControler:showTips(GameConfig.getLanguage("tid_common_1010"))
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, {currentShopId = self.shopId})
    
end

--更新 本次登录是否提示  状态
function ShopRefreshView:updateLoginAttention()
	self.status = ShopModel:getLoginAttentionStatus(self.shopId)
	if not self.status then
		self.panel_duigou.panel_1:setVisible(false)
	else
		self.panel_duigou.panel_1:setVisible(true)
	end

	self.panel_duigou:setTouchedFunc(c_func(self.clickLoginAttention, self))
end

function ShopRefreshView:clickLoginAttention()
	local status = ShopModel:getLoginAttentionStatus(self.shopId)
	if not status then
		self.panel_duigou.panel_1:setVisible(true)
		ShopModel:setLoginAttentionStatus(true, self.shopId)
	else
		self.panel_duigou.panel_1:setVisible(false)
		ShopModel:setLoginAttentionStatus(false, self.shopId)
	end
end

function ShopRefreshView:onBtnCloseTap()
    self:startHide()
end

function ShopRefreshView:setShopId(shopId)
	self.shopId = shopId
end

--按钮事件
function ShopRefreshView:registerEvent()
	ShopRefreshView.super.registerEvent()
	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBtnRefreshTap, self))
	self.UI_1.btn_close:setTap(c_func(self.onBtnCloseTap, self))
	self:registClickClose("out")
end

function ShopRefreshView:startHide()
	ShopRefreshView.super.startHide(self)
	EventControler:dispatchEvent(ShopEvent.SHOP_REFRESH_VIEW_CLOSED)
end

return ShopRefreshView
