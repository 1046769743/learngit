--
--Author:      zhuguangyuan
--DateTime:    2018-04-22 09:40:53
--Description: 仙盟科技-无极阁建筑 主界面
--

local GuildSkillMainView = class("GuildSkillMainView", UIBase);

function GuildSkillMainView:ctor(winName)
    GuildSkillMainView.super.ctor(self, winName)
end

function GuildSkillMainView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildSkillMainView:registerEvent()
	GuildSkillMainView.super.registerEvent(self);
	EventControler:addEventListener(GuildEvent.GUILD_THEME_LEVEL_UP_SUCCEED, self.updateUI, self)
end

function GuildSkillMainView:initData()
	self.labelNum = FuncGuild.infinitePavilionThemeMaxNum
	self.defaultSelectedIndex = tonumber(GuildModel:selectedSkillThemeId())
	self.themeName = FuncGuild.themeName
	self.stageName = FuncGuild.stageName
	-- 标签到主题id 的映射
	self.indexToThemeIdMap = FuncGuild.indexToThemeIdMap
end

function GuildSkillMainView:initView()
	self:registerLabelEvent()
	self.btn_sx:setTap(c_func(self.popTotalPropertiesView,self))
	self.btn_jy:setTap(c_func(self.popSkillLevelUpView,self))
	self.btn_back:setTap(c_func(self.startHide,self))
	self.btn_wen:setTap(c_func(self.showRuleView,self))
	-- self.mc_res:showFrame(4)
end

function GuildSkillMainView:showRuleView()
	WindowControler:showWindow("GuildRulseView",FuncGuild.Help_Type.WUJIGE)
end
-- 弹出总属性界面
function GuildSkillMainView:popTotalPropertiesView()
	WindowControler:showWindow("GuildSkillPropertiesView",FuncGuild.effectZoneType.GLOBAL)
end

-- 弹出精研界面
-- 盟主或者副盟主才可精研
-- 解锁后才可精研
-- 达到最大精研阶段后不可精研
function GuildSkillMainView:popSkillLevelUpView()
	local refine = FuncGuild.getGroupRightData(GuildModel:getMyRight(),"refine")
	if refine ~= 1 then
		WindowControler:showTips("盟主或者副盟主可精研")
		return
	end
	local guildStage = GuildModel:getCurStageInGuild( self.selectedThemeId )
	if not guildStage then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_guild_skill_11",self.stageName[tonumber(self.selectedThemeData.buildLv or 1)]))
		return
	end
	local newStageData = FuncGuild.getGroupDataByGroupAndStageId( self.selectedThemeId,guildStage+1 )
	if not newStageData then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_skill_18"))
		return
	end
	WindowControler:showWindow("GuildSkillThemeLevelUpView",self.selectedThemeId)
end

-- 修炼当前技能
function GuildSkillMainView:practiceCurSkill()
	if self.hasSentRequest then
		return 
	end
	-- 没有待修炼的技能 则返回
	local toLightenId = GuildModel:getToLigntenSkillId(self.selectedThemeId)
	if not toLightenId then
		return
	end

	-- 未解锁 仙盟阶段比玩家阶段低 都不能修炼
	local guildStage =  GuildModel:getCurStageInGuild( self.selectedThemeId )
	local playerStage =  GuildModel:getNextSkillStageAboutPlayer( self.selectedThemeId )
	if not guildStage then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_guild_skill_5",self.stageName[tonumber(self.selectedThemeData.buildLv or 1)]))
		return
	end
	if tonumber(guildStage) < tonumber(playerStage) then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_skill_19"))
		return
	end

	local function practiceSkillCallBack( serverData )
		echo("_________ 修炼技能返回 ______________ ")
		self.hasSentRequest = false
		if not serverData or serverData.error then
			return 
		end
		local data = serverData.result.data
		dump(data, "========= 修炼技能返回 =========")
		self.practiceMcCurrentView.btn_xl:setTouchEnabled(false)

		self:playAnimation()
		-- 注意如果本阶段修炼完成,弹出修炼完成界面
		-- local isReach,curStage = GuildModel:checkIfReachNewStage(self.selectedThemeId)
		-- if isReach then
		-- 	WindowControler:showWindow("GuildSkillThemeReachNewGradeView",self.selectedThemeId,curStage)
		-- end
		-- self:updateUI()
	end
	if not self.hasSentRequest then
		self.hasSentRequest = true
		GuildServer:skillLevelUp(toLightenId,practiceSkillCallBack)
	end
end

-- 注册页签的点击函数
function GuildSkillMainView:registerLabelEvent()
	for i=1,self.labelNum do
		self.panel_right["mc_g"..i]:setTouchedFunc(c_func(self.selectOneLabel, self,i),nil,true)
	end
	self:selectOneLabel(self.defaultSelectedIndex)
