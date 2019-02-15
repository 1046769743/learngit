--
-- Author: ZhangYanguang
-- Date: 2016-02-23
-- MostSdk 工具类

PCSdkHelper = {}

local channelMap = require("common.channel")

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

-- Lua&Java通信工具类的名称
local javaPCCommHelperClsName = "com/utils/core/SDKUtils"
local ocPCCommHelperClsName = "SDKUtils"

PCSdkHelper.javaPCCommHelperClsName = javaPCCommHelperClsName
PCSdkHelper.ocPCCommHelperClsName = ocPCCommHelperClsName

--[[
	默认Android方法签名
	为避免不同方法签名的书写错误导致部分Androi设备闪退，故统一签名
	要求：
	   Java方法参数均为HashMap<String, String> params
	   Java方法返回值均为：String
]]
PCSdkHelper.defaultAndroidSign = "(Ljava/util/HashMap;)Ljava/lang/String;"

-- SDK相关消息
PCSdkHelper.EVENT_SCREEN_ORIENTATION = "PCSdkHelper.EVENT_SCREEN_ORIENTATION"
PCSdkHelper.SCREEN_ORIENTATION = {
	-- 横屏Home键在右
	LANDSCAPE_HOME_RIGHT = 1,
	-- 横屏Home键在左
	LANDSCAPE_HOME_LEFT = -1
}

-- PUSH通知状态
PCSdkHelper.PUSH_STATUS = {
	RECEIVE = "1",
	CLICKED = "2",
	DELETED = "3"
}

-- MostSdk 状态码
MystiqueStatusCode = {
	MST_INIT_SUCCESS = 0,
	MST_INIT_FAIL = 1,
	MST_LOGIN_SUCCESS = 2,
	MST_LOGIN_FAIL = 3,
	MST_LOGIN_CANCEL = 4,
	MST_LOGOUT_SUCCESS = 5,
	MST_LOGOUT_FAIL = 6,
	MST_LOGOUT_CANCEL = 7,
	MST_CHARGE_SUCCESS = 8,
	MST_CHARGE_FAIL = 9,
	MST_CHARGE_CANCEL = 10,
	MST_CHARGE_FORBIDDEN = 11,
	MST_SWITCH_USER_SUCCESS = 12,
	MST_SWITCH_USER_FAIL = 13,
	MST_SHARE_SUCCESS = 14,
	MST_SHARE_FAIL = 15,
	MST_SHARE_CANCEL = 16,

	MST_SAVE_PICTURES_SUCCESS = 17,
	MST_SAVE_PICTURES_FAIL = 18,

	-- xianpro项目扩展
	-- 网络状态变化
	MST_NETWORK_CHANGE = 30,
	-- 屏幕方向变化
	MST_ORIENTATION_CHANGE = 31,
	-- 推送Push状态(1表示收到 2表示点击 3表示被删除)
	MST_PUSH_STATUS = 32,
	-- 获取定位信息
	MST_LOCATION_RESULT = 33,
}

PCSdkHelper.supportedMethodsMap = nil

local isInLogin = false
local lastLoginTime = 0

-- ========================================================
-- MostSDK Java&Object-c 端回调Lua的全局函数
function G_SDKCallBackFromNative(jsonData)
	-- echo("zygtest-mostsdk charge G_SDKCallBackFromNative",jsonData)

	local jsonParams
	local code = nil
	local actionData = nil

	if device.platform == PLANTFORM_ANDROID then
		jsonParams = jsonData
		actionData = json.decode(jsonParams)
		code = actionData.code

	elseif device.platform == PLANTFORM_IOS then
		--[[
		if jsonData == nil then
			PCSdkHelper:registerLuaScriptHandler()
			return
		end
		
		code = jsonData.code
		jsonParams = jsonData.data
		if jsonParams ~= nil and jsonParams ~= "" then
			actionData = json.decode(jsonParams)
		end
		]]

		jsonParams = jsonData
		actionData = json.decode(jsonParams)
		code = actionData.code
	end

	if code == nil or code == "" then
		echo("mostsdk-G_SDKCallBackFromNative Error code is ",code)
		return
	else
		echo("mostsdk-G_SDKCallBackFromNative code is ",code)
	end 

	-- 初始化成功
	if code == MystiqueStatusCode.MST_INIT_SUCCESS then
		-- 应用在MostSDK中注册应用是分配的应用ID
		-- PCSdkHelper.app_id = actionData.app_id
		-- 渠道的别名，决定具体渠道的文件名，命名规则大写字母开头
		-- PCSdkHelper.channel_alias = actionData.channel_alias

		-- 应用在MostSDK中注册应用是分配的应用ID
		LS:pub():set(StorageCode.mostsdk_app_id, actionData.app_id)
		-- 渠道的别名，决定具体渠道的文件名，命名规则大写字母开头
		LS:pub():set(StorageCode.mostsdk_channel_alias, actionData.channel_alias)

		--[[
		原玩蟹mostsdk初始化后自动登录逻辑，现已无用，不会走到这里，注释掉 by ZhangYanguang 2018.04.23
		echo("初始化成功 PCSdkHelper.app_id=",PCSdkHelper.app_id)
		if not DEBUG_SKIP_LOGIN_SDK then
			echo("mostsdk-初始化成功，开始登录逻辑")
			if LoginControler:checkAutoLogin() then
				echo("mostsdk-login-init")
				echo("mostsdk-初始化成功，开始登录逻辑")
				PCSdkHelper:login()
			end
		end
		]]
	-- 初始化失败
	elseif code == MystiqueStatusCode.MST_INIT_FAIL then
		echo("mostsdk-初始化失败")
	-- 登录成功，做选服等游戏内登录逻辑
	elseif code == MystiqueStatusCode.MST_LOGIN_SUCCESS then
		-- echo("mostsdk-登录成功=func=",PCSdkHelper.onSDKLoginSuccess)
		PCSdkHelper:onSdkLoginSuccess(actionData)

	-- 注销成功
	elseif code == MystiqueStatusCode.MST_LOGOUT_SUCCESS then
		echo("mostsdk-注销成功")
		PCSdkHelper:onSdkLogoutSuccess()
	-- 登录失败或取消
	elseif code == MystiqueStatusCode.MST_LOGIN_FAIL or code == MystiqueStatusCode.MST_LOGIN_CANCEL then
		-- 可与MST_LOGIN_CANCEL做相同处理
		echo("mostsdk-登录失败或取消")
		isInLogin = false
	-- 支付成功
	elseif code == MystiqueStatusCode.MST_CHARGE_SUCCESS then
		echo("mostsdk-支付成功",jsonData)
		-- WindowControler:showTips(GameConfig.getLanguage("tid_common_2071"))
		--这里会回调支付成功的订单号，游戏根据自己需要处理后续逻辑
        --data返回示例 {"bill_id":"201507241000000313"}
        local data = {
        	ssid = actionData.ssid,
        	pbid = actionData.pbid
    	}
        PCChargeHelper:onChargeSuccess(data)
	-- 支付失败
	elseif code == MystiqueStatusCode.MST_CHARGE_FAIL then
		echo("mostsdk-支付失败")
		--游戏可以忽略
		local data = {
			ssid = actionData.ssid,
        	pbid = actionData.pbid
		}
		PCChargeHelper:onChargeFail()
	-- 支付取消
	elseif code == MystiqueStatusCode.MST_CHARGE_CANCEL then
		echo("mostsdk-支付取消")
		--游戏可以忽略
		local data = {
			ssid = actionData.ssid,
        	pbid = actionData.pbid
		}
		PCChargeHelper:onChargeFail()
	-- 支付禁止
	elseif code == MystiqueStatusCode.MST_CHARGE_FORBIDDEN then
		echo("mostsdk-支付禁止")
		PCChargeHelper:onChargeFail()
	-- 玩家切换账号成功
	elseif code == MystiqueStatusCode.MST_SWITCH_USER_SUCCESS then
		--这里可能出现两种情况,游戏方需要处理这两种情况
        --1.玩家还在登录页面，并未加载任何的游戏数据但是通过用户中心切换了账号。
        --2.玩家在游戏中切换账号
        echo("mostsdk-切换账号成功")
        if device.platform == PLANTFORM_ANDROID then
        	PCSdkHelper:onSdkSwitchUserSuccess(actionData)
        end

    -- 玩家切换账号失败
	elseif code == MystiqueStatusCode.MST_SWITCH_USER_FAIL then

	-- 截屏成功
	elseif code == MystiqueStatusCode.MST_SAVE_PICTURES_SUCCESS then
		PCShareHelper:onCorpImageSuccess(actionData)

	-- 截屏失败
	elseif code == MystiqueStatusCode.MST_SAVE_PICTURES_FAIL then
		PCShareHelper:onCorpImageFail()

	-- 分享成功
	elseif code == MystiqueStatusCode.MST_SHARE_SUCCESS then
		PCShareHelper:onShareSucess()
	-- 分享失败
	elseif code == MystiqueStatusCode.MST_SHARE_FAIL then
		PCShareHelper:onShareFail()
	-- 分享取消
	elseif code == MystiqueStatusCode.MST_SHARE_CANCEL then
		PCShareHelper:onShareFail()
	-- 网络状态变化
	elseif code == MystiqueStatusCode.MST_NETWORK_CHANGE then
		echo("网络状态变化了")
		echo(network.getInternetConnectionStatus())
		PCSdkHelper:onNetWorkChange()
	-- 屏幕方向变化
	elseif code == MystiqueStatusCode.MST_ORIENTATION_CHANGE then
		local orientation = actionData.orientation
		PCSdkHelper:onScreenOrientationChange(orientation)
	-- Push通知状态变化
	elseif code == MystiqueStatusCode.MST_PUSH_STATUS then
		local status = actionData.status
		echo("TPush Push通知状态变化了status=")
		echo(status)
		-- push通知打点
		if status then
			local actionKey = ""
			if tostring(status) == PCSdkHelper.PUSH_STATUS.RECEIVE then
				actionKey = ActionConfig.push_receive
			elseif tostring(status) == PCSdkHelper.PUSH_STATUS.CLICKED then
				actionKey = ActionConfig.push_clicked
			end

			ClientActionControler:sendTutoralStepToWebCenter(actionKey)
		end
	-- 定位信息
	elseif code == MystiqueStatusCode.MST_LOCATION_RESULT then
		-- dump(actionData,"actionData-----------")
		PCLBSHelper:updateLocationData(actionData)
	end
end

--[[
	保存Token数据
]]
function PCSdkHelper:saveTokenData(actionData)
	echo("saveTokenData=")
	-- Most用户ID
	AppHelper:setValue(StorageCode.mostsdk_account_id, tostring(actionData.account_id))
	-- 登录验证所需token，由sdk端传给游戏
	AppHelper:setValue(StorageCode.mostsdk_token, tostring(actionData.account_token))
	-- 渠道的别名，决定具体渠道的文件名，命名规则大写字母开头
	AppHelper:setValue(StorageCode.mostsdk_channel_alias, tostring(actionData.channel_alias))
	-- 账号名称
	AppHelper:setValue(StorageCode.mostsdk_account_name, tostring(actionData.account_name))
	-- 账号类型
	AppHelper:setValue(StorageCode.mostsdk_account_usertype, tostring(actionData.currentUserType))
end

function PCSdkHelper:clearTokenData()
	-- 登录验证所需token，由sdk端传给游戏
	AppHelper:setValue(StorageCode.mostsdk_token, "")
	-- 渠道的别名，决定具体渠道的文件名，命名规则大写字母开头
	AppHelper:setValue(StorageCode.mostsdk_channel_alias,"")
end

--[[
	sdk注销成功
]]
function PCSdkHelper:onSdkLogoutSuccess()
	echo("mostsdk-onSdkLogoutSuccess")
	-- 游戏内切换账号到登录界面，然后再注销账号，需要清除切换账号的状态
	LoginControler:setIsSwitchAccount(false)
	
	-- WindowControler:globalDelayCall(c_func(LoginControler.restarGame,LoginControler),1/GameVars.GAMEFRAMERATE)
	-- 如果已经登录，说明是通过游戏中的注销按钮调用的注销
	if LoginControler:isLogin() then
		LoginControler:restarGame()
	else
		-- 重新弹出登录界面(没有必要清理lua栈)
		LoginControler:reLoginAfterLogout()
	end
end

--[[
	sdk账号登录成功
	1.直接登录时登录成功
	2.切换账号后登录成功
		a.iOS切换账号成功(回调中不带数据),再次点击后触发登录成功(回调中带数据)
		b.Android切换账号成功(回调中带数据与登录成功回调数据一致)
]]
function PCSdkHelper:onSdkLoginSuccess(actionData)
	-- echo("mostsdk-onSDKLoginSuccess")
	isInLogin = false
	echo("mostsdk-登录成功，开始选服登录的相关逻辑 account_token=",actionData.account_token)
	self:saveTokenData(actionData)

	-- Android平台，sdk登录成功，执行游戏层登录
	if device.platform == PLANTFORM_ANDROID then
		-- 执行游戏层登录
		LoginControler:doSdkLogin()
	elseif device.platform == PLANTFORM_IOS then
		-- 如果游戏已登录，一定是切换账号后的登录成功
		if LoginControler:isLogin() then
			-- 设置切换账号状态
			LoginControler:setIsSwitchAccount(true)
			-- 重启游戏，游戏重启时会根据是否切换账号状态进行游戏层登录
			LoginControler:restarGame()
		else
			-- 如果游戏未登录
			-- 1.可能是直接登录成功
			-- 2.或者是在游戏登录界面登录时通过sdk界面进行的切换账号

			-- 执行游戏层登录
			LoginControler:doSdkLogin()
		end
	end
end

--[[
	sdk账号登录成功
	1.直接登录时登录成功
	2.切换账号后登录成功
		a.iOS切换账号成功(回调中不带数据),再次点击后触发登录成功(回调中带数据)
		b.Android切换账号成功(回调中带数据与登录成功回调数据一致)
]]
function PCSdkHelper:onSdkSwitchUserSuccess(actionData)
	echo("mostsdk-onSdkSwitchUserSuccess")
	isInLogin = false
	echo("mostsdk-登录成功，开始选服登录的相关逻辑 account_token=",actionData.account_token)
	self:saveTokenData(actionData)

	-- Android平台，切换账号成功
	if device.platform == PLANTFORM_ANDROID then
		-- 如果游戏已登录
		if LoginControler:isLogin() then
			-- 设置切换账号状态
			LoginControler:setIsSwitchAccount(true)
			-- 重启游戏，游戏重启时会根据是否切换账号状态进行游戏层登录
			LoginControler:restarGame()
		else
			-- 如果游戏未登录，一定是在游戏登录界面登录时通过sdk界面进行的切换账号
			-- 执行游戏层登录
			LoginControler:doSdkLogin()
		end
	end
end

--[[
 * 上报游戏数据
 * 玩家数据初始化成功后以及执行支付操作前需要向渠道上报游戏数据
 * 
 * role_id: 角色id
 * role_name:角色名称
 * sec: 分区标识
 * sec_name: 分区名称
 * vip: vip等级
 * level: 角色等级
 * balance: 货币余额
 * @param userInfoMap
]]
function PCSdkHelper:sendUserInfo(isRegister)
	echo("mostsdk ourpalm sendUserInfo=",isRegister)

	local functionName = "sendUserInfo"

	local userInfoParams = {}
	-- 如下key值都是ourpalm定义的，不要随意修改
	userInfoParams.roleid = UserModel:rid()
	local rolename = UserModel:name()

	-- 如果没有初始化昵称，使用默认值，后端保持一致的默认昵称
	if not UserExtModel:hasInited() then
		rolename = "无名氏"
	end

	userInfoParams.rolename = rolename
	userInfoParams.gameserverid = LoginControler:getServerId()
	userInfoParams.gameservername = LoginControler:getServerName()
	userInfoParams.roleviplv = tostring(UserModel:vip())
	userInfoParams.rolelv = tostring(UserModel:level())
	if isRegister then
		userInfoParams.type = 1
	else
		userInfoParams.type = 2
	end

	-- echo("\n\nsendUserInfo ---------------------------")
	-- dump(userInfoParams,"userInfoParams-----------------")
	
	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {userInfoParams}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then 
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,userInfoParams)
	else
		echoWarn(device.platform .. " no sendUserInfo function")
	end	
end

-- 检查是否在登录中
function PCSdkHelper:checkIsInLogin()
	-- 如果正在登录中
	if isInLogin then
		-- 超时时间设置为10秒
		local overTime = 10
		if lastLoginTime and lastLoginTime > 0 then
			local curTime = TimeControler:getServerTime()
			if (curTime - lastLoginTime) >= overTime then
				return false
			end
		end

		return true
	else
		return false
	end
end

-- 调用sdk登录功能，弹出渠道登录界面(某些渠道比如纵乐，该接口为试玩接口)
function PCSdkHelper:login()
	if PCSdkHelper:checkIsInLogin() then
		-- echo("sdk return....")
		return
	end

	isInLogin = true
	lastLoginTime = TimeControler:getServerTime()

	local functionName = "login"
	echo("mostsdk-login-ourpalm login")

	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 打开sdk用户中心界面
function PCSdkHelper:openUserCenter()
	if DEBUG_SKIP_LOGIN_SDK then
		WindowControler:showTips('该平台不支持该功能')
		return
	end

	local functionName = "openUserCenter"
	echo("mostsdk-openUserCenter")
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 打开sdk客服反馈系统
function PCSdkHelper:openUserFeedback()
	local functionName = "openUserFeedback"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	else
		WindowControler:showTips("PC平台不支持")
	end
end

-- 调用sdk登出功能
function PCSdkHelper:logout()
	if DEBUG_SKIP_LOGIN_SDK then
		WindowControler:showTips('该平台不支持该功能')
		return
	end
	
	local functionName = "logout"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

--[[
	打开应用宝论坛
]]
function PCSdkHelper:openForum()
	if not self:isTencentChannel() then
		return
	end

	local functionName = "openForum"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end
end

--[[
	打开应用宝V+特权
]]
function PCSdkHelper:openVplayer()
	if not self:isTencentChannel() then
		return
	end
	
	local functionName = "openVplayer"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end
end

--[[
	是否是腾讯应用宝渠道
]]
function PCSdkHelper:isTencentChannel()
	-- TODO 2018.09.04 五测强制关闭论坛功能
	if true then
		return false
	end

	local channelName = AppInformation:getChannelName()
	-- 渠道名称必须与channel.csv配置中保持一致
	if channelName == "Tencent" then
		return true
	end

	return false
end

-- 是否支持切换账号功能
function PCSdkHelper:isSwitchUserSupported()
	return PCSdkHelper:isFunctionSupported("switchUser")
end

-- 是否支持用户中心功能
function PCSdkHelper:isUserCenterSupported()
	if device.platform == PLANTFORM_IOS then
		return false
	end

	return PCSdkHelper:isFunctionSupported("openUserCenter")
end

-- 是否支持注销功能
function PCSdkHelper:isLogoutSupported()
	if device.platform == PLANTFORM_IOS then
		return false
	end
	
	return PCSdkHelper:isFunctionSupported("logout")
end

-- 是否支持指定API
function PCSdkHelper:isFunctionSupported(functionName)
	-- 特殊处理，跳过sdk登录的显示切换账号
	if DEBUG_SKIP_LOGIN_SDK then
		return true
	end

	local supportedMethodsMap = self:getSupportedMethods()
	if supportedMethodsMap then
		if 1 == supportedMethodsMap[functionName] then
			return true
		else
			return false
		end
	end

	return true
end

-- 获取sdk支持的方法列表
function PCSdkHelper:getSupportedMethods()
	if PCSdkHelper.supportedMethodsMap then
		return PCSdkHelper.supportedMethodsMap
	end

	local functionName = "getSupportedMethods"
	local params = {}

	local jsonResult = nil
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,jsonResult = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,jsonResult = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	if jsonResult then
		PCSdkHelper.supportedMethodsMap = json.decode(jsonResult)
	end

	return PCSdkHelper.supportedMethodsMap
end

-- 切换账号
function PCSdkHelper:switchUser()
	echo("mostsdk switchUser切换账号")
	local functionName = "switchUser"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

--[[
 * 加载url
 * url:加载的url地址
 * type: 0-webview 全屏窗口(简陋版，仅有关闭按钮) 1-webview 半屏窗口 2-browser浏览器 3-全屏(带前进、后退、刷新功能)
]]
function PCSdkHelper:loadUrl(url,type)
	local functionName = "loadUrl"
	local urlInfo = {
		url = url,
		type = type
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {urlInfo}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,urlInfo)
	else
		WindowControler:showTips("该平台暂不支持loadUrl")
	end
end

--获取设备Id
function PCSdkHelper:getDeviceID()
	local functionName = "getDeviceID"
	if PCSdkHelper.deviceId then
		return PCSdkHelper.deviceId
	end

	-- if IS_CLOSE_DEVICE_CACHE == false then
	-- 	local localStoragedDeviceId = LS:pub():get(StorageCode.device_id ,"")
	-- 	if localStoragedDeviceId ~= "" then
	-- 		return localStoragedDeviceId
	-- 	end
	-- end

	local params = {}

	local deviceId = nil
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,deviceId = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,deviceId = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	else
		--windows and mac and else
		result = true
		deviceId = Tool:getDeviceId()
	end

	if not result then
		echoError(functionName .. " fail")
	else
		-- LS:pub():set(StorageCode.device_id, deviceId)
		PCSdkHelper.deviceId = deviceId
	end

	return deviceId
end

--获取设备信息
--[[
result = {
	"broken"       = "0"
	"country_code" = "CN"
	"device_id"    = "350D4EFF-5440-4132-A7DA-1029F12940D4"
	"free_memory"  = "320784.0"
	"idfa"         = "350D4EFF-5440-4132-A7DA-1029F12940D4"
	"idfv"         = "3BC12611-B680-4A78-B5CF-D5D26E6D3668"
	"mac"          = "02:00:00:00:00:00"
	"model"        = "iPad6,11"
	"network"      = "WIFI"
	"os_version"   = "11.3"
	"room_size"    = "26650948.8"
	"system_name"  = "iOS"
	"total_memory" = "2027008.0"
}
-- 注意：不要使用devInfo.system_name(返回的是iOS，需要统一使用ios)
---]]
function PCSdkHelper:getDeviceInfo()
	if self._deviceInfo then
		return self._deviceInfo
	end
	local functionName = "getDeviceInfo"

	local params = {}
	local deviceInfoObj = {}
	local deviceInfo = "{}"
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,deviceInfo = luaj.callStaticMethod(javaPCCommHelperClsName, functionName,{params},PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,deviceInfo = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	else
		result = true
		deviceInfoObj.system_name = "pc"
		deviceInfoObj.model = device.platform
	end

	if result then
		if deviceInfoObj.system_name ~= "pc" then 
			deviceInfoObj = json.decode(deviceInfo)
		end
	else
		echoWarn( functionName .. " fail")
	end
	self._deviceInfo = deviceInfoObj
	return deviceInfoObj
end

--[[
	获取设备存储空间信息
	iOS数据结构
	{
		"internalAvaliable" = "8406360064"
		"internalTotal"     = "31999852544"
	}
	
	Android数据结构
	{
		"externalTotal": "56598290432",
		"externalAvailable": "3481796608",
		"internalTotal": "56598290432",
		"internalAvaliable": "3481796608"
	}
	
	externalAvailable:sdcard可用存储空间
	externalTotal:sdcard总存储空间

	internalAvaliable:内部可用存储空间
	internalTotal:内部总存储空间

	1.以上，单位都是byte，如果值是-1，表示获取数据失败
	2.Android平台理论上internalAvaliable与externalAvailable相同 internalTotal与externalTotal相同
]]
function PCSdkHelper:getStorageInfo()
	local functionName = "getStorageInfo"

	local params = {}
	local storageInfoObj = {}
	local storageInfo = "{}"
	local result = false
	if device.platform == PLANTFORM_ANDROID then
		result,storageInfo = luaj.callStaticMethod(javaPCCommHelperClsName, functionName,{params},PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,storageInfo = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	if result then
		storageInfoObj = json.decode(storageInfo)
	else
		echoWarn( functionName .. " fail")
	end

	return storageInfoObj
end

--[[
	获取系统软硬件信息，方便对不同系统不同渠道包进行差异化处理
	与getDeviceInfo的差异：getDeviceInfo通过BasicSDK获取，信息有限且不易扩展
	{
		"brand": "Xiaomi",
		"model": "MI 5s",
		"manufacturer": "Xiaomi",
		"host": "c3-miui-ota-bd36",
		"sdk": 23,
		"hardware": "qcom",
		"release": "6.0.1",
		"cpu": "armeabi-v7a",
		"device": "capricorn",
		"display": "MXB48T",
		"product": "capricorn"
	}
--]]
function PCSdkHelper:getOSInfo()
	if self.osInfo then
		return self.osInfo
	end

	local functionName = "getOSInfo"
	local osInfo = {}
	local params = {}

	local result = nil
	local osJsonInfo = nil
	if device.platform == PLANTFORM_ANDROID then
		result,osJsonInfo = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then

	end

	if osJsonInfo then
		osInfo = json.decode(osJsonInfo)
		self.osInfo = osInfo
	end

	return osInfo
end

-- 设置sdk退出类型(Android返回键退出界面) 0:游戏的退出 1:sdk的退出 
function PCSdkHelper:setSdkExitGameType(exitType)
	if not exitType then
		return
	end

	local functionName = "setSdkExitGameType"
	local params = {
		exitType = tostring(exitType)
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end
end

-- 复制文字到系统剪贴板
function PCSdkHelper:copyContentToClipboard(content)
	local functionName = "copyWithString"
	local params = {
		content = content or ""
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	end
end

-- 获取渠道ID(作为子渠道用)
function PCSdkHelper:getChannelId()
	local channelID = ""
	local functionName = "getChannelId"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		result,channelID = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,channelID = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	return channelID
end

-- 获取渠道ID
function PCSdkHelper:getServiceId()
	local serviceId = ""
	local functionName = "getServiceId"
	local params = {}

	if self.serviceId then
		return self.serviceId
	end

	if device.platform == PLANTFORM_ANDROID then
		result,serviceId = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,serviceId = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	if serviceId then
		self.serviceId = serviceId
	end

	return serviceId
end

-- 获取原始渠道名称
function PCSdkHelper:getOriginChannelName()
	local channelName = nil
	local functionName = "getChannelName"
	if device.platform == PLANTFORM_ANDROID then
		result,channelName = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,channelName = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
	
	return channelName
end

-- 获取渠道名称(将掌趣sdk返回的渠道ID映射为玩蟹的渠道名称)
function PCSdkHelper:getChannelName()
	local channelName = nil
	local channelId = self:getChannelId()
	
	if channelId and channelMap then
		local key = string.format("cid%s",channelId)
		if key and channelMap[key] then
			-- 查询映射表，获取渠道名称
			channelName = channelMap[key].name
		end
	end
	
	return channelName
end

function PCSdkHelper:checkNetWorkPermission()
	-- 因权限获取不准确，暂时关闭
	if true then
		return true
	end

	local state = self:getNetWorkPermissionState()
	-- 关闭了网络权限
	if state then
		-- 关闭了网络权限
		if state == 0 then
			return false
		-- 仅开启了wifi权限
		elseif state == 1 then
			local status = network.getInternetConnectionStatus()
			-- 没有网络或只有wan网
			if status == network.status.kCCNetworkStatusNotReachable
				or status == network.status.kCCNetworkStatusReachableViaWWAN then
				return false
			end
		end
	end

	return true
end

-- 获取网络权限状态，目前仅iOS系统实现了该功能
function PCSdkHelper:getNetWorkPermissionState()
	local functionName = "checkNetWorkPermission"
	echo("检查网络权限")
	-- 0  关闭 1 仅wifi 2 流量+wifi
	-- 默认打开状态
	local state = 2
	if device.platform == PLANTFORM_ANDROID then
		-- Android状态获取不准确
		-- result,rt = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {}, "()I")
		-- echo("network check network",rt)
		-- if rt then
		-- 	if tonumber(rt) == 0 then
		-- 		state = 2
		-- 	elseif tonumber(rt) == -1 then
		-- 		state = 0
		-- 	end
		-- end
	elseif device.platform == PLANTFORM_IOS then
		result,state = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	return state
end

-- 检查网络权限
function PCSdkHelper:goPermissionSettingView()
	local functionName = "goSettingView"
	if device.platform == PLANTFORM_ANDROID then

	elseif device.platform == PLANTFORM_IOS then
		result,state = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end
end

-- 获取游戏安装后显示的名称
function PCSdkHelper:getGameDisplayName()
	local functionName = "getGameDisplayName"
	local params = {}

	local gameName = nil
	if device.platform == PLANTFORM_ANDROID then
		result,gameName = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		result,gameName = luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	return gameName
end


-- 网络发生变化
-- 临时方案，之后会修改会Android/iOS OS收到系统网络变化消息后，回调该方法
function PCSdkHelper:onNetWorkChange()
	local lastNetworkStatus = PCSdkHelper.lastNetworkStatus
	if PCSdkHelper.lastNetworkStatus == network.isInternetConnectionAvailable() then
		return
	end
	
	PCSdkHelper.lastNetworkStatus = network.isInternetConnectionAvailable()
	-- 发送网络变化消息
	EventControler:dispatchEvent(NetworkEvent.NETWORK_STATUS_CHANGE)
end

-- 屏幕方向发生变化
function PCSdkHelper:onScreenOrientationChange(orientation)
	local customOrientation = nil

	if device.platform == PLANTFORM_ANDROID then
		if orientation == 0 then
			customOrientation = PCSdkHelper.SCREEN_ORIENTATION.LANDSCAPE_HOME_RIGHT
		elseif orientation == 8 then
			customOrientation = PCSdkHelper.SCREEN_ORIENTATION.LANDSCAPE_HOME_LEFT
		end
	elseif device.platform == PLANTFORM_IOS then 
		if orientation == 3 then
			customOrientation = PCSdkHelper.SCREEN_ORIENTATION.LANDSCAPE_HOME_RIGHT
		elseif orientation == 4 then
			customOrientation = PCSdkHelper.SCREEN_ORIENTATION.LANDSCAPE_HOME_LEFT
		end
	end 

	if customOrientation then
		-- echo("mostsdk-屏幕方向变化orientation=" .. tostring(customOrientation))
		EventControler:dispatchEvent(PCSdkHelper.EVENT_SCREEN_ORIENTATION,{orientation = customOrientation})
	end
end

-- 检查设置sdk退出类型
function PCSdkHelper:checkSdkExitType()
	if device.platform ~= PLANTFORM_ANDROID then
		return
	end

	if DEBUG_SKIP_LOGIN_SDK then
		return
	end

	local osInfo = self:getOSInfo()
	local channelName = self:getChannelName()
	-- echo("zygdbug osInfo=",json.encode(osInfo))
	-- 如果是小米渠道包
	if "Xiaomi" == channelName then
	-- if true then
		local brand = osInfo.brand
		echo("brand=",brand)
		-- 如果不是小米手机
		if brand and not string.find(string.lower(brand),"xiaomi") then
			-- echo("zygdbug 设置不支持sdk exit")
			self:setSdkExitGameType(0)
		end
	end
end

-- =======================================
-- 为Object-c注册回调Lua的函数
function PCSdkHelper:registerLuaScriptHandler()
	local params = {
        callLuaHandler = G_SDKCallBackFromNative
    }

    luaoc.callStaticMethod("PCCommHelper", "regisgerLuaScriptHandler",params)
end

-- 为Java注册该lua文件初始化完成的回调
function PCSdkHelper:registerLuaRequireHandler()
	local functionName = "onLuaInitFinish"
	local params = {}
	luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);

	self:checkSdkExitType()
end

-- 重置lua初始化状态(清空lua栈后需要调用该方法)
function PCSdkHelper:resetLuaInitedStatus()
	local functionName = "resetLuaInitedStatus"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end
end

--登入成功之后给bugly设置账号账号
function PCSdkHelper:initBuglyUserinfo( username )
	username = username or LS:pub():get(StorageCode.username ,"")
	local rid = PCSdkHelper:getDeviceID()
	local platform = AppInformation:getAppPlatform()
	if LoginControler and LoginControler:isLogin() then
		rid = UserModel:rid()
		username = UserModel:name()
	else
		if(username ~= "") then
			username = rid
		end
		local serverName
		
	end
	--连接一下平台
	rid = rid .."_"..platform
	
	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, "setBuglyUserInfo",{ {value=username,key = platform,rid = rid} }, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, "setBuglyUserInfo",{value=username,key = platform,rid = rid})
	end
end

-- 初始化MostSdk(已移到native中初始化,lua中不要调用该方法 by ZhangYanguang 2018.05.03)
function PCSdkHelper:initMostSdk()
	-- 切换账号重启lua栈后不再初始化sdk
	local key = "sdk_ourpalm_init"
	if AppHelper:getValue(key) ~= "" then
		return
	end

	if DEBUG_SKIP_LOGIN_SDK then
		return
	end

	echo("mostsdk-lua端初始化sdk")
	local functionName = "initMostSdk"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName,{})
	end

	AppHelper:setValue(key,"true")
end

-- Object-c请求注册Lua回调函数
-- function G_RequestRegisgerLuaScriptHandler()
-- 	PCSdkHelper:registerLuaScriptHandler()
-- end

-- 为Object-c注册回调Lua的函数
if device.platform == PLANTFORM_IOS then
	PCSdkHelper:registerLuaScriptHandler()
elseif device.platform == PLANTFORM_ANDROID then
	PCSdkHelper:registerLuaRequireHandler()
end

-- 设置iOS语音模式
function PCSdkHelper:setVoicemode( mode )
	if device.platform ~= "ios" then 
		return
	end
	if self.currentMode == mode then
		return
	end
	self.currentMode = mode
	local voiceMode 
	-- 1是正常模式  2是录音录音模式  3 是播放模式
	if mode == 1 then
		voiceMode = GameVars.voiceModeDic.AVAudioSessionCategoryAmbient
	elseif mode == 2 then
		voiceMode = GameVars.voiceModeDic.AVAudioSessionCategoryAmbient
		return
	elseif mode == 3 then
		voiceMode = GameVars.voiceModeDic.AVAudioSessionCategoryAmbient
		return
	end

	luaoc.callStaticMethod(ocPCCommHelperClsName, "setVoiceMode",{mode = voiceMode})
end


--android下判断是否是刘海手机
function PCSdkHelper:checkIsNotchInScreen(  )
	if device.platform   ~= "android" then
		return false;
	end
	echo("startCheckIsNotchInScreen------------")
	local result,jsonResult =luaj.callStaticMethod(javaPCCommHelperClsName, "isNotchInScreen",{ {} }, PCSdkHelper.defaultAndroidSign);
	echo("PCSdkHelper:checkIsNotchInScreen:",tostring(jsonResult),tostring(result))
	if result then
		if jsonResult =="1" then
			return true
		end
		return false
	end
	return false
end

-- 获取sdcard根路径
function PCSdkHelper:getSdcardRootPath()
	local sdcardRootPath = ""
	local functionName = "getSdcardRootPath"
	local params = {}

	if self.sdcardRootPath then
		return self.sdcardRootPath
	end

	if device.platform == PLANTFORM_ANDROID then
		result,sdcardRootPath = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end

	if sdcardRootPath then
		self.sdcardRootPath = sdcardRootPath
	end

	return sdcardRootPath
end

-- 获取包名称
function PCSdkHelper:getPackageName()
	local packageName = ""
	local functionName = "getPackageName"
	local params = {}

	if self.packageName then
		return self.packageName
	end

	if device.platform == PLANTFORM_ANDROID then
		result,packageName = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end

	if packageName then
		self.packageName = packageName
	end

	return packageName
end

-- 获取Android TargetSdkVesion
function PCSdkHelper:getTargetSdkVersion()
	local packageName = ""
	local functionName = "getTargetSdkVersion"
	local params = {}

	if self.targetSdkVersion then
		return self.targetSdkVersion
	end

	if device.platform == PLANTFORM_ANDROID then
		result,targetSdkVersion = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
	end

	if targetSdkVersion then
		self.targetSdkVersion = targetSdkVersion
	end

	return targetSdkVersion
end

-- 判断文件是否存在
function PCSdkHelper:isFileExist(filePath)
	if device.platform == PLANTFORM_ANDROID then
		local functionName = "isFileExist"
		local params = {
			filePath = filePath
		}

		local findRt = "0"

		result,findRt = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PCSdkHelper.defaultAndroidSign);
		
		if findRt == "1" then
			return true
		else
			return false
		end
	else
		local isExist = cc.FileUtils:getInstance():isFileExist(filePath)
		return isExist
	end
end

return PCSdkHelper
