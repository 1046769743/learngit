local SelectRoleView = class("SelectRoleView", UIBase)

function SelectRoleView:ctor(winName,selectType,randRole,delayShow)
	SelectRoleView.super.ctor(self, winName)
	self.curSelectRole = randRole
	self.delayShow = delayShow
	self.selectType = selectType or LoginControler.SELECT_ROLE_TYPE.LOGIN

	-- 随机角色
	if self.curSelectRole == nil then
		self.curSelectRole = 1
		local randomIndex =  RandomControl.getOneRandomInt(11,1)
		if randomIndex % 2 == 0 then
			self.curSelectRole = 2
		end
	end

	-- 是否播放了主角出场动画
	self.hasPlayUICharDebut = false

	-- TODO 该延迟时间与视频播放时间需要保持一致
	if self.delayShow then
		self:delayCall(c_func(self.forcePlayUICharDebut,self),9)
	end

	if not self.delayShow then
		self:playBgMusic()
	end
end

function SelectRoleView:initData()
	self.isInit = true

	self.flaName = "UI_xuzhang_xuanjue"

	self.roleType = {
		ROLE_MALE = 1,
		ROLE_FEMALE = 2,
	}

	self.hidList = {
		"101",			--男
		"104"			--女
	}

	self.initCharPos = cc.p(0,0)
	self.moveTargetPos = cc.p(150,0)

	self.heroAnimCache = {}

	-- 当前昵称是否是玩家手动输入的，默认不是
	-- 如果是手动输入的昵称，点击切换性别不再自动生成随机名字
	-- 如果是不是手动输入的昵称，点击切换性别会再次自动生成随机名字
	self.isInputName = false
end

function SelectRoleView:loadUIComplete()
	self:initData()
	self:registerEvent()
	self:initView()
	self:initViewAlign()
	-- echo("加载UI完成。。。。。。")
end

-- 播放背景音乐
function SelectRoleView:playBgMusic()
	AudioModel:playSound(s_char_light,false)
	AudioModel:stopMusic()
	AudioModel:playMusic(MusicConfig.m_scene_role_jiangmopu,true)
end

-- TODO 解决ZhangBiqiang iPhone6 Plus,iOS11.3视频播放问题，防止没有视频回调
function SelectRoleView:forcePlayUICharDebut()
	echo("forcePlayUICharDebut 强制播放出场动画",self.hasPlayUICharDebut)
	if not self.hasPlayUICharDebut then
		self:playUICharDebut()
	end
end

-- 选角播放主角出场
function SelectRoleView:playUICharDebut()
	if self.hasPlayUICharDebut then
		return
	end

	self.hasPlayUICharDebut = true

	self:playBgMusic()
	
	local callBack = function()
		self:playAnim()
	end

	self.charBgAnim:setVisible(true)

	if self.curSelectRole == self.roleType.ROLE_MALE then
		self.maleCharAnim:setVisible(true)
		self.femaleCharAnim:setVisible(false)
	else
		self.maleCharAnim:setVisible(false)
		self.femaleCharAnim:setVisible(true)
	end
	
	-- 播放闪白动画
	local charCtn = self.panel_ren.ctn_hero2
	local charAppearAnim =  ViewSpine.new("eff_plot_10001_shanbai")
	charAppearAnim:playLabel("eff_plot_10001_shanbai",false)
	charCtn:addChild(charAppearAnim)
	self:delayCall(c_func(callBack),0.5)
end

-- 初始化背景动画
function SelectRoleView:initBgAnim()
	local bgAnim  = ViewSpine.new("eff_plot_10001_xuanjuebeijing")
	bgAnim:playLabel("eff_plot_10001_xuanjuebeijing",true)
	-- bgAnim:addto(self)
	bgAnim:anchor(0.5,0.5)
	bgAnim:pos(GameVars.width/2 - GameVars.UIOffsetX,-GameVars.height/2 )
	self:addChild(bgAnim,-1)
end

