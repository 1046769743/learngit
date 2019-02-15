--
-- Author: ZhangYanguang
-- Date: 2018-03-15
-- iOS设备工具类

IOSDeviceHelper = {}
-- 配置网址：https://www.theiphonewiki.com/wiki/Models
local iOSDeviceMap = {
	['iPhone4'] = 	{"iPhone3,1","iPhone3,2","iPhone3,3"},
	['iPhone4S'] = 	{"iPhone4,1"},
	['iPhone5'] = 	{"iPhone5,1","iPhone5,2"},
	['iPhone5C'] = 	{"iPhone5,3","iPhone5,4"},
	['iPhone5S'] = 	{"iPhone6,1","iPhone6,2"},
	['iPhone6'] = 	{"iPhone7,2"},
	['iPhone6Plus'] = 	{"iPhone7,1"},
	['iPhone6S'] = 	{"iPhone8,1"},
	['iPhone6SPlus'] = 	{"iPhone8,2"},
	['iPhoneSE'] = 	{"iPhone8,4"},
	['iPhone7'] = 	{"iPhone9,1","iPhone9,3"},
	['iPhone7Plus'] = {"iPhone9,2","iPhone9,4"},
	['iPhone8'] = 	{"iPhone10,1","iPhone10,4"},
	['iPhone8Plus'] = 	{"iPhone10,2","iPhone10,5"},
	['iPhoneX'] = 	{"iPhone10,3","iPhone10,6"},
	['iPhoneXS'] = 	{"iPhone11,2"},
	['iPhoneXSMax'] = 	{"iPhone11,4","iPhone11,6"},
	['iPhoneXR'] = 	{"iPhone11,8"},

	['iPad'] = 		{"iPad1,1"},
	['iPad2'] = 	{"iPad2,1","iPad2,2","iPad2,3","iPad2,4"},
	['iPadMini'] = 	{"iPad2,5","iPad2,6","iPad2,7"},
	['iPad3'] = 	{"iPad3,1","iPad3,2","iPad3,3"},
	['iPad4'] = 	{"iPad3,4","iPad3,5","iPad3,6"},
	['iPadAir'] = 	{"iPad4,1","iPad4,2","iPad4,3"},
	['iPadMini2'] = {"iPad4,4","iPad4,5","iPad4,6"},
	['iPadMini3'] = {"iPad4,7","iPad4,8","iPad4,9"},
	['iPadMini4'] = {"iPad5,1","iPad5,2"},
	['iPadAir2'] = 	{"iPad5,3","iPad5,4"},
	['iPadPro9.7'] = {"iPad6,3","iPad6,4"},
	['iPadPro12.9'] = {"iPad6,7","iPad6,8"},
	['iPad5'] = 		{"iPad6,11","iPad6,12"},
	['iPadPro12.9-2'] = {"iPad7,1","iPad7,2"},
	['iPadPro10.5'] = 	{"iPad7,3","iPad7,4"},
	['iPad6'] = {"iPad7,5","iPad7,6"},
}

function IOSDeviceHelper:getDeviceType(model)
	if self.deviceName then
		return self.deviceName
	else
		for k,arr in pairs(iOSDeviceMap) do
			for i=1,#arr do
				if model == arr[i] then
					self.deviceName = k
					return self.deviceName
				end
			end
		end

		self.deviceName = "other"
	end

	return self.deviceName
end

-- 判断是否是iPhoneX，目的是判断是否刘海屏
-- 公测用native接口替换掉该接口
function IOSDeviceHelper:isIphoneX(model)
	if self._isIphoneX then
		return self._isIphoneX
	end

	if not model or model == "" then
		return false
	end

	for k,arr in pairs(iOSDeviceMap) do
		if table.indexof(arr, model) then
			if k == "iPhoneX" or k == "iPhoneXS" 
				or k == "iPhoneXSMax" or k == "iPhoneXR" then
				self._isIphoneX = true
				return self._isIphoneX
			end
		end
	end

	return false
end

return IOSDeviceHelper


