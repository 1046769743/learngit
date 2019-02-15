local LoginEnterGameView = class("LoginEnterGameView", UIBase)
local SERVER_STATUS_LANG = {
	{lang = "tid_login_1020", mark="[新开]"},
	{lang = "tid_login_1021", mark="[火爆]"},
	{lang = "tid_login_1022", mark="[维护]"},
	{lang = "tid_login_1025", mark="[关闭]"},
}

function LoginEnterGameView:ctor(winName,showServerList)
	LoginEnterGameView.super.ctor(self, winName)

	self.showServerList = showServerList

	-- 初始化区是否开启
	self.initServerOpen = nil
end

function LoginEnterGameView:loadUIComplete()
	-- AudioModel:playMusic("m_scene_start", true)
	self:initView()
	self:setViewAlign()
	self:registEventListeners()
	self:registerEvent()
	self:updateUI()
	
	self:showGonggao()
	
	-- 注册定时检查开服时间定时器
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
end

function LoginEnterGameView:initView()
	-- touch层
	self.ctn_touch:setContentSize(cc.size(GameVars.width,GameVars.height))
	self.ctn_touch:pos(0,-GameVars.height)
	self.ctn_touch:setTouchedFunc(c_func(self.onLoginTap, self))

	-- 如果是sdk登录，隐藏掉账号按钮(PC平台为切换账号方便而保留)
	if LoginControler:isLoginSdkActive() then
		self.panel_account.btn_1:setVisible(false)
	end

	-- TODO 隐藏协议按钮(最终需求确定后可以彻底删除协议相关内容)
	self.panel_account.btn_3:setVisible(false)

	self.loginLoadingView = WindowControler:getWindow("LoginLoadingView")
end

--[[
	点击空白区域执行登录逻辑
]]
function LoginEnterGameView:onLoginTap()
	local curTime = TimeControler:getServerTime()
	if self.lastTapTime == nil or (curTime - self.lastTapTime) > 1 then
		self:onEnterGameTap()
		self.lastTapTime = curTime
	end
end

-- 注册点击事件
function LoginEnterGameView:registerEvent()
	self.panel_1.btn_serverlist:setTap(c_func(self.onServerListTap, self))
	-- 进入游戏
	self.btn_1:setTap(c_func(self.onEnterGameTap, self))
	-- 账号
	self.panel_account.btn_1:setTap(c_func(self.onAccountTap,self))
	-- 公告
	self.panel_account.btn_2:setTap(c_func(self.onGongGaoTap,self))
	-- 协议
	self.panel_account.btn_3:setTap(c_func(self.onAgreementTap,self))
	-- 同意协议
	self.mc_1:setTouchedFunc(c_func(self.onConfirmAgreementTap, self))
	-- 声明
	self.txt_shengming:setTouchedFunc(c_func(self.onAgreementTap, self))

	-- 排队时间结束，自动登录
	EventControler:addEventListener(LoginEvent.LOGINEVENT_QUEUE_TIME_END
		,self.onEnterGameTap, self)
end

function LoginEnterGameView:showGonggao()
	if PrologueUtils:showPrologue() then
		return
	end

	if not LoginControler:showGonggao() then
		return
	end

	-- 弹出公告
	LoginControler:fetchGonggao()
end

function LoginEnterGameView:showAgreementInfo(visible)
	self.mc_1:setVisible(visible)
	self.txt_shengming:setVisible(visible)
	self.txt_shengming2:setVisible(visible)
end

-- 注册监听事件
function LoginEnterGameView:registEventListeners()
	EventControler:addEventListener(LoginEvent.LOGINEVENT_LOGIN_UPDATE_MODEL_COMPLETE, self.onModelUpdateEnd, self)
	EventControler:addEventListener(LoginEvent.LOGINEVENT_CHANGEZONE, self.onChangeZone, self)
	-- 同意协议
	EventControler:addEventListener(LoginEvent.LOGINEVENT_ON_AGREE, self.onConfirmAgreement, self)
	-- 选服失败
	EventControler:addEventListener(LoginEvent.LOGINEVENT_SELECT_ZONE_FAIL, self.onSelectZoneFail, self)
end

function LoginEnterGameView:updateUI()
	-- 默认选择协议
	self.mc_1:showFrame(2)
	self.isAgree = true
	self:setServerListBtn()

	-- TODO 屏蔽掉协议相关内容
	self:showAgreementInfo(false)
	--[[
	if LoginControler:showAgreementInfo() then
		self:showAgreementInfo(true)
	else
		self:showAgreementInfo(false)
	end
	]]
end

--[[
	当选服失败
]]
function LoginEnterGameView:onSelectZoneFail()
	echo("选服失败LoginEnterGameView")
	-- 恢复UI
	self:doLoginLoadingRecover()
end

