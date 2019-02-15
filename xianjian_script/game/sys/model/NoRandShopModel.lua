local NoRandShopModel = class("NoRandShopModel", BaseModel)
local NO_RAND_SHOP_TIME_EVENTS = {
	[FuncShop.SHOP_TYPES.PVP_SHOP] = TimeEvent.TIMEEVENT_PVP_SHOP_REFRESH_CD,	-- 竞技场商店
	[FuncShop.SHOP_TYPES.GUILD_SHOP] = TimeEvent.TIMEEVENT_GUILD_SHOP_REFRESH_CD,   -- 仙盟商店
	[FuncShop.SHOP_TYPES.TOWER_SHOP] = TimeEvent.TIMEEVENT_TOWER_SHOP_REFRESH_CD,   -- 锁妖塔商店
	[FuncShop.SHOP_TYPES.WONDER_SHOP] = TimeEvent.TIMEEVENT_WONDER_SHOP_REFRESH_CD,   -- 须臾商店
	[FuncShop.SHOP_TYPES.MALL_YONGANDANG] = TimeEvent.TIMEEVENT_MALL_YONGANDANG_REFRESH_CD   -- 永安当
}

--目前pvp和侠义商店都是这种
function NoRandShopModel:init(d)
	NoRandShopModel.super.init(self, d)
	self:registerEvent()
	self:startShopRefreshCd()
end

function NoRandShopModel:registerEvent()
	for shopId, event in pairs(NO_RAND_SHOP_TIME_EVENTS) do
		EventControler:addEventListener(event, self.onShopCd, self)
	end
end

function NoRandShopModel:onShopCd(event)
	local shopId
	if event.name == TimeEvent.TIMEEVENT_PVP_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.PVP_SHOP
	elseif event.name == TimeEvent.TIMEEVENT_GUILD_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.GUILD_SHOP
	elseif event.name == TimeEvent.TIMEEVENT_TOWER_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.TOWER_SHOP
	elseif event.name == TimeEvent.TIMEEVENT_WONDER_SHOP_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.WONDER_SHOP
	elseif event.name == TimeEvent.TIMEEVENT_MALL_YONGANDANG_REFRESH_CD then
		shopId = FuncShop.SHOP_TYPES.MALL_YONGANDANG
	end
	if shopId then
		self:clearBuyedGoods(shopId)
		EventControler:dispatchEvent(ShopEvent.SHOPEVENT_NORAND_SHOP_REFRESHED, {currentShopId = shopId})		
		WindowControler:globalDelayCall(c_func(self.startShopRefreshCd, self, shopId), 1)
	end
end

function NoRandShopModel:getLeftRefreshTime( shopId )
	local eventName = NO_RAND_SHOP_TIME_EVENTS[shopId]
	local leftTime = TimeControler:getCdLeftime(eventName)
	return leftTime
end

function NoRandShopModel:clearBuyedGoods(shopId)
	local data = self:getShopData(shopId)
	data.buyGoodsTimes = {}
end

function NoRandShopModel:startShopRefreshCd(targetShopId)
	local ids = FuncShop.NO_RAND_SHOP_IDS
	if targetShopId then
		ids = {targetShopId}
	end
	local now = TimeControler:getServerTime()
	for _, shopId in pairs(ids) do
		local r_time = FuncShop.getNoRandShopRefreshTime(shopId)
		local left = r_time - now
		local event = NO_RAND_SHOP_TIME_EVENTS[shopId]
		if event then
			TimeControler:startOneCd(event, left)
		end
	end
end

function NoRandShopModel:updateData(d)
	NoRandShopModel.super.updateData(self, d)
	EventControler:dispatchEvent(ShopEvent.NORANDSHOPEVENT_MODEL_UPDATE, data)
end

function NoRandShopModel:getShopData(shopId)
	-- dump(self._data,"服务器商店数据111 ======")
	local data = self._data[shopId]
	local serverTime = TimeControler:getServerTime()
	-- if(serverTime > data.lastFlushTime) then
		
	-- end
	return self._data[shopId] or {}
	
