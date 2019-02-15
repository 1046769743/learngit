local LoginBindingAccount = class("LoginBindingAccount", UIBase)

function LoginBindingAccount:ctor(winName, isBinding)
	LoginBindingAccount.super.ctor(self, winName)
	self.isBinding = isBinding
	self.userIsAgreed = true
end

function LoginBindingAccount:loadUIComplete()
	self.panelAgreement = self.panel_user_agreement

	if not self.isBinding then
		self.mc_content:showFrame(2)
		self.mc_content.currentView.txt_1:setString(GameConfig.getLanguage("tid_login_1038"))
        --//安卓平台
       if(device.platform == "android")then
             echo("-------------LoginBindingAccount:loadUIComplete-----------------------");
             self.mc_content.currentView.txt_1:setPositionY(self.mc_content.currentView.txt_1:getPositionY()+24);
       end
       self.mc_content.currentView.UI_1.txt_1:setString(GameConfig.getLanguage("tid_login_1058")) 
	end

	self:onConfirmAgreement()

	self:registerEvent()
end

function LoginBindingAccount:registerEvent()
	local bindingView = self.mc_content:getViewByFrame(1)
	bindingView.btn_confirm:setTap(c_func(self.beginBinding, self))
	bindingView.panel_user_agreement.txt_3:setTouchedFunc(c_func(self.showAgreement,self))
	bindingView.panel_user_agreement.panel_1:setTouchedFunc(c_func(self.onAgreeTap,self))

	bindingView.UI_1.btn_close:setTap(c_func(self.close, self))
	bindingView.UI_1.mc_1:setVisible(false)

	local waringView = self.mc_content:getViewByFrame(2)
	waringView.btn_cancel:setTap(c_func(self.close, self))
	waringView.btn_gobinding:setTap(c_func(self.goBinding, self))
	waringView.panel_user_agreement.txt_3:setTouchedFunc(c_func(self.showAgreement,self))
	waringView.panel_user_agreement.panel_1:setTouchedFunc(c_func(self.onAgreeTap,self))

	waringView.UI_1.btn_close:setTap(c_func(self.close, self))
	waringView.UI_1.mc_1:setVisible(false)

	EventControler:addEventListener(LoginEvent.LOGINEVENT_BIND_ACCOUNT_SUCCESS, self.onBindSuccess, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_BIND_ACCOUNT_FAIL, self.onBindFail, self)
	-- 同意协议
    EventControler:addEventListener(LoginEvent.LOGINEVENT_ON_AGREE, self.onConfirmAgreement, self)
end

function LoginBindingAccount:onAgreeTap()
	self.isAgree = not self.isAgree
	local panelDot = self.mc_content.currentView.panel_user_agreement.panel_dot
	panelDot:setVisible(self.isAgree)
end

function LoginBindingAccount:showAgreement()
	WindowControler:showWindow("GameAgreementView")
end

function LoginBindingAccount:onConfirmAgreement()
	self.isAgree = true
	local panelDot = self.mc_content.currentView.panel_user_agreement.panel_dot
	panelDot:setVisible(self.isAgree)
end

-- 绑定成功
function LoginBindingAccount:onBindSuccess()
	WindowControler:showTips(GameConfig.getLanguage("tid_login_1009"))

	LoginControler:setLocalLoginType(LoginControler.LOGIN_TYPE.ACCOUNT)
	-- 绑定成功后，修改上次登录类型 by ZhangYanguang
	LoginControler:setLastLoginType(LoginControler.LOGIN_TYPE.ACCOUNT)

	LS:pub():set(StorageCode.username, self.name)
	LS:pub():set(StorageCode.userpassword, self.pass)

	EventControler:dispatchEvent(LoginEvent.LOGINEVENT_GUEST_BINDING_SUCCESS)
	self:close()
end

-- 绑定失败
function LoginBindingAccount:onBindFail(event)
	local serverData = event.params
	local errorData = serverData.error
	if errorData then
		if errorData.code == 20101 then
			WindowControler:showTips(GameConfig.getLanguage("tid_login_1034"))
		end
	end
end

function LoginBindingAccount:beginBinding()
	local bindingView = self.mc_content:getViewByFrame(1)
	local inputUserName = bindingView.input_name
	local inputPassword = bindingView.input_password
	local inputPasswordConfirm = bindingView.input_password_confirm
	local name = inputUserName:getText() 

	if not self.isAgree then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1012"))
		return
	end
	
	if name == "" then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1013"))
		return
	end	
	--检查名字
	local nameIsOk, nameOkTip = FuncAccountUtil.checkAccountName(name)
	if not nameIsOk then
		WindowControler:showTips(nameOkTip)
		return
	end

	local pass = inputPassword:getText() 
	local pass_confirm = inputPasswordConfirm:getText() 
	if  pass == "" or pass_confirm == "" then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1002"))
		return
	end
	if pass ~= pass_confirm then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1008"))
		return
	end
	--检查密码长度
	local passOk, passOkTip = FuncAccountUtil.checkAccountPassword(pass) 
	if not passOk then
		WindowControler:showTips(passOkTip)
		return
	end
	if not self.userIsAgreed then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1012"))
		return
	end
	self.name = name
	self.pass = pass
	LoginControler:bindAccount(name, pass)
end

function LoginBindingAccount:goBinding()
	if not self.isAgree then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1012"))
		return
	end

	self.isBinding = true
	self.mc_content:showFrame(1)  
	self.mc_content.currentView.UI_1.txt_1:setString(GameConfig.getLanguage("tid_login_1059"))
	self.mc_content.currentView.panel_user_agreement.panel_dot:visible(self.userIsAgreed)
end

function LoginBindingAccount:close()
	self:startHide()
end

return LoginBindingAccount

