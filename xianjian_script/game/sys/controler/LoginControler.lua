--
-- Author: xd
-- Date: 2015-11-24 19:01:12
--
local LoginControler={
	_login_count = 0,
}

LoginControler._token = nil 
LoginControler._uname = nil
LoginControler.MAX_HISTORY_SERVERS = 10

LoginControler.SERVER_STATUS = {
	NORMAL = 1,
	MAINTAIN = 2, 
	CLOSE = 3,
}

-- 服务器显示状态
LoginControler.SERVER_DISPLAY_STATUS = {
	NEW = 1,
	HOT = 2, 
	MAINTAIN = 3,
	CLOSE = 4,
}


-- 选角类型
LoginControler.SELECT_ROLE_TYPE = {
	GUILD ="guild",			--新手引导
	LOGIN = "login"			--登录
}

LoginControler.LOGIN_TYPE = {
	ACCOUNT ="account",
	GUEST = "guest"
}

--服务器信息 
LoginControler._serverInfo = {
	id = "dev",
	name = "内网测试服1",
	link ="172.16.110.249:9091",
	status = 1
}

-- 公告类型
LoginControler.GONGGAO_TYPE = {
	LOGIN = 1,
	HOME = 2,
	MAINTAIN = 3
}

function LoginControler:init()
	if(not DEBUG_SERVICES) then 
		EventControler:addEventListener(LoginEvent.SERVEREVENT_INIT_SUCCESS,LoginControler.onSelectZoneSuccess, LoginControler)
		EventControler:addEventListener(LoginEvent.SERVEREVENT_INIT_FAIL,LoginControler.onSelectZoneFail, LoginControler)
	end
	
end

-- {
-- 		id = "dev",
-- 		name ="内网测试服1",
-- 		status = 1,
-- 		link ="172.16.110.249:9091" 
-- }
function LoginControler:tryAutoLogin()
	local lastLoginType = LS:pub():get(StorageCode.last_login_type)
	if lastLoginType == LoginControler.LOGIN_TYPE.ACCOUNT then
		if LoginControler:checkLocalAccountInfo() then
			--如果有账号信息，自动登录
			-- WindowControler:showTips("账号自动登录")
			LoginControler:autoLogin()
		end
	elseif lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
		if LoginControler:checkLocalGuestInfo() then
			-- WindowControler:showTips("游客账户，自动登录")
			LoginControler:guestLogin()
		else
			echoError("游客登录信息为空")
		end
	end
end

-- 检查是否自动登录
function LoginControler:checkAutoLogin()
	if DEBUG_SKIP_AUTO_LOGIN then
		return false
	end

	local lastLoginType = LS:pub():get(StorageCode.last_login_type)
	if lastLoginType == LoginControler.LOGIN_TYPE.ACCOUNT then
		if LoginControler:checkLocalAccountInfo() then
			local last_server_id = LS:pub():get(StorageCode.login_last_server_id)
			if last_server_id ~= "" and last_server_id~=nil then 
				return true
			end
		end
	elseif lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
		if LoginControler:checkLocalGuestInfo() then
			return true
		else
			echoError("游客登录信息为空")
		end
	end

	return false
end

--自动登录
function LoginControler:autoLogin()
	if self:isLoginSdkActive() then
		-- sdk自动登录，必须在sdk初始化成功后才可以执行
		return
	else
		local username = LS:pub():get(StorageCode.username ,"")
    	local password = LS:pub():get(StorageCode.userpassword ,"")
		self:doLogin(username, password)
	end
end

--登入入口
function LoginControler:doLogin(uname, upassword)
	echo("\n登录账号uname=",uname)
	self._currentLoginingType = LoginControler.LOGIN_TYPE.ACCOUNT
	self._uname = uname
	Server:setHasGetUserInfo(false)
	local params = {passport=uname, password = upassword,platformGroup =PLATFORM_LOGIN_GROUP or "pc"}
	local loginBack = c_func(self.doLoginBack, self)
	HttpServer:sendHttpRequest(params, MethodCode.user_login_205, 
		loginBack, nil, true, true)
end

-- ourpalm sdk login
function LoginControler:doSdkLogin()
	echo("mostsdk-HttpServer doSdkLogin--------------------------")
	self._currentLoginingType = LoginControler.LOGIN_TYPE.ACCOUNT

	local account_token = AppHelper:getValue(StorageCode.mostsdk_token)
	local channel_alias = AppHelper:getValue(StorageCode.mostsdk_channel_alias)
	echo("mostsdk-account_token=",account_token)
	echo("mostsdk-channel_alias=",channel_alias)

	local params = {
		account_token = account_token,
		device_id = AppInformation:getDeviceID(),
		channel_alias = channel_alias,
		serviceId = PCSdkHelper:getServiceId()
	}

	local loginBack = c_func(self.doLoginBack, self)
	HttpServer:sendHttpRequest(params, MethodCode.user_ourpalm_login_223, 
		loginBack, nil, true, true)
end

--登入返回
function LoginControler:doLoginBack(result)
	self:setIsWhiteAccount(false)
	echo("doLoginBack the response data is:")
	if result and type(result) == "table" then
		echo(json.encode(result))
	end

	if result.error then
		local tip = ServerErrorTipControler:checkShowTipByError(result.error)
		echo("mostsdk-doLoginBack error=",result.error)
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_FAIL)
		return
	end

	PushHelper:setPushAccount(self._uname)

	local data = result.result.data

	echo("mostsdk-登录成功，返回token=",data.loginToken)
	-- 设置token
	self:setToken(data.loginToken)

	-- 是否是白名单账号
	if data.isTestAccount and tonumber(data.isTestAccount) == 1 then
		self:setIsWhiteAccount(true)
	end

	self:addLoginCount()

	-- 获取服务器列表
	self:doGetServerList()

	Server:setHasGetUserInfo(false)
	self:setLocalLoginType(self._currentLoginingType)
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_SUCCESS)

	-- 账号登录成功，需要清空排队时间
	LoginControler:clearQueueTime()