end

function NoRandShopModel:getShopLastFlushTime(shopId)
	local data = self:getShopData(shopId)
	return data.lastFlushTime or 0
end

function NoRandShopModel:getBuyGoodsTimes(shopId)
	local data = self:getShopData(shopId)
	return data.buyGoodsTimes or {}
end

function NoRandShopModel:getShopGoodsInfo(shopId)
	--如果自动刷新后有购买 lastFlushTime会置成该时间
	local lastFlushTime = self:getShopLastFlushTime(shopId)
	local buyGoodsTimes = self:getBuyGoodsTimes(shopId)

	local auto_refresh_t, isToday = FuncShop.getNoRandShopRefreshTime(shopId, true)
	local now = TimeControler:getServerTime()
	--如果当前时间大于当天约定的刷新时间，并且上一次刷新时间在约定刷新时间之前,客户端
	--清空已买列表
	-- dump(buyGoodsTimes,"=====000000=====")
	-- echo("=======auto_refresh_t====",auto_refresh_t)
	-- echoError("lastFlushTime==", lastFlushTime, "auto_refresh_t==", auto_refresh_t, "now===", now)
	local todayInfo = os.date("*t", now)
	local lastFlushDayInfo = os.date("*t", lastFlushTime)
	local reFreshTimeInfo = os.date("*t", auto_refresh_t)
	if lastFlushTime == 0 then
		if  now >= auto_refresh_t then
			buyGoodsTimes = {}
		end
	else
		if todayInfo.yday > lastFlushDayInfo.yday then
			if tostring(shopId) == tostring(FuncShop.SHOP_TYPES.PVP_SHOP) then
				local last_auto_refresh_t = auto_refresh_t - 86400
				if lastFlushTime < last_auto_refresh_t and now > last_auto_refresh_t then
					-- echoError("______不是一天___PVP_SHOP___")
					buyGoodsTimes = {}
				end
			else
				if now > auto_refresh_t then
					-- echoError("______不是一天______")
					buyGoodsTimes = {}
				end
			end			
		elseif todayInfo.yday == lastFlushDayInfo.yday then
			--同一天
			if  now >= auto_refresh_t and auto_refresh_t > lastFlushTime then
				-- echoError("______同一天______")
				buyGoodsTimes = {}
			end
		end
	end
	-- local shopBuyGoodsIds = table.keys(buyGoodsTimes)
	local shopInfo = self:getConfigShopGoods(shopId)
	-- dump(shopInfo,"看一下 数据信息====",6)
	-- dump(buyGoodsTimes, "\n\nbuyGoodsTimes====")
	local ret = {}
	for x, info in ipairs(shopInfo) do
		info.soldOut = nil
		info.leftBuyTimes = info.canBuyTime or 1
		for i,v in pairs(buyGoodsTimes) do
            if tonumber(i) == tonumber(info.id) then
                local t = info.canBuyTime or 1
			    if v >= t then
				    info.soldOut = true
				    info.leftBuyTimes = 0
				else
					info.leftBuyTimes = t - v
			    end
            end
		end
		
		ret[x] = info
	end
	return ret
end

function NoRandShopModel:getConfigShopGoods(shopId)
	if shopId == FuncShop.SHOP_TYPES.PVP_SHOP then
		return FuncShop.getPvpShopGoods()
    elseif shopId == FuncShop.SHOP_TYPES.TOWER_SHOP then 
        return FuncShop.getTowerShopGoods()
    elseif shopId == FuncShop.SHOP_TYPES.GUILD_SHOP then 
    	return FuncShop.getGuildShopGoods()
    elseif shopId == FuncShop.SHOP_TYPES.WONDER_SHOP then
    	return FuncShop.getWonderShopGoods()
   	elseif shopId == FuncShop.SHOP_TYPES.MALL_YONGANDANG then
   		return FuncMonthCard.getMallGoods()
	end
end

return NoRandShopModel
