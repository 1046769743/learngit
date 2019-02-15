local MonthCardMainView = class("MonthCardMainView", UIBase)
function MonthCardMainView:ctor(winName,_type)
    MonthCardMainView.super.ctor(self, winName)
    self.currentType = _type
    if not self.currentType then
        self.currentType = MonthCardModel:getCurrentType()
    end
end

function MonthCardMainView:loadUIComplete()
    -- 适配
    self:uiAdjust()
    -- 事件注册
    self:registerEvent()

    self:initData()
    self:initUI()
    self:refreshYeQianState()
end
function MonthCardMainView:uiAdjust()
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_back, UIAlignTypes.RightTop)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_yeqian, UIAlignTypes.Right)
end
function MonthCardMainView:registerEvent()
    self.panel_yeqian.btn_back:setTap(c_func(self.close,self))
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_REFRESH_RED_POINT_EVENT, self.refreshRedPoint, self)
    EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.refreshRedPoint, self)

end
function MonthCardMainView:initData( ... )
    self.YEQIAN = FuncMonthCard.CARDTYPE
end
function MonthCardMainView:initUI()
    -- 初始化页签
    self:initYeQian()
    self:yeQianTap( self.currentType )
end

function MonthCardMainView:onSelfPop( _type )
    -- self.currentShopId = _type
    self.currentFrame = 0
    echo("MonthCardMainView:onSelfPop:",_type)
    self:yeQianTap( _type )
end

function MonthCardMainView:initYeQian()
    local panel = self.panel_yeqian

    --1元档干掉了
    for i = 1, 3 do
        local mc = panel["mc_"..i]
        mc:showFrame(1)
        local btn = mc.currentView.btn_1
        btn:setTap(c_func(self.yeQianTap, self, i))
        local dataCfg = FuncMonthCard.getMonthCardById(self.YEQIAN[i])
        btn:getUpPanel().txt_1:setString(GameConfig.getLanguage(dataCfg.monthCardName))
        btn:getDownPanel().txt_1:setString(GameConfig.getLanguage(dataCfg.monthCardName))

        mc:showFrame(2)
        local btn2 = mc.currentView.btn_2
        btn2:getUpPanel().txt_1:setString(GameConfig.getLanguage(dataCfg.monthCardName))
        btn2:getDownPanel().txt_1:setString(GameConfig.getLanguage(dataCfg.monthCardName))


        mc:showFrame(1)
        -- mc:pos(0, 10 - 130 * (i - 2))
    end
    -- panel.panel_mail:pos(10, -365)
    self:refreshRedPoint()
end
-- 刷新页签的选中状态
function MonthCardMainView:refreshYeQianState( )
    local panel = self.panel_yeqian
    for i = 1,3 do
        local mc = panel["mc_"..i]
        if self.currentType == i then
            mc:showFrame(2)
        else
            mc:showFrame(1)
        end
    end
end
function MonthCardMainView:yeQianTap( _type )
    self.currentType = _type
    self:refreshYeQianState()
    self:refreshRedPoint()
    self:updatePanel()
end

function MonthCardMainView:refreshRedPoint( )
    local panel = self.panel_yeqian
    
    for i = 1,3 do
        local isShow = MonthCardModel:isShowRedPoint(i)
        local mc = panel["mc_"..i]
        local panelRed = mc.currentView.panel_hongdian
        if panelRed then
            panelRed:visible(isShow)
        end
    end
end


function MonthCardMainView:updatePanel()
    self.mc_top:showFrame(self.currentType)

    local dataCfg = FuncMonthCard.getMonthCardById(self.YEQIAN[self.currentType])
    self.mc_top.currentView.txt_1:setString(GameConfig.getLanguage(dataCfg.monthCardName))

    self.UI_1:visible(true)
    self.UI_2:visible(false)

    self.UI_1:updateUI(self.currentType)
end

function MonthCardMainView:close()
    self:startHide()
end

return MonthCardMainView
