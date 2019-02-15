--[[
	Author: ZhangYanguang
	Date: 2017-06-06
	玩家设置昵称界面
]]

local LoginSetNicknameView = class("LoginSetNicknameView", UIBase)
-- local GEN_RANDOM_NAME_MAX_TRY = 10

function LoginSetNicknameView:ctor(winName)
	LoginSetNicknameView.super.ctor(self, winName)
	self.gen_random_name_try_count = 0
	self.isInit = true
end


function LoginSetNicknameView:loadUIComplete()
	self:initView()
	self:registerEvent()
	self:showView()
end

function LoginSetNicknameView:initData()
	self.isPlaying = false         -- 动画是否在播放中
	self.isDicePlayedOnce = false  -- 动画是否播放完
	self.checkRoleNameOk = false   -- 网络请求是否返回
end

function LoginSetNicknameView:initView()
	local size = self.panel_talkdi:getContainerBox()
	self.panel_talkdi:setScaleX(GameVars.width/size.width)
	self.input_name = self.panel_baobao.input_name
	self.btn_random_name = self.panel_baobao.btn_random_name
	
	self.input_name:setText("")
	self.panel_name1.txt_1:setString(GameConfig.getLanguage("tid_login_1061")) 
	self.panel_name1:setVisible(false)
	-- self.panel_qipao:setVisible(false)
	self.panel_baobao:setVisible(false)
	self.txt_wojiao:setVisible(false)
	self.btn_jian:setVisible(false)
	self:initRandomButton() -- 初始化随机改名按钮
	self:initViewAlign()
end

-- 适配
function LoginSetNicknameView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_talkdi, UIAlignTypes.MiddleBottom) 
  	FuncCommUI.setViewAlign(self.widthScreenOffset, self.ctn_zuo, UIAlignTypes.LeftBottom)
  	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_baobao, UIAlignTypes.LeftBottom)
  	FuncCommUI.setViewAlign(self.widthScreenOffset, self.txt_wojiao, UIAlignTypes.LeftBottom)
  	FuncCommUI.setViewAlign(self.widthScreenOffset, self.btn_jian, UIAlignTypes.LeftBottom)
  	-- FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_qipao, UIAlignTypes.LeftBottom)
  	FuncCommUI.setViewAlign(self.widthScreenOffset, self.panel_name1, UIAlignTypes.LeftBottom)

end

function LoginSetNicknameView:registerEvent()
	self.btn_random_name:setTap(c_func(self.onRandomNameTap, self))
	self.btn_jian:setTap(c_func(self.onRenameConfirm, self))
end

function LoginSetNicknameView:showView()
	-- 主角立绘
	-- self:delayCall(c_func(self.showCharSpine,self), 1 / GameVars.GAMEFRAMERATE)
	-- -- 气泡
	-- self:delayCall(c_func(self.showBubble,self), 10 / GameVars.GAMEFRAMERATE)
	-- -- 文字描述
	-- self:delayCall(c_func(self.showCharDes,self), 40 / GameVars.GAMEFRAMERATE)
	-- -- 我是谁
	-- self:delayCall(c_func(self.showWho,self), 60 / GameVars.GAMEFRAMERATE)
	-- -- 自助随机命名
	-- self:delayCall(c_func(self.onRandomNameTap,self), 90 / GameVars.GAMEFRAMERATE)
	-- -- 异常处理，如果初始化昵称出现异常，保证onSetNameSuccess被执行
	-- self:delayCall(c_func(self.onSetNameSuccess,self), 200 / GameVars.GAMEFRAMERATE)

	self:showCharSpine()
	-- self:showBubble()
	self:showCharDes()
	self:showWho()
	self:onRandomNameTap()
	self:onSetNameSuccess()
end

-- 初始化随机取名按钮
function LoginSetNicknameView:initRandomButton()
	local panel = self.btn_random_name:getUpPanel()
	self.ctn = panel.ctn_1
	self.staticDice = panel.panel_1
	self:addDiceAnim()

	self.ctn:setVisible(false)
	self.staticDice:setVisible(true)
end

-- 添加骰子动画
function LoginSetNicknameView:addDiceAnim()
	self.diceAnim = self:createUIArmature("UI_wanjiaxiangqing", "UI_wanjiaxiangqing_shaizi", self.ctn, false, GameVars.emptyFunc)
	-- self.diceAnim:setScale(0.75)
	self.diceAnim:setPosition(0,0)
	-- self.diceAnim:pause(1)
end

-- 展示主角立绘
function LoginSetNicknameView:showCharSpine()
	local avatar = UserModel:avatar();
	local garmentId = GarmentModel:getOnGarmentId()
    local resName = FuncGarment.getGarmentSpinName(garmentId,avatar)
	local artSpine = ViewSpine.new(resName)
    artSpine:playLabel("stand",true);
    artSpine:setScale(0.7)
    artSpine:pos(50,-80)
    self.ctn_zuo:addChild(artSpine)
end

