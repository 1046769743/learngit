-- WelfaregGtLingShiView
--aouth wk
--time 2017/8/10

local WelfaregGtLingShiView = class("WelfaregGtLingShiView", UIBase);


function WelfaregGtLingShiView:ctor(winName)
    WelfaregGtLingShiView.super.ctor(self, winName);
end

function WelfaregGtLingShiView:loadUIComplete()
	self:registerEvent();

	self:registClickClose(-1, c_func( function()
            self:clickButtonBack();
    end , self));
	self.UI_1.mc_1:getViewByFrame(1).btn_1:visible(false)
	-- self.mc_1.currentView.btn_1:visible(false)
	-- self.mc_1:getViewByFrame(1).btn_1:setTap(c_func(self.getLingShiView,self));
	-- self.mc_1:getViewByFrame(2).btn_1:setTap(c_func(self.getLingShiView,self));
	-- self:registClickClose(-1, c_func( function()
 --            self:clickButtonBack();
 --    end , self));

	self.UI_1.btn_close:setTap(c_func(self.clickButtonBack,self));

	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_common_2078"))

	self:updateUI();
end

function WelfaregGtLingShiView:registerEvent()
	EventControler:addEventListener(NewLotteryEvent.REFRESH_REPLACE_VIEW, self.reFreshUI, self)
	EventControler:addEventListener(WelfareEvent.LINGSHICLEARE_EVENT, self.reFreshUI, self)
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.reFreshUI, self)
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY, self.reFreshUI, self)
end

function WelfaregGtLingShiView:reFreshUI()
	self:updateUI()
	EventControler:dispatchEvent(ActivityEvent.REFRESH_RED_POINT)
end

--点击领取灵石按钮
function WelfaregGtLingShiView:getLingShiView()
	-- if not MonthCardModel:checkLingShiShopOpen(  ) then
	-- 	WindowControler:showTips("需激活彩依献礼才能领取")
	-- 	return 
	-- end
	-- if MonthCardModel:checkLingShiShopOpen(  ) then
		NewLotteryServer:LingQuZhaowuFu()  --发送灵石替换协议
	-- else
		-- WindowControler:showTips("需激活灵石特权才能领取")
	-- 	WindowControler:showWindow("MonthCardMainView",FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caiyi])
	-- end

	self:clickButtonBack()

end

function WelfaregGtLingShiView:updateUI()
	-- local cost = UserModel:totalCostGold();
	local alreadycost = UserModel:getGoldConsumeCoinInner()
	-- local islinshi = cost - alreadycost  --可以替换的灵石数量

	-- local strings = "每消耗<color=33ff00>1<->仙玉，可获取<color=33ff00>1<->灵石"
	-- self.rich_1:setString(strings)
	self.txt_2:setString(1)
	self.txt_4:setString(1)
	
	if alreadycost > 0 then
		self.mc_1:showFrame(1)
		self.mc_1.currentView.btn_1:setTap(c_func(self.getLingShiView, self));
	else
		--判断是否开启灵石商店
		if MonthCardModel:checkLingShiShopOpen(  ) then
			self.mc_1:showFrame(1)
			self.mc_1.currentView.btn_1:setTap(c_func(self.getLingShiView, self));
		else
			self.mc_1:showFrame(2)
			self.mc_1.currentView.btn_1:setTap(c_func(self.gotoBuyYueka, self));
		end
	end
	
	self.mc_1.currentView.txt_2:setString(alreadycost)
	
end

--灵石商店兑换条件改为购买 彩依送礼  30元月卡 FuncMonthCard.card_caiyi  "2"
function WelfaregGtLingShiView:gotoBuyYueka()
	WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caiyi])
end

function WelfaregGtLingShiView:clickButtonBack()
    self:startHide();

end


return WelfaregGtLingShiView;
