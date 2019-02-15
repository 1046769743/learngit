-- Author: ZhangYanguang
-- Date: 2017-05-22
-- 游戏加载主界面
-- 游戏加载主要内容
--[[
	1.检查序章完成进度
	2.更新GlobalServer
	3.检查热更
	4.加载游戏资源
	5.执行登录逻辑(是否自动登录等)

	进度条：
	1.1-3 占80% 
		如果有热更新 占100%
	2.20%

	2017.11.30优化登录流程
	1.检查版本完成前一直显示黑色框，不显示进度条
	2.检查完成后，开始显示进度条
]]

local LoginLoadingView = class("LoginLoadingView", UIBase)

function LoginLoadingView:ctor(winName)
	LoginLoadingView.super.ctor(self, winName)
end

function LoginLoadingView:loadUIComplete()
	AudioModel:playMusic("m_scene_start", true)
	
	self:registerEvent()
	self:initView()
	self:initAnim()
	self:setViewAlign()

	echo("LoginLoadingView:doLoadingLogic")
	self:doLoadingLogic()
end

function LoginLoadingView:initView()
	self:updateVersionInfo()

	-- 更新信息tipView
	self.panelUpdateInfoTip = self.panel_huoqu
	-- 文件下载进度条提示
	self.mcDownloadTip = self.mc_1
	self.mcDownloadTip:showFrame(1)
	self.mcDownloadTip.currentView.txt_1:setString("")
	self.mcDownloadTip.currentView.txt_2:setString("")

	-- 网络环境
	self.txtNetworkTip = self.txt_tishi
	-- 进度条
	self.progress_bar = self.panel_loading_progress.panel_1.progress_1
	self.ctn = display.newNode()
	self.ctn_jindu = display.newNode()
	self.progress_bar:addChild(self.ctn, 100)
	self.progress_bar:addChild(self.ctn_jindu, 50)

	-- TODO 新版已没有云
	-- self.progress_cloud = self.panel_loading_progress.panel_1.panel_cloud
	self.progress_panel_box = self.panel_loading_progress:getContainerBox()
	self.txt_progress = self.panel_loading_progress.panel_1.txt_1
	self._tip_str = ""

	self.txt_progress:setString("5%")
	self.progress_bar:setPercent(5)

	self:setProgressVisible(false)
	self:setUpdateTipVisibale(true)
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self) ,1)

	-- 送李逍遥提醒
	if self.panel_lxy then
		self.panel_lxy:setVisible(false)
		local lxyTip = LS:pub():get(StorageCode.login_give_lxy_tip, "")
		if lxyTip == "" then
			self.showLXY = true
			self.lxyOriginPosY = self.panel_lxy:getPositionY()
			LS:pub():set(StorageCode.login_give_lxy_tip, "1")
		end
	end
end

function LoginLoadingView:updateVersionInfo()
	local scriptVersion = AppInformation:getVersion()
	-- 版本号
	local version = "当前版本：v." .. scriptVersion
	self.txt_banben:setString(version)
end

--[[
	第一次启动游戏就热更时，更新李逍遥位置
]]
function LoginLoadingView:setLXYPos()
	if self._has_res_update and self.showLXY then
		self.panel_lxy:setVisible(true)
		self.panel_lxy:setPositionY(self.lxyOriginPosY + 30)
	end
end

function LoginLoadingView:doLoadingLogic()
	echo("是否进入序章",PrologueUtils:showPrologue())
	--重置server error状态
	Server:resetServerError()
	self:initCommonRes()
	--更新服务器地址
    self:checkGlobalServer()
end

