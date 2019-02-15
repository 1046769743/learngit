--幸运转盘积分
local CompResLuckyJiFenView = class("CompResLuckyJiFenView", UIBase);

function CompResLuckyJiFenView:ctor(winName)
    CompResLuckyJiFenView.super.ctor(self, winName);
end

function CompResLuckyJiFenView:loadUIComplete()
	self:registerEvent();

    self:updateUI();
end

function CompResLuckyJiFenView:registerEvent()
	CompResLuckyJiFenView.super.registerEvent();
	EventControler:addEventListener(UserEvent.USEREVENT_ROULETTE_COIN_CHANGE,self.updateUI,self);
	self.btn_tilijiahao:setTap(c_func(self.onAddTap, self));
end

function CompResLuckyJiFenView:onAddTap()
	-- WindowControler:showWindow("GuildMainBuildView",2)
	WindowControler:showWindow("BuyRouletteCoinView")
end

function CompResLuckyJiFenView:updateUI()
	local _count = UserModel:getRouletteCoin()
	self.txt_tili:setString(_count);
	self.txt_zongtili:visible(false)
end


return CompResLuckyJiFenView;


-- if not UserModel:tryCost(FuncDataResource.RES_TYPE.SP, tonumber(battleSpCost), true) then
--         WindowControler:showWindow("CompBuySpMainView")  
--         return
--     end