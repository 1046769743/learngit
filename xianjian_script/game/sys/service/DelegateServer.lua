--[[
	Author: lichaoye
	Date: 2017-05-31
	挂机-Server
]]

local DelegateServer = class("DelegateServer")

--[[
	获取任务列表
]]
function DelegateServer:getTaskList(params)
	local params = params or {}
	local _callBack = params.callBack
	Server:sendRequest(
		{},
		MethodCode.delegate_get_list_4401,
		function ( data )
			-- dump(data, "挂机列表返回值")
			local result = data.result
			if result then
				if _callBack then _callBack(result.data.data) end
			else
				echo("error MethodCode.delegate_get_list_4401")
			end
		end
	)
end

--[[
	开始任务
	@@ delegateId 任务Id
	@@ partners 伙伴列表 {}
]]
function DelegateServer:startTask(params)
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local partners = params.partners
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId, partners = partners},
		MethodCode.delegate_start_task_4403,
		function ( data )
			-- dump(data, "开始任务返回值")
			local result = data.result
			-- 靠dirtyList刷新
			DelegateModel:reFreshTaskList()
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_start_task_4403")
			end
		end
	)
end

--[[
	完成任务
	@@ delegateId 任务Id
]]
function DelegateServer:finishTask(params)
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId},
		MethodCode.delegate_finish_task_4405,
		function ( data )
			-- dump(data, "完成任务返回值")
			local result = data.result
			-- 靠dirtyList刷新
			DelegateModel:reFreshTaskList()
			if result then
				EventControler:dispatchEvent(DelegateEvent.DELEGATE_FINISH_CHANGE)
				result.data.taskId = delegateId
				if _callBack then _callBack(result.data) end
			else
				echo("error MethodCode.delegate_finish_task_4405")
			end
		end
	)
end

--[[
	加速任务
	@@ delegateId 任务Id
]]
function DelegateServer:speedUpTask(params)
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId},
		MethodCode.delegate_speedup_task_4417,
		function ( data )
			-- dump(data, "加速任务返回值")
			-- 靠dirtyList刷新
			DelegateModel:reFreshTaskList()
			local result = data.result
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_speedup_task_4417")
			end
		end
	)
end

--[[
	刷新任务
	@@ delegateId 任务Id
]]
function DelegateServer:refreshTask(params)
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId},
		MethodCode.delegate_refresh_task_4409,
		function ( data )
			dump(data, "刷新任务返回值")
			-- 靠dirtyList刷新
			DelegateModel:reFreshTaskList()
			local result = data.result
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_refresh_task_4409")
			end
		end
	)
end
-- 召回任务 delegateId 任务Id
function DelegateServer:recallTask(params)
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId},
		MethodCode.delegate_recall_task_4411,
		function ( data )
			-- dump(data, "召回任务返回值")

			DelegateModel:reFreshTaskList()
			local result = data.result
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_recall_task_4411")
			end
		end
	)
end
-- 刷新特殊委托任务
function DelegateServer:refreshSpeicalDelegate(params )
	local params = params or {}
	local delegateId = tonumber(params.delegateId)
	local _callBack = params.callBack
	Server:sendRequest(
		{delegateId = delegateId},
		MethodCode.delegate_refresh__special_task_4413,
		function ( data )
			DelegateModel:reFreshTaskList()
			local result = data.result
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_refresh__special_task_4413")
			end
		end
	)
end
-- 刷新普通委托
function DelegateServer:refreshNormalDelegate(params )
	local params = params or {}
	local _callBack = params.callBack
	Server:sendRequest({},
		MethodCode.delegate_refresh__normal_task_4415,
		function ( data )
			DelegateModel:reFreshTaskList()
			local result = data.result
			if result then
				if _callBack then _callBack() end
			else
				echo("error MethodCode.delegate_refresh__normal_task_4415")
			end
		end
	)
end


return DelegateServer