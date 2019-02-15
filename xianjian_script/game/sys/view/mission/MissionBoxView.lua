local MissionBoxView = class("MissionBoxView", UIBase)

function MissionBoxView:ctor(winName,index)
	MissionBoxView.super.ctor(self, winName)
    self.index = index
end

function MissionBoxView:setAlignment()
    --设置对齐方式
end

function MissionBoxView:registerEvent()
    MissionBoxView.super.registerEvent();
    self.UI_1.btn_close:setTap(c_func(self.onBtnBackTap, self));
    self.UI_1.mc_1:visible(false)
    self:registClickClose("out")
end

function MissionBoxView:loadUIComplete()
    self:registerEvent()
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid2021"))

    self:initUI( )
end

-- 第几个宝箱就需要完成几个任务
function MissionBoxView:initUI( )
    -- 领取条件
    local _str = string.format(GameConfig.getLanguage("#tid_mission_004"),tostring(self.index))
    self.rich_1:setString(_str)
    -- 奖励显示
    for i = 1,4 do
        self["UI_x"..i]:visible(false)
    end
    
    local rewards = FuncMission.getMissionReward(self.index)
    rewards = string.split(rewards.str,";")
    for i,v in pairs(rewards) do
        if v and v ~= "" and i <= 4 then
            local strT = string.split(v,",")
            local itemView = self["UI_x"..i]
            itemView:visible(true)
            local data = {}
            data.reward = v
            itemView:setRewardItemData(data)
            -- itemView:showResItemName(true)
            -- itemView:showResItemNum(false)
            FuncCommUI.regesitShowResView(itemView,strT[1],0,strT[2],v,true,true)
        end
    end
    -- 按钮状态
    local boxState = MissionModel:getBoxState(self.index)
    if boxState == MissionModel.boxStatus.CanGet then
        self.mc_1:showFrame(1)
        local btn = self.mc_1.currentView.btn_1
        btn:setTap(c_func(self.getBoxReward, self))
    elseif boxState == MissionModel.boxStatus.NotCanGet then
        self.mc_1:showFrame(2)
        local btn = self.mc_1.currentView.btn_1
        btn:setTap(c_func(self.onBtnBackTap, self))
    elseif boxState == MissionModel.boxStatus.Getted then
        self.mc_1:showFrame(3)
        local btn = self.mc_1.currentView.btn_1 
        btn:setTap(c_func(self.onBtnBackTap, self))
    end
end

-- 宝箱领取请求
function MissionBoxView:getBoxReward()
    -- 此时领取宝箱奖励
    echo("领取宝箱奖励")
    -- local boxId = FuncMission.getMissionBoxId( self.index )
    MissionServer:requestBoxReward({id = self.index}, c_func(self.getBoxRewardCallBack,self))
end

function MissionBoxView:getBoxRewardCallBack( params )
    if params.result then
        -- 领取奖励
        dump(params.result.data.reward, "baoxiang ----", 4)
        FuncCommUI.startFullScreenRewardView(params.result.data.reward, nil)
    else 
        if params.error.code == 550102 then
            WindowControler:showTips(GameConfig.getLanguage("#tid_mission_001")) 
        end
    end
    self:onBtnBackTap()
end

function MissionBoxView:onBtnBackTap()
    self:startHide()
end

return MissionBoxView