-- 展示气泡
function LoginSetNicknameView:showBubble()
	self.panel_qipao:setVisible(true)
	self:playFadeInAnim(self.panel_qipao,0.2)
end

-- 展示描述
function LoginSetNicknameView:showCharDes()
	self.panel_name1:setVisible(true)
	self:playFadeInAnim(self.panel_name1,0.2)
end

-- 展示我是谁
function LoginSetNicknameView:showWho()
	local str = "[思考]我叫..."

	self.txt_wojiao:setVisible(true)
	self.txt_wojiao:setString("")
	self.txt_wojiao:startPrinter(str,10)
end

-- 展示命名
function LoginSetNicknameView:showRandomName()
	
	self.panel_baobao:setVisible(true)
	-- self:playFadeInAnim(self.panel_baobao,0.2)
	-- TODO
	self.panel_baobao:setVisible(true)
	-- dump(self.diceAnim, "showRandomName_diceAnim", 10)
	self:delayCall(c_func(self.showConfirmBtn,self), 0.7)
end

-- 展示确认按钮
function LoginSetNicknameView:showConfirmBtn()
	self.btn_jian:setVisible(true)
	self:playFadeInAnim(self.btn_jian,0.2)
end

-- 随机取名
function LoginSetNicknameView:onRandomNameTap()
	if self.isPlaying then
		return
	end

	self.staticDice:setVisible(false)
	self.ctn:setVisible(true)
	self:playDiceAnim()
	local name = self:doGenOneRandomName()
	UserServer:checkRoleName(name, c_func(self.onCheckRoleNameOk, self))
end

-- 骰子动画播放
function LoginSetNicknameView:playDiceAnim()
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

function LoginSetNicknameView:onSetNameSuccess()
	if self.isInit then
		self.isInit = false
		self:showRandomName()
	end
end

function LoginSetNicknameView:playFadeInAnim(view,time)
	view:opacity(0)

	local acts = cc.Sequence:create(
		act.fadein(time),nil)

	view:stopAllActions()
	view:runAction(acts)
end

function LoginSetNicknameView:doGenOneRandomName()
	local avatarId = tostring(UserModel:avatar())
	local sex = FuncChar.getHeroSex(avatarId)
	local name = FuncAccountUtil.getRandomRoleName(sex)
	self.random_name = name
	return name
end

function LoginSetNicknameView:onCheckRoleNameOk(serverData)
	self.checkRoleNameOk = true
	if self.isDicePlayedOnce then
		self:doInitRandomName(self.random_name)
		self.diceAnim:gotoAndPause(1)
	end

	-- if serverData.error then
	-- 	if self.gen_random_name_try_count < GEN_RANDOM_NAME_MAX_TRY then
	-- 		local anotherRandomName = self:doGenOneRandomName()
	-- 		UserServer:checkRoleName(anotherRandomName, c_func(self.onCheckRoleNameOk, self))
	-- 	else
	-- 		self:doInitRandomName(self.random_name)
	-- 	end
	-- else
	-- 	self:doInitRandomName(self.random_name)
	-- 	dump(self.random_name, "checkRoleNameOk.........", 10)
	-- end

	-- self.gen_random_name_try_count = self.gen_random_name_try_count + 1
end

function LoginSetNicknameView:doInitRandomName(name)
	self.input_name:setText(name)
	self:onSetNameSuccess()
end

-- 确认取名
function LoginSetNicknameView:onRenameConfirm()
	-- self.gen_random_name_try_count = 0
	local name = self.input_name:getText()
	local ok, tip = FuncAccountUtil.checkRoleName(name)
	if not ok then
		WindowControler:showTips(tip)
		return
	end

	if self.isPlaying then
		return
	end

	if UserModel:isNameInited() then
		local cost = UserExtModel:getRenameCost()
        if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) == true then
             UserServer:changeRoleName(name, self.rename_is_free, c_func(self.onChangeRoleName, self))
        end
	else
		UserServer:setRoleName(name, c_func(self.onSetRoleName, self))
	end
end

function LoginSetNicknameView:onChangeRoleName(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1019"))
		EventControler:dispatchEvent(UserEvent.USEREVENT_NAME_CHANGE_OK)
		self:close()
	end
end

function LoginSetNicknameView:_checkRenameError(errorInfo)
	local code = errorInfo.code
	--这三个错误一般客户端都检查了
	--特殊字符
	-- if code == 10046 then
	-- end
	-- --长度不符
	-- if code == 10047 then
	-- end
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

function LoginSetNicknameView:onSetRoleName(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_info_1002"))
		EventControler:dispatchEvent(UserEvent.USEREVENT_SET_NAME_OK)
		TeamFormationModel:doSpecialOnFormation()
		self:close()
	end
end

function LoginSetNicknameView:close()
	self:startHide()
end

function LoginSetNicknameView:startHide()
	LoginSetNicknameView.super.startHide(self)
	EventControler:dispatchEvent(UserEvent.USEREVENT_CLOSE_SET_NICK_NAME_VIEW)
end

return LoginSetNicknameView

