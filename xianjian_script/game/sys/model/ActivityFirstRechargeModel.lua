--
-- Author: LXH
-- Date: 2017-09-19 17:16:43
--

local ActivityFirstRechargeModel = class("ActivityFirstRechargeModel", BaseModel)

function ActivityFirstRechargeModel:init(d)
	ActivityFirstRechargeModel.super:init(self, d)
	-- 设置firstShowRed参数的原因 是因为未充值时红点会在每次登陆后显示
	self.firstShowRed = true
	self:showRedPoint()
	self.firstChargePush = FuncDataSetting.getDataByConstantName("FirstChargePush")
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.onRechargeCallBack, self)
	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT, self.onRechargeCallBack, self)
	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT, self.onRechargeCallBack, self)
	-- EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, self.setFirstChargePushStatus, self)
end

function ActivityFirstRechargeModel:setFirstChargePushStatus(event)
	local raidId = event.params.raidId

	if tostring(self.firstChargePush) == tostring(raidId) then
		self.needShowFirstRecharge = true
	end
end

function ActivityFirstRechargeModel:resetFirstChargePushStatus()
	self.needShowFirstRecharge = nil
end

function ActivityFirstRechargeModel:getFirstChargePushStatus()
	return self.needShowFirstRecharge
end

-- 判断是否有充值
function ActivityFirstRechargeModel:isRecharged()
	if UserModel:buyProductTimes() and  table.length(UserModel:buyProductTimes()) > 0 then
		return true
	end
	return false
end
 
-- 判断是否已经领取首充奖励
function ActivityFirstRechargeModel:haveGetFirstGift()

	if UserExtModel:firstRechargeGift() == 1 then
		return true
	end
	return false
end

-- 检查是否显示红点
function ActivityFirstRechargeModel:showRedPoint()
	local redPoint = false
	local isShowButton = false
	if self:haveGetFirstGift() then
		EventControler:dispatchEvent(HomeEvent.HOME_MODEL_BUTTON_SHOW,
        	{buttonType = HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE, isShow = isShowButton})
	else
		if not self:isRecharged() then
			-- 未充值过时每次登陆后第一次进显示红点，关闭首充界面后会将firstShowRed置false不显示红点
			redPoint = self.firstShowRed  
		elseif not self:haveGetFirstGift() then
			-- 充值过且未领取红点会一直显示，已领取后不显示红点
			redPoint = true		
		end
		EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        	{redPointType = HomeModel.REDPOINT.ACTIVITY.FIRST_CHARGE, isShow = redPoint})
	end	
end

function ActivityFirstRechargeModel:setFirstShowRed(_bool)
	self.firstShowRed = _bool
end

function ActivityFirstRechargeModel:getFirstShowRed()
	return self.firstShowRed
end

function ActivityFirstRechargeModel:onRechargeCallBack()
	self:showRedPoint()
end

return ActivityFirstRechargeModel