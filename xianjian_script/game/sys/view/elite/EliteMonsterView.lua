--
--Author:      zhuguangyuan
--DateTime:    2018-01-31 17:42:27
--Description: 场景地图中点击怪 弹出的与怪对话界面
--

local EliteMonsterView = class("EliteMonsterView", UIBase);

function EliteMonsterView:ctor(winName,raidId)
    EliteMonsterView.super.ctor(self, winName)
    self.raidId = raidId
    self.storyId = FuncChapter.getStoryIdByRaidId(self.raidId)
end

function EliteMonsterView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

--===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
function EliteMonsterView:getEnterBattleCacheData()
    echo("\n 战斗前缓存view数据 EliteMonsterView")
    local params = {raidId = self.raidId}
    return params
end

function EliteMonsterView:onBattleExitResume(cacheData )
    dump(cacheData,"战斗恢复view EliteMonsterView")
    EliteMonsterView.super.onBattleExitResume(cacheData)

    if cacheData and cacheData.raidId then
        self.raidId = cacheData.raidId
        self.raidData = FuncChapter.getRaidDataByRaidId(self.raidId)
        self.storyId,self.raidId = EliteMainModel:checkIsPerfect(self.storyId,self.raidId)
        self:startHide()

        -- -- 检查完美通关
        -- local maxStoryId = WorldModel:getUnLockMaxStoryId( FuncChapter.stageType.TYPE_STAGE_ELITE )
        -- local curStoryId = FuncChapter.getStoryIdByRaidId(self.raidId)
        -- if tonumber(maxStoryId) >= tonumber(curStoryId) then
        --     if WorldModel:isLastRaidId(self.raidId) then
        --         local function showTips() 
        --             EventControler:dispatchEvent(EliteEvent.ELITE_AUTO_OPEN_LEFT_GRIDS)
        --             self:startHide()
        --         end
        --         self:delayCall(c_func(showTips), 0.5)
        --     else
        --         self:startHide()
        --     end
        -- else
        --     self:startHide()
        -- end
    end
end

function EliteMonsterView:registerEvent()
	EliteMonsterView.super.registerEvent(self);
    self:registClickClose("out")

    self.ctn_click:setContentSize(cc.size(GameVars.width,GameVars.height))
    -- local color = color or cc.c4b(255,0,0,120)
    -- local layer = cc.LayerColor:create(color)
    -- layer:setContentSize(cc.size(GameVars.width,GameVars.height))
    self.ctn_click:pos(-(GameVars.width-GameVars.gameResWidth)/2,-GameVars.height+(GameVars.height-GameVars.gameResHeight)/2)
    -- self.ctn_click:addChild(layer)
    -- self.ctn_click:setTouchEnabled(true)
    -- self.ctn_click:setTouchSwallowEnabled(true)
    -- self.ctn_click:setTouchedFunc(c_func(self.startHide,self))

    EventControler:addEventListener(BattleEvent.BEGIN_BATTLE_FOR_FORMATION_VIEW, self.onTeamFormationComplete, self)


    -- 监听副本次数变化(扫荡、买次数),更新扫荡按钮及关卡
    EventControler:addEventListener(UserEvent.USEREVENT_STAGE_COUNTS_CHANGE, self.updateEliteTimes, self)
    -- 监听购买挑战次数
    EventControler:addEventListener(WorldEvent.WORLDEVENT_BUY_CHALLEGE_TIMES,self.buyEliteTimesSucceed,self)
    EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE, self.onSpChange, self)
end
-- 罗鑫说想加个小提示 O.O 2017/8/22 
function EliteMonsterView:buyEliteTimesSucceed()
    WindowControler:showTips(GameConfig.getLanguage("#tid_elite_006"))
end