function SelectRoleView:registerEvent()
	-- TODO 临时测试用
	self.panel_name:setTouchedFunc(c_func(self.startHide,self))

	self:registerTouchFunc(self.panel_nan,self.roleType.ROLE_MALE)
	self:registerTouchFunc(self.panel_nv,self.roleType.ROLE_FEMALE)

	local nanTouchNode = display.newNode()
	local size = cc.size(240,70)
	nanTouchNode:setContentSize(size)
    nanTouchNode:pos(-size.width,0)

	self.panel_name2.panel_anniudaxiao.ctn_niutiangaiming:addChild(nanTouchNode)

	local onTouchGlobalEnd = function()
		if self.clickAnim then
			self.clickAnim:setVisible(false)
		end
	end

	nanTouchNode:setTouchedFunc(c_func(self.onConfirmTap,self), nil, true
    	, c_func(self.playClickAnim,self),nil,false,c_func(onTouchGlobalEnd,self))
end

function SelectRoleView:registerTouchFunc(ctn,roleType)
	local nanTouchNode = display.newNode()
	local size = cc.size(120,120)

	-- local color = cc.c4b(255,0,0,120)
 --  	local layer = cc.LayerColor:create(color)
 --    nanTouchNode:addChild(layer)
 --    nanTouchNode:setTouchEnabled(true)
 --    nanTouchNode:setTouchSwallowEnabled(true)
 --    layer:setContentSize(size)

	nanTouchNode:setContentSize(size)
    nanTouchNode:pos(-size.width+20,-20)
	ctn:addChild(nanTouchNode)

	nanTouchNode:setTouchedFunc(c_func(self.doSelectRole,self,roleType))
end

function SelectRoleView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.ctn_zuoshangjiao, UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_name2, UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_shijv, UIAlignTypes.Left)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_nan, UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_nv, UIAlignTypes.LeftBottom)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_baobao, UIAlignTypes.Left)
end

function SelectRoleView:initView()
	self:initCharNickNameView()

	-- 如果是延迟显示，先隐藏UI
	if self.delayShow then
		self.panel_name:setVisible(false)
		self.mc_shijv:setVisible(false)
		self.panel_name2:setVisible(false)
	end

	self:initBgAnim()

	local label = ""
	-- 选角背景动画
	self.charBgAnim =  ViewSpine.new("UI_login_xuanjue")
	local charCtn = self.panel_ren.ctn_hero2
	charCtn:addChild(self.charBgAnim)

	if self.curSelectRole == self.roleType.ROLE_MALE then
		label = "nanzhu_stand"
	else
		label = "nvzhu_stand"
	end
	self.charBgAnim:playLabel(label,true)
	
	-- 男主动画
	local maleCharAnim = ViewSpine.new("UI_login_xuanjue_nan")
	maleCharAnim:playLabel("nanzhu_stand", true)
	maleCharAnim:setVisible(false)
	charCtn:addChild(maleCharAnim)
	self.maleCharAnim = maleCharAnim

	-- 女主动画
	local femaleCharAnim = ViewSpine.new("UI_login_xuanjue_nv")
	femaleCharAnim:playLabel("nvzhu_stand", true)
	femaleCharAnim:setVisible(false)
	charCtn:addChild(femaleCharAnim)
	self.femaleCharAnim = femaleCharAnim

	if self.curSelectRole == self.roleType.ROLE_MALE then
		self.charAnim = self.maleCharAnim

		self.maleCharAnim:setVisible(true)
		self.femaleCharAnim:setVisible(false)
	else
		self.charAnim = self.femaleCharAnim

		self.maleCharAnim:setVisible(false)
		self.femaleCharAnim:setVisible(true)
	end

	-- 初始化创建各种动画特效
	self:initAnim()

	if not self.delayShow then
		self:playAnim()
	else
		self.charBgAnim:setVisible(false)
		self.charAnim:setVisible(false)
	end

	-- 设置输入框输入回调
	local onInputEndCallBack = function()
		local newName = self.input_name:getText()
		if newName ~= self.lastName then
			self.isInputName = true
			self.lastName = newName
		else
			self.isInputName = false
		end
	end
	self.input_name:setInputEndCallback(c_func(onInputEndCallBack))
