--[[
	Author: 张燕广
	Date:2018-05-14
	Description: 支付工具类
]]

PCChargeHelper = {}

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

local javaPCCommHelperClsName = PCSdkHelper.javaPCCommHelperClsName
local ocPCCommHelperClsName = PCSdkHelper.ocPCCommHelperClsName
PCChargeHelper.defaultAndroidSign = PCSdkHelper.defaultAndroidSign

-- 订单轮询时间间隔，单位秒
local BILL_POLL_CFG = {1,5,10,30,60}

-- 月卡等礼包类商品购买时必须传数量“1”
local GIFT_BAG_PROP_COUNT = 1

-- 支付成功消息
PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS = "PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS"

function PCChargeHelper:reInit()
	self:resetData()

	if not self.hasInited then
		-- 支付server端回调
		EventControler:addEventListener("notify_sdk_charge_2210", self.onServerChargeCallback, self)
		EventControler:addEventListener(SystemEvent.SYSTEMEVENT_APP_ENTER_BACKGROUND, self.onEnterBackground,self)

		self.hasInited = true

		-- echo("charge 注册支付回调事件")
		-- TODO测试用例
		-- EventControler:addEventListener(PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS, self.onTestChargeSuccess, self)
	end
end

function PCChargeHelper:getGiftBagPropCount()
	return GIFT_BAG_PROP_COUNT
end

--[[
	重置数据
]]
function PCChargeHelper:resetData()
	-- 服务器返回的订单ID
	self.serverOrderId = nil
	self.serverOrderInfo = nil

	-- 服务器返回的商品ID
	self.serverProductId = nil

	-- 订单ID
	self.ssid = nil
	-- 商品ID
	self.pbid = nil

	-- 当前重置参数数据
	self.chargeParamsInfo = nil
end

--[[
	支付，server端回调
]]
function PCChargeHelper:onServerChargeCallback(event)
	echo("charge onServerChargeCallback event=",event)

	if event and event.params then
		dump(event.params,"charge event.params=")
		local data = event.params.params.data
		local orderInfo = data.orderInfo
		self:updateOrderInfo(orderInfo)
	end
end

--[[
	更新订单数据
]]
function PCChargeHelper:updateOrderInfo(orderInfo)
	if not orderInfo then
		return
	end

	self.serverOrderId = orderInfo.orderId
	self.serverProductId = orderInfo.productId
	self.serverOrderInfo = table.deepCopy(orderInfo)
end

--[[
	当支付成功,client sdk回调支付成功
]]
function PCChargeHelper:onChargeSuccess(data)
	self.isInCharge = false

	echo("charge onChargeSuccess sdk支付成功")
	dump(data)

	-- 订单ID
	self.ssid = data.ssid
	-- 商品ID
	self.pbid = data.pbid

	-- 确认支付成功(sdk返回的订单数据与server返回的一致)
	if self:checkBill() then
	-- if false then
		echo("charge 第一次确定订单成功")
		self:onConfirmChargeSuccess()
	else
		echo("charge 未收到server消息，发起轮询")
		-- 开启轮询
		self:startQueryBill(self.ssid)
	end
end

--[[
	确认订单是否真正成功
	条件:收到server返回的订单数据，且与sdk返回的数据一致
]]
function PCChargeHelper:checkBill()
	if self.ssid == nil or self.pbid == nil then
		return false
	end

	if self.ssid == self.serverOrderId and self.pbid == self.serverProductId then
		echo("charge-self.serverOrderId=",self.serverOrderId)
		echo("charge-self.serverProductId=",self.serverProductId)
		return true
	end

	return false
end

--[[
	确认支付成功，且获得服务器下发的结果
	1.client sdk回调支付成功
	2.game server确认支付成功，收到发货(game server下发的商品清单)回调
]]
function PCChargeHelper:onConfirmChargeSuccess()
	echo("charge onConfirmChargeSuccess 支付成功发送消息给业务逻辑层")
	-- dump(self.serverOrderInfo,"charge self.serverOrderInfo=")

	-- 发送充值日志，客户端不需要发送充值日志 2017-05-17 by ZhangYanguang
	-- PCLogHelper:sendChargeLog(self.chargeParamsInfo)
	-- 发送充值成功消息给业务逻辑层
	EventControler:dispatchEvent(PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS
		,{orderInfo=self.serverOrderInfo})
end

--[[
	开启轮询订单
]]
function PCChargeHelper:startQueryBill(billId)
	echo("charge startQueryBill开启轮询orderId=",billId)
	self.queryBillId = billId
	self.pollCount = 1

	if self:checkQueryBill() then
		local delaySec = self:getPollDelaySec()
		if delaySec then
			WindowControler:globalDelayCall(c_func(self.queryBill,self), delaySec)
		end
	end
end