end 

-- 设置是否是白名单账号
function LoginControler:setIsWhiteAccount(isWhiteAccout)
	self.isWhiteAccount = isWhiteAccout
end

-- 是否是白名单账号
function LoginControler:checkWhiteAccount()
	return self.isWhiteAccount
end

--退出登入
function LoginControler:logout()
	self:destroyData()
	Server:handleClose()
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOG_OUT)
end

--注册
function LoginControler:doRegister( uname,upassword ,call)
	if not call then
		call = GameVars.emptyFunc
	end

	HttpServer:sendHttpRequest({  passport=uname,password = upassword   },MethodCode.user_register_207, call, nil, true, true)
end

--获取服务器列表
function LoginControler:doGetServerList()
	local token = self:getToken()
	local params = {loginToken=token }

	echo("mostsdk-获取服务器列表1 doGetServerList token=",token)

	HttpServer:sendHttpRequest(params, MethodCode.user_serverList_211,c_func(self.getServerListBack, self), nil, true, true)
end

--获取服务器列表返回
function LoginControler:getServerListBack(result)
	echo("获取服务器列表成功getServerListBack")

	if result.error then
		echo("获取服务器列表失败")
		dump(result)
		--TODO 待处理比如token过期
		local tip = ServerErrorTipControler:checkShowTipByError(result.error)
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_GET_SERVER_LIST_FAIL)
		return
	end

	if result.result then
		-- 更新服务器时间
		if result.result.serverInfo then
			local serverTime = result.result.serverInfo.serverTime
			if serverTime then
				TimeControler:updateServerTime(serverTime)
			end
		end

		echo("设置服务器数据")
		self:setServerListData(result.result.data)
		self:onGetServerList()
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK)
	end
end

function LoginControler:onGetServerList()
	local serverList = LoginControler:getServerList()
	local history = LoginControler:getHistoryLoginServers(true)
	local id = VersionControler:getServerId()

	local info = nil
	local serverId = nil
	-- 有历史区服数据
	if #history > 0 then
		if id ~= nil and id ~= "" then
			-- 本地优先,获取上次登录的区信息
			info = self:getServerInfoById(id)
			serverId = id
		else
			--服务器数据优先
			serverId = history[1].sec
			info = self:getServerInfoById(serverId)
		end
	else
		info = self:getLatestOpenServer()
	end

	-- 修改灰度服登录及切换相关修改 by ZhangYanguang 2018.01.18
	-- if self:checkLastServerId(serverId) then
	
	-- 检查上次serverId是否合法(比如：某服被删除)
	-- 新建账号登录后，serverId为nil
	if serverId and not self:checkValidServerId(serverId) then
		echo("mostsdk-上次登录区服信息不一致，清空上次区服信息serverId=",serverId,#history)
		echo("mostsdk-",json.encode(history),info)

		self:clearLastServerInfo()
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_FAIL)
	end
	
	-- echo("LoginControler:onGetServerList-info")
	-- dump(info)
	LoginControler:setServerInfo(info)
end

--[[
	检查上次登录的serverId是否合法
	如果现在的服务器列表中没有，那么就是非法的
]]
function LoginControler:checkValidServerId(serverId)
	local serverList = LoginControler:getServerList()
	if serverList and #serverList > 0 then
		for i=1,#serverList do
			local info = serverList[i]
			if info and info._id == serverId then
				return true
			end
		end
	end

	return false
end

-- 检查服务器返回的最近登录的服务器信息与本地记录的是否一致
function LoginControler:checkLastServerId(serverId)
	local last_server_id = LS:pub():get(StorageCode.login_last_server_id)
	if last_server_id ~= "" and last_server_id~=nil then 
		if last_server_id ~= serverId then
			return true
		end
	end
	return false
end

function LoginControler:storeCurrentServerInfo()
	LS:pub():set(StorageCode.login_last_server_id, LoginControler:getServerId())
	LS:pub():set(StorageCode.login_last_server_index, LoginControler:getServerMark())
	LS:pub():set(StorageCode.login_last_server_name, LoginControler:getServerName())
end

-- 获取最新的区服
function LoginControler:getLatestOpenServer()
	local serverList = LoginControler:getServerList()
	local list = table.deepCopy(serverList)
	local sortByOpenTime = function(a, b)
		return tonumber(a.openTime) > tonumber(b.openTime)
	end
	table.sort(list, sortByOpenTime)
	return list[1]
end

function LoginControler:getServerInfoById(id)
	local serverList = LoginControler:getServerList()
	for _, info in pairs(serverList) do
		if tostring(info._id) == tostring(id) then
			return info
		end
	end

	return nil
end

function LoginControler:destroyData()
	self._token = nil
	self._uname = nil
	self._serverInfo = nil
	self._historyServers = nil
	self._roleHistoryServers = nil
	self._isLogin = false
	Server:setHasGetUserInfo(false)

	self._lastBattleId = nil
	self._lastPoolType = nil
end

-- 清空model
function LoginControler:clearModels()
	local skip_models = {"AudioModel"}
	for k,v in pairs(_G) do
		if string.find(k, "Model$") then
			if not table.find(skip_models, k) then
				_G[k] = nil
			end
		end
	end
	local model_path = "game.sys.model.init"
	package.loaded[model_path] = false
	require("game.sys.model.init")

	TimeControler:destroyData()
	WindowControler:clearGlobalDelay()
	--EventControler:clearAllEvent()
	--WindowControler:destroyData()
