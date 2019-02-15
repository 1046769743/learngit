local BuyTiLiView = class("BuyTiLiView", UIBase);

--[[
    self.panel_1,
    self.panel_1.btn_1,
    self.panel_1.btn_back,
    self.panel_1.scale9_bg,
    self.panel_1.txt_1,
    self.panel_1.txt_2,
    self.panel_bg,
]]

function BuyTiLiView:ctor(winName)
    echo("aaa");
    BuyTiLiView.super.ctor(self, winName);
end

function BuyTiLiView:loadUIComplete()
	self:registerEvent();
    self:initUI();
end 

function BuyTiLiView:registerEvent()
	BuyTiLiView.super.registerEvent();
    self.panel_1.btn_1:setTap(c_func(self.press_panel_1_btn_1, self));
    self.panel_1.btn_back:setTap(c_func(self.press_panel_1_btn_close, self));
end

function BuyTiLiView:press_panel_1_btn_1()
    local callBack = function()
        local buyCount = CountModel:getSpBuyCount()
        local maxBuyTimes = UserModel:getSpMaxBuyTimes()
        local _str = string.format(GameConfig.getLanguage("#tid_shop_1012"),tostring(buyCount),tostring(maxBuyTimes-buyCount)) 
        local msg = _str
        WindowControler:showTips(msg)
        self:startHide();
    end

    if self:canBuySp() then
        UserServer:buySp(callBack)
    else
        local buyCount = CountModel:getSpBuyCount()
        local _str = string.format(GameConfig.getLanguage("#tid_shop_1011"),tostring(buyCount)) 
        WindowControler:showTips(_str)
    end
end

function BuyTiLiView:press_panel_1_btn_close()
    self:startHide();
end

function BuyTiLiView:initUI()
    --立绘
    local imagePath = FuncRes.npcImage(101);
    local sp = display.newSprite(imagePath); 
    local ctn = self.panel_1.ctn_1;  
    ctn:addChild(sp);  
end

-- 判断能否购买体力
function BuyTiLiView:canBuySp()
    local buyCount = CountModel:getSpBuyCount()
    local maxBuyTimes = UserModel:getSpMaxBuyTimes()

    if tonumber(buyCount) >= tonumber(maxBuyTimes) then
        return false
    end

    return true
end

function BuyTiLiView:updateUI()
	
end


return BuyTiLiView;
