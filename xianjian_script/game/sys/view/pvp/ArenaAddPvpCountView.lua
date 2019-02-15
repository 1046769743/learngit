local ArenaAddPvpCountView = class("ArenaAddPvpCountView", UIBase)

function ArenaAddPvpCountView:ctor(winName)
	ArenaAddPvpCountView.super.ctor(self, winName)
end

function ArenaAddPvpCountView:loadUIComplete()
	self:updateUI()
	self:registerEvent()
end

function ArenaAddPvpCountView:updateUI()
	local max = FuncPvp.getPVPChallengeMaxCount()
	--购买的挑战次数
	local buyCount = CountModel:getPVPBuyChallengeCount()
	--已经挑战的次数
	local callengeCount = CountModel:getPVPChallengeCount()
	local firstTime = PVPModel:firstTime()
	local left = FuncPvp.getPvpChallengeLeftCount(buyCount, callengeCount, firstTime)
--	self.panel_add_count.txt_count:setString(GameConfig.getLanguageWithSwap("tid_pvp_1008", left, max))
    self.panel_add_count.txt_count:setString(string.format("%d/%d",left,max))
	self.panel_add_count.btn_1:visible(left<=0)

    

    EventControler:dispatchEvent(PvpEvent.PVP_COUNT_CHANGE_EVENT);
    
end

function ArenaAddPvpCountView:registerEvent()
	self.panel_add_count.btn_1:setTap(c_func(self.onAddTap, self))
	EventControler:addEventListener(PvpEvent.PVPEVENT_REPORT_RESULT_OK, self.onReportResultOk, self)
	EventControler:addEventListener(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK, self.onBuyPvpCountOk, self)
	EventControler:addEventListener(PvpEvent.COUNT_TYPE_BUY_PVP, self.onPvpCountCd, self)
    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.updateUI,self)
    --竞技场挑战次数发生了变化
end

function ArenaAddPvpCountView:onPvpCountCd()
	self:updateUI()
	EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end

function ArenaAddPvpCountView:onBuyPvpCountOk()
	self:updateUI()
	EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end

function ArenaAddPvpCountView:onReportResultOk()
	self:updateUI()
	EventControler:dispatchEvent(PvpEvent.PVP_RED_POINT_EVENT);
end

function ArenaAddPvpCountView:onAddTap()
    --VIP为3位分水岭,大于等于则才可以购买挑战次数
--   local  _user_vip=UserModel:vip();
--   if(_user_vip<3)then
--         WindowControler:showTips(GameConfig.getLanguage("pvp_buy_operate_need_vip3_1002"));
--         return
--   end
   PVPModel:tryShowBuyPvpView()
end

return ArenaAddPvpCountView