-- 初始化场景动画
function LoginLoadingView:initAnim()
	local ctnAnim = self.ctn_1
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_lxy,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,ctnAnim,UIAlignTypes.MiddleBottom)
	local anim = self:createUIArmature("UI_denglu", "UI_denglu_denglu", ctnAnim, false, GameVars.emptyFunc)
	anim:pos(0,0)

	local callBack = function()
		local charCtn = display.newNode()
		self.charCtn = charCtn

		local jianSpine  = ViewSpine.new("UI_denglu_juese")
		jianSpine:playLabel("UI_denglu_juese_xia",true)
		jianSpine:addto(charCtn)

		-- TODO效果不好，暂时屏蔽
		-- local fireSpine = ViewSpine.new("eff_UI_denglu_juese")
		-- fireSpine:playLabel("eff_UI_denglu_juese",true)
		-- fireSpine:addto(charCtn)

		local charSpine  = ViewSpine.new("UI_denglu_juese")
		charSpine:playLabel("UI_denglu_juese_shang",true)
		charSpine:addto(charCtn)

		charCtn:pos(0,30)
		self.charCtnOrginPos = cc.p(charCtn:getPositionX(),charCtn:getPositionY())

		local charNode = anim:getBoneDisplay("ren")
		FuncArmature.changeBoneDisplay(charNode,"layer2",charCtn)
		-- self:addChild(charSpine)
		-- charSpine:pos(300,-300)
	end

	self:delayCall(callBack, 1/GameVars.GAMEFRAMERATE )
	self.heCtn = anim:getBoneDisplay("niao"):getBoneDisplay("layer1")
	for i=1,4 do
		self:delayCall(c_func(self.createHeAnim,self,i), i*2/GameVars.GAMEFRAMERATE )
	end

	-- 正在进入六界文字动画
	local anim = self:createUIArmature("UI_denglu", "UI_denglu_jinruliujie", self.ctn_loading
		, true, GameVars.emptyFunc)
	anim:pos(0,0)
	self.enterLoadingAnim = anim
	self.enterLoadingAnim:setVisible(false)
end

function LoginLoadingView:getCharSpineCtn()
	return self.charCtn
end

function LoginLoadingView:setEnterLoadingVisible(visible)
	self.enterLoadingAnim:setVisible(visible)
end

--[[
	进度条(选服进序章)：主角动画移到中间位置
]]
function LoginLoadingView:doCharMoveAnim(dis,sec)
	local posx,posy = self.charCtn:getPosition()
	local x = posx + dis
	local y = posy

	self.charCtn:stopAllActions()
	self.charCtn:runAction(cc.MoveTo:create(sec, 
	 	cc.p(x, y)))
end

--[[
	进度条(选服进序章)：主角消失动画
]]
function LoginLoadingView:doCharMoveDisappearAnim(callBack)
	self:setEnterLoadingVisible(false)
	local sec = 0.2
	self:doCharMoveAnim(GameVars.width,sec)
	if callBack then
		self:delayCall(c_func(callBack),sec )
	end
end

--[[
	进度条(选服进序章)：恢复主角位置(1.先右移动出界 2.再从左边出现)
]]
function LoginLoadingView:doCharRecoveryAnim()
	local posx,posy = self.charCtn:getPosition()

	local act1 = cc.MoveTo:create(0.5, 
	 	cc.p(posx+GameVars.width*0.5, posy))

	local callBack = function()
		self.charCtn:setPosition(cc.p(-300,posy))
	end

	local actCallBack = act.callfunc(callBack)
	local act2 = cc.MoveTo:create(0.5, 
	 	cc.p(self.charCtnOrginPos.x, self.charCtnOrginPos.y))

	self.charCtn:stopAllActions()
	self.charCtn:runAction(
		cc.Sequence:create(act1,actCallBack,act2)
	)
end

function LoginLoadingView:createHeAnim(index)
	local heSpine  = ViewSpine.new("UI_denglu_he")
	heSpine:playLabel("UI_denglu_he" .. index,true)
	heSpine:pos(0,0)
	FuncArmature.changeBoneDisplay(self.heCtn,"node" .. index ,heSpine)
end

-- 初始化通用资源
function LoginLoadingView:initCommonRes()
	local scene = WindowControler:getCurrScene()
	scene:initCommonRes()
end

function LoginLoadingView:setViewAlign()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_loading_progress, UIAlignTypes.MiddleBottom)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mcDownloadTip, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txtNetworkTip, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_banben, UIAlignTypes.LeftTop)
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panelUpdateInfoTip, UIAlignTypes.Middle)

	-- 防沉迷提醒
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_fcm, UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name, UIAlignTypes.MiddleTop)
	-- ctn_loading适配
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_loading, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bg, UIAlignTypes.MiddleTop)
	FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_bg.scale9_1,UIAlignTypes.MiddleTop, 1, 0)
