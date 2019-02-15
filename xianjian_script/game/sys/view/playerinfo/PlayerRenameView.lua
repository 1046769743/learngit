--修改:      zhuguangyuan
--DateTime:    2017-07-11 19:15:54
--Description: 主角重新命名 完成 7/12/2017

local PlayerRenameView = class("PlayerRenameView", UIBase)
-- local GEN_RANDOM_NAME_MAX_TRY = 10	--随机名称的最多次数

function PlayerRenameView:ctor(winName)
	PlayerRenameView.super.ctor(self, winName)	
end

function PlayerRenameView:loadUIComplete()
	-- 设置输入控件输入完毕回调函数
	-- 隐藏“请输入新名字”提示
	self.input_name:setInputEndCallback(c_func(self.hideEnterNewNameTxt, self))

    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_010")) 
	self:registerEvent() --注册各个按钮的处理事件
	self:setRenameCost() --设置是否花费仙玉花费仙玉的值
	self:initRandomButton() -- 初始化随机改名按钮

	-- if not UserExtModel:hasChangedName() then --如果名字为空  question
	-- 	self.UI_1.btn_close:visible(false)
	-- 	self.mc_cost:visible(false)
	-- 	-- self.txt_1:setString(GameConfig.getLanguage("tid_info_1001"))
	-- 	--self.txt_1:setString("什么鬼")
	-- end
end


-- 用户点击“请输入新名字”进行输入
-- 输入完成后返回 若输入不为空 隐藏掉“请输入新名字”提示
function PlayerRenameView:hideEnterNewNameTxt(  )
	if self.input_name:getText() == "" or self.input_name:getText() == " " then
		return
	end
	
	self.txt_xx:setVisible(false)
end
-- 初始化数据
function PlayerRenameView:initData()
	-- self.gen_random_name_try_count = 0
	self.isPlaying = false
	self.isDicePlayedOnce = false     -- 动画是否播完一遍
	self.checkRoleNameOk  = false     -- 网络请求是否返回
end

-- 初始化随机取名按钮
function PlayerRenameView:initRandomButton()
	local panel = self.btn_random_name:getUpPanel()
	self.staticDice = panel.panel_1
	self.ctn = panel.ctn_1
	self:addDiceAnim()
	self.ctn:setVisible(false)
	self.staticDice:setVisible(true)
end

-- 添加随机取名动画
function PlayerRenameView:addDiceAnim()
	self.diceAnim = self:createUIArmature("UI_wanjiaxiangqing", "UI_wanjiaxiangqing_shaizi", self.ctn, false, GameVars.emptyFunc)	
	self.diceAnim:setScale(0.9)
	self.diceAnim:setPosition(-2, 0)
	self.diceAnim:pause(1)
end

function PlayerRenameView:registerEvent()
	-- if UserExtModel:hasChangedName() then
		self:registClickClose("out")
		self.UI_1.btn_close:setTap(c_func(self.close, self))
	-- end

	self.btn_confirm:setTap(c_func(self.onRenameConfirm, self))--确定按钮

	
	self.btn_random_name:setTap(c_func(self.onRandomNameTap, self))--随机按钮
	
	--mc_1是啥  question
	self.UI_1.mc_1:visible(false)

end


--设置重命名的花费
--判断是否是首次重命名，是则免费
function PlayerRenameView:setRenameCost()
	echo("\n\n UserExtModel:hasChangedName() ----------- ",UserExtModel:hasChangedName())
	if UserExtModel:hasChangedName() then
		self.rename_is_free = 0 --不免费
		self.mc_cost:showFrame(1)
		local cost = UserExtModel:getRenameCost()
		self.mc_cost.currentView.txt_cost:setString(cost)
		self.mc_cost.currentView.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_011")) 

		if cost > UserModel:getGold() then
			self.mc_cost.currentView.txt_cost:setColor(FuncCommUI.COLORS.TEXT_RED)
		end
	else
		self.rename_is_free = 1 --免费
		self.mc_cost:showFrame(2)
		self.mc_cost.currentView.txt_1:setString(GameConfig.getLanguage("#tid_playerInfo_012"))
	end
end

---------------------------------------------------------
--随机生成一个名字并检验其合法性  若合法则设为主角名字
function PlayerRenameView:onRandomNameTap()
	if self.isPlaying then
		return
	end

	self.staticDice:setVisible(false)
	self.ctn:setVisible(true)
	self:playDiceAnim()    -- 点击骰子播放动画
	local name = self:doGenOneRandomName() --随机生成一个名称
	UserServer:checkRoleName(name, c_func(self.onCheckRoleNameOk, self)) --处理服务器返回数据	
end

--  骰子动画播放
function PlayerRenameView:playDiceAnim()
	self.isDicePlayedOnce = false
	local doInitName = function()
		self.isDicePlayedOnce = true
		-- 动画播完后判断网络是否返回，若返回则取得名字
		if self.checkRoleNameOk then
			self:doInitRandomName(self.random_name)
			self.diceAnim:gotoAndPause(1)    -- 重置骰子动画			
			self.isPlaying = false	
			self.ctn:setVisible(false)
			self.staticDice:setVisible(true)	
		end
	end
	-- 注册动画回调事件
	self.diceAnim:registerFrameEventCallFunc(10, 1, c_func(doInitName))
	self.diceAnim:startPlay()
	self.isPlaying = true
end

--随机生成一个名称
function PlayerRenameView:doGenOneRandomName()
	local avatarId = UserModel:avatar()..''
	local sex = FuncChar.getHeroSex(avatarId)
	local name = FuncAccountUtil.getRandomRoleName(sex)
	self.random_name = name
	return name
end

--处理服务器返回数据
function PlayerRenameView:onCheckRoleNameOk(serverData)
	if serverData.error then
		self.isPlaying = false
		self.diceAnim:gotoAndPause(1)
		return
	end

	self.checkRoleNameOk = true
	if self.isDicePlayedOnce then
		self:doInitRandomName(self.random_name)
		self.diceAnim:gotoAndPause(1)
	end
	-- if serverData.error then 
	-- 	if self.gen_random_name_try_count < GEN_RANDOM_NAME_MAX_TRY then
	-- 		local anotherRandomName = self:doGenOneRandomName()
	-- 		-- dump(anotherRandomName, "重新随机取名", 10)
	-- 		UserServer:checkRoleName(anotherRandomName, c_func(self.onCheckRoleNameOk, self))
	-- 	else
	-- 		self.diceAnim:registerFrameEventCallFunc(20, 1, c_func(doInitName))
	-- 		self.diceAnim:startPlay()
	-- 		-- self:doInitRandomName(self.random_name)
	-- 	end
	-- else
		-- self:doInitRandomName(self.random_name)
	-- self.gen_random_name_try_count = self.gen_random_name_try_count + 1  --限定随机次数
end

function PlayerRenameView:doInitRandomName(name)
	self.txt_xx:setVisible(false)
	self.input_name:setText(name)
end


--------------------------------------------------------------
--游戏玩家输入名字
function PlayerRenameView:onRenameConfirm()
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

	--首次命名免费不用检查仙玉是否足够，否则需要检测仙玉是否足够
	if self.rename_is_free == 1 then --注意此处不能写为if self.rename_is_free then 因为0和1都为true
									 --false 和 nil 都表示条件假，其他值都表示条件真
		UserServer:changeRoleName(name, self.rename_is_free, c_func(self.onChangeRoleName, self))
		self.rename_is_free = 0 --不免费
	else	
		local cost = UserExtModel:getRenameCost()
	    if UserModel:tryCost(UserModel.RES_TYPE.DIAMOND, tonumber(cost), true) == true then
	         UserServer:changeRoleName(name, self.rename_is_free, c_func(self.onChangeRoleName, self))
	    end
	end
end

function PlayerRenameView:onChangeRoleName(serverData)
	if serverData.error then
		self:_checkRenameError(serverData.error)
	else
		WindowControler:showTips(GameConfig.getLanguage("tid_login_1019"))
		EventControler:dispatchEvent(UserEvent.USEREVENT_NAME_CHANGE_OK)
		self:close()
	end
	
	-- 更新显示是否免费及耗费仙玉数量
	self:setRenameCost()
end

function PlayerRenameView:_checkRenameError(errorInfo)
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
		echo("重名弹窗++++++++++++=")
	end
end

function PlayerRenameView:close()
	self:startHide()
end

return PlayerRenameView

