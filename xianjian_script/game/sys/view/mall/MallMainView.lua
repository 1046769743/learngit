
local MallMainView = class("MallMainView", UIBase);


function MallMainView:ctor(winName,_type)
    MallMainView.super.ctor(self, winName); 
    self.currentShopId = _type
    self.currentFrame = 0

    self.anim_table = {
    	["648"] = "UI_fendangchongzhi_04",
    	["328"] = "UI_fendangchongzhi_03",
    	["198"] = "UI_fendangchongzhi_02",
    	["98"] = "UI_fendangchongzhi_01"
	}
end
function MallMainView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_2, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_title, UIAlignTypes.LeftTop)
	
end

function MallMainView:onSelfPop( _type )
	-- self.currentShopId = _type
    self.currentFrame = 0
    for k,v in pairs(self.MALL_SHOPS_TYPE) do
    	if _type == v then
    		self:yeQianTap(k)
    		break
    	end
    end
end

function MallMainView:addEventListeners()
	EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, self.onRefreshEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_MODEL_UPDATE, self.onRefreshEnd, self)
	EventControler:addEventListener(ShopEvent.NORANDSHOPEVENT_MODEL_UPDATE, self.onRefreshEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_NORAND_SHOP_REFRESHED, self.onRefreshEnd, self)
	--月卡购买成功
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.onRefreshEnd, self)

	
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.chargeSuccess, self)
end

function MallMainView:chargeSuccess( event )
	local data = event.params
	-- 弹出购买的钻石和道具
	local reward = nil
	if type(data) == "table" and data._type and data._type == FuncMonthCard.RECHARGE_TYPE.PURCHASE then
    	reward = data.reward
	else
		local num = data
    	reward = "4,"..num
	end
	
    FuncCommUI.startFullScreenRewardView({reward}, nil)
	self:onRefreshEnd()
end

function MallMainView:registerEvent()
	self.btn_back:setTap(c_func(self.close,self))
	self.btn_refresh:setTap(c_func(self.refreshButton,self))

	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self,false), 0)
end
function MallMainView:loadUIComplete()
	self.btn_refresh = self.panel_shuaxinkuang.btn_1
	self.txt_refresh = self.panel_shuaxinkuang.txt_3
	self.panel_xad = self.panel_shangpin2
	self.panel_xad:visible(false)
	self.panel_yad = self.panel_shangpin3
	self.panel_yad:visible(false)
	self.panel_yk = self.panel_shangpin1
	self.panel_yk:visible(false)


	self:setViewAlign()
	self:addEventListeners()
	self:registerEvent()

	self:initData()
	self:refreshUI()
	self:initYeQian()
	self:refreshYeqianState( )

	self:doSpShield()
end

local CHONGZHIUI = "chongzhiUI"
function MallMainView:initData()
	self.MALL_SHOPS_TYPE = {
		[1] = FuncShop.SHOP_TYPES.MALL_YONGANDANG,
		[2] = FuncShop.SHOP_TYPES.MALL_XINANDANG,
		[3] = FuncShop.SHOP_CHONGZHI
	}

	if not self.currentShopId then
		self.currentShopId = FuncShop.SHOP_CHONGZHI
	end
end

function MallMainView:updateTime(  )
	self:refreshPanel(true)
	self:refreshTimesYongAnDang(true)
	self:refreshTimesForPurchaseItem()
end
-----------------------------------------------------------------------
----------------------------页签start----------------------------------
function MallMainView:initYeQian( )
	local panel = self.panel_yeqian
	for i=1,3 do
		panel["mc_"..i]:showFrame(1)
		local redPanel = panel["mc_"..i].currentView.panel_hongdian
		redPanel:visible(false)

		local btn = panel["mc_"..i].currentView.btn_1
		btn:setTap(c_func(self.yeQianTap,self,i))
	end

	panel.mc_1:visible(false)
	--干掉了永安当  保留新安当 且永久开启
	if ShopModel:isHasShopItemList(FuncShop.SHOP_TYPES.MALL_XINANDANG) then
		panel.mc_2:visible(true)
		panel.mc_2:pos(0,-108)
		panel.mc_3:pos(0,0)
		panel.panel_mail:pos(-10, -204)
	else
		panel.mc_2:visible(false)
		panel.mc_3:pos(0, 0)
		panel.panel_mail:pos(-10, -97)
	end
