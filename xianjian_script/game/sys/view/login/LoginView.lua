local LoginView = class("LoginView", UIBase)

function LoginView:ctor(winName)
	LoginView.super.ctor(self, winName)
	self:initData()
	self.current_is_registing = false
end

function LoginView:loadUIComplete()
	self:registClickClose("out")
	
	self:registerEvent()
	self:setViewAlign()
	self:initView()
	self:updateUI()
end

function LoginView:initView()
	self.forgetPassTxt = self.mc_info.currentView.txt_4
	if self.forgetPassTxt then
		-- TODO 忘记密码功能暂时不支持
		self.forgetPassTxt:setVisible(false)
	end
	self.mc_info:getViewByFrame(1).UI_di.txt_1:setString(GameConfig.getLanguage("tid_login_1065")) 
	self.mc_info:getViewByFrame(2).UI_di.txt_1:setString(GameConfig.getLanguage("tid_login_1066"))

	self.mc_info:getViewByFrame(1).UI_di.mc_1:setVisible(false)
	self.mc_info:getViewByFrame(2).UI_di.mc_1:setVisible(false)
end

function LoginView:updateUI()
	self:setUserNameAndPass(self.username, self.password)
end

function LoginView:setUserNameAndPass(username, password)
	local infoView = self.mc_info.currentView
	infoView.input_name:setText(username)
	infoView.input_password:setText(password)
	if infoView.input_password2 then
		infoView.input_password2:setText(password)
	end
end

function LoginView:initData()
	self.username = LS:pub():get(StorageCode.username ,"")
    self.password = LS:pub():get(StorageCode.userpassword ,"")
end

function LoginView:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
end

function LoginView:registerEvent()
	self.mc_info:getViewByFrame(1).UI_di.btn_close:setTap(c_func(self.onBackTap, self))
	self.mc_info:getViewByFrame(2).UI_di.btn_close:setTap(c_func(self.onBackTap, self))
	self.mc_info:getViewByFrame(1).btn_login:setTap(c_func(self.onLoginTap, self))
	self.mc_info:getViewByFrame(1).btn_register:setTap(c_func(self.onRegistTap, self))
	self.mc_info:getViewByFrame(2).btn_register:setTap(c_func(self.beginRegist, self))
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_SUCCESS, self.onLoginOk, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_GET_SERVER_LIST_OK, self.onGetServerList, self)
	-- 同意协议
    EventControler:addEventListener(LoginEvent.LOGINEVENT_ON_AGREE, self.onConfirmAgreement, self)
end

function LoginView:onBackTap()
	if self.current_is_registing then
		self.mc_info:showFrame(1)
		self.current_is_registing = false
	else
		self:startHide()
	end
end

function LoginView:onLoginOk()
    LS:pub():set(StorageCode.username, self.username)
    LS:pub():set(StorageCode.userpassword, self.password)
end

function LoginView:onGetServerList()
	self:startHide()
end

--登入
function LoginView:onLoginTap()
	local infoView = self.mc_info.currentView
	self.username = infoView.input_name:getText()
	self.password = infoView.input_password:getText()
	if not self:checkUserNameOrPassword(self.username, self.password,true) then
		return
	end

	-- 是否是sdk登录
	if LoginControler:isLoginSdkActive() then
		LoginControler:doSdkLogin()
	else
		LoginControler:doLogin(self.username, self.password)
	end
end

--点击登录旁边的注册按钮
function LoginView:onRegistTap()
	self.current_is_registing = true
	self.mc_info:showFrame(2)
	self:setUserNameAndPass(self.username, self.password)

	self.isAgree = true
	local infoView = self.mc_info.currentView
	self.panelDot = infoView.panel_user_agreement.panel_dot

	self.panelDot:setVisible(self.isAgree )
	-- 是否同意协议
	infoView.panel_user_agreement.panel_1:setTouchedFunc(c_func(self.onAgreeTap,self))
	infoView.panel_user_agreement.txt_3:setTouchedFunc(c_func(self.showAgreement,self))
end

function LoginView:onAgreeTap()
	self.isAgree = not self.isAgree
	self.panelDot:setVisible(self.isAgree)
end

function LoginView:onConfirmAgreement()
	self.isAgree = true
	self.panelDot:setVisible(self.isAgree)
end

function LoginView:showAgreement()
	WindowControler:showWindow("GameAgreementView")
end

function LoginView:checkUserNameOrPassword(username, password,isLogin)
    if not username or username=="" then 
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1001"))
        return false
    else
    	-- TODO 之后登录也要做这个检查
    	-- if not isLogin then
    	if true then
    		--检查名字
			local nameIsOk, nameOkTip = FuncAccountUtil.checkAccountName(username)
			if not nameIsOk then
				WindowControler:showTips(nameOkTip)
				return false
			end
    	end
    end

    if not password or password == "" then
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1002"))
        return false
    end

    -- TODO 之后登录也要做这个检查
    -- if not isLogin then
    if true then
    	--检查密码长度
		local passOk, passOkTip = FuncAccountUtil.checkAccountPassword(password) 
		if not passOk then
			WindowControler:showTips(passOkTip)
			return false
		end
    end
    
	return true
end

--开始注册
function LoginView:beginRegist()
	local msgTip = ""
	if not self.isAgree then
		-- 请勾选下方的用户协议
		msgTip = GameConfig.getLanguage("tid_login_1037")
		WindowControler:showTips(msgTip)
		return
	end

	local infoView = self.mc_info.currentView
    local username = infoView.input_name:getText()
    local password = infoView.input_password:getText()
    local repassword = infoView.input_password2:getText()

    if password ~= repassword then
    	-- 两次密码输入不相同，请重新输入
    	msgTip = GameConfig.getLanguage("tid_login_1043")
    	WindowControler:showTips(msgTip)
    	return
    end

	if not self:checkUserNameOrPassword(username, password) then
		return
	end

	self.username = username
	self.password = password
    LoginControler:doRegister(username, password, c_func(self.onRegistOk, self))
end

function LoginView:onRegistOk(serverData)
	echo("doRegister the response data is:")
	if serverData and type(serverData) == "table" then
		echo(json.encode(serverData))
	end
	
	local errorData = serverData.error
	if errorData then
		if errorData.code == 20101 then
			WindowControler:showTips(GameConfig.getLanguage("tid_login_1034"))
		end
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1006"))
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_REGIST_OK)
		LoginControler:setToken(nil)
		LoginControler:removeServerListCache()
		self.mc_info:showFrame(1)

		LS:pub():set(StorageCode.username ,self.username)
		LS:pub():set(StorageCode.userpassword ,self.password)
		LS:pub():set(StorageCode.login_last_server_id, "")

		LogsControler:saveUserInfo( self.username,self.password )

		self:setUserNameAndPass(self.username, self.password)
	end
end

return LoginView