-- 扫荡之后更新关卡可挑战次数  更新扫荡按钮
function EliteMonsterView:updateEliteTimes()
    local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
    local txtElitetimes = self.rich_3
    local tips = GameConfig.getLanguage("#tid_elite_004")
    tips = "<color = 764F32>"..tips.."<->"
    local tips2 = eliteLeftTimes.."/3"
    if eliteLeftTimes == 0 then
        tips2 = "<color = E1725F>"..tips2.."<->"
    else
        tips2 = "<color = 139018>"..tips2.."<->"
    end  
    -- 剩余挑战次数
    txtElitetimes:setString(tips..tips2)

    self:updateSweepBtn()
end


function EliteMonsterView:onSpChange()
    self:updateSpDisplay()
    self:updateSweepBtn()  
end
-- 更新体力展示
function EliteMonsterView:updateSpDisplay()
    local mySp = UserExtModel:sp()
    if tonumber(mySp) < tonumber(self.raidData.spCost) then
        self.mc_buzu:showFrame(2)
        self.mc_buzu.currentView.txt_2:setString(self.raidData.spCost)
    else
        self.mc_buzu:showFrame(1)
        self.mc_buzu.currentView.txt_2:setString(self.raidData.spCost)
    end
end

-- 扫荡按钮受可挑战次数和体力的双重限制
function EliteMonsterView:updateSweepBtn()
    self.btn_1:setBtnStr("扫荡")
    local btn_saoTen = self.btn_2
    -- 扫荡按钮还受体力的限制
    local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
    if eliteLeftTimes == 0 then
        btn_saoTen:setBtnStr("扫荡3次")
        return
    end
    local spLeftTimes = math.floor( UserExtModel:sp() / self.raidData.spCost)
    if eliteLeftTimes > spLeftTimes and spLeftTimes ~= 0 then
        eliteLeftTimes = spLeftTimes
    end
    btn_saoTen:setBtnStr("扫荡"..eliteLeftTimes.."次")
end


function EliteMonsterView:onTeamFormationComplete( event )
    local params = event.params
    local sysId = params.systemId
    if sysId == FuncTeamFormation.formation.pve_elite then
        local formation = params.formation
        echo("\n\n\n\n\n\n 进入战斗前 向服务器发送布阵信息及关卡id enterPVEStage ")
        WorldServer:enterPVEStage(self.raidId, c_func(self.enterEliteStageCallBack,self), formation)
    end
end

-- PVE战斗前初始化
function EliteMonsterView:enterEliteStageCallBack(event)
    if event.result ~= nil then
        self.battleId = event.result.data.battleInfo.battleId

        -- 缓存用户数据
        UserModel:cacheUserData()

        -- 保存当前战斗信息，战斗结算会用到
        local cacheBattleInfo = {}
        cacheBattleInfo.raidId = self.raidId
        cacheBattleInfo.battleId = self.battleId
        cacheBattleInfo.level = FuncChapter.getRaidAttrByKey(self.raidId,"level")
        cacheBattleInfo.spCost = self.raidData.spCost  -- 主角加经验(等于体力消耗) 
        cacheBattleInfo.heroAddExp = self.raidData.expPartner or 0  -- 伙伴加经验
        WorldModel:resetDataBeforeBattle()
        WorldModel:setCurPVEBattleInfo(cacheBattleInfo)
        echo("\n\n\n\n\n\n\n\n\n\n 战斗前所在关卡为 @@@@@@@@@@@@@@@@@"..self.raidId)
        dump(cacheBattleInfo,"战斗前数据缓存：== ")
         -- 初始化PVE战斗结果
        local cacheData = {
            battleRt = Fight.result_lose,
            raidId = self.raidId,
            -- 缓存关卡成绩
            raidScore = WorldModel:getBattleStarByRaidId(self.raidId)
        }
        WorldModel:setPVEBattleCache(cacheData)

        -- 发送 关闭布阵界面 消息
        EventControler:dispatchEvent(BattleEvent.CLOSE_TEAM_FORMATION_FOR_BATTLE)

        -- 开始战斗
        local battleInfo = {}
        battleInfo.battleUsers = event.result.data.battleInfo.battleUsers;
        battleInfo.randomSeed = event.result.data.battleInfo.randomSeed;
        battleInfo.battleLabel = GameVars.battleLabels.worldPve
        battleInfo.battleId = self.battleId
        battleInfo.levelId = FuncChapter.getRaidAttrByKey(self.raidId,"level")

        local params = {
            raidId = self.raidId,
        }
        EliteMainModel:saveMonterData(params)
        BattleControler:startPVE(battleInfo)
    end