end

function LoginControler:addLoginCount()
	self._login_count = self._login_count + 1
end

function LoginControler:getLoginCount()
	return self._login_count
end

--loginType : guest or account
function LoginControler:setLocalLoginType(loginType)
	LS:pub():set(StorageCode.login_type, loginType)
end

function LoginControler:setLastLoginType(loginType)
	LS:pub():set(StorageCode.last_login_type, loginType)
end

function LoginControler:getLastLoginType()
	return LS:pub():set(StorageCode.last_login_type, "")
end

function LoginControler:getLocalLoginType()
	return LS:pub():get(StorageCode.login_type, "")
end

-- 获取区服显示状态
function LoginControler:getServerStatusKey(info)
	-- 优先判断开服时间
	--维护
	if tonumber(info.status) == self.SERVER_STATUS.MAINTAIN 
		or not self:checkServerOpenTime(info) then
		return self.SERVER_DISPLAY_STATUS.MAINTAIN
	-- 关闭状态
	elseif tonumber(info.status) == self.SERVER_STATUS.CLOSE then
		-- 目前关闭状态的UI显示，与维护状态相同
		return self.SERVER_DISPLAY_STATUS.CLOSE
	end

	--新开
	if info.new_open then
		-- 流畅状态
		return self.SERVER_DISPLAY_STATUS.NEW
	end

	--火爆
	return self.SERVER_DISPLAY_STATUS.HOT
end

-- 获取区服状态
function LoginControler:getServerStatus(info)
	-- 优先判断开服时间
	--维护
	if tonumber(info.status) == self.SERVER_STATUS.MAINTAIN 
		or not self:checkServerOpenTime(info) then
		return self.SERVER_STATUS.MAINTAIN 
	-- 关闭状态
	elseif tonumber(info.status) == self.SERVER_STATUS.CLOSE then
		-- 目前关闭状态的UI显示，与维护状态相同
		return self.SERVER_STATUS.CLOSE
	end

	return self.SERVER_STATUS.NORMAL
end

-- 判断区服是否是维护状态
function LoginControler:checkMaintianStatus(info)
	local status = self:getServerStatus(info)
	return status == self.SERVER_STATUS.MAINTAIN
end

--[[
	2018-01-06 by ZhangYanguang
	选区接口已经去掉
	Server init接口中会附带sec参数，实现选区功能
]]
function LoginControler:doSelectZone()
	local link = self:getServerLink()
	local tempArr = string.split(link, ":")
	ServiceData.IP = tempArr[1]
	ServiceData.PORT =  tempArr[2]
	Server:init()
end

-- 选服成功
function LoginControler:onSelectZoneSuccess()
	self._lastServerInfo = self._serverInfo
end

-- 选服失败
function LoginControler:onSelectZoneFail()
	echo("选服失败doSelectZoneBack error",self:checkQueueTime())
	-- 如果因排队导致选服失败
	if self:checkQueueTime() then
		-- 不做处理
	else
		WindowControler:globalDelayCall(c_func(self.doGetServerList,self), 0.1)
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_SELECT_ZONE_FAIL)
	end
end

--试玩登录
function LoginControler:guestLogin()
	local deviceId = AppInformation:getDeviceID()
	HttpServer:sendHttpRequest({deviceId=deviceId}, MethodCode.user_guest_login_217, c_func(self.onGuestLoginOk, self), nil, true, true)
end

function LoginControler:onGuestLoginOk(data)
	echo("onGuestLoginOk the response data is")
	dump(data)

	self._currentLoginingType = LoginControler.LOGIN_TYPE.GUEST
	self:doLoginBack(data)
end

-- 绑定账号
function LoginControler:bindAccount(passport, password)
	local did = AppInformation:getDeviceID()
	local params = {
		deviceId = did,
		passport = passport, 
		password = password,
	}

	HttpServer:sendHttpRequest(params, MethodCode.user_bind_account_219, c_func(self.onBindAccountCallBack, self), nil, true, true)
end

function LoginControler:onBindAccountCallBack(data)
	echo("onBindAccountCallBack the response data is")
	dump(data)
	if data and data.result then
		LS:pub():set(StorageCode.device_id, "")
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_BIND_ACCOUNT_SUCCESS)
	else
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_BIND_ACCOUNT_FAIL,data)
	end
end

function LoginControler:doConnectBack(result )
	echo("========================================LoginControler:doConnectBack========================================")
	if not Server:isGetUserInfo( ) then
		--请求用户信息
		self:doGetUserInfo()
	else --//否则是掉线后重新登录
        self:doGetUserDataAfterOffline();
--		if self._lastBattleId then
--			BattleControler:reConnectBattle(self._lastBattleId,self._lastPoolType)
--			self._lastBattleId = nil
--			self._lastPoolType = nil
--		end
	end
end

--获取用户信息
function LoginControler:doGetUserInfo()
	local tempFunc = function()
		Server:sendRequest({}, MethodCode.user_getUserInfo_301,nil)
	end
	WindowControler:globalDelayCall(tempFunc)
end

--离线之后重新联网获取用户信息
function LoginControler:doGetUserDataAfterOffline()
	Server:sendRequest({}, MethodCode.user_relogin_359, c_func(self.doReloginInfoBack, self))
	-- WindowControler:globalDelayCall(tempFunc)
end

