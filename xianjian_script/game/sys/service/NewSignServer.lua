--[[
	Author: lichaoye
	Date: 2017-05-10
	签到-Server
]]

local NewSignServer = class("NewSignServer")

--[[
	抽签
	@@tType 玩家抽签类型1普通抽2摇一摇
]]
function NewSignServer:drawRequest(params)
	local params = params or {}
	local tType = tostring(params.tType)
	local _callBack = params.callBack
	Server:sendRequest(
		{type = tType},
		MethodCode.sign_mark_1901,
		function ( data )
			-- dump(data, "抽签返回值")
			local result = data.result
			if result then
				-- 测试
				-- result.data.level = result.data.index
				result.data.tType = tType
				NewSignModel:setSignReward(result.data)
				EventControler:dispatchEvent(WelfareEvent.REFRESH_MAIN_VIEW_RED)
				NewLotteryModel:sendMainLotteryRed()
				if _callBack then _callBack(result.data) end
			else
				echo("error MethodCode.sign_mark_1901")
			end
		end
	)
end

--[[
	领取签到奖励
	@@day 目标天数
]]
function NewSignServer:getTotalReward(params)
	local params = params or {}
	local day = tostring(params.day)
	local _callBack = params.callBack
	Server:sendRequest(
		{days = day},
		MethodCode.sign_markTotal_1903,
		function ( data )
			dump(data, "领取签到奖励")
			local result = data.result
			if result then
				if _callBack then _callBack() end
				EventControler:dispatchEvent(NewSignEvent.TOTALSIGN_UPDATE_EVENT)
				EventControler:dispatchEvent(WelfareEvent.REFRESH_MAIN_VIEW_RED)
				NewLotteryModel:sendMainLotteryRed()
			else
				echo("error MethodCode.sign_markTotal_1903")
			end
		end
	)
end

--[[
	获取上上签中奖列表
]]
function NewSignServer:getLuckyList(params)
	local params = params or {}
	local _callBack = params.callBack
	Server:sendRequest(
		{},
		MethodCode.sign_lucky_list_1905,
		function ( data )
			-- dump(data, "上上签列表")
			local result = data.result
			if result then
				NewSignModel:udpateBroadList(result.data.signPerfectList, true)
				EventControler:dispatchEvent(NewSignEvent.LUCKY_UPDATE_EVENT)
			else
				echo("error MethodCode.sign_lucky_list_1905")
			end
		end
	)
end

return NewSignServer