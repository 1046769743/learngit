--[[
	Author: 张燕广
	Date:2018-04-06
	Description: 日志服务工具类
]]

PCLogHelper = {}

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

local javaPCCommHelperClsName = PCSdkHelper.javaPCCommHelperClsName
local ocPCCommHelperClsName = PCSdkHelper.ocPCCommHelperClsName

PCLogHelper.defaultAndroidSign = PCSdkHelper.defaultAndroidSign

PCLogHelper.UPDATE_TYPE = {
	COST = "0",		--消耗
	ADD = "1",		--新增
}

-- 自定义事件 role-task之detail 枚举值
PCLogHelper.TASK_DETAIL = {
	ACCEPT = "accept",		--接任务
	SUCCESS = "complete",	--任务完成
	FAIL = "fail",			--任务失败
	CANCEL = "cancel"		--放弃任务
}

-- 自定义事件 role-stage之detail 枚举值
PCLogHelper.STAGE_DETAIL = {
	BEGIN = "begin",		--接任务
	END = "end",			--任务完成
	FAIL = "fail",			--任务失败
	CANCEL = "cancel"		--放弃任务
}

-- 自定义事件 role-act之detail 枚举值
PCLogHelper.ACT_DETAIL = {
	BEGIN = "begin",		--接任务
}

--[[
	自定义事件-游戏自定义事件 (TODO 使用前需要运营配置)
	
	actId:(必须)副本场景标识，英文或数字
	actName:(必须)副本场景名称，最好传中文
	detail:(必须)枚举类型，见PCLogHelper.ACT_DETAIL
]]
function PCLogHelper:sendActLog(actId,actName,detail)
	local infoMap = self:getBaseInfo()
	infoMap.actId = actId
	infoMap.actName = actName
	infoMap.detail = detail

	local logContentDict = {
		log_id = "1002",
		log_key = "role-stage",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	自定义事件-副本场景日志	(TODO 使用前需要运营配置)
	
	stageId:(必须)副本场景标识，英文或数字
	stageName:(必须)副本场景名称，最好传中文
	detail:(必须)枚举类型，见PCLogHelper.STAGE_DETAIL
]]
function PCLogHelper:sendStageLog(stageId,stageName,detail)
	local infoMap = self:getBaseInfo()
	infoMap.stageId = stageId
	infoMap.stageName = stageName
	infoMap.detail = detail

	local logContentDict = {
		log_id = "1002",
		log_key = "role-stage",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	自定义事件-任务日志	(TODO 使用前需要运营配置)
	
	taskId:(必须)任务Id
	taskName:(必须)任务名称，最好传中文
	detail:(必须)枚举类型，见PCLogHelper.TASK_DETAIL
]]
function PCLogHelper:sendTaskLog(taskId,taskName,detail)
	local infoMap = self:getBaseInfo()
	infoMap.taskId = taskId
	infoMap.taskName = taskName
	infoMap.detail = detail

	local logContentDict = {
		log_id = "1001",
		log_key = "role-task",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	玩家属性变更日志	
	
	propKey:(必须)属性标识
			1.等级标识为level
			2.VIP等级标识为viplevel
			3.其他属性标识自行设定
	propValue:(必须)新属性值
	updateValue:(必须)变化的属性值
	des:(必须)描述变更的原因或途径
]]
function PCLogHelper:sendPropUpdateLog(propKey,propValue,updateValue,des)
	local infoMap = self:getBaseInfo()
	infoMap.propKey = propKey
	infoMap.propValue = propValue
	infoMap.rangeability = updateValue
	infoMap.custom = des or ""

	local logContentDict = {
		log_id = "10",
		log_key = "role-prop-update",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	玩家虚拟物品变更日志	
	
	itemId:(必须)物品ID
	itemName:(必须)物品名称
	updateType:(必须)1新增 0消耗
	updateCount:(必须)变化数量
	remains:(必须)当前总量
	des:(必须)描述变更的原因或途径
	isPrecious:(可选)是否为珍贵物品 1：是 0：否
]]
function PCLogHelper:sendItemUpdateLog(itemId,itemName,updateType,updateCount,remains,des,isPrecious)
	local infoMap = self:getBaseInfo()
	infoMap.itemId = itemId
	infoMap.itemName = itemName
	infoMap.updateType = updateType
	infoMap.itemCount = updateCount
	infoMap.remains = remains
	infoMap.isPrecious = isPrecious or 0
	infoMap.custom = des or ""

	local logContentDict = {
		log_id = "9",
		log_key = "role-item-update",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	玩家虚拟货币变更日志

	cid:(必须)货币ID
	cname:(必须)货币名称
	updateType:(必须)1新增 0消耗
	updateCount:(必须)变化数量
	remains:(必须)当前总量
	des:(必须)描述变更的原因或途径
	isPrecious:(可选)是否为珍贵物品 1：是 0：否
]]
function PCLogHelper:sendCurrencyUpdateLog(cid,cname,updateType,updateCount,remains,des,isPrecious)
	local infoMap = self:getBaseInfo()
	infoMap.itemId = cid
	infoMap.itemName = cname
	infoMap.updateType = updateType
	infoMap.itemCount = updateCount
	infoMap.remains = remains
	infoMap.isPrecious = isPrecious or 0
	infoMap.custom = des or ""

	local logContentDict = {
		log_id = "91",
		log_key = "role-income-update",
		log_json = json.encode(infoMap)
	}

	self:sendLog(logContentDict)
