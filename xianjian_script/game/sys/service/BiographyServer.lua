--[[
	奇侠传记Server
	author: lcy
	add: 2018.7.20
]]

-- 奇侠传记
local BiographyServer = class("BiographyServer")

function BiographyServer:init()
	-- 战斗结束
    EventControler:addEventListener(BattleEvent.BATTLEEVENT_BATTLE_RESULT,self.onBattleResult,self)
end

function BiographyServer:changeCurrentPartner(nodeId,callBack)
	local params = {
		nodeId = nodeId,
	}

	Server:sendRequest(params, MethodCode.biography_change_partner_7801, callBack)
end
-- MethodCode.biography_finish_task_7803
function BiographyServer:finishTask(nodeId,callBack)
	local params = {
		nodeId = nodeId,
	}

	Server:sendRequest(params, MethodCode.biography_finish_task_7803, callBack)
end

function BiographyServer:getBoxReward(nodeId,callBack)
	local params = {
		nodeId = nodeId,
	}

	Server:sendRequest(params, MethodCode.biography_get_box_7805, callBack)	
end

-- 战斗接口
-- eventId从事件走，
function BiographyServer:enterBattleEvent(eventId,formation,callBack)
	local params = {
		eventId = eventId,
		formation = formation,
	}
	Server:sendRequest(params,MethodCode.biography_start_battle_7807, callBack)
end

function BiographyServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleResultClient = battleParams
	}

	Server:sendRequest(params, MethodCode.biography_finish_battle_7809, callBack)	
end

function BiographyServer:onBattleResult(data)
	local battleResult = data.params
	self.__result = battleResult.rt
	if battleResult.battleLabel == GameVars.battleLabels.biographyPve then
		self:reportBattleResult(battleResult, c_func(self.onReportBattlResultCallBack, self))
	end
end

function BiographyServer:onReportBattlResultCallBack(data)
	local rewardData = {}

	-- dump(data, "data ==========")
	
	if data.result.data then
		rewardData.result = self.__result
		rewardData.reward = data.result.data.reward
	else
		-- 看看怎么处理错误码
		-- local rewardData = {}
		rewardData.result = Fight.result_lose
	end
	
	BattleControler:showReward(rewardData)
end

BiographyServer:init()

return BiographyServer