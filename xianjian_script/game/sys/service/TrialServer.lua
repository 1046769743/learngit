
local TrialServer = class("TrialServer")

function TrialServer:init()
	echo("TrialServer:init");

    --匹配战斗收到战斗结果
    EventControler:addEventListener("notify_trial_match_battle_end_1810", 
        self.MatchBattleEndCallBack, self);

    --主动离开战斗
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE, 
        self.onBattleLeave, self);

    --单人战斗结束，上报结果
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, 
        self.blockBattleEnd, self);


    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,
        self.showDeblockActionCallBack, self);


end 

function TrialServer:showDeblockActionCallBack()
	-- echo("-------------------------------------------------------------------");
	-- echo("-------======TrialServer:showDeblockActionCallBack=======---------");
	-- echo("-------------------------------------------------------------------");

end

--单人战斗结束，上报战斗结果
function TrialServer:blockBattleEnd(data) 
    echo("------TrialDetailView:blockBattleEnd(data)-------");

    -- local matchSystem = BattleControler:getBattleLabel();
	if BattleControler:checkIsTrail() ~= Fight.not_trail then 
	    -- dump(data.params, "TrialServer:blockBattleEnd");

	    local battleParams = {}
	    -- battleParams.frame = data.params.frame
	    -- battleParams.fragment = data.params.fragment
	    -- battleParams.operation = data.params.operation
	    -- battleParams.rt = data.params.rt
	    -- battleParams.battleId = self._battleId;
	    -- battleParams.star  = data.params.battleStar

	    --战斗结果 和服务器保持一直 
	    battleParams = data.params
	    
	    
	    self._result = data.params.rt;
	    self._star = data.params.star

	    self:endBattle(c_func(self.endBattleCallback, self), 
	        battleParams);
	end 
end

function TrialServer:setBattleId(battleId)
	self._battleId = battleId;
end

function TrialServer:getBattleId()
	return self._battleId
end

function TrialServer:onBattleLeave(data)
	echo("---TrialServer:onBattleLeave----")

	if BattleControler:checkIsTrail() ~= Fight.not_trail then 
	    echo("---TrialServer:onBattleLeave == true ----")
	    local battleParams = {}
	    battleParams.frame = data.params.frame
	    battleParams.fragment = data.params.fragment
	    battleParams.operation = data.params.operation
	    battleParams.rt = data.params.rt
	    battleParams.battleId = self._battleId;
	    battleParams.star = data.params.battleStar
	    self._result = data.params.rt;

	    -- local startable =  number.splitByNum( data.params.battleStar ,2)
	    -- -- dump(startable)
	    -- local star = 0
	    -- for i=1,#startable do
	    -- 	if startable[i] == 1 then
	    -- 		star = star + 1
	    -- 	end
	    -- end
	    -- battleParams.star =  star
	    self:endBattle(c_func(self.endBattleCallback, self), 
	        battleParams);
	end 
end

-- function TrialServer:isTrailBattle(matchSystem)
-- 	echo("---matchSystem---", matchSystem);
-- 	if matchSystem == GameVars.battleLabels.trailPve or 
-- 		matchSystem == GameVars.battleLabels.trailPve2 or
-- 			matchSystem == GameVars.battleLabels.trailPve3 or  
-- 				matchSystem == GameVars.battleLabels.trailGve1 or  
-- 					matchSystem == GameVars.battleLabels.trailGve2 or  
-- 						matchSystem == GameVars.battleLabels.trailGve3 or  
-- 							matchSystem == GameVars.poolSystem.trail1 or  
-- 								matchSystem == GameVars.poolSystem.trail2 or  
-- 									matchSystem == GameVars.poolSystem.trail3 then 
-- 		return true;
-- 	else 
-- 		return false;
-- 	end 
-- end

function TrialServer:MatchBattleEndCallBack(event)
    local matchSystem = BattleControler:getPoolSystem();
    
    echo(" ---------MatchBattleEndCallBack-------- " .. tostring(matchSystem));

    if  true then  --self:isTrailBattle(matchSystem) ==
	    -- dump(event.params, "MatchBattleEndCallBack event");

	    local preExp = UserModel:getCacheUserData().preExp;
	    local preLv = UserModel:getCacheUserData().preLv;

	    local isWin = event.params.params.data.result == "1" and true or false;
	    local expChange = 0;
	    local battleId = TrailModel:getbattleTypeAndId() --BattleControler:getPoolType();
	    if battleId ~= nil then
		    if isWin == true then 
		    	expChange = FuncTrail.getTrailData(battleId, "winCostSp");
		    else 
		    	expChange = FuncTrail.getTrailData(battleId, "lossCostSp");
		    end

		    echo("expChange " .. tostring(expChange));
		    TrailModel:setispipeizhong(false)  --匹配结束
		    BattleControler:showReward( {reward = event.params.params.data.reward,
		        result = tonumber(event.params.params.data.result), 
		        addExp = expChange, preExp = preExp, preLv = preLv}); 
		end
	end   
end