end

function MallMainView:yeQianTap( _type )

	local shopType = self.MALL_SHOPS_TYPE[_type] 
	if self.currentShopId == shopType then
		return 
	end

	if not self.scroll_list:isCreateComplete() then
		return
	end

	echo("========_type=======",_type,self.currentShopId,shopType)
	self.currentShopId = shopType
	self:refreshUI()

	self:refreshYeqianState( )
end
function MallMainView:refreshYeqianState( )
	for i=1,3 do
		local mc = self.panel_yeqian["mc_"..i]
		if self.MALL_SHOPS_TYPE[i] == self.currentShopId then
			mc:showFrame(2)
			self.mc_title:showFrame(i)
			self.mc_biaoti:showFrame(i)
		else
			mc:showFrame(1)
		end
	end

	echo("刷新 成功 开始=========")
	self:updateRefreshBtn()
	
end
function MallMainView:updateRefreshBtn()
	if self.currentShopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
		self.panel_shuaxinkuang:visible(true)

		-- 当前刷新次数
		local curtimes = CountModel:getMallXinAnDangNum()	
		-- 总刷新次数
		local allTimes = FuncDataSetting.getMonthCardShopFlushTime()
		-- self.txt_refresh:setString(curtimes.."/"..allTimes)

	else
		self.panel_shuaxinkuang:visible(false)
	end
end

----------------------------页签end----------------------------------
---------------------------------------------------------------------
function MallMainView:getShopListData( )
	local data = nil
	if self.currentShopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
		data = ShopModel:getShopItemList(self.currentShopId)
	elseif self.currentShopId == FuncShop.SHOP_TYPES.MALL_YONGANDANG then
		data = NoRandShopModel:getShopGoodsInfo(self.currentShopId)
	elseif self.currentShopId == FuncShop.SHOP_CHONGZHI then
		data = RechargeModel:handleRechargeData(FuncMonthCard.getRechargeData())
	end
	return data
end

--
function MallMainView:onRefreshEnd( )
	self:stopAllActions()

	local callFunc = function ()
		self:initYeQian()
		self:refreshUI()
		self:refreshYeqianState( )
	end

	self:delayCall(callFunc, 0.05)	
end

function MallMainView:refreshUI()
	self.datas = self:getShopListData()
	local height = 290
	local offsetX = -11
	-- dump(datas,"2928=========",5)
	if self.currentShopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
		self.mc_tips:setVisible(false)
		self.mc_zhongbu:showFrame(1)
		-- 底部倒计时刷新
		self:refreshPanel(true)
		height = 260
		offsetX = -12
	else
		self.mc_zhongbu:showFrame(2)
		self.mc_tips:setVisible(true)
		if self.currentShopId == FuncShop.SHOP_TYPES.MALL_YONGANDANG then
			self.mc_tips:showFrame(1)
			self:refreshTimesYongAnDang(true)
		else
			self.mc_tips:showFrame(2)
		end
	end
	self.scroll_list = self.mc_zhongbu.currentView.scroll_1

	local createFunc = function (shopData, index)
		return self:updateItem(shopData,nil,index )
	end

	local params = {
		{
			data = self.datas,
			createFunc = createFunc,
			perNums = 4,
			widthGap = 0,
			offsetX = offsetX,
        	offsetY = 10,
			heightGap = 2,
			itemRect = {x = 0, y= -height, width = 230, height = height},
			perFrame= 1,
		}
	}
	self.scroll_list:cancleCacheView()
	self.scroll_list:styleFill(params)
	self.scroll_list:hideDragBar()
	-- self.scroll_list:refreshCellView(1)
