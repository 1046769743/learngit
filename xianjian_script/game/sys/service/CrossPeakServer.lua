

local CrossPeakServer = class("CrossPeakServer")

function CrossPeakServer:init()
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onBattleResult,self)
end
function CrossPeakServer:onBattleResult( data )
    -- dump(data.params,"战斗结束gamecontrol返回的数据")
    local battleResult = data.params
    if battleResult.battleLabel == GameVars.battleLabels.crossPeakPve then
        self:reportBattleResult(battleResult,c_func(self.onReportBattlResultCallBack,self))
    end
end
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
function CrossPeakServer:reportBattleResult(battleParams,callBack)
    local params = {
        battleResultClient = battleParams
    }

    Server:sendRequest(params,MethodCode.crosspeak_robotReport_5935 , callBack)
end
function CrossPeakServer:onReportBattlResultCallBack(data)
    -- dump(data,"单人战报上传结果===")
    if data.result.data then
        local rewardData = {}
        rewardData.result = data.result.data.result
        rewardData.crossPeak = {}
        rewardData.crossPeak.addScore = data.result.data.addScore
        rewardData.crossPeak.addCrossPeakCoin = data.result.data.addCrossPeakCoin
        rewardData.crossPeak.newBoxId = data.result.data.newBoxId
        BattleControler:showReward(rewardData)
    else
        local rewardData = {}
        rewardData.result = 2
        rewardData.crossPeak = {}
        rewardData.crossPeak.addScore = 0
        rewardData.crossPeak.addCrossPeakCoin = 0
        BattleControler:showReward(rewardData)
    end
end



-- 挑战购买次数
function CrossPeakServer:buyChallengeTimeServer(callBack)
    Server:sendRequest({}, MethodCode.crosspeak_buyChallengeTimes_5907, callBack );
end
-- 匹配机器人
function CrossPeakServer:startBattleWithRobot(callBack)
    Server:sendRequest({}, MethodCode.crosspeak_startMatch_5933, callBack );
end
-- 开始匹配 
function CrossPeakServer:startMatchServer(callBack)
    Server:sendRequest({}, MethodCode.crosspeak_startMatch_5901, callBack );
end
-- 取消匹配
function CrossPeakServer:quxiaoMatchServer(callBack)
    Server:sendRequest({}, MethodCode.crosspeak_quxiaoMatch_5903, callBack );
end
-- 领取活动奖励
function CrossPeakServer:getActiveRewardServer( id ,callBack )
    Server:sendRequest({rewardId = id}, MethodCode.crosspeak_receiveActiveReward_5911, callBack );
end
-- 领取活动奖励
function CrossPeakServer:requestRankServer( callBack )
    Server:sendRequest({}, MethodCode.crosspeak_request_rank_5923, callBack );
end
-- 排行请求
function CrossPeakServer:getCrossPeakRankSever(_type,start,length,callBack )
    local param = {rankType = _type,start = start,length = length}
    Server:sendRequest(param,MethodCode.crosspeak_request_crossPeak_rank_5925,callBack);
end
-- 解锁宝箱
function CrossPeakServer:crossPeakBoxUnlockSever(boxIndex,callBack )
    local param = {index = boxIndex}
    Server:sendRequest(param,MethodCode.crosspeak_box_unlock_5927,callBack);
end
-- 扔掉宝箱
function CrossPeakServer:crossPeakBoxRemoveSever(boxIndex,callBack )
    local param = {index = boxIndex}
    Server:sendRequest(param,MethodCode.crosspeak_box_remove_5929,callBack);
end
-- 领取宝箱奖励
function CrossPeakServer:crossPeakBoxRewardSever(boxIndex,isFree,callBack )
    local param = {index = boxIndex,isFree = isFree}
    Server:sendRequest(param,MethodCode.crosspeak_box_reward_5931,callBack);
end
-- 获取战斗信息列表
function CrossPeakServer:crossPeakReportListSever(callBack )
    Server:sendRequest({},MethodCode.crosspeak_report_list_5937,callBack);
    
end
-- 查看回放
function CrossPeakServer:crossPeakRePlayReport(params,callBack )
    Server:sendRequest(params,MethodCode.crosspeak_report_6301,callBack);
end
-- 领取小任务奖励 
function CrossPeakServer:crossPeakGetRenWuSever(id,callBack )
    Server:sendRequest({missionId = id},MethodCode.crosspeak_renwu_reward_5939,callBack);
end
-- 刷新小任务 crosspeak_renwu_refresh_5941
function CrossPeakServer:crossPeakRefreshRenWuSever(id,callBack )
    Server:sendRequest({missionId = id},MethodCode.crosspeak_renwu_refresh_5941,callBack);
end
-- 领取任务宝箱奖励
function CrossPeakServer:crossPeakGetRenWuBoxSever(callBack )
    Server:sendRequest({},MethodCode.crosspeak_renwu_box_5943,callBack);
end

function CrossPeakServer:crossPeakGuildKillSever(callBack )
    Server:sendRequest({},MethodCode.crosspeak_guild_kill_5947,callBack);
end



CrossPeakServer:init()
return CrossPeakServer