end

-- --------------------- 随机取名相关方法 begin ---------------------
function SelectRoleView:initCharNickNameView()
	-- 主角起名panel
	self.panel_baobao = self.panel_name2.panel_baobao
	self.input_name = self.panel_baobao.input_name
	self.btn_random_name = self.panel_baobao.btn_random_name
	-- 设置点击事件
	self.btn_random_name:setTap(c_func(self.onRandomNameTap, self))

	self.input_name:setText("")

	self:initRandomButton()
	self:onRandomNameTap()
end

-- 添加骰子动画
function SelectRoleView:addDiceAnim()
	self.diceAnim = self:createUIArmature("UI_wanjiaxiangqing", "UI_wanjiaxiangqing_shaizi", self.ctn, false, GameVars.emptyFunc)
	-- self.diceAnim:setScale(0.75)
	-- self.diceAnim:setPosition(-4, -3)
	self.diceAnim:pos(0,0)
	self.diceAnim:pause(1)
end

-- 初始化随机取名按钮
function SelectRoleView:initRandomButton()
	local panel = self.btn_random_name:getUpPanel()
	self.ctn = panel.ctn_1
	self.staticDice = panel.panel_1
	self:addDiceAnim()

	self.ctn:setVisible(false)
	self.staticDice:setVisible(true)
end

--[[
	随机生成名字
]]
function SelectRoleView:onRandomNameTap()
	if self.isPlaying then
		return
	end

	self.staticDice:setVisible(false)
	self.ctn:setVisible(true)
	self:playDiceAnim()
	local name = self:doGenOneRandomName()
	UserServer:checkRoleName(name, c_func(self.onCheckRoleNameOk, self))
end

function SelectRoleView:onCheckRoleNameOk(serverData)
	self.checkRoleNameOk = true
	if self.isDicePlayedOnce then
		self:doInitRandomName(self.random_name)
		self.diceAnim:gotoAndPause(1)
	end
end

function SelectRoleView:doGenOneRandomName()
	local sex = FuncChar.SEX_TYPE.NV
	if self.curSelectRole == self.roleType.ROLE_MALE then
		sex = FuncChar.SEX_TYPE.NAN
	end
	local name = FuncAccountUtil.getRandomRoleName(sex)
	echo("sex,name=",sex,name)
	self.random_name = name
	return name
end

-- 骰子动画播放
function SelectRoleView:playDiceAnim()
	self.isDicePlayedOnce = false
	local doInitName = function()
		self.isDicePlayedOnce = true
		-- 动画播完后判断网络是否返回，若返回则取得名字
		self.isPlaying = false
		self.diceAnim:gotoAndPause(1)     -- 重置动画	
		if self.checkRoleNameOk then
			self:doInitRandomName(self.random_name)					
			self.ctn:setVisible(false)
			self.staticDice:setVisible(true)
		end
	end
	self.diceAnim:registerFrameEventCallFunc(self.diceAnim.totalFrame, 1, c_func(doInitName))
	self.diceAnim:startPlay()
	self.isPlaying = true
end

function SelectRoleView:doInitRandomName(name)
	self.input_name:setText(name)
	self.lastName = name
	self.isInputName = false
end

-- --------------------- 随机取名相关方法 end ---------------------
function SelectRoleView:playAnim()
	self.panel_name:setVisible(true)
	self.mc_shijv:setVisible(true)
	self.panel_name2:setVisible(true)

	self.titleAnim:play()
	self.verseAnim:play()
	self.maleCtnAnim:play()
	self.femaleCtnAnim:play()
	self.changeLifeCtnAnim:play()
	if self.tipAnim then
		self.tipAnim:play()
	end
end

