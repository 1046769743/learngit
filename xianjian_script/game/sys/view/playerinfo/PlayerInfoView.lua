--
--Author:      zhuguangyuan
--DateTime:    2017-07-13 13:37:41
--Description: 玩家详情（新版）
--

local PlayerInfoView = class("PlayerInfoView", UIBase)

--初始化函数
function PlayerInfoView:ctor(winName)
	PlayerInfoView.super.ctor(self, winName)
end

--加载界面
function PlayerInfoView:loadUIComplete()
	self:setViewAlign()  --适配
	self:registerEvent() --注册事件
	self:displayPlayerInfo()--展示玩家信息 
	self.mc_content:getViewByFrame(1).panel_1.panel_huizhang:setVisible(false)     
end

------------------------------------------------------------------------------------------
--适配屏幕
function PlayerInfoView:setViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_close, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_res, UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title, UIAlignTypes.LeftTop)
    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_134,UIAlignTypes.MiddleTop, 1, 0)
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_h, UIAlignTypes.LeftTop)
end

------------------------------------------------------------------------------------------
--注册该版面的一些事件的回调
function PlayerInfoView:registerEvent()
	self.btn_close:setTap(c_func(self.close, self))	--关闭PlayerInfoView界面
	EventControler:addEventListener(TitleEvent.INFOPLAYER_RED_SHOW, self.onTitleUpdate, self) --称号信息变更红点显示
	EventControler:addEventListener("BUY_TOUXIAN_EVENT", self.TouXianUpDataUI, self) --境界提升信息变更红点显示
	EventControler:addEventListener(TitleEvent.TitleEvent_C_X_CALLBACK, self.onTitleDressUpdate, self) --监听穿戴或卸载称号
	EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserModelUpdate, self) 

    EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_EVENT, self.onChangePlayerIcon, self)
    EventControler:addEventListener(UserEvent.USER_CHANGE_HEAD_FRAM_EVENT, self.onChangePlayerIconFrame, self)
    EventControler:addEventListener(UserEvent.USER_CHANGE_QIAN_MING_EVENT, self.onChangeQianMing, self)

    EventControler:addEventListener(UserEvent.USEREVENT_PLAYER_POWER_CHANGE,self.setPowerNum, self);
end

--称号信息变更红点显示回调函数
function PlayerInfoView:onTitleUpdate()
	local  isShowRedPoint = TitleModel:sendHomeRed()
	local contentView = self.mc_content.currentView.panel_1
	local buttonViews = contentView.mc_buttons.currentView
	buttonViews.panel_red:setVisible(isShowRedPoint)

	-- --刷新到玩家详情界面
    self:displayPlayerInfo()
    self:onTitleDressUpdate()
end


--境界提升信息变更红点显示回调函数
function PlayerInfoView:TouXianUpDataUI()
	--境界
	local contentView = self.mc_content.currentView.panel_1

    local showCharBuyTouXianView = function()
    	WindowControler:showWindow("CharBuyTouXianView")
    end

    local isred = CharModel:isShowCharCrownRed()
    contentView.mc_god:getViewByFrame(UserModel:crown()).panel_red:setVisible(isred)
    contentView.mc_god:showFrame(UserModel:crown())	
    contentView.mc_god:setTouchEnabled(true)
    contentView.mc_god:setTouchedFunc(c_func(showCharBuyTouXianView, self), nil, true)
end

--监听穿戴或卸载称号
function PlayerInfoView:onTitleDressUpdate()
	local titleID = TitleModel:gettitleids()
	local contentView = self.mc_content.currentView.panel_1
	local _ctn = contentView.ctn_title
	if titleID ~= "" then
		contentView.txt_ch_name:setVisible(false)
    	TitleModel:showtitle(titleID,_ctn) --显示称号
    else
    	_ctn:removeAllChildren()
    	contentView.txt_ch_name:setVisible(true) 
    	contentView.txt_ch_name:setString(GameConfig.getLanguage("#tid_playerInfo_001"))
    end
    -- --刷新到玩家详情界面
    -- self:displayPlayerInfo()
	local isred = CharModel:isShowCharCrownRed()
    contentView.mc_god:getViewByFrame(UserModel:crown()).panel_red:setVisible(isred)

