--新版六界游商

local WanderMerchantMainView = class("WanderMerchantMainView", UIBase);

WanderMerchantMainView.cdName_wander_merchant_trigger = "wander_merchant_trigger"   -- 延迟几秒 检测本次登录是否触发游商
WanderMerchantMainView.delayTime__wander_merchant_trigger = 2

function WanderMerchantMainView:ctor(winName)
    WanderMerchantMainView.super.ctor(self, winName)
end

function WanderMerchantMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
end 

function WanderMerchantMainView:registerEvent()
	WanderMerchantMainView.super.registerEvent(self);
	self.btn_close:setTap(c_func(self.press_btn_close,self))
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.initData,self)   ---- 跨天刷新物品列表
	EventControler:addEventListener(ActivityEvent.TRAVELSHOP_TAKE_DISCOUNT_ENENT,self.refreshBtn, self)  ---- 刷新折扣后的价格
	EventControler:addEventListener(ActivityEvent.TRAVELSHOP_REFRESH_BUYBTN_STATUS, self.refreshBtn, self)
	EventControler:addEventListener(PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS, self.showReward, self)
end

function WanderMerchantMainView:initData()
	--临界情况  如果跨天的瞬间点了抽折扣 那么跨天的两秒后 会刷新一次数据 
	TimeControler:startOneCd(WanderMerchantMainView.cdName_wander_merchant_trigger,WanderMerchantMainView.delayTime__wander_merchant_trigger)
    EventControler:addEventListener(WanderMerchantMainView.cdName_wander_merchant_trigger, self.refreshBtn, self)
	self.rewardArr = {}
	if FuncTravelShop.getOpenTime_DiJiTian() > 0 then
		self.rewardArr = FuncTravelShop.getRewardArray(FuncTravelShop.getOpenTime_DiJiTian())
		self:initView()
	else
		echo("warning!!!!!!  没到开服时间 !!!!!!")
	end
end

function WanderMerchantMainView:initView()
	self.mc_tips:showFrame(3)
	self.currentFrame = 30
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)
	self:refreshBtn()
	self:updateUI()
end

--刷新界面按钮和价格
function WanderMerchantMainView:refreshBtn()
	-- echo("礼包过期时间 ============== ",UserExtModel:discountExpireTime())
	local dailyBuyTimes = CountModel:getTravelShopNum()
	-- echo("礼包购买次数 = ================ =",dailyBuyTimes)
	local count = CountModel:getTravelShopTakeNum()
	-- echo("抽奖次数 =================== ",count)
	if count == 0 then
		self.mc_tips:showFrame(1)
		self.mc_2:showFrame(2)
		self.mc_2.currentView.txt_1:setString(GameConfig.getLanguage("#tid_activity_73097"))
		self.mc_2.currentView.btn_1:setTouchedFunc(c_func(self.gotoTakeDiscount, self),nil,true);  --- 抽折扣
		self:updateBtnAnim(self.mc_2.currentView.btn_1:getUpPanel(), 98, -35)
	else
		self.mc_2:showFrame(1)
		self.mc_2.currentView.mc_btn:showFrame(1)
		self.mc_2.currentView.mc_btn:setTouchEnabled(true)
		self.mc_2.currentView.mc_btn:setTouchedFunc(c_func(self.gotoBugReward, self),nil,true);  --- 购买
		local nowPrice,discount = FuncTravelShop.getDiscountPrice() ---现价和折扣
		-- echo("discount ========== ",discount)
		nowPrice = nowPrice/100   -- 分转换成元
		self.mc_2.currentView.txt_4:setString(nowPrice.."元")
		self.mc_2.currentView.txt_2:setString("60")
		self.mc_tips:showFrame(discount/1000 + 1)
		self.mc_tips.currentView.ctn_1:removeAllChildren()
		local tipsAni = self:createUIArmature("UI_kaifuhuodong","UI_kaifuhuodong_zhekou",self.mc_tips.currentView.ctn_1, true, GameVars.emptyFunc)
		
		local btnPanel = self.mc_2.currentView.mc_btn.currentView.btn_1:getUpPanel()
		self:updateBtnAnim(btnPanel, 78, -36)
	end

	if dailyBuyTimes == 1 then
		self.ctn_anniu:removeAllChildren()
		self.mc_2:showFrame(1)
		self.mc_2.currentView.mc_btn:showFrame(3)
		self.mc_2.currentView.mc_btn:setTouchEnabled(false)
	end
end

function WanderMerchantMainView:updateBtnAnim(_btnPanel, x, y)
	local btn_anim = _btnPanel:getChildByName("saoguang")
	if not btn_anim then
		local btnAni = self:createUIArmature("UI_kaifuhuodong","UI_kaifuhuodong_sg",_btnPanel, true)
		btnAni:pos(x, y)
		btnAni:setName("saoguang")
	end
end
--道具展示
function WanderMerchantMainView:updateUI()
	
	if not self.rewardArr then
        echoError("__没有传入道具",self.rewardArr )
        return
    end
        
    local itemNum = table.length(self.rewardArr);

    if itemNum > 4 then 
        echo("warning!!!  GuildDigRewardView:initUI() itemNum is more then 4!!!");
    end

    self.mc_1:setVisible(true)
    self.mc_1:showFrame(itemNum);

    for i = 1, itemNum do
        local itemCommonUI = nil
        local itemPanel = self.mc_1:getCurFrameView()["UI_" .. tostring(i)]

        itemCommonUI = itemPanel
        itemCommonUI:setResItemData(
            {reward = self.rewardArr[i]});
        -- itemCommonUI:showResItemName(true, true);
        -- itemCommonUI:showResItemNameWithQuality()
        local resNum, _, _, resType, resId = UserModel:getResInfo(self.rewardArr[i])
        FuncCommUI.regesitShowResView(itemCommonUI, resType, resNum, resId, self.rewardArr[i], true, true)
    end

    if FuncTravelShop.getOpenTime_DiJiTian() == 1 or FuncTravelShop.getOpenTime_DiJiTian() == 2 then
    	self.panel_time.mc_t1:showFrame(1)
    elseif FuncTravelShop.getOpenTime_DiJiTian() == 3 then
    	self.panel_time.mc_t1:showFrame(2)
    end

end

--倒计时
function WanderMerchantMainView:updateTime( )
	if self.currentFrame >= 30 then
        self.currentFrame = 0
        local leftTime = ActConditionModel:getTravelShopEndTime()
        if leftTime <= 0 then
        	-- 活动结束 关闭抽折扣界面
        	EventControler:dispatchEvent(ActivityEvent.TRAVELSHOP_TIME_IS_OVER_EVENT)
            WindowControler:showTips("活动已经结束")
            self:startHide()
        end
        local downTime = NoRandShopModel:getLeftRefreshTime(FuncShop.SHOP_TYPES.MALL_YONGANDANG)  -- 偷偷用永安当倒计时
        local str = fmtSecToHHMMSS(downTime)
    	self.panel_time.txt_1:setString(str)
        --[[
        --艺术字倒计时可以用
        local length = string.len(fmtSecToHHMMSS(downTime))
        local tmp = {}
        for i = 1,length do
        	tmp[i] = string.sub(fmtSecToHHMMSS(downTime),i,i) ---- 把时间的每一个数字拆开放在table里面
        end
        for j = length, 1, -1 do     ---把时间的间隔符删除
        	if tmp[j] == ":" then
        		table.remove(tmp,j)
        	end
        end
        -- dump(tmp,"tmp ========================== ")
        for k,v in pairs(tmp) do
        	local timeView = self.panel_time["mc_"..(k - 1)]
        	timeView:showFrame(tonumber(v)+1)
        end
        ]]--
    end
    self.currentFrame = self.currentFrame + 1
end

--抽折扣
function WanderMerchantMainView:gotoTakeDiscount(  )
	WindowControler:showWindow("TakeDiscountView")
end

--购买商品
function WanderMerchantMainView:gotoBugReward(  )
	local overTime = UserExtModel:discountExpireTime()
	local nowTime = TimeControler:getServerTime()
	if nowTime > overTime then
		WindowControler:showTips("礼包已经过时")
		return 
	end
	local dailyBuyTimes = CountModel:getTravelShopNum()
	if dailyBuyTimes == 1 then
		return
	end
	echo("购买礼包")
	local itemData = FuncTravelShop.getRechargeData()
	dump(itemData,"充值信息表里的 =====",5)
	local propId = itemData.id
	local propName = GameConfig.getLanguage(itemData.typeName) 
	local propCount = itemData.gold
	local chargeCash = itemData.price -- 以分为单位
	if propCount == nil then
		propCount = ""
	end
	echo(propId,"______购买道具id")
	echo(propName,"______购买道具name")
	echo(propCount,"______购买道具count")
	echo(chargeCash,"______购买道具chargeCash")
	PCChargeHelper:charge(propId,propName,propCount,chargeCash)
end

--显示购买的商品
function WanderMerchantMainView:showReward()
	----购买完礼包再监听这个事件  防止跟抽完折扣延迟显示价格冲突
	-- EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE, self.refreshBtn, self)
	WindowControler:showWindow("RewardSmallBgView",self.rewardArr)
end

function WanderMerchantMainView:initViewAlign()
	-- TODO
end



function WanderMerchantMainView:deleteMe()
	WanderMerchantMainView.super.deleteMe(self);
end

function WanderMerchantMainView:press_btn_close()
	self:startHide()
end
return WanderMerchantMainView;




