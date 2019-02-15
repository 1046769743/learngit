FuncTravelShop = FuncTravelShop or {}

local systemHide = nil
local discountShop = nil
local discountShopClass = nil
local config_recharge = nil

FuncTravelShop.TIME_TYPE = {
	STARTSERVER_TIME = 1,  --开服时间
	CREATEPEOPLE_TIME = 2, --创建角色时间
	NATURAL_TIME = 3,      --自然时间
}


function FuncTravelShop.init()
	systemHide = Tool:configRequire("common.SystemHide")
	discountShop = Tool:configRequire("discountShop.DiscountShop");
	discountShopClass = Tool:configRequire("discountShop.DiscountShopClass");
	config_recharge = Tool:configRequire("recharge.Recharge")
end

function FuncTravelShop.getSystemHide()
	local travelShop = {}
	for k,v in pairs(systemHide) do
		if tonumber(v.type) == 3 then
			table.insert(travelShop,systemHide[k])
		end
	end

	for k,v in pairs(travelShop) do
		local startTime,endTime = FuncTravelShop.getOpenTimeAndStopTimeById(v.id,FuncCount.COUNT_TYPE.COUNT_TYPE_TRAVELSHOP_EVERYDAY_TIME)
		local now = TimeControler:getServerTime()
		if now >= startTime and now <= endTime then
			return v.subIdArray,startTime,endTime,v.id
		else
			return v.subIdArray,0,0,v.id
		end
	end
end

function FuncTravelShop.getRewardArray(key)
	local reward = discountShop[tostring(FuncTravelShop.getSystemHide()[key])].rewardArray
	return reward
end


function FuncTravelShop.getSystemHideDataById( _systemHideId )
    local _systemHideId = tostring(_systemHideId)
    return systemHide[_systemHideId]
end


--通过systemHide表中数据计算 开启时间和过期时间
function FuncTravelShop.getOpenTimeAndStopTimeById(_systemHideId, _countId)
	local bornTime = CarnivalModel:getBornTime()
    local systemHideData = FuncTravelShop.getSystemHideDataById(_systemHideId)
    if systemHideData.timeType == FuncTravelShop.TIME_TYPE.CREATEPEOPLE_TIME then
    	local startTime = bornTime + systemHideData.firstOpenTime * 24 * 60 * 60    ---时间戳转换年月日
    	local year_S = tostring(os.date("%Y",startTime))
		local month_S = tostring(os.date("%m",startTime))
		local day_S = tostring(os.date("%d",startTime))
		-- echo("年月日 =========================== ",year_S..month_S..day_S)

		local time_S = year_S..month_S..day_S
		local firstOpenTime = tonumber(time_S)

        local year = math.floor(firstOpenTime / 10000)  --  年月日转换时间戳
        local month = math.floor((firstOpenTime - year * 10000) / 100)
        local day = firstOpenTime % 100
        local hour = FuncCount.getHour(_countId)
        local min = FuncCount.getMinute(_countId)

        local timeStamp = os.time({year = year, month = month, day = day, hour = hour, min = min})
        local duration = systemHideData.durationTime * 24 * 60 * 60
        -- echo("时间戳 ==================== ",timeStamp,duration+timeStamp)
        return timeStamp, duration + timeStamp
    end
end

--开启活动的第几天
function FuncTravelShop.getOpenTime_DiJiTian()
	local subIdArray,startTime,endTime = FuncTravelShop.getSystemHide()
	if startTime == 0 then
		return 0
	end
	local age = TimeControler:getServerTime() - startTime
	-- echo("startTime = = = ============ = = = =",startTime)
	-- echo("age == = = == = = == = = = ",age)
	local maxOpenDate
	if age > 0 then
		maxOpenDate = math.floor(age/(24*3600)) + 1
	end
     
    echo("_____ 今天是开启活动的第几天 ______ ",maxOpenDate)

    return maxOpenDate
end

--每天能抽几次
function FuncTravelShop.getMaxTakeDiscount()
	local count = FuncDataSetting.getDataByConstantName("DiscountShopTimes") or 10
	return count
end

--获得现价和折扣
function FuncTravelShop.getDiscountPrice()
	local id = UserExtModel:discountId()
	echo("商品id ============== ",id)
	local discount = config_recharge[id].discount
	local nowPrice = config_recharge[id].price
	return nowPrice,discount
end

--获取当前id的recharge信息
function FuncTravelShop.getRechargeData()
	local id = UserExtModel:discountId()
	local data = config_recharge[id]
	return data
end

--获取当前id的countId
function FuncTravelShop.getRechargeForCountId()
	local id = UserExtModel:discountId()  ---- 这个id没抽折扣的时候是取不到的  有问题  暂时不用
	local countId
	if id == nil then
		countId = "1002"
	else
		countId = config_recharge[id].countId
	end

	return countId
end
