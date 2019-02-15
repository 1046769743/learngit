--[[
	Author: 张燕广
	Date:2018-03-26
	Description: LBS服务类
]]

PCLBSHelper = {}

local MAP_LOCATION_API = "http://api.map.baidu.com/geocoder"

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

local javaPCCommHelperClsName = PCSdkHelper.javaPCCommHelperClsName
local ocPCCommHelperClsName = PCSdkHelper.ocPCCommHelperClsName

-- 位置信息变更消息
PCLBSHelper.LBSEVENT_LOCATION_UPDATE = "PCLBSHelper.LBSEVENT_LOCATION_UPDATE"

-- 是否是第一次获取到位置
PCLBSHelper.isFirstGetLocaiton = true

PCLBSHelper.defaultAndroidSign = PCSdkHelper.defaultAndroidSign

-- 对外接口，初始化LBS SDK
function PCLBSHelper:init()
	self:startLocationServiceWithTime()
end

-- 对外接口，请求位置信息,通过PCLBSHelper.LBSEVENT_LOCATION_UPDATE消息发送位置信息
function PCLBSHelper:startLocationService()
	if self.curProvince then
		self:sendLocationInfo()
	else
		self:startLocationServiceWithTime()
	end
end

-- 开启定位服务
-- timeInterval:外部调用时不要传递这个参数
function PCLBSHelper:startLocationServiceWithTime(timeInterval)
	-- 间隔时间(秒)
	local time = 5 * 60
	-- 间隔距离(米)
	local distance = 2000

	-- iOS第一次返回时没有位置信息，仅有经纬度，所以初始化时设置比较小的时间间隔
	if device.platform == PLANTFORM_IOS then
		time = 1
	end

	if timeInterval then
		time = timeInterval
	end

	local params = {
		time = time,
		distance = distance
	}

	local functionName = "startLocationServiceWithTime"
	if device.platform == PLANTFORM_ANDROID then
		-- echo("LBS 开启定位服务")
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCLBSHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		-- echo("LBS 开启定位服务")
		-- dump(params)
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	end
end

-- 重新开启定位服务
function PCLBSHelper:reStartLocationServiceWithTime()
	local timeInterval = 60
	self:stopLocationService()
	self:startLocationServiceWithTime(timeInterval)
end

-- 停止定位服务
function PCLBSHelper:stopLocationService()
	local params = {}

	local functionName = "stopLocationService"
	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCLBSHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	end
end

--[[
	- "actionData-----------" = {
-     "city"            = "北京市"
-     "code"            = 33
-     "country"         = "中国"
-     "district"        = "朝阳区"
-     "latitude"        = "39.976523"
-     "longitude"       = "116.400128"
-     "province"        = "unknown"
-     "street"          = "安定路"
-     "subThoroughfare" = "29号"
- }
]]
-- 更新定位信息
function PCLBSHelper:updateLocationData(data)
	-- echo("LBS 更新位置信息-")
	-- dump(data)
	
	if data then
		local province = data.province
		self.longitude = data.longitude
		self.latitude = data.latitude

		local city = data.city
		-- iOS省份有时候为"unknown"
		if device.platform == PLANTFORM_IOS then
			if province == "unknown" and city ~= "unknown" then
				province = city
			end
		end

		echoWarn("LBS province======",province)
		if province and province ~= "unknown" then
			if province ~= self.curProvince then
				self.curProvince = province
				self:onLocationChange()
			end
		else
			-- 暂时屏蔽，百度API有时也获取不到位置
			-- BasicSDK iOS版第一次返回时只有经纬度，没有位置数据
			--[[
			if self.longitude and self.latitude then
				local callBack = function(provionce)
					if provionce then
						self.curProvince = provionce
						self:onLocationChange()
					end
				end
				-- 通过百度API获取位置信息
				self:updateLocalProvince(self.longitude,self.latitude,c_func(callBack))
			end
			]]
		end
	end
end

-- 发送位置信息
function PCLBSHelper:sendLocationInfo()
	local params = {
		province = self.curProvince
	}

	-- echo("发送位置消息")
	echo("LBS curProvince=",self.curProvince)
	
	EventControler:dispatchEvent(PCLBSHelper.LBSEVENT_LOCATION_UPDATE,params)
end

-- 位置发生变更
function PCLBSHelper:onLocationChange()
	self:sendLocationInfo()

	-- 解决iOS平台第一次返回时无位置的问题
	if device.platform == PLANTFORM_IOS then
		if PCLBSHelper.isFirstGetLocaiton then
			self:reStartLocationServiceWithTime()
			PCLBSHelper.isFirstGetLocaiton = false
		end
	end
end

-- 获取当前省份
function PCLBSHelper:getProvince()
	return self.curProvince
end

-- 获取当前省份(直辖市格式:XX市，如 北京市，省格式:XX省，如河北省)
function PCLBSHelper:updateLocalProvince(longitude,latitude,callBack)
	local getInfoCallBack = function(data)
		local provionce = nil
		if data and data.code == 200 then
			local responeData = data.data
			if responeData.result and responeData.result.addressComponent then
				provionce = responeData.result.addressComponent.province
				if callBack then
					callBack(provionce)
				end
			end
		end
	end

	self:getLocalInfo(longitude, latitude, c_func(getInfoCallBack))
end

--[[
	longitude:经度
	latitude:维度
	callBack:回调函数
]]
-- 返回当前经纬度对应的位置信息
function PCLBSHelper:getLocalInfo(longitude,latitude,callBack)
	if longitude == nil or longitude == "" 
		or latitude == nil or latitude == "" then
		return
	end

	local mapAPICallBack = function(data)
		callBack(data)
	end

	local params = {
		output="json",
		location= string.format("%s,%s",longitude,latitude)
	}

	WebHttpServer:sendRequest(params, MAP_LOCATION_API, "GET",{}, c_func(mapAPICallBack))
end

return PCLBSHelper
