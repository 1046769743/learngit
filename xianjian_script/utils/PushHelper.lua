--
-- Author: ZhangYanguang
-- Date: 2018-03-13
-- 通知Push工具类

PushHelper = {}

local PLANTFORM_ANDROID = "android"
local PLANTFORM_IOS = "ios"

local javaPCCommHelperClsName = PCSdkHelper.javaPCCommHelperClsName
local ocPCCommHelperClsName = PCSdkHelper.ocPCCommHelperClsName

PushHelper.defaultAndroidSign = PCSdkHelper.defaultAndroidSign

-- 体力领取模板
local spTempMap = {
	-- 设置本地消息类型，1:通知，2:消息
	type = "1",
	-- 设置消息标题
	title = "体力通知",
	-- 设置消息内容
	content = "体力满了，快回六界战斗吧2",
	-- 设置消息日期，格式为：20140502
	date = "20180313",
	-- 设置消息触发的小时(24小时制)，例如：22代表晚上10点
	hour = "18",
	-- 获取消息触发的分钟，例如：05代表05分
	min = "10",
	-- 设置动作类型：1打开activity或app本身，2打开浏览器，3打开Intent ，4通过包名打开应用
	actType = "1",
}

local isInit = false

function PushHelper:init()
	self:registerEvent()
	self:initCommonPushTag()
end

function PushHelper:registerEvent()
	-- TODO 后期如果需要计算的变化类通知较多，考虑修改方案
	-- 体力变化时重新注册本地通知
	-- EventControler:addEventListener(UserEvent.USEREVENT_SP_CHANGE
	-- 	,self.registerLocalNotices, self)

	-- 2018.06.11 因性能问题，按钮开关切换状态不实时更新tag
	-- EventControler:addEventListener(SettingEvent.SETTINGEVENT_PUSH_SETTING_CHANGE,self.updatePushTag,self)
end

function PushHelper:registerLocalNotices()
	self:clearLocalNotices()

	-- 测试代码
	-- local noticeMap = {
	-- 	type = "1",
	-- 	title = "体力通知",
	-- 	content = "测试点击回调",
	-- 	date = "20180314",
	-- 	hour = "17",
	-- 	min = "26",
	-- 	actType = "1",
	-- }

	-- local openSpNotice = LS:prv():get(StorageCode.setting_notice_maxsp, "1") == "1"
	-- echo("TPush openSpNotice=",openSpNotice)

	-- if openSpNotice then
	-- 	self:registerOneLocalNotification(noticeMap)
	-- end
	
	self:registerSPFullNotices()
	-- self:updatePushTag()
end

function PushHelper:registerTagNotices()
	self:updatePushTag()
end

function PushHelper:registerSPFullNotices()
	-- 判断是否登录了
	local isLogin = LoginControler:isLogin()
	if not isLogin then
		return
	end

	local openSpNotice = LS:prv():get(StorageCode.setting_notice_maxsp, "1") == "1"
	-- 如果体力未满
	-- if true then
	if openSpNotice and not UserExtModel:checkIsMaxSp() then
		local time = TimeControler:getTime()
		local leftTime = UserExtModel:getFullSPLeftTime()
		local fullTime = time + leftTime

		local date = os.date("%Y%m%d",fullTime)
		local year = os.date("%Y",fullTime)
		local month = os.date("%m",fullTime)
		local day = os.date("%d",fullTime)

		local hour = os.date("%H",fullTime)
		local min = os.date("%M",fullTime)

		local spMap = table.copy(spTempMap)
		spMap.date = date
		spMap.hour = hour
		spMap.min = min
		-- iOS专用
		if device.platform == PLANTFORM_IOS then
			spMap.year = year
			spMap.month = month
			spMap.day = day
		end
		
		-- "体力已满"
		spMap.title = GameConfig.getLanguage("#tid_playerInfo_015") 
		-- "体力已经恢复满，赶快返回六界，继续探险吧"
		spMap.content = GameConfig.getLanguage("#tid_playerInfo_014")

		echo("TPush sp notice=",json.encode(spMap))
		self:registerOneLocalNotification(spMap)
	else
		echo("TPush 体力满或关闭了通知")
	end
end

-- 注册Push 本地通知
function PushHelper:registerOneLocalNotification(noticeMap)
	local functionName = "registerLocalNotification"

	echo("TPush notice=",json.encode(noticeMap))
	if device.platform == PLANTFORM_ANDROID then
		result = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {noticeMap}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,noticeMap)
	end
