local CrosspeakBuyView = class("CrosspeakBuyView", UIBase)

function CrosspeakBuyView:ctor(winName)
	CrosspeakBuyView.super.ctor(self, winName)
end
function CrosspeakBuyView:setAlignment()
    --设置对齐方式
end

function CrosspeakBuyView:registerEvent()
    CrosspeakBuyView.super.registerEvent();
    self:registClickClose("out")
    self.UI_1.btn_close:setTap(c_func(self.closeUI,self))
end


function CrosspeakBuyView:loadUIComplete()
    self:registerEvent()

    self:initUI()
end
function CrosspeakBuyView:initUI( )
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_001"))
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.buyTap,self))

    local maxTimes = FuncCrosspeak.getMaxBuyTimes()
    local currentTimes = CountModel:getCrossBuyNum()
    if currentTimes >= maxTimes then
        self.mc_two:showFrame(2)
    else
        self.mc_two:showFrame(1)
        local panel = self.mc_two.currentView
        local cost = FuncCrosspeak.getCostGoldByTimes( currentTimes + 1 )
        panel.txt_2:setString(cost)
        
        panel.txt_5:setString(currentTimes.."/"..maxTimes)
        if UserModel:getGold() >= cost then
            panel.txt_2:setColor(cc.c3b(0x66,0xff,41))
            FilterTools.clearFilter(self.UI_1.mc_1);
        else
            panel.txt_2:setColor(cc.c3b(255,0,0))
            FilterTools.setGrayFilter(self.UI_1.mc_1);
        end
    end



    
end
function CrosspeakBuyView:buyTap( )
    local maxTimes = FuncCrosspeak.getMaxBuyTimes()
    local currentTimes = CountModel:getCrossBuyNum()
    if currentTimes >= maxTimes then
        WindowControler:showTips(GameConfig.getLanguage("#tid_crosspeak_tips_2001"))
    else
        local cost = FuncCrosspeak.getCostGoldByTimes( currentTimes + 1 )
        if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, cost, true) then
            CrossPeakServer:buyChallengeTimeServer(c_func(self.buyTapCallBack,self))
        end
        
    end
end
function CrosspeakBuyView:buyTapCallBack( params )
    if params.result then
        -- todo 
        -- 关闭UI 刷新主场景挑战UI
        self:closeUI()
        EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_CHALLENGE_TIMESCHANGE_EVENT)
        
    end
end
function CrosspeakBuyView:closeUI( )
    self:startHide()
end

return CrosspeakBuyView