end

function EliteMonsterView:initData()
	self.raidData = FuncChapter.getRaidDataByRaidId(self.raidId)

    -- 扫荡的两种类型
    self.sweetpType = {
        SWEEP_ONE = 1,
        SWEEP_TEN = 10
    }
end

function EliteMonsterView:initView()
    self.storyId = tostring(self.raidData.chapter)
    local chapter = FuncChapter.getChapterByStoryId(self.storyId)
    local section = FuncChapter.getSectionByRaidId(self.raidId)
    section = Tool:transformNumToChineseWord(tonumber(section))
    self.UI_1.txt_1:setString("第"..section.."节")

    local monsterName = GameConfig.getLanguage(self.raidData.name)
    self.txt_name:setString(monsterName)

    -- self.mc_hulu:visible(true)
    -- local panel_up = UIBaseDef:createPublicComponent( "UI_elite_layer","panel_up")
    -- panel_up:visible(true)
    self.huluMC = self.mc_hulu
    local raidScore = WorldModel:getBattleStarByRaidId( self.raidId )
    self.huluMC:setVisible(true)
    if raidScore == WorldModel.stageScore.SCORE_ONE_STAR then
        self.huluMC:showFrame(1)
    elseif raidScore == WorldModel.stageScore.SCORE_TWO_STAR then
        self.huluMC:showFrame(2)
    elseif raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        self.huluMC:showFrame(3)
    elseif raidScore == WorldModel.stageScore.SCORE_LOCK then
        self.huluMC:showFrame(4)
    end
    self.huluMC:scale(0.75)

    self.txt_green:visible(false)

	self.btn_zhan:setTap(c_func(self.enterTeamFormation,self))
    self.UI_1.btn_1:setTap(c_func(self.startHide,self))
	self.btn_gl:setTap(c_func(self.gotoStrategyView,self))

    -- 显示立绘
    local spineStr = self.raidData.eliteMoster
    local spineArr = string.split(spineStr[1],",")
    local spineId = spineArr[1]

    local sourceData = FuncTreasure.getSourceDataById(spineId)
    local spine = FuncRes.getSpineViewBySourceId(spineId,sex,true,sourceData) 
    local scale11 = 1.5
    if spineArr[2] then
        scale11 = scale11 * spineArr[2]
    end
    spine:scale(scale11)
    -- spine:setScaleX(-2)
    spine:pos(0,0)
    self.ctn_1:addChild(spine)

    -- 推荐战力
    dump(self.raidData, "self.raidData", nesting)
    local powerNumUI = self.UI_number
    local rich_power = self.rich_power
    if self.raidData and self.raidData.recommendPower then
        powerNumUI:setPower(self.raidData.recommendPower)
    elseif rich_power and powerNumUI then
        rich_power:visible(false)
        powerNumUI:visible(false)
    end

    -- 可能奖励
    local rewardArr = nil
    local rewardTip = ""

    -- 根据是否首次通关，展示不同的可能获得奖品
    local raidScore = WorldModel:getBattleStarByRaidId( self.raidData.id )
    if raidScore == WorldModel.stageScore.SCORE_LOCK then
        -- self.txt_jl:setString("首次通关奖励")
        rewardTip = GameConfig.getLanguage("#tid_story_10101")
        rewardArr = self.raidData["firstBonus"]
    else
        -- self.txt_jl:setString("关卡奖励")
        rewardTip = GameConfig.getLanguage("#tid_story_10102")
        rewardArr = self.raidData["bonusView"]
    end
    -- self.txt_jl:setString(rewardTip)

    local rewardNum = 3 --默认只展示3个奖品 但是配置可能不止三个
    
    -- 默认先隐藏全部
    for i=1,rewardNum do
        self.panel_jiangli["UI_"..i]:setVisible(false)
    end

    local count = #rewardArr
    if #rewardArr > 3 then
        count = 3
    end
    for i=1, count do
        local rewardUI = self.panel_jiangli["UI_"..i]
        rewardUI:setVisible(true)

        local rewardStr = rewardArr[i]
        local params = {
            reward=rewardStr,
        }
        rewardUI:setResItemData(params)
        -- rewardUI:setResItemClickEnable(true)
        rewardUI:showResItemNum(false)  -- 隐藏数量

        local resNum,_,_ ,resType,resId = UserModel:getResInfo( rewardStr )
        -- FuncCommUI.regesitShowResView(rewardUI:getResItemIconCtn(),resType,resNum,resId,rewardStr,true,true)
        FuncCommUI.regesitShowResView(rewardUI,resType,resNum,resId,rewardStr,true,true)
    end

    -- 剩余挑战次数
    self:updateEliteTimes()
    self:onSpChange()
    -- 扫荡,未达到扫荡条件则将按钮置灰
    if EliteMainModel:isSweepConditionTrue(self.raidId,true) then
        FilterTools.clearFilter(self.btn_1)
        FilterTools.clearFilter(self.btn_2)
    else
        FilterTools.setGrayFilter(self.btn_1)
        FilterTools.setGrayFilter(self.btn_2)
    end
    self.btn_1:setTap(c_func(self.onSweepOne,self))
    self.btn_2:setTap(c_func(self.onSweepTen,self))

    -- local bgSprite = display.newSprite(FuncRes.iconElite("elite_bg_tiaozhanbj")) 
    -- self.ctn_click:removeAllChildren()
    -- self.ctn_click:addChild(bgSprite)
