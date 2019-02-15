--
-- Author: xd
-- Date: 2015-12-08 19:59:02
--
local TimeControler={}

TimeControler.timeType_mmss = 1				--获取 分分:秒秒的格式的时间
TimeControler.timeType_hhmmss = 2				--获取 时时:分分:秒秒的格式的时间
TimeControler.timeType_dhhmmss = 3			--获取 天 时时:分分:秒秒的格式的时间
TimeControler.timeType_dhhmm = 4				--获取 天 时时:分分的格式的时间
TimeControler.timeType_hhmm = 5 				--获取时时分分格式

--时区这个宏要与 c 那一致
TimeControler.TIME_ZONE = {
	GMT8 = 0, --北京
	--other
}

--记录日期是否登入
TimeControler.dayLoginMap = {
	
}

--时差秒数 这个 可能根据不同语言版本计算不同时差 --如果要通过取余计算当天的小时数 需要加上这个时差取余才能得到正确结果 
TimeControler.timeDifference = 8*3600  				

--记录一些cd的剩余时间 以秒为单位  用小数存储,考虑到切换后台在切换回来的时间差 ,用get方法返回的时候 向上取整
TimeControler._cdObj  = nil			


TimeControler._hasgesitTime =false

local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
--计时器刷新
function TimeControler:init(  )

	--获取系统时间  这个是精确到秒的
	if not self._time then
		self._time = self:getTime()
	end
	self._bsTime = 0
	self._bsmlTime = self._bsTime * 1000
	self._miliTime = self._time * 1000
	self._cdObj = {}
	--初始化为true --因为在没有登入的时候 是 不需要开始计时的 这个时候 游戏从后台切换回来 不需要做任何处理
	self._hasinit = true

	

	--这里配置所有的 时间恢复事件
	self._eventObj = {
		[TimeEvent.TIMEEVENT_ONSP]= { 
		 	delay = FuncDataSetting.getDataByConstantName("HomeSPRecoverSpeed")  ,		--体力恢复间隔 6分钟
		 	--func = c_func(dispatch, TimeEvent.TIMEEVENT_ONSP) ,
		 },

		["testMofa"] ={ 
			delay = 10,  				--测试魔法恢复时间 5秒一次
		  	--func = c_func(dispatch, "testMofa"), 
		},
	}

	self:restartCountTime()

	EventControler:addEventListener(SystemEvent.SYSTEMEVENT_APP_ENTER_FOREGROUND   ,self.onEnterForeground, self)


	if not self._hasgesitTime then

		local requestFunc = function (  )
			
			if Server:checkIsSending() then
				return
			end
			if LoginControler:isLogin() then
				Server:sendRequest({}, MethodCode.sys_heartBeat, nil, true, true)
			end
			
		end

		self._heartbeatId = scheduler.scheduleGlobal(requestFunc,GameStatic.kakuraHeartBeatSecend)
		self._hasgesitTime = true
	end

	self.intervalTime = 0 -- 用于记录是否跨天的参数

	--注册全局计时
	self._updateId = scheduler.scheduleGlobal(c_func(self.registerTimeUpdate,self),1)

	--定时发事件
	self:addStaticTimeRegister();
	self:initToFireStaticTimeReachEvent();
	if device.platform == "windows" or  device.platform == "mac" then
		TimeControler:registerCycleCall("LOG_SAVELOCAL_EVENT",5,c_func( LogsControler.sureSaveLogs,LogsControler) )
	end
	
end

--注册周期回调
function TimeControler:registerCycleCall(_event,_delay,callFunc,callParams)
    self._eventObj[_event] = {delay = _delay,callFunc = callFunc,callParams = callParams}
    self:_startOneCount(self._eventObj[_event], _event)
end

--清除周期回调
function TimeControler:clearCycleCall( _eventName )
	local info = self._eventObj[_eventName]
	if not info then
		return
	end
	if info.delayId then
		scheduler.unscheduleGlobal(info.delayId)
	end
	
	if info.funcId then
		scheduler.unscheduleGlobal(info.funcId)
	end
	self._eventObj[_eventName] = nil
end

--注册全局刷新计时
function TimeControler:registerTimeUpdate( )
	if not self._isNeedUpdateTime then
		self._time = self._time +1
		self._bsTime = self._bsTime + 1
		self._bsmlTime = self._bsmlTime + 1000
		--同时更新下 带毫秒的时间
		self._miliTime = self._miliTime  + 1000
		for k,v in pairs(self._cdObj) do
			local leftTime = v
			if leftTime > 0 then
				leftTime = leftTime -1
				self._cdObj[k] = leftTime
				if leftTime <=0 then
					--销毁掉这个cdObj
					self._cdObj[k] = nil;
					--那么发送这个消息,表示时间到了
					--先销毁再发事件，因为发事件有可能再次注册这个事件 guan
					EventControler:dispatchEvent(k)
				end
			end
		end

	end
	
	local yushu = self._time % 10

	self.intervalTime = self.intervalTime + 1
	if self.intervalTime > 20 then-- 20秒判断一次是否跨天
		self.intervalTime = 0
		if LoginControler:isLogin() then
			self:checkOverDay()
		end
	end
end


--设置跨天参数
function TimeControler:setOverDay( result,needCheck )


	local targetTime = math.floor( result.serverInfo.serverTime/1000 )
	
	self._time = targetTime
	--毫秒
	self._milisecond = result.serverInfo.serverTime % 1000
	self._miliTime = result.serverInfo.serverTime 	--带毫秒的时间戳

	local timeData = os.date("*t", self._time)
	local key = timeData.day
	if timeData.hour>=4 then
		key = timeData.day
	else
		key = timeData.day-1
	end

	local str = os.date("%m-%d-%H-%M",self._time)
	--echo("____setOverDay",key,str  )
	local isOverDay = false
	if not  self.dayLoginMap[key] then
		isOverDay = true
	end
	if needCheck and isOverDay then
		EventControler:dispatchEvent(TimeEvent.TIMEEVENT_HAS_OVER_DAY)
	end
	self.dayLoginMap[key] =true
	--不需要在同步时间了
	self._isNeedUpdateTime =false
	self.canUpdateTime = true
	self:updateServerTime(result.serverInfo.serverTime)
end

--判断跨天
function TimeControler:checkOverDay(  )

	--如果是没有获取过用户信息的 那么不需要判断是否是否跨天
	if not Server:isGetUserInfo() then 
		return
	end

	local timeData = os.date("*t", self._time)
	local key = timeData.day
	if timeData.hour>=4 then
		key = timeData.day
	else
		key = timeData.day-1
	end

	if key == 0 then
		return 
	end
	
	if self.dayLoginMap[key] then
		return false
	end
	self.dayLoginMap[key] = true
	local str = os.date("%m-%d-%H:%M",self._time)
	echo("____跨天了-------",key,str)
	EventControler:dispatchEvent(TimeEvent.TIMEEVENT_HAS_OVER_DAY)
	--强刷用户数据
	local tempFunc = function (  )
		Server:sendRequest({}, MethodCode.user_getUserInfo_301, c_func(self.updateUserDataBack,self))
	end
	--0.1秒后强制更新用户数据
	WindowControler:globalDelayCall(tempFunc, 0.1)
	return true
end


--重新更新数据返回
function TimeControler:updateUserDataBack(result )
	
	if not result.result then
		local time = os.time() * 1000
		self:updateServerTime(time,true);
		return
	end
	echo("强制同步数据回来--------")
	local userData = result.result.data.user

	local delKeyMap = {}
	local tempTb = ServiceData:getModelToServerMap(  )
	local copyTb = table.copy(UserModel._data)
	for k,v in pairs(tempTb) do
		--如果是没有映射key的 
		if #v.keys == 0  then
			copyTb[v.model.__cname] = nil
		end
	end
	UserModel._data.avatar = nil
	table.findDelKey(copyTb,userData,delKeyMap,true)

	
	-- dump(delKeyMap,"___delKeyMap")
	local turnData = {u=userData,d = delKeyMap}
	--这里需要进行数据比对
	Server:updateBaseData(turnData,true)
	TimeControler:setOverDay( result.result,true )
	--强制进行状态检查
	LoginInfoControler:onBattleStatus( result.result.data,true )
end





--切换回来
function TimeControler:onEnterForeground(e )
	if not self._hasinit then
		return
	end

	--没有登入就不需要同步
	if not LoginControler:isLogin() then
		return
	end

	--清除所有倒计时
	self:clearAllCount()

	self._isNeedUpdateTime = true


	echo("需要updateTime")


	CommonServer:updateUserState(c_func(self.forceUpdateTime,self) )

	-- if  not Server:checkHasMethod(MethodCode.user_updateTime_317) then
	-- 	--发送一次同步时间操作
	-- 	Server:sendRequest({}, MethodCode.user_updateTime_317, c_func(self.forceUpdateTime,self))
	-- end
	
	

end





--清除所有的计时器
function TimeControler:clearAllCount(  )
	if not self._eventObj then return end
	for k,v in pairs(self._eventObj) do
		if v.delayId then
			scheduler.unscheduleGlobal(v.delayId)
		end
		
		if v.funcId then
			scheduler.unscheduleGlobal(v.funcId)
		end
	end
end


--强制同步服务器时间
function TimeControler:forceUpdateTime( result )
	--必须是正确的网络返回
	if not result.result then
		local time = os.time() * 1000
		self:updateServerTime(time,true);
		return
	end
	echo("___同步时间------",self._isNeedUpdateTime)
	self:updateServerTime(result.result.serverInfo.serverTime,true);
end



--重启计时器
function TimeControler:restartCountTime( )

	if not self._hasinit then
		return
	end
	--根据这个时间  来分别判断 需要延迟多久开始计时 为了计算更精准
	for k,v in pairs(self._eventObj) do
		self:_startOneCount(v,k)
	end

end

--开启一个计时器
function TimeControler:_startOneCount( info,eventName)
	local tempFunc = function (info,eventName  )
		self:dispatchEvent(eventName,1,info)
		info.funcId = scheduler.scheduleGlobal(c_func(self.dispatchEvent,self, eventName,1,info),info.delay)
	end
	local time = self:getServerTime()
	local delay = info.delay
	delay = time % delay
	delay = info.delay - delay
	info.delayId =  scheduler.performWithDelayGlobal( c_func(tempFunc,info,eventName ) ,delay  )
	
end


--发送恢复事件和次数
function TimeControler:dispatchEvent( eventName,times,info )
	times = times or 1
	--echo(eventName,"____times:",times)
	EventControler:dispatchEvent(eventName,times)
	if info and type(info) == "table" and info.callFunc then
		info.callFunc(times)
	end
end


--获取剩余刷新时间 接口   返回的是以秒为单位的时间 

--[[

timeType 获取时间类型  如果不传类型 那么返回的是秒数

]]
function TimeControler:getLeftResumeTime(eventName  ,timeType )
	local t = self:getServerTime()
	if not self._eventObj[eventName] then
		echo("TimeControler","错误的事件类型:",eventName)
		return 0
	end
	local delay = self._eventObj[eventName].delay
	local result = t%delay
	if (result ~= 0) then 
		result = delay - result
	end
	return self:turnTimeSec(result)

end

--转换时间描述
function TimeControler:turnTimeSec( second,timeType )
	if not timeType then
		return second

	elseif timeType == self.timeType_mmss then
		return fmtSecToMMSS(second)

	elseif timeType ==self.timeType_hhmmss then
		return fmtSecToHHMMSS(second)

	elseif timeType ==self.timeType_dhhmm then
		return fmtSecToLnDHM(second)

	elseif timeType == self.timeType_dhhmmss then
		return fmtSecToLnDHHMMSS(second)
	elseif timeType == self.timeType_hhmm then
		return fmtSecToHHMM(second)
	end

	return  second
end

--根据当前值,恢复间隔(秒为单位),最大值,上次更新时间计算恢复剩余总时间
-- timeType 显示时间格式  默认是 timeType_hhmmss
function TimeControler:getLeftFullRecoverTimeStr( current,recoverCD,maxNums,lastUpTime,timeType )
	local shengyusp =  maxNums - current
	local sumtime =  shengyusp * recoverCD
	local dt = TimeControler:getServerTime()- lastUpTime
	local times =  math.fmod(dt, recoverCD)
	local zuisongtime =  sumtime - times
	return TimeControler:turnTimeSec( zuisongtime,timeType or TimeControler.timeType_hhmmss )
end



-- 同步战斗服时间
function TimeControler:updateBattleServerTime( time )
	self._bsTime = math.ceil( time/1000 )
	self._bsmlTime = time
end


--同步服务器时间 
function TimeControler:updateServerTime( time,isForceUpdate )

	if self._isNeedUpdateTime and (not isForceUpdate) then
		echo("__不应该同步,应该等待 强制同步")
		return 
	end

	local targetTime = math.floor( time/1000 )
	local dt = targetTime - self._time
	if dt < -30 then
		echoWarn("时间小于0了 是不是时间倒退了或者网络延迟了----",dt)
		return
	end

	local str = os.date("%m-%d-%H:%M",targetTime)
	--echo("____updateServerTime,",str,dt ,isForceUpdate )

	self._time = targetTime
	--毫秒
	self._milisecond = time % 1000
	self._miliTime = time 	--带毫秒的时间戳

	if not self.canUpdateTime then 
		return
	end

	--判断是不是本地时间和服务器时间有较大差距,如果差距很大 而且没提示过的 那么给一个tis提示
	if DEBUG_FPS then
		if not self._hasTimeTips then
			local localTime = self:getLocalTime()
			--超过60秒判定修改时间
			if math.abs( targetTime - localTime ) >= 200 then
				local tempFunc = function (  )
					WindowControler:showTips("Server Time is Wrong!! ")
				end

				WindowControler:globalDelayCall(tempFunc, 3)
				self._hasTimeTips = true
			end
		end
		

	end

		
	if not Server:isGetUserInfo() then
		return
	end
	--如果是需要同步时间的 超过10秒就算不同步了 这个期间如果服务器修改时间了也得同步
	if self._isNeedUpdateTime or dt > 10 then
		self:clearAllCount()
		self._isNeedUpdateTime = false
		local curTime = self._time

		local lastTime = curTime - dt
		--计算应该恢复多少次体力
		for k,v in pairs(self._eventObj) do
			local ts = self:countIntervalTimes(v.delay,lastTime,curTime)
			
			--如果ts 大于0 那么恢复 ts秒
			if ts > 0 then
				-- echoError(ts,"___ts______")
				self:dispatchEvent(k, ts,v)
			end
		end

		--更新一些倒计时
		for k,v in pairs(self._cdObj) do
			local leftTime = v- dt
			if v > 0 then
				if leftTime <=0 then
					self._cdObj[k] = nil
					--通知时间到了
					EventControler:dispatchEvent(k)
					leftTime =0
				else
					self._cdObj[k] = leftTime
				end
				--echo(k,leftTime,"______cdleftTime")
			else
				--todo
			end
		end

		--重起计时器
		self:restartCountTime()

		--延迟几帧 判断是否需要获取邮件列表 因为这个时候可能掉线了
		local checkMaill = function (  )
			if LoginControler:isLogin() then
				MailServer:requestMail(  )
			end
		end

		--如果时间差大于60秒我同步下邮件
		if dt > 60 then
			WindowControler:globalDelayCall(checkMaill, 0.1)
		end
		--判断是否跨天跨天重新拉取301
		local result = self:checkOverDay()

		--切后台超过1小时 那么强制同步用户数据
		if not result and  dt > ServiceData.overBackGroundTime then
			Server:sendRequest({}, MethodCode.user_getUserInfo_301, c_func(self.updateUserDataBack,self))
		end

	end
	

end

--设置时区
function TimeControler:setTimeZone(tz)
	pc.PCUtils:setTimeZone(tz);
end

--获取毫秒
function TimeControler:getMiliSecond(  )
	return self._milisecond
end


--计算时间戳差值 恢复次数  比如 上次
--[[
	interval 时间间隔 以秒为单位
	lastTime 上次更新时间 以秒为单位的时间戳
	currentTime 如果为空 表示取当前系统时间

]]
function TimeControler:countIntervalTimes(interval ,lastTime,currentTime )
	local usec
	if not currentTime then
		currentTime,usec = self:getServerTime()
	end

	lastTime = lastTime - lastTime % interval

	currentTime = currentTime - currentTime % interval



	local dx = currentTime -lastTime
	if dx < 0 then
		dx =0
	end

	local times = math.floor(dx/interval)
	return times


end




--[[

	cd 相关


]]

--timeType  获取时间描述类型 不传递 表示 获取剩余秒数
-- 1 2 3 4对应 四种  描述格式
function TimeControler:getCdLeftime( cdName ,timeType)
	local sec = self._cdObj[cdName]
	sec = sec or 0
	sec = math.floor(sec)
	return self:turnTimeSec(sec, timeType)
end



--开始一个cd 计时   cdName 对应 TimeEvent的某个cdkey, leftTime 表示开始时的剩余时间
--时间到了之后会发送一个 cd到了的事件

--示例 比如  TimeControler:startOneCd(TimeEvent.TimeEvent.TIMEEVENT_CDPVP,5*60) --每当挑战一次jjc以后 的剩余cd
function TimeControler:startOneCd( cdName,leftTime )
	self._cdObj[cdName] = leftTime
end

--删除一个cd 计时
function TimeControler:removeOneCd( cdName )
	self._cdObj[cdName] = nil;
end


--计算下一次刷新时间 传递的是 配置表里面配的时间 
function TimeControler:countNextRefreshTime( m,h,w,j )
	-- local timeObj = os.date(self:getServerTime())
	local date = os.date("*t",self:getServerTime())
	-- local dateStr =date.year.."-"..date.month .."-"..date.day.." " ..date.hour ..":" ..date.min
	--从大到小判断
	--如果有月份中的第几天,比如签到
	local day

	--
	local resultTimeObj = table.copy(date)
	resultTimeObj.min = 0 
	resultTimeObj.sec = 0
	resultTimeObj.hour = 0

	local second = 0
	--判断是否已经是下一天了
	if m ~= "*"  then
		second = toint(m) * 60
		resultTimeObj.min = toint(m)
	end

	if h~= "*" then
		second = second + toint(h) * 3600
		resultTimeObj.hour = toint(h)
	end

	--判断当天是否过期了 那么计算时间需要从明天开始计算
	if date.hour * 3600 + date.min * 60 + date.sec > second then
		resultTimeObj.day = resultTimeObj.day + 1
		resultTimeObj.wday = resultTimeObj.wday+1
		if resultTimeObj.wday == 8 then
			resultTimeObj.wday =1
		end
	end




	if j ~= "*" then
		day = toint(j)
		--如果当前天数小于 日期	
		if resultTimeObj.day <= day then
			resultTimeObj.day = day
		else
			--那么说明是下一个月的
			resultTimeObj.day = day
			resultTimeObj.month = resultTimeObj.month +1
			--如果是明年的
			if resultTimeObj.month == 13 then
				resultTimeObj.month = 1
				resultTimeObj.year = resultTimeObj.year+1
			end
		end

	--如果是星期几
	elseif w ~="*" then
		--todo
		local wday = toint(w)
		wday = wday +1
		if wday ==8 then
			wday =1
		end
		--如果小于当前星期
		if wday < resultTimeObj.wday then
			resultTimeObj.day = resultTimeObj.day + (wday + 7 - resultTimeObj.wday)
		else
			resultTimeObj.day = resultTimeObj.day + (wday  - resultTimeObj.wday)
		end
		echo("wday",wday,"resultTimeObj.wday",resultTimeObj.wday)
	end

	local time = os.time(resultTimeObj)
	
	return time
end

--返回2个值  一个是秒的时间戳 一个是 3位的 1-999之间的  毫秒数
function TimeControler:getTime( )
	

	local time,usec = pc.PCUtils:getMicroTime()
	if not self._time then
		self._time = time
		self._milisecond = usec/1000
	end
	--没登入 走本地时间
	if not LoginControler:isLogin() then
		return time,usec
	end
	--如果误差小于2秒 那么走 本地时间 否则走服务器时间
	if math.abs(time - self._time) <= 2 then
		return time,usec
	end

	return self._time,usec
end


--获取本地时间 一个是秒的时间戳 一个是 6位的 1-999999之间的  微秒数
local _lastCacheGetSec
local _lastCacheGetMSec
function TimeControler:getLocalTime( )
	local sec ,ws = pc.PCUtils:getMicroTime()
	

	if device.platform == "windows" then

		if not _lastCacheGetSec then
			_lastCacheGetSec = sec
			_lastCacheGetMSec = ws
		else
			local dt = (sec-_lastCacheGetSec ) * 1000000 + ws -_lastCacheGetMSec 
			--如果获取到的时间小了 那么需要加一秒
			if ( dt < 0) then
				sec = sec +1
			end
			_lastCacheGetSec = sec
			_lastCacheGetMSec = ws
		end
	end

	

	return sec,ws
end


--获取服务器时间
function TimeControler:getServerTime(  )
	if not self._hasinit then
		return pc.PCUtils:getMicroTime()
	end
	return math.round(self._time)
end

-- 获取战斗服服务器时间(秒)
function TimeControler:getBattleServerTime()
	return math.ceil(self._bsTime)
end
-- 获取战斗服毫秒数
function TimeControler:getBattleServerMiliTime()
	return self._bsmlTime
end



--获取带毫秒的服务器时间
function TimeControler:getServerMiliTime(  )
	return self._miliTime
end


--获取微秒
function TimeControler:getUsec(  )
	local _,usec =  pc.PCUtils:getMicroTime()
	return usec
end

--获取次日时间戳
function TimeControler:getNextDayTime(  )
	
end

--销毁计时器
function TimeControler:deleteMe(  )
	self:clearAllCount()
	--清除所有事件
	EventControler:clearOneObjEvent(self)
end

local daySecond = 86400;

function TimeControler:initToFireStaticTimeReachEvent()

	function convertToSecond(time)
		local splitTime = string.split(time, ":");
		
		local hour = tonumber(splitTime[1]);
		local minute = tonumber(splitTime[2]);
		local second = tonumber(splitTime[3]);

		local passTime = hour * 60 * 60 + minute * 60 + second;

		return passTime
	end

	local dates = os.date("*t", self:getServerTime());
	local todayTime = dates.hour * 60 * 60 + dates.min * 60 + dates.sec;

	for k, staticTime in pairs(GameVars.fireEventTime) do
		local targetSceond = convertToSecond(staticTime);
		local timeStr =  self:gsubColonStringToNil(staticTime);

		local leftTime = 0;
		if todayTime >= targetSceond then 
			--时间过了，明天继续
			leftTime = targetSceond + daySecond - todayTime;
		else 
			leftTime = targetSceond - todayTime;
		end 
		self:startOneCd(self:getEventName(timeStr), leftTime);

	end

end

function TimeControler:gsubColonStringToNil(str)
	return string.gsub(str, ":", "")
end

--注册事件，明天继续发
function TimeControler:addStaticTimeRegister()
	for k, staticTime in pairs(GameVars.fireEventTime) do
		local str = TimeControler:gsubColonStringToNil(staticTime);
		EventControler:addEventListener(self:getEventName(str), 
        	self.reRegisterStaticTime, self);
	end
end

function TimeControler:reRegisterStaticTime(event)
	
	function getStaticTime( eventName )
		local len = string.len(eventName);
		local strLasts = string.sub(eventName, len - 5, len);
		local hour = string.sub(strLasts, 1, 2);
		local minute = string.sub(strLasts, 3, 4);
		local second = string.sub(strLasts, 5, 6);
		return hour .. ":" .. minute .. ":" .. second;
	end

	local eventName = event.name;
	local staticTime = getStaticTime(eventName);

	-- echo("reRegisterStaticTime " .. tostring(event.name));
	-- echo("staticTime " .. tostring(staticTime));

	local timeStr =  self:gsubColonStringToNil(staticTime);

	self:startOneCd(self:getEventName(timeStr), daySecond);

    EventControler:dispatchEvent(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        {clock = staticTime});
end

function TimeControler:getEventName(timeStr)
	return "TIMEEVENT_STATIC_TIME_REACH_" .. tostring(timeStr);
end

function TimeControler:destroyData()
	self:clearAllCount()
	self._hasinit = false
	self._time = nil
	self._cdObj = nil
	self._hasgesitTime = false
	if self._updateId then
		scheduler.unscheduleGlobal(self._updateId)
	end
	if self._heartbeatId then
		scheduler.unscheduleGlobal(self._heartbeatId)
	end
end

function TimeControler:getDayAfterOpenServer()
    local serverInfo = LoginControler:getServerInfo();

    local openTime = tonumber(serverInfo.openTime);
    local curTime = TimeControler:getServerTime();

    -- echo("---openTime--", tostring(openTime));
    -- echo("---curTime--", tostring(curTime));
    -- echo("---curTime - openTime--", tostring(curTime - openTime));

    local secondINaDay = 60 * 60 * 24;

    return math.floor( (curTime - openTime) / secondINaDay ) + 1;
end

--测试代码
-- local defChar = "*"

-- local nextTime = TimeControler:countNextRefreshTime( 35,15,defChar,2 )
-- local data = os.date("*t", nextTime)
-- dump(data,'__data')


function TimeControler:getTempTime(  )
	local time,msec = self:getLocalTime()
	return (time %100000000)  + msec/1000000
end

return TimeControler







