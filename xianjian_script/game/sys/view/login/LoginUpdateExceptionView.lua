local LoginUpdateExceptionView = class("LoginUpdateExceptionView", UIBase)


function LoginUpdateExceptionView:ctor(winName, loading,code)
	LoginUpdateExceptionView.super.ctor(self, winName)
	self.loadingView = loading
	self.code = code

	echoWarn("LoginUpdateExceptionView self.code=",self.code)

	-- 暂停新手引导
	-- EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = true})
end

function LoginUpdateExceptionView:loadUIComplete()
	self:registerEvent()
	self.txtTitle = self.UI_1.txt_1
	self.txtTipMsg = self.txt_1
	self.mcAction = self.UI_1.mc_1

	self:showException()
end

-- 根据code类别展示错误提示
function LoginUpdateExceptionView:showException()
	-- 默认按钮显示为确定
	self.mcAction:showFrame(1)
	local btnRetry = self.mcAction.currentView.btn_1
	btnRetry:setTap(c_func(self.onRetryTap, self))
	-- 重试
	btnRetry:setBtnStr(GameConfig.getLanguage("#tid407"))
	btnRetry:setClickPriority(GameVars.clickPriorityMap.overGuide)
	-- 服务器状态异常，请稍后再试！
	local commonServerTip = GameConfig.getLanguage("login_server_is_maintain_1002")

	-- 提示
	local tipTitle = GameConfig.getLanguage("#tid408")
	local tipMsg = ""
	local confirmStr = "确定"

	local GLOBAL_SERVER_CODES = VersionControler.CHECK_GLOBAL_SERVER_CODE
	local VERSION_CODES = VersionControler.CHECK_VERSION_CODE
	local UPDATE_CODES = VersionControler.UPDATE_PACKAGE_CODE 
	
	local code = self.code
	if code == VERSION_CODES.CODE_NETWORK_ERROR then
		-- tipMsg = "更新中断，请检查网络连接或存储空间之后再重试"
		-- tipMsg = GameConfig.getLanguage("#tid401")

		local status = network.getInternetConnectionStatus()
		-- 如果没有网络
		if status == network.status.kCCNetworkStatusNotReachable then
			tipMsg = "更新中断，请检查网络连接之后再重试"
		else
			tipMsg = commonServerTip
		end
	elseif code == VERSION_CODES.CODE_SERVER_ERROR then
		tipMsg = commonServerTip

	elseif code == VERSION_CODES.CODE_DOWNLOAD_NEW_CLIENT then
		-- 下载新客户端
		-- tipMsg = "当前版本已停用，请下载新客户端"
		tipMsg = GameConfig.getLanguage("#tid402")

		-- zhangyg 需要获取AppStore URL，调整到AppStore
		btnRetry:setBtnStr(confirmStr)
		btnRetry:setTap(c_func(self.onGoAppStore, self))

	elseif code == GLOBAL_SERVER_CODES.CODE_NO_VERSION 
		or code == VERSION_CODES.CODE_CLIENT_VERSION_NOT_EXIST then
		-- tipMsg = "服务器异常，请稍候重试"
		tipMsg = "该版本暂未上线"
		btnRetry:setBtnStr(confirmStr)
		btnRetry:setTap(c_func(self.onExitGame, self))
	elseif code == VERSION_CODES.CODE_MAINTAIN_SERVER then
		-- 服务器维护中
		-- tipMsg = "服务器正在维护中，具体开服时间请留意官网信息！"
		tipMsg = GameConfig.getLanguage("#tid403")

		btnRetry:setBtnStr(confirmStr)

	elseif code == VERSION_CODES.CODE_BACK_TO_TARGET_VERSION then
		-- 灰度回滚失败
		-- tipMsg = "灰度版本回退失败"
		tipMsg = GameConfig.getLanguage("#tid404")

	elseif code == VERSION_CODES.CODE_OTHER_ERROR then 
		--其他未知错误
		-- tipMsg = "更新出现未知错误"
		tipMsg = GameConfig.getLanguage("#tid405")

	-- 下面的错误为下载更新相关错误
	elseif code == UPDATE_CODES.CODE_DOWNLOAD_ZIP_FAILURE then
		-- 下载zip失败
		-- tipMsg = "下载更新文件失败，请重新尝试"
		tipMsg = GameConfig.getLanguage("#tid405")

	elseif code == UPDATE_CODES.CODE_UNZIP_ERROR then
		-- 安装，解压zip失败
		-- tipMsg = "安装失败，请重新尝试"
		tipMsg = GameConfig.getLanguage("#tid406")

	elseif code == UPDATE_CODES.CODE_DOWNLOAD_PARAM_ERROR then 
		-- 下载参数错误，说明服务器端给的数据格式有错误
		-- tipMsg = "更新出现参数错误"
		tipMsg = GameConfig.getLanguage("#tid405")
	elseif tonumber(code) == ErrorCode.kakura_needClientUpdate or  tonumber(code) == ErrorCode.kakura_server_error  then
		self.UI_1.btn_close:setVisible(false)
		
		-- 发布了新客户端，请重启游戏更新客户端
		-- 更新客户端通知
		-- tipMsg = GameConfig.getLanguage("#tid409")
		tipMsg = "发现新资源,请重新登录游戏"
		btnRetry:setBtnStr(confirmStr)

		btnRetry:setTap(c_func(self.onExitGame, self))
	else
		-- 未知异常
		tipMsg = commonServerTip
		btnRetry:setTap(c_func(self.onExitGame, self))
	end

	if code then
		tipMsg = tipMsg .. "(" .. code .. ")"
	end

	self.txtTitle:setString(tipTitle)
	self.txtTipMsg:setString(tipMsg)
end

function LoginUpdateExceptionView:registerEvent()
	-- self.UI_1.btn_close:setTap(c_func(self.onCloseTap, self))
	self.UI_1.btn_close:setVisible(false)
	
	-- EventControler:addEventListener(SystemEvent.SYSTEMEVENT_COMP_SERVEROVER_CLOSE, self.onTutorialChange,self)
end

function LoginUpdateExceptionView:onTutorialChange(event)
	-- EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = true})
end

-- 退出游戏
function LoginUpdateExceptionView:onExitGame()
	-- AppInformation:callNative(AppInformation.actionCode.ACTION_EXIT_GAME)
	LoginControler:restarGame()
end

-- 跳转到相应渠道
function LoginUpdateExceptionView:onGoAppStore()
	WindowControler:showTips(GameConfig.getLanguage("tid_login_1064")) 
end

function LoginUpdateExceptionView:onRetryTap()
	if self.loadingView then
		self.loadingView:retryCheckVersion()
	end
	self:close()
end

function LoginUpdateExceptionView:onCloseTap()
	self:close()
end

function LoginUpdateExceptionView:close()
	self:startHide()
end

function LoginUpdateExceptionView:startHide()
	LoginUpdateExceptionView.super.startHide(self)
	-- EventControler:dispatchEvent(TutorialEvent.TUTORIAL_SET_PAUSE, {ispause = false})
	-- 必须在上一个消息之后调用，解决新手引导中连续弹出热更界面和断网提醒界面，导致先导出的界面无法点击的问题
    -- EventControler:dispatchEvent(SystemEvent.SYSTEMEVENT_UPDATE_EXCEPTION_CLOSE)
end

return LoginUpdateExceptionView