function LoginControler:doReloginInfoBack(result )
	--如果有错误了 return
	-- dump(result.result,"重连返回360 数据",8)
	if result.error then
		return
	end
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_RELOGINBACK )
	--发一个消息出去 判断是否需要重连或者进入下一场战斗
	if result.result.data then
		--判断是否登入正常
		if result.result.data.user and result.result.data.user.userExt and result.result.data.user.userExt.loginTime then
			local loginTime = result.result.data.user.userExt.loginTime
			local lastLoginTime = result.result.data.user.userExt.lastLoginTime
			if not UserExtModel:checkLoginTime(lastLoginTime, loginTime ) then
				return
			end
		end

		LoginInfoControler:onBattleStatus(result.result.data,true)
	end
end

--获取用户信息返回
function LoginControler:doGetUserInfoBack( result )
	echo("\n===================获取用户信息返回 doGetUserInfoBack...")

	--如果有错误了
	if result.error then
		return
	end
	--强制在获取用户返回后才算登入才成功
	self._isLogin = true
	Server:setHasGetUserInfo(true)
	result = result.result
	--初始化更新跨天参数
	TimeControler:setOverDay(result)

	local data = result.data
	local userData = data.user

	if data.versionInfo then
		VersionControler:setVersionInfo( data.versionInfo )
	end


	self:initGameStaticData(data.configs)

	local dataMap = ServiceData:getModelToServerMap(  )
	for i,v in ipairs(dataMap) do
		if v.model == UserModel then
			UserModel:init(userData)
		else
			local model = v.model
			local keys = v.keys

			
			if not keys or  #keys == 0 then
				local tb = {}
				-- echo("=======model.__cname==========",model.__cname) 
				model:init(tb)

				if not UserModel._data[model.__cname] then
					UserModel._data[model.__cname] = tb
				end
			else
				local params = {}
				for ii,vv in ipairs(keys) do
					local tempArr = string.split(vv, ".")
					local data 

					if #tempArr == 1 then
						data = userData[tempArr[1]] or {}
						 userData[tempArr[1]] = data

					elseif #tempArr == 2 then
						data = userData[tempArr[1]][tempArr[2]] or {}
						userData[tempArr[1]][tempArr[2]] = data
					elseif #tempArr == 3 then
						data = userData[tempArr[1]][tempArr[2]][tempArr[3]] or {}
						userData[tempArr[1]][tempArr[2]][tempArr[3]] = data
					end
					-- echo(tempArr[1],"___aaaa__",vv,i)
					-- dump(data,"data")
					
					table.insert(params, data)
				end

				-- if v.keys[1] == "retrieveList" then
				-- 	local d = data.configs[v.keys[1]]
				-- 	userData[v.keys[1]] = d
				-- 	params[1] = d
				-- end

				model:init(unpack(params))
			end
			

		end
	end

	-- 必须在UserMode更新后调用 by ZhangYanguang
	LS:initPrv()
	PCSdkHelper:initBuglyUserinfo()
	-- 锁妖塔
	
	-- TowerMainModel:init({})
	
	--调试显示用户信息
	if DEBUG >0 then
		local scene = WindowControler:getCurrScene()
		scene:showUserInfo()
	end

	--所有model init 后执行
    UserModel:initPlayerPower();
	--登入完成后 初始化邮件
	-- MailServer:init()
	--登入完成以后请求下邮件
	MailServer:requestMail()



    --请求一下好友系统事件
    -- FriendServer:init();
    -- FriendServer:requestFriendApply();--请求好友申请列表
    -- FriendServer:requestFriendSp();--请求好友的体力赠送情况

    -- ChatServer:init();

    self:storeCurrentServerInfo()
	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE);

	-- 发送角色信息给sdk
	if UserExtModel:hasInited() then
		PCSdkHelper:sendUserInfo()
	else
		-- 先发送注册日志
		-- PCSdkHelper:sendUserInfo(true)
		-- PCSdkHelper:sendUserInfo()
		self:setIsNewRole(true)
	end

    -- LampServer:init()
    if data.status ~= nil then
	    if data.status.status ~= nil then
	    	--非空闲状态
			if data.status.status ~= LoginInfoControler.MatchingType.FREE then  
				--保存数据
				UserModel:saveLoginData(data)
			end	
			-- 重登走这里
			if data.status.status == LoginInfoControler.MatchingType.GVESCENE then
				GuildActMainModel:setReconnectionData(data)
			end
		end
	end
	ClientActionControler:sendLoginDataToWebCenter()

	--如果没有商店信息 那么 需要重新请求商店数据
	ShopModel:tryGetShopInfo()

	--打印没有处理的echoError
	WindowControler:globalDelayCall(FuncTranslate.echoNoHandleError, 1)
end

function LoginControler:initGameStaticData(staticData)
	GameStatic:mergeServerData(staticData)
end

function LoginControler:isLogin()
	return self._isLogin
end

--获取token 是用来判断 是否登入的标志
function LoginControler:getToken()
	return self._token
end

-- 设置token
function LoginControler:setToken(token)
	self._token = token
end

function LoginControler:getUname()
	return self._uname or ""
end

--设置服务器列表
function LoginControler:setServerListData(data)
	local list = data.secList

	if list == nil or #list == 0 then
		echo("服务器列表为空")
		return
	end

	local latest_index = nil
	local server_open_t = 0
	for index, info in pairs(list) do
		if tonumber(info.openTime) >= server_open_t then
			latest_index = index
			server_open_t = tonumber(info.openTime)
		end
	end

	list[latest_index].new_open = true
	self._serverList = list

	-- 过滤无效的服务器列表
	data.roleHistorys = self:getfilteredRoleServerList(data.roleHistorys)

	local history = data.roleHistorys or {}
	local sortByLogoutTime = function(a, b)
		local at = tonumber(a.logoutTime) or 0
		local bt = tonumber(b.logoutTime) or 0
		return at > bt
	end
	local keys = table.sortedKeys(history, sortByLogoutTime)
	local ret = {}

	for i=1,self.MAX_HISTORY_SERVERS do
		local key = keys[i]
		if key and history[key] then
			table.insert(ret, history[key])
		end
	end

	self._historyServers = ret
	self._roleHistoryServers = data.roleHistorys
