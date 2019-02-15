
--
--Author:      zhuguangyuan
--DateTime:    2017-10-24 08:37:58
--Description: 仙盟GVE活动
--Description: 队伍实时挑战怪界面
--

local GuildActivityInteractView = class("GuildActivityInteractView", UIBase);

local GuildGameControlerClazz = require("game.sys.view.guildActivity.map.GuildGameControler")

function GuildActivityInteractView:ctor(winName,params)
    GuildActivityInteractView.super.ctor(self, winName)
end

function GuildActivityInteractView:loadUIComplete()
	self:initView()
	self:initViewAlign()
	self:initData()
	self:registerEvent()
	self:createChallengeSence()
end

-- function GuildActivityInteractView:onBecomeTopView()
-- 	self:createChallengeSence()
-- end
function GuildActivityInteractView:createChallengeSence()
	echo("________________ GuildActMainModel.isInReconnection ",GuildActMainModel.isInReconnection)
	if (GuildActMainModel:getMyTeamId())
		and not GuildActMainModel.isNotFirstComeOutMonster then
		GuildActMainModel.isNotFirstComeOutMonster = true
		self:loading(0)
		return
	end
	if GuildActMainModel.isInReconnection == true or GuildActMainModel:isInNewGuide() then
		echo("\n\n\n\n  活动场景重连恢复 ____________")
		-- GuildActMainModel.isInReconnection = false
		if not GuildActMainModel:getMyTeamId() and (not GuildActMainModel:isInNewGuide()) then
			if GuildActMainModel:getTotalReward() then
				if GuildActMainModel:getChallengeTimes() <= GuildActMainModel:getMaxChallengeTimes() then
					WindowControler:showWindow("GuildActivityKillMonsterRewardView",GuildActMainModel:getTotalReward())
				else
					WindowControler:showTips(GameConfig.getLanguage("#tid_guild_056"));
				end
				GuildActMainModel:resetTeamReward()
			end
			self:delayCall(c_func(self.startHide,self),0.5) 
		else
			self.panel_shicai:setVisible(false)
			local function callBack()
				-- if GuildActMainModel.isInReconnection then
				-- 	GuildActMainModel.isInReconnection = false
				-- end
				-- local event = {}
				-- event.params = {}
				-- local _reward = GuildActMainModel:getTotalReward()
				-- if _reward then
				-- 	event.params.totalReward = _reward
				-- end
				-- self.mapControler:onOneRoundAccountDataReady( event )
			end
			-- GuildActMainModel:setIsInCombo( false )
			self.mapControler:deleteMonsters()
			self.mapControler:resumeMonsterAtOnce()
		end
	end

	if self.mapControler.monsterModelArr then
		echo("monsterModelArr=",table.length(self.mapControler.monsterModelArr))
	else
		echo("monsterModelArr=nil")
	end

	echo("GuildActMainModel:getChallengeRound()=",GuildActMainModel:getChallengeRound())
	if not self.mapControler.monsterModelArr or table.length(self.mapControler.monsterModelArr) <=0  then
		self.mapControler:resumeMonsterAtOnce()
	end
end
--===== 战斗进入与恢复
-- ===== 注意这两个函数是在 WindowControler 的进入战斗和退出战斗恢复ui时调用的
function GuildActivityInteractView:getEnterBattleCacheData()
    -- echo("\n 战斗前缓存view数据 GuildActivityInteractView")
    return  {
    			
            }
end

function GuildActivityInteractView:onBecomeTopView()
	local callBack = function()
		if self == WindowControler:getCurrentWindowView() then
			self:onBattleExitResume()
		end
	end
	-- 延迟一帧且判断是否最顶层View的原因：
	-- 进战斗时如果先关闭了布阵，后显示loading，那么该方法也会被调用一次
	self:delayCall(c_func(callBack), 1/GameVars.GAMEFRAMERATE)
end

function GuildActivityInteractView:onBattleExitResume(_cacheData )
    -- dump(_cacheData,"战斗恢复view GuildActivityInteractView")
    if _cacheData then
    end
	GuildActMainModel.isInBattleResume =  true

    if not GuildActMainModel:getMyTeamId() and not GuildActMainModel:isInNewGuide() then
		if GuildActMainModel:getTotalReward() then
			if GuildActMainModel:getChallengeTimes() <= GuildActMainModel:getMaxChallengeTimes() then
				WindowControler:showWindow("GuildActivityKillMonsterRewardView",GuildActMainModel:getTotalReward())
			else
				WindowControler:showTips( GameConfig.getLanguage("#tid_guild_056"));
			end
			GuildActMainModel:resetTeamReward()
		end
		self:delayCall(c_func(self.startHide,self),0.5) 
	else
		echo("_________ 战斗后瞬间恢复怪 —————————————————— ")
		self.panel_shicai:setVisible(false)
		local function callBack( ... )
			if GuildActMainModel:isInNewGuide() then
				-- 已经进行了两次战斗
				if GuildActMainModel.newGuideBattleCount == 2 then
					-- WindowControler:showTips( { text = "弹出蓝葵说话" })
					-- EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_INDUCTOR_EXPLAIN,{} )

					PlotDialogControl:showPlotDialog("50023", function( ... )
						GuildActMainModel._beforeComboScore = GuildActMainModel._myTeamScore
						GuildActMainModel._beforeComboIngredients = table.deepCopy(GuildActMainModel._myTeamIngredients)
						-- 引导端监听消息 出来一个蓝葵说话 点击后发送一个消息 开始combo 这里模拟发送
						EventControler:dispatchEvent(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_COMBO,{})
					end)

				end
			end
			-- if GuildActMainModel.isInReconnection then
			-- 	GuildActMainModel.isInReconnection = false
			-- end
			-- local event = {}
			-- event.params = {}
			-- local _reward = GuildActMainModel:getTotalReward()
			-- if _reward then
			-- 	event.params.totalReward = _reward
			-- end
			-- self.mapControler:onOneRoundAccountDataReady( event )

		end
		-- GuildActMainModel:setIsInCombo( false )
		self.mapControler:deleteMonsters()
		self.mapControler:resumeMonsterAtOnce(callBack)
	end

	self.mapControler:moveToTargetPointOnStep()
end

function GuildActivityInteractView:initView()
	self:initMap()
	self.panel_guai:setVisible(false)
	self.panel_shipei2:setVisible(false)
	self.txt_dog:setVisible(false)
	self.panel_bubble:setVisible(false)
	self.panel_playerTitle:setVisible(false)
	self.txt_monsterName:setVisible(false)
	self.panel_duihua:setVisible(false)
	-- 收集结束
	self.panel_end:setVisible(false)
-- -- -- -- ============================================
	self.btn_xiang:setTap(c_func(self.showSceneRuleView,self))
	self.ItemHaveCacheViewList = {}
	self:initTeamMaterials()
	self:updateTeamScore()

	-- ChatModel:settematype("guild")
	-- -- 对话框
	-- self.chatmainview =  WindowControler:createWindowNode("ChatAddMainview")
 --    self.chatmainview:setPosition(cc.p(0,0))
 --    self.panel_duihua.ctn_chat:addChild(self.chatmainview)

 --    local node = display.newNode()
 --    node:addto(self.panel_duihua.ctn_chat,100):size(330,104)
 --    node:anchor(0,0)
 --    node:setPositionY(-100)
 --    node:setTouchedFunc(c_func(self.showChatView, self),nil,true);

 --    -- 测试传送门动画
 --    if not self.xuanzhuanAni then
	-- 	self.xuanzhuanAni = self:createUIArmature("UI_xianmenggve","UI_xianmenggve_chuansongmen", self, true,GameVars.emptyFunc)
	-- 	self.xuanzhuanAni:pos(300,-500)
	-- end
	-- self.xuanzhuanAni:startPlay(true)
end

function GuildActivityInteractView:showSceneRuleView()
	WindowControler:showWindow("GuildActivitySceneRuleView") 
end

function GuildActivityInteractView:initMap()
	self.mapControler = GuildGameControlerClazz.new(self)
	self.guildGameMap = self.mapControler:getGameMap()
	self._root:addChild(self.guildGameMap,-1)
	self.guildGameMap:pos(0,0)
end

function GuildActivityInteractView:playEndAnim(callBack)
	self.panel_end:setVisible(true)
	self:delayCall(callBack, 1)
end

function GuildActivityInteractView:initViewAlign()
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_bao, UIAlignTypes.LeftTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei, UIAlignTypes.MiddleTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_dog, UIAlignTypes.MiddleTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_shipei2, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_duihua, UIAlignTypes.LeftBottom)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_xiang, UIAlignTypes.MiddleTop)
end


function GuildActivityInteractView:initData()
	self._guildId = UserModel:guildId()
	self._teamId = GuildActMainModel:getMyTeamId()
end

function GuildActivityInteractView:registerEvent()
	GuildActivityInteractView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.quitChallengeReconfirm, self)) 
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_LEAVE_TEAM_CONFIRM, self.quitChallenge, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_CLOSE_INTERACT_VIEW, self.onClose, self)
end
-- 彈出聊天框
function GuildActivityInteractView:showChatView()
	-- FuncCommon.openSystemToView(FuncCommon.SYSTEM_NAME.CHAT)
	WindowControler:showWindow("ChatMainView", 4)
end

-- function GuildActivityInteractView:dataPrepared( event )
-- 	self.isDataPrepared = true
-- end

-- 退出队伍二次确认
function GuildActivityInteractView:quitChallengeReconfirm()
	if GuildActMainModel:isInNewGuide() then
		self:startHide()
		return
	end
	
	local viewType = FuncGuildActivity.tipViewType.quitChallenge
	local params = {}
	WindowControler:showWindow("GuildActivityTeamQuitReconfirmView",viewType,params)
end

function GuildActivityInteractView:quitChallenge()
	echo("____________ 退出挑战 ___________ ")
	ChatModel:setTeamMessage({})
	ChatModel:setChatTeamData({})
	GuildActMainModel:quitChallenge()
	self:startHide()
end
-- 倒计时
function GuildActivityInteractView:loading(leftTime)
	echo("___________ 进入loading")
	-- local leftTime = 0
	local frameCount = 0
	self.panel_shicai:setVisible(true)
	local function updateFrame()
		if leftTime > 5 then
			self.panel_shicai:setVisible(false)
			self:unscheduleUpdate()
			-- 显示积分
			-- 开始出怪
			self.mapControler:setAppearControlVar()
			return
		end
		if (frameCount % GameVars.GAMEFRAMERATE == 0) then
			leftTime = leftTime + 1
			self.panel_shicai.mc_1:showFrame(leftTime)
		end
		frameCount = frameCount + 1;
	end
	self:scheduleUpdateWithPriorityLua(c_func(updateFrame), 0);
end

-- 一轮选怪并战斗的倒计时
function GuildActivityInteractView:oneRoundCountdown()
	if GuildActMainModel:isInNewGuide() then
		echo("______  新手引导阶段的 倒计时 不走正常逻辑 _____")
		-- 打第一只怪前的倒计时,从90秒到20秒时停止不动
		local curRound = 1
		local frameCount = 0
		self.panel_shipei2:setVisible(true)
		if not GuildActMainModel.newGuideBattleCount then
			leftTimeMax = FuncDataSetting.getDataByConstantName("FoodTurnCountDown")
			leftTimeMin = FuncDataSetting.getDataByConstantName("FoodFirstTime")
		-- 打第二只怪前的倒计时,到5秒时停止不动
		elseif GuildActMainModel.newGuideBattleCount == 1 then
			leftTimeMax = FuncDataSetting.getDataByConstantName("FoodFirstTime")
			leftTimeMin = FuncDataSetting.getDataByConstantName("FoodSecondTime")
		-- 打完第二只怪后剩余时间
		elseif GuildActMainModel.newGuideBattleCount == 2 then
			leftTimeMax = FuncDataSetting.getDataByConstantName("FoodSecondTime")
			leftTimeMin = 0
		end
		echo("_____ leftTimeMax,leftTimeMin ___________",leftTimeMax,leftTimeMin)
		local function updateFrame()
			if (frameCount % GameVars.GAMEFRAMERATE == 0) then
				leftTimeMax = leftTimeMax - 1
				if leftTimeMax >= leftTimeMin then
					local _str = string.format(GameConfig.getLanguage("#tid_guild_058"),tostring(curRound))
					local left = TimeControler:turnTimeSec( leftTimeMax, TimeControler.timeType_mmss )
					self.panel_shipei2.txt_daojishi:setString(_str) 
					self.panel_shipei2.txt_daojishi2:setString(left) 
					self.panel_shipei2.txt_daojishi2:visible(true)
				else
					self.panel_shipei2.txt_daojishi:setString(GameConfig.getLanguage("#tid_guild_091"))
					self.panel_shipei2.txt_daojishi2:visible(false)
					self:unscheduleUpdate()
				end
			end
			frameCount = frameCount + 1;
		end
		self:scheduleUpdateWithPriorityLua(c_func(updateFrame), 0);
		return
	end

	self.panel_shipei2:setVisible(true)
	local curRound = GuildActMainModel:getChallengeRound()
	echo("进入第 "..curRound.." 轮战斗倒计时")
	GuildActMainModel:setIsInCombo( false )

	local frameCount = 0
	local configTime = FuncDataSetting.getOneAccountTime()
	if not configTime then
		configTime = 60
	end
	local function updateFrame()
		if (frameCount % GameVars.GAMEFRAMERATE == 0) then
			local left = TimeControler:getCdLeftime( GuildActMainModel.eventName_oneRoundTimer..curRound)
			echo("__!!!!__ 剩余时间,是否combo ____",left,GuildActMainModel:getIsInCombo())
			if (left <= 0) then
				GuildActMainModel:setIsInCombo( true )
				self.panel_shipei2:setVisible(true)
				self.panel_shipei2.txt_daojishi:setString(GameConfig.getLanguage("#tid_guild_091")) 
				self.panel_shipei2.txt_daojishi2:visible(false)
				if (left <= 0) then
					self:unscheduleUpdate()
				end
			elseif (tonumber(left) <= tonumber(configTime)) then
				if GuildActMainModel:getIsInCombo() == true then
					self.panel_shipei2.txt_daojishi:setString(GameConfig.getLanguage("#tid_guild_091"))
					self.panel_shipei2.txt_daojishi2:visible(false)
				else
					GuildActMainModel:setIsInCombo( false )
					left = TimeControler:turnTimeSec( left, TimeControler.timeType_mmss );
					local _str = string.format(GameConfig.getLanguage("#tid_guild_058"),tostring(curRound))
		        	self.panel_shipei2.txt_daojishi:setString(_str) 
		        	self.panel_shipei2.txt_daojishi2:setString(left) 
		        	self.panel_shipei2.txt_daojishi2:visible(true)
		        end
	        end
	        self:initTeamMaterials()
			self:updateTeamScore()
		end
		frameCount = frameCount + 1;
	end
	self:scheduleUpdateWithPriorityLua(c_func(updateFrame), 0);
end

function GuildActivityInteractView:updateUI()

end

-- 更新显示队内积分
function GuildActivityInteractView:updateTeamScore()
	local teamScore = GuildActMainModel:getChallengesScore()
	if GuildActMainModel:getChallengeTimes() <= GuildActMainModel:getMaxChallengeTimes() then
		self:showScoreNum( self.panel_shipei.mc_shuzi,teamScore )
	else
		self:showScoreNum( self.panel_shipei.mc_shuzi,0 )
	end
end

function GuildActivityInteractView:showScoreNum( _mcView,_score )
-- 参照战力组件
	local mcView = _mcView or self.mc_shuzi
	local nums = number.split(_score)
    local len = table.length(nums);
    --不能高于6
    if len > 6 then 
        return
    end 
    mcView:showFrame(len);
    for k, v in ipairs(nums) do
        local mcs = mcView:getCurFrameView();
        local childMc = mcs["mc_" .. tostring(k)]
        childMc:showFrame(v + 1);
    end
end

-- 初始化食材显示
function GuildActivityInteractView:initTeamMaterials()
	local configIngredients = {}
	if GuildActMainModel:isInNewGuide() then
		configIngredients = GuildActMainModel:getTeachMaterials()
	else
		configIngredients = FuncGuildActivity.getFoodMaterial(GuildActMainModel:getCurFoodId())
	end
	-- dump(configIngredients, "configIngredients", nesting)
	for k,v in pairs(configIngredients) do
		local itemView = self.panel_bao["panel_r"..k]

		local itemId = FuncGuildActivity.getMaterialIcon(v.id)
		local itemPath = FuncRes.getFoodIcon(itemId)
		itemSprite = display.newSprite(itemPath):anchor(0.5,0.5)
		itemSprite:pos(0,0)
		itemSprite:setScale(0.5)
		itemView.ctn_1:removeAllChildren()
		itemView.ctn_1:addChild(itemSprite)

		local num = GuildActMainModel:getOneChallengeGotMaterials(v.id)
		if GuildActMainModel:getChallengeTimes() > GuildActMainModel:getMaxChallengeTimes() then
			self.txt_dog:setVisible(true)
			num = 0
		end
		local name = FuncGuildActivity.getMaterialName(v.id)
		name = GameConfig.getLanguage(name)
		itemView.txt_1:setString(name..":"..num)
		self.ItemHaveCacheViewList[v.id] = itemView
	end
	local num = table.length(configIngredients)
	for i=num+1,6 do
		if self.panel_bao["panel_r"..i] then
			self.panel_bao["panel_r"..i]:visible(false)
		end
	end
end
-- 更新显示队内食材总量
function GuildActivityInteractView:updateTeamMaterials(_materialId)
	if GuildActMainModel:getChallengeTimes() <= GuildActMainModel:getMaxChallengeTimes() then
		self.txt_dog:setVisible(false)
		local num = GuildActMainModel:getOneChallengeGotMaterials(_materialId)
		local name = FuncGuildActivity.getMaterialName(_materialId)
		name = GameConfig.getLanguage(name)
		if self.ItemHaveCacheViewList[_materialId] then
			self.ItemHaveCacheViewList[_materialId].txt_1:setString(name..":"..num)
		end
	else
		self.txt_dog:setVisible(true)
	end
end

function GuildActivityInteractView:deleteMe()
	if self.mapControler then
		self.mapControler:deleteMe()
	end
	GuildActivityInteractView.super.deleteMe(self);
end

function GuildActivityInteractView:onClose()
	self:startHide()
	self:deleteMe()
end

function GuildActivityInteractView:getGuidingPos( ... )
	return self.mapControler:getGuidingPos(...)
end

return GuildActivityInteractView;
