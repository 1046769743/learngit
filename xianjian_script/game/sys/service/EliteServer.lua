--
-- Author: zq
-- Date: 2016-8-16
--

local EliteServer = class("EliteServer")
function EliteServer:init()

    -- 奇缘关闭
    EventControler:addEventListener(WorldEvent.WORLDEVENT_UNLOCK_ROMANCE_CLOSE,self.onGveBattleClose,self)
    -- 战斗系统关闭
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)
	-- GVE 战斗结束
    EventControler:addEventListener("notify_world_gve_match_battle_end_1208", self.onGVEBattleComplete, self)
    -- 额外奖励界面关闭
    EventControler:addEventListener(WorldEvent.WORLDEVENT_EXTREA_REWARD_VIEW_CLOSE,self.showUnLockRomanceView,self) 
end

-- GVE战斗界面关闭
function EliteServer:onBattleClose(event)
    echo("WorldServer:onBattleClose,self.battleResult=",self.battleResult)
    if tostring(self.battleResult) ~= tostring(Fight.result_win) then
    	return
    end

    -- 获取战斗开始前缓存的信息
    local cacheBattleInfo = WorldModel:getCurPVEBattleInfo()

    -- PVE 战斗
    if cacheBattleInfo ~= nil then

    else
    	if tostring(BattleControler:getPoolSystem()) == tostring(GameVars.poolSystem.gve) then

            self:showUnLockRomanceView()
	    end
    end
end
-- 额外奖励界面关闭时，弹出奇缘开启界面
function EliteServer:showUnLockRomanceView()
	echo("###WorldServer:showUnLockRomanceView=",BattleControler:getPoolSystem())
	if tostring(BattleControler:getPoolSystem()) == tostring(GameVars.poolSystem.gve) then
--		local poolType = BattleControler:getPoolType()
--		local matchData = FuncMatch.getMatchData(poolType)
--		local raidId = matchData.extId
--        local poolType = BattleControler:getPoolType()
--        EliteModel:tiaozhanHuidian(poolType)
--		EventControler:dispatchEvent(EliteEvent.ELITE_CHALLENGE_SUCCEED)
    end
end

-- GVE战斗结束回调
function EliteServer:onGVEBattleComplete(event)
    -- echo("\n\nWorldServer:onGVEBattleComplete,poolSystem=",BattleControler:getPoolSystem())
    local poolSystem = BattleControler:getPoolSystem()
    local battleLabel = FuncMatch.getBattleLabelByPoolSystem( poolSystem )
    
    self.battleResult = nil
    if tostring(battleLabel) == GameVars.battleLabels.worldGve1 then
    	local serverData = event.params.params
	    -- dump(serverData)
	    local poolType = BattleControler:getPoolType()
		local matchData = FuncMatch.getMatchData(poolType)
		local raidId = matchData.extId
		local raidData = FuncElite.getRaidDataByRaidId(raidId)
		local spCost = raidData.consume1
		
	    -- 额外奖励
	    self.extraBonus = {}
	    self.extraBonus = serverData.data.extraBonus

	    local rewardData = {}
	    rewardData.reward = serverData.data.reward
	    rewardData.result = serverData.data.result
	    rewardData.exp = spCost

	    -- 保存战斗结果
	    self.battleResult = rewardData.result

        
	    -- zhangyg 服务器没有在该接口回传exp
        local cacheData = UserModel:getCacheUserData()

        -- 战斗胜利
        if tonumber(Fight.result_win) == tonumber(rewardData.result) then
            rewardData.addExp = spCost
            
            EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID_ELITE});
        else
            rewardData.addExp = 1
        end

        rewardData.preLv = cacheData.preLv
        rewardData.preExp = cacheData.preExp

        ShareBossModel:setFindRewardStatus(serverData.data.shareBossReward)
	    -- echo("rewardData==")
	    -- dump(rewardData)
	    BattleControler:showReward(rewardData)
        -- 先写到这  
        if self.battleResult == 1 then
            local poolType = BattleControler:getPoolType()
            EliteModel:tiaozhanHuidian(poolType)
            Cache:set("QiYuanDuiHuanBtnType",1)
		    EventControler:dispatchEvent(EliteEvent.ELITE_CHALLENGE_SUCCEED)
        end
        
    end
end
-- GVE战斗结束
function EliteServer:onGveBattleClose()
    EventControler:dispatchEvent(WorldEvent.WORLDEVENT_CLOSE_GVE_BATTLE)
end

--挑战
function EliteServer:challenge(_Id,callBack)
    local params = {
		eliteId = _Id,
	}
	Server:sendRequest(params,MethodCode.elite_challenge_mark_2403 , callBack ,nil,nil,true)
end
-- 兑换
function EliteServer:exchange(_Id,_all,callBack)
    Server:sendRequest({ eliteId = _Id ,all = _all}, MethodCode.elite_exchange_mark_2405, callBack );
end
-- 购买
function EliteServer:buy(_Id,callBack)
    Server:sendRequest({ eliteId = _Id }, MethodCode.elite_buy_2407, callBack );
end


EliteServer:init();
return EliteServer