end

--[[
	充值日志
]]
function PCLogHelper:sendChargeLog(logMap)
	if logMap and type(logMap) == "table" then
		local logContentDict = {
			log_id = "8",
			log_key = "role-credit",
			log_json = json.encode(logMap)
		}

		self:sendLog(logContentDict)
	end
end

--[[
	获取基本信息
]]
function PCLogHelper:getBaseInfo()
	local infoMap = {}
	infoMap.roleLevel = UserModel:level()
	infoMap.roleVipLevel = UserModel:vip()
	-- infoMap.time = os.date("%Y-%m-%d-%H:%M:%S",TimeControler:getServerTime())

	return infoMap
end

--[[
/**
 *  log_id: 日志ID
 *  log_key: 日志Key
 *  log_json: 日志内容，json格式
 *
 {
	 "log_id": "8"
	 "log_key": "role-credit"
	 "log_json": "json格式"
 }
 *  log_id 和 log_key对应表
 *  log_id    log_key                 描述
 *   8       role-credit         玩家充值日志
 *   9       role-item-update    玩家虚拟物品变更
 *   10      role-prop-update    玩家属性变更
 *   1001    role-task           任务
 *   1002    role-stage          副本，场景
 *   1003    role-act            自定义事件
 *   2001    role-interact       自定义交互事件
 */
 ]]
function PCLogHelper:sendLog(logContentDict)
	local functionName = "sendLog"

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {logContentDict}, PCLogHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,logContentDict)
	end
end

-- 获取ServiceCode,服务器日志上报需要该值
function PCLogHelper:getServiceCode()
	-- 如果跳过了sdk
	if DEBUG_SKIP_LOGIN_SDK then
		return "no_service_code"
	end

	if PCLogHelper.serviceCode then
		return PCLogHelper.serviceCode
	end

	local serviceCode = ""
	local functionName = "getServiceCode"
	local params = {}
	
	if device.platform == PLANTFORM_ANDROID then
		result,serviceCode = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCLogHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,serviceCode = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	if serviceCode ~= nil and serviceCode ~= "" then
		PCLogHelper.serviceCode = serviceCode
	end

	return serviceCode
end

--[[
	日志测试
]]
function PCLogHelper:testLog()
	self:testCurrencyLog()
end

--[[
	虚拟货币日志测试
]]
function PCLogHelper:testCurrencyLog()
	local cid = "c1"
	local cname = "测试货币"
	local updateType = PCLogHelper.UPDATE_TYPE.ADD
	local updateCount = 10
	local remains = 20
	local des = "充值活动1"

	self:sendCurrencyUpdateLog(cid,cname,updateType,updateCount,remains,des,isPrecious)
end

return PCLogHelper