end

-- 清空所有本地通知
function PushHelper:clearLocalNotices()
	echo("TPush 清空local")
	local functionName = "clearLocalNotifications"
	local params = {}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	end
end

-- 判断权限
function PushHelper:isNotificationEnabled()
	local functionName = "isNotificationEnabled"
	local params = {}
	
	-- 默认是允许
	local isAllow = "1"
	if device.platform == PLANTFORM_ANDROID then
		result,isAllow = luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		-- 未实现(iOS SDK 没有对应接口)
	end

	echo("TPush isAllow=",isAllow)
	return isAllow == "1"
end

-- 初始化通用Push tag
function PushHelper:initCommonPushTag()
	-- 平台
	local platform = AppInformation:getAppPlatform()
	self:setTag(platform)

	-- 设备类型
	-- if device.platform == PLANTFORM_ANDROID then
	-- 	self:setTag("android")
	-- elseif device.platform == PLANTFORM_IOS then 
	-- 	self:setTag("ios")
	-- end
end

function PushHelper:updatePushTag()
	echo("TPush 更新 tag..........")
	if not LoginControler:isLogin() then
		echo("TPush 更新 tag return")
		return
	end

	self:initCommonPushTag()

	local pushCfg = {
		{
			isOpen = LS:prv():get(StorageCode.setting_notice_world_answer, "1") == "1",
			tag = "SixAnswer"
		},

		{
			isOpen = LS:prv():get(StorageCode.setting_notice_getsp, "1") == "1" ,
			tag = "ReplenishPower"
		},

		{
			isOpen = LS:prv():get(StorageCode.setting_notice_guild, "1") == "1" and LoginControler:isLogin() and GuildModel:isInGuild() ,
			tag = "GuildBoss"
		},

		{
			isOpen = LS:prv():get(StorageCode.setting_notice_fairylandbattle, "1") == "1" ,
			tag = "CrossPeak"
		},

		{
			isOpen = LS:prv():get(StorageCode.setting_notice_guildactivity, "1") == "1" ,
			tag = "GuildGve"
		},
	}

	for i=1,#pushCfg do
		local isOpen = pushCfg[i].isOpen
		local tag = pushCfg[i].tag
		if isOpen then
			self:setTag(tag)
		else
			self:deleteTag(tag)
		end
	end
end

-- 设置Push tag
function PushHelper:setTag(tag)
	echo("TPush setTag=",tag)
	self:setPushTag(1,tag)
end

function PushHelper:deleteTag(tag)
	echo("TPush deleteTag=",tag)
	self:setPushTag(0,tag)
end

-- 设置Push tag
-- action:0 删除tag 1 设置tag
-- tag: 设置的tag内容
function PushHelper:setPushTag(action,tag)
	local functionName = "setPushTag"
	local params = {
		action = tostring(action),
		tag = tostring(tag)
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {params}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,params)
	end
end

-- 设置推送账号，设置成功后，可以针对特定账号进行消息推送
function PushHelper:setPushAccount(uname)
	-- test code
	if uname == nil then
		uname = "xianpro"
	end

	local functionName = "setPushAccount"
	local accountInfo = {
		account = uname
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {accountInfo}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		echo("setPushAccount uname=",uname)
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,accountInfo)
	end
end

function PushHelper:deletePushAccount(uname)
	-- test code
	if uname == nil then
		uname = "xianpro"
	end

	local functionName = "deletePushAccount"
	local accountInfo = {
		account = uname
	}

	if device.platform == PLANTFORM_ANDROID then
		luaj.callStaticMethod(javaPCCommHelperClsName, functionName, {accountInfo}, PushHelper.defaultAndroidSign);
	elseif device.platform == PLANTFORM_IOS then
		echo("deletePushAccount uname=",uname)
		luaoc.callStaticMethod(ocPCCommHelperClsName, functionName ,accountInfo)
	end
end

-- 性能测试
function PushHelper:test()
	-- local timeCfg = {
	-- 	{hour="08",min="10"},
	-- 	{hour="12",min="14"},
	-- 	{hour="18",min="20"},
	-- 	{hour="21",min="23"}
	-- }
	
	for i=1,2 do
		local pushMap = table.copy(spTempMap)
		local min = pushMap.min
		local newMin = tostring(tonumber(min) + i)
		pushMap.min = newMin

		self:registerOneLocalNotification(pushMap)
	end
end

return PushHelper