--[[
	window 显示完毕
]]
function LoginEnterGameView:showComplete()
	LoginEnterGameView.super.showComplete(self)

	-- 打开服务器列表
	if self.showServerList then
		self:onServerListTap()
	end
end

-- 设置服务器列表按钮
function LoginEnterGameView:setServerListBtn()
	local btn = self.panel_1.btn_serverlist

	local serverId = LoginControler:getServerId()
	-- echo("\n\n-----------serverId=====",serverId)
	if not serverId then
		btn:setBtnStr('', "txt_1")
		btn:setBtnStr('', "txt_2")
		-- btn:getUpPanel().rich_servermark:setString("")
		btn:getUpPanel().txt_servermark:setString("")
	else
		local serverName = LoginControler:getServerName()
		-- %s服
		local msgTip = GameConfig.getLanguage("tid_login_1042")
		local serverMark = string.format(msgTip, LoginControler:getServerMark())
		btn:setBtnStr(serverMark, "txt_1")
		-- echo("setServerListBtn serverMark=",serverMark)

		local index = LoginControler:getServerStatusKey(LoginControler:getServerInfo())
		local lang = SERVER_STATUS_LANG[index].lang
		local statusMark = SERVER_STATUS_LANG[index].mark
		local str = GameConfig.getLanguageWithSwap(lang, serverName,statusMark)
		-- btn:getUpPanel().rich_servermark:setString(str)
		-- btn:getUpPanel().rich_servermark:setString(serverName)
		btn:getUpPanel().txt_servermark:setString("  " .. serverName)

		-- TODO
		-- btn:getUpPanel().txt_3:setVisible(false)

		-- 服务器状态
		self:updateServerStatus()
	end

	-- 区服ID改变时，清空区服排队时间
	if serverId ~= LoginControler:getQueueServerId() then
		LoginControler:clearQueueTime()
	end
end

function LoginEnterGameView:updateFrame()
	if not self.updateCount then
		self.updateCount = 1
	else 
		self.updateCount = self.updateCount + 1
	end

	-- 每秒刷新一次
	if self.updateCount % GameVars.GAMEFRAMERATE == 0 then
		self:updateServerStatus()
	end
end

-- 更新服务器状态
function LoginEnterGameView:updateServerStatus()
	local mcStatus = self.panel_1.mc_status
	local serverId = LoginControler:getServerId() 

	if not serverId then
		mcStatus:setVisible(false)
	else
		local info = LoginControler:getServerInfo()
		local index = LoginControler:getServerStatusKey(info)
		-- 服务器状态
		mcStatus:setVisible(true)

		if self.initServerOpen == nil then
			self.initServerOpen = LoginControler:checkServerOpenTime(info)
		end

		-- 通过强制修改显示状态的方案避免到达开区时间后刷新服务器列表的操作
		-- 区服从未到开启时间变成到达开启时间
		-- 强制修改为开启状态
		local isOpen = LoginControler:checkServerOpenTime(info)
		if self.initServerOpen == false and isOpen then
			index = LoginControler.SERVER_DISPLAY_STATUS.NEW
		end
		
		mcStatus:showFrame(index)
	end
end

function LoginEnterGameView:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_fcm, UIAlignTypes.MiddleTop)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_2, UIAlignTypes.MiddleBottom)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_3, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_account, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_txt, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg, UIAlignTypes.MiddleBottom)
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_bg.scale9_1,UIAlignTypes.MiddleBottom, 1, 0)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_shengming, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_shengming2, UIAlignTypes.MiddleBottom)
end

--[[2018.05.23 废弃代码暂时注释
function LoginEnterGameView:onLogout()
	self:setServerListBtn()
end
]]

--[[
	当改变区服
]]
function LoginEnterGameView:onChangeZone()
	self.initServerOpen = nil
	self:setServerListBtn()
end

--[[
	获取用户数据完成(init成功,完成选服)
]]
function LoginEnterGameView:onModelUpdateEnd()
	echo("========================================onModelUpdateEnd----------------------------------------")
	echo("UserExtModel:hasInited()=",UserExtModel:hasInited())
	--游客登录后没有初始化
	if UserExtModel:hasInited() then
		LoginControler:enterGameHomeView()
	else
		-- 执行序章逻辑
		if PrologueUtils:checkSkipPrologue() then
			WindowControler:showSelectRoleView()
		else
			self:doLoginLoading()
			PrologueUtils:doPrologueLogic()
		end
	end
end

--[[
	点击服务器列表
]]
function LoginEnterGameView:onServerListTap()
    if not LoginControler:getToken() then
        WindowControler:showTips(GameConfig.getLanguage("tid_login_1003") )
        -- WindowControler:showWindow("LoginView")
		LoginControler:showLoginView()
        return
    end

	-- 进入服务器列表打点
	ClientActionControler:sendNewDeviceActionToWebCenter(
        ActionConfig.login_select_server);

	WindowControler:showWindow("ServerListView")
