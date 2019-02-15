--
--Author:      zhuguangyuan
--DateTime:    2017-07-26 13:56:41
--Description: 关卡视图--展开
--

local EliteRaidUnfoldView = class("EliteRaidUnfoldView", UIBase);

function EliteRaidUnfoldView:ctor(winName)
    EliteRaidUnfoldView.super.ctor(self, winName)
end

function EliteRaidUnfoldView:loadUIComplete()
	-- self:initData()
	-- self:initView()

	-- self:registerEvent()
	-- self:initViewAlign()

	-- self:updateUI()
end 



----------------------------------------------
--
----------------------------------------------
function EliteRaidUnfoldView:initData(itemData)
	self.currentRaidData = itemData
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidUnfoldView:initView()
    -- self.btn_saoOne = self.btn_1
    -- self.btn_saoTen = self.btn_2
    -- self.btn_tiaoZhan = self.btn_zhan
    -- self.txtRewardTips = self.txt_1
    -- self.txtElitetimes = self.txt_red
end



----------------------------------------------
--
----------------------------------------------
function EliteRaidUnfoldView:registerEvent()
	-- EliteRaidUnfoldView.super.registerEvent(self);

 --    -- 扫荡按钮侦听
 --    btn_saoOne:setTap(c_func(self.onSweepOne,self))
 --    btn_saoTen:setTap(c_func(self.onSweepTen,self))
 --    btn_tiaoZhan:setTap(c_func(self.goTeamFormationView,self))

 --    -- 监听副本次数变化(扫荡、买次数),更新扫荡按钮及关卡
 --    EventControler:addEventListener(UserEvent.USEREVENT_STAGE_COUNTS_CHANGE, self.updateEliteTimes, self)
 --    -- 布阵结束，开始战斗
 --    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)
end

-------------------------------------------------------------------------------
-- 扫荡
-------------------------------------------------------------------------------
-- 扫荡一次
function EliteRaidUnfoldView:onSweepOne()
    local times = 1
    if not self:isSweepConditionTrue() then --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
    -- 体力不足
    if tonumber(mySp) < self.currentRaidSpCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self.curSweepType = self.sweetpType.SWEEP_ONE
        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentRaidId)
        if eliteLeftTimes == 0 then
            self:goBuyEliteTimesView()
        else
            self:doSweep(self.currentRaidId,times)
        end
    end
end

-- 扫荡动态次数(需要根据体力计算实际扫荡次数)
function EliteRaidUnfoldView:onSweepTen()
    local times = 10
    if not self:isSweepConditionTrue() then  --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
     -- 体力不足
    if tonumber(mySp) < self.currentRaidSpCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        -- 体力足够扫荡一次
        self.curSweepType = self.sweetpType.SWEEP_TEN

        -- 取体力剩余次数和关卡剩余次数的最小值
        local leftTimes = math.floor(mySp / self.currentRaidSpCost)
        if leftTimes < times then
            times = leftTimes
        end

        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.currentRaidId)
        if eliteLeftTimes == 0 then
            echo("@@@@@@@@@@ 次数没啦  @@@@@@@@@@")
            self:goBuyEliteTimesView()
            return
        else
            if times > eliteLeftTimes then
                times = eliteLeftTimes
            end
        end
        self:doSweep(self.currentRaidId,times)
    end
end

-- 扫荡
function EliteRaidUnfoldView:doSweep(raidId,times)
    local sweepCallBack = function(serverData)
        if serverData and serverData.result ~= nil then
            local params = {
                rewardData = serverData.result.data.reward,
                targetData = nil,
                raidId = self.currentRaidId,
                sweepType = self.curSweepType 
            }
            ShareBossModel:setFindRewardStatus(serverData.result.data.shareBossReward)
            WindowControler:showWindow("WorldSweepListView",params)
        end
    end
    WorldServer:sweep(raidId,times,c_func(sweepCallBack))
end

-- 检查扫荡条件  -- 三星关卡才能扫荡
function EliteRaidUnfoldView:isSweepConditionTrue()
    local raidScore = WorldModel:getBattleStarByRaidId( self.currentRaidId )
    if raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
        local tipMsg = GameConfig.getLanguage("#tid_story_10109")
        WindowControler:showTips(tipMsg)
        return false
    end
end





----------------------------------------------
--
----------------------------------------------
function EliteRaidUnfoldView:initViewAlign()
	-- TODO
end

function EliteRaidUnfoldView:initUI()
    -- -- 设置节奖励
    -- local rewardArr = nil
    -- local rewardTip = ""

    -- -- 根据是否首次通关，展示不同的可能获得奖品
    -- local raidScore = WorldModel:getBattleStarByRaidId( itemData.id )
    -- if raidScore == WorldModel.stageScore.SCORE_LOCK then
    --     txtRewardTips:setString("首次通关奖励")
    --     rewardTip = GameConfig.getLanguage("#tid_story_10101")
    --     rewardArr = itemData["firstBonus"]
    -- else
    --     txtRewardTips:setString("关卡奖励")
    --     rewardTip = GameConfig.getLanguage("#tid_story_10102")
    --     rewardArr = itemData["bonusView"]
    -- end

    -- local rewardNum = 3 --默认只展示3个奖品 但是配置可能不止三个
    
    -- -- 默认先隐藏全部
    -- for i=1,rewardNum do
    --     panelDetils["UI_"..i]:setVisible(false)
    -- end

    -- for i=1,rewardNum do
    --     local rewardUI = panelDetils["UI_"..i]
    --     rewardUI:setVisible(true)

    --     local rewardStr = rewardArr[i]
    --     local params = {
    --         reward=rewardStr,
    --     }
    --     rewardUI:setResItemData(params)
    --     rewardUI:setResItemClickEnable(true)
    --     rewardUI:showResItemNum(false)  -- 隐藏数量

    --     local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
    --     FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr)
    -- end

    -- -- 设置扫荡按钮
    -- -- 面板2显示今日剩余挑战次数
    -- local leftEliteTimes = WorldModel:getEliteRaidLeftTimes( self.currentRaidId )
    -- txtElitetimes:setString("剩余挑战次数："..leftEliteTimes.."/3")

    -- -- 显示扫荡按钮
    -- if leftEliteTimes == 0 then
    --     btn_saoTen:setBtnStr("扫荡3次")
    -- else
    --     local spLeftTimes = math.floor( UserExtModel:sp() / self.currentRaidSpCost)
    --     if leftEliteTimes > spLeftTimes then
    --         leftEliteTimes = spLeftTimes
    --     end
    --     btn_saoTen:setBtnStr("扫荡"..leftEliteTimes.."次")
    -- end

end




function EliteRaidUnfoldView:updateUI()
end

function EliteRaidUnfoldView:deleteMe()
	-- TODO

	EliteRaidUnfoldView.super.deleteMe(self);
end

return EliteRaidUnfoldView;
