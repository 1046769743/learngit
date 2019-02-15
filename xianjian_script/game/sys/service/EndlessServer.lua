--
-- Author: lxh
-- Date: 2018-01-19 17:00:38
--
local EndlessServer = class("EndlessServer")

function EndlessServer:init()
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onBattleComplete, self)
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE, self.onEnterSecondBattle, self)
end 

function EndlessServer:setCurParams(params)
	self.params = params
end

function EndlessServer:onBattleComplete(data )
    local brData = data.params
    if (brData.battleLabel == GameVars.battleLabels.endlessPve) then
    	-- dump(brData,"====")
    	self._battleResult = brData
	    self:reportBattleResult(brData,c_func(self.onReportBattlResultCallBack,self))
    end
end
function EndlessServer:setWaveData(data)
	if self.waveData then
		self.waveData = {}
	end
	self.waveData = data
end
function EndlessServer:getWaveData()
	return self.waveData
end
function EndlessServer:resetWaveData()
	self.waveData = nil
end

function EndlessServer:onReportBattlResultCallBack( event )
	self.isFirstEnd = false
	local rewardData = {}
    if event.result ~= nil then
        rewardData.result = self._battleResult.rt
        rewardData.reward = event.result.data and (event.result.data.reward or {}) or {}
        rewardData.star = self._battleResult.star
        -- 如果是第一场战斗、直接退出游戏，不弹战斗结算
        if self.curWave == FuncEndless.waveNum.FIRST and 
        	rewardData.result == Fight.result_win then
        	--将上一场的数据存储起来
        	self:setWaveData(StatisticsControler:getStatisDatas(not self.isPVP)) 
	        self.isFirstEnd = true
	        self._star1 = self._battleResult.star --第一场的战斗结果
	        BattleControler:onExitBattle(self._battleResult.rt)
	        return
        end
        EndlessModel:clearCacheBattleUsers()
        EndlessModel:setHandleCount(nil)
    else
        rewardData.result = Fight.result_lose
    end
    if self._star1 then
    	-- 星级判断
    	if self._star1 == 1 and self._battleResult.star == 1 then
    		rewardData.star = 1
    	elseif self._star1 == 7 and self._battleResult.star == 7 then
    		rewardData.star = 7
    	else
    		rewardData.star = 5
    	end
    	self._star1 = nil
    end
    -- 展示结算界面
    BattleControler:showReward(rewardData)
end

function EndlessServer:onEnterSecondBattle(event)
	if self.isFirstEnd and self.curWave == FuncEndless.waveNum.FIRST then
		self.isFirstEnd = false
		local formation = {}
		formation.id = self.params.formation.id
		formation.partnerFormation = self.params.formation.partnerFormation2
		formation.treasureFormation = self.params.formation.treasureFormation2

		local endlessId = self.params.params[FuncTeamFormation.formation.endless].endlessId
		local wave = FuncEndless.waveNum.SECOND
		EndlessServer:challengeEndless(endlessId, formation, c_func(self.onEnterBattle, self), wave)  	
    end
end

function EndlessServer:onEnterBattle(data )
	if data.result then
		local serviceData = data.result.data.battleInfo
		-- dump(serviceData,"s0------")
		local battleInfo = BattleControler:turnServerDataToBattleInfo(serviceData)
		BattleControler:startBattleInfo(battleInfo)
	end
end

-- 挑战无底深渊关卡   需要传入的参数为  关卡endlessId  以及 阵型formation  wave表示打的是第几波怪
function EndlessServer:challengeEndless(endlessId, formation, callBack, wave)
	local params = {
		formation = formation,
		endlessId = endlessId,
		wave = wave,
	}
	self.curWave = wave
	Server:sendRequest(params, MethodCode.endless_startChallenge_6101, callBack, nil, nil, true)
end
-- 提交战报
function EndlessServer:reportBattleResult(battleParams, callBack)

	if self.curWave == FuncEndless.waveNum.FIRST then
		EndlessModel:setHandleCount(battleParams.handleCount)
	end

	local endlessFormation = TeamFormationModel:getFormation(FuncTeamFormation.formation.endless)
	local formation = {}
	formation.id = endlessFormation.id
	formation.partnerFormation = endlessFormation.partnerFormation
	formation.treasureFormation = endlessFormation.treasureFormation

	local lastBattleUsers = EndlessModel:getCacheBattleUsers()
	local lastHandleCount = EndlessModel:getHandleCount()
	local params = {
		battleResultClient = battleParams,
		endlessFormation = formation,
		lastBattleUsers = lastBattleUsers,
		lastHandleCount = lastHandleCount,
	}
	Server:sendRequest(params, MethodCode.endless_reportResult_6103, callBack, nil, nil, true)
end

-- 领取无底深渊宝箱  需要传入的参数为 层数floor  以及 宝箱id
function EndlessServer:getBoxReward(floor, boxId, callBack)
	local params = {
		floor = floor,
		id = boxId,
	}
	Server:sendRequest(params, MethodCode.endless_getBoxReward_6105, callBack, nil, nil, true)
end

--获取好友和盟友的无底深渊数据
function EndlessServer:getFriendAndGuildData(callBack)
	local params = {

		}
	Server:sendRequest(params, MethodCode.endless_getFriendAndGuildData_6107, callBack, nil, nil, true)
end

--无底深渊扫荡
function EndlessServer:sweepEndless(endlessId, callBack)
	local params = {
		endlessId = endlessId, 
	}
	Server:sendRequest(params, MethodCode.endless_sweepChallenge_6109, callBack, nil, nil, true)
end

function EndlessServer:buyEndlessChallengeTimes(callBack)
	local parmas = {

	}
	Server:sendRequest(parmas, MethodCode.endless_buyTimes_6111, callBack, nil, nil, true)
end

EndlessServer:init()

return EndlessServer