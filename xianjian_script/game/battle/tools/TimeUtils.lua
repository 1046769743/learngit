--
-- Author: Your Name
-- Date: 2014-01-24 15:48:33
--

local registerObjArr = {}


TimeUtils = TimeUtils and TimeUtils or  {}

local view
local frameRate = 60

TimeUtils._timeArray = {}

function TimeUtils.getInfoLength(  )
	return #TimeUtils._timeArray
end

local actions
function TimeUtils.initTimeUtils(  )
	-- if not actions then
	-- 	actions = view:schedule(TimeUtils.updateFrame,1/frameRate)
	-- end
	-- gameLayer:schedule(mainUpdateFrame,1/GameVars.GAMEFRAMERATE)
end

local _currentCount =0
local speed = 1

function TimeUtils.setSpeed( spd )
	speed = spd
end

local playCheck = true

function TimeUtils.playOrPause(value )
	playCheck = value
end


function TimeUtils.updateFrame(   )

	local length = #registerObjArr

	for i=length,1,-1 do
		TimeUtils._updateFrame(registerObjArr[i]  )
	end
	TimeUtils:_updateFrame()

end


function TimeUtils:_updateFrame(   )
	
	local timeArr = self._timeArray
	local len = #timeArr
	if len ==0 then
		return
	end
	local info
	if not actions then

	end
	local allArr = table.copy(timeArr)

	local oldLen = len

	len = #allArr

	if oldLen ~= len then
		Log.print(oldLen,len,"__copy后的数组长度变了--")
	end
	if len ==0 then
		return
	end
	for i=len,1,-1 do
		info = allArr[i]
		
		-- 是不能暂停的  那么就继续
		if ( (not playCheck) and ( not  info.outPause)   )    then
		
		--如果不在这个数组里面 因为某些计时的回调操作可能 会清除部分 计时
		elseif table.indexof(timeArr, info ) == false then
			
		else
			info[1] = info[1]-1
			--如果是停止的 那么什么都不做
			if info.isStop then

			else
				--如果 时间到了
				if(info[1] == 0) then
					--local temp1 = table.getn(timeArr)
					table.removebyvalue(timeArr,info)
					--local temp2 =  table.getn(timeArr)
					TimeUtils.checkStopTime( self )

					local func = info[2]
					if func ~= nil then
						if info[3] ~=nil then
						--todo
							func(unpack(info[3]))
						else
							func()
						end
					else
						if not info[5] then
							error("传入的函数是空的")
						end
					end
				end

				--如果是做持续事件的
				if info[8]  then
					--todo
					info[8] = info[8] +1
					--如果达到间隔了
					if info[8]% info[7] ==0 then
						--todo
						if info[5] ~= nil then
							if info[6] == nil then
								--todo
								info[5]()
							else
								info[5](unpack(info[6]))
							end

						end
					end

				end	
			end
		end
	end


end




--设置间隔执行事件
function TimeUtils.setTimeOut( time,func,params  ,outPause)
	return TimeUtils:_setTimeOut(time,func,params  ,outPause)
end

function TimeUtils:_setTimeOut(time, func, params, outPause)
	local timeArr =  self._timeArray
	if not outPause then outPause  = false end
	_currentCount = _currentCount + 1
	if func == nil then Log.error("传入的函数是空的..持续时间:"..time) return end
	if params and type(params) ~= "table" then
		Log.debug("传入的参数格式是错误的,必须为table") 
		params = {params}
	end

	if time <=0 then
		--todo
		if func ~= nil then
			if params ~= nil then
				func(unpack(params))
			else
				func()
			end
		end
		return _currentCount
	end

	local info = {}
	info[1] = math.round(time)
	info[2] = func
	info[3] = params
	info[4] = _currentCount 	--记录计数id 到时清除计数就是靠这个
	info.outPause = outPause
	table.insert(timeArr,1,info)
	return _currentCount
end






--info信息 1-剩余时间，2-回调函数, 3-回调参数  4-计数， 5-持续函数 6-持续函数参数  7-间隔 8间隔计数  
--info.isStop = false 是否停止 默认为false 

