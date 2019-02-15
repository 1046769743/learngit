--
-- Author: ZhangYanguang
-- Date: 2016-02-22
--
--六界系统，网络服务类

local WorldServer = class("WorldServer")

function WorldServer:init()
	-- 监听战斗事件
    -- 战斗系统关闭
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)

    -- PVE 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onPVEBattleComplete,self)

    -- PVE 战斗离开
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE,self.onPVEBattleLeave,self)

    -- PVE 战斗胜利
    EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN, self.onPVEBattleWin, self)

    -- 获取在线玩家
    EventControler:addEventListener(WorldEvent.GET_ONLINE_PLAYER,self.checkOnlinePlayer, self);

    -- 刷新在线玩家
    EventControler:addEventListener(WorldEvent.GET_ONLINE_PLAYER_AGAIN,self.checkOnlinePlayerAgain, self);
end

function WorldServer:checkOnlinePlayer()
    local params = {
        rids = nil,
        limit = 20,
    };

    if Server._isClose == true then 
        return;
    end

    Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
        c_func(WorldServer.checkOnlinePlayerCallBack, self), false, true);
end

function WorldServer:checkOnlinePlayerCallBack(event)
    if event and event.result then
        --发事件
        EventControler:dispatchEvent(WorldEvent.GET_ONLINE_PLAYER_SUCCESS, 
            {onLines = event.result.data.onlines});
    else
        echo("检查在线玩家发生错误")
    end
end

function WorldServer:checkOnlinePlayerAgain(data)
    -- dump(data.params.rids, "HomeServer:checkOnlinePlayerAgain")

    local params = {
        rids = data.params.rids,
        limit = 20,
    };
    
    if Server._isClose == true then 
        return;
    end

    Server:sendRequest(params, MethodCode.user_getOnlinePlayer_319,
        c_func(WorldServer.checkOnlinePlayerAgainCallBack, self), false, true);
end

function WorldServer:checkOnlinePlayerAgainCallBack(event)
    -- dump(event, "__checkOnlinePlayerCallBack__");
    -- echo("event.result.data.onlines====")
    -- dump(event.result.data.onlines)
    
    --发事件
    EventControler:dispatchEvent(WorldEvent.GET_ONLINE_PLAYER_AGAIN_SUCCESS, 
        {onLines = event.result.data.onlines});
end

function WorldServer:onPVEBattleWin(battleResult)
    if PrologueUtils:showPrologue() then
        return
    end

    local pveBattleCache = WorldModel:getPVEBattleCache()
    if pveBattleCache then
        pveBattleCache.battleRt = Fight.result_win
        -- 发出首次通关消息
        if pveBattleCache.raidScore == 0 then
            echo("______________ 发送首次通关的消息 ______________  ")
            if pveBattleCache.raidId and WorldModel:isEliteRaid(pveBattleCache.raidId) then
                echo("_______ 精英关卡首次通关 ______ ")
                EventControler:dispatchEvent(EliteEvent.ELITE_FIRST_PASS_RAID,{raidId=pveBattleCache.raidId})
            else
                EventControler:dispatchEvent(WorldEvent.WORLDEVENT_FIRST_PASS_RAID,{raidId=pveBattleCache.raidId})
            end
        end
    end
end

-- PVE战斗离开
function WorldServer:onPVEBattleLeave(data)
    if PrologueUtils:showPrologue() then
        return
    end
    local battleResult = data.params
    self:reportPVEBattleResult(battleResult)
end

-- PVE战斗结束回调
function WorldServer:onPVEBattleComplete(data)
    -- echo("为何在这里能监听打破--- ")
    if PrologueUtils:showPrologue() then
        return
    end

    local battleResult = data.params
    self:reportPVEBattleResult(battleResult)
end

-- 上报PVE战斗结果
function WorldServer:reportPVEBattleResult(battleResult)
    -- echo ("\n\nPVE上报战斗结果========================")
    local cachePVeBattlInfo = WorldModel:getCurPVEBattleInfo()
    if cachePVeBattlInfo == nil then
        return
    end

    if BattleControler:checkIsWorldPVE() then
        local battleId = cachePVeBattlInfo.battleId

        --直接用战斗传递的结果
        local battleParams = battleResult
        -- local battleParams = {}

        -- battleParams.battleId = tostring(battleId)
        -- battleParams.frame = battleResult.frame
        -- battleParams.fragment = battleResult.fragment
        -- battleParams.operation = battleResult.operation
        -- battleParams.rt = battleResult.rt
        -- battleParams.star = battleResult.battleStar
        
        -- echo("battleParams.star====" .. battleParams.star)
        -- 缓存数据
        cachePVeBattlInfo.battleStar = battleParams.star
        cachePVeBattlInfo.battleRt = battleParams.rt
        cachePVeBattlInfo.resultInfo = battleResult.resultInfo
        
        EliteMainModel:saveBattleResult(battleParams.rt)
        self:reportBattleResult(battleParams,c_func(self.onPVEReportBattlResultCallBack,self))
    end
end

