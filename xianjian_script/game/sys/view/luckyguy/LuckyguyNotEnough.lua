--

local LuckyguyNotEnough = class("LuckyguyNotEnough", UIBase);

function LuckyguyNotEnough:ctor(winName)
    LuckyguyNotEnough.super.ctor(self, winName);
end

function LuckyguyNotEnough:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out")
    self:initView()
    
end 

function LuckyguyNotEnough:registerEvent()
	LuckyguyNotEnough.super.registerEvent();
    self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self));
    self.btn_1:setTap(c_func(self.press_btn_close, self));
    self.btn_2:setTap(c_func(self.buyItem, self));
end

function LuckyguyNotEnough:initView()
	-- self.UI_1.txt_1:setString("积分不足")
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_activity_30002001"))
    self.txt_1:setString(GameConfig.getLanguage("#tid_activity_30002002"))
    self.txt_2:setString(GameConfig.getLanguage("#tid_activity_30002003"))
    self.UI_1.panel_1:visible(false)
    self.UI_1.mc_1:visible(false)
end


function LuckyguyNotEnough:buyItem()
    WindowControler:showWindow("BuyRouletteCoinView")
    self:startHide()
end


function LuckyguyNotEnough:press_btn_close()
    self:startHide()
end

return LuckyguyNotEnough;
