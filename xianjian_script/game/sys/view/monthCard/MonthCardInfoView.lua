local MonthCardInfoView = class("MonthCardInfoView", UIBase)
function MonthCardInfoView:ctor(winName)
    MonthCardInfoView.super.ctor(self, winName)
    
end

function MonthCardInfoView:loadUIComplete()
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.buyCallBack, self)
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_TIME_OVER_EVENT, self.monthCardOver, self)
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY, self.monthCardOver, self)
    
end
function MonthCardInfoView:buyCallBack( event )
    local id = event.params
    
    if tostring(id) == tostring(self.mcId) then
        -- echoError("--yue ka gou mai chengg === ",id)
        self:updateBtn( self.mcId )



    end
end
function MonthCardInfoView:monthCardOver()
    if not self.mcId then
        self.mcId = "1"
    end
    self:updateBtn( self.mcId )
end 

function MonthCardInfoView:updateUI(_type)
    local monthCardId = FuncMonthCard.CARDTYPE[_type]
    self:updateComp( monthCardId )
    self:doSpShield()
end

--刷新通用的
function MonthCardInfoView:updateComp( mcId )
    echo("当前 月卡id == ",mcId)
    self.mcId = mcId
    -- 周卡详情
    -- self:updateRewardPanel( mcId )

    self.panel_1.panel_2.mc_1:showFrame(2)
    -- 判断是否是周卡或者是月卡
    if tonumber(mcId) == 1 then       
        self.panel_1.panel_2.txt_1:setString("（特权时间：7天）")

    else
        if tonumber(mcId) == 2 then
            self.panel_1.panel_2.mc_1:showFrame(1)
        end
        self.panel_1.panel_2.txt_1:setString("（特权时间：30天）")
    end

    -- 展示区
    local frame = tonumber(mcId)
    -- btn 
    self.btn_1:setTap(c_func(self.btnTiaozhuanTap, self,mcId))
    self.btn_2:setTap(c_func(self.btnTiaozhuanTap, self,mcId))
    -- bg
    local bgPath = FuncRes.iconMonthCardBg("monthcard_img_xiyao")
    if tonumber(self.mcId) == 1 then
        self.btn_1:visible(true)
        self.btn_2:visible(false)
        bgPath = FuncRes.iconMonthCardBg("monthcard_img_xiyao")
    elseif tonumber(self.mcId) == 2 then
        self.btn_1:visible(false)
        self.btn_2:visible(true)
        bgPath = FuncRes.iconMonthCardBg("monthcard_img_caiyi")
    elseif tonumber(self.mcId) == 3 then
        self.btn_1:visible(false)
        self.btn_2:visible(false)
        bgPath = FuncRes.iconMonthCardBg("monthcard_img_caishen")
    end

    self.ctn_1:removeAllChildren()
    local bg = display.newSprite(bgPath)
    self.ctn_1:addChild(bg)

    if tonumber(self.mcId) == 1 then
        bg:pos(0, 0)
    elseif tonumber(self.mcId) == 2 then
        bg:pos(0, 26)
    elseif tonumber(self.mcId) == 3 then
        bg:pos(0, 0)
    end
    self.panel_1.mc_2:showFrame(tonumber(self.mcId))

    -- 判断是否已购买
    self:updateBtn( mcId )

end

local BTN_TYPE = {
    CAN_GET = 1,
    GETTED = 2,
    XUFEI = 3,
    GOUMAI = 4,
}
function MonthCardInfoView:updateBtn( mcId )
    self.btnType = nil
    

    local data = FuncMonthCard.getMonthCardById( mcId )
    local mcData = MonthCardModel:getDataById( mcId )
    -- 充值数据
    local propId = data.propId
    local rechargeData = FuncCommon.getRechargeDataById(propId)

    -- 价格
    local cost = rechargeData.price / 100

    -- local btn = self.panel_1.btn_1
    local btn_mc = self.panel_1.mc_1
    -- local btnTxt = btn:getUpPanel().txt_1
    if mcData and mcData:getLeftTime() > 0 then
        if mcData:isCanGetReward() then
            -- 判断是否可领取
            btn_mc:showFrame(2)
            self.btnType = BTN_TYPE.CAN_GET
        else
            -- 提前续费时间 (天)
            local tqt = data.renewalTime
            if mcData:getLeftTimeDay() > tqt then
                -- 显示 已领取
                btn_mc:showFrame(3)
                self.btnType = BTN_TYPE.GETTED
            else    
                -- 显示续费
                btn_mc:showFrame(1)
                local btn_txt_mc = btn_mc.currentView.btn_1:getUpPanel().mc_1
                btn_txt_mc:showFrame(1)
                local btn_txt = btn_txt_mc.currentView.txt_1
                btn_txt:setString(cost.."元续费")
                self.btnType = BTN_TYPE.XUFEI
            end
        end

        local leftTxt = self.panel_1.txt_1
        leftTxt:setString("剩余"..mcData:getLeftTimeDay().."天")
        leftTxt:visible(true)
    else
        -- 没买过
        -- 首次免费体验的天数
        local freeDay = data.firstBuyTime
        local freeTxt = self.panel_1.txt_1
        if tonumber(freeDay) > 0 and not mcData then
            freeTxt:visible(true)
            freeTxt:setString("首次购买额外赠送".. freeDay .."天")
        else
            freeTxt:visible(false)
        end


        self.btnType = BTN_TYPE.GOUMAI

        btn_mc:showFrame(1)
        local btn_txt_mc = btn_mc.currentView.btn_1:getUpPanel().mc_1
        btn_txt_mc:showFrame(1)
        local btn_txt = btn_txt_mc.currentView.txt_1
        btn_txt:setString(cost.."元订购")
        self.btnType = BTN_TYPE.XUFEI
    end
    if self.btnType ~= BTN_TYPE.GETTED then
        local btn = btn_mc.currentView.btn_1
        btn:setTap(c_func(self.cardBtnTap,self,mcId,propId))
        self:setButtonAnim(btn:getUpPanel())
    end
