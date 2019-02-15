local CrosspeakPlayerTipsView = class("CrosspeakPlayerTipsView", UIBase)

function CrosspeakPlayerTipsView:ctor(winName,_type)
	CrosspeakPlayerTipsView.super.ctor(self, winName)
    self.cpType = _type
end
function CrosspeakPlayerTipsView:setAlignment()
    --设置对齐方式
end

function CrosspeakPlayerTipsView:registerEvent()
    CrosspeakPlayerTipsView.super.registerEvent();
    self:registClickClose("out")
end 
function CrosspeakPlayerTipsView:loadUIComplete()
    self:registerEvent()
    self:initUI()
end
function CrosspeakPlayerTipsView:initUI( )
    self.panel_tips.UI_tips.btn_close:visible(false)
    self.panel_tips.UI_tips.mc_1:showFrame(1)
    self.panel_tips.UI_tips.mc_1.currentView.btn_1:setTap(c_func(self.closeUI,self))

    -- 标题
    local titleName 
    local des
    if self.cpType == 1 then
        -- 本周玩法
        local pmType = FuncCrosspeak.getPlayerModel()
        titleName = FuncCrosspeak:getPlayModelName( pmType )
        des = FuncCrosspeak:getPlayModelDes( pmType )
    elseif self.cpType == 2 then
        local curSeg = CrossPeakModel:getCurrentSegment()
        titleName = FuncCrosspeak.getBattleModelName( curSeg )
        des = FuncCrosspeak.getBattleModelDes( curSeg )
    end
    self.panel_tips.UI_tips.txt_1:setString(titleName)
    self.panel_tips.rich_1:setString(des)

end


function CrosspeakPlayerTipsView:closeUI( )
    self:startHide()
end

return CrosspeakPlayerTipsView
