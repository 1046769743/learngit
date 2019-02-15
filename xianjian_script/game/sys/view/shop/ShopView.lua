local ShopView = class("ShopView", UIBase)
ShopView.updateCount =0
local ITEM_MOVE_DISTANCE = 180

local PANEL_RES_MC_MAP = {
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_2] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_3] = 1,
	[FuncShop.SHOP_TYPES.PVP_SHOP] = 3,
	[FuncShop.SHOP_TYPES.CHAR_SHOP] = 4, --暂时屏蔽掉
    [FuncShop.SHOP_TYPES.ARTIFACT_SHOP] = 6, -- 神器
    [FuncShop.SHOP_TYPES.TOWER_SHOP] = 5, --爬塔
    [FuncShop.SHOP_TYPES.GUILD_SHOP] = 7, --仙盟商店  
    [FuncShop.SHOP_TYPES.WONDER_SHOP] = 8, --须臾商店 
}
--//背板类型
local   BACK_PANEL_MC_MAP={
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = 1,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_2] = 2,
	[FuncShop.SHOP_TYPES.NORMAL_SHOP_3] = 3,
	[FuncShop.SHOP_TYPES.PVP_SHOP] = 4,
	[FuncShop.SHOP_TYPES.CHAR_SHOP] = 4,
    [FuncShop.SHOP_TYPES.ARTIFACT_SHOP] = 4,
    [FuncShop.SHOP_TYPES.TOWER_SHOP] = 4,
    [FuncShop.SHOP_TYPES.GUILD_SHOP] = 4,
}

--//商店显示flash动画类型
local   ANI_SHOW_MAP={
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_1]=1,
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_2]=2,
   [FuncShop.SHOP_TYPES.NORMAL_SHOP_3]=3,
   [FuncShop.SHOP_TYPES.PVP_SHOP] = 5,
   [FuncShop.SHOP_TYPES.CHAR_SHOP] = 6,
   [FuncShop.SHOP_TYPES.ARTIFACT_SHOP] = 5,
   [FuncShop.SHOP_TYPES.TOWER_SHOP] = 5,
   [FuncShop.SHOP_TYPES.GUILD_SHOP] = 5,
}

function ShopView:ctor(winName, defaultShopId)
    ShopView.super.ctor(self, winName)
    if defaultShopId and table.find(FuncShop.SHOP_TYPES,defaultShopId) ~= false then    	
    		self.defaultShopId = defaultShopId  	
    else
    	self.defaultShopId = ShopModel:getSelectdShopId() or FuncShop.SHOP_TYPES.NORMAL_SHOP_1
    	if self.defaultShopId == FuncShop.SHOP_TYPES.GUILD_SHOP and not GuildModel:isInGuild() then
    		self.defaultShopId = FuncShop.SHOP_TYPES.NORMAL_SHOP_1
    	end
	end

	if ShopModel:isTempShop(self.defaultShopId) and ShopModel:getTempShopLeftTime(self.defaultShopId) == 0 then
		self.defaultShopId = FuncShop.SHOP_TYPES.NORMAL_SHOP_1
		ShopModel:setSelectdShopId(self.defaultShopId)
	end

	self.shop_showed = {}
    self.scroll_effect={}--//记录ScrollView缓动的情况
    self.bg = display.newSprite(FuncRes.iconBg("store_bg_dabeijing.png"))
end

function ShopView:loadUIComplete()
	self:loadkQuestUI(DailyQuestModel:getquestId());
	self.index_anim = 0
	self._anim_move_items = {}

	self.scrollOriginRect = table.deepCopy(self.scroll_list:getViewRect())
	self.scrollOriginPosX, self.scrollOriginPosY = self.scroll_list:getPosition()
	self._curshopId = self.defaultShopId
	self:registerEvent()
	self.mc_shuaxin:setVisible(false)
	self:updateOpenAnim()
	self.UI_shop_btns1:setMainView(self, FuncShop.btns_Type.type_left)
	self.UI_shop_btns2:setMainView(self, FuncShop.btns_Type.type_right)

	local isFirstGuild = false
	if self.defaultShopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
		isFirstGuild = true
	end

	self:updateButton(self._curshopId, isFirstGuild)
	self:updateUI()
	--@测试 版署包 暂时屏蔽掉商店刷新功能
	if APP_PLAT == 10001 then
		self.mc_shuaxin:visible(false)
	end
	
	ShopModel:setShopIsShow(true)
    --边缘模糊