--[[
	初始化创建各种动画，然后默认跳到第一帧先不播放
]]
function SelectRoleView:initAnim()
	local flaName = self.flaName
	-- 标题动画及换装
	self.titleAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a1"
		, self.ctn_zuoshangjiao, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(self.titleAnim,"node1",self.panel_name)
	self.titleAnim:gotoAndPause(1)

	-- 诗句动画及换装
	self.verseAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a2"
		, self.ctn_shijv, false, GameVars.emptyFunc)
	self.mc_shijv:showFrame(self.curSelectRole)

	FuncArmature.changeBoneDisplay(self.verseAnim,"node2",self.mc_shijv)
	self.verseAnim:gotoAndPause(1)

	self.ctn_nanzhu = self.panel_nan.ctn_nanzhu
	self.ctn_nvzhu = self.panel_nv.ctn_nvzhu

	-- 男及女头像动画
	-- 男动画
	self.maleCtnAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a3"
		, self.ctn_nanzhu, false, GameVars.emptyFunc)

	self.maleHeadAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_xuannannv_nan"
		, nil, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(self.maleCtnAnim,"node3",self.maleHeadAnim)
	self.maleCtnAnim:gotoAndPause(1)

	-- 女动画
	self.femaleCtnAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a4"
		, self.ctn_nvzhu, false, GameVars.emptyFunc)

	self.femaleHeadAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_xuannannv_nv"
		, nil, false, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(self.femaleCtnAnim,"node4",self.femaleHeadAnim)
	self.femaleCtnAnim:gotoAndPause(1)

	-- 逆天改命按钮
	self.ctn_niutiangaiming = self.panel_name2.panel_anniudaxiao.ctn_niutiangaiming
	self.changeLifeCtnAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a5"
		, self.ctn_niutiangaiming, false, GameVars.emptyFunc)

	self.changeLifeAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_loop"
		, nil, true, GameVars.emptyFunc)
	FuncArmature.changeBoneDisplay(self.changeLifeCtnAnim,"node5",self.changeLifeAnim)
	self.changeLifeCtnAnim:gotoAndPause(1)

	-- 注册点击事件
	self.panel_name:setTouchedFunc(c_func(self.onConfirmTap,self))

	-- 文字tip
	self.ctn_xuanzezhenshixingbie = self.panel_name2.ctn_xuanzezhenshixingbie
	self.panel_xuanzezhenshixingbi = self.panel_name2.panel_xuanzezhenshixingbie
	-- 需求原因暂时屏蔽
	self.panel_xuanzezhenshixingbi:setVisible(false)
	--[[
	self.tipAnim = self:createUIArmature(flaName, "UI_xuzhang_xuanjue_a6"
		, self.ctn_xuanzezhenshixingbie, false, GameVars.emptyFunc)

	self.panel_xuanzezhenshixingbi:pos(-108,34)
	FuncArmature.changeBoneDisplay(self.tipAnim,"node6",self.panel_xuanzezhenshixingbi)
	self.tipAnim:gotoAndPause(1)
	]]

	self:updateCharAnim()
end

--[[
	更新主角头像和诗句动画
]]
function SelectRoleView:updateCharAnim()
	-- 更新角色ID
	self.hid = self.hidList[self.curSelectRole]

	if self.curSelectRole == self.roleType.ROLE_MALE then
		self.maleHeadAnim:playWithIndex(0,false)
		self.femaleHeadAnim:playWithIndex(2,false)
	else
		self.femaleHeadAnim:playWithIndex(0,false)
		self.maleHeadAnim:playWithIndex(2,false)
	end
	
	self.mc_shijv:showFrame(self.curSelectRole)
end

--[[
	点击男/女头像，执行选择角色操作
]]
function SelectRoleView:doSelectRole(roleType)
	if self.curSelectRole == roleType then
		return
	end

	self.curSelectRole = roleType

	self:updateCharAnim()
	self:playSwitchAnim()

	-- 再随机生成角色昵称
	if not self.isInputName then
		self:onRandomNameTap()
	end
