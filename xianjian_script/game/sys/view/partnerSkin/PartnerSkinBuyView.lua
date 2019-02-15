--张强
--2017.5.19

local PartnerSkinBuyView = class("PartnerSkinBuyView", UIBase);


function PartnerSkinBuyView:ctor(winName, skinId)
    PartnerSkinBuyView.super.ctor(self, winName);
    self._skinId = skinId;
end

function PartnerSkinBuyView:loadUIComplete()
	self:registerEvent();
    self:uiAdjust();
    self:initUI();
end 

function PartnerSkinBuyView:registerEvent()
	PartnerSkinBuyView.super.registerEvent();
    self.btn_close:setTap(c_func(self.startHide, self));
end

function PartnerSkinBuyView:initUI()

    -- 皮肤卷的消耗
    local costNum = FuncPartnerSkin.getCostNum(self._skinId)

    self.txt_num:setString(costNum) 
    -- 是否永久
    self.txt_time:setString(GameConfig.getLanguage("#tid_partnerskin_001"))

    -- title
    local partnerName = FuncPartnerSkin.getPartnerName(self._skinId)
    local skinName = FuncPartnerSkin.getSkinName(self._skinId)

    self.txt_buy:setString(GameConfig.getLanguage("#tid_partnerskin_002")..partnerName..GameConfig.getLanguage("#tid_partnerskin_003").."【"..skinName.."】")

    self.btn_cancle:setTouchedFunc(c_func(self.startHide, self));
    self.btn_ok:setTouchedFunc(c_func(self.clickConfirm, self));

end

function PartnerSkinBuyView:clickConfirm()
    echo("--clickConfirm--");

    local need = FuncPartnerSkin.getCostNum(self._skinId);
    local have = UserModel:getSkinCoin();

    if need <= have then 
        -- 去购买 发消息
        PartnerSkinServer:buySkinServer(self._skinId,c_func(self.buyCallback,self))
--        self:buyCallback()
    else 
        WindowControler:showTips( GameConfig.getLanguage("#tid_partnerskin_004"));
    end 
end

function PartnerSkinBuyView:buyCallback()
    echo("--buyCallback---");
    
    WindowControler:showWindow("PartnerSkinShowView", self._skinId);

    EventControler:dispatchEvent(PartnerSkinEvent.SKIN_BUY_SUCCESS_EVENT, 
         {skinId = self._skinId})
    self:startHide();
end

--分辨率适配
function PartnerSkinBuyView:uiAdjust()
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop);
end


return PartnerSkinBuyView;

