--    self.scroll_list:enableMarginBluring();
    --显示出售银票
    local function openSellView()
        local itemD = ItemsModel:getCanSellItems()
        if #itemD > 0 then
            WindowControler:showWindow("CompSellItemsView",itemD)
        end
    end;
    self:delayCall(openSellView,0.5)

    --获取盟数据
    self:getGuildData()
    self:setViewAlign()
end

function ShopView:updateOpenAnim()
	self.panel_shuaxintips:setVisible(false)
	-- self.UI_backhome:setVisible(false)
	self.panel_title:setVisible(false)
	self.UI_shop_btns1:setVisible(false)
    self.UI_shop_btns2:setVisible(false)
    -- self.mc_res:setVisible(false)
    self.panel_cc1:setVisible(false)
    self.panel_cc2:setVisible(false)
    self.btn_back:setVisible(false)
    self.panel_ss2:setVisible(false)
    self.panel_ss1:setVisible(false)
    self.btn_refresh:setVisible(false)
    self.panel_bottom:setVisible(false)
    self.UI_shop_btns1:pos(0,0)
    self.UI_shop_btns2:pos(0,0)
    self.mc_res:pos(-70,5)
    self.UI_backhome:pos(-270,5)
    self.panel_cc1:pos(0,0)
    self.panel_cc2:pos(0,0)
    self.panel_ss1:pos(0,90)
    self.panel_ss2:pos(0,90)
    self.btn_back:pos(0,0)
    self.panel_title:pos(80,-10)
    self.btn_refresh:pos(33,0)
    self.panel_bottom:pos(0,0)

    local tempNode = display.newNode()
    tempNode:anchor(0, 1)
    self.UI_backhome:parent(tempNode)
    self.mc_res:parent(tempNode)

    local openAnim = self:createUIArmature("UI_shangdian", "UI_shangdian_donghua", self.ctn_anim, true)
    self.showAni = openAnim:getBoneDisplay("layer1")
    local anim_di = self.showAni:getBoneDisplay("node14")
    FuncArmature.changeBoneDisplay(anim_di, "panel_ss1", self.panel_ss1)
    FuncArmature.changeBoneDisplay(anim_di, "panel_ss2", self.panel_ss2)
    FuncArmature.changeBoneDisplay(self.showAni, "node1", self.bg)
    FuncArmature.changeBoneDisplay(self.showAni, "node3", self.panel_bottom)
    FuncArmature.changeBoneDisplay(self.showAni, "node15", self.panel_cc1)
    FuncArmature.changeBoneDisplay(self.showAni, "node16", self.panel_cc2)
    FuncArmature.changeBoneDisplay(self.showAni, "node17", self.panel_title)
    FuncArmature.changeBoneDisplay(self.showAni, "node18", tempNode)
    FuncArmature.changeBoneDisplay(self.showAni, "node19", self.btn_back)
    FuncArmature.changeBoneDisplay(self.showAni, "node22", self.UI_shop_btns2)
    FuncArmature.changeBoneDisplay(self.showAni, "node23", self.UI_shop_btns1)
    FuncArmature.changeBoneDisplay(self.showAni, "node20", self.btn_refresh)
    openAnim:startPlay(false, true)

    -- if not self.btnAnim then
    -- 	self.btnAnim = self:createUIArmature("UI_shangdian", "UI_shangdian_shuaxin", self.btn_refresh, true)
    -- 	self.btnAnim:pos(113, -33)
    -- end  

    self.showAni:registerFrameEventCallFunc(30, 1, function()
    		self.mc_shuaxin:setVisible(true)
    		self:setBottomJianTouVisible()
    		self:setRefreshInfoVisible()
    	end)

    self.showAni:registerFrameEventCallFunc(40, 1, function()
    		-- EventControler:dispatchEvent(ShopEvent.OPEN_ANIM_END)
    		ShopModel:setOpenAnimStatus(true)
    	end)
    if tostring(self._curshopId) == tostring(FuncShop.SHOP_TYPES.GUILD_SHOP) then
    	self.showAni:getBone("node20"):setVisible(false)
    end 
