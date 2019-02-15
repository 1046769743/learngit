
--[[
	Author: wk
	Date:2018-08-2
	Description: TODO
]]

local GatherSoulContinueView = class("GatherSoulContinueView", UIBase);
--[[
	data = [
		needGold = 0,
		items = {
			{id = 101,needNums = 1,hasNums = 1 },
		}
		
	]

]]

function GatherSoulContinueView:ctor(winName,frame,data ,callBack)
    GatherSoulContinueView.super.ctor(self, winName)
    self.data = data
    self.frame = frame
    self.callBack = callBack
end

function GatherSoulContinueView:loadUIComplete()
	self.btn_1_x = self.btn_1:getPositionX()
	self:registerEvent()
	self:initData()
	

end 

function GatherSoulContinueView:registerEvent()
	GatherSoulContinueView.super.registerEvent(self);
	EventControler:addEventListener(NewLotteryEvent.QUICK_BUY_SOUL,self.showGou,self);
	-- EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT,self.initData,self);

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_res1,UIAlignTypes.RightTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1,UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1,UIAlignTypes.MiddleBottom)
end

function GatherSoulContinueView:initData()
	self:showGou()
	self.btn_1:setTouchedFunc(c_func(self.sureButton, self),nil,true);
	self.panel_1.btn_1:setTouchedFunc(c_func(self.continueButton, self),nil,true);
	self.panel_1.txt_1:setTouchedFunc(c_func(self.selectButton, self),nil,true);
	self.btn_1:getUpPanel().panel_red:visible(false)
	-- self.panel_text:setVisible(false)
	
	local num = FuncDataSetting.getOriginalData("LotteryQuicklyGet")
	local rechargeNum  = UserModel:rechargeTotal()   --充值测试
	-- echoError("========rechargeNum==============",rechargeNum)

	local lotteryConditions = FuncDataSetting.getDataArrayByConstantName("LotteryConditions")
	local str = lotteryConditions[1]
	local res = string.split(str, ",")
	
	local conditionGroup = {{t = tonumber(res[1]),v = res[2]}}
	local isopen = UserModel:checkCondition( conditionGroup )
	-- echoError("=======isopen==========",isopen)
	if not isopen and rechargeNum >= num then
	--if false then
		self.btn_1:setVisible(true)
		self.panel_1:setVisible(true)
		self.btn_1:setPositionX(self.btn_1_x)
	else
		self.btn_1:setVisible(true)
		self.panel_1:setVisible(false)
		self.btn_1:setPositionX(self.btn_1_x + 160)
	end

end


function GatherSoulContinueView:continueButton()
	echo("========继续聚魂========")
	NewLotteryModel:setIsContinueSoulButton( true )
	EventControler:dispatchEvent(NewLotteryEvent.CONTINUE_BUTTON)
end

function GatherSoulContinueView:sureButton()
	echo("========确定========")
	NewLotteryModel:setIsContinueSoulButton()
	EventControler:dispatchEvent(NewLotteryEvent.CLOSE_FINISH_UI_TOBACK_FRAME)
end

function GatherSoulContinueView:showGou(pames)
	local isQuickBuy =  NewLotteryModel:checkIsQuickBuySoul()
	if isQuickBuy then
		self.panel_1.panel_1:setVisible(true)
	else
		self.panel_1.panel_1:setVisible(false)
	end

end

function GatherSoulContinueView:selectButton()
	local isQuickBuy =  NewLotteryModel:checkIsQuickBuySoul()
	if isQuickBuy then
		self.panel_1.panel_1:setVisible(false)
		NewLotteryModel:setQuickBuySoul( false )
	else
		NewLotteryModel:setQuickBuySoul( true )
		self.panel_1.panel_1:setVisible(true)
	end
	EventControler:dispatchEvent(NewLotteryEvent.QUICK_BUY_SOUL)
end


function GatherSoulContinueView:initView()
	-- TODO
end

function GatherSoulContinueView:initViewAlign()
	-- TODO
end


function GatherSoulContinueView:deleteMe()
	-- TODO

	GatherSoulContinueView.super.deleteMe(self);
end

return GatherSoulContinueView;