end

function LoginLoadingView:frameUpdate()
	self:updateVersionInfo()
	if not self.frameCount  then
		self.frameCount = 1
	end

	self:updateProgressCloud()
	-- self:updateTipStr()
	self:updateNetworkStatus()
	self:updateDownloadTip()
	-- 修改李逍遥位置
	self:setLXYPos()
	self.frameCount = self.frameCount + 1
end

function LoginLoadingView:updateNetworkStatus()
	if device.platform == "windows" then
		return
	end

	if self.frameCount % 5 == 0 then
		local status = network.getInternetConnectionStatus()
		local statusStr = "网络状态："
		if status == network.status.kCCNetworkStatusNotReachable then
			statusStr = statusStr .. "没有网络"
		elseif status == network.status.kCCNetworkStatusReachableViaWiFi then
			statusStr = statusStr .. "WIFI"
		elseif status == network.status.kCCNetworkStatusReachableViaWWAN then
			statusStr = statusStr .. "移动网络"
		end

		self.txtNetworkTip:setString(statusStr)
	end
end

function LoginLoadingView:getDisplaySize(byteSize)
	local kbSize = byteSize / 1024

	local displaySizeStr = ""
	-- 大于1MB
	if kbSize >= 1024 then
		displaySizeStr = string.format("%.2f",tostring(kbSize / 1024)) .. "MB"
	else
		displaySizeStr = string.format("%.2f",tostring(kbSize)) .. "KB"
	end

	return displaySizeStr
end

-- 更新下载进度/资源加载提示
function LoginLoadingView:updateDownloadTip()
	-- 默认状态
	self.mcDownloadTip:showFrame(2)
	self.mcDownloadTip.currentView.txt_1:setVisible(false)
	
	if self._has_res_update then
		self.mcDownloadTip:showFrame(1)

		local downloadPercent = self._downloadPercent or 0
		local fileSize = self._fileSize or 0 

		local totalStr = self:getDisplaySize(fileSize)

		local downloadSize = fileSize * (downloadPercent) / 100
		local downloadStr = self:getDisplaySize(downloadSize)

		if downloadPercent >= 100 then
			downloadStr = totalStr
		end
		
		self.mcDownloadTip.currentView.txt_1:setString(GameConfig.getLanguage("tid_login_1060") .. tostring(downloadPercent) .. "%")
		self.mcDownloadTip.currentView.txt_2:setString(downloadStr .."/" .. totalStr)
	else
		self.mcDownloadTip:showFrame(2)
		-- 显示安装更新包
		if self._install_update then
			-- 模拟安装过程
			--[[
			if self._install_update_over then
				self.mcDownloadTip.currentView.txt_1:setVisible(false)
			else
				self.mcDownloadTip.currentView.txt_1:setVisible(true)
			end
			--]]
			self.mcDownloadTip.currentView.txt_1:setVisible(true)

			local callBack = function()
				self._install_update_over = true
				self.mcDownloadTip.currentView.txt_1:setVisible(false)
			end
			-- self:delayCall(c_func(callBack),20 / GameVars.GAMEFRAMERATE)
		else
			self.mcDownloadTip.currentView.txt_1:setVisible(false)
		end
	end
end

function LoginLoadingView:updateTipStr()
	if self._tip_str then
		self.txt_1:setString(self._tip_str)
	end
end

function LoginLoadingView:updateProgressCloud()
	self.progress_cloud = self.panel_loading_progress.panel_1.panel_cloud
	if self.progress_cloud then
		self.progress_cloud:setVisible(false)
		-- self.progress_cloud:pos(math.ceil(percent)*1.0/100 * totalWidth-15, -box.height/2)
	end

	local box = self.progress_panel_box
	local totalWidth = box.width
	-- echoError("width=", box.width, "height=", box.height)
	local percent = self.progress_bar:getPercent()
	self.txt_progress:setString(math.ceil(percent).."%")

	if not self.animMan then
		self.animMan = self:createUIArmature("UI_loading", "UI_loading_renwu", self.ctn, true)
		self.animMan:pos(-2, 65)

		self.animGuang = self:createUIArmature("UI_loading", "UI_loading_guangxiao", self.ctn, true)
		self.animGuang:pos(-1, 34)

		self.animProgress = self:createUIArmature("UI_loading", "UI_loading_jindu", self.ctn_jindu, true)
		self.animProgress:pos(totalWidth / 2 - 35, -5.5) 
	end

	-- percent = 20
	local anim = self.animProgress
	local zhezhao = anim:getBoneDisplay("layer14")
	zhezhao:pos(math.ceil(percent)*1.0/100 * 900 - 685, -6)
	self.ctn:pos(math.ceil(percent)*1.0/100 * (totalWidth - 70), -box.height/2)
