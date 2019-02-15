

local MissionServer = class("MissionServer")

function MissionServer:init()
	-- 战斗离开
    -- EventControler:addEventListener(BattleEvent.BATTLEEVENT_USER_LEAVE,self.onPVEBattleLeave,self)
	-- 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onBattleResult,self)


    -- 战斗胜利
    -- EventControler:addEventListener(WorldEvent.WORLDEVENT_PVE_BATTLE_WIN, self.onPVEBattleWin, self)
    -- 战斗系统关闭
    -- EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_CLOSE,self.onBattleClose,self)
end
-- 
function MissionServer:onBattleResult( data )
	-- dump(data.params,"战斗结束gamecontrol返回的数据")

    self._battleResult = data.params
    if (self._battleResult.battleLabel == GameVars.battleLabels.missionMonkeyPve ) or 
     (self._battleResult.battleLabel == GameVars.battleLabels.missionBattlePve ) or 
     (self._battleResult.battleLabel == GameVars.battleLabels.missionIcePve ) or 
     (self._battleResult.battleLabel == GameVars.battleLabels.missionBombPve ) then
        self:reportBattleResult(self._battleResult,c_func(self.onReportBattlResultCallBack,self))
    end
end
--
-- 汇报战斗结果
-- battleParams 结构
--[[
	battleId
	frame
	fragment
	operation
	rt
	star
]]
function MissionServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleResultClient = battleParams
	}
    dump(battleParams, "---汇报战斗结果-----", 8)
    local missionId = MissionModel:getDoingMissionId()
    local missionType = FuncMission.getMissionTypeById( missionId )
    
    if tonumber(missionType) == FuncMission.MISSIONTYPE.HOUZI then
        Server:sendRequest(params,MethodCode.mission_finishMission_5509 , callBack)
    elseif tonumber(missionType) == FuncMission.MISSIONTYPE.PVP then
        Server:sendRequest(params,MethodCode.mission_finishMission_5513 , callBack)
    elseif tonumber(missionType) == FuncMission.MISSIONTYPE.QUEST then
        -- 答题不会进
    elseif tonumber(missionType) == FuncMission.MISSIONTYPE.BINGDONG then
        Server:sendRequest(params,MethodCode.mission_finishMission_5509 , callBack)
    elseif tonumber(missionType) == FuncMission.MISSIONTYPE.BAOZHA then
        Server:sendRequest(params,MethodCode.mission_finishMission_5509 , callBack)
    end
	
end
--
function MissionServer:onReportBattlResultCallBack(event)
	-- dump(event,"战报上传,服务器返回奖励数据")
	local cacheData = UserModel:getCacheUserData()
    local rewardData = {}
    rewardData.result = self._battleResult.rt
    if event.result ~= nil then
        -- echoError("战斗结束了，self._battleResult.index == ",event.result.data.index)
    	-- self._battleResult.index
        if event.result.data.index >= 0 then
            MissionModel:setBattleReward(event.result.data.index)
        else
            MissionModel:setBattleReward(nil)
        end
    elseif event.error.code == 550901 then
        -- 此时已经过期
        MissionModel:setBattleReward(nil)
        WindowControler:showTips(GameConfig.getLanguage("#tid_mission_003"))
    end
    -- 展示结算界面
    EventControler:dispatchEvent(MissionEvent.CHUZHANDOU_EVENT) 
    BattleControler:showReward(rewardData)
end


-- 请求宝箱信息
function MissionServer:requestBoxReward(params, callBack)
	
    Server:sendRequest(params,MethodCode.mission_getReward_5501, callBack);
end
-- 获取排行
function MissionServer:requestRanK( params, callBack )
	Server:sendRequest(params,MethodCode.mission_getRank_5503, callBack);
end
-- 获取对手信息
function MissionServer:requestUserInfo( params, callBack )
	Server:sendRequest(params,MethodCode.mission_getBattleInfo_5505, callBack);
end
-- 参与活动 单人战斗
function MissionServer:requestActive( params, callBack )
	Server:sendRequest(params,MethodCode.mission_startMission_5507, callBack);
end
-- PVP战斗  比武切磋
function MissionServer:requestPvpActive( params, callBack )
    Server:sendRequest(params,MethodCode.mission_startBattleMission_5511, callBack);
end
-- 开始答题
function MissionServer:requestQuestActive( params, callBack )
    Server:sendRequest(params,MethodCode.mission_startExamMission_5515, callBack);
end
-- 退出答题
function MissionServer:quitMissionQuestActive( params,callBack )
    Server:sendRequest(params,MethodCode.mission_quitExamMission_5517, callBack);
end
-- 提交答题
function MissionServer:tijiaoQuestActive( params, callBack )
    Server:sendRequest(params,MethodCode.mission_reportExamMission_5519, callBack);
end

MissionServer:init()
return MissionServer