end


--更新主角模型回调函数
function PlayerInfoView:onUserModelUpdate()
	local contentView = self.mc_content.currentView.panel_1
	if contentView.txt_name then
		contentView.txt_name:setString(UserModel:name())
	end
end

--更改签名回调函数
function PlayerInfoView:onChangeQianMing()
    local qianmingTxt = UserExtModel:sign()
    if qianmingTxt == "" then
        qianmingTxt = "策划配默认的"
    end
    local contentView = self.mc_content.currentView.panel_1
    contentView.txt_qianmingneirong:setString(qianmingTxt)
end

--更换头像
function PlayerInfoView:onChangePlayerIcon(event)
    local headId = event.params.userHeadId
	local avatarCtn = self.mc_content.currentView.panel_1.ctn_tou
	UserHeadModel:setPlayerHeadAndFrame(avatarCtn,UserModel:avatar(),headId,UserModel:frame())
end

--更换头像框
function PlayerInfoView:onChangePlayerIconFrame(event)
    local headFrameId = event.params.headFrameId
	local frameCtn = self.mc_content.currentView.panel_1.ctn_tou
	UserHeadModel:setPlayerHeadAndFrame(frameCtn,UserModel:avatar(),headId,headFrameId)
end

function PlayerInfoView:setPowerNum(contentView)
	local contentView = self.mc_content.currentView.panel_1
	-- 阵容总战力 主角战力
	contentView.UI_power:setPower(UserModel:getcharSumAbility())--UserModel:getAbility())
	contentView.UI_power2:setPower(CharModel:getCharAbility())

end

