local CrosspeakBuyTipsView = class("CrosspeakBuyTipsView", UIBase)

function CrosspeakBuyTipsView:ctor(winName,boxIndex)
	CrosspeakBuyTipsView.super.ctor(self, winName)
    self.boxIndex = boxIndex
end
function CrosspeakBuyTipsView:setAlignment()
    --设置对齐方式
end

function CrosspeakBuyTipsView:registerEvent()
    CrosspeakBuyTipsView.super.registerEvent();
    self:registClickClose("out")
    self.UI_1.btn_close:setTap(c_func(self.closeUI,self))
end


function CrosspeakBuyTipsView:loadUIComplete()
    self:registerEvent()

    self:initUI()
end
function CrosspeakBuyTipsView:initUI( )
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_001"))
    self.UI_1.mc_1:showFrame(1)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.buyTap,self))

    -- 缺少的仙气
    local _,leftTime,xianyuT = CrossPeakModel:isBoxCostEnough(self.boxIndex)
    local needNum = math.ceil(xianyuT * 1.0 / FuncDataSetting.getCrosspeakXianqiNum(  ) )
    local needGoldNum = xianyuT*1.0 / FuncDataSetting.getCrosspeakXianyuNum(  )
    needGoldNum = math.ceil(needGoldNum)

    self.mc_two:showFrame(1)
    local panel = self.mc_two.currentView
    panel.txt_2:setString(needGoldNum)
    -- 补足 
    local bzStr = GameConfig.getLanguage("#tid_crosspeak_021")
    panel.txt_3:setString(bzStr..needNum)
end
function CrosspeakBuyTipsView:buyTap( )
    local _,leftTime,xianyuT = CrossPeakModel:isBoxCostEnough(self.boxIndex)
    local needGoldNum = xianyuT*1.0 / FuncDataSetting.getCrosspeakXianyuNum(  )
    needGoldNum = math.ceil(needGoldNum)

    if UserModel:getGold() >= needGoldNum then
        CrossPeakServer:crossPeakBoxRewardSever(self.boxIndex,0,c_func(self.buyTapCallBack,self) )
    else
        -- 仙玉不足
        WindowControler:showTips(GameConfig.getLanguage("tid_common_1001"))
    end
end
function CrosspeakBuyTipsView:buyTapCallBack( params )
    if params.result then
        -- 关闭UI 刷新主场景挑战UI
        EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_BOX_STATE_EVENT)
        local rewards = params.result.data.rewards
        dump(rewards, "----jiangli-----", 4)
        WindowControler:showWindow("RewardSmallBgView", rewards);
        self:closeUI()
    end
end
function CrosspeakBuyTipsView:closeUI( )
    self:startHide()
end

return CrosspeakBuyTipsView
