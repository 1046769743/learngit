local CrosspeakUpSegmentView = class("CrosspeakUpSegmentView", UIBase)

function CrosspeakUpSegmentView:ctor(winName)
	CrosspeakUpSegmentView.super.ctor(self, winName)
end
function CrosspeakUpSegmentView:setAlignment()
    --设置对齐方式
end

function CrosspeakUpSegmentView:registerEvent()
    CrosspeakUpSegmentView.super.registerEvent();
    self:registClickClose()

end


function CrosspeakUpSegmentView:loadUIComplete()
    self:registerEvent()
    self:initUI()
end
function CrosspeakUpSegmentView:initUI( )

    FuncCommUI.addCommonBgEffect(self.ctn_efbg,10)


    local currentSegmentId = CrossPeakModel:getCurrentSegment()
    -- local currentScore = CrossPeakModel:getCurrentScore()
    -- local segmentName = FuncCrosspeak.getSegmentName( currentSegmentId )
    local segmentIcon = FuncCrosspeak.getSegmentIcon( currentSegmentId )
    -- self.segmentPanel.txt_1:setString(GameConfig.getLanguage(segmentName))
    -- self.segmentPanel.txt_2:setString(currentScore)
    local iconPath = FuncRes.crossSegmentIcon( segmentIcon )
    local icon = display.newSprite(iconPath)
    self.ctn_1:removeAllChildren()
    self.ctn_1:addChild(icon)
    icon:scale(0.7)

    -- 奖励列表
    local rewards = FuncCrosspeak.getSegmentUpReward( currentSegmentId )
    local panel = self.panel_1
    for i=1,3 do
        panel["UI_"..i]:visible(false)
    end
    if rewards then
        for i,v in pairs(rewards) do
            local rewardView = panel["UI_"..i]
            rewardView:visible(true)
            local itemData = v
            rewardView:setResItemData({reward = itemData})
            rewardView:showResItemName(false)
            rewardView:showResItemNum(true)
        end
    end
end

function CrosspeakUpSegmentView:closeUI( )
    self:startHide()
end

return CrosspeakUpSegmentView
  