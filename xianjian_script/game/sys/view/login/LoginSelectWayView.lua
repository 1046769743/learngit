local LoginSelectWayView = class("LoginSelectWayView", UIBase)

function LoginSelectWayView:ctor(winName,doAutoLogin)
	LoginSelectWayView.super.ctor(self, winName)
	-- 是否执行自动登录
	self.doAutoLogin = doAutoLogin

	echo("mostsdk-login LoginSelectWayView self.doAutoLogin=",self.doAutoLogin)
end

function LoginSelectWayView:loadUIComplete()
	self:initView()
	self:setViewAlign()
	self:registEventListeners()
	self:registerEvent()
	self:updateUI()

	-- 检查执行登录逻辑
	self:checkShowLoginViewOrAudoLogin()

	--登录主界面打点
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ActionConfig.login_main_view);
end

function LoginSelectWayView:initView()
	self.btnGuestLogin = self.btn_guest_login
	self.btnAccountLogin = self.btn_account_login

	self.btnGuestLogin:setVisible(false)
	self.btnAccountLogin:setVisible(false)

	-- touch层
	self.ctn_touch:setContentSize(cc.size(GameVars.width,GameVars.height))
	self.ctn_touch:pos(0,-GameVars.height)
	self.ctn_touch:setTouchedFunc(c_func(self.onLoginTap, self))
end

function LoginSelectWayView:onLoginTap()
	local curTime = TimeControler:getServerTime()
	if self.lastTapTime == nil or (curTime - self.lastTapTime) > 1 then
		self:onAccountLoginTap()
		self.lastTapTime = curTime
	end
end

-- 注册点击事件
function LoginSelectWayView:registerEvent()
	self.btnAccountLogin:setTap(c_func(self.onAccountLoginTap, self))
	self.btnGuestLogin:setTap(c_func(self.onGuestLoginTap, self))

	-- 如果是SDK登录,隐藏试玩按钮
	if LoginControler:isLoginSdkActive() then
		self.btnGuestLogin:setVisible(false)
	end
end

-- 注册监听事件
function LoginSelectWayView:registEventListeners()
	-- 2018.05.23 废弃代码暂时注释
	-- EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onModelUpdateEnd, self)
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_SUCCESS, self.onLoginOk,self )
    EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_FAIL, self.onLoginFail,self )
    -- 账号登录成功&获取服务器列表成功
	EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK, self.onAutoLoginCallBack, self)
	-- 2018.05.23 废弃代码暂时注释
	-- EventControler:addEventListener(LoginEvent.LOGINEVENT_SHOW_SELECT_WAY, self.showSelectView, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_SELECT_ZONE_FAIL, self.onSelectZoneFail, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_FAIL, self.onGetServerListFail, self)
end

--[[
	登录/自动登录逻辑
]]
function LoginSelectWayView:checkShowLoginViewOrAudoLogin()
	echo("\n\n============= checkShowLoginViewOrAudoLogin=",LoginControler:isSwitchAccount(),LoginControler:isSwitchZone())
	if DEBUG_SKIP_AUTO_LOGIN then
		self:showSelectView()
		return
	end

	if LoginControler:isSwitchAccount() then
		self:showSelectView()
		return
	end

	echo("LoginSelectWayView isLogin=",LoginControler:isLogin())
	
	if not LoginControler:isLogin() then
		echo("\n\n============ LoginControler:getLoginCount()===",LoginControler:getLoginCount(),LoginControler:checkAutoLogin())

		-- 修改灰度服登录及切换相关修改 by ZhangYanguang 2018.01.18
		--只有第一次进客户端时才自动登录
		if LoginControler:getLoginCount() <= 1 then
			if LoginControler:checkAutoLogin() then
				self.isAutoLogin = true
				LoginControler:tryAutoLogin()
			else
				self:showSelectView()
			end
		else
			self:showSelectView()
		end
	else
		if LoginControler:isSwitchZone() then
			self:startHide()
			WindowControler:showWindow("LoginEnterGameView",true)
		end
	end
end

--[[
	选择登录方式
]]
function LoginSelectWayView:showSelectView()
	WindowControler:closeWindow("LoginEnterGameView")
	self.btnGuestLogin:setVisible(true)
	self.btnAccountLogin:setVisible(true)
	-- 如果是SDK登录,隐藏试玩按钮
	if LoginControler:isLoginSdkActive() then
		self.btnGuestLogin:setVisible(false)
	end

	echo("mostsdk self.doAutoLogin=",self.doAutoLogin)
	if self.doAutoLogin then
		-- 不延迟一帧，pc平台按钮显示有问题(发白，且能触发事件)
		if device.platform == "windows" or device.platform == "mac"  then
			self:delayCall(c_func(self.onLoginTap,self),1 / GameVars.ARMATURERATE)
			-- self:onLoginTap()
		else
			self:onLoginTap()
		end
	else
		echo("mostsdk-skip login")
	end
end

function LoginSelectWayView:onAccountLoginTap()
	-- WindowControler:showWindow("LoginView")
	echo("mostsdk-onAccountLoginTap----1")
	LoginControler:showLoginView()
end

--试玩
function LoginSelectWayView:onGuestLoginTap()
	if LoginControler:isLoginSdkActive() then
		LoginControler:showLoginView()
		return
 	end

	LoginControler:guestLogin()
end

function LoginSelectWayView:updateUI()
	
end

function LoginSelectWayView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_guest_login,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_account_login,UIAlignTypes.MiddleBottom) 
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_lxy,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_txt,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg, UIAlignTypes.MiddleBottom)
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_bg.scale9_1,UIAlignTypes.MiddleBottom, 1, 0)
end

--[[ 2018.05.23 废弃代码暂时注释
function LoginSelectWayView:onModelUpdateEnd()
	echo("LoginSelectWayView========================================onModelUpdateEnd----------------------------------------")
	self:startHide()
	
	if UserExtModel:hasInited() then
		LoginControler:enterGameHomeView()
	else
		--游客登录后没有初始化
		LoginControler:showLoginSelectRoleView()
	end
end
]]

--[[
	当账号登录成功
]]
function LoginSelectWayView:onAutoLoginCallBack()
	if self.isAutoLogin then
		echo("\n=============== 自动登录 ===============")
		if LoginControler:isSwitchZone() then
			self:startHide()
			WindowControler:showWindow("LoginEnterGameView",true)
		else
			LoginControler:doEnterGameRequest(self)
		end
	else
		echo("\n=============== 非自动登录 ===============")
		self:startHide()
		WindowControler:showWindow("LoginEnterGameView")
	end
end

--[[
	选服失败
]]
function LoginSelectWayView:onSelectZoneFail()
	self:startHide()
	WindowControler:showWindow("LoginEnterGameView")
end

--[[
	获取服务器列表失败
]]
function LoginSelectWayView:onGetServerListFail()
	self:onSelectZoneFail()
end

--[[
	账号登录成功
]]
function LoginSelectWayView:onLoginOk(event)
	local loginType = LoginControler:getLocalLoginType()
	local lastLoginType = LS:pub():get(StorageCode.last_login_type, "")
    LoginControler:setLastLoginType(LoginControler:getLocalLoginType())

	if lastLoginType == "" then return end
	local showBindingView = false
	if lastLoginType == LoginControler.LOGIN_TYPE.GUEST then
		if loginType == LoginControler.LOGIN_TYPE.GUEST then
			showBindingView = true
		end
	end
end

--[[
	账号登录失败
]]
function LoginSelectWayView:onLoginFail()
	echo("mostsdk-登录及获取服务器列表失败")
	-- self:showSelectView()
end

return LoginSelectWayView

