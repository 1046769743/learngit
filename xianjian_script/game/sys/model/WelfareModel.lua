-- WelfareModel
--福利模块
local WelfareModel = class("WelfareModel", BaseModel)

function WelfareModel:init()
	-- WelfareModel.super.init(self, eliteArr)
 --    self.elitesChallengeArr = self._data;  -- 记录挑战
 	self:eventListener()
 	self:getTimeSendHome()
 	self:sendHomeRed()
end

function WelfareModel:sendHomeRed()
	local singred = NewSignModel:isNewSignRedPoint()
	local lingshired = NewLotteryModel:fuliIsShowRed()
	local tilired =  self:getTiliRed()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
	{redPointType = HomeModel.REDPOINT.MAPSYSTEM.WELFARE, isShow = singred or lingshired or self:getTiliRed()})
end	

function WelfareModel:eventListener()
	EventControler:addEventListener(WelfareEvent.SEND_HOME_RED_WELFARE, self.sendHomeRed, self)
end
function WelfareModel:updataCDTime()
	self:getTimeSendHome()
	self:sendHomeRed()
end

function WelfareModel:getTimeSendHome()
	local servetime = os.date("*t", TimeControler:getServerTime()) 
	-- dump(servetime,"服务器时间=======")
	local hour = tonumber(servetime.hour)
	local timeData = FuncActivity.getDailyTime()
	local expireTimes = 0
	local endhuors = nil
	if hour <= 8 then
		endhuors = 8

	else
		for i=1,#timeData do
			local qiantime = tonumber(timeData[i][1])
			local houtime = tonumber(timeData[i][2])
			if hour < qiantime  then
				endhuors = qiantime
				break
			end
		end
	end
	if endhuors ~= nil then
		local sehgnyutime = endhuors - hour
		if sehgnyutime <= 0 then
			sehgnyutime = 1
		end
		expireTimes = sehgnyutime*3600 - tonumber(servetime.min)*60 - servetime.sec
		if expireTimes > 0 then
		 	TimeControler:startOneCd(WelfareEvent.SEND_HOME_RED_WELFARE,expireTimes+2 )
		end
	end
end

function WelfareModel:getTiliRed()
	local systemname = FuncCommon.SYSTEM_NAME.SPFOOD
	local isopen = FuncCommon.isSystemOpen(systemname)
	if not isopen then
		return false
	end

	--服务器时间
	local sumNum = CountModel:getTiLiNum()
	local servetime = os.date("*t", TimeControler:getServerTime()) 
	local hour = servetime.hour
	local data = FuncGuild.byCountTypeGetTable(sumNum,4) --服务器数据
	local index = 1
	local serveData = {}
	for i=#data,1,-1 do
		serveData[index] = data[i]
		index = index + 1
	end
	local isallget = true
	for i=1,#serveData do
		if serveData[i] ~= 1 then
			isallget = false
		end
	end

	if not isallget then
		if hour < 4 then
			return true
		end
	end

	if not isallget then
		local timeData = FuncActivity.getDailyTime()
		local selectFood = nil
		for i=1,#timeData do
			local qiantime = tonumber(timeData[i][1])
			local houtime = tonumber(timeData[i][2])
			-- local strArr = qiantime..":00".."~"..houtime..":00".."  "..strname
			-- if hour >= houtime  then--and hour <= houtime then
			-- 	if serveData[i] ~= 1 then
			-- 		selectFood = i
			-- 	end
			-- 	break
			-- end
			if serveData[i] ~= 1 then
				if hour >= houtime then
					return true
				elseif hour >= qiantime and hour < houtime then
					return true
				end
			end
		end
	else
		return false
	end
	return false

end


return WelfareModel