end

-- 过滤掉无效的服务器列表
function LoginControler:getfilteredRoleServerList(roleSecList)
	local list = {}
	for secId,secInfo in pairs(roleSecList) do
		if self:isValidSec(secId) then
			list[secId] = secInfo
		end
	end

	return list
end

-- 判断是否合法的区服,区服Id在serverList中不存在即为非法的
function LoginControler:isValidSec(secId)
	for k,secInfo in pairs(self._serverList) do
		if secId == secInfo._id then
			return true
		end
	end

	return false
end

-- 获取历史区服列表
function LoginControler:getHistoryLoginServers(sorted)
	if sorted then
		return self._historyServers
	else
		return self._roleHistoryServers
	end
end

--获取服务器列表
function LoginControler:getServerList()
	return self._serverList
end

--[[
	检查服务器开服时间
	maintainEndTime:服务器维护结束时间 为0不处理该字段，>0 当前时间与其比较
	openTime:开服时间
	返回值：true 表示服务器开服中  false：表示服务器维护中
]]
function LoginControler:checkServerOpenTime(serverInfo)
	local isOpen = true

	if serverInfo == nil then
		return isOpen
	end

	-- 服务器时间
	local serverTime = TimeControler:getServerTime()
	-- echo("status=",serverInfo.status)
	-- echo("serverTime=",serverTime)
	-- echo("serverInfo.openTime=",serverInfo.openTime)
	-- echo("serverInfo.maintainEndTime=",serverInfo.maintainEndTime)

	if serverInfo.maintainEndTime then
		local maintainEndTime = serverInfo.maintainEndTime
		-- 维护中,还未开服
		if maintainEndTime > 0 and serverTime < maintainEndTime then
			isOpen = false
			return isOpen
		end
	end

	if serverInfo.openTime then
		local openTime = serverInfo.openTime
		-- 还没到开服时间
		if serverTime < openTime then
			isOpen = false
			return isOpen
		end
	end

	return isOpen
end

function LoginControler:removeServerListCache()
	self._serverList = nil
end

--设置当前的服务器信息
--[[
	id = "dev",
	"link" = "172.16.110.249:9091"
	"name" ="内网测试服",
	"status" ="状态"

]]
function LoginControler:setServerInfo(serverInfo )
	-- echo("\n\n--------------setServerInfo--------------")
	-- dump(serverInfo)
	-- 保存新选择的服务器版本列表
	if serverInfo then
		VersionControler:saveServerInfo(serverInfo)
	end
	
	self._lastServerInfo = self._serverInfo
	self._serverInfo = serverInfo

	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_CHANGEZONE)
end

function LoginControler:getLastServerInfo()
	return self._lastServerInfo
end

function LoginControler:getLastServerId()
	return self._lastServerInfo and self._lastServerInfo._id or nil
end

function LoginControler:getServerInfo()
	return self._serverInfo
end

--获取服务器的id
function LoginControler:getServerId()
	return self._serverInfo and self._serverInfo._id or nil
end

function LoginControler:getServerMark()
	return self._serverInfo and self._serverInfo.mark or nil
end

--获取服务器名字
function LoginControler:getServerName()
	return self._serverInfo and self._serverInfo.name or nil
end

function LoginControler:getServerMark()
	return self._serverInfo and self._serverInfo.mark or ""
end

--获取服务器的ip
function LoginControler:getServerLink()
	return self._serverInfo.link
end

--获取service 名称 根据id
function LoginControler:getServerNameById( id )
	for k,v in pairs(self._serverList) do
		if tostring(v._id) == tostring(id) then
			return v.name
		end
	end
	echo("____没有获取到区服:",id)
	return "no区服"
end

-- 检查本地账号信息
function LoginControler:checkLocalAccountInfo()
	if self:isLoginSdkActive() then
		return true
	end

	local username = LS:pub():get(StorageCode.username ,"")
    local password = LS:pub():get(StorageCode.userpassword ,"")
    if username~="" and password ~= "" then
    	return true
	end

	return false
end

function LoginControler:checkLocalGuestInfo()
	local loginType = self:getLocalLoginType()
	--local deviceId = LS:pub():get(StorageCode.device_id, "")
	local deviceId = AppInformation:getDeviceID()
	if deviceId ~= "" and loginType == "guest" then
		return true
	end
	return false
end

-- 展示主界面公告
function LoginControler:checkShowHomeGonggao()
	if DEBUG_SKIP_HOME_GONGGAO then
		return false
	end

	if not self.hasShowGonggao and not TutorialManager.getInstance():isHomeExistGuide() then
		return true
	end

	return false
end

-- 展示主城公告
function LoginControler:showHomeGonggao() 
	self.hasShowGonggao = true
	self:fetchGonggao(true)
end

-- 是否显示公告
function LoginControler:showGonggao() 
	if DEBUG_SKIP_LOGIN_GONGGAO or LoginControler:isSwitchZone() or LoginControler:isSwitchAccount() then
		return false
	end

	return true
end

