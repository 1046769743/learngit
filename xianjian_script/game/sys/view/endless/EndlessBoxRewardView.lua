--[[
	Author: TODO
	Date:2018-01-24
	Description: TODO
]]

local EndlessBoxRewardView = class("EndlessBoxRewardView", UIBase);

function EndlessBoxRewardView:ctor(winName, data)
    EndlessBoxRewardView.super.ctor(self, winName)

    self:initData(data)
end

function EndlessBoxRewardView:loadUIComplete()
	self:registerEvent()  
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_endless_tips_10"))
    self.UI_1.mc_1:setVisible(false)

    self:updateUI()
end 

function EndlessBoxRewardView:registerEvent()
	EndlessBoxRewardView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_panel_bg_btn_close, self));   
end

function EndlessBoxRewardView:initData(data)
	self.maxRewardNum = 6

    self.boxStatus = data._boxStatus
    self.curFloor = data._curFloor
    -- 已获得星总数量
    self.ownStar = data._ownStar
    -- 解锁宝箱需求的总数量
    self.needStarNum = data._needStarNum
    self.boxIndex = data._boxIndex
    --获取该宝箱中的奖励数据
    self.rewardData = FuncEndless.getBoxRewardByIdAndType(self.curFloor, self.boxIndex)
end

function EndlessBoxRewardView:initView()
	-- TODO
end

function EndlessBoxRewardView:initViewAlign()
	-- TODO
end

function EndlessBoxRewardView:updateUI()
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
        itemView:showResItemName(false)
        itemView:showResItemNum(true)

        if boxStatus == FuncEndless.boxRewardType.HASRECEIVED then 
            -- 已领取的标记
            local getTipView = UIBaseDef:cloneOneView(self.panel_1.panel_lv)
            itemView:addChild(getTipView)
            getTipView:pos(0,0)
        end

        self:regesitShowResView(itemView,rewardStr)
    end

    for i = rewardNum+1,self.maxRewardNum do
        local itemView = self.panel_1["UI_"..i]
        itemView:setVisible(false)
    end

    -- 显示宝箱数量
    local rewardTip = GameConfig.getLanguageWithSwap("#tid_endless_star_1", self.needStarNum)
    self.txt_1:setString(rewardTip)

    if boxStatus == FuncEndless.boxRewardType.NOTRECEIVED then
        self.mc_1:showFrame(2)
    elseif boxStatus == FuncEndless.boxRewardType.CANRECEIVED then
        self.mc_1:showFrame(1)
    elseif boxStatus == FuncEndless.boxRewardType.HASRECEIVED then
        self.mc_1:showFrame(3)
    end

    if boxStatus ~= FuncEndless.boxRewardType.HASRECEIVED then
        self.mc_1:getCurFrameView().btn_1:setTap(c_func(self.pressBtnAction,self,boxStatus))
    end
end


function EndlessBoxRewardView:regesitShowResView(itemView,rewardStr)
    if rewardStr then
        local reward = string.split(rewardStr,",")
        local rewardType = reward[1];
        local rewardNum = reward[table.length(reward)];
        local rewardId = reward[table.length(reward) - 1];

        FuncCommUI.regesitShowResView(itemView,
            rewardType,rewardNum,rewardId,rewardStr,true,true)
    end
end

function EndlessBoxRewardView:pressBtnAction(status)
    if status == FuncEndless.boxRewardType.NOTRECEIVED or
        status == FuncEndless.boxRewardType.HASRECEIVED then
        self:startHide()
    else
        echo("领取奖励")
        EndlessServer:getBoxReward(self.curFloor, self.boxIndex, c_func(self.openStarBoxCallBack, self))
    end
end

function EndlessBoxRewardView:openStarBoxCallBack(event)
    if event.result ~= nil then
        self:startHide()

        local rewardData = event.result.data.reward
        FuncCommUI.startRewardView(rewardData)
        EventControler:dispatchEvent(EndlessEvent.ENDLESS_BOX_STATUS_CHANGED)
    end
end

function EndlessBoxRewardView:press_panel_bg_btn_close()
    self:startHide()
end

function EndlessBoxRewardView:deleteMe()
	-- TODO

	EndlessBoxRewardView.super.deleteMe(self);
end

return EndlessBoxRewardView;
