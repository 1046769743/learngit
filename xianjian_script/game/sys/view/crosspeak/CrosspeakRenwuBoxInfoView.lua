local CrosspeakRenwuBoxInfoView = class("CrosspeakRenwuBoxInfoView", UIBase)

function CrosspeakRenwuBoxInfoView:ctor(winName,boxId)
	CrosspeakRenwuBoxInfoView.super.ctor(self, winName)
    self.boxId = boxId
end
function CrosspeakRenwuBoxInfoView:setAlignment()
    --设置对齐方式
end

function CrosspeakRenwuBoxInfoView:registerEvent()
    CrosspeakRenwuBoxInfoView.super.registerEvent();
    self:registClickClose("out")
end
function CrosspeakRenwuBoxInfoView:loadUIComplete()
    self:registerEvent()
    self:initUI()
end
function CrosspeakRenwuBoxInfoView:initUI( )
    local boxId = self.boxId
    local boxData = FuncCrosspeak.getBoxDataById( boxId )
    local boxName = FuncCrosspeak.getBoxName(boxId)
    self.txt_1:setString(GameConfig.getLanguage(boxName))
    local boxRewardTips = FuncCrosspeak.getBoxRewardTips(boxId)
    self.txt_2:setString(GameConfig.getLanguage(boxRewardTips))
end
function CrosspeakRenwuBoxInfoView:closeUI( )
    self:startHide()
end

return CrosspeakRenwuBoxInfoView