-- 获取公告
function LoginControler:fetchGonggao(isHome)
	local params = {PlatId = AppInformation:getGroupAppPlatform()}
	local isMaintain = false
	local gonggaoType = LoginControler.GONGGAO_TYPE.LOGIN
	if isHome then
		gonggaoType = LoginControler.GONGGAO_TYPE.HOME
	end
	HttpServer:sendHttpRequest(params, MethodCode.get_notice_3101, c_func(self.onGonggaoBack, self,gonggaoType), nil, true, true)
end

-- 获取维护公告
function LoginControler:fetchMaintainGonggao()
	local params = {PlatId = AppInformation:getGroupAppPlatform()}
	local gonggaoType = LoginControler.GONGGAO_TYPE.MAINTAIN
	HttpServer:sendHttpRequest(params, MethodCode.get_maintain_notice_3103, c_func(self.onGonggaoBack, self,gonggaoType), nil, true, true)
end

function LoginControler:onGonggaoBack(gonggaoType,serverData)
	echo("onGonggaoBack the response data is")
	-- dump(serverData,"serverData----------")
	if serverData and serverData.error then
		dump(serverData,"获取公告失败")
	end

	if serverData.result and serverData.result.data then
		self._gonggao_has_show = true
		--暂时屏蔽公告报错 wk，后面广哥修改在打开，
		if gonggaoType == LoginControler.GONGGAO_TYPE.MAINTAIN then
			WindowControler:showWindow("GameGonggaoView", serverData.result.data,gonggaoType)
		elseif gonggaoType == LoginControler.GONGGAO_TYPE.LOGIN then
			-- dump(serverData.result.data,"serverData.result.data------")
			local noticeContent = serverData.result.data.NoticeContent
			if noticeContent and #noticeContent==0 then
				WindowControler:showTips("暂无公告")
				return
			end
			WindowControler:showWindow("NoticeMainView", serverData.result.data)
		end
	end
end

function LoginControler:isStartPlay()
 	return self._isStartPlay == true and true or false;
end

-- 加载游戏资源
function LoginControler:loadGameRes(callBack)
	GameLuaLoader:loadGameSysFuncs()
	GameLuaLoader:loadGameBattleInit()
	if callBack then
		callBack()
	end
	
	--告诉数据中心Loading完了
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ActionConfig.login_load_game_res);
end

-- dev环境保存区服版本号
function LoginControler:saveDevServerVersion()
	local serverInfo = self:getServerInfo()
	local versionInfo = serverInfo.version
	if versionInfo then
		local curVersionInfo = versionInfo[AppInformation:getUpgradePath()]
		if curVersionInfo ~= nil then
			local scriptVersion = curVersionInfo.version
			AppInformation:setDevVersion(scriptVersion)
		else
			echoError("区别列表数据异常")
		end
	end
end

-- 选服等请求,成功后更新model，进入游戏
function LoginControler:doEnterGameRequest(fromView)
	if not AppInformation:isReleaseMode() then
		self:saveDevServerVersion()
	end

    -- 进入游戏前，再次判断是否需要执行更新逻辑
	local targetVersion = VersionControler:getTargetServerVersion()
	local doCheck = VersionControler:doCheckByTargetVersion(targetVersion)

	echo("\n\n点击进入游戏,doCheckVersion targetVersion=",targetVersion,doCheck)
	if doCheck then
		if fromView then
			fromView:startHide()
		end
		-- TODO 自动登录过程
		self:reStartVms()
		return
	end

	--初次登录、切换服务服务器
	local serverId = LoginControler:getServerId()
	local lastServerId = LoginControler:getLastServerId()

	echo("\n\nserverId=",serverId)
	echo("lastServerId=",lastServerId)
	
	if tostring(serverId) ~= tostring(lastServerId) then
		if not LoginControler:getServerId() then
			return
		end
		Server:setHasGetUserInfo(false )
		LoginControler:doSelectZone()
		return
	end

	if Server:isGetUserInfo() then
		if fromView then
			fromView:startHide()
		end
		LoginControler:enterGameHomeView()
	else
		LoginControler:doSelectZone()
	end
end

-- 进入游戏主城
function LoginControler:enterGameHomeView()
	-- 是否走序章逻辑
	-- if PrologueUtils:showPrologue() then
	-- 	PrologueUtils:doPrologueLogic()
	-- 	return
	-- end

	-- TODO 临时状态功能已屏蔽
	-- 保存协议信息状态
	-- LoginControler:saveAgreementInfoStatus()

	if self.testQuickLogin  then
		self.testQuickLogin  = false
		return
	end
	
	TutorialManager:checkToOpenTurorial();
	--发个消息，进入游戏了
    EventControler:dispatchEvent(UserEvent.LOGIN_ENTER_GAME_RES_LOADING);
	self:resetData()

	if DEBUG_ENTER_SCENE_TEST and DEBUG_ENTER_WINDOW_TEST then
		display.getRunningScene():enterTestWindow()
	else
		LoginControler:checkIsFirstLogin()
		--商城红点特殊处理
		if LoginControler:getFirstLoginStatus() then
			LS:prv():set(StorageCode.enter_mallMainView, "0")
			RechargeModel:setRechargeRedPoint(true)
		else
			if tonumber(LS:prv():get(StorageCode.enter_mallMainView)) == 0  then
				RechargeModel:setRechargeRedPoint(true)
			else
				RechargeModel:setRechargeRedPoint(false)
			end			
	   	end

		-- WuXingTeamEmbattleView
		WindowControler:showWindow("WorldMainView");
	end

	self._isStartPlay = true;

	local closeLoading = function()
		LoginControler:closeLoginViews()
	end

	WindowControler:globalDelayCall(c_func(closeLoading), 1)