end

--[[
	点击公告
]]
function LoginEnterGameView:onGongGaoTap()
	-- WindowControler:showTips("弹出公告")
	LoginControler:fetchGonggao()
end

--[[
	点击协议
]]
function LoginEnterGameView:onAgreementTap()
	WindowControler:showWindow("GameAgreementView")
end

-- 是否同意协议
function LoginEnterGameView:onConfirmAgreementTap()
	self.isAgree = not self.isAgree
	if self.isAgree then
		self.mc_1:showFrame(2)
	else
		self.mc_1:showFrame(1)
	end
end

--[[
	当同意协议
]]
function LoginEnterGameView:onConfirmAgreement()
	self.mc_1:showFrame(2)
end

--[[
	点击账号，与切换账号/切换区服相关功能进行优化处理
]]
function LoginEnterGameView:onAccountTap()
	-- 只有pc平台才会执行该逻辑
	self:startHide()
	WindowControler:closeWindow("LoginSelectWayView")
	WindowControler:showWindow("LoginSelectWayView")
end

--[[
	登录loading时设置UI的显示
]]
function LoginEnterGameView:setLoadingUIVisible(visible)
	local loginLoadingView = self.loginLoadingView
	if loginLoadingView and loginLoadingView.txt_fcm then
		loginLoadingView.txt_fcm:setVisible(visible)
	end

	-- 协议
	self:showAgreementInfo(visible)
	-- 版号
	self.panel_txt:setVisible(visible)
	-- 右上角按钮
	self.panel_account:setVisible(visible)
	-- 区服信息
	self.panel_1:setVisible(visible)
	-- 进入六界按钮
	self.btn_1:setVisible(visible)
end

--[[
	执行选服、是否进序章等相关loading
]]
function LoginEnterGameView:doLoginLoading()
	self:setLoadingUIVisible(false)

	local loginLoadingView = self.loginLoadingView
	loginLoadingView:doCharMoveAnim(GameVars.width*0.5,8)
	loginLoadingView:setEnterLoadingVisible(true)
end

--[[
	执行选服、是否进序章等相关loading失败后的恢复
]]
function LoginEnterGameView:doLoginLoadingRecover()
	self:setLoadingUIVisible(true)

	local loginLoadingView = self.loginLoadingView
	loginLoadingView:doCharRecoveryAnim()
	loginLoadingView:setEnterLoadingVisible(false)
end

--[[
	点击”进入六界“
]]
function LoginEnterGameView:onEnterGameTap()
	--检查已经选中的服务器的状态
    ClientActionControler:sendNewDeviceActionToWebCenter(
        ActionConfig.login_click_enter_game);

	-- 检查是否同意协议
	if not self.isAgree then
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1037"))
		return
	end

	-- 检查是否在排队等待中
	-- if LoginControler:checkQueueTime() then
	-- 	WindowControler:showHighWindow("LoginQueueUpView")
	-- 	return
	-- end

	-- 检查是否达到开服时间
	local sererInfo = LoginControler:getServerInfo()
	dump(sererInfo,"sererInfo--------")
	-- 如果没有开服且不是白名单账号
	if LoginControler:checkMaintianStatus(sererInfo) and not LoginControler:checkWhiteAccount() then
		-- 维护状态下刷新服务器类别机制
		if LoginControler:checkRefreshServerList() then
			echo("维护状态下刷新服务器列表")
			LoginControler:doGetServerList()
		end

		LoginControler:saveMaintianEnterGameInfo()
		-- WindowControler:showTips("该服务器正在维护")
		LoginControler:fetchMaintainGonggao()
		return
	end

	--[[
	-- 移到选服成功之后执行序章逻辑前执行
	-- 判断是否展示序章loading
	if PrologueUtils:checkShowPrologueLoading() then
		-- 执行loading
		self:doLoginLoading()
	end

	echo("\n\n-------------UserExtModel:hasInited()=",UserExtModel:hasInited())
	echo("Server:isConnect()=",Server:isConnect())
	echo("PrologueUtils:showPrologue()=",PrologueUtils:showPrologue())
	]]

	--[[2018.5.24 修改序章区服逻辑
	-- 执行登录逻辑
	if Server:isConnect() then
		if UserExtModel:hasInited() then
			LoginControler:doEnterGameRequest(self)
		else
			-- 如果是序章，执行执行登录逻辑
			if PrologueUtils:showPrologue() then
				LoginControler:doEnterGameRequest(self)
			else
				LoginControler:showLoginSelectRoleView()
			end
		end
	else
		LoginControler:doEnterGameRequest(self)
	end
	]]

	LoginControler:doEnterGameRequest(self)
end

return LoginEnterGameView

