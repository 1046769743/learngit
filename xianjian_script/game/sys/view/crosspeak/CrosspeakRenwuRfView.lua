local CrosspeakRenwuRfView = class("CrosspeakRenwuRfView", UIBase)

function CrosspeakRenwuRfView:ctor(winName,id,callBack)
	CrosspeakRenwuRfView.super.ctor(self, winName)
    self.id = id
    self.callBack = callBack
end
function CrosspeakRenwuRfView:setAlignment()
    --设置对齐方式
end

function CrosspeakRenwuRfView:registerEvent()
    CrosspeakRenwuRfView.super.registerEvent();
    self:registClickClose("out")
    self.UI_1.btn_close:setTap(c_func(self.closeUI,self))
end


function CrosspeakRenwuRfView:loadUIComplete()
    self:registerEvent()

    self:initUI()
end
function CrosspeakRenwuRfView:initUI( )
    self.UI_1.txt_1:setString("刷新任务") --GameConfig.getLanguage("#tid_crosspeak_001")
    self.UI_1.mc_1:showFrame(2)
    self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.QuerenTap,self))
    self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.quxiaoTap,self))
end
function CrosspeakRenwuRfView:QuerenTap( )
    -- 判断是否满足刷新条件
    local refreshedNum = CountModel:getCrosTaskRefreshNum()
    local maxNum = FuncDataSetting.getCrosspeakRenwuRefreshNum()
    if refreshedNum >= maxNum then
        WindowControler:showTips( { text = "刷新次数已达上限" })
        self:closeUI()
    else
        CrossPeakServer:crossPeakRefreshRenWuSever(self.id,c_func(self.QuerenTapCallBack,self) )
    end 
end
function CrosspeakRenwuRfView:QuerenTapCallBack( params )
    if params.result then
        if self.callBack then
            self.callBack(params)
        end
        -- 关闭UI 刷新主场景挑战UI
        self:closeUI()
    end
end
function CrosspeakRenwuRfView:quxiaoTap( )
    self:closeUI()
end
function CrosspeakRenwuRfView:closeUI( )
    self:startHide()
end

return CrosspeakRenwuRfView