end

function LoginLoadingView:registerEvent()
	EventControler:addEventListener(VersionEvent.VERSIONEVENT_CHECK_GLOBAL_SERVER, self.onGlobalServerCheckOk, self)
	EventControler:addEventListener(VersionEvent.VERSIONEVENT_CHECK_VERSION, self.onVersionCheckOk, self)
	EventControler:addEventListener(VersionEvent.VERSIONEVENT_UPDATE_PACKAGE, self.onVersionUpdatePackage, self)
end

function LoginLoadingView:retryCheckVersion()
	self:setUpdateTipVisibale(true)
	-- VersionControler:checkVersion()
	self:checkGlobalServer()
end

-- 检查版本更新
function LoginLoadingView:checkGlobalServer()
	echo("LoginLoadingView检查GlobalServer")
	VersionControler:checkGlobalServer()
end

-- 检查版本更新
function LoginLoadingView:checkVersion()
	echo("LoginLoadingView:checkVersion")
	self._tip_str = GameConfig.getLanguage('tid_update_1001')
	VersionControler:checkVersion()
end

--[[
	1.更新服务器地址
	2.更新序章设备标记
]]
function LoginLoadingView:onGlobalServerCheckOk(event)
	-- self.progress_bar:setPercent(10)
	local params = event.params
	local code = params.code
	local GLOBAL_SERVER_CODES = VersionControler.CHECK_GLOBAL_SERVER_CODE

	echo("LoginLoadingView:onGlobalServerCheckOk code=",code)

	-- 如果checkGlobalServer正常，执行检查序章标记逻辑
	if code == GLOBAL_SERVER_CODES.CODE_UPDATE_GLOBAL_SERVER then
		-- 检查序章
		-- self:checkPrologue()
		self:checkVersion()
	else
		echo("LoginLoadingView:onGlobalServerCheckOk 更新GlobalServer异常")
		self:showUpdateException(code)
	end
end

-- 检查更新完成
function LoginLoadingView:onVersionCheckOk(event)
	echo("LoginLoadingView:onVersionCheckOk")
	self:setProgressVisible(true)
	self:setUpdateTipVisibale(false)

	local params = event.params
	local code = params.code
	local VERSION_CODES = VersionControler.CHECK_VERSION_CODE
	echo("LoginLoadingView:onVersionCheckOk code=",code)

	if code == VERSION_CODES.CODE_NO_UPDATE then -- 不需要更新
		-- 不需要更新
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self.progress_bar:tweenToPercent(80, 20, c_func(self.onUpdateEnd, self, false))

	elseif code == VERSION_CODES.CODE_DO_UPDATE then -- 需要更新
		self._have_update_package= true
		self._tip_str = GameConfig.getLanguage("tid_update_1004")
		-- 暂时不需要该进度
		-- self.progress_bar:tweenToPercent(20, 5)

	elseif code == VERSION_CODES.CODE_DOWNLOAD_NEW_CLIENT  					--新客户端[目前不支持]
		   or code == VERSION_CODES.CODE_MAINTAIN_SERVER   					--维护
		   or code == VERSION_CODES.CODE_BACK_TO_TARGET_VERSION				--灰度更新失败
		   or code == VERSION_CODES.CODE_CLIENT_VERSION_NOT_EXIST 			--客户端版本在服务端不存在
		   or code == VERSION_CODES.CODE_NETWORK_ERROR 						--网络错误
		   or code == VERSION_CODES.CODE_OTHER_ERROR 						--其他未知错误
		then 
		
		self:showUpdateException(code)
	end

	--告诉数据中心完成检测有没有更新
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ActionConfig.login_check_version);
end