end

-- 更新页签的选中效果
function GuildSkillMainView:selectOneLabel( _toSelectIndex )
	if _toSelectIndex == self.selectedLabelIndex then
		return
	end
	self.selectedLabelIndex = _toSelectIndex
	self.selectedThemeId = self.indexToThemeIdMap[self.selectedLabelIndex]
	GuildModel:recordSelectedSkillThemeId(self.selectedThemeId)
	self:updateData()

	for i=1,self.labelNum do
		local choosedView = self.panel_right["mc_g"..i]
		if i == self.selectedLabelIndex then
			choosedView:showFrame(2)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
			-- choosedView:getCurFrameView().panel_red:visible(false)
		else
			choosedView:showFrame(1)
			choosedView:getCurFrameView().btn_1:setBtnStr(self.themeName[i],"txt_1")
			-- choosedView:getCurFrameView().panel_red:visible(false)
		end
	end
	-- 突然被踢出仙盟的情况处理
	if not GuildControler:touchToMainview() then
		return 
	end
	self:updateCenterPanel()
end

function GuildSkillMainView:updateData()
	self.curPlayerStageId = GuildModel:getNextSkillStageAboutPlayer( self.selectedThemeId )
	if not self.curPlayerStageId then
		self.curPlayerStageId = GuildModel:getCurStageAboutPlayer( self.selectedThemeId )
	end
	self.selectedThemeData = FuncGuild.getGroupDataByGroupAndStageId( self.selectedThemeId,self.curPlayerStageId )
	-- dump(self.selectedThemeData, "主题数据")
end