end

function MallMainView:updateItem( shopData,view,index )
	if self.currentShopId == FuncShop.SHOP_CHONGZHI then
		local item = view
		if not item then
			if shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.MONTHCARD then
				-- item = WindowsTools:createWindow("CompMallItemView")
				item = UIBaseDef:cloneOneView(self.panel_yk)
				self:updateYuekaItemPanel(item,shopData)
			elseif shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.RECHARGE then
				item = UIBaseDef:cloneOneView(self.panel_yad)
				self:updateXianyuItemPanel(item,shopData)
			elseif shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE then
				item = UIBaseDef:cloneOneView(self.panel_yad)
				self:updatePurchaseItemPanel(item,shopData)
			end
		else
			if shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.MONTHCARD then
				self:updateYuekaItemPanel(item,shopData)
			elseif shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.RECHARGE then
				self:updateXianyuItemPanel(item,shopData)
			elseif shopData._type == FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE then
				self:updatePurchaseItemPanel(item,shopData)
			end
		end
		return item
	else
		local data = self:getItemDataByShopData(shopData)
		local item = view
		if self.currentShopId == FuncShop.SHOP_TYPES.MALL_YONGANDANG then
			if not item then
				item = UIBaseDef:cloneOneView(self.panel_xad)
				self:updateShopItemPanel(item,data,index,shopData)
			else
				self:updateShopItemPanel(item,data,index,shopData)
			end
		else
			if not item then
				item = UIBaseDef:cloneOneView(self.panel_xad)
				self:updateRankShopItemPanel(item,data,index,shopData)
			else
				self:updateRankShopItemPanel(item,data,index,shopData)
			end
		end
		
		return item
	end
end

--充值 直购礼包
function MallMainView:updatePurchaseItemPanel(panel,itemData)
	local data = itemData._data
	local split_table = string.split(data.param, ",")
	local itemId = split_table[2]
	local itemNum = 1
	if split_table[3] then
		itemNum = split_table[3]
	else
		itemNum = split_table[2]
	end

	local name, nameWithNum = FuncCommon.getNameByReward(data.param)
	local spine = nil
	if tostring(split_table[1]) == FuncDataResource.RES_TYPE.ITEM then
		local itemCfg = FuncItem.getItemData(itemId)
		if itemCfg.subType_display == FuncItem.itemSubTypes_New.ITEM_SUBTYPE_201 then
			spine = FuncTreasureNew.getTreasLihui(itemId)
			spine:setScale(0.6)
			spine:pos(20, -30)
			name = GameConfig.getLanguage(FuncTreasureNew.getTreasureName(itemId))
		elseif itemCfg.subType_display == FuncItem.itemSubTypes_New.ITEM_SUBTYPE_202 then
			name = FuncPartner.getPartnerName(itemId)
		end
	end

	panel.panel_4:visible(false)
	panel.panel_2:visible(false)
	--需求 法宝需要显示spine
	if spine then
		panel.UI_1:setVisible(false)
		panel.ctn_1:removeAllChildren()
		panel.ctn_1:addChild(spine)
	else
		panel.UI_1:setVisible(false)
		-- local reward = {reward = data.param}
		-- panel.UI_1:setRewardItemData(reward)
		-- panel.UI_1:showResItemNum(true)
		if data.icon then
			local iconPath = FuncRes.iconRecharge(data.icon)
			local iconSpr = display.newSprite(iconPath)
			panel.ctn_1:removeAllChildren()
			panel.ctn_1:addChild(iconSpr)
			iconSpr:pos(0, -15)
		end
	end
	
	panel.mc_1:showFrame(2)
	local showDes = string.format("%s[item/item_small_suipian.png]x%s", name, itemNum)
	panel.mc_1.currentView.rich_1:setString(showDes)

	-- 消费金额,分转为元
	local cost = data.price / 100
	panel.panel_1.txt_3:setString("￥"..cost)

	panel.mc_buytips:showFrame(4)

	local buyTimes = CountModel:getPurchaseGiftBagNumById(data.id) or 0
	local purchaseTimes = data.purchaseTimes
	panel.txt_1:setString(GameConfig.getLanguage("#tid_activity_30000001")..(purchaseTimes - buyTimes))

	local leftTime = FuncCommon.byTimegetleftTime(TimeControler:getServerTime()) --itemData.expireTime - TimeControler:getServerTime()
	panel.txt_2:setString(GameConfig.getLanguage("#tid_activity_30000002")..TimeControler:turnTimeSec(leftTime, TimeControler.timeType_dhhmmss))
	if purchaseTimes <= buyTimes then
		panel.panel_4:visible(true)
		panel.txt_2:setVisible(true)
		panel.txt_1:setVisible(false)
		panel.txt_2:pos(44, -45)
	else
		panel.txt_1:setVisible(false)
		panel.txt_2:setVisible(false)
		panel.txt_1:pos(56, -50)
	end

	panel:setTouchedFunc(c_func(self.btnRechargeTap,self,itemData))
