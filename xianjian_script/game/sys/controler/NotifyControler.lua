--
-- Author: xd
-- Date: 2015-11-10 17:07:21
--

--通知管理
local NotifyControler = NotifyControler or  {}

--接收到一个通知
function NotifyControler:receivenNotify( notify)
	local time1 = os.clock()
	local  eventName = NotifyEvent[tostring(notify.method)]
	local result = notify.result
	
	echo("获取一条通知-----:",notify.method,eventName)
	--dump(notify)
	--如果对应了 通知名称  那么 发送这个通知出去 
	if eventName then
		EventControler:dispatchEvent(eventName,notify)
	end
	-- 更新时间
	if notify.battleServerTime then
		TimeControler:updateBattleServerTime(notify.battleServerTime)
	end

	--几个特殊的协议
	-- 收到GM推送消息 ,后面根据参数做扩展,
	--暂时只有推送日志到错误平台
	if eventName == "notify_sys_GM_push" then
		ClientActionControler:sendLuaErrorLogToPlatform()
	elseif eventName == "notify_battle_check_error" then
		if notify.params.data and notify.params.data.errorInfo then
			echo("__收到战斗服推送错误日志")
			local errorInfo = notify.params.data.errorInfo
			local str = errorInfo.message --"battlId:"..errorInfo.battleId.."\nbattleData:\n" .. errorInfo.battleData .."\n viewLog:"..self.gameControler.logical.logsInfo
	        --发送一个战斗服错误信息
	        if BattleControler._battleInfo then
	        	str = str .."\n battleInfo:\n".. json.encode(BattleControler._battleInfo)
	        	if BattleControler.gameControler and BattleControler.gameControler.verifyControler then
	        		str = str .."\n viewLog:\n" ..  BattleControler.gameControler.verifyControler:encrypt()
	        	end
	        end

	        ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.battlePushServerError..tostring(BattleControler:getBattleLabel()),str)
        	
        	echoError("收到战斗服的报错信息:"..errorInfo.code)

		end
		

	end
	
	--如果有pushId  那么必须给一个反馈
	--[[
	local time2 = os.clock()
	local costTime = time2 - time1 
	if costTime >= 0.2 then
		echoWarn("通知耗时=",costTime,eventName)
	end
	]]
end

return NotifyControler