------------------------------------------------------------------------------------------
--展示玩家信息
function PlayerInfoView:displayPlayerInfo()

	if self.info_view_inited then 
		return 
	end
	local contentView = self.mc_content.currentView.panel_1
	contentView.panel_progress2:setVisible(false)
	--显示头像
	self:setPlayerIcon()
	--个性设置(更改头像和头像框)
	contentView.btn_gexing:setTap(
		function()
        	WindowControler:showWindow("PlayerHeadView")
    	end
    )

	--显示名字
	contentView.txt_name:setString(UserModel:name())
	--重命名按键
	contentView.btn_rename:setTap(
		function ()
        	WindowControler:showWindow("PlayerRenameView")
    	end
    )
	
    --level(等级）
	contentView.txt_level:setString(tostring( UserModel:level() )..GameConfig.getLanguage("tid_common_2049") )   
	local currentExp = UserModel:exp()
	local maxExp = FuncChar.getCharMaxExpAtLevel(UserModel:level())
	echo("等级============="..UserModel:level())
	echo("currentExp============="..currentExp)
	echo("maxExp============="..maxExp)
    
	if FuncChar.getCharMaxLv() == UserModel:level() then 
        contentView.panel_progress.txt_exp:setString("--/--")--显示文字百分比
        contentView.panel_progress.progress_exp:setPercent(100) --显示进度条
    else
        local str = string.format("%d/%d",currentExp, maxExp)
	    local percent = currentExp*1.0/maxExp*100
	    contentView.panel_progress.txt_exp:setString(str)
	    contentView.panel_progress.progress_exp:setPercent(percent)
    end
   
  --   --vip(仙尊)
  --   local vipLevel = UserModel:vip();
  --   local maxVipLevel = FuncCommon.getMaxVipLevel()

  --   if maxVipLevel == vipLevel then
  --       contentView.panel_progress2.txt_exp:setString("--/--")
  --       contentView.panel_progress2.progress_exp:setPercent(100)
  --   else
  --       local currentExp = UserModel:goldTotal()
  --       local maxExp = FuncCommon.getVipPropByKey((vipLevel+1), "cost")
  --       local str = string.format("%d/%d",currentExp, maxExp)
  --       local percent = currentExp*1.0/maxExp*100
  --       contentView.panel_progress2.txt_exp:setString(str)
	 --    contentView.panel_progress2.progress_exp:setPercent(percent)

		-- echo("vip等级============="..vipLevel)
		-- echo("currentExp============="..currentExp)
		-- echo("maxExp============="..maxExp)
  --   end

    --contentView.txt_levelxz:setString("仙尊vip "..vipLevel)

	--仙盟
	local isaddGuild = GuildModel:isInGuild()
	if not isaddGuild then 
		contentView.txt_xianmeng_name:setString(GameConfig.getLanguage("#tid_playerInfo_002"))
	else
		local guildname = UserModel:guildName()
		if guildname == "" then
			guildname = GuildModel.guildName.name
		end
		contentView.txt_xianmeng_name:setString(guildname)
	end
    --境界
    local showCharBuyTouXianView = function()
    	WindowControler:showWindow("CharBuyTouXianView")
    end
    local isred = CharModel:isShowCharCrownRed()
    contentView.mc_god:getViewByFrame(UserModel:crown()).panel_red:setVisible(isred)
    contentView.mc_god:showFrame(UserModel:crown())	-----
    contentView.mc_god:setTouchEnabled(true)
    contentView.mc_god:setTouchedFunc(c_func(showCharBuyTouXianView, self), nil, true)
    
 	
	--称号
	local isShow = TitleModel:sendHomeRed()
	local buttonViews = contentView.mc_buttons.currentView
	buttonViews.panel_red:setVisible(isShow)
	self:onTitleDressUpdate()  --称号穿上或者卸下时更新称号
    --总战力
    -- contentView.UI_power:setPower(UserModel:getAbility())
    self:setPowerNum()

    --账号
	contentView.txt_account_id:setString(UserModel:uidMark()) 
	-- 点击称号按钮4次可弹出GM窗口，用于调试----------------
	-- contentView.txt_account_id:setTouchEnabled(true)
 --    self._num = 0
 --    contentView.txt_account_id:setTouchedFunc(function ()
 --    	echo("-------------dianji shijian ======")
 --    	self._num = self._num + 1
 --    	if self._num == 3 then
 --    		DEBUG_LOGVIEW = true
 --    		DEBUG_GMVIEW = true
 --    		DEBUG_ENTER_SCENE_TEST = true
 --    		FuncCommUI.addLogsView()
 --    		FuncCommUI.addGmEnterView()
 --    		FuncCommUI.addSceneTest()
 --    		FuncCommUI.LogsView:visible(true)
 --    		FuncCommUI.GMEnterView:visible(true)
 --    		FuncCommUI.SceneTestView:visible(true)
 --    	elseif self._num == 6 then 
 --    		DEBUG_LOGVIEW = false
 --    		DEBUG_GMVIEW = false
 --    		DEBUG_ENTER_SCENE_TEST = false
 --    		FuncCommUI.LogsView:visible(false)
 --    		FuncCommUI.GMEnterView:visible(false)
 --    		FuncCommUI.SceneTestView:visible(false)
 --    		self._num = 0
 --    	end
 --    end)
    -------------------------------------------------------

    --所在区服:
	local sname = LoginControler:getServerName()
	local smark = LoginControler:getServerMark()
	contentView.txt_server_name:setString(string.format("%s%s", smark, sname))

    --签名内容
    local qianmingTxt = UserExtModel:sign()
    if qianmingTxt == "" then
        qianmingTxt = "玩家签名信息，最多输入15个字"
    end
    contentView.txt_qianmingneirong:setString(qianmingTxt)
    --修改签名按键
    contentView.btn_qianming:setTap(
    	function ()
        	WindowControler:showWindow("PlayerQianMingView")
    	end
    )
	--设置中部按钮
	self:setInfoButtons()  

	self.info_view_inited = true
end

--显示头像和头像框和圆盘立绘
function PlayerInfoView:setPlayerIcon()
	local contentView = self.mc_content.currentView.panel_1

	--头像和头像框
	UserHeadModel:setPlayerHeadAndFrame(contentView.ctn_tou,UserModel:avatar(),UserModel:head(),UserModel:frame())

	--中部圆盘大头像
	-- 立绘动画遮罩
	local artMaskSprite = display.newSprite(FuncRes.iconOther("icon_other_bgMask2"))
	artMaskSprite:anchor(0.5,0)
	artMaskSprite:setScale(0.86)
	artMaskSprite:pos(0,-47)
	--立绘动画
	local garmentId = GarmentModel:getOnGarmentId()
	local charSpine = FuncGarment.getGarmentArtSp(garmentId,avatarId)
	charSpine:anchor(0.5,0)
	charSpine:setScale(0.5)
	charSpine:pos(0,0)
	charSpine:setAnimation(0, "ui", true); 

	--遮罩与立绘合成
	local newHeroAnim = FuncCommUI.getMaskCan(artMaskSprite,charSpine)
	newHeroAnim:pos(0,0)

	local avatarCtn2 = contentView.mc_buttons.currentView.ctn_1
	avatarCtn2:removeAllChildren()
	avatarCtn2:addChild(newHeroAnim)
end

--设置中部按钮  阵容、称号、设置、公告、切换账号、切换区服
function PlayerInfoView:setInfoButtons()
	local contentView = self.mc_content.currentView.panel_1
	local buttonViews = contentView.mc_buttons.currentView

    -- buttonViews.btn_xiangqing:setTap(c_func(self.checkLineUpInfo, self))--查看阵容
	buttonViews.btn_title:setTap(c_func(self.onTitleBtnTab, self))--称号
	buttonViews.btn_setup:setTap(c_func(self.onSetupBtnTab, self))--设置
	buttonViews.btn_notice:setTap(c_func(self.onNoticeBtnTab, self))--公告
	buttonViews.btn_gologin:setTap(c_func(self.onCDKeyButton, self))--兑换码
end

function PlayerInfoView:onCDKeyButton()
	WindowControler:showWindow("CdkeyExchangeView")
end

-- 查看阵容（需达到一定等级）
function PlayerInfoView:checkLineUpInfo()
	local isOpen,lvl = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.LINEUP)
	if isOpen then
		LineUpViewControler:showMainWindow()
	else
		local xtname = GameConfig.getLanguage(FuncCommon.getSysOpenxtname(FuncCommon.SYSTEM_NAME.LINEUP))
		WindowControler:showTips(GameConfig.getLanguageWithSwap("tid_teaminfo_1001", lvl, xtname))
	end
