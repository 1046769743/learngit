local ArenaBuyCountView = class("ArenaBuyCountView", UIBase)

function ArenaBuyCountView:ctor(winName,_uiType,_param)
	ArenaBuyCountView.super.ctor(self, winName)
    self._uiType = _uiType
    self._param = _param
end

function ArenaBuyCountView:loadUIComplete()
	self:registerEvent()
    if self._uiType == FuncPvp.UICountType.BuyCountType then--购买挑战次数
        self:updateCountView()
    elseif self._uiType == FuncPvp.UICountType.Challenge5Times then --挑战5次
        self:updateChallenge5View()
    end
end


function ArenaBuyCountView:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.startHide, self))
	self:registClickClose("out")
    if self._uiType == FuncPvp.UICountType.BuyCountType then--如果是购买挑战次数UI
        self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.onBuyTap, self))
    elseif self._uiType == FuncPvp.UICountType.Challenge5Times then--挑战5次
        self.UI_1.mc_1:showFrame(2)
        self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.clickButtonConfirm,self))
        self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.startHide,self))
    end
end

function ArenaBuyCountView:onBuyTap()
    --目前购买资格已经取消了限制
--    local    _user_vip=UserModel:vip();
--    if(_user_vip <3)then
--          WindowControler:showTips(GameConfig.getLanguage("pvp_buy_operate_need_vip3_1002"));
--          self:startHide();
--          return;
--    end
    local buyCount = CountModel:getPVPBuyCount()
    local maxBuyCount = FuncDataSetting.getDataByConstantName("ArenaBuyCost")
    --检测,是否仙玉足够
    if buyCount < maxBuyCount then
        local _user_gold = UserModel:getGold()
        if _user_gold < self._buyCost then
            WindowControler:showTips(GameConfig.getLanguage("tid_shop_1030"))
            return
        end
        PVPServer:buyPVP(c_func(self.onBuyPvpCountOk, self))
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1049"))
        return
    end   
end

function ArenaBuyCountView:onBuyPvpCountOk(event)
    if event.result ~= nil then
	    EventControler:dispatchEvent(PvpEvent.PVPEVENT_BUY_CHALLENGE_COUNT_OK)
	    WindowControler:showTips(GameConfig.getLanguage("tid_common_1009"))
    else
        echo("-----ArenaBuyCountView:onBuyPvpCountOk------",event.error.message)
    end
	self:startHide()
end

--购买挑战次数
function ArenaBuyCountView:updateCountView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_pvp_1013"))
	self.UI_1.mc_1.currentView.btn_1:setBtnStr(GameConfig.getLanguage("tid_common_1008"))

	local cost = PVPModel:getNextBuyCost()
    self._buyCost = cost
	self.txt_1:setString(GameConfig.getLanguage("tid_pvp_1009"))
	self.txt_2:setString(cost)
	self.txt_3:setString(GameConfig.getLanguage("tid_pvp_1010"))
	local buyCount = CountModel:getPVPBuyCount()
--	local maxBuyCount = FuncPvp.getPVPMaxBuyTimes()
    local maxBuyCount = FuncDataSetting.getDataByConstantName("ArenaBuyCost")
    --只显示已经购买的次数
	self.txt_4:setString(GameConfig.getLanguageWithSwap("tid_pvp_1011", buyCount, maxBuyCount))

	-- self.txt_5:setString(GameConfig.getLanguage("tid_pvp_1012"))
	--完成积分任务后显示活跃已满，是否购买
    if buyCount >= 5 then
        self.txt_5:setVisible(true)
    else
        self.txt_5:setVisible(false)
    end
	
end

--挑战5次花费
function ArenaBuyCountView:updateChallenge5View()
    echo("---updateChallenge5View---");
    self.txt_4:setVisible(false)
    -- self.txt_5:setVisible(false)
    self.txt_2:setString(tostring(self._param)) --花费多少
    --如果相关的仙玉不足
    if UserModel:getGold() < self._param then
        self.txt_2:setColor(FuncCommUI.COLORS.TEXT_RED)
    end
    self.txt_3:setString(GameConfig.getLanguage("pvp_challenge_5_times_1007"))--挑战5次?

    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_pvp_003"));
    local buyCount = CountModel:getPVPBuyCount() 
    if buyCount >= 5 then
        self.txt_5:setVisible(true)
    else
        self.txt_5:setVisible(false)
    end
end
--点击确认按钮
function ArenaBuyCountView:clickButtonConfirm()   
    local buyCount = CountModel:getPVPBuyCount()
    local maxBuyCount = FuncDataSetting.getDataByConstantName("ArenaBuyCost")
    if (buyCount + 5) <= maxBuyCount then
        --关闭自身
        self.notNeedRemove = true
        self:startHide()
        EventControler:dispatchEvent(PvpEvent.PVP_CHALLENGE_5_TIMES_EVENT)
        -- EventControler:dispatchEvent("CD_ID_PVP_UP_LEVEL")
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_pvp_1049"))
    end
    
end

function ArenaBuyCountView:startHide()
    if not self.notNeedRemove then
        EventControler:dispatchEvent(PvpEvent.PVP_BUY_COUNT_VIEW_CLOSED)
    end
    
    ArenaBuyCountView.super.startHide(self)
end

return ArenaBuyCountView