--[[
	获取下次订单轮询延迟时间
]]
function PCChargeHelper:getPollDelaySec()
	if not self.pollCount then
		self.pollCount = 1
	end

	local delaySec = BILL_POLL_CFG[self.pollCount]
	return delaySec
end

--[[
	检查是否需要继续查询订单
]]
function PCChargeHelper:checkQueryBill()
	-- 如果在轮询期间发生新的支付，self.queryBillId与self.ssid可能就不相等了，需要停止旧订单的轮询
	if self.queryBillId and self.queryBillId == self.ssid then
		if self.pollCount and self.pollCount <= #BILL_POLL_CFG then
			return true
		end

		-- 如果轮询超过了最大次数，发送错误日志到平台
		if self.pollCount and self.pollCount > #BILL_POLL_CFG then
			local msg = "ChargeError:PCChargeHelper:checkQueryBill轮询已超过最大次数" .. self.pollCount .. "/" .. #BILL_POLL_CFG
			ClientActionControler:sendLuaLogToPlatform(msg,"PCChargeHelper.checkQueryBill")
		end
	end

	return false
end

--[[
	查询订单 TODO 轮询订单是否需要加version等参数？
]]
function PCChargeHelper:queryBill()
	if not self.queryBillId then
		return
	end

	local params = {
		orderId = self.queryBillId
	}

	local callBack = c_func(self.onQueryBillBack,self)
	Server:sendRequest(params,MethodCode.sdk_charge_query_bill, callBack ,false,false,true)
end

--[[
	轮询订单回调
]]
function PCChargeHelper:onQueryBillBack(event)
	echo("charge onQueryBillBack self.pollCount=",self.pollCount)
	-- if event then
	-- 	dump(event.result,"event.result=")
	-- end

	self.pollCount = self.pollCount + 1
	if event.result ~= nil then 
		-- 更新购买的商品信息数据
		local data = event.result.data
		if data then
			-- 更新本地数据
			--[[
			local dirtyList = data.dirtyList
			if dirtyList then
				echo("更新数据dirtyList=")
				dump(dirtyList)
				Server:updateBaseData(dirtyList)
			end
			]]
			local orderInfo = data.orderInfo
			self:updateOrderInfo(orderInfo)
		end

		if self:checkBill() then
			echo("charge 轮询后确认订单成功")
			self:onConfirmChargeSuccess()
		else
			--[[
				如果轮询获取的结果不一致
				如果轮询回调后，恰好开启新订单且新订单还未收到回调
				，那么self.ssid和self.pbid同时为nil，该情况不发送错误日志
					
			]]
			if self.ssid ~= nil and self.pbid ~= nil and self.serverOrderId ~= nil and self.serverProductId ~= nil then
				local logData = {
					msg = "订单查询不一致",
					ssid = self.ssid or "",
					pbid = self.pbid or "",

					serverOrderId = self.serverOrderId or "",
					serverProductId = self.serverProductId or ""
				}

				local msg = json.encode(logData)
				ClientActionControler:sendLuaLogToPlatform(msg,"PCChargeHelper.onQueryBillBack")
			end
		end
	else
		-- 失败
		if self:checkQueryBill() then
			local delaySec = self:getPollDelaySec()
			if delaySec then
				WindowControler:globalDelayCall(c_func(self.queryBill,self), delaySec)
			end
		end
	end
end

--[[
	当支付失败
]]
function PCChargeHelper:onChargeFail(data)
	self.isInCharge = false

	-- echoError("支付失败onChargeFail")
	WindowControler:showTips("支付失败")
	echo("charge 支付失败")
end

--[[
	需要根据globalSeverUrl动态拼接
]]
function PCChargeHelper:getGameUrl()
	if not self.gameUrl then
		local prefix = ""
		local url = AppInformation:getGlobalServerURL()
		local urlArr = string.split(url,"?")

		url = urlArr[1]
		if not string.find(url,"http") then
			url = string.format("https://%s",url)
		end
		self.gameUrl = string.format("%s%s",url,"?mod=ourpalm&act=Sdk.orderCallBack")
	end

	return self.gameUrl
end

--[[
	Android平台微信、支付宝等支付方式，如果是调起第三方App，导致游戏切入后台的情景都会执行该逻辑

	支付前先断开WebSocket，支付成功切回前台后通过checkBill的方式判断是否支付成功
	临时解决方案:vivo等手机微信支付成功时，游戏在后台收到服务器的推送会导致游戏卡死
]]
function PCChargeHelper:onEnterBackground()
	-- 如果正在支付中
	if self.isInCharge then
		if device.platform == PLANTFORM_ANDROID then
			Server:handleClose()
		end
	end
end