end

---------------------------------------------------------------
---------------------------充值相关----------------------------
-- 充值 月卡
function MallMainView:updateYuekaItemPanel(panel,itemData)
	local data = itemData._data
	panel.panel_4:visible(false)
	panel.panel_2:visible(false)
	local name = data.propName
	panel.txt_1:setString(GameConfig.getLanguage(name))

	panel.btn_1:setVisible(false)
	panel.btn_1:setTouchedFunc(function (  )
		WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[tostring(data.param)] )
	end)
	-- 消费金额,分转为元
	local cost = data.price / 100

	local iconPath = FuncRes.iconRecharge(data.icon)
	local iconSpr = display.newSprite(iconPath)
	panel.ctn_1:removeAllChildren()
	panel.ctn_1:addChild(iconSpr)

	local cardId = tostring(data.param)
	--获取剩余时间
	local leftDay = MonthCardModel:getCardLeftDay( cardId )
	local checkCanBy =  MonthCardModel:checkCanBuyCard( cardId )
	local frame = 1
	echo(leftDay,checkCanBy,"_____",cardId)

	panel:setTouchedFunc(function ()
			WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[tostring(data.param)] )
		end)
	if leftDay == 0 then
		frame = 1
		panel.mc_1:showFrame(frame)
		panel.mc_1.currentView.txt_3:setString("￥"..cost)
		-- iconSpr:setTouchedFunc(c_func(self.btnRechargeTap,self,itemData))
	else
		if checkCanBy then
			frame = 3
			panel.mc_1:showFrame(frame)
			panel.mc_1.currentView.txt_3:setString("￥"..cost)
			panel.mc_1.currentView.txt_2:setString("剩余时间:"..leftDay.."天")
		else
			frame = 2
			panel.mc_1:showFrame(frame)
			if MonthCardModel:isLingshi( cardId ) then
				panel.mc_1.currentView.txt_1:setString("永久")
			else
				panel.mc_1.currentView.txt_1:setString("剩余时间:"..leftDay.."天")
			end
		end
	end
