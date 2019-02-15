--[[
	Author: LXH
	Date:2017-10-30
	Description: TODO
]]

local CompNewLoading = class("CompNewLoading", UIBase);

function CompNewLoading:ctor(winName, _loadingNumber, initTweenPercentInfo, processActions, processEndCfunc, onExitBattle)
    CompNewLoading.super.ctor(self, winName)
    self.loadingNumber = _loadingNumber
    echo("\n\n\n_loadingNumber=====", _loadingNumber)

    -- 是否是退出战斗的loading
	if onExitBattle then
		AudioModel:playMusic(AudioModel:getCacheMusic())
	end

	-- local serverInfo = LoginControler:getServerInfo() 
	-- local openTime = tonumber(serverInfo.openTime or  TimeControler:getServerTime())
	self.onlineDay = HappySignModel:getOnlineDays() or 1
	self.initTweenPercentInfo = initTweenPercentInfo or {percent=25, frame=20}
	self.processActions = processActions
	self.processEndCfunc = processEndCfunc
end

function CompNewLoading:loadUIComplete()

	if APP_PLAT == 1001 then
		if self.txt_fangchenmi then
			self.txt_fangchenmi:setVisible(true)
			FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_fangchenmi, UIAlignTypes.MiddleTop)
		end
	else
		if self.txt_fangchenmi then
			self.txt_fangchenmi:setVisible(false)
		end
	end

	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function CompNewLoading:registerEvent()
	CompNewLoading.super.registerEvent(self)
end

function CompNewLoading:initData()
	self.loadingData = FuncLoadingNew.getDataByLoadingNumber(self.loadingNumber)
	self.background = self.loadingData.background
	self.interval = FuncLoadingNew.getIntervalByLoadingNumber(self.loadingNumber) or 2
	if not self.loadingData.showType then
		echoError("loadingData.showType not found..  number = ", self.loadingNumber)
		self.loadingData.showType = 1
	end
	if not self.background then
		echoError("loadingData.background not found..  number = ", self.loadingNumber)
		self.background = "loading_bg_kaiqi.png"
	end
	-- if not self.loadingData.paramStr1 then
	-- 	echoError("loadingData.paramStr1 not found..  number = ", self.loadingNumber)
	-- 	self.loadingData.paramStr1 = "partner.png"
	-- end

	-- if not self.loadingData.paramStr2 then
	-- 	echoError("loadingData.paramStr2 not found..  number = ", self.loadingNumber)
	-- 	self.loadingData.paramStr2 = "#tid2298"
	-- end
	-- if not self.loadingData.paramStr3 then
	-- 	echoError("loadingData.paramStr3 not found..  number = ", self.loadingNumber)
	-- 	self.loadingData.paramStr3 = "#tid6200"
	-- end
	-- if not self.loadingData.paramStr4 then
	-- 	echoError("loadingData.paramStr4 not found..  number = ", self.loadingNumber)
	-- 	self.loadingData.paramStr4 = "#tid6201"
	-- end
	-- if not self.loadingData.paramStr5 then
	-- 	echoError("loadingData.paramStr4 not found..  number = ", self.loadingNumber)
	-- 	self.loadingData.paramStr5 = "loading_img_hyn.png"
	-- end
	self.mc_1:showFrame(tonumber(self.loadingData.showType))


	self.xoffset =(GameVars.width - GameVars.gameResWidth) / 2
	self.yoffset = (GameVars.height - GameVars.gameResHeight) / 2

	-- echo("\n\nself.xoffset==", self.xoffset, "self.yoffset==", self.yoffset)
end

function CompNewLoading:initView()
	if self.loadingData.backColour == nil then
		self.loadingData.backColour = 1
	end
	self.mc_ccc:showFrame(self.loadingData.backColour)
	if tonumber(self.loadingData.showType) == 1 then		
		self:initFirstFrame()
	elseif tonumber(self.loadingData.showType) == 2 then		
		self:initSecondFrame()
	elseif tonumber(self.loadingData.showType) == 3 then
		self:initThirdFrame()
	end	
	self:showRandomTips()

	self.progressBar = self.panel_progress.progress_1
	self.progressBarBox = self.progressBar:getContainerBox()
	self.ctn = display.newNode()
	self.ctn_jindu = display.newNode()
	self.progressBar:addChild(self.ctn, 100)
	self.progressBar:addChild(self.ctn_jindu, 50)
	-- 设置初始进度
	self.progressBar:setPercent(0)

	local initPercentInfo = self.initTweenPercentInfo
	self:scheduleUpdateWithPriorityLua(c_func(self.frameUpdate, self), 1)
	self:tweenToPercentWithAction(initPercentInfo.percent, initPercentInfo.frame)
	local delayTime = 0
	if LOADING_TIME then
		delayTime = 1.0/GameVars.GAMEFRAMERATE*2000
	else
		delayTime = 1.0/GameVars.GAMEFRAMERATE*20
	end
	self:delayCall(c_func(self.startLoad, self), delayTime)