end

-------------------------------------------------------------------------------
-- 扫荡
-------------------------------------------------------------------------------
-- 扫荡一次
function EliteMonsterView:onSweepOne()
    local times = 1
    if not EliteMainModel:isSweepConditionTrue(self.raidId) then --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
    -- 体力不足
    if tonumber(mySp) < self.raidData.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        self.curSweepType = self.sweetpType.SWEEP_ONE
        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
        if eliteLeftTimes == 0 then
            self:goBuyEliteTimesView()
        else
            self:doSweep(self.raidId,times)
        end
    end
end

-- 扫荡动态次数(需要根据体力计算实际扫荡次数)
function EliteMonsterView:onSweepTen()
    local times = 10
    if not EliteMainModel:isSweepConditionTrue(self.raidId) then  --未达到三星
        return
    end

    local mySp = UserExtModel:sp()
     -- 体力不足
    if tonumber(mySp) < self.raidData.spCost then
        WindowControler:showWindow("CompBuySpMainView");
        return
    else
        -- 体力足够扫荡一次
        self.curSweepType = self.sweetpType.SWEEP_TEN

        -- 取体力剩余次数和关卡剩余次数的最小值
        local leftTimes = math.floor(mySp / self.raidData.spCost)
        if leftTimes < times then
            times = leftTimes
        end

        -- 精英关卡剩余次数
        local eliteLeftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
        if eliteLeftTimes == 0 then
            self:goBuyEliteTimesView()
            return
        else
            if times > eliteLeftTimes then
                times = eliteLeftTimes
            end
        end 
        self:doSweep(self.raidId,times)  
    end
end

