--
-- Author: ZhangYanguang
-- Date: 2016-06-02
-- 获取App信息及与Native通信

ServiceData = require("game.sys.data.ServiceData")

AppInformation = AppInformation or {}

-- 版本变化事件
AppInformation.APP_VERSION_CHANGE = "AppInformation.APP_VERSION_CHANGE"

-- 各平台配置
AppInformation.platformCfg = ServiceData.platformCfg

-- Java通信工具类的名称
AppInformation.javaPCCommHelperClsName = "com/playcrab/heracles/PCCommHelper"

-- ObjectC通信工具类名称
AppInformation.ocPCCommHelperClsName = "PCCommHelper"

-- Native通信ActionCode
AppInformation.actionCode = {
	ACTION_EXIT_GAME = 1,   --退出游戏
}

AppInformation.DevicePerformance = {
	HIGH = 1,
	MIDDLE = 2,
	LOW = 3,
}

-- 当前平台，如果需要切换平台，修改该配置即可
AppInformation.curPlatform = ServiceData.curPlatform

function AppInformation:init()
	echo("\n\nAppInformation:init")
	if device.platform ~= "windows" then
		self.configMgr = kakura.Config:getInstance()
	end
end

-- 获取SDK相关账号ID
-- 接入SDK后需要设置该值
function AppInformation:getSDKAccountID()
	return "account_id"
end

-- 获取SDK相关账号名称
-- 接入SDK后需要设置该值
function AppInformation:getSDKAccountName()
	return "account_name"
end

-- 获取SDK相关Token
-- 接入SDK后需要设置该值
function AppInformation:getSDKToken()
	return "account_name"
end

-- 获取游戏名称
-- 注意：只能调用getGameCfgValue，不能调用getValue
-- 因为LS初始化会调用getGameName,而getValue又会调用LS，会引起循环调用，导致栈溢出
function AppInformation:getGameName()
	local gameName = self:getGameCfgValue("APP_GAME_NAME")
	return gameName or "xianpro"
end

-- 获取游戏安装后名称
function AppInformation:getGameDisplayName()
	return PCSdkHelper:getGameDisplayName() or "仙剑·六界情缘"
end

-- 获取APP平台(集群，在打包系统platform的概念为集群，但是使用的字段是APP_DEPLOYMENT）
-- 注意：只能调用getGameCfgValue，不能调用getValue
-- 因为LS初始化会调用getAppPlatform,而getValue又会调用LS，会引起循环调用，导致栈溢出
function AppInformation:getAppPlatform()
	local platform = self:getGameCfgValue("APP_DEPLOYMENT")

	if platform == nil then
		platform = AppInformation.curPlatform
	end

	return platform
end

--[[
	!!! 注意 !!!
	1.支持分组功能的platform
	2.与AppInformation:getAppPlatform的区别时会在platform后面链接上android/ios/pc
	3.接口调用方有:
		1).获取公告
]]
function AppInformation:getGroupAppPlatform()
	local platform = self:getAppPlatform()
	-- 因为dev平台公告没有实现分组功能，所以dev平台下写死返回"dev"
	if platform == "dev" then
		return platform
	end

	if device.platform == "android" or device.platform == "ios" then
		platform = platform .. device.platform
	else
		platform = platform .. "pc"
	end

	return platform
end

