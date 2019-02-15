--[[
	Author: lichaoye
	Date: 2017-04-14
	查看阵容-Server
]]
local LineUpServer = class("LineUpServer")

function LineUpServer:init()
	
end

--[[
	获取阵容信息
	@@trid 玩家rid
	@@tsec 玩家所在区服
	@@formationId 阵型id 休闲玩法为99，功能玩法传自己的id
]]
function LineUpServer:requestFormationInfo(params)
	local params = params or {}
	local trid = tostring(params.trid)
	local tsec = tostring(params.tsec)
	local formationId = tostring(params.formationId)
	local _callBack = params.callBack
	Server:sendRequest(
		{trid = trid, tsec = tsec, formationId = formationId},
		MethodCode.lineup_get_formation_4501,
		function ( data )
			-- dump(result.result.data, "获取阵容信息返回值")
			local result = data.result
			if result then
				-- echo("获取阵容信息返回值",json.encode(result.data))
				local data = result.data
				data.formationId = FuncTeamFormation.formation.pve
				LineUpModel:initLineUpInfo( false, data )
				if _callBack then
					_callBack()
				end
			else
				echo("error MethodCode.lineup_get_formation_4501")
			end
		end
	)
end

--[[
	查看赞我的人
	@@page 请求第几页信息
	@@isOverWirte 是否直接覆盖以前的数组
]]
function LineUpServer:getPraiseList(page, _callBack, isOverWirte)
	Server:sendRequest(
		{page = page},
		MethodCode.lineup_get_praiselist_4509,
		function (data )
			dump(data, "赞我的人")
			local result = data.result
			if result then
				local data = result.data
				LineUpModel:updatePraiseList(data.info, page, isOverWirte)
				
				if page ~= 1 then -- page == 1时认为是初始化，不需要发消息
					EventControler:dispatchEvent(LineUpEvent.PRAISE_LIST_UPDATE_EVENT)
				end

				if _callBack then
					_callBack()
				end
			else
				echo("error MethodCode.lineup_get_formation_4501")
			end
		end
	)
end

--[[
	获取自己被点赞的信息
]]
function LineUpServer:getOwnPraiseInfo(_callBack)
	Server:sendRequest(
		{},
		MethodCode.lineup_get_ownpraise_info_4511,
		function (data )
			dump(data, "自己被点赞的信息")
			local result = data.result
			if result then
				local data = result.data
				LineUpModel:initLineUpInfo( true, data )
				if _callBack then
					_callBack()
				end
			else
				echo("error MethodCode.lineup_get_ownpraise_info_4511")
			end
		end
	)
end

--[[
	点赞
	@@trid 被赞玩家id
	@@tsec 被赞玩家区服
]]
function LineUpServer:givePraise()
	local trid, tsec = LineUpModel:getServerInfo()
	if LineUpModel:isRobot() then -- 机器人
		local doLike,likeNum = LineUpModel:getRobotPraise( trid )
		local info = {doLike = 1, likeNum = likeNum + 1}
		LineUpModel:setPraiseInfo(info)
		LineUpModel:setRobotPraise( trid, info )
		EventControler:dispatchEvent(LineUpEvent.PRAISE_UPDATE_EVENT, {})
	else -- 正常情况
		Server:sendRequest(
			{trid = tostring(trid), tsec = tostring(tsec)},
			MethodCode.lineup_give_praise_4503,
			function ( data )
				dump(data, "点赞返回值")
				local result = data.result
				if result then
					local data = result.data
					LineUpModel:setPraiseInfo(data)
					EventControler:dispatchEvent(LineUpEvent.PRAISE_UPDATE_EVENT, {})
				else
					echo("error MethodCode.lineup_cancel_praise_4505")
				end
			end
		)
	end
end

--[[
	取消点赞
	@@trid 被赞玩家id
	@@tsec 被赞玩家区服
]]
function LineUpServer:cancelPraise()
	local trid, tsec = LineUpModel:getServerInfo()
	if LineUpModel:isRobot() then -- 机器人
		echo("机器人取消点赞")
		local doLike,likeNum = LineUpModel:getRobotPraise( trid )
		local info = {doLike = 0, likeNum = likeNum - 1}
		LineUpModel:setPraiseInfo(info)
		LineUpModel:setRobotPraise( trid, info )
		EventControler:dispatchEvent(LineUpEvent.PRAISE_UPDATE_EVENT, {})
	else -- 正常
		local trid, tsec = LineUpModel:getServerInfo()
		Server:sendRequest(
			{trid = tostring(trid), tsec = tostring(tsec)},
			MethodCode.lineup_cancel_praise_4505,
			function ( data )
				dump(data, "取消点赞返回值")
				local result = data.result
				if result then
					local data = result.data
					LineUpModel:setPraiseInfo(data)
					EventControler:dispatchEvent(LineUpEvent.PRAISE_UPDATE_EVENT, {})
				else
					echo("error MethodCode.lineup_cancel_praise_4505")
				end
			end
		)
	end
end

--[[
	设置背景
	@@bgId 背景id
]]
function LineUpServer:setBackGround( bgId )
	Server:sendRequest(
		{backgroundId = tostring(bgId)},
		MethodCode.lineup_set_bg_4507,
		function ( result )
			dump(result, "设置背景返回值")
		end
	)
end

return LineUpServer