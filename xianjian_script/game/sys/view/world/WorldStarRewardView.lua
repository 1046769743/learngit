local WorldStarRewardView = class("WorldStarRewardView", UIBase);

function WorldStarRewardView:ctor(winName,data)
    WorldStarRewardView.super.ctor(self, winName);

    self:initData(data)
end

function WorldStarRewardView:loadUIComplete()
	self:registerEvent();
    self:registClickClose("out")

    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid6010"))
    self.UI_1.mc_1:setVisible(false)

    self:updateUI()
end 

function WorldStarRewardView:registerEvent()
	WorldStarRewardView.super.registerEvent();
    self.UI_1.btn_close:setTap(c_func(self.press_panel_bg_btn_close, self));
end

function WorldStarRewardView:initData(data)
    self.maxRewardNum = 6

    -- 已获得星总数量
    self.ownStar = data.ownStar
    -- 解锁宝箱需求的总数量
    self.needStarNum = data.needStarNum
    self.storyId = data.storyId
    self.boxIndex = data.boxIndex
    self.boxStatus = data.boxStatus

    -- 获取奖励数据
    self.storyData = FuncChapter.getStoryDataByStoryId(self.storyId)
    self.rewardData = self.storyData["bonus" .. self.boxIndex]
end 


function WorldStarRewardView:updateUI()
    -- 根据宝箱状态，显示操作按钮的状态
    local boxStatus = self.boxStatus

	local rewardNum = #self.rewardData
    -- 领取的标记panel
    self.panel_1.panel_lv:setVisible(false)

    for i=1,rewardNum do
        local itemView = self.panel_1["UI_"..i]
        itemView:setVisible(true)

        local rewardStr = self.rewardData[i]
        local params = {
            reward = rewardStr,
        }
        itemView:setRewardItemData(params)
        itemView:showResItemName(true,true,nil,true)
        itemView:showResItemNameWithQuality()
        itemView:showResItemNum(true)

        if boxStatus == WorldModel.starBoxStatus.STATUS_USED then 
            -- 已领取的标记
            local getTipView = UIBaseDef:cloneOneView(self.panel_1.panel_lv)
            itemView:addChild(getTipView)
            getTipView:pos(-3,0)

            local panelBg = getTipView.panel_1
            -- 如果是碎片
            if itemView:checkIsPiece() then
                local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
                headMaskSprite:anchor(0,1)
                headMaskSprite:pos(3,-2)
                headMaskSprite:setScale(0.99)

                local newPanelBg = FuncCommUI.getMaskCan(headMaskSprite,panelBg)
                newPanelBg:addto(getTipView)
                newPanelBg:pos(panelBg:getPositionX(),panelBg:getPositionY())
            end
        end

        self:regesitShowResView(itemView,rewardStr)
    end

    for i=rewardNum+1,self.maxRewardNum do
        local itemView = self.panel_1["UI_"..i]
        itemView:setVisible(false)
    end

    -- 显示宝箱数量
    -- self.panel_3.txt_1:setString(GameConfig.getLanguageWithSwap("tid_common_1006",self.ownStar,self.needStarNum))
    
    -- local starTip = GameConfig.getLanguageWithSwap("tid_common_1006",self.ownStar,self.needStarNum)
    -- local rewardTip = "领取条件：副本评价达到" .. starTip .. "个特等"
    local rewardTip = GameConfig.getLanguageWithSwap("#tid_story_1551",self.needStarNum)
    self.txt_1:setString(rewardTip)

    if boxStatus == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH then
        self.mc_1:showFrame(2)
    elseif boxStatus == WorldModel.starBoxStatus.STATUS_ENOUGH then
        self.mc_1:showFrame(1)
    elseif boxStatus == WorldModel.starBoxStatus.STATUS_USED then
        self.mc_1:showFrame(3)
    end

    if boxStatus ~= WorldModel.starBoxStatus.STATUS_USED then
        self.mc_1:getCurFrameView().btn_1:setTap(c_func(self.pressBtnAction,self,boxStatus))
    end
end

function WorldStarRewardView:regesitShowResView(itemView,rewardStr)
    if rewardStr then
        local reward = string.split(rewardStr,",")
        local rewardType = reward[1];
        local rewardNum = reward[table.length(reward)];
        local rewardId = reward[table.length(reward) - 1];

        FuncCommUI.regesitShowResView(itemView,
            rewardType,rewardNum,rewardId,rewardStr,true,true)
    end
end

function WorldStarRewardView:pressBtnAction(status)
    if status == WorldModel.starBoxStatus.STATUS_NOT_ENOUGH or
        status == WorldModel.starBoxStatus.STATUS_USED then
        self:startHide()
    else
        echo("领取奖励")
        WorldServer:openStarBox(self.storyId,self.boxIndex,c_func(self.openStarBoxCallBack,self))
    end
end

function WorldStarRewardView:openStarBoxCallBack(event)
    if event.result ~= nil then
        self:startHide()

        local rewardData = event.result.data.reward
        FuncCommUI.startRewardView(rewardData)

        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_OPEN_STAR_BOXES)
    end
end

-- FuncCommUI.startRewardView(info.reward)

function WorldStarRewardView:press_panel_bg_btn_close()
    self:startHide()
end


return WorldStarRewardView;