-- 获取APP发行商(打包系统中使用的字段是APP_PLATFORM）
function AppInformation:getAppPublisher()
	local platform = self:getGameCfgValue("APP_PLATFORM")

	if platform == nil then
		platform = "playcrab"
	end

	return platform
end

-- 获取客户端版本
function AppInformation:getClientVersion()
	local clientVersion = self:getValue("APP_BUILD_NATIVE_NUM")
	if clientVersion == nil then
		-- dev模式下没有clientVersion，用vesion代替
		clientVersion = self:getVersion()
	end
	
	return clientVersion
end

-- 获取客户端脚本版本
function AppInformation:getVersion()
	local scriptVersion = self:getValue("APP_BUILD_NUM")
	if self:isReleaseMode() then
		return scriptVersion
	else
		-- local serverInfo = LoginControler:getServerInfo()
		-- local versionInfo = serverInfo.version
		-- if versionInfo then
		-- 	scriptVersion = versionInfo[self:getUpgradePath()].version
		-- end

		scriptVersion = self:getValue("DEV_VERSION")
		return scriptVersion or ""
	end
end

-- 更新脚本版本
function AppInformation:setVersion(version)
	if version == nil or version == "" then
		return
	end

	if self:isReleaseMode() then
		self:setValue("APP_BUILD_NUM", version)
	else
		self:setDevVersion(version)
	end

	EventControler:dispatchEvent(AppInformation.APP_VERSION_CHANGE)
end

function AppInformation:setDevVersion(version)
	if version == nil or version == "" then
		return
	end
	echo("保存dev版本号-------------",version)
	self:setValue("DEV_VERSION", version)
end

-- 获取 global_server_url
function AppInformation:getGlobalServerURL()
	-- local globalServerURL = self:getValue("GLOBAL_SERVER_URL")
	-- return globalServerURL or "global server url is nil"
	return self.globalServerURL
end


-- 重置global_server_url
function AppInformation:setGlobalServerURL(globalServerURL)
	self.globalServerURL = Tool:turnUrl(globalServerURL)
	
	-- if globalServerURL == nil or globalServerURL == "" then
	-- 	return
	-- end

	-- self:setValue("GLOBAL_SERVER_URL", globalServerURL)
end

-- 检查是否有GlboalServerUrl
function AppInformation:checkGlobalServerURL()
	return self.globalServerURL ~= nil
end

-- 获取VMS URL
function AppInformation:getVmsURL()
	if self.vmsURL then
		return self.vmsURL
	end

	local vmsURL = self:getValue("VMS_URL")
	if vmsURL == nil then
		vmsURL = AppInformation.platformCfg[AppInformation.curPlatform].vms_url
	end

	vmsURL = Tool:turnUrl(vmsURL)

	self.vmsURL = vmsURL
	return vmsURL
end

-- 重置VMS URL
function AppInformation:setVmsURL(vmsURL)
	echo("AppInformation:setVmsURL vmsURL = ",vmsURL)
	if vmsURL == nil or vmsURL == "" then
		return
	end

	self:setValue("VMS_URL", vmsURL)
end

-- 获取升级序列
function AppInformation:getUpgradePath()
	local upgradePath = self:getValue("UPGRADE_PATH")

	if upgradePath == nil then
		upgradePath = AppInformation.platformCfg[AppInformation.curPlatform].upgrade_path
	end

	return upgradePath
end

-- 获取 app information
function AppInformation:getValue(key)
	
	local value = nil
	if self:isReleaseMode() then
		value = self:getGameCfgValue(key)
	else
		value = LS:pub():get(key,nil)
	end

	return value
end

-- 持久化保存app information数据
function AppInformation:setValue(key,value)
	if self:isReleaseMode() then
		self:setGameCfgValue(key,value)
	else
		LS:pub():set(key,value)
	end
end

-- 从game.conf配置文件中获取值（walleui正式包中才有该配置文件）
function AppInformation:getGameCfgValue(key)
	local value = nil
	if self.configMgr ~= nil then
		value = self.configMgr:getValue(tostring(key))
		if value == "" or value == nil then
			value = nil
		end
	end

	return value
end

-- 更新game.confg中的值
function AppInformation:setGameCfgValue(key,value)
	if self.configMgr ~= nil then
		self.configMgr:setValue(key, value)        				
		self.configMgr:save()
	end
end

-- 获取行为日志服务器地址
function AppInformation:getActionLogServerURL()
	local serverUrl = self:getValue("LOG_SERVER_URL")
	if serverUrl == nil or serverUrl == "" then
		serverUrl = "https://api-xianpro-client.playcrab.com/v1/upload/api/";
	end

	return serverUrl
end

-- 获取错误日志服务器地址
function AppInformation:getErrorLogServerURL()
	local serverUrl = "https://api-xianpro-lua.playcrab.com/v1/upload/api/";

	return serverUrl
end

-- 获取操作系统平台
function AppInformation:getOSPlatform()
	if device.platform == "android" or device.platform == "ios" then 
		return device.platform
	else
		return "pc"
	end
end

-- 获取渠道名称(玩蟹版渠道名称)
function AppInformation:getChannelName()
	-- 默认渠道名称，不能传空
	local channelName = "Ourpalm"
	local chName = PCSdkHelper:getChannelName()
	if chName then
		channelName = chName
	end

	return channelName
end

-- 获取渠道ID
function AppInformation:getChannelID()
	local channelID = PCSdkHelper:getChannelId()
	return channelID or ""
end

-- 获取设备ID
function AppInformation:getDeviceID()
	return PCSdkHelper:getDeviceID()
end

-- MostSDK id
function AppInformation:getMostId()
	return "most_id"
end

-- client是否Releas版，walleui出的正式包为Release版本
function AppInformation:isReleaseMode()
	return cc.FileUtils:getInstance():isFileExist("game.conf")
end

-- Lua调用Natvie
-- actionCode:AppInformation.actionCode
-- params:调用参数，数据类型为table
function AppInformation:callNative(actionCode,params)
	echo("callNative actionCode=" .. actionCode)

	local functionName = "callNative"
	local callParams = params or {}
	callParams.action_code = actionCode

	if device.platform == "android" then
		luaj.callStaticMethod(AppInformation.javaPCCommHelperClsName, functionName, {callParams}, "(Ljava/util/HashMap;)V");
	elseif device.platform == "ios" then 
		dump(chargeInfoParams)

		luaoc.callStaticMethod(AppInformation.ocPCCommHelperClsName, functionName,callParams)
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_appInfor_001"))
	end
end

--先粗暴的判断
function AppInformation:getDevicePerformance()
    if device.platform == "android" then
        return AppInformation.DevicePerformance.LOW;
    elseif device.platform == "ios" or  device.platform == "mac" then
    	return AppInformation.DevicePerformance.HIGH;
    elseif device.platform == "windows" then 
    	return AppInformation.DevicePerformance.MIDDLE;
    end
    return AppInformation.DevicePerformance.HIGH;
end

--是不是高性能设备
--先粗暴的认为android都很挫
function AppInformation:isHighPerformanceDevice()
    if device.platform == "android" then
        return false;
    end
    return true;
end

-- 获取clientInfo
function AppInformation:getClientInfo(isInit)
	local client_device_type = device.platform
	local client_os_version = device.platform

	local deviceInfo = nil
	if device.platform == "android" or device.platform == "ios" then 
		deviceInfo = PCSdkHelper:getDeviceInfo()
		if deviceInfo then
			if device.platform == "ios" then
				client_device_type = IOSDeviceHelper:getDeviceType(deviceInfo.model)
			else
				client_device_type = deviceInfo.model
			end
			
			client_os_version = deviceInfo.os_version or "other"
		end
	end

	local clientInfo = {
		client_device_type= client_device_type,
		client_device_id = AppInformation:getDeviceID(),
		client_os_type = device.platform,
		client_os_version = client_os_version,
		client_channel_name = AppInformation:getChannelName()
	}

	if isInit then
		-- ourpalm平台服务器日志需要
		clientInfo.ourPalmServiceCode = PCLogHelper:getServiceCode()
	end

	return clientInfo
end

-- 是否是iPhoneX
function AppInformation:isIphoneX()
	if device.platform == "ios" then 
		local devInfo = PCSdkHelper:getDeviceInfo()
		local model = devInfo.model

		if IOSDeviceHelper:isIphoneX(model) then
			return true
		end

		return false
	end

	return false
end

--是否是带刘海的手机
function AppInformation:isToolBarIphone(  )
	if IS_NOTOCH_DEVICE then
		return true
	end
	if self:isIphoneX() then
		return true
	end
	-- print(GameVars.width / GameVars.height,"__GameVar.width GameVars.height")
	-- print(GameVars.width / GameVars.height,"__GameVar.width GameVars.height")
	-- print(GameVars.width / GameVars.height,"__GameVar.width GameVars.height")
	-- print(GameVars.width / GameVars.height,"__GameVar.width GameVars.height")
	--如果长宽比小于1.85 直接返回false
	if GameVars.width / GameVars.height  < 1.9 then
		return false
	end

	-- 
	local rt = PCSdkHelper:checkIsNotchInScreen(  )
	
	return rt
end

local _deviceIp
--获取设备ip
function AppInformation:getDeviceIp(  )
	if _deviceIp then
		return  _deviceIp
	end
	local socket =require("socket")
	local client = socket.connect("www.baidu.com", 80)
    local ip = nil

    -- 没有网络时client为nil
    if client then
        ip = client:getsockname() 
    end

    local hostname = nil
    if ip == nil then
        hostname = socket.dns.gethostname()
        ip = socket.dns.toip(hostname)
    end

    if ip == nil then
        return hostname
    end
    --如果是没练上网络 也不返回
    if ip == "127.0.0.1" then
    	return ip
    end
    _deviceIp = ip
    return _deviceIp
end

--判断是否是底端设备 true是低端设备
function AppInformation:checkIsLowDevice(  )
	if device.platform == "mac" or device.platform == "win" or device.platform == "ios" then
		return false
	end

	local sysVersion = self:getClientInfo().client_os_version
	local versionArr = string.split(sysVersion, ".")
	if versionArr[1] and tonumber(versionArr[1]) then
		local versionNum = tonumber(versionArr[1])
		if versionNum > 4 then
			return false
		else
			return true
		end
	end
	return false
end

-- 判断iOS系统视频特殊处理
function AppInformation:checkSpecialVideo()
	if device.platform == "ios"  then
		local deviceInfo = self:getClientInfo()
		local client_os_version = deviceInfo.client_os_version
		local numArr = string.split(client_os_version, ".")
		local versionNum  = 0
		for i=1,2 do
			if tonumber(numArr[i]) then
				versionNum = versionNum+  math.pow(10, (2-i)) * tonumber(numArr[i])
			end
		end
		echo(versionNum,versionNum >= (11*10 +3),"versionNum-----",client_os_version)
		--如果ios 版本号大于11.3 不播放视频
		if versionNum >= (11*10 +3) then
			return true
		end
		return false
	end

	return false
end

-- 判断是否是先锋体验包
function AppInformation:checkXianFengTiYan()
	if not LoginControler:isLogin() then
		echo("checkXianFengTiYan 没有登录")
		return false
	end

	local constUpgradePath = "android_cn_0710"
	local constPlatform = "ztest"
	local secIdList = {"3002","3003"}
	-- local constSecId = "3002"
	
	local upgradePath = self:getUpgradePath()
	local platform = self:getAppPlatform()
	local serverInfo = LoginControler:getServerInfo()
	local secId = serverInfo._id

	-- dump(serverInfo,"serverInfo----------")
	echo("upgradePath=",upgradePath)
	echo("platform=",platform)
	echo("secId=",secId)
	
	if upgradePath == constUpgradePath and platform == constPlatform 
		and secId and table.indexof(secIdList,tostring(secId)) then
		return true
	end

	return false
end

AppInformation:init()
