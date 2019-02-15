local CrosspeakBoxInfoView = class("CrosspeakBoxInfoView", InfoTips1Base)

function CrosspeakBoxInfoView:ctor(winName,boxData)
	CrosspeakBoxInfoView.super.ctor(self, winName)
    self.boxId = boxData.boxId
    self.boxData = boxData
end
function CrosspeakBoxInfoView:setAlignment()
    --设置对齐方式
end

function CrosspeakBoxInfoView:registerEvent()
    CrosspeakBoxInfoView.super.registerEvent();
    self:registClickClose("out")
end
function CrosspeakBoxInfoView:loadUIComplete()
    self:registerEvent()
    self:initUI()
end
function CrosspeakBoxInfoView:initUI( )
    local boxId = self.boxId
    local boxData = FuncCrosspeak.getBoxDataById( boxId )
    local boxName = FuncCrosspeak.getBoxName(boxId)
    self.txt_1:setString(GameConfig.getLanguage(boxName))
    local boxRewardTips = FuncCrosspeak.getBoxRewardTips(boxId)
    self.txt_2:setString(GameConfig.getLanguage(boxRewardTips))

    -- 下方按钮显示逻辑
    local state = CrossPeakModel:checkBoxUnlockByIndex( self.boxData.index )
    -- 1当前没有解锁中的状态
    -- 2当前有解锁中的宝箱and非解锁中的宝箱
    -- 3当前有解锁中的宝箱and解锁中的宝箱
    local frame = state
    if frame == 5 then
        frame = 1
    end
    self.mc_gc:showFrame(frame)
    local panel = self.mc_gc.currentView
    if state == 1 or state == 5 then
        local btn_1 = panel.btn_1
        btn_1:setTap(c_func(self.removeBox,self))
        local btn_2 = panel.btn_2
        btn_2:setTap(c_func(self.startUnlockBox,self))
        local str = "解锁"
        btn_2:getUpPanel().txt_1:setString(str)
    elseif state == 2 then
        local btn_1 = panel.btn_1
        btn_1:setTap(c_func(self.removeBox,self))
        local btn_2 = panel.btn_2
        btn_2:setTap(c_func(self.jiasuUnlockBox,self))
        -- 消耗的资源
        local txt = self.mc_gc.currentView.panel_huobi.txt_1
        local isUnlock,haveNum,allNum = CrossPeakModel:jiasuBoxUnlock(self.boxData.index)
        if not isUnlock then
            txt:setColor(cc.c3b(255,0,0))
        else
            txt:setColor(cc.c3b(0,255,0))
        end
        txt:setString(haveNum.."/"..allNum)
        -- 立即解锁
        local str = "立即解锁"
        btn_2:getUpPanel().txt_1:setString(str)
    elseif state == 3 then
        local btn_2 = panel.btn_2
        btn_2:setTap(c_func(self.jiasuUnlockBox,self))
        --倒计时刷新
        self.currentFrame = 30
        self:updateUnlockTime( )
        self:scheduleUpdateWithPriorityLua(c_func(self.updateUnlockTime,self), 0)
        local str = "加速解锁"
        btn_2:getUpPanel().txt_1:setString(str)

        local txt = self.mc_gc.currentView.panel_huobi.txt_1
        local isUnlock,haveNum,allNum = CrossPeakModel:jiasuBoxUnlock(self.boxData.index)
        if not isUnlock then
            txt:setColor(cc.c3b(255,0,0))
        else
            txt:setColor(cc.c3b(0,255,0))
        end
        txt:setString(haveNum.."/"..allNum)
    end
end
--刷新倒计时
function CrosspeakBoxInfoView:updateUnlockTime( )
    if self.currentFrame >= 30 and self.currentFrame >= 0 then
        self.currentFrame = 0

        local currentTime = TimeControler:getServerTime()
        local leftTime = self.boxData.unlockFinishTime - currentTime
        if leftTime <= 0 then
            self:initUI( )
            self.currentFrame = -1
        else
            local str = fmtSecToHHMMSS(leftTime)
            local panel = self.mc_gc.currentView
            panel.txt_1:setString(str)
        end
    elseif self.currentFrame >= 0 then 
        self.currentFrame = self.currentFrame  + 1 
    end
end

function CrosspeakBoxInfoView:removeBox( )
    CrossPeakServer:crossPeakBoxRemoveSever(self.boxData.index,c_func(self.removeBoxCallback,self))
end
function CrosspeakBoxInfoView:removeBoxCallback(params)
    EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_BOX_STATE_EVENT)
    self:closeUI()
end
function CrosspeakBoxInfoView:startUnlockBox( )
    -- if CrossPeakModel:isGetBoxMax( ) then
    --     echoError("需要罗鑫给文本提示") -- 宝箱上限
    --     return 
    -- end
    CrossPeakServer:crossPeakBoxUnlockSever(self.boxData.index,c_func(self.startUnlockBoxCallback,self) )
end
function CrosspeakBoxInfoView:startUnlockBoxCallback( params )
    self:closeUI()
end
function CrosspeakBoxInfoView:jiasuUnlockBox( )
    if CrossPeakModel:isGetBoxMax( ) then
        -- 宝箱奖励领取上限 提示
        local str = GameConfig.getLanguage("#tid_crosspeak_tips_2027")
        WindowControler:showTips(str)
        return 
    end
    if CrossPeakModel:isBoxCostEnough(self.boxData.index) then
        CrossPeakServer:crossPeakBoxRewardSever(self.boxData.index,0,c_func(self.jiasuUnlockBoxCallback,self) )
    else
         -- 弹出仙玉兑换仙气UI
        WindowControler:showWindow("CrosspeakBuyTipsView",self.boxData.index,c_func(self.jiasuUnlockBoxCallback,self))
        self:closeUI()
    end
end
function CrosspeakBoxInfoView:jiasuUnlockBoxCallback( params )
    if params.result then
        local rewards = params.result.data.rewards
        dump(rewards, "----jiangli-----", 4)
        WindowControler:showWindow("RewardSmallBgView", rewards);
        EventControler:dispatchEvent(CrossPeakEvent.CROSSPEAK_BOX_STATE_EVENT)
    end
    self:closeUI()
end
function CrosspeakBoxInfoView:closeUI( )
    self:startHide()
end

return CrosspeakBoxInfoView