end

--判断是否是首日第一次登陆的逻辑
function LoginControler:checkIsFirstLogin()
	self.isFirstLogin = false
	local currentTime = TimeControler:getServerTime()
	local firstLoginTime = LS:prv():get(StorageCode.first_loginTime)
	if not firstLoginTime then
		LS:prv():set(StorageCode.first_loginTime, currentTime)		
		self.isFirstLogin = true
	else
		local refreshLeftTime = FuncCommon.byTimegetleftTime(firstLoginTime)
		if currentTime - firstLoginTime > refreshLeftTime then
			LS:prv():set(StorageCode.first_loginTime, currentTime)
			self.isFirstLogin = true
		end
	end
end

--获取是否是首次登陆的状态
function LoginControler:getFirstLoginStatus()
	return self.isFirstLogin
end
--[[
	切换账号逻辑：
	1.pc切换账号逻辑:直接重启lua栈
	2.Android sdk切换账号逻辑
		a.调用sdk的switchUser接口
		b.在切换账号成功回调保存token等数据到C++
		c.如果已登录角色，重启lua栈，从C++中获取token执行游戏层登录
		d.如果没有登录角色，直接执行游戏层登录
	3.iOS sdk切换账号逻辑
		a.调用sdk的switchUser接口
		b.在登录成功回调(掌趣iOS切换账号后没有切换成功回调，而是登录成功的回调)保存token等数据到C++
		c.如果已登录角色，重启lua栈，从C++中获取token执行游戏层登录
		d.如果没有登录角色，直接执行游戏层登录

	4.在sdk悬浮窗中切换账号逻辑同上
]]
function LoginControler:doSwitchAccount()
	echo("mostsdk-doSwitchAccount 切换账号")
	if self:isLoginSdkActive() then
		PCSdkHelper:switchUser()
	else
		-- 设置切换账号状态
		self:setIsSwitchAccount(true)
		self:restarGame()
	end
end

--[[
	注销账号逻辑:
	1.pc上直接重启游戏
	2.Android/iOS 先执行sdk注销功能，成功后重启游戏
]]
function LoginControler:doLogoutAccount()
	if self:isLoginSdkActive() then
		PCSdkHelper:logout()
	else
		self:restarGame()
	end
end

--[[
	设置快速启动游戏(跳过logo等)
]]
function LoginControler:setQuickRestart()
	AppHelper:setValue(StorageCode.login_is_quick_restart,"true")
end

-- 重启游戏
function LoginControler:restarGame()
	self:setQuickRestart()
	
	-- 清空在C++端记录的服务器数据
	VersionControler:clearServerInfo()
	LoginControler:logout()
	GameLuaLoader:clearModules(true)
end

-- 是否切换账号
function LoginControler:isSwitchAccount()
	return AppHelper:getValue(StorageCode.login_is_switch_acccount) ~= ""
end

-- 是否切换区服
function LoginControler:isSwitchZone()
	return false
end

--[[
	设置是否在切换账号中
]]
function LoginControler:setIsSwitchAccount(isSwitch)
	if isSwitch then
		AppHelper:setValue(StorageCode.login_is_switch_acccount,"true")
	else
		AppHelper:setValue(StorageCode.login_is_switch_acccount,"")
	end
end

--[[
	进入主城前重置相关数据
]]
function LoginControler:resetData()
	self:setIsSwitchAccount(false)
	PCSdkHelper:clearTokenData()
	AppHelper:setValue(StorageCode.login_is_quick_restart,"")
	-- 清空数据
	self.enterGameInfo = nil
end

-- 展示更新异常界面
function LoginControler:showLoginUpdateExceptionView(loadingView,code)
	WindowControler:showHighWindow("LoginUpdateExceptionView", loadingView ,code)
end

-- 是否显示账号升级按钮
function LoginControler:showAccountUp()
	-- TODO 屏蔽主城账号升级按钮 by ZhangYanguang
	if true then
		return false
	end

	local loginType = self:getLocalLoginType()
	-- local isShow = loginType == LoginControler.LOGIN_TYPE.GUEST and TutorialManager:isFinishForceGuide()
	local isShow = loginType == LoginControler.LOGIN_TYPE.GUEST
	return isShow
end

-- 保存新手引导时选择的角色ID
function LoginControler:setLocalRoleId(roleId)
	-- echo("保存角色ID=",roleId)
	LS:pub():set(StorageCode.login_select_role_id,roleId)

	-- 序章引导中选择了角色
	if PrologueUtils:showPrologue() then
		UserModel:setAvatar(roleId)
	end
end

-- 获取本地保存的角色ID
function LoginControler:getLocalRoleId()
	return LS:pub():get(StorageCode.login_select_role_id,"")
end

-- 重置角色ID
function LoginControler:resetLocalRoleId()
	self:setLocalRoleId("")
end

-- 请求服务器设置角色ID
function LoginControler:setRoleId(roleId,callBack)
	local defaultName = ""
	UserServer:setHero(roleId, defaultName,callBack);
end

function LoginControler:checkShowPlayerSetNicknameView()
	-- 如果关闭了新手引导且玩家昵称没有初始化
	if IS_CLOSE_TURORIAL and not UserModel:isNameInited() then
		WindowControler:showWindow("LoginSetNicknameView")
	end
end

function LoginControler:checkShowRoleInfo()
	local localRoleId = self:getLocalRoleId()
	return localRoleId == ""
end

function LoginControler:clearLastServerInfo()
	LS:pub():set(StorageCode.last_login_type,"")
	LS:pub():set(StorageCode.login_last_server_id,"")
end