end

--称号
function PlayerInfoView:onTitleBtnTab()
	TitleModel:openTitleSystem()
end

--设置
function PlayerInfoView:onSetupBtnTab()
	self.mc_content.currentView:setVisible(false)
	self.mc_content:showFrame(2)
	----
	self.mc_content.currentView.panel_h:setVisible(false)

	self._music_volume = AudioModel:getMusicVolume()
	self._sound_volume = AudioModel:getSoundVolume()
	self:updateSettingView()
end

--公告
function PlayerInfoView:onNoticeBtnTab()
	LoginControler:fetchGonggao()
end

------------------------------------------------------------------
-- 玩家设置
------------------------------------------------------------------

-- -- 音效
-- function PlayerInfoView:yinxiaoClick( )
--     if AudioModel:isSoundOn() then
--         LS:pub():set(StorageCode.setting_sound_st, FuncSetting.SWITCH_STATES.OFF)
--     else
--         LS:pub():set(StorageCode.setting_sound_st, FuncSetting.SWITCH_STATES.ON)
--     end
--     self:updateVoiceStatus()
-- end
-- -- 音乐
-- function PlayerInfoView:yinyueClick( )
--     if AudioModel:isMusicOn() then
--         LS:pub():set(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.OFF)
--     else
--         LS:pub():set(StorageCode.setting_music_st, FuncSetting.SWITCH_STATES.ON)
--     end
--     self:updateVoiceStatus()
-- end
-- -- 更新音效音乐界面
-- function PlayerInfoView:updateVoiceStatus()
-- 	local contentView = self.mc_content.currentView.panel_1
--     -- 如果音效没开启，则进度条也设置为0、否则读取存储的音效值来这是进度
--     if not AudioModel:isSoundOn() then
--         contentView.panel_bg.panel_1:visible(true)
--         contentView.panel_bg.slider_r:setPercent(0)
--     else
--         contentView.panel_bg.panel_1:visible(false)
--         contentView.panel_bg.slider_r:setPercent(AudioModel:getSoundVolume()*100)
--     end
--     if not AudioModel:isMusicOn() then
--         contentView.panel_music.panel_1:visible(true)
--         contentView.panel_music.slider_r:setPercent(0)
--     else
--         contentView.panel_music.panel_1:visible(false)
--         contentView.panel_music.slider_r:setPercent(AudioModel:getMusicVolume()*100)
--     end
-- end