-- 刷新中部技能面板
-- 及底部修炼当前技能耗费的 资源数量
function GuildSkillMainView:updateCenterPanel()
	-- 根据配置显示不同帧 不同帧只有技能位置不同 
	local showFrameIndex = tonumber(self.selectedThemeData.view or 1)
	self.mc_1:showFrame(showFrameIndex)
	self.currentView = self.mc_1:getCurFrameView()

	-- 显示中部四个技能及状态
	local hasLightendId = GuildModel:getHasLigntenSkillId( self.selectedThemeId )
	if not hasLightendId then
		hasLightendId = 0
	end
	local toLightenId = GuildModel:getToLigntenSkillId(self.selectedThemeId)

	local skillArr = self.selectedThemeData.skillId
	local len = table.length(skillArr)
	for i=0,4 do
		self.currentView["mc_x"..i]:setVisible(true)
	end
	for i=1,len do
		self.currentView["panel_"..i].ctn_1:removeAllChildren()
		local skillId = skillArr[i]
		local skillData = FuncGuild.getSkillDataBySkillId( skillId )
		-- self.currentView["panel_"..i].txt_1:setString(GameConfig.getLanguage(skillData.description))

		-- 属性的三种状态对应123帧,增减量的三种状态对应456三帧 
		local isProperty,adjustment = true,0
		if skillData.effect2 then
			isProperty = false
			adjustment = 3
		end
		if tonumber(skillId) <= tonumber(hasLightendId) then
			self.currentView["panel_"..i].mc_1:showFrame(3+adjustment)
			self.currentView["mc_x"..(i-1)]:showFrame(2)
		elseif tostring(skillId) == tostring(toLightenId) then
			self.index = i
			self.adjustment = adjustment
			local animation1 = self:createUIArmature("UI_xianmeng_keji", "UI_xianmeng_keji_daiji",self.currentView["panel_"..i].ctn_1, true,GameVars.emptyFunc)
			self.currentView["panel_"..i].mc_1:showFrame(2+adjustment)
			self.currentView["mc_x"..(i-1)]:showFrame(2)
		else
			self.currentView["panel_"..i].mc_1:showFrame(1+adjustment)
			self.currentView["mc_x"..(i-1)]:showFrame(1)
		end
		local cView = self.currentView["panel_"..i].mc_1:getCurFrameView()
		cView.txt_1:setString(GameConfig.getLanguage(skillData.description))

		if not toLightenId then
			self.currentView["mc_x4"]:setVisible(false)
		end
		if skillData.condition == nil and skillData.level == 1 then
			self.currentView["mc_x0"]:setVisible(false)
		end
	end

	-- 玩家当前主题是否圆满升级
	local guildStage,playerStage = 0,1
	-- 显示修炼按钮状态
	local totalStages = FuncGuild.getGroupTotalStagesByGroupId( self.selectedThemeId )
	guildStage =  GuildModel:getCurStageInGuild( self.selectedThemeId ) or 0
	playerStage =  GuildModel:getNextSkillStageAboutPlayer( self.selectedThemeId ) or totalStages

	if not toLightenId then
		self.mc_2:showFrame(2)
		self.practiceMcCurrentView = self.mc_2:getCurFrameView()
		self.practiceMcCurrentView.txt_1:setString(GameConfig.getLanguage("#tid_guild_skill_2"))
	else
		self.mc_2:showFrame(1)
		self.practiceMcCurrentView = self.mc_2:getCurFrameView()

		-- 更新显示 点亮新技能需消耗的资源
		local skillData = FuncGuild.getSkillDataBySkillId( toLightenId )
		local toLightenCostArr = skillData.cost
		dump(toLightenCostArr, "toLightenCostArr")
		local cost1 = toLightenCostArr[1]
		local costArr = string.split(cost1,",")
		local costType = costArr[1] -- 暂时默认都用贡献,若要改 falsh图标也要改
		local costValue = costArr[2]
		self.practiceMcCurrentView.txt_1:setString(costValue)
		if tonumber(costValue) > tonumber(UserModel:getGuildCoin()) then
			self.practiceMcCurrentView.txt_1:setColor(cc.c3b(255,0,0))
		else
			self.practiceMcCurrentView.txt_1:setColor(cc.c3b(255,246,219))
		end

		self.practiceMcCurrentView.btn_xl:setTap(c_func(self.practiceCurSkill,self))
		-- 玩家换了仙盟  当前仙盟当前主题的阶段比玩家曾经升级到的阶段要小
		if playerStage > guildStage then
			echo("___ 玩家换了仙盟  当前仙盟当前主题的阶段比玩家曾经升级到的阶段要小 ____")
			self.practiceMcCurrentView.btn_xl:setTouchEnabled(false)
			-- FilterTools.setGrayFilter( self.practiceMcCurrentView.btn_xl )
		else
			self.practiceMcCurrentView.btn_xl:setTouchEnabled(true)
			-- FilterTools.clearFilter( self.practiceMcCurrentView.btn_xl  )
		end
	end

	-- 上方文字提示 只跟当前主题是否解锁有关
	if not guildStage or guildStage == 0 then
		self.panel_up.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_guild_skill_9",
								self.stageName[tonumber(self.selectedThemeData.buildLv or 1)]))
	else
		self.panel_up.txt_1:setString(GameConfig.getLanguageWithSwap("#tid_guild_skill_10",
						self.themeName[tonumber(self.selectedThemeId)],self.stageName[tonumber(playerStage)]))
	end
	self.panel_up.mc_up:showFrame(totalStages)
	local currentView = self.panel_up.mc_up:getCurFrameView()
	echo("_________ guildStage,playerStage  __________",guildStage,playerStage)
	for i=1,totalStages do
		if i == tonumber(playerStage) then
			currentView["mc_"..i]:showFrame(3)
		elseif guildStage == 0 then
			currentView["mc_"..i]:showFrame(1)
		elseif guildStage >= i then
			currentView["mc_"..i]:showFrame(2)
		else
			currentView["mc_"..i]:showFrame(1)
		end
	end
end

function GuildSkillMainView:playAnimation()
	self:disabledUIClick()
	self.currentView["panel_"..self.index].ctn_1:removeAllChildren()
	local animation2 = self:createUIArmature("UI_xianmeng_keji", "UI_xianmeng_keji_baozong",self.currentView["panel_"..self.index].ctn_1, false,GameVars.emptyFunc)
	local isReach,curStage = GuildModel:checkIfReachNewStage(self.selectedThemeId)
	animation2:registerFrameEventCallFunc(59,1,function()
		self:resumeUIClick()
		if isReach then
			WindowControler:showWindow("GuildSkillThemeReachNewGradeView",self.selectedThemeId,curStage)
		end
		self:updateUI()
	end)
end

function GuildSkillMainView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_t,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop) 
	
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop) 
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_res,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_1,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_2,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_up,UIAlignTypes.MiddleTop)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_sx,UIAlignTypes.LeftTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_jy,UIAlignTypes.LeftBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2,UIAlignTypes.MiddleBottom)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1,UIAlignTypes.MiddleTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.Middle)
    FuncCommUI.setScale9Align(self.widthScreenOffset,self.panel_right,UIAlignTypes.Right,0,1)
end

function GuildSkillMainView:updateUI()
	self:updateData()
	self:updateCenterPanel()
end

function GuildSkillMainView:deleteMe()
	GuildModel:recordSelectedSkillThemeId(self.selectedThemeId,true)
	GuildSkillMainView.super.deleteMe(self);
end

return GuildSkillMainView;