function LoginControler:clearLastLoginInfo()
	LS:pub():set(StorageCode.last_login_type,"")
	LS:pub():set(StorageCode.login_last_server_id,"")
	LS:pub():set(StorageCode.username ,"")
    LS:pub():set(StorageCode.userpassword ,"")
end

function LoginControler:isLoginSdkActive()
	if device.platform == "windows" or device.platform == "mac"  then
		return false
	end

	if DEBUG_SKIP_LOGIN_SDK then
		return false
	end

	return true
end

--[[
	展示账号登录相关界面
]]
function LoginControler:showLoginView()
	-- echoError("1111")
	-- 如果是sdk登录
	if self:isLoginSdkActive() then
		echo("mostsdk-showLoginView=",LoginControler:isSwitchAccount())
		-- 如果是切换账号
		if LoginControler:isSwitchAccount() then
			echo("mostsdk-切换账号")
			LoginControler:doSdkLogin()
		else
			PCSdkHelper:login()
		end
	-- 非sdk登录
	else
		WindowControler:showWindow("LoginView")
	end
end

--[[
	注销后重新弹出登录界面
]]
function LoginControler:reLoginAfterLogout()
	WindowControler:closeWindow("LoginEnterGameView")
	WindowControler:showWindow("LoginSelectWayView")
	LoginControler:showLoginView()
end

-- 是否在登录界面中
function LoginControler:isInLoginView()
	return WindowControler:getWindow( "LoginLoadingView" ) ~= nil
			or WindowControler:getWindow( "LoginSelectWayView" ) ~= nil
			or WindowControler:getWindow( "LoginEnterGameView" ) ~= nil
end

--[[
	关闭登录相关界面
]]
function LoginControler:closeLoginViews()
	WindowControler:closeWindow("LoginEnterGameView")
	WindowControler:closeWindow("LoginSelectWayView")
	WindowControler:closeWindow("LoginLoadingView")
end

--重启vms
function LoginControler:reStartVms()
	-- 清空在C++端记录的服务器数据
	-- 不能清空，否则灰度版本有问题 by ZhangYanguang
	-- VersionControler:clearServerInfo()
	WindowControler:closeAllWindow()
	WindowControler:showWindow("LoginLoadingView")
end


--快速登入帐号一直到进入主城
function LoginControler:quickLoginByData( username,password)
	self:doLogin(username,password)	
	self.testQuickLogin = true
	--假定0.2秒
	WindowControler:globalDelayCall(c_func( self.doEnterGameRequest,self,false ),0.3 )

end

--[[
	保存维护状态，点击进入游戏信息
	1.第几次点击
	2.点击的时间戳
]]
function LoginControler:saveMaintianEnterGameInfo()
	if self.enterGameInfo == nil then
		self.enterGameInfo = {count=0,time=TimeControler:getServerTime()}
	else
		self.enterGameInfo.count = self.enterGameInfo.count + 1
		self.enterGameInfo.time = TimeControler:getServerTime()
	end
end

-- 维护状态检查是否刷新服务器列表
function LoginControler:checkRefreshServerList()
	if not self.enterGameInfo then
		return false
	end

	local count = self.enterGameInfo.count
	if count and tonumber(count) > 0 then
		local curTime = TimeControler:getServerTime()
		local time = self.enterGameInfo.time
		-- 最大30秒
		local maxInterval = 30
		local interval = math.min(math.ldexp(1,count),maxInterval)

		echo("count,interval=",count,interval)
		if curTime >= (time + interval) then
			return true
		end
		echo("不刷新服务器列表")
	end

	return false
end

--[[
	登录选角
]]
function LoginControler:showLoginSelectRoleView()
	WindowControler:showWindow("SelectRoleView",LoginControler.SELECT_ROLE_TYPE.LOGIN)
end

--[[
	登录界面是否显示协议信息
]]
function LoginControler:showAgreementInfo()
	local value = LS:pub():get(StorageCode.show_agreement_info,"0")
	return value == "0"
end

--[[
	保存协议信息展示状态
]]
function LoginControler:saveAgreementInfoStatus()
	if self:showAgreementInfo() then
		LS:pub():set(StorageCode.show_agreement_info,"1")
	end
end

--[[
	设置登录排队相关数据
]]
function LoginControler:setQueueData(queueData)
	self.queueData = table.copy(queueData)
	-- 等待的总秒数
	self.queueData.waitTotalSec = self.queueData.queueTime - TimeControler:getTime()
	-- 保存本地时间
	-- LS:pub():set(self:getServerId(),self.queueData.queueTime)
	self.queueTime = self.queueData.queueTime
	-- 排队时间对应的区服id
	self.queueServerId = self:getServerId()
end

function LoginControler:getQueueData()
	return self.queueData
end

function LoginControler:getQueueServerId()
	return self.queueServerId
end

--[[
	获取排队时间
]]
function LoginControler:getQueueTime()
	return self.queueTime
end

function LoginControler:clearQueueTime()
	echo("清空排队时间...")
	self.queueTime = nil
end

--[[
	检查是否在排队中
]]
function LoginControler:checkQueueTime()
	if not self.queueData then
		return false
	end

	echo("\n\n-----------self.queueTime=",self.queueTime)
	echo("TimeControler:getTime=",TimeControler:getTime())

	local queueTime = self.queueData.queueTime
	if queueTime and queueTime >= TimeControler:getTime() then
		return true
	end

	return false
end

function LoginControler:setIsNewRole(isNewRole)
	self.isNewRole = isNewRole
end

function LoginControler:checkIsNewRole()
	return self.isNewRole
end

LoginControler:init()

return LoginControler
