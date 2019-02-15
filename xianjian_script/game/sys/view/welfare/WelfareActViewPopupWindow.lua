---- 开服抢购 没有激活夕瑶赠灯的情况下的弹窗
local WelfareActViewPopupWindow = class("WelfareActViewPopupWindow", UIBase);

function WelfareActViewPopupWindow:ctor(winName)
    WelfareActViewPopupWindow.super.ctor(self, winName)
end

function WelfareActViewPopupWindow:loadUIComplete()
	self:registerEvent()
	self:initViewAlign()
	self:initView()
end 

function WelfareActViewPopupWindow:registerEvent()
	WelfareActViewPopupWindow.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.startHide, self))
    self.btn_1:setTap(c_func(self.startHide, self))
    self:registClickClose("out")

    -- EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE, self.stoneChanged,self)
end


function WelfareActViewPopupWindow:initView()
    -- 道具展示

    self.UI_1.panel_2:visible(false)
    self.UI_1.mc_1:visible(false)

    local desc = GameConfig.getLanguage("#tid_activity_5150")
    self.txt_1:setString(desc)

    self.btn_1:setBtnStr( GameConfig.getLanguage("#tid_activity_5152"),"txt_1")
    self.btn_2:setBtnStr( GameConfig.getLanguage("#tid_activity_5151"),"txt_1")

    -- self.btn_1:setBtnStr( "离开","txt_1")
    -- self.btn_2:setBtnStr( "去购买","txt_1")

    self:clickGoBtn()
end

---跳转夕瑶赠灯
function WelfareActViewPopupWindow:clickGoBtn()
    local btn_go = self.btn_2
    btn_go:setTap(function (  )
        self:startHide()
        WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_xiyao])
    end)
end


function WelfareActViewPopupWindow:initViewAlign()
	-- TODO
end


function WelfareActViewPopupWindow:deleteMe()
	-- TODO
	WelfareActViewPopupWindow.super.deleteMe(self);
end

return WelfareActViewPopupWindow;