function LoginLoadingView:onVersionUpdatePackage(event)
	self:setProgressVisible(true)
	self:setUpdateTipVisibale(false)

	local params = event.params
	local code = params.code
	local UPDATE_CODES = VersionControler.UPDATE_PACKAGE_CODE

	-- echo("LoginLoadingView:onVersionUpdatePackage code=",code)

	-- 是否下载更新包
	if code == UPDATE_CODES.CODE_DOWNLOAD_CONFIRM then
		local fileSize = params.fileSize
		WindowControler:showWindow("LoginUpdateConfirmView",fileSize)

	elseif code == UPDATE_CODES.CODE_PREPARE_DOWNLOAD then --准备下载zip
		self._fileCount = params.totalFileCount or 1 	   --下载文件总数量
		-- 单位是字节
		self._fileSize = params.totalFileSize --下载文件总大小
		self._downloadPercent = 0
		self._has_res_update = true
		self._install_update = false
		self._install_update_over = false
	elseif code == UPDATE_CODES.CODE_DOWNLOADING then
		--正在下载zip
		local percent = 0
		if params.percent and params.percent ~= "" then
			-- 当前是第几个包文件
			local curFileIndex = params.curFileIndex
			-- 最后一个包可能小于其他包,为简化计算假定每个包都是一样大
			percent = params.percent * (curFileIndex/self._fileCount)
			percent = math.floor(percent)
			-- 解决断网后重连网络导致下载进度回退抖动问题
			if percent >= self._downloadPercent then
				self._downloadPercent = percent
			else
				return
			end
		end
		
		self._tip_str = GameConfig.getLanguage("tid_update_1002")
		-- 热更前占20%，下载更新占80%
		local displayPercent = 20 + (100-20) * percent*1.0/100
		self.progress_bar:tweenToPercent(displayPercent, 5)

	elseif code == UPDATE_CODES.CODE_DOWNLOAD_ZIP_FAILURE then
	 	--下载zip失败
		self:showUpdateException(code)

	elseif code == UPDATE_CODES.CODE_UNZIP_ERROR then
		--解压zip失败
		self:showUpdateException(code)
	elseif code == UPDATE_CODES.CODE_BACK_VERSION_NOT_FOUND then 
		--灰度回滚，没有找到版本---
		-- Zhangyanguang 2016-06-30
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_UPDATE_DOWNLOAD_COMPLETE then
		self._install_update = true
		-- 下载安装包及安装完成
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_UPDATE_COMPLETE then 
		--更新完成
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)
	-- 版本变更后重启游戏
	elseif code == UPDATE_CODES.CODE_CHANGE_VERSION_RESTART then
		-- 灰度后重启
		echo("灰度后重启游戏")
		self.versionChangeRestart = true
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)
	elseif code == UPDATE_CODES.CODE_UPDATE_VERSION_COMPLETE then
		--更新完成，只更新了版本号，没有任何脚本或资源变化
		self._have_update_package = false
		self._tip_str = GameConfig.getLanguage("tid_update_1003")
		self:delayCall(c_func(self.onUpdateEnd, self), 0.2)

	elseif code == UPDATE_CODES.CODE_DOWNLOAD_PARAM_ERROR then 
		--下载参数错误
		self:showUpdateException(code)

	elseif code == UPDATE_CODES.CODE_NO_RES_CHANGE_COMPLETE then
		-- 没有资源变更，更新完成
		self:onSimulateUpdateEnd()
	end
end

-- 展示更新异常界面
function LoginLoadingView:showUpdateException(code)
	self:delayCall(c_func(self.onUpdateException, self,code), 0.3)
end

function LoginLoadingView:onUpdateException(code)
	self:setUpdateTipVisibale(false)
	LoginControler:showLoginUpdateExceptionView(self,code)
end

-- 没有资源更新，模拟进度
function LoginLoadingView:onSimulateUpdateEnd(_frame)
	local frame = _frame or 20
	self.progress_bar:tweenToPercent(80, frame, c_func(self.loadGameRes, self))
end

