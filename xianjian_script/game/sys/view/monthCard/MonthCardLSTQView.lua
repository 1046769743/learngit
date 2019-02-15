local MonthCardLSTQView = class("MonthCardLSTQView", UIBase)
function MonthCardLSTQView:ctor(winName)
	MonthCardLSTQView.super.ctor(self, winName)
    
end

function MonthCardLSTQView:loadUIComplete()
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.buyCallBack, self)
	
	self.mcId = 2
	self:updateUI()
end

function MonthCardLSTQView:updateUI()
	local mcId = self.mcId
	local monthData = FuncMonthCard.getMonthCardById( mcId )

	-- 月卡支付ID
	self.propId = monthData.propId
	-- 充值数据
	self.rechargeData = FuncCommon.getRechargeDataById(self.propId)

	-- 立即获得
	local reward = monthData.firstBuyGift
	self.panel_2.mc_1:showFrame(#reward)
	local panel = self.panel_2.mc_1.currentView
	for i = 1,#reward do
		local data = {}
        data.reward = reward[i]
		
		panel["UI_"..i]:setRewardItemData(data)
        -- panel["UI_"..i]:showResItemNum(false)
        local resNum2,_,_ ,resType2,resId2 = UserModel:getResInfo( reward[i] )
		FuncCommUI.regesitShowResView(panel["UI_"..i],resType2,resNum2,resId2,reward[i],true,true)
	end

	-- btn 
	local btn = self.panel_1.btn_1
	btn:setTap(function (  )
		-- 判断特权是否开启
	    WindowControler:showWindow("WelfareNewMinView","lingshishangdian") 
	end)

	-- 添加背景
	self.ctn_1:removeAllChildren()
	local bgPath = FuncRes.iconMonthCardBg("monthcard_img_lingshi")
	local bg = display.newSprite(bgPath)
	self.ctn_1:addChild(bg)
	-- 刷新按钮
	self:upDateBtn(  )
end

function MonthCardLSTQView:upDateBtn(  )
    local isHas = MonthCardModel:checkLingShiShopOpen(  )
	local mc_btn = self.panel_2.mc_2
	if isHas then
		-- 已购买
		mc_btn:showFrame(2)
	else
		-- 未购买
		mc_btn:showFrame(1)
		mc_btn.currentView.btn_1:setTap(c_func(self.onBuyBtnTap,self))
	end
end

-- 点击了购买按钮
function MonthCardLSTQView:onBuyBtnTap()
	echo("购买月卡,id=",self.mcId)
	echo("self.propId=",self.propId)

	local data = self.rechargeData
	local propId = data.id
	local propName = GameConfig.getLanguage(data.typeName) 
	local propCount = data.gold
	local chargeCash = data.price -- 以分为单位
	PCChargeHelper:charge(propId,propName,propCount,chargeCash)
end

function MonthCardLSTQView:buyCallBack( event )
	local id = event.params
	
	if tostring(id) == tostring(self.mcId) then

		self:upDateBtn( )
	end


end

return MonthCardLSTQView