end

--刷新 新加的 向下指示箭头
function ShopView:setBottomJianTouVisible()
	if self.showJiantou then
		if not self.jiantou_anim then
			self.jiantou_anim = self:createUIArmature("UI_fsjiantou", "UI_fsjiantou_zong", self.ctn_jiantou, true)
			self.jiantou_anim:pos(20, -40)
			self.jiantou_anim:setVisible(true)
		else
			self.jiantou_anim:setVisible(true)
		end
	else
		if self.jiantou_anim then
			self.jiantou_anim:setVisible(false)
		end
	end
end

--根据商店是否勾选了 本次登陆不提示刷新 去显示下方的刷新信息
function ShopView:setRefreshInfoVisible()
	if self._curshopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
		self.panel_shuaxintips:setVisible(false)
	else
		if ShopModel:getLoginAttentionStatus(self._curshopId) then
			self:updateRefreshInfo()
			self.panel_shuaxintips:setVisible(true)
		else
			self.panel_shuaxintips:setVisible(false)
		end	
	end
end

function ShopView:updateRefreshInfo()
	local constantName = "RefreshNum1"
    if self._curshopId == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
    	self.constantName = "RefreshNum3"
    elseif self._curshopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
    	self.constantName = "MonthCardShopFlushTime"
    end

	local refreshTimes = CountModel:getShopRefresh(self._curshopId) or 0
    --判断刷新次数是否超过最大值
    local maxRefreshNum = FuncDataSetting.getDataByConstantName(constantName);
    --每次都需要+1
    local needMoneyInfo = FuncShop.getRefreshCost(self._curshopId, refreshTimes + 1)
    local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
    self.panel_shuaxintips.txt_2:setString(needNum)
    self.panel_shuaxintips.txt_4:setString(refreshTimes.."/"..maxRefreshNum)

    local mcFrame = FuncShop.RES_MC_MAP[resType]
	if mcFrame == nil then mcFrame = 1 end
	self.panel_shuaxintips.mc_1:showFrame(mcFrame)
end

function ShopView:updateButton(_shopId, _isFirstGuild)	
	self.UI_shop_btns1:selectShop(_shopId, _isFirstGuild)
	self.UI_shop_btns2:selectShop(_shopId, _isFirstGuild)
end

function ShopView:getGuildData()
	ShopModel:getGuildModelData()
end

function ShopView:updateShopBtnStatusInfo(shopId, key, value)
	local info = self.shopBtns[shopId]
	info[key]= value
end

function ShopView:setViewAlign()
	-- local btn_back_Bone = self.showAni:getBoneDisplay("node19")
	-- local title_Bone = self.showAni:getBoneDisplay("node17")
	-- local btns1_Bone = self.showAni:getBoneDisplay("node23")
	-- local btns2_Bone = self.showAni:getBoneDisplay("node22")
	-- local cc1_Bone = self.showAni:getBoneDisplay("node15")
	-- local cc2_Bone = self.showAni:getBoneDisplay("node16")
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_shop_btns1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.UI_shop_btns2, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_cc1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_cc2, UIAlignTypes.Right)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_ss1, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_ss2, UIAlignTypes.Right)
    -- self.UI_shop_btns.scroll_1:setBarBgWay(-1);
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_title, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_res, UIAlignTypes.RightTop)

end

function ShopView:registerEvent()
	ShopView.super.registerEvent(self)
	local jiantou_Node = display.newNode()
	jiantou_Node:setContentSize(cc.size(45, 45))
	jiantou_Node:anchor(0, 1)
	self.ctn_jiantou:addChild(jiantou_Node, 100)
	jiantou_Node:pos(-2, -13)
	jiantou_Node:setTouchedFunc(c_func(self.gotoNextScrollPos, self))
	--刷新按钮
	local btn_refresh = self.btn_refresh
	btn_refresh:setTap(c_func(self.onRefreshTap, self))
	btn_refresh:setTouchSwallowEnabled(true)

    self.btn_back:setTap(c_func(self.press_btn_back, self))

    --根据策划需要 判断是否需要变动的剩余时间
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self),0)

    --注册商店刷新事件 直接刷新ui
    --
	--EventControler:addEventListener(ShopEvent.SHOPEVENT_BUY_ITEM_END, self.onBuyItemEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, self.onRefreshEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_GET_SHOP_END, self.onGetShopInfoEnd, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_SHOP_JIEFENG_END, self.onShopJiefeng, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_SHOP_JIEFENG_VIEW_CLOSE, self.onShopJiefengClose, self)
	EventControler:addEventListener(ShopEvent.SHOPEVENT_NORAND_SHOP_REFRESHED, self.onNoRandShopRefreshed, self)