-- 扫荡
function EliteMonsterView:doSweep(raidId,times)
    local sweepCallBack = function(serverData)
        if serverData and serverData.result ~= nil then
            local params = {
                rewardData = serverData.result.data.reward,
                targetData = self.targetData,       ----------------------------!!!!!!!!!!!!!!!!! 其他系统调到精英界面 默认在列表界面扫荡而不是这里!!!!!!
                raidId = self.raidId,
                sweepType = self.curSweepType 
            }
            ShareBossModel:setFindRewardStatus(serverData.result.data.shareBossReward)
            WindowControler:showWindow("WorldSweepListView",params)
        end
    end
    WorldServer:sweep(raidId,times,c_func(sweepCallBack))
end

-- 检查扫荡条件  -- 三星关卡才能扫荡
function EliteMonsterView:isSweepConditionTrue()
    local raidScore = WorldModel:getBattleStarByRaidId( self.raidId )
    if raidScore == WorldModel.stageScore.SCORE_THREE_STAR then
        return true
    else
        local tipMsg = GameConfig.getLanguage("#tid2133")
        WindowControler:showTips(tipMsg)
        return false
    end
end

-- =====================================================================


-- 跳到通关攻略界面
function EliteMonsterView:gotoStrategyView()
    local arrayData = {
        systemName = FuncCommon.SYSTEM_NAME.ROMANCE,---系统名称
        diifID = self.raidId,  --关卡ID
    }
    RankAndcommentsControler:showUIBySystemType(arrayData)    
end

function EliteMonsterView:updateee( ... )
    -- body
end
function EliteMonsterView:enterTeamFormation()
    -- 若关卡未开启则提示信息
    local maxPassRaid = WorldModel:getMaxUnLockEliteRaidId()
    if tonumber(self.raidId) > tonumber(maxPassRaid) then
        WindowControler:showTips("上一关卡未通关")
        return 
    end

    -- 若挑战次数不足则购买
    local leftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
    if leftTimes == 0 then  
        self:goBuyEliteTimesView()  
        return
    end

    local battleSpCost = self.raidData.spCost --self.raidData.spCost
    if leftTimes == 3 and maxPassRaid == "20101" then
        echo("\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n 新手引导不消耗体力")
        battleSpCost = 0 
    end

    -- 若体力不足，则提示购买体力
    if not UserModel:tryCost(FuncDataResource.RES_TYPE.SP, tonumber(battleSpCost), true) then
        WindowControler:showWindow("CompBuySpMainView")  
        return
    end

    -- 获取关卡配置的布阵信息
    local format = self.raidData.format

    local formation = {}
    if format then
        for i=1,#format do
            local arr = string.split(format[i],",")
            formation[arr[1]] = arr[2]
        end
    end

    -- 将进战斗 则同步改动关卡列表界面及章界面的选中状态
    --Author:      zhuguangyuan
    --DateTime:    2018-02-26 18:12:31
    EventControler:dispatchEvent(EliteEvent.ELITE_CHOOSR_STORYID_CHANGE,{storyId = self.storyId,raidId = self.raidId})

    -- 进入布阵界面
    local params = {}
    params[FuncTeamFormation.formation.pve_elite] = {
        npcs = formation,
        raidId = self.raidId,
    }
    WindowControler:showWindow("WuXingTeamEmbattleView",FuncTeamFormation.formation.pve_elite,params)
end

function EliteMonsterView:goBuyEliteTimesView( ... )
    local buyTimes = WorldModel:getEliteBuyTimes(self.raidId)
    local maxTimes = WorldModel:getEliteMaxBuyTimes()
    echo("__________ buyTimes,maxTimes ________________",buyTimes,maxTimes)
    
    if buyTimes < maxTimes then
        WindowControler:showWindow("WorldBuyChallengeTimesView",self.raidId);
    else
        WindowControler:showTips(GameConfig.getLanguage("tid_story_10119"))
    end
end

function EliteMonsterView:initViewAlign()
end

function EliteMonsterView:updateUI()
end

function EliteMonsterView:deleteMe()
	EliteMonsterView.super.deleteMe(self);
end

return EliteMonsterView;
