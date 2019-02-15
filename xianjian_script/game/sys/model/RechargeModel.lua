local RechargeModel = class("RechargeModel",BaseModel)

function RechargeModel:init(d)
	RechargeModel.super.init(self,d)
	dump(d,"___RechargeModel")

	EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY, self.checkRechargeRedPoint, self)
end


function RechargeModel:updateData( data )
	RechargeModel.super.updateData(self,data)
	ShopServer:getShopInfo( nil )
	for k,v in pairs(data) do
		local rechargeData = FuncCommon.getRechargeDataById(k)
		if rechargeData.type == FuncMonthCard.RECHARGE_TYPE.PURCHASE then
			EventControler:dispatchEvent(RechargeEvent.FINISH_RECHARGE_EVENT, {reward = rechargeData.param, 
																						_type = rechargeData.type})
		end
	end
end

--商城红点特殊处理  每日首次登陆需要红点 打开商城后一天内都不显示红点
function RechargeModel:checkRechargeRedPoint()
	local isShowRed = false
	local purchaseConfig = FuncMonthCard.getRechargeDataByType(FuncMonthCard.RECHARGE_TYPE.PURCHASE)
	for i,v in ipairs(purchaseConfig) do
		local openTime, expireTime = FuncCommon.getOpenTimeAndExpireTimeById(v.systemHideId, v.countId)
		local currentTime = TimeControler:getServerTime()
		local leftTimes = v.purchaseTimes - CountModel:getPurchaseGiftBagNumById(v.id)
		if currentTime >= openTime and currentTime < expireTime then
			if leftTimes > 0 then
				isShowRed = true
				break
			end
		end
	end
	self:setRechargeRedPoint(isShowRed)
end

function RechargeModel:setRechargeRedPoint(_bool)
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
			{redPointType = HomeModel.REDPOINT.ACTIVITY.MALL, isShow = _bool})
end

function RechargeModel:isFirstBuy(buyId)
	local info = self._data;
	if info[buyId] == nil or info[buyId] == 0 then
		return true
	end
	return false
end

function RechargeModel:getMonthCardBuyTime( monthId )
	for k,v in pairs(self._data) do
		local data = FuncCommon.getRechargeDataById(k)
		if tostring(data.param) == tostring(monthId)  then
			return v
		end

	end
	return  0

end

function RechargeModel:getRechargeDataById(_id)
	return self._data[tostring(_id)]
end

--处理充值 数据 因为直购礼包 有一个显示的时间 将排序功能移到这里 购买过的且不在续费期的月卡 需要沉底
function RechargeModel:handleRechargeData(_data)
	local chargeData = {}

	for i,v in ipairs(_data) do
		if v._type == FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE then
			local openTime, expireTime = FuncCommon.getOpenTimeAndExpireTimeById(v._data.systemHideId, v._data.countId)

			local curTime = TimeControler:getServerTime()
			if curTime >= openTime and curTime < expireTime then
				v.expireTime = expireTime
				v.order = 1
				table.insert(chargeData, v) 
			end
		else
			v.order = 1
			if v._type == FuncMonthCard.RECHARGE_DATA_TYPE.MONTHCARD then
				local monthCard = MonthCardModel:getDataById(v._data.param)
				local data = FuncMonthCard.getMonthCardById(v._data.param)
				local tqt = data.renewalTime
				--购买过的月卡 且不在续费状态时 order设置为0  以便排序
				if monthCard and monthCard:getLeftTime() > 0 and monthCard:getLeftTimeDay() > tqt then
					v.order = 0
				end
			end
			
			table.insert(chargeData, v)
		end
	end

	table.sort(chargeData, function (a, b)
			if a.order > b.order then
				return true
			elseif a.order < b.order then
				return false
			end

			if a._data.locate < b._data.locate then
				return true
			end
			
			return false
		end)

	return chargeData
end

return RechargeModel;