--持续做什么事情																			
function TimeUtils.setLastTimeOut(lastFunc,lastParams,delay,lastTime, endFunc,endParams  ,outPause )
	
	return TimeUtils:_setLastTimeOut(lastFunc,lastParams,delay,lastTime, endFunc,endParams  ,outPause)
end


--持续做什么事情																			
function TimeUtils:_setLastTimeOut(lastFunc,lastParams,delay,lastTime, endFunc,endParams  ,outPause )
	local timeArr =  self._timeArray
	if not outPause then outPause  = false end
	local info = {}
	if not lastTime then lastTime =-1 end
	if not delay then delay  = 1 end 
	_currentCount = _currentCount+ 1
	info[1] = lastTime
	info[2] = endFunc
	info[3] = endParams
	info[4] = _currentCount
	info[5] = lastFunc
	info[6] = lastParams
	info[7] = delay
	info[8] =0
	info.outPause = outPause
	table.insert(timeArr,1,info)
	self:checkUpdate( )
	return _currentCount
end



--清除一个计时
function TimeUtils.clearTimeOut( func,id,obj )
	-- body
	return TimeUtils:_clearTimeOut( func,id,obj )
	

end


--清除一个计时
function TimeUtils:_clearTimeOut( func,id,obj )
	-- body
	local timeArr = self._timeArray
	local len = #timeArr
	local result =false
	local haseClear =false
	local info
	if len == 0 then return haseClear end
	
	for i = len,1 ,-1 do
		info = timeArr[i]
		result = false
		if func ~= nil then
			if info[2] == func  then
				if not obj then
					result = true
				else
					--如果是传入对象的 那么必须是这个函数的第一个参数 为obj 
					if info[3] and info[3][1] and obj == info[3][1] then
						result = true
					end
				end
			end

			if info[5] == func then
				if not obj then
					result = true
				else 
					if obj == info[6][1] then
						result = true
					end
				end
			end

		end

		if id ~= nil then
			if info[4] == id then
				result = true
			end
		end

		if result then
			table.remove(timeArr,i)
			haseClear = true
			TimeUtils.checkStopTime( self )
		end
	end


	return haseClear

end


--清除一个对象的所有计时
function TimeUtils.clearTimeByObject(obj )
	return TimeUtils:_clearTimeByObject(obj )
end


--清除一个对象的所有计时
function TimeUtils:_clearTimeByObject(obj )
	--print("__清除计时-------")
	if not obj then
		Log.debug("清除了空的对象obj")
		return false
	end

	local timeArr =  self._timeArray

	if not  timeArr  then
		Log.debug("__没有时间数组了")
		return false
	end

	local len = #timeArr
	local result = false
	local haseClear = false

	local info
	local i
	if len == 0 then return haseClear end

	for i=len,1 ,-1 do
		info = timeArr[i]
		if (not info) then
			Log.debug("__没有info信息") 
		else
			result =false
			-- and  table.keyof(obj, info[2] )
			if info[3] and info[3][1] == obj and  table.keyof(obj.__index, info[2] ) then
				result = true
			end
			
			if info[6] and info[6][1] == obj and  table.keyof(obj.__index, info[5] ) then
				result = true
			end

			if result then
				table.remove(timeArr,i)
				haseClear = true
				TimeUtils.checkStopTime( self )
			end
		end
	end
	return haseClear
end

--设置一个计时暂停或者恢复 true播放 false 停止
function TimeUtils.setPlayOrPauseOne(value,func,id,obj )
	TimeUtils:_setPlayOrPauseOne(value,func,id,obj )
end

--设置一个计时暂停或者恢复 true播放 false 停止
function TimeUtils:_setPlayOrPauseOne(value,func,id,obj )
	local timeArr =  self._timeArray
	local len = #timeArr
	local result =false
	local info
	if len == 0 then return  end
	
	for i=len,1 ,-1 do
		info = timeArr[i]
		result =false
		if func ~= nil then
			if info[2] == func  then
				if not obj then
					result = true
				else 
					--如果是传入对象的 那么必须是这个函数的第一个参数 为obj 
					if obj == info[3][1] then
						result = true
					end
				end
			end

			if info[5] == func then
				if not obj then
					result = true
				else 
					if obj == info[6][1] then
						result = true
					end
				end
			end

		end

		if result then
			-- 设置这个 计时暂停或者恢复
			info.isStop = value
		end

	end