end

function CompNewLoading:initFirstFrame()
	self:initBg(self.background)
	self:initRightIcon(self.loadingData.paramStr5)
	self:initLeftIcon()
end


function CompNewLoading:initSecondFrame()
	self:initBg(self.background)
	local panel = self.mc_1.currentView
	local lihuiImage = self.loadingData.paramStr1
	local txt = self.loadingData.paramStr2
	local iconImage1 = self.loadingData.paramStr3
	local iconImage2 = self.loadingData.paramStr4
	local lihuiSprite = display.newSprite(FuncRes.icon("loading/"..lihuiImage))
	local iconMaskSprite = display.newSprite(FuncRes.iconOther("loading_img_zhezhao"))
	local iconMaskSprite1 = display.newSprite(FuncRes.iconOther("loading_img_zhezhao"))
	local icon1 = FuncRes.iconBg(iconImage1)
	local iconSprite1 = FuncCommUI.getMaskCan(iconMaskSprite, display.newSprite(icon1))
	-- lihuiSprite:pos(-self.xoffset, -self.yoffset)
	panel.ctn_weizhi:removeAllChildren()
	panel.ctn_weizhi:addChild(lihuiSprite)
	if iconImage2 then
		panel.mc_1:showFrame(1)
		local icon2 = FuncRes.iconBg(iconImage2)		
		local iconSprite2 = FuncCommUI.getMaskCan(iconMaskSprite1, display.newSprite(icon2))
		panel.mc_1.currentView.panel_tu2.ctn_1:addChild(iconSprite2)
		-- lihuiSprite:pos(-100, 0)
	else
		panel.mc_1:showFrame(2)
		lihuiSprite:pos(100, 0)
	end
	panel.mc_1.currentView.panel_tu1.ctn_1:addChild(iconSprite1)

	panel.mc_1.currentView.panel_txt:zorder(50)	
	panel.mc_1.currentView.panel_txt.txt_1:setString(GameConfig.getLanguage(txt))

end


function CompNewLoading:initThirdFrame()
	local panel = self.mc_1.currentView
	self:initBg(self.background)
	if self.loadingData.onlineDays and self.loadingData.background == "loading_bg_huodongtxj.png" then
		panel.panel_1:setVisible(true)
		local leftDay = 7 - self.onlineDay
		if leftDay < 1 then
			echoError("请策划检查配表是否正确")
		else
			panel.panel_1.mc_1:showFrame(tonumber(leftDay))
		end
		
	else		
		panel.panel_1:setVisible(false)
	end
end

function CompNewLoading:initViewAlign()
	
	local panel = self.mc_1:getViewByFrame(2).mc_1:getViewByFrame(1)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1:getViewByFrame(1).panel_2, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1:getViewByFrame(1).panel_1, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, panel, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_1:getViewByFrame(2).panel_txt, UIAlignTypes.Right)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_aba, UIAlignTypes.Left)
	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_1, UIAlignTypes.Right)	
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_progress, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.rich_tishi, UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.mc_ccc, UIAlignTypes.MiddleBottom)
	
end

function CompNewLoading:updateUI()
	
end

function CompNewLoading:initBg(bgImage)
	self:changeBg(bgImage)
	-- local bgImagePath = FuncRes.iconBg(bgImage)
	-- local bgImageSprite = display.newSprite(bgImagePath):addto(self,-2);
	-- -- self._bgImagePath = bgImage
	-- self._bgImage = bgImageSprite:anchor(0,1)
	-- self._bgImage:pos(-self.xoffset, self.yoffset)

	-- self.__bgView = bgImageSprite
 --    self.__bgView:setScale(GameVars.bgSpriteScale)
end

function CompNewLoading:initRightIcon(iconImage)
	local iconRight = FuncRes.iconBg(iconImage)
	local iconMaskSprite = display.newSprite(FuncRes.iconOther("loading_bg_zhezhao"))
	local iconRightSprite = FuncCommUI.getMaskCan(iconMaskSprite, display.newSprite(iconRight))
	self.mc_1.currentView.panel_1.ctn_1:addChild(iconRightSprite)
end

function CompNewLoading:initLeftIcon()
	local panelLeft = self.mc_1.currentView.panel_2
	local iconLeft = FuncRes.icon("loading/"..self.loadingData.paramStr1)

	local iconLeftSprite = display.newSprite(iconLeft):addto(panelLeft.panel_aba.ctn_1)
	local txt_1 = GameConfig.getLanguage(self.loadingData.paramStr2)
	panelLeft.panel_aba.txt_1:setString(txt_1)
	local txt_2 = GameConfig.getLanguage(self.loadingData.paramStr3)
	panelLeft.txt_1:setString(txt_2)
	local txt_3 = GameConfig.getLanguage(self.loadingData.paramStr4)
	panelLeft.txt_2:setString(txt_3)
end

function CompNewLoading:showRandomTips()
	local tips = FuncLoadingNew.getRandomTipsByLoadingNumber(self.loadingNumber)
	self.rich_tishi:setString(GameConfig.getLanguage(tips))

	self:delayCall(c_func(self.showRandomTips, self), self.interval)
end

function CompNewLoading:tweenToPercentWithAction(percent, frame, actionCFunc)
	local tweenArgs = {percent, frame}
	if percent == 100 then
		local endFunc = c_func(function() 
			if self.processEndCfunc then
				self.processEndCfunc()
			end
			self:close()
		end)
		table.insert(tweenArgs, endFunc)
	end
	-- echo(percent,frame,"__________compLoading",os.clock())
	self.progressBar:tweenToPercent(unpack(tweenArgs))

	if actionCFunc then
		actionCFunc()
	end
end

function CompNewLoading:startLoad()
	local processActions = self.processActions
	local frame = 0
	for _, info in ipairs(processActions) do
		if frame  == 0 then
			self:tweenToPercentWithAction(info.percent, info.frame, info.action)
		else
			self:delayCall(c_func(self.tweenToPercentWithAction,self,info.percent, info.frame, info.action or false), frame/GameVars.GAMEFRAMERATE )
		end
		frame = frame + info.frame
		
	end
end

--结束loading, 如果不传回调 直接关闭 
function CompNewLoading:finishLoading(frame,actionCFunc)
	-- echo("____完成loading-----")
	self:stopAllActions()
	local percent = self.progressBar:getPercent()
	self.progressBar:stopTween()
	local percent = 100
	if not actionCFunc then
		actionCFunc = c_func(self.startHide,self)
	end
	self.progressBar:tweenToPercent(percent,frame,actionCFunc)
end

function CompNewLoading:frameUpdate()
	local percent = self.progressBar:getPercent()
	if percent < 100 then
		percent = math.ceil(percent)
	else
		percent = 100

	end
	self.panel_progress.txt_1:setString(percent.."%")
	self:updateProgressAnim(percent)
end

function CompNewLoading:updateProgressAnim(percent)
	local box = self.progressBarBox
	local totalWidth = box.width
	if not self.ctn:getChildByName("run") then
		local animRun = self:createUIArmature("UI_loading", "UI_loading_renwu", self.ctn, true)
		local animGuang = self:createUIArmature("UI_loading", "UI_loading_guangxiao", self.ctn, true)
		local animJinDu = self:createUIArmature("UI_loading", "UI_loading_jindu", self.ctn_jindu, true)
		animRun:pos(-2, 35)
		animGuang:pos(5, 0)
		animJinDu:pos(totalWidth / 2 + 1, -6) 
		animRun:setName("run")
		animJinDu:setName("progress")
	end
	
	local zhezhao
	if self.ctn_jindu:getChildByName("progress") then
		local anim = self.ctn_jindu:getChildByName("progress")
		zhezhao = anim:getBoneDisplay("layer14")
	end
	zhezhao:pos(math.ceil(percent)*1.0/100 * totalWidth - 675, -box.height/2)
	self.ctn:pos(math.ceil(percent)*1.0/100 * totalWidth - 5, -box.height/2)
end

function CompNewLoading:deleteMe()
	-- TODO
	-- FuncRes.removeBgTexture(self._bgImagePath)
	CompNewLoading.super.deleteMe(self);
end

function CompNewLoading:onProgressEnd()
	self:delayCall(function ()
		self:close()
	end, 1)
end

function CompNewLoading:close()
	self:startHide()
end

return CompNewLoading;
