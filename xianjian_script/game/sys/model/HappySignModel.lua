--
-- Author: zq
-- Date: 2016-8-15 18:06:21
--

local HappySignModel  = class("HappySignModel ", BaseModel )

function HappySignModel:init( d )
    self._signedId = {}
    if d.receiveDays then
        self._signedId = number.splitByNum(d.receiveDays,2) --已签到的天数
    end
    
    self.initTime = TimeControler:getServerTime()
    self._signedTime = d.lastRecTime or 0
    self._onlinedDays = d.onlineDays

	self:checkShowRed()

    self:disptchTimeOutEvent()
    
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAPPYSIGN_END_EVENT, self.disptchHiddenEvent, self)
end

function HappySignModel:updateData(d)
    HappySignModel.super.updateData(self, d)
    if d.receiveDays then
        self._signedId = number.splitByNum(d.receiveDays,2) --已签到的天数
    end

    if d.onlineDays then
        -- if self._onlinedDays < d.onlineDays then
            self._onlinedDays = d.onlineDays
            -- echoError("\n\n+++++updateData+++++++", self._onlinedDays, "self:isHappySignFinish()==", self:isHappySignFinish())
            if self:isHappySignFinish() then
               HomeModel._showButton[FuncHome.RIGHTBUTTON_NAME[5]] = false
            end 
            EventControler:dispatchEvent(HappySignEvent.ONLINED_DAYS_CHANGED_EVENT)
            EventControler:dispatchEvent(UserEvent.BUTTON_REFRESH_EVENT)  
        -- end                     
    end

    if d.lastRecTime then
        self._signedTime = d.lastRecTime
    end
	self:checkShowRed()
    
--   EventControler:dispatchEvent(HappySignEvent.RED_POINT_EVENT,{show = self:checkShowRed()})
end

--排序
function HappySignModel:getSortItems()
    local allData = {}
    local periodId = self:getPeriodStatus()
    allData = FuncHappySign.getPeriodData(periodId)
    -- local _allDataSigned = {} --已经签到的
    local _allData = {} -- 还没签到
    for i,v in pairs(allData) do
        if self:isHappySign(v.hid) then
            v.isSign = true
            table.insert(_allData,v)
        else
            v.isSign = false
            table.insert(_allData,v)
        end
    end
    
	function comps(a,b)
        return tonumber(a.hid) < tonumber(b.hid)
    end
    table.sort(_allData,comps);
    -- table.sort(_allDataSigned,comps);
    -- dump(_allDataSigned, "\n\n_allDataSigned===")
    -- for i,v in pairs(_allDataSigned) do
    --     table.insert(_allData,v)
    -- end
    
    return _allData;
end

function HappySignModel:getPeriodStatus()
    if self:isFirstPeriodFinish() and self._onlinedDays > FuncHappySign.getPeriodDays(FuncHappySign.periodId.FIRST) then
        self.period = FuncHappySign.periodId.SECOND
    else
        self.period = FuncHappySign.periodId.FIRST
    end

    return self.period
end

--判断是否显示小红点
function HappySignModel:checkShowRed(  )
	local redPoint = false
    local isShowButton = false
    local sysName = FuncCommon.SYSTEM_NAME.HAPPYSIGN
    local isopen =  FuncCommon.isSystemOpen(sysName)
    if not isopen then
        return
    end

    --发送都签完了消息
    if self:isHappySignFinish() == true and self:isRefreshedSign() then 
        EventControler:dispatchEvent(HomeEvent.HOME_MODEL_BUTTON_SHOW,
            {buttonType = HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN, isShow = isShowButton});
    else
        if self._onlinedDays then
            if self:isHappySignFinish() == true then
                redPoint = false
            else
                for i = 1, self._onlinedDays do
                    if self._signedId[i] == nil or self._signedId[i] == 0 then
                        redPoint = true
                        break
                    end
                end
            end
            
        end
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN, isShow = redPoint});
    end
    -- WindowControler:globalDelayCall(function (),time)
end

function HappySignModel:isRefreshedSign()
    local todayTargetStamp = self:getRefreshTime()
    local curTime = TimeControler:getServerTime()
    if tonumber(curTime) >= tonumber(todayTargetStamp) and tonumber(self._signedTime) < tonumber(todayTargetStamp) then 
        -- 刷新
        return true
    else 
        -- 没到时间
        return false
    end
end

function HappySignModel:disptchTimeOutEvent()
    local todayTargetStamp = self:getRefreshTime()
    local isShowButton = false
    -- echo("\n\ntodayTargetStamp", todayTargetStamp)
    if tonumber(self._signedTime) < tonumber(todayTargetStamp) and self:isHappySignFinish() == true then
        local expireTimes = todayTargetStamp - self.initTime
        -- echo("\n\nexpireTimes", expireTimes)
        if tonumber(expireTimes) > 0 then
            TimeControler:startOneCd(TimeEvent.TIMEEVENT_HAPPYSIGN_END_EVENT, expireTimes)
        end
        
    end
end

function HappySignModel:disptchHiddenEvent()
    local isShowButton = false
    EventControler:dispatchEvent(HomeEvent.HOME_MODEL_BUTTON_SHOW,
                        {buttonType = HomeModel.REDPOINT.ACTIVITY.HAPPY_SIGN, isShow = isShowButton})
end

-- 判断第一期奖励是否全部领取
function HappySignModel:isFirstPeriodFinish()
    for i = 1, FuncHappySign.getPeriodDays(FuncHappySign.periodId.FIRST) do
        if self._signedId[i] == 0 or self._signedId[i] == nil then
            return false
        end
    end

    return true
end

--判断是否全部领取
function HappySignModel:isHappySignFinish( )
    for i = 1, FuncHappySign.getHappySignDays() do
        if self._signedId[i] == 0 or self._signedId[i] == nil then
            return false
        end
    end

    return true
    
end
-- 判断 是否已签过
function HappySignModel:isHappySign( itemId )
    local a = self._signedId[tonumber(itemId)]
    if a == nil then
       a = 0
    end
	return a > 0
end

function HappySignModel:getSignId()
    return self._signedId
end

function HappySignModel:getOnlineDays()
    return self._onlinedDays
end
-- 再登陆几天 可领取
function HappySignModel:willSignDayNums(itemId)
     return tonumber(itemId) - tonumber(self._onlinedDays)
end

--
function HappySignModel:isCanSignForHome()
     
end

--判断 是否可以签到
function HappySignModel:canHappySign( itemId )
	return _yuan3(tonumber(self._onlinedDays) >= tonumber(itemId),true,false)
end

function HappySignModel:setHappySignId( itemId )
	self._signedId[tonumber(itemId)] = 1
end

function HappySignModel:getRefreshTime()
     -- 处理四点刷新的事
    local curTime = TimeControler:getServerTime()
    local dates = os.date("*t", curTime)
    -- 每天几点几分刷新
    local targetH = FuncCount.getHour(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO)
    local targetM = FuncCount.getMinute(FuncCount.COUNT_TYPE.COUNT_TYPE_SIGN_RECEIVE_RETIO) or 0
    targetH = tonumber(targetH)
    targetM = tonumber(targetM)

    local oneDay = 24 * 60 * 60
    -- 当天对应时间的时间戳
    local todayTargetStamp = os.time({year=dates.year, month=dates.month, day=dates.day, hour=targetH, min = targetM})
    return todayTargetStamp
end

return HappySignModel