-- 报告战斗结果回调
function WorldServer:onPVEReportBattlResultCallBack(event)
	echo("\n\nonPVEReportBattlResultCallBack ")
	self.extraBonus = nil
	self.battleResult = nil

    if BattleControler.userLevel then
        --如果是玩家点击离开
        return
    end

    -- 显示奖品列表界面
    local rewardData = {}

    local cacheData = UserModel:getCacheUserData()

    if event.result ~= nil then
        local serverData = event.result

        dump(serverData, "\n\nserverData====")
        -- 获取战斗开始前缓存的信息
        local cacheBattleInfo = WorldModel:getCurPVEBattleInfo()
        ShareBossModel:setFindRewardStatus(serverData.data.shareBossReward)
        -- 额外奖励
        self.extraBonus = serverData.data.extraBonus
        
        rewardData.ratio = serverData.data.ratio
        rewardData.reward = serverData.data.reward
        rewardData.result = cacheBattleInfo.battleRt
        rewardData.star = cacheBattleInfo.battleStar

        self.battleResult = rewardData.result

        -- 战斗胜利
        if tonumber(Fight.result_win) == tonumber(cacheBattleInfo.battleRt) then
            -- 战斗成功加经验值
            rewardData.addExp = cacheBattleInfo.spCost
            rewardData.heroAddExp = cacheBattleInfo.heroAddExp

            EventControler:dispatchEvent(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN,{raidId=UserExtModel:getMainStageId()})
            EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID});
        else
            -- 战斗失败加经验值
            rewardData.addExp = 1
            rewardData.heroAddExp = 0
        end

        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp

    else
        rewardData.result = Fight.result_lose
        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp
    end

    
    -- 展示结算界面
    BattleControler:showReward(rewardData)
end
-- 获取是否有额外宝箱
function WorldServer:getExtraBonus( ... )
    return self.extraBonus
end

-- GVE&PVE战斗界面关闭
function WorldServer:onBattleClose(event)
    echo("WorldServer:onBattleClose,self.battleResult=",self.battleResult)
    if tostring(self.battleResult) ~= tostring(Fight.result_win) then
    	return
    end

    -- 获取战斗开始前缓存的信息
    local cacheBattleInfo = WorldModel:getCurPVEBattleInfo()
    -- echo("cacheBattleInfo==",cacheBattleInfo)

    -- PVE 战斗
    if cacheBattleInfo ~= nil then
        EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLOSE_PVE_BATTLE)
		-- 重置缓存
    	WorldModel:setCurPVEBattleInfo(nil)
    end
end

-- ===================================================================================
-- 进入副本(普通和精英通用接口)
-- stageId，节点ID
function WorldServer:enterPVEStage(stageId,callBack,formation)
    local levelId = nil
    -- 检查关卡人数是否满了
    local function isFormationFull(partnerFormation)
        if not partnerFormation then return true end

        for _,info in pairs(partnerFormation) do
            if info.partner.partnerId == "0" then
                return false
            end
        end

        return true
    end
    -- 这两关要做助战假关卡的，如果己方人物没有满且没有对应伙伴则换关卡
    if tonumber(stageId) == 10205 then
        -- 这一关检查阵容人数和赵灵儿
        if not isFormationFull(formation.partnerFormation) and not PartnerModel:isPartnerExist(5022) then
            levelId = 10207
        end
    elseif tonumber(stageId) == 10206 then
        -- 这一关检查阵容人数和龙幽
        if not isFormationFull(formation.partnerFormation) and not PartnerModel:isPartnerExist(5033) then
            levelId = 10208
        end
    end

	local params = {
		stageId = stageId,
        formation = formation,
        levelId = levelId,
	}
	Server:sendRequest(params,MethodCode.pve_enterMainStage_1201 , callBack )
end

-- 汇报战斗结果
-- battleParams结构
--[[
	battleId
	frame
	fragment
	operation
	rt
	star
]]
function WorldServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleResultClient = battleParams
	}

	Server:sendRequest(params,MethodCode.pve_reportBattleResult_1203 , callBack)
end

-- 领取星评级宝箱
function WorldServer:openStarBox(storyId,boxIndex,callBack)
	local params = {
		chapterId = storyId,
		id = boxIndex
	}

	Server:sendRequest(params,MethodCode.pve_openStarBox_1209 , callBack)
end

-- 打开额外宝箱
-- 打开精英探索场景的宝箱 2018.2.24
function WorldServer:openExtraBox(storyId,boxId,callBack)
    local storyData = FuncChapter.getStoryDataByStoryId(storyId)
    local boxData = storyData.eliteDiscoverBox
    local oldBoxId = boxId
    for k,v in pairs(boxData) do
        if tostring(boxId) == v then
            boxId = k
            break
        end
    end
    echo("_____boxId_________",boxId)
    if tostring(oldBoxId)==tostring(boxId) then
        dump(boxData, "boxData")
        echoError("错误!精英地图表配置的宝箱id 没有配置到story表")
    else
        local params = {
            chapterId  = storyId,
            id = boxId,
        }
        Server:sendRequest(params,MethodCode.pve_openExtraBox_1211, callBack)
    end
end


-- PVE扫荡
function WorldServer:sweep(raidId,times,callBack)
    local params = {
        stageId = raidId,
        times = times
    }

    dump(params)
    Server:sendRequest(params,MethodCode.pve_sweep_1213, callBack)
end

-- 购买挑战次数
function WorldServer:buyChalengeTimes(eliteId,callBack)
    local params = {
        eliteId = eliteId
    }

    Server:sendRequest(params,MethodCode.pve_buy_challenge_times_1215, callBack)
end

WorldServer:init();

return WorldServer