end

function SelectRoleView:playSwitchAnim()
	if not self.switchIndex then
		self.switchIndex = 0
	end

	self.charAnim = nil
	local label1 = ""
	local label2 = ""
	-- 女切男
	if self.curSelectRole == self.roleType.ROLE_MALE then
		label1 = "nanzhu_qiehuan"
		label2 = "nanzhu_stand"

		self.charAnim = self.maleCharAnim

		self.femaleCharAnim:setVisible(false)
	-- 男切女
	elseif self.curSelectRole == self.roleType.ROLE_FEMALE then
		label1 = "nvzhu_qiehuan"
		label2 = "nvzhu_stand"

		self.charAnim = self.femaleCharAnim

		self.maleCharAnim:setVisible(false)
	end

	self.switchIndex = self.switchIndex + 1

	-- 播放主角动画
	self.charAnim:setVisible(true)
	self.charAnim:playLabel(label1,false)
	-- 播放主角背景动画
	self.charBgAnim:playLabel(label1,false)
	self:delayCall(c_func(self.playCharAnim,self,self.switchIndex,label2), 60/GameVars.GAMEFRAMERATE)
end

-- 播放主角切换动画
function SelectRoleView:playCharAnim(index,label)
	if index ~= self.switchIndex then
		return
	end

	self.charAnim:playLabel(label,true)
	self.charBgAnim:playLabel(label,true)
end

--[[
	逆天改命点击效果
]]
function SelectRoleView:playClickAnim()
	if self.clickAnim then
		self.clickAnim:setVisible(true)
		return
	end

	local ctn_niutiangaiming = self.ctn_niutiangaiming
	self.clickAnim = self:createUIArmature(self.flaName, "UI_xuzhang_xuanjue_dianji"
		, ctn_niutiangaiming, true, GameVars.emptyFunc)
	self.clickAnim:pos(-99,39)
end

-- 选角色确定
function SelectRoleView:onConfirmTap()
	-- 选角与昵称一起设置
	local defaultName = self.input_name:getText()
	local ok, tip = FuncAccountUtil.checkRoleName(defaultName)
	if not ok then
		WindowControler:showTips(tip)
		return
	end

	UserServer:setHero(self.hid, defaultName, c_func(self.onHeroSetOk, self));
end

--[[
	当角色选择成功
]]
function SelectRoleView:onHeroSetOk(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
		return
	end

	if self.selectType == LoginControler.SELECT_ROLE_TYPE.GUILD then
		-- 序章引导选角成功打点
		ClientActionControler:sendNewDeviceActionToWebCenter(
        	ActionConfig.guide_select_role);

		-- 如果新注册的角色，发送玩家数据
		if LoginControler:checkIsNewRole() then
			PCSdkHelper:sendUserInfo(true)
			PCSdkHelper:sendUserInfo()
		end	
	end
	
	self:startHide()
	TeamFormationModel:doSpecialOnFormation()
	-- 如果关闭了序章(仅dev下会关闭)，直接进主城
	if PrologueUtils:checkSkipPrologue() then
		LoginControler:enterGameHomeView()
	else
		EventControler:dispatchEvent(LoginEvent.LOGINEVENT_CLOSE_SELECT_ROLE_VIEW)
	end
end

function SelectRoleView:_checkRenameError(errorInfo)
	local code = errorInfo.code
	--这三个错误一般客户端都检查了
	--特殊字符
	if code == 10046 then
	end
	--长度不符
	if code == 10047 then
	end
	--敏感词
	if code == 10048 then
		WindowControler:showTips(GameConfig.getLanguage("tid_setting_1005"))
	--重名判断
	elseif code == 32502 then
		WindowControler:showTips(GameConfig.getLanguage("tid_info_nameuse"))
	else
		local tip = ServerErrorTipControler:checkShowTipByError(errorInfo)
	end
end

return SelectRoleView
