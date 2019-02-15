--
-- Author: lxh
-- Date: 2017-10-14
--
--共享副本模块，网络服务类
local ShareBossServer = class("ShareBossServer")

function ShareBossServer:init()
	-- echoError("sfjsfsdf=======")
	-- PVE 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT, self.onPVEBattleComplete,self)
end

function ShareBossServer:getShareBossList(callBack)
	local params = {

	}
	Server:sendRequest(params, MethodCode.shareBoss_get_5401, callBack)
end

function ShareBossServer:challengeShareBossList(_formation, _trid, _tsec, callBack)
	local params = {
		formation = _formation,
		trid = _trid,
		tsec = _tsec,
	}
	Server:sendRequest(params, MethodCode.shareBoss_challenge_5403, callBack)
end

--开启一个幻境协战（原共享副本）
function ShareBossServer:openOneShareBoss(callBack)
    local params = {
        
    }
    Server:sendRequest(params, MethodCode.shareBoss_openShareBoss_5409, callBack)
end

function ShareBossServer:onPVEBattleComplete(data)
	local battleResult = data.params
    if battleResult.battleLabel == GameVars.battleLabels.shareBossPve then
        self:reportBattleResult(battleResult,c_func(self.onReportBattlResultCallBack,self))
    end
end

function ShareBossServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleResultClient = battleParams
	}
	Server:sendRequest(params,MethodCode.shareBoss_report_5405 , callBack)
end

function ShareBossServer:onReportBattlResultCallBack(event)
    if event.result ~= nil then
    	local result = event.result.data
    	result.result = 1 --共享副本永远是战斗胜利的
    	BattleControler:showReward(result)
    	ShareBossModel:setAllBossDatas()
    else
        ShareBossModel:setAllBossDatas()
    	BattleControler.gameControler:showShareBossEnd(function( )
            BattleControler:onExitBattle()	    	
	    end)
    end
end

ShareBossServer:init()

return ShareBossServer