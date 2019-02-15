local MissionRewardView = class("MissionRewardView", UIBase)

function MissionRewardView:ctor(winName,index,missionId)
	MissionRewardView.super.ctor(self, winName)
    self.selectIndex = MissionModel:getMissionPosition( )
    -- index为php数组索引，从0开始(index为-1表示任务没完成，>-1表示任务完成)
    self.rewardIndex = index + 1
    self.missionId = missionId
    if self.rewardIndex < 1 or self.rewardIndex > 5 then
        self.rewardIndex = 1
        echoError("此时index有问题 找程序")
    end
end

function MissionRewardView:setAlignment()
    --设置对齐方式
end

function MissionRewardView:registerEvent()
    MissionRewardView.super.registerEvent();
    -- self.UI_1.btn_close:setTap(c_func(self.onBtnBackTap, self));
end

function MissionRewardView:loadUIComplete()
    self:registerEvent()

    local rewardArr = FuncMission.getConfirmReward(self.missionId)
    if rewardArr then
        self.panel_rd:setVisible(false)
       
        local callBack = function()
            -- 固定奖励
            self:showRewardView(rewardArr)
        end

        self:delayCall(c_func(callBack), 1/GameVars.GAMEFRAMERATE)
    else
        self.panel_rd:setVisible(true)
        -- 目前只有六界问答会这行这里(随机奖励)
        self:initUI()
    end
end

function MissionRewardView:initUI( )
    local max_reward = 5
    for i=1,max_reward do
        self.panel_rd["UI_x"..i]:visible(false)
    end

    local _rewards = FuncMission.getProbableReward(self.missionId)
    -- 获取需要的格式
    for i,v in pairs(_rewards) do
        local strT = string.split(v,",")
        local str = nil
        if strT[2] == FuncDataResource.RES_TYPE.ITEM then
            str = strT[2]..","..strT[3]..","..strT[4]
        else
            str = strT[2]..","..strT[3]
        end
        local data = {}
        data.reward = str
        local itemView = self.panel_rd["UI_x"..i]
        itemView:visible(true)
        itemView:setRewardItemData(data)
        if i == self.rewardIndex then
            self.reward = str
        end
        -- if strT[3] == self.rewardId then
        --     self.rewardIndex = i
        -- end
        -- itemView:showResItemName(true)
        -- itemView:showResItemNum(false)
        -- 注册点击事件
        FuncCommUI.regesitShowResView(itemView,strT[2],0,strT[3],str,true,true)
    end
    for i=1,5 do
        self.panel_rd["panel_s"..i]:visible(false)
    end
    self:startAction()
end

function MissionRewardView:startAction(  )
    local quanshu = 20 -- 循环的圈数 quanshu/5
    local total = quanshu + self.rewardIndex
    for i=1,total do
        local dur = 0.1
        local delayTime = 0 
        if i > quanshu then
            for m=1 ,(i-quanshu) do
                delayTime = delayTime  + (i - quanshu) * 0.02
            end
        end
        delayTime = delayTime + dur * i
        self:delayCall(function ( ... )
                for ii=1,5 do
                    self.panel_rd["panel_s"..ii]:visible(false)
                end
                local t1 = i % 5;
                if t1 == 0 then
                    t1 = 5
                end
                if i == total then
                    self:delayCall(function ( ... )
                        self:stopActionCallBack()
                    end,1)
                    -- self:registClickClose()
                end
                self.panel_rd["panel_s"..t1]:visible(true)
            end,delayTime)
    end
end

function MissionRewardView:stopActionCallBack( )
    self:showRewardView({self.reward})
end

function MissionRewardView:showRewardView(rewardArr)
     dump({self.reward}, "奖励内容-----", 3)
     FuncCommUI.startFullScreenRewardView(rewardArr, nil)
     self:onBtnBackTap();
end

function MissionRewardView:onBtnBackTap()
    self:startHide()
end

return MissionRewardView