function PlayerInfoView:updateSettingView()
	local contentView = self.mc_content.currentView.panel_1
	contentView.UI_yincang:setVisible(false)
	contentView.UI_4:setVisible(false)
    contentView.panel_bg.panel_1:visible(false)
    contentView.panel_music.panel_1:visible(false)


	contentView.panel_bg.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_003")) 
	contentView.panel_bg.slider_r:setMinMax(0, 100)
	-- echo("\n\nAudioModel:getSoundVolume()==", AudioModel:getSoundVolume())
    contentView.panel_bg.slider_r:setPercent(self._sound_volume*100)
    contentView.panel_bg.slider_r:setTouchEnabled(true)

    -- local soundChange = function (...)
    --     local per = math.floor(contentView.panel_bg.slider_r:getPercent()/10)
    --     -- echo("\n\nper===soundChange===", per)
    --     AudioModel:setSoundVolume(per/10,true)
    -- end
    -- contentView.panel_bg.slider_r:onSliderChange(soundChange)

    local soundSliderEnd = function( per )
        per = math.floor(per/10)
        AudioModel:setSoundVolume(per/10)
    end
    contentView.panel_bg.slider_r:onSliderEnd(soundSliderEnd)
    -- contentView.panel_bg.btn_1:setTap(c_func(self.yinxiaoClick, self))
    contentView.panel_bg.btn_1:setTap(function( )
        AudioModel:setSoundVolume(0)
        contentView.panel_bg.slider_r:setPercent(0)
    end)
    -- -- panel_s
    -- progress_s
    -- 音量
    contentView.panel_music.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_004"))
    contentView.panel_music.slider_r:setMinMax(0,100)
    contentView.panel_music.slider_r:setPercent(self._music_volume*100)
    contentView.panel_music.slider_r:setTouchEnabled(true)

    -- local musicChange = function (...)
    --     local per = math.floor(contentView.panel_music.slider_r:getPercent()/10)
    --     AudioModel:setMusicVolume(per/10,true)
    -- end
    -- contentView.panel_music.slider_r:onSliderChange(musicChange)

    local musicSliderEnd = function( per )
        per = math.floor(per/10)
        AudioModel:setMusicVolume(per/10)
    end
    contentView.panel_music.slider_r:onSliderEnd(musicSliderEnd)

    contentView.panel_music.btn_1:setTap(function( )
        AudioModel:setMusicVolume(0)
        contentView.panel_music.slider_r:setPercent(0)
    end)
    -- contentView.panel_music.btn_1:setTap(c_func(self.yinyueClick, self))
    -- self:updateVoiceStatus()

    local pushViewCfg = {
    	{
    		view = contentView.panel_ts.panel_1.panel_dui,
    		storageKey = StorageCode.setting_notice_maxsp,
   	 	},

   	 	{
    		view = contentView.panel_ts.panel_2.panel_dui,
    		storageKey = StorageCode.setting_notice_world_answer,
   	 	},

   	 	{
    		view = contentView.panel_ts.panel_3.panel_dui,
    		storageKey = StorageCode.setting_notice_getsp,
   	 	},

   	 	{
    		view = contentView.panel_ts.panel_4.panel_dui,
    		storageKey = StorageCode.setting_notice_guild,
   	 	},

   	 	{
    		view = contentView.panel_ts.panel_5.panel_dui,
    		storageKey = StorageCode.setting_notice_fairylandbattle,
   	 	},

   	 	{
    		view = contentView.panel_ts.panel_6.panel_dui,
    		storageKey = StorageCode.setting_notice_guildactivity,
   	 	},
	}

	for i=1,#pushViewCfg do
		local view = pushViewCfg[i].view
		local storageKey = pushViewCfg[i].storageKey

		-- 设置显示状态
		local isOpen = LS:prv():get(storageKey, "1")
		isOpen = tostring(isOpen) == "1"
		view:setVisible(isOpen)

		view:parent().panel_1:setTouchedFunc(c_func(self.onSwitchTap,self,view,storageKey),nil, true)
	end


	-- contentView.btn_logout1:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_common_2075"))
	-- contentView.btn_logout2:getUpPanel().txt_1:setString(GameConfig.getLanguage("tid_common_2076"))

	local visibleButtons = {}
	-- btn_logout2 注销
	if PCSdkHelper:isLogoutSupported() then
		contentView.btn_logout2:setVisible(true)
		table.insert(visibleButtons, contentView.btn_logout2)
	else
		contentView.btn_logout2:setVisible(false)
	end

	-- btn_logout1 用户中心
	if PCSdkHelper:isUserCenterSupported() then
		contentView.btn_logout1:setVisible(true)
		table.insert(visibleButtons, contentView.btn_logout1)
	else
		contentView.btn_logout1:setVisible(false)
	end

	-- 切换账号
	if PCSdkHelper:isSwitchUserSupported() then
		contentView.btn_qhzh:setVisible(true)
		table.insert(visibleButtons, contentView.btn_qhzh)
	else
		contentView.btn_qhzh:setVisible(false)
	end

	contentView.btn_logout1:setTouchedFunc(function ()
				PCSdkHelper:openUserCenter()
			end)

	contentView.btn_logout2:setTouchedFunc(function ()
				LoginControler:doLogoutAccount()
			end)
	-- 切换账号
	contentView.btn_qhzh:setTouchedFunc(function ()
				WindowControler:showWindow("PlayerLogoutTipView",1)
			end)
	--打开反馈界面
	table.insert(visibleButtons, contentView.btn_gmfk)
	contentView.btn_gmfk:setTouchedFunc(function ()
				-- GameFeedBackControler:enterGameFeedBackView()
				PCSdkHelper:openUserFeedback()
			end)

	local buttonNum = #visibleButtons
	local middle = math.floor(buttonNum / 2) + 1
	local initPos = 480
	if buttonNum % 2 == 0 then
		initPos = 562
	end
	for i,v in ipairs(visibleButtons) do
		v:setPositionX(initPos + (i - middle) * 180)
	end
end

function PlayerInfoView:onSwitchTap(view,storageKey)
	local isOpen = LS:prv():get(storageKey, "1") == "1" 

	isOpen = not isOpen
	view:setVisible(isOpen)

	if isOpen then
		LS:prv():set(storageKey, "1")
	else
		LS:prv():set(storageKey, "0")
	end

	EventControler:dispatchEvent(SettingEvent.SETTINGEVENT_PUSH_SETTING_CHANGE)

	if isOpen and not PushHelper:isNotificationEnabled() then
		WindowControler:showWindow("PushPermissionView")
	end
end

--关闭按钮
function PlayerInfoView:close()
	if self.mc_content:getCurFrame() == 2 then 
		self.mc_content.currentView:setVisible(false)
		self.mc_content:showFrame(1)
		self:displayPlayerInfo()--展示玩家信息
	else
		self:startHide()
	end
end

return PlayerInfoView