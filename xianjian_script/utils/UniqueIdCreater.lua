--[[
	产生 uinqueIdCreater 
	登陆后才能用
	设备后4位+精确到毫秒的时间戳+MethodCode
	eg: 
	42ad_1490413583321_315
]]
UniqueIdCreater = UniqueIdCreater or {}

--网络用的
function UniqueIdCreater:createUniqueId(methodCode,requestId)
	methodCode = methodCode or "";
	requestId = requestId or "0"
	local deviceId = AppInformation:getDeviceID();
	local deviceLen = string.len(deviceId);

	local deviceSuffix = string.sub(deviceId,  deviceLen - 3, deviceLen);
	local time = TimeControler:getServerMiliTime();
	local uniqueId = string.format("%s_%s_%s_%s", 
			deviceSuffix, tostring(time), tostring(methodCode),tostring(requestId));
	return uniqueId;
end





