end

--获取一个time的剩余时间
function TimeUtils.getLeftTimeOut( func,id ,obj )
	return TimeUtils:_getLeftTimeOut( func,id ,obj )
end

--获取一个time的剩余时间
function TimeUtils:_getLeftTimeOut( func,id ,obj )
	-- body
	local timeArr =  self._timeArray
	local len = #timeArr
	local leftTime =0
	local result =false
	if len == 0 then return leftTime end
	local info
	for i=len,1 ,-1 do
		info = timeArr[i]
		result =false
		if func ~= nil then
			if info[2] == func  then
				if not obj then
					result = true
				else 
					--如果是传入对象的 那么必须是这个函数的第一个参数 为obj 
					if obj == info[3][1]   then
						result = true
					end
				end
			end

			if info[5] == func then
				if not obj then
					result = true
				else 
					if obj == info[6][1] then
						result = true
					end
				end
			end
		end

		if result then
			leftTime = info[1]
			return leftTime
		end

	end
	return leftTime
end


function TimeUtils:checkStopTime(  )
	--如果长度为0了
	if #self._timeArray ==0 then
		
	end
end


function TimeUtils:checkUpdate( )
	if true then
		return
	end
end


--清除所有的计时
function TimeUtils.clearAllTime( )
	-- body
	for i,v in ipairs(registerObjArr) do
		TimeUtils._clearAllTime(v,true)
	end
	registerObjArr = {}
end

--清除所有的计时
function TimeUtils:_clearAllTime(outToArr )
	self._timeArray= {}
	if not outToArr then
		table.removebyvalue(registerObjArr, outToArr, true)
	end
end



--清除所有player的计时
function TimeUtils.clearAllPlayerTime(  )
	local timeArr = TimeUtils._timeArray
	local len = #timeArr
	local result = false
	local haseClear = false

	local info
	local i
	if len == 0 then return haseClear end

	local player

	for i=len,1 ,-1 do
		info = timeArr[i]
		if (not info) then
			Log.print ("清除playerTime的时候__没有info信息") 
		else
			result =false
			-- and  table.keyOfItem(obj, info[2] )
			if info[3] and info[3][1]   then
				player = info[3][1]
				if type( player) == "table" then
					if player.toInfoString then
						result = true
					end
				end
			end
			
			if info[6] and info[6][1]  then
				player = info[6][1]
				if type( player) == "table" then
					if player.toInfoString then
						result = true
					end
				end
			end

			if result then
				table.remove(timeArr,i)
				haseClear = true
				TimeUtils:checkStopTime(  )
			end
		end
	end


	return haseClear
end



--给某一个对象注册计时器
function TimeUtils.registTime( obj,handleUpdate )
	if type(obj) ~= "table" then
		Log.debug("传入的对象不是table")
		return
	end
	--如果已经有了计时器了
	if obj._timeArray then
		return
	end
	--为了防止这个属性被占用
	obj._timeArray = {}

	if not handleUpdate then
		if table.indexof(registerObjArr, obj) == false then
			table.insert(registerObjArr, obj)
		end
	else
		obj.setTimeOut = TimeUtils._setTimeOut
		obj.clearTimeOut = TimeUtils._clearTimeOut
		obj.getLeftTimeOut = TimeUtils._getLeftTimeOut
		obj.updateTimeInfo =  TimeUtils._updateFrame
		obj.setLastTimeOut = TimeUtils._setLastTimeOut
		obj.clearTimeOut = TimeUtils._clearTimeOut
		obj.clearTimeByObject = TimeUtils._clearTimeByObject

		obj.setPlayOrPauseOne = TimeUtils._setPlayOrPauseOne
		obj.checkUpdate = TimeUtils.checkUpdate
		obj.clearAllTime = TimeUtils._clearAllTime
	end

end

function TimeUtils.destroy( obj )
	if type(obj) ~= "table" then
		Log.debug("传入的对象不是table")
		return
	end
	obj._timeArray = nil
end