--//监听角色的等级,VIP变化  
    EventControler:addEventListener(UserEvent.USEREVENT_VIP_CHANGE,self.onShopJiefeng,self);
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE,self.onShopJiefeng,self);


    EventControler:addEventListener(GuildEvent.REFRESH_GUILD_WOOD_EVENT,self.onRefreshEnd,self);

    EventControler:addEventListener(ShopEvent.SHOP_REFRESH_BTNS, self.refreshButtons, self)
    

    --在当前界面玩家被剔除回调
    EventControler:addEventListener(GuildEvent.GUILD_QUILT_EVENT, self.reFreshSelectGuildBtn, self)

    -- EventControler:addEventListener(ShopEvent.OPEN_ANIM_END, self.setScrollStatus, self)

    --竞技场挑战总次数发生变化
    EventControler:addEventListener(PvpEvent.CHALLENGE_TIMES_CHANGED_EVENT, self.onRefreshEnd, self)
    --刷新状态发生了变化
    EventControler:addEventListener(ShopEvent.SHOP_REFRESH_VIEW_CLOSED, self.setRefreshInfoVisible, self)
    --跨天了 更新下方 刷新状态
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY, self.setRefreshInfoVisible, self)
end

--点击箭头 切换滚动条
function ShopView:gotoNextScrollPos()
	local itemList = self:getShopItemList(self._curshopId)
	local group, index = self.scroll_list:getGroupPos(2, true)
	if index >= #itemList then
		return
	else
		self.scroll_list:gotoTargetPos(index + 3, 1, 2, 0.5)
	end
end

function ShopView:setScrollStatus()
	local itemList = self:getShopItemList(self._curshopId)
	if #itemList > 6 then
		self.scroll_list:gotoTargetPosForOffset(6, 1, 1, 0.5, -10)
	end
end

function ShopView:reFreshSelectGuildBtn()
	if self._curshopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
		self._curshopId = FuncShop.SHOP_TYPES.NORMAL_SHOP_1
	end
	local shopId = self._curshopId
	self.UI_shop_btns1:refreshBtns()
	self.UI_shop_btns1:selectShop(shopId)
	self.UI_shop_btns2:refreshBtns()
	self.UI_shop_btns2:selectShop(shopId)
	self:updateUI()
end

function ShopView:refreshButtons(event)
	local shopId = event.params
	self:updateButton(shopId)
end

function ShopView:onNoRandShopRefreshed(event)
	local shopId = self._curshopId
	local currentShopId = event.params.currentShopId
	if FuncShop.isNoRandShop(shopId) and tostring(currentShopId) == tostring(shopId) then
		-- echoError("\n\n\n_________onNoRandShopRefreshed_________")
		self._is_refresh_show = true
		self:updateUI()
		self:showShop(shopId)
	end
end

function ShopView:onShopJiefeng(event)
	local shopId = event.params
    if type(shopId) == 'string' then
        self._curshopId = shopId
    else    
        shopId = self._curshopId
    end
    echo("此时解锁商店ID = "..shopId)
	self.UI_shop_btns1:refreshBtns()
	self.UI_shop_btns1:selectShop(shopId)
	self.UI_shop_btns2:refreshBtns()
	self.UI_shop_btns2:selectShop(shopId)
	self:updateUI()
end

function ShopView:onShopJiefengClose(event)
	local shopId = event.params
end

function ShopView:onBuyItemEnd()
	self:updateUI()
end

function ShopView:onRefreshEnd(event)
	
	local currentShopId = event.params.currentShopId
	if tostring(currentShopId) == tostring(self._curshopId) then
		-- echoError("\n\n_____onRefreshEnd____")
		self._is_refresh_show = true
		self:updateUI()
		self:showShop(self._curshopId)
	end	
end

function ShopView:onGetShopInfoEnd()
	self:updateUI()
end

function ShopView:updateFrame(dt)
    self.updateCount = self.updateCount +1
    --一秒刷新一次
    if self.updateCount % GameVars.GAMEFRAMERATE  == 0 then
        self:updateBottomPanelInfo()
    end
end

function ShopView:updateBottomPanelInfo()
	local shopId = self._curshopId
	if FuncShop.isNoRandShop(shopId) then
		self:updateNoRandomShopBottomPanel()
	else
		self:updateNormalShopBottomPanel()
	end
end

--按钮边上的刷新次数处理
function ShopView:updateNoRandomShopBottomPanel()
	-- self.mc_shuaxin:showFrame(3)
	local countType = FuncCount.COUNT_TYPE.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES

	if self._curshopId == FuncShop.SHOP_TYPES.TOWER_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_TOWERSHOP_DAY_TIMES
	end
	if self._curshopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_TOWERSHOP_DAY_TIMES
	end
	if self._curshopId == FuncShop.SHOP_TYPES.WONDER_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_WONDERSHOP_DAY_TIMES
	end
	local m = FuncCount.getMinute(countType)
	local h = FuncCount.getHour(countType)
	h = tonumber(h)
	--刷新时间显示
	-- local pre = "今日"
	-- local now = TimeControler:getServerTime()
	-- local d = os.date("*t", now)
	local refresh_t, isToday = FuncShop.getNoRandShopRefreshTime(self._curshopId)
	-- if not isToday then
	-- 	pre = "明日"
	-- end
	local timeStr = string.format("%02d:%02d", h, m)
	local panel_refresh = self.mc_shuaxin.currentView.panel_time
	-- txt_refresh:setString(string.format(GameConfig.getLanguage("#tid_shop_1001"), timeStr))
	panel_refresh.txt_time_tip:setString(string.format(GameConfig.getLanguage("#tid_shop_1001"), ""))
	panel_refresh.txt_refresh_time:setString(timeStr)
end

--底部刷新时间显示
function ShopView:updateNormalShopBottomPanel()
	local shopId = self._curshopId
	local panel_time = self.mc_shuaxin.currentView.panel_time
	if not panel_time then return end

	local isTempShop = ShopModel:isTempShop(shopId)
	local timeToShow = 0
	if isTempShop then
		timeToShow = ShopModel:getTempShopLeftTime(shopId)
		local shopName = FuncShop.getShopNameById(shopId)
		panel_time.txt_time_tip:setString(GameConfig.getLanguageWithSwap("tid_shop_1021", shopName))
		panel_time.txt_refresh_time:setString(fmtSecToHHMMSS(timeToShow))
		--//注意一下的代码会将程序陷入死递归,实际上是不应该有的
		-- ,档外部系统进入临时商店的时候需要实现[判断一下商店是否已经关闭了,
		-- 而不是进入商店后在判断
		if timeToShow == 0 then
--            assert(false,"User should judge whether temple shop is opened.");
			local windowView = WindowControler:getCurrentWindowView()
			if WindowControler:checkCurrentViewName("CompGoodItemView") then
				windowView:startHide()
			end
			if ShopModel:isTempShop(self.defaultShopId) and ShopModel:getTempShopLeftTime(self.defaultShopId) == 0 then
				self.defaultShopId = FuncShop.SHOP_TYPES.NORMAL_SHOP_1
			end
			self._curshopId = self.defaultShopId
			self:updateUI()
            self.UI_shop_btns1:refreshBtns()
            self.UI_shop_btns1:selectShop(self._curshopId)
            self.UI_shop_btns2:refreshBtns()
			self.UI_shop_btns2:selectShop(self._curshopId)
		end
	else
		--非临时商店显示的是下次刷新时间
		local targetTime,left = ShopModel:getNextRefreshTime(shopId) 
		timeToShow = targetTime
		panel_time.txt_time_tip:setString(string.format(GameConfig.getLanguage("#tid_shop_1001"), ""))
		panel_time.txt_refresh_time:setString(fmtSecToHHMM(timeToShow))
	end
end

--返回按钮
function ShopView:press_btn_back()
	ShopModel:setShopIsShow(false)
	ShopModel:setOpenAnimStatus(false)
    self:startHide()

    ShopModel:showHomeAnimForShop()
end

function ShopView:onRefreshTap()
	local currentShopId = self._curshopId
	local status = ShopModel:getLoginAttentionStatus(currentShopId)
	if status then
		ShopModel:onBtnRefreshTap(currentShopId)
	else
		WindowControler:showWindow("ShopRefreshView", currentShopId)
	end
end

--刷新ui
function ShopView:updateUI()
	self:updateBottomPanelInfo()
end

function ShopView:getItemDataByShopData(shopData)
	local currentShopId = self._curshopId
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
		}
	else
		local shopGoodsId = shopData.id
		local shopGoodsData = FuncShop.getGoodsInfo(currentShopId, shopGoodsId)
		-- dump(shopGoodsData,"单个数据 = = = = = =")
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
			soldOut = buyTimes > 0,
			shopGoodsId = shopGoodsId,
			itemType = shopGoodsData.resourceType,
            specials=shopGoodsData.specials,
            effectType = shopGoodsData.effectType,
		}
	end
	return data
end

function ShopView:showReFeshButton(shopId)
	local btn_refresh = self.btn_refresh
	if shopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
		btn_refresh:setVisible(false)
		self.showAni:getBone("node20"):setVisible(false)
	else
		btn_refresh:setVisible(true)
		self.showAni:getBone("node20"):setVisible(true)
	end
end


function ShopView:delayShowShop(shopId)
	self:delayCall(c_func(self.showShop, self, shopId), 0.1)
end

function ShopView:showShop(shopId)
    -- echoError("\n\n商店ID = "..shopId)
	local isOpen = ShopModel:checkIsOpen(shopId) 
    self._curshopId = shopId
    self:showReFeshButton(shopId)
	self:updateShopCoinPanel(shopId)
	self:updateBottomRefreshPanel(shopId)

	self:updateBottomPanelInfo()
	self.scroll_list:visible(true)
    --商店标题
    -- echo("\n\nFuncShop.ShopTitleMap[shopId]===", FuncShop.ShopTitleMap[shopId], "shopId===", shopId)
    -- self.mc_biaoti:showFrame(FuncShop.ShopTitleMap[shopId])
    self.panel_title.mc_1:showFrame(1)
	--获取商店列表
	local itemList = self:getShopItemList(shopId)
	self._anim_move_items = {}
	self.shop_data_list = itemList
	local itemNum = #itemList
	local createFunc = function (shopData, index)
		self.index_anim = self.index_anim + 1
		local data = self:getItemDataByShopData(shopData)
        local global_index=BACK_PANEL_MC_MAP[shopId];
		local item = WindowsTools:createWindow("CompShopItemView",
				  data, index,global_index,ANI_SHOW_MAP[shopId])
		if not self._is_refresh_show then
			item:setOpenAnim(self.index_anim)
		end
		-- dump(shopData,"1111111211111111111111111")
		item.btn_1:setTap(c_func(self.pressBuyItem, self, item, index, shopData))
--		self:checkAnimInitMoveItems(item, itemNum)
		return item
	end

	local updateFunc = function (shopData,view,index)
		-- echoError("____index____", index, "self._is_refresh_show==", self._is_refresh_show)
		if self._is_refresh_show then			
			self:animShowItem(view, shopData)
		else
			local data = self:getItemDataByShopData(shopData)
			view:setItemData(data)
			view:updateUI()
			view.btn_1:setTap(c_func(self.pressBuyItem, self, view, index, shopData))
		end
	end
	local offsetX, offsetY, widthGap, heightGap = self:getItemScrollValues(#itemList)
	local params = {
		{
			data = itemList,
			createFunc = createFunc,
			updateFunc = updateFunc,
			perNums = 3,
			offsetX = offsetX,
			offsetY = offsetY,
			widthGap = widthGap,
			heightGap = heightGap,
			itemRect = {x = 0, y= -200, width = 250, height = 190},
			perFrame=3,
		}
	}
	-- self.scroll_list:cancleCacheView( )
    -- self.scroll_list:setFillEaseTime(0.3);
--    self.scroll_list:setItemAppearType(1, false);	
	self.scroll_list:styleFill(params)
	self.scroll_list:refreshCellView(1)
	-- self.scroll_list:easeMoveto(0,0,0)
    self.scroll_effect[shopId]=true
	if #itemList <= 6 then
		self.showJiantou = false
	else
		self.showJiantou = true
	end

    self.scroll_list:setCanScroll(true)
    self.scroll_list:hideDragBar()
	if ShopModel:getOpenAnimStatus() then
		self:setBottomJianTouVisible()
    	self:setRefreshInfoVisible()
	end
end

function ShopView:checkAnimInitMoveItems(item, totalNum)
	if self.shop_showed[self._curshopId]~=nil then
		return false
	end
	local items = self._anim_move_items
	local num = 6
	if totalNum >6 then
		num = 9
		if num > totalNum then
			num = totalNum
		end
	else
		if num < totalNum then
			num = totalNum
		end
	end
	if #items < num then
		table.insert(items, item)
		local count = math.floor(#items/3) + 1
		if #items%3 == 0 then
			count = count - 1
		end
		item:visible(false)
		item:runAction(act.moveby(0, 0, -ITEM_MOVE_DISTANCE*count))
	end
	if #items >= num then
		self:doAnimMoveItems(items, num)
	end
end

function ShopView:doAnimMoveItems(items, num)
	local count = 0
	for i=1,num,3 do
		count = count + 1
		for j=i,i+2 do
			local item = items[j]
			if item ~= nil then
				item:visible(true)
				item:runAction(self:makeItemMoveAction(count, item))
			end
		end
	end
	self.shop_showed[self._curshopId] = true
end

function ShopView:makeItemMoveAction(count, item)
	local frameTime = 1.0/GameVars.GAMEFRAMERATE
	--local itemVisible = function()
	--    --item:visible(true)
	--end
	local offset = 1*(count-1)
	local act = act.sequence(
		--act.callfunc(itemVisible),
		act.delaytime((count-1)*2*frameTime),
		act.easebackout(act.moveby(frameTime*6, 0, ITEM_MOVE_DISTANCE*count-5-offset)),
		act.moveby(frameTime*3, 0, 10+offset*2),
		act.moveby(frameTime*2, 0, -5-offset)
	)
	return act
end

function ShopView:getShopItemList(shopId)
	local TYPES = FuncShop.SHOP_TYPES
	local shop_data_in_shop_model_ids = {
        TYPES.NORMAL_SHOP_1, 
        TYPES.NORMAL_SHOP_2, 
        TYPES.NORMAL_SHOP_3, 
        TYPES.ARTIFACT_SHOP,
        TYPES.CHAR_SHOP,
    }
	if table.find(shop_data_in_shop_model_ids, shopId) then
		return ShopModel:getShopItemList(shopId)
	elseif shopId == TYPES.PVP_SHOP then
		return NoRandShopModel:getShopGoodsInfo(TYPES.PVP_SHOP)
    elseif shopId == TYPES.TOWER_SHOP then
        return NoRandShopModel:getShopGoodsInfo(TYPES.TOWER_SHOP)
    elseif shopId == TYPES.GUILD_SHOP then
    	return NoRandShopModel:getShopGoodsInfo(TYPES.GUILD_SHOP) --FuncShop.getGuildShopGoods()--TYPES.GUILD_SHOP)
    elseif shopId == TYPES.WONDER_SHOP then
    	return NoRandShopModel:getShopGoodsInfo(TYPES.WONDER_SHOP)
	end
	
end

function ShopView:updateShopCoinPanel(shopId)
	local mcFrame = PANEL_RES_MC_MAP[shopId]
	if not mcFrame then mcFrame = 1 end
	self.mc_res:showFrame(mcFrame)
end

function ShopView:updateBottomRefreshPanel(shopId)
	self.mc_shuaxin:showFrame(1)
end

function ShopView:animShowItem(item, shopData)
	local data = self:getItemDataByShopData(shopData)
	local scalePos = cc.p(260/2,-191/2)
	local scaleTime = 0.1
	local setData = act.callfunc(c_func(item.setItemData, item, data))
	local updateItemUI = act.callfunc(c_func(item.updateUI, item))
	local scaleBig = item:getFromToScaleAction(scaleTime, 0.1, 0.1, 1, 1, false, scalePos)
	item:runAction(act.sequence(setData, updateItemUI, scaleBig))
	if item:getItemIndex() >= #self.shop_data_list then
		self._is_refresh_show = false
	end
end

-- return ffsetx, offsety, widthgap, heightgap
function ShopView:getItemScrollValues(itemNum)
	echo("-------------- itemNum -== ",itemNum)
	if itemNum <= 6 then
		return 3, 20, 4, 12 
	else
		return 3, 20, 4, 12 
	end
end

--购买道具
function ShopView:pressBuyItem(itemView, index, shopData)
	-- dump(shopData, "\n\nshopData===")

    if self.scroll_list:isMoving() then
        return
    end
    --判断是否解锁
    local isUnLock,str = ShopModel:checkItemByIndexAndShopId( self._curshopId,index )
    if not isUnLock then
        WindowControler:showTips(str)
        return
    end
	local data = self:getItemDataByShopData(shopData)
	-- dump(data,"22222222222=============")
	-- echo("11111111111111111====",index)
    local currentShopId = self._curshopId
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

	local isUnlock, unLockStr = nil
	if self._curshopId == FuncShop.SHOP_TYPES.GUILD_SHOP then
        isUnlock, unLockStr = ShopModel:getGuildItemUnlock(index)
    elseif self._curshopId == FuncShop.SHOP_TYPES.PVP_SHOP then
    	isUnlock, unLockStr = ShopModel:getPvpShopItemUnLock(index)
    elseif self._curshopId == FuncShop.SHOP_TYPES.TOWER_SHOP then
       	isUnlock, unLockStr = ShopModel:checkIsTowerShopItemUnlock(index)
    elseif self._curshopId == FuncShop.SHOP_TYPES.WONDER_SHOP then
    	isUnlock, unLockStr = ShopModel:getWonderShopItemUnlock(index)
    end

	local params = {
		itemId = itemId,
		costInfo = costInfo,
		viewType = FuncItem.ITEM_VIEW_TYPE.SHOP,
		itemNum = data.num,
		okAction = c_func(buyFunc),
		closeManual = true,
		itemType = data.itemType,
		---[[   新加的类型 wk 
		shopType = self._curshopId,
		isunlock = isUnlock,
		tipStr = unLockStr, 
		--]]
	}
--//注意,在弹出这个窗口的同时也需要监听商店刷新事件,商店自动刷新的那一刻,就需要关闭这个打开的UI
	self.goodsDetailView = WindowControler:showWindow("CompGoodItemView",  params)
end

function ShopView:buyItemAction(data, shopData, index, itemId, itemView)
	local onBuyBack = c_func(self.buyItemBack, self, itemId, data, shopData, itemView)
	local currentShopId = self._curshopId
	if FuncShop.isNoRandShop(currentShopId) then
		ShopServer:noRandShopBuyGoods(currentShopId, data.shopGoodsId or data.itemId , onBuyBack)
	else
		ShopServer:buyGoods(self._curshopId, data.shopGoodsId, index, onBuyBack)
	end
end

--购买道具返回
function ShopView:buyItemBack(itemId, data, shopData, itemView, serverData)
	if self.goodsDetailView then
		self.goodsDetailView:close()
		self.goodsDetailView = nil
	end
	if not serverData.result then
		return 
	end
	
	data.soldOut = true
	shopData.soldOut = true
	itemView:setItemData(data)
	itemView:playSoldOutAnim()
	
	local resourceType = nil
	if data.itemType then
		resourceType = data.itemType
	else
		resourceType = FuncDataResource.RES_TYPE.ITEM
	end
	local rewardStr = string.format("%s,%s,%s", resourceType, data.itemId, data.num)
	FuncCommUI.startRewardView({rewardStr})

	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_BUY_ITEM_END,data)
end

return ShopView