--[[
 * 支付接口 参数列表如下：
 * propId:		商品id(必填)
 * propName:	商品名称，不含数字(必填),100钻石，必须填写”钻石“，propCount填写100
 * propCount:	商品数量
 * propDes:		商品描述(可选)
 * rolelv:		游戏角色等级(可选)
 * roleviplv:	游戏角色VIP等级(可选)
 * Gameurl:		发货地址(可选)，如果不填用平台配置的地址
 * ExtendParams:扩展参数(可选)
 * chargeCash:  商品价格，以分为单位(必填)
 * currencyType: 货币类型，人民币为1(必填) 
 				(1人民币 2美元 3日元 4港币 5英镑 6新加坡币 7越南盾 8台币 9韩元 10泰铢)

 备注：
 如游戏中所卖商品在游戏界面显示为“100元宝”，当调用支付接口时，商品名称请传“元宝”，商品数量请传“100”
 如游戏中所卖商品在游戏界面显示为“月卡“，当调用支付接口时，商品名称请传“月卡”，商品数量请传“1”
 如游戏中所卖“月卡”有多个，当调用支付接口时，商品名称建议传入月卡的金额。例如“30元月卡”、“50元月卡”等等，商品数量请传“1”
]]
function PCChargeHelper:charge(propId,propName,propCount,chargeCash)
	if AppInformation:checkXianFengTiYan() then
		WindowControler:showTips("先锋体验服，暂未开启充值功能")
		return
	end

	-- 月卡等礼包类商品数量必须传 GIFT_BAG_PROP_COUNT
	if not propCount or propCount == "" then
		propCount = self:getGiftBagPropCount()
	end
	
	if device.platform ~= PLANTFORM_ANDROID  and  device.platform ~= PLANTFORM_IOS then
		echo("\n\n——------------充值相关数据如下——------------")
		echo("商品Id  propId=",propId)
		echo("商品名称 propName=",propName)
		echo("商品数量 propCount=",propCount)
		echo("金额(分) chargeCash=",chargeCash)

		WindowControler:showTips("pc平台不支持支付功能,直接算购买成功")
		Server:sendRequest({propId =propId}, 100283)
		EventControler:dispatchEvent(PCChargeHelper.CHARGEEVENT_CHARGE_SUCCESS)
		return
	end

	self:reInit()

	-- local rid = UserModel:rid()
	-- echo("rid=",rid)
	-- if true then
	-- 	return
	-- end

	local functionName = "charge"

	local chargeParams = {}
	chargeParams.propId = tostring(propId)
	chargeParams.propName = tostring(propName)
	chargeParams.propCount = tostring(propCount)
	chargeParams.chargeCash = tostring(chargeCash)
	-- gameUrl
	chargeParams.Gameurl = tostring(self:getGameUrl())
	-- 人民币
	chargeParams.currencyType = tostring(1)
	-- 游戏角色等级
	chargeParams.rolelv = tostring(UserModel:level())
	-- 游戏角色VIP等级
	chargeParams.roleviplv = tostring(UserModel:vip())
	-- 扩展参数(必须传该参数，可以为空字符)
	chargeParams.ExtendParams = ""
	-- 商品描述(必须传该参数，可以为空字符)
	chargeParams.propDes = ""

	-- echo("charge lua开启支付")
	-- dump(chargeParams,"charge chargeParams")

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {chargeParams}, PCChargeHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then 
		-- echo("IOS 支付")
		-- dump(chargeParams)
		if self.isInCharge then
			echo("支付中....")
			return
		end

		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,chargeParams)
	end

	-- 保存充值数据，发送日志用
	self.chargeParamsInfo = table.copy(chargeParams)
	-- 正在支付中
	self.isInCharge = true
end

--[[
	@TEST
	支付测试用例
]]
function PCChargeHelper:testCharge(caseId)
	caseId = caseId or 2
	if caseId == 1 then
		local propId = "1"
		local propName = "测试1"
		local chargeCrash = 10
		local propCount = 1

		self:charge(propId,propName,propCount,chargeCrash)
	elseif caseId == 2 then
		local propId = "2"
		local propName = "测试2"
		local chargeCrash = 1
		local propCount = 1

		self:charge(propId,propName,propCount,chargeCrash)
	end
end

--[[
	@TEST
	支付订单查询测试用例
]]
function PCChargeHelper:testQuryBill()
	self.queryBillId = "0062018051610590773800"
	self.pollCount = 1
	self:queryBill()
end

--[[
	@TEST
	支付成功逻辑处理测试用例
]]
function PCChargeHelper:onTestChargeSuccess(event)
	echo("charge onTestChargeSuccess")
	if event and event.params then
		dump(event.params,"charge event.params=")
		local orderInfo = event.params.orderInfo
		local jsonStr = json.encode(orderInfo)
		echo("支付成功结果=",jsonStr)
		WindowControler:showTips("支付成功了！")
		EventControler:dispatchEvent(MonthCardEvent.MONTH_CARD_RECHARGE_SUCCESS_EVENT,orderInfo)
	end
end

return PCChargeHelper
