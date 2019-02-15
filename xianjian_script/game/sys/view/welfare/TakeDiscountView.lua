----六界游商抽折扣
local TakeDiscountView = class("TakeDiscountView", UIBase);

function TakeDiscountView:ctor(winName)
    TakeDiscountView.super.ctor(self, winName)
end

function TakeDiscountView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initUI()
end 

function TakeDiscountView:registerEvent()
	TakeDiscountView.super.registerEvent(self);
	EventControler:addEventListener(ActivityEvent.TRAVELSHOP_PLAY_ANIMATION_EVENT,self.playAnimation, self)  -- 播放抽奖动画
	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.initUI,self)  -- 跨天刷新界面
	EventControler:addEventListener(ActivityEvent.TRAVELSHOP_TIME_IS_OVER_EVENT,self.close,self)  -- 活动结束关闭界面
end

function TakeDiscountView:initData()
	self.map = {
		[1] = "yizhe",
		[2] = "erzhe",
		[3] = "sanzhe",
		[4] = "sizhe",
		[5] = "wuzhe",
		[6] = "liuzhe",
		[7] = "qizhe",
		[8] = "bazhe",
		[9] = "jiuzhe",
	}
end

--初始化折扣的显示
function TakeDiscountView:initUI(  )
	self.mc_1:showFrame(9)
	self.mc_2:showFrame(1)
	self.mc_3:showFrame(2)
	self.index = 1

	local lockAni = self:createUIArmature("UI_zhekou","UI_zhekou_1",self.ctn_1, false, GameVars.emptyFunc)
	lockAni:gotoAndPause(20)
	local subAnim = lockAni:getBoneDisplay(self.map[self.index]) ---- 子动画也要停掉  不然会有问题
    subAnim:gotoAndPause(20)
	lockAni:pause()
	self:updateUI()
end

function TakeDiscountView:updateUI()
	self.mc_b1:setVisible(true)
	local count = CountModel:getTravelShopTakeNum()
	-- echo("count ================ ",count)
	if count == 0 then
		self:registClickClose(-1, c_func( function()
			self:close()
	    end , self))
	    -- self:registClickClose("out")
		self.mc_b1:showFrame(2)
		self.mc_b1.currentView.panel_1.txt_2:setString(tostring(count))
		self.mc_b1.currentView.btn_1:setTouchedFunc(c_func(self.takeDiscount, self),nil,true); -- 开始
	else
		self.mc_b1:showFrame(1)
		self.mc_b1.currentView.panel_1.txt_2:setString(tostring(count))
		self.mc_b1.currentView.btn_1:setTouchedFunc(c_func(self.close, self),nil,true); -- 确定
		self.mc_b1.currentView.btn_2:setTouchedFunc(c_func(self.takeDiscount, self),nil,true); -- 再抽一次
	end
end

--抽折扣
function TakeDiscountView:takeDiscount()
	local arr,startTime,endTime,id = FuncTravelShop.getSystemHide()
	-- echo("id ================= ",id)
	if ActConditionModel:countIsOk() then
		ActConditionModel:travelTakeDiscount(id)
	else
		WindowControler:showTips("次数已经用完")
	end
end

function TakeDiscountView:playAnimation()
	--播放动画的时候不让关闭界面
	self.ctn_1:removeAllChildren()
	self.ctn_2:removeAllChildren()
	self:deleteClickClose()
	self.mc_b1:setVisible(false)
	local nowPrice,discount = FuncTravelShop.getDiscountPrice() ---现价和折扣
	discount = discount/1000   --- 转换成具体的几折  用于动画显示
	-- echo("折扣===================== ",discount,self.index)
	--播放完动画
	local lockAni = self:createUIArmature("UI_zhekou","UI_zhekou_"..self.index,self.ctn_1, false, GameVars.emptyFunc)

	local lockAniNext = self:createUIArmature("UI_zhekou","UI_zhekou_"..discount,self.ctn_1, false, GameVars.emptyFunc)
	lockAniNext:setVisible(false)

	local stopAni = self:createUIArmature("UI_zhekou","UI_zhekou_baozha0",self.ctn_2, false, GameVars.emptyFunc)
	stopAni:setVisible(false)

	lockAniNext:registerFrameEventCallFunc(1,1,function ()
		stopAni:setVisible(true)
		stopAni:startPlay(false,true)
		self.index = discount
	end)

	lockAniNext:registerFrameEventCallFunc(20,1,function ()
		lockAniNext:pause()
	end)

	lockAni:registerFrameEventCallFunc(118,1,function () 
		lockAni:pause()
		lockAni:setVisible(false)
		lockAniNext:setVisible(true)
		-- lockAniNext:gotoAndPause(1)
		lockAniNext:startPlay(false,true)
	end)
	lockAni:gotoAndPause(45)
	local subAnim = lockAni:getBoneDisplay(self.map[self.index]) ---- 子动画也要停掉  不然会有问题
    subAnim:gotoAndPause(45)
	-- lockAni:startPlay(false,true)
	lockAni:play()

	self:delayCall(function( )
 		--延迟刷新按钮  
		self:updateUI()
		--延迟刷新WanderMerchantMainView界面的价格  防止提前看到折扣后的价格
		EventControler:dispatchEvent(ActivityEvent.TRAVELSHOP_TAKE_DISCOUNT_ENENT)
  	end,3.2)
end

function TakeDiscountView:initViewAlign()
	-- TODO
end

function TakeDiscountView:close(  )
	self:startHide()
end

function TakeDiscountView:deleteMe()
	TakeDiscountView.super.deleteMe(self);
end

return TakeDiscountView;