-- 加载游戏资源
function LoginLoadingView:loadGameRes()
	self:initVoiceSdk()
	PushHelper:init()
	PCShareHelper:init()
	
	local loadResCallBack = function()
		local frame = 5
		
		-- 因sdk初始化没有失败回调，给sdk初始化预留更多时间
		if not DEBUG_SKIP_LOGIN_SDK then
			frame = 30
		end

		self.progress_bar:tweenToPercent(100, frame,c_func(self.onProgressEnd,self))
	end
	
	local loadGameRes = function()
		LoginControler:loadGameRes(loadResCallBack)
	end

	-- local initLBSSdk = function()
	-- 	PCLBSHelper:init()
	-- end

	-- self:delayCall(initLBSSdk, 0.3)
	self:delayCall(loadGameRes, 0.4)
end

-- 初始化语音sdk
function LoginLoadingView:initVoiceSdk()
	ChatShareControler:iniData()
end

-- 热更逻辑完成
function LoginLoadingView:onUpdateEnd(isUpdate)
	
	--告诉数据中心内更完成
	ClientActionControler:sendNewDeviceActionToWebCenter(
		ActionConfig.login_update_version);
	
	-- self:startHide()
	echo("LoginLoadingView self._have_update_package=",self._have_update_package)
	echo("当前版本号:=",AppInformation:getVersion())
	if self._have_update_package then
		-- 热更后需要快速启动(跳过logo展示等)
		LoginControler:setQuickRestart()
		GameLuaLoader:clearModules()
	elseif self.versionChangeRestart then
		echo("灰度/版本切换回退重启.....")
		-- 版本变更后重启游戏(基本上就是灰度/版本回退,重启后不再检查版本直接进游戏)
		AppHelper:setValue("swichted_version",tostring(AppInformation:getVersion()))
		GameLuaLoader:clearModules(true)
		self.versionChangeRestart = false
	else
		-- 灰度/版本切换再次重后会执行这里
		AppHelper:setValue("swichted_version","")
		cc.FileUtils:getInstance():purgeCachedEntries()
		self:loadGameRes()
	end
end

--不走更新过程的情况，进度加载结束
function LoginLoadingView:onProgressEnd()
	echo("LoginLoadingView:onProgressEnd")
	self:setProgressVisible(false)
	self.panel_lxy:setVisible(false)
	echo("LoginLoadingView:onProgressEnd self._have_update_package--------",self._have_update_package)

	WindowControler:showWindow("LoginSelectWayView",true)
end

function LoginLoadingView:setUpdateTipVisibale(visible)
	self.panelUpdateInfoTip:setVisible(visible)
end

-- 设置进度条是否可见
function LoginLoadingView:setProgressVisible(visible)
	-- echo("LoginLoadingView:setProgressVisible",visible)
	self.panel_loading_progress:setVisible(visible)
	if self.animMan then
		self.animMan:setVisible(visible)
	end

	if self.animGuang then
		self.animGuang:setVisible(visible)
	end

	if self.animProgress then
		self.animProgress:setVisible(visible)
	end

	self.mcDownloadTip:setVisible(visible)
end

--[[
-- 执行序章逻辑
function LoginLoadingView:doPrologueLogic()
	-- 序章第一场战斗模拟加载进度
	local firstBattleSimulatePercent = 100
	-- 序章第一场战斗模拟帧数
	local firstBattleSimulateFrame = 40

	-- 是否进入第一场战斗
	local showFirstBattle = PrologueUtils:showFirstBattle()
	local frame = 10

	if showFirstBattle then
		frame = firstBattleSimulateFrame
		self.progress_bar:tweenToPercent(firstBattleSimulatePercent, frame,c_func(self.onPrologueProgressEnd, self,showFirstBattle))
	else
		self.progress_bar:tweenToPercent(100, frame, c_func(self.onPrologueProgressEnd, self,showFirstBattle))
	end
end

-- 序章进度模拟完成
function LoginLoadingView:onPrologueProgressEnd(showFirstBattle)
	-- echo("showFirstBattle==",showFirstBattle)
	if not showFirstBattle then
		self:startHide()
	end
	
	PrologueUtils:doPrologueLogic()
end
]]

function LoginLoadingView:startHide()
    WindowControler:closeWindow("LoginSelectWayView")
	WindowControler:closeWindow("LoginEnterGameView") 
	LoginLoadingView.super.startHide(self)
end

return LoginLoadingView

