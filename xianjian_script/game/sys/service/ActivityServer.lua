local ActivityServer = class("ActivityServer")

function ActivityServer:finishTask(scheduleId, taskId, callBack)
	local params = {scheduleId = scheduleId, taskId = taskId}
	Server:sendRequest(params, 
		MethodCode.act_finish_task_3601, callBack)
end

function ActivityServer:getTiLiReward(params, callBack)
	Server:sendRequest(params,MethodCode.get_TILI_365, callBack)
end

function ActivityServer:getKaiFuQianggouData(params, callBack)
	Server:sendRequest(params,MethodCode.act_getKaiFuQGData_6501, callBack)
end

function ActivityServer:kaiFuQianggouData(params, callBack)
	Server:sendRequest(params,MethodCode.act_getKaiFuQG_6503, callBack)
end

function ActivityServer:zhaohuiReward( params, callBack )
	Server:sendRequest(params,MethodCode.retrieve_retrieveGetReward_6701, callBack)
end

function ActivityServer:travelShopTakeDiscount( params, callBack )
	Server:sendRequest(params,MethodCode.travel_shop_take_discount_7705, callBack)
end

function ActivityServer:sharedSuccess(callBack)
	local params = {}
	Server:sendRequest(params, MethodCode.shared_success_375, callBack)
end

return ActivityServer