end
-- 充值 仙玉
function MallMainView:updateXianyuItemPanel(panel,itemData)
	local data = itemData._data
	panel.panel_4:visible(false)
	panel.panel_2:visible(false)
	panel.UI_1:setVisible(false)
	panel.txt_1:setVisible(false)
	panel.txt_2:setVisible(false)

	-- 得到的仙玉数
	local haveNum = data.gold
	panel.mc_1:showFrame(1)
	panel.mc_1.currentView.panel_xianyu.txt_1:setString(haveNum)
	local offSetX = (4 - string.len(tostring(haveNum))) * 5
	panel.mc_1.currentView.panel_xianyu:setPositionX(offSetX)
	-- 消费金额,分转为元
	local cost = data.price / 100
	panel.panel_1.txt_3:setString("￥"..cost)

	-- 判断是否冲过值
	local isFirstBuy = RechargeModel:isFirstBuy(data.id)
	if not isFirstBuy then
		panel.mc_buytips:visible(false)
		-- 是否有额外奖励
		if data.giftGold and data.giftGold > 0 then
			panel.mc_buytips:showFrame(2)
			panel.mc_buytips:visible(true)
			panel.mc_buytips.currentView.txt_1:setString(data.giftGold)
		end
	else
		panel.mc_buytips:showFrame(1)
		panel.mc_buytips:visible(true)
	end

	panel.ctn_1:removeAllChildren()

	if cost > 60 then
		local animName = self.anim_table[tostring(cost)]
		self:createUIArmature("UI_fendangchongzhi", animName, panel.ctn_1, true)
	else
		local iconPath = FuncRes.iconRecharge(data.icon)
		local iconSpr = display.newSprite(iconPath)
		panel.ctn_1:addChild(iconSpr)
	end
	
	panel:setTouchedFunc(c_func(self.btnRechargeTap,self,itemData))
end

function MallMainView:btnRechargeTap( itemData )
	if itemData._type == FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE then
		local buyTimes = CountModel:getPurchaseGiftBagNumById(itemData._data.id) or 0
		local purchaseTimes = itemData._data.purchaseTimes
		if buyTimes >= purchaseTimes then
			WindowControler:showTips(GameConfig.getLanguage("#tid_activity_30000003"))
			return 
		end

		if itemData.expireTime < TimeControler:getServerTime() then
			WindowControler:showTips("商品已过期")
			return 
		end
	end
	-- 跳到充值
	-- WindowControler:showTips("跳到充值")
	MonthCardModel:setChargeData(itemData)
	-- 充值接口调用
	-- WindowControler:showTips("充值仙玉/月卡")
	dump(itemData._data,"充值信息表里的 =====",5)
	
	local data = itemData._data
	local propId = data.id
	local propName = GameConfig.getLanguage(data.typeName) 
	local propCount = data.gold or ""
	local chargeCash = data.price -- 以分为单位
	echo(propId,"______购买道具id")
	PCChargeHelper:charge(propId,propName,propCount,chargeCash)
end
---------------------------------------------------------------
---------------------------------------------------------------

------------------------商店item-------------------------------
---------------------------------------------------------------
-- 不随机商店
function MallMainView:updateShopItemPanel(panel,itemData,index,shopData)
	if tolua.isnull(panel) then
		return
	end
	-- 隐藏 折扣
	panel.panel_2:visible(false)
	-- 更新item
	local ui_item = panel.panel_3.UI_1
	local data = {
        itemId = itemData.itemId,
        itemNum = itemData.num,
        itemType = itemData.itemType
    }
    ui_item:setItemData(data)


    --商品名
    local itemName = ""
    if itemData.itemType == FuncDataResource.RES_TYPE.ITEM then
        itemName = FuncItem.getItemName(tostring(itemData.itemId))
    elseif itemData.itemType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        itemName = FuncUserHead.getHeadFrameName(tostring(itemData.itemId))
    end
    local num = itemData.num
	panel.txt_1:setString(itemName)
	-- panel.txt_3:setString(num)

	-- 当前拥有的
	panel.panel_3.txt_1:visible(false)
	panel.panel_3.txt_2:visible(false)

	-- 消耗与剩余购买次数
	local costInfo = itemData.costInfo
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    panel.panel_1.txt_3:setString(needNums)
    panel.panel_1.txt_3:setString(needNums)
	local leftTimes = itemData.leftBuyTimes
	if leftTimes > 0 then
		panel.panel_1.mc_1:showFrame(1)
		panel.panel_1.mc_1.currentView.txt_2:setString(" "..leftTimes)
		panel.panel_4:visible(false)
	else
		panel.panel_1.mc_1:showFrame(2)
		panel.panel_4:visible(true)
	end
    
	-- 购买逻辑
	panel:setTouchedFunc(c_func(self.pressBuyItem, self, panel, index, shopData))
end

function MallMainView:refreshTimesYongAnDang( isRefresh )
	if self.currentShopId ~= FuncShop.SHOP_TYPES.MALL_YONGANDANG then
		return
	end
	self.currentFrame = self.currentFrame + 1
	if not isRefresh then
		if self.currentFrame % 30 ~= 1 then
			return 
		end
	end
	
	-- local t, leftTime = ShopModel:getNextRefreshTime(self.currentShopId )  --MallMainView:getLeftTime()
	-- echo(leftTime,"_leftTime")
	local leftTime = NoRandShopModel:getLeftRefreshTime(self.currentShopId)
	local str = fmtSecToHHMMSS(leftTime)
	self.mc_tips.currentView.txt_2:setString(str)
end

function MallMainView:refreshTimesForPurchaseItem()
	if self.currentShopId ~= FuncShop.SHOP_CHONGZHI then
		return
	end

	self.currentFrame = self.currentFrame + 1

	if self.currentFrame % GameVars.GAMEFRAMERATE == 0 then
		for i,v in ipairs(self.datas) do
	    	local view = self.scroll_list:getViewByData(v)	    	
	    	if v._type == FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE and view then
	    		local leftTime = FuncCommon.byTimegetleftTime(TimeControler:getServerTime()) --v.expireTime - TimeControler:getServerTime()
	    		if leftTime >= 0 then
	    			view.txt_2:setString(GameConfig.getLanguage("#tid_activity_30000002")..TimeControler:turnTimeSec(leftTime, TimeControler.timeType_dhhmmss))
	    		end
	    	end
		end
	end
end

--随机商店
function MallMainView:updateRankShopItemPanel(panel,itemData,index,shopData)
	-- dump(itemData,"itemData -====",5)
	-- 判断是否有折扣
	local _itemId = itemData.itemId
    local _discount = shopData.discount
    if _discount then
        panel.panel_2:setVisible(true)
        local frame = math.floor(_discount/1000)
        if frame <= 0 then
        	frame = 1
        end
        if frame >= 10 then
        	panel.panel_2:visible(false)
        else
        	panel.panel_2.mc_1:showFrame(frame)
        end
        
    else
        panel.panel_2:visible(false)
    end   

	-- 更新item
	local ui_item = panel.panel_3.UI_1
	local data = {
        itemId = itemData.itemId,
        itemNum = itemData.num,
        itemType = itemData.itemType
    }
    ui_item:setItemData(data)


    --商品名
    local itemName = ""
    if itemData.itemType == FuncDataResource.RES_TYPE.ITEM then
        itemName = FuncItem.getItemName(tostring(itemData.itemId))
    elseif itemData.itemType == FuncDataResource.RES_TYPE.USERHEADFRAME then
        itemName = FuncUserHead.getHeadFrameName(tostring(itemData.itemId))
    end
    local num = itemData.num
	panel.txt_1:setString(itemName)
	-- panel.txt_3:setString(num)

	-- 当前拥有的
	panel.panel_3.txt_1:visible(false)
	panel.panel_3.txt_2:visible(false)

	-- 消耗与剩余购买次数
	local costInfo = itemData.costInfo
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    panel.panel_1.txt_3:setString(needNums)
	panel.panel_4:visible(itemData.soldOut)
	panel.panel_1.txt_1:visible(false)
	panel.panel_1.mc_1:visible(false)
    
	-- 购买逻辑
	panel:setTouchedFunc(c_func(self.pressBuyItem, self, panel, index, shopData))
end
function MallMainView:refreshPanel( isRefresh )
	if self.currentShopId ~= FuncShop.SHOP_TYPES.MALL_XINANDANG then
		return
	end
	self.currentFrame = self.currentFrame + 1
	if not isRefresh then
		if self.currentFrame % 30 ~= 1 then
			return 
		end
	end
	
	self.panel_shuaxinkuang:visible(true)
	local t, leftTime = ShopModel:getNextRefreshTime(self.currentShopId )  --MallMainView:getLeftTime()
	-- echo(leftTime,"_leftTime")
	local str = fmtSecToHHMMSS(leftTime)
	self.panel_shuaxinkuang.txt_3:setString(str)

	local refreshTimes = CountModel:getShopRefresh(self.currentShopId) or 0
	local needMoneyInfo = FuncShop.getRefreshCost(self.currentShopId, refreshTimes+1)
	local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
	self.panel_shuaxinkuang.txt_1:setString(needNum)

	local refreshTimes = CountModel:getShopRefresh(self.currentShopId) or 0
	local maxRefreshNum = FuncDataSetting.getDataByConstantName("MonthCardShopFlushTime")
	local leftRefreshTimes = tonumber(maxRefreshNum) - tonumber(refreshTimes)
	self.panel_shuaxinkuang.txt_5:setString(leftRefreshTimes)
end

-- 取第二天剩余时间
function MallMainView:getLeftTime()
	local serverTime = TimeControler:getServerTime()
	local data = os.date("*t", serverTime)
	-- -- 今天的秒数
	local currentMiao = data.hour * 60 * 60 + data.min * 60 + data.sec 
	local refrTime = 0
	-- 下午四点秒数
	if data.hour >= 4 then
		refrTime = 28 * 3600 - currentMiao
	else
		refrTime = 4*3600 - currentMiao
	end

	return refrTime + 5
end

--------------------------end----------------------------------

--购买道具
function MallMainView:pressBuyItem(itemView, index, shopData)
    if self.scroll_list:isMoving() then
        return
    end
    --判断是否解锁
    local isUnLock,str = ShopModel:checkItemByIndexAndShopId( self.currentShopId,index )
    if not isUnLock then
        WindowControler:showTips(str)
        return
    end
	local data = self:getItemDataByShopData(shopData)

    local currentShopId = self.currentShopId
    local soldOut = data.soldOut
	if soldOut then
		WindowControler:showTips({text = GameConfig.getLanguage("tid_shop_1008")})
		return
	end
	local costInfo = data.costInfo
	local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(costInfo)
	local itemId = data.itemId

	local buyFunc = function()
		if not UserModel:tryCost(resType, needNum, true, FuncCommon.CostType.BUY) then
			return
		end
		
		self:buyItemAction(data, shopData, index, data.itemId, itemView) 
	end

	local params = {
		itemId = itemId,
		costInfo = costInfo,
		viewType = FuncItem.ITEM_VIEW_TYPE.SHOP, 
		itemNum = data.num,
		okAction = c_func(buyFunc),
		closeManual = true,
		itemType = data.itemType,
		shopType = self.currentShopId,
	}
	--//注意,在弹出这个窗口的同时也需要监听商店刷新事件,商店自动刷新的那一刻,就需要关闭这个打开的UI
	self.goodsDetailView = WindowControler:showWindow("CompGoodItemView",  params)
end
function MallMainView:buyItemAction(data, shopData, index, itemId, itemView)
	local onBuyBack = c_func(self.buyItemBack, self, itemId, data, shopData, itemView,index)

	if FuncShop.isNoRandShop(self.currentShopId) then
		ShopServer:noRandShopBuyGoods(self.currentShopId, data.shopGoodsId or data.itemId , onBuyBack)
	else
		ShopServer:buyGoods(self.currentShopId, data.shopGoodsId, index, onBuyBack)
	end
end

function MallMainView:press_btn_close()
    self:startHide()
end

function MallMainView:getItemDataByShopData(shopData)
	local currentShopId = self.currentShopId
	local data = {}
	if FuncShop.isNoRandShop(currentShopId) then
		local cost = shopData.price[1] -- shopData.cost
		data = {
            shopId=currentShopId,
			itemId = shopData.itemId,
			num = shopData.num,
			costInfo = cost, --string.format("%s,%s", FuncShop.getNoRandShopCoinType(currentShopId), cost),
			soldOut = shopData.soldOut,
			shopGoodsId = shopData.id,
			itemType =  shopData.type or FuncDataResource.RES_TYPE.ITEM,
			leftBuyTimes = shopData.leftBuyTimes 
		}
	else
		local shopGoodsId = shopData.id
		local shopGoodsData = FuncShop.getGoodsInfo(currentShopId, shopGoodsId)

		local itemId = shopGoodsData.itemId
		local buyTimes = shopData.buyTimes or 0
		local costInfo = shopGoodsData.price or shopGoodsData.cost
		local num = shopGoodsData.goodsNumber or shopGoodsData.num
		data = {
	        shopId = currentShopId,
			itemId = shopGoodsData.itemId,
			num = num,
			costInfo = costInfo[1],
			itemIndex = shopData.index,
			soldOut = FuncShop.isShopItemSoldOut(currentShopId, shopData),
			shopGoodsId = shopGoodsId,
			itemType = shopGoodsData.resourceType,
	        specials=shopGoodsData.specials,
	        effectType = shopGoodsData.effectType,
	        leftBuyTimes = 1 - shopData.buyTimes
		}
		--如果是有折扣的
		if shopData.discount then
			
			data.costInfo =  FuncDataResource.getResZhekouNums( data.costInfo,shopData.discount,1 )
			echo(costInfo[1],data.costInfo ,"__sajdhsajdhsjadha",shopData.discount)
		end
		
	end
	return data
end

--购买道具返回
function MallMainView:buyItemBack(itemId, data, shopData, itemView,index, serverData)
	
	
	if self.goodsDetailView and (not tolua.isnull(self.goodsDetailView))  then
		self.goodsDetailView:startHide()
		self.goodsDetailView = nil
	end

	if not serverData.result then
		return
	end

	-- if data.leftBuyTimes then
	-- 	data.leftBuyTimes = data.leftBuyTimes - 1
	-- end
	-- if shopData.leftBuyTimes then
	-- 	shopData.leftBuyTimes = shopData.leftBuyTimes - 1
	-- end
	 
	-- if data.leftBuyTimes <= 0 then
	-- 	data.soldOut = true
	-- 	shopData.soldOut = true
	-- end

	
	
	
	local resourceType = nil
	if data.itemType then
		resourceType = data.itemType
	else
		resourceType = FuncDataResource.RES_TYPE.ITEM
	end
	local rewardStr = string.format("%s,%s,%s", resourceType, data.itemId, data.num)
	FuncCommUI.startRewardView({rewardStr})

end

function MallMainView:refreshButton()
	-- 当前刷新次数
	local curtimes = CountModel:getMallXinAnDangNum()	
	-- 总刷新次数
	local allTimes = FuncDataSetting.getMonthCardShopFlushTime()
	if allTimes <=  curtimes then 
		WindowControler:showTips(GameConfig.getLanguage("#tid_welfare_003"))
		return
	end

	local shoptype = FuncShop.SHOP_TYPES.MALL_XINANDANG
	local status = ShopModel:getLoginAttentionStatus(shoptype)
	if status then
		ShopModel:onBtnRefreshTap(shoptype)
	else
		WindowControler:showWindow("ShopRefreshView", shoptype)
	end
end

function MallMainView:close( ... )
	if self.goodsDetailView and (not tolua.isnull(self.goodsDetailView)) then
		self.goodsDetailView:startHide()
	end

	self:startHide()
	RechargeModel:setRechargeRedPoint(false)
end
-- 做特殊逻辑屏蔽跳转
function MallMainView:doSpShield()
	-- 如果战斗中屏蔽这个跳转
	if BattleControler:isInBattle() then
		self.UI_backhome:visible(false)
		self.mc_title:visible(false)
	end
end

return MallMainView