end

function MonthCardInfoView:setButtonAnim(_btnPanel)
    local btnAnim = _btnPanel:getChildByName("saoguang")
    if not btnAnim then
        local anim = self:createUIArmature("UI_kaifuhuodong", "UI_kaifuhuodong_anniusg", _btnPanel, true)
        anim:pos(74, -38)
        anim:setName("saoguang")
    end
end

function MonthCardInfoView:cardBtnTap( mcId,propId )
    if self.btnType == BTN_TYPE.CAN_GET then
        -- 领取
        local function getCallBack( event )
            if event.result then
                dump(event.result.data.reward, "jiangli ----", 4)
                FuncCommUI.startFullScreenRewardView(event.result.data.reward, nil)
            end
            local mcData = MonthCardModel:getDataById( mcId )
            mcData:isCanGetReward()
            ----领取成功 更新红点
            EventControler:dispatchEvent(MonthCardEvent.MONTH_CARD_REFRESH_RED_POINT_EVENT)
            self:updateBtn( mcId )
        end
        CardMonthServer:getEveryDayReward(mcId,getCallBack)
    elseif self.btnType == BTN_TYPE.GETTED then
        -- 已领取
        WindowControler:showTips("奖励已领取")
    elseif self.btnType == BTN_TYPE.XUFEI then
        -- 去续费
        -- WindowControler:showTips("开始续费")
        self:buyMothCardByPropId(propId)
    elseif self.btnType == BTN_TYPE.GOUMAI then
        -- 首次购买
        -- WindowControler:showTips("首次购买")
        self:buyMothCardByPropId(propId)
    end
end

--[[
    购买月卡
]]
function MonthCardInfoView:buyMothCardByPropId( propId )
    local data = FuncCommon.getRechargeDataById(propId)
    local propId = data.id
    local propName = GameConfig.getLanguage(data.typeName) 
    local propCount = data.gold or ""
    local chargeCash = data.price -- 以分为单位
    echo(propId,"______购买道具id")
    echo(propName,"______购买道具name")
    echo(propCount,"______购买道具count")
    echo(chargeCash,"______购买道具chargeCash")
    
    if propCount == nil then
        propCount = ""
    end

    PCChargeHelper:charge(propId,propName,propCount,chargeCash)
end

-- 月卡 奖励描述
function MonthCardInfoView:updateRewardPanel( mcId )
    local data = FuncMonthCard.getMonthCardById( mcId )
    local panel_reward = self.panel_1.panel_1
    panel_reward:visible(false)
    local rw = data.monthCardDes
    rw = string.split(rw,";")

    local createItemFunc = function ( itemData )
        local view = UIBaseDef:cloneOneView(panel_reward)
        self:updateItem(view, itemData)
        return view
    end

    local _scrollParams = {
        {
            data = rw,
            createFunc = createItemFunc,
            offsetX = 0,
            offsetY = -10,
            itemRect = {x=0,y= -50,width=245,height = 50},
            widthGap = 0,
            heightGap = -13,
        }
    }
    self.list = self.panel_1.scroll_1
    self.list:styleFill(_scrollParams);
    self.list:hideDragBar()

end
function MonthCardInfoView:updateItem( view, itemData )
    view.panel_1.rich_1:setString(GameConfig.getLanguage(itemData))
end


function MonthCardInfoView:btnTiaozhuanTap( mcId )
    echo("tiaozhuan ----按钮 事件 ---- ",mcId)
    if tonumber(mcId) == 1 then 
        WindowControler:showWindow("GatherSoulMainView");
    elseif tonumber(mcId) == 2 then
        WindowControler:showWindow("WelfareNewMinView", "lingshishangdian")    
    elseif tonumber(mcId) == 3 then
        MonthCardModel:isOpenSanHuangCiFu(FuncMonthCard.card_caishen)
    end
end

function MonthCardInfoView:doSpShield()
    -- 如果战斗中屏蔽这个跳转
    if BattleControler:isInBattle() then
        self.btn_1:visible(false)
        self.btn_2:visible(false)
    end
end

return MonthCardInfoView
