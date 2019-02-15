local CrosspeakGuizetView = class("CrosspeakGuizetView", UIBase)

function CrosspeakGuizetView:ctor(winName)
	CrosspeakGuizetView.super.ctor(self, winName)
end
function CrosspeakGuizetView:setAlignment()
    --设置对齐方式
end

function CrosspeakGuizetView:registerEvent()
    CrosspeakGuizetView.super.registerEvent();
    self:registClickClose("out")
    self.UI_1.btn_1:setTap(c_func(self.onBtnBackTap,self))
end
--返回 
function CrosspeakGuizetView:onBtnBackTap()
    self:startHide()
end

function CrosspeakGuizetView:loadUIComplete()
    self:registerEvent()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_crosspeak_tips_2005"))
    self:initUI()
end
function CrosspeakGuizetView:initUI( )
    self.panel_1:visible(false)
    self.panel_2:visible(false)
    self.panel_3:visible(false)
    self.panel_4:visible(false)
    local createItemFunc = function (itemData)
        local itemView = UIBaseDef:cloneOneView(self["panel_"..itemData]);
        if itemData == 1 then
            self:updateItem1(itemView, itemData)
        elseif itemData == 2 then
            self:updateItem2(itemView, itemData)
        elseif itemData == 3 then 
            self:updateItem3(itemView, itemData)
        elseif itemData == 4 then 
            self:updateItem4(itemView, itemData)
        end
        
        return itemView
    end

    local _scrollParams = { 
        {
            data = {1},
            createFunc = createItemFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -130, width = 740, height = 130},
        },
        {
            data = {2},
            createFunc = createItemFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -130, width = 740, height = 130},
        },
        {
            data = {3},
            createFunc = createItemFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -400, width = 740, height = 400},
        },
        {
            data = {4},
            createFunc = createItemFunc,
            offsetX = 0,
            offsetY = 0,
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -1200, width = 740, height = 1200},
        },
    };
    self.scroll_1:styleFill(_scrollParams);
    self.scroll_1:hideDragBar()
end

function CrosspeakGuizetView:updateItem1(itemView, itemData)
    -- 段位
    local currentSegmentId = CrossPeakModel:getCurrentSegment()
    local currentScore = CrossPeakModel:getCurrentScore()
    local segmentName = FuncCrosspeak.getSegmentName( currentSegmentId )
    itemView.txt_2:setString(GameConfig.getLanguage(segmentName))
    itemView.txt_3:setString("("..currentScore..")")
    local rewards = FuncCrosspeak.getSegmentReward( currentSegmentId)
    if table.length(rewards) > 0 then 
        itemView.mc_1:showFrame(1)
        local panel = itemView.mc_1.currentView
        
        for i=1,3 do
            panel["UI_"..i]:visible(false)
        end
        for i,v in pairs(rewards) do
            local rewardView = panel["UI_"..i]
            rewardView:visible(true)
            local itemData = v
            rewardView:setResItemData({reward = itemData})
            rewardView:showResItemName(false)
            rewardView:showResItemNum(true)

            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
            FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
        end
    else
        itemView.mc_1:showFrame(2)
    end 
end
function CrosspeakGuizetView:updateItem2(itemView, itemData)
    local currentRank = CrossPeakModel:getCurrentRank( )
    local rewards = FuncCrosspeak.getRewardByRank( currentRank )
    local rankStr = ""
    if currentRank == 0 then
        rankStr = "未上榜"
    else
        rankStr = "第"..currentRank.."名"
    end
    itemView.txt_2:setString(rankStr)
    if table.length(rewards) > 0 then 
        itemView.mc_1:showFrame(1)
        local panel = itemView.mc_1.currentView
        
        for i=1,3 do
            panel["UI_"..i]:visible(false)
        end
        for i,v in pairs(rewards) do
            local rewardView = panel["UI_"..i]
            rewardView:visible(true)
            local itemData = v
            rewardView:setResItemData({reward = itemData})
            rewardView:showResItemName(false)
            rewardView:showResItemNum(true)

            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
            FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
        end
    else
        itemView.mc_1:showFrame(2)
        itemView.mc_1.currentView.txt_1:visible(false)
    end
end
function CrosspeakGuizetView:updateItem3(itemView, itemData)
    local str = GameConfig.getLanguage("#tid_corsspeak_instruction_3001")
    itemView.rich_3:setString(str)
end
function CrosspeakGuizetView:updateItem4(itemView, itemData)
    local data = FuncCrosspeak.getCrossPeakRankReward()
    local panel = itemView.panel_rulereward
    panel:visible(false)
    local posX = panel:getPositionX()
    local posY = panel:getPositionY()
    for i,v in pairs(data) do
        local _panel = UIBaseDef:cloneOneView(panel);
        _panel:pos(posX,posY - (i-1)*90)
        _panel:addto(itemView)
        if v.rankStart == v.rank then
            local _str = string.format(GameConfig.getLanguage("#tid_crosspeak_012"),tostring(v.rank))
            _panel.txt_1:setString(_str)
        else
            local _str = string.format(GameConfig.getLanguage("#tid_crosspeak_013"),tostring(v.rankStart),tostring(v.rank))
            _panel.txt_1:setString(_str)
        end
        local rewards = v.reward
        for i=1,3 do
            _panel["UI_"..i]:visible(false)
        end
        for i,v in pairs(rewards) do
            local rewardView = _panel["UI_"..i]
            rewardView:visible(true)
            local itemData = v
            rewardView:setResItemData({reward = itemData})
            rewardView:showResItemName(false)
            rewardView:showResItemNum(true)

            local  needNum,hasNum,isEnough ,resType,resId = UserModel:getResInfo(itemData)
            FuncCommUI.regesitShowResView(rewardView, resType, needNum, resId,itemData,true,true)
        end
    end
end

return CrosspeakGuizetView
