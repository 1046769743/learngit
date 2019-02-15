--
--Author:      zhuguangyuan
--DateTime:    2017-10-23 17:35:26
--Description: 仙盟GVE活动主界面
--


local GuildActivityMainView = class("GuildActivityMainView", UIBase);

function GuildActivityMainView:ctor(winName)
    GuildActivityMainView.super.ctor(self, winName)
end

function GuildActivityMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
	local view = WindowControler:createWindowNode("BulleTip")
    -- view:setTxt(FuncPlot.getLanguage(str,UserModel:name(  )))
    self._root1 = display.newNode():addto(self)
    
    view:setTxt("FuncPlot.getLanguage(str,UserModel:name(  ))")
    view:parent(self._root1)
end 

--=================================================================================
--=================================================================================
function GuildActivityMainView:registerEvent()
	GuildActivityMainView.super.registerEvent(self);
	self.btn_back:setTap(c_func(self.onClose, self))  -- 返回
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ONE_ACTIVITY_OPEN, self.onActivityOpen, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_GOT_REWARD, self.gotOneReward, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_SOMEONE_INPUT_INGREDIENTS, self.onSomeoneInputIngredients, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_ACCOUNT_TIME_UP, self.onClose, self)
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_EVENT_CHALLENGE_END, self.onChallengeEnd, self)
	-- 新手引导结束
	EventControler:addEventListener(GuildActivityEvent.GUILD_ACTIVITY_GUIDE_TRIGGER_REWARD, self.onGuideFinished, self)
end

-- 引导结束 发请求获取100仙玉奖励
function GuildActivityMainView:onGuideFinished( event )
	if not self.hasSentRequest then
		self.hasSentRequest = true
		local params = {}
		PlotDialogControl:showPlotDialog("50024",function ( ... )
			local function gotRewardCallBack(serverData)
				if serverData and serverData.error then
				else
					-- local data = serverData.result.data
					-- dump(data, "data", nesting)
					-- 发送消息告知引导结束
					EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_GUILDACTIVITY,{} )
					local reward = {"4,100"}
					WindowControler:showWindow("RewardSmallBgView",reward )
				end
			end
			GuildActivityServer:hasFinishedGuide(params,gotRewardCallBack)
		end)
	end
end

--关闭按钮
function GuildActivityMainView:onClose()
	self:startHide()
end
-- 打开规则界面
function GuildActivityMainView:openActivityRuleView()
	WindowControler:showWindow("GuildActivityRuleView")
end
-- 打开煮菜界面
function GuildActivityMainView:openCookingView()
    WindowControler:showWindow("GuildActivityCookingView")
end

-- 打开奖励规则界面
function GuildActivityMainView:openTeachVideoView()
	echo("______________ 弹微信小视频 ________")
    -- WindowControler:showWindow("GuildActivityRewardRuleView")
end
-- 打开累积奖励界面
function GuildActivityMainView:openRewardView()
    WindowControler:showWindow("GuildActivityRewardView")
end

-- 活动开启成功
function GuildActivityMainView:onActivityOpen(event)
    self._foodId = event.params.foodId
    self._openTime = event.params.lastGveTime
    -- self:initData()
    self:initView()
	self:updateUI()
	-- self:gotoCollectMaterials()
	-- self:gotoCooking()
end
function GuildActivityMainView:onChallengeEnd( event )
	 self:initView()
	 GuildActMainModel:updateGveRedPoint()
end
function GuildActivityMainView:gotOneReward( event )
	local isShowRedPoint = GuildActMainModel:isShowRewardRedPoint()
	echo("展示红点否》-- 奖励相关",isShowRedPoint)
	self.btn_3:getUpPanel().panel_red:setVisible(isShowRedPoint)
end

function GuildActivityMainView:onSomeoneInputIngredients( event )
	local isShowRedPoint = GuildActMainModel:isShowCookingRedPoint()
	echo("展示红点否》-- 食材相关",isShowRedPoint)
	self.panel_1.panel_zhuozi.btn_1:getUpPanel().panel_red:visible(isShowRedPoint)

	local configMaterials = FuncGuildActivity.getFoodMaterial(self._foodId)
	for k,v in pairs(configMaterials) do
		local itemView = self.panel_2["panel_x"..k]
		local materialData = GuildActMainModel:getCurHaveIngredients(v.id)
		self:updateOneItemHave( materialData, itemView)
	end	

	-- 中部食物名字
	-- local foodName = FuncGuildActivity.getFoodName(self._foodId)
	-- foodName = GameConfig.getLanguage(foodName)
	-- leftPanel.txt_name:setString(foodName)
	-- add食物星级
	local foodStar = GuildActMainModel:getFoodStar()
	echo("___________ 食物星级 ____________ ",foodStar)
	self.maxFoodStar = 5
	self.panel_1.panel_zhuozi.mc_star:showFrame(self.maxFoodStar)
	local currentView = self.panel_1.panel_zhuozi.mc_star:getCurFrameView()
	for i=1,self.maxFoodStar do
		if i <= foodStar then
			currentView["mc_"..i]:showFrame(1)
		else
			currentView["mc_"..i]:showFrame(2)
		end
	end
end
--=================================================================================
--=================================================================================
function GuildActivityMainView:initData()
	self._guildId = UserModel:guildId()
	self._foodId = GuildActMainModel:getCurFoodId() 
	if not self._foodId then
		self._foodId = GuildActMainModel:getToOpenFoodId()
	end
	-- self.ItemHaveCacheViewList = {}
end


--=================================================================================
--=================================================================================
function GuildActivityMainView:initView()
	self.panel_icon.btn_rule:setTap(c_func(self.openActivityRuleView, self)) 
	-- 教学视频和奖励入口按钮
	self.btn_1:visible(false) 
	-- self.btn_1:setTap(c_func(self.openTeachVideoView, self)) 
	self.btn_3:setTap(c_func(self.openRewardView, self)) 
	local isShowRedPoint = GuildActMainModel:isShowRewardRedPoint()
	echo("展示奖励红点------------",isShowRedPoint)
	self.btn_3:getUpPanel().panel_red:setVisible(isShowRedPoint)
	--=============================================================
	local leftPanel = self.panel_1
	-- 显示npc
	local npcId = FuncGuildActivity.getFoodNPC(self._foodId)
	-- local icon = FuncCommon.getNpcIcon(npcId)
	-- local iconPath = FuncRes.iconHero( icon )
	-- local iconSp = display.newSprite(iconPath);
	-- leftPanel.UI_tou.ctn_1:addChild(iconSp)
	-- leftPanel.UI_tou.panel_lv:visible(false)
	-- leftPanel.UI_tou.mc_dou:visible(false)
	local npcData = FuncCommon.getNpcDataById(npcId)
	local spine = FuncRes.getArtSpineAni(npcData.spine) --=--PartnerModel:initNpc(npcId)
	spine:scale(0.7)
	leftPanel.panel_zhuozi.ctn_2:removeAllChildren()
	leftPanel.panel_zhuozi.ctn_2:addChild(spine)
	-- npc 提示信息
	local sentence = FuncGuildActivity.getFoodNPCBubble(self._foodId)
	sentence = GameConfig.getLanguage(sentence)
	leftPanel.panel_xinxi.txt_1:setString(sentence)

	local actArr = {
        act.scaleto(0.3, 1),
        act.delaytime(3),
        act.scaleto(0.2, 0),
        act.delaytime(2)
	}
	leftPanel.panel_xinxi:stopAllActions()
	leftPanel.panel_xinxi:runAction(act._repeat(act.sequence(unpack(actArr))))
	-- -- 显示订单
	-- local npcName = FuncCommon.getNpcName(npcId)
	-- npcName = GameConfig.getLanguage(npcName)
	-- local _str = string.format(GameConfig.getLanguage("#tid_guild_059"),npcName)
	-- leftPanel.txt_shi:setString(_str)

	-- 中部食物图标占位符
	local itemId = FuncGuildActivity.getFoodIcon(self._foodId)
	local iconPath = FuncRes.getFoodIcon(itemId)
	foodSprite = display.newSprite(iconPath):anchor(0.5,0.5)
	foodSprite:pos(0,2)
	foodSprite:setScaleY(0.8)
	foodSprite:setScaleX(1.3)
	leftPanel.panel_zhuozi.ctn_1:removeAllChildren()
	leftPanel.panel_zhuozi.ctn_1:addChild(foodSprite)

	--=============================================================
	-- 我收集到的食材
	self.panel_2.txt_shi:setString(GameConfig.getLanguage("#tid_guild_060")) 
	-- 显示收集到的食材
	local configMaterials = FuncGuildActivity.getFoodMaterial(self._foodId)
	for k,v in pairs(configMaterials) do
		local itemView = self.panel_2["panel_x"..k]
		local materialData = GuildActMainModel:getCurHaveIngredients(v.id)
		self:updateOneItemHave( materialData, itemView)
		-- self.ItemHaveCacheViewList[v.id] = itemView
	end

	local maxTimes = GuildActMainModel:getMaxChallengeTimes()
	-- 挑战剩余次数
	local challengeTimes = GuildActMainModel:getChallengeTimes()
	if challengeTimes > maxTimes then 
		challengeTimes = maxTimes
	end
	challengeTimes = maxTimes - challengeTimes
	self.panel_2.txt_cishu:setString(GameConfig.getLanguage("#tid_guild_061")..challengeTimes.."/"..maxTimes)

	self:gotoCollectMaterials() 
	self:gotoCooking()
	self:onSomeoneInputIngredients()
end

-- 更新一个食材的item
function GuildActivityMainView:updateOneItemHave( _materialData,_itemView )
	local itemId = FuncGuildActivity.getMaterialIcon(_materialData.id)
	local itemPath = FuncRes.getFoodIcon(itemId)
	itemSprite = display.newSprite(itemPath):anchor(0.5,0.5)
	itemSprite:pos(0,0)
	itemSprite:setScale(1)
	_itemView.panel_chicai.ctn_1:removeAllChildren()
	_itemView.panel_chicai.ctn_1:addChild(itemSprite)

	local materialName = FuncGuildActivity.getMaterialName(_materialData.id)
	materialName = GameConfig.getLanguage(materialName)
	_itemView.txt_1:setString(materialName)

	local progress = _itemView.panel_progress.progress_jindu
    local percent = _materialData.curNum / _materialData.maxNum * 100
    progress:setDirection(ProgressBar.l_r)
    progress:setPercent(percent)
    _itemView.panel_progress.txt_1:setString(_materialData.curNum)

    local numStatus = FuncGuildActivity.getMaterialNumStatus( percent )
    _itemView.txt_2:setString(numStatus)
end

-- 打开收集食材界面
function GuildActivityMainView:gotoCollectMaterials()
	-- if not GuildActMainModel:getInGVEOpenPeriod() then
	-- 	self.panel_2.btn_2:setBtnStr(GameConfig.getLanguage("#tid_guild_062"),"txt_1")
	-- 	self.panel_2.btn_2:setTap(c_func(self.openActivity, self))
	-- else
	-- 	self.panel_2.btn_2:setBtnStr(GameConfig.getLanguage("#tid_guild_063"),"txt_1")
	-- 	self.panel_2.btn_2:setTap(function() 
 --    		WindowControler:showWindow("GuildActivityTeamMainView")
 --    	end)
 --    end

 	-- 四测 活动盟主手动开启改为到时自动开启
 	-- 新手引导情况下 默认可以点进去
	self.panel_2.btn_2:setBtnStr(GameConfig.getLanguage("#tid_guild_063"),"txt_1")
	self.panel_2.btn_2:getUpPanel().panel_red:visible(false)
	if GuildActMainModel:getChallengeTimes() < GuildActMainModel:getMaxChallengeTimes() then
		local isOpen = GuildActMainModel:isActivityCanOpen()
		if not isOpen then
		else
			self.panel_2.btn_2:getUpPanel().panel_red:visible(true)
		end
	end

	self.panel_2.btn_2:setTap(function() 
		if GuildActMainModel:isInNewGuide() then
			WindowControler:showWindow("GuildActivityTeamMainView")
		else
			local isOpen,str = GuildActMainModel:isActivityCanOpen( _activityId )
			if isOpen then
				WindowControler:showWindow("GuildActivityTeamMainView")
			elseif str then
				WindowControler:showTips(str) 
			end
		end
	end)
end

function GuildActivityMainView:openActivity()
	-- WindowControler:showTips( GameConfig.getLanguage("#tid_guild_064"))
	WindowControler:showTips( "需策划配置语言表-每周xxxx点开启")


	-- if not GuildModel:judgmentIsForZBoos() then
	-- 	WindowControler:showTips( GameConfig.getLanguage("#tid_guild_064"))
	-- 	return
	-- end

	-- local _activityId = "1"
	-- if not GuildActMainModel:isActivityCanOpen( _activityId ) then
	-- 	return
	-- end
	-- GuildActMainModel:openActivity(self._guildId)
	-- 更新self._foodId
end

-- 打开煮菜界面
function GuildActivityMainView:gotoCooking()
	if not GuildActMainModel:getInGVEOpenPeriod() then
		self.panel_1.panel_zhuozi.btn_1:getUpPanel().panel_red:visible(false)
		self.panel_1.panel_zhuozi.btn_1:setTap(function() 
			WindowControler:showTips( GameConfig.getLanguage("#tid_guild_065"))
		end) 
	else
		local isShow = GuildActMainModel:isShowCookingRedPoint()
		self.panel_1.panel_zhuozi.btn_1:getUpPanel().panel_red:visible(isShow)
		self.panel_1.panel_zhuozi.btn_1:setTap(c_func(self.openCookingView, self)) 
	end
end

--=================================================================================
--=================================================================================
function GuildActivityMainView:initViewAlign()
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_1, UIAlignTypes.Left)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_3, UIAlignTypes.Left)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zhulian, UIAlignTypes.Left)
 	
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2, UIAlignTypes.Right)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon, UIAlignTypes.LeftTop)
 	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1.panel_zhuozi, UIAlignTypes.MiddleBottom)
end

function GuildActivityMainView:updateUI()
	-- TODO
end

function GuildActivityMainView:deleteMe()
	-- TODO

	GuildActivityMainView.super.deleteMe(self);
end

return GuildActivityMainView;