--战斗开始
function TrialServer:startBattle(callBack, id, battleType,_formation)
	UserModel:cacheUserData();

	-- -- 构建数据结构
 --    local _user_formation = table.deepCopy(TeamFormationModel:getPVPFormation())
 --    local _formation = {
 --        treasureFormation = table.deepCopy(_user_formation.treasureFormation),
 --        partnerFormation = table.deepCopy(_user_formation.partnerFormation),
 --    }

    -- echo("==============1111111111=============",id)
    

	-- echo("startBattle " .. tostring(id));
	-- local params = {
	-- 	trialId = id,
	-- 	-- battleType = battleType,
	-- 	formation = {},
	-- }
	-- echo("1111111111111111111111111111111111")
		-- 1是单人，2是匹配
		if battleType == 1 then 
			local params = {
		        trialId = id,
		        formation = _formation, --玩家自己的PVP阵列
		    }
			Server:sendRequest(params, 
				MethodCode.trial_start_battle_1801, callBack,nil,nil,true  )
		else 

			local params = {
				trialId = id
			}
			Server:sendRequest(params, 
				MethodCode.trial_normal_battle_1805, callBack,nil,nil,true )
		end 

end

--战斗结束
function TrialServer:endBattle(callBack, battleParams)
	echo("----TrialServer:endBattle-----");
	-- dump(battleParams, "__battleParams_");
	local params = {
		battleResultClient = battleParams
	}
	Server:sendRequest(params, MethodCode.trial_end_battle_1803, callBack);
end

--扫荡
function TrialServer:sweep(callBack, id, leftCount)
	-- echo("sweepBegin " .. tostring(id));
	-- echo("leftCount " .. tostring(leftCount));

	UserModel:cacheUserData();

	local params = {
		trialId = id,
		count = leftCount
	}

	Server:sendRequest(params, MethodCode.trial_sweep_battle_1807, callBack);
end

---最强路人
function TrialServer:getPowerLuRenData(callBack)

	local params = {}
	params.type = 31
	params.rank = 1
	params.rankEnd = 1

	Server:sendRequest(params, MethodCode.rank_getRankList_1701, callBack);

end

function TrialServer:endBattleCallback(event)
     -- echo("endBattleCallback");
     -- dump(event.result, "_____endBattleCallback-----");

	ChatModel:settematype(nil)   ---队伍聊天出去玩家
	TrailModel:setPiPeiPlayer(nil)  ---匹配除去玩家
	ChatModel:setTeamMessage({}) ---空的数据格式

    local reward = {};
  --   if event.error ~= nil then
  --   	local rewardData = {}
  --   	local preExp = UserModel:getCacheUserData().preExp;
		-- local preLv = UserModel:getCacheUserData().preLv;
		-- rewardData.result = Fight.result_lose
		-- rewardData.preLv = preLv
		-- rewardData.preExp = preExp
		-- BattleControler:showReward(rewardData)
		-- echo("1111111111111111======战斗验证失败=======1111111111111111")
  --   	return 
  --   end
    if event.result ~= nil and event.result.data ~= nil then 
        reward = event.result.data.data;
        reward = FuncCommon.repetitionRewardCom(reward)
	    self:callblackData(event.result.data)
	    local rewardData = {
	    	reward = reward,
	        result = self._result,
	        star = self._star
	    }
	    BattleControler:showReward(rewardData)
	    local startable =  number.splitByNum( self._star ,2)
	    -- dump(startable)
	    local star = 0
	    for i=1,#startable do
	    	if startable[i] == 1 then
	    		star = star + 1
	    	end
	    end
	    if event.result.data.dirtyList ~= nil then
	    	if event.result.data.dirtyList.u ~= nil then
	    		TrailModel:setserverStarData(event.result.data.dirtyList.u.trials)
	    	end
	    end
	    -- if tonumber(star) == 3 then
	    -- 	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT);
	    -- end


	else
		-- FightEvent:dispatchEvent(BattleEvent.BATTLEEVENT_CLOSE_REWARD)
		local rewardData = {}
    	local preExp = UserModel:getCacheUserData().preExp;
		local preLv = UserModel:getCacheUserData().preLv;
		rewardData.result = Fight.result_lose
		rewardData.preLv = preLv
		rewardData.preExp = preExp
		BattleControler:showReward(rewardData)
		-- echo("1111111111111111======战斗验证失败=======1111111111111111")
	end

end
function TrialServer:callblackData(data)
	local id = nil
	local starnumber = nil
	if data.dirtyList ~= nil then
		if data.dirtyList.u ~= nil then
			local reward = data.dirtyList.u.trials
			if reward~=nil then
				for k,v in pairs(reward) do 
					id = tonumber(k)
					starnumber = tonumber(v)
					TrailModel:setTrailStar(id,starnumber)
				end
			end
		end
	end
end
---创建组队
function TrialServer:sendCreateTeam(params,callBack)
	Server:sendRequest(params, MethodCode.trial_create_team_1811, callBack);
end
---加入组队
function TrialServer:sendAddteam(params,callBack)
	Server:sendRequest(params, MethodCode.trial_add_team_1815, callBack);
end


TrialServer:init();

return TrialServer





