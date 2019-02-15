--
--Author:      zhuguangyuan
--DateTime:    2018-04-22 09:34:32
--Description: 仙盟科技-无极阁建筑 盟主或者副盟主 开启某一主题的新阶段 的操作界面
--


local GuildSkillThemeLevelUpView = class("GuildSkillThemeLevelUpView", UIBase);

function GuildSkillThemeLevelUpView:ctor(winName,themeId)
    GuildSkillThemeLevelUpView.super.ctor(self, winName)
    self.selectedThemeId = themeId
end

function GuildSkillThemeLevelUpView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildSkillThemeLevelUpView:registerEvent()
	GuildSkillThemeLevelUpView.super.registerEvent(self);
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self:registClickClose("out")
end

function GuildSkillThemeLevelUpView:initData()

end

function GuildSkillThemeLevelUpView:initView()
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_guild_skill_7"))
	self.UI_1.mc_1:showFrame(1)

	local curGuildStage = GuildModel:getCurStageInGuild( self.selectedThemeId )
	self.curStage = curGuildStage
	local themeData = FuncGuild.getGroupDataByGroupAndStageId( self.selectedThemeId,curGuildStage )
	local nextGuildStage = GuildModel:getNextStageInGuild( self.selectedThemeId )
	self.curThemeData = themeData
	local nextStageDesc = themeData.next
	self.txt_2:setString(GameConfig.getLanguage(nextStageDesc))

	if not nextGuildStage then
		-- 满级后 精研按钮不可点击 即不会出现这个view 不会走这里
		-- self.txt_2:setString("已达到满级")
	else
		local upStageCost = themeData.costStone
		local hasNum = GuildModel:getOwnGuildStoneNum()
		self.mc_1:showFrame(1)
		if not upStageCost then
			upStageCost = themeData.costJade
			hasNum = GuildModel:getOwnGuildJadeNum()
			self.mc_1:showFrame(2)
		end
		echo("_________upStageCost ________",upStageCost)
		self.txt_1:setString(upStageCost)

		local isMoneyEnough = false
		if tonumber(hasNum) >= tonumber(upStageCost) then
			isMoneyEnough = true
		end

		local buildingsLevel = GuildModel:getBuildsLevel()
		dump(buildingsLevel, "===========================")
		local level = 1
		if buildingsLevel and buildingsLevel[tonumber(FuncGuild.guildBuildType.MOUNTAINBARRIER)] then  -- 建筑6 表示无极阁
			level = buildingsLevel[tonumber(FuncGuild.guildBuildType.MOUNTAINBARRIER)]
		end
		local isBuildingLevelEnough = (level >= themeData.buildLv)
		self.UI_1.mc_1:getCurFrameView().btn_1:setTap(c_func(self.skillGroupLevelUp,self,isMoneyEnough,isBuildingLevelEnough))
	end

	self.mc_next1:showFrame(tonumber(curGuildStage))
	local themeData = FuncGuild.getGroupDataByGroupAndStageId( self.selectedThemeId,tonumber(nextGuildStage) )
	if themeData then
		self.mc_next2:showFrame(tonumber(nextGuildStage))
	else
		self.mc_next2:showFrame(1)
	end
end

function GuildSkillThemeLevelUpView:skillGroupLevelUp(isMoneyEnough,isBuildingLevelEnough)
	if not isBuildingLevelEnough then
		WindowControler:showTips(GameConfig.getLanguageWithSwap("#tid_guild_skill_17",self.curThemeData.buildLv))
		return
	end
	if not isMoneyEnough then
		WindowControler:showTips(GameConfig.getLanguage("#tid_guild_skill_3"))
		return
	end
	local function skillLevelUpCallBack( serverData )
		self.hasSentRequest = false
		if not serverData or serverData.error then
			return
		else
			local data = serverData.result.data
			dump(data, " ========= 精研返回数据 =================")
			GuildModel:updateSkillGroupsData( data )
			GuildModel:updateGuildResource( data )

			
			local eventchat = {
				param1 =  self.selectedThemeId ,--self.themeName[tonumber(self.selectedThemeId)],
				param2 =  self.curStage+1 ,--self.stageName[tonumber(self.curStage+1)],
				time   = TimeControler:getServerTime(),
				type   = 10,
			}
			GuildModel:insertDataToList(eventchat)

			WindowControler:showWindow("GuildSkillThemeReachNewGradeView",self.selectedThemeId,self.curStage)
			EventControler:dispatchEvent(GuildEvent.REFRESH_GUILD_RESOURCE_EVENT, {currentShopId = FuncShop.SHOP_TYPES.GUILD_SHOP}) 
			EventControler:dispatchEvent(GuildEvent.GUILD_THEME_LEVEL_UP_SUCCEED) 
			self:startHide()

-- - " ========= 精研返回数据 =================" = {
-- -     "jade"        = 490
-- -     "skillGroups" = {
-- -         "2" = 2
-- -     }
-- -     "stone"       = 2390
-- - }			
		end
	end
	if not self.hasSentRequest then
		self.hasSentRequest = true
		GuildServer:skillGroupLevelUp(self.selectedThemeId,skillLevelUpCallBack)
	end
end

function GuildSkillThemeLevelUpView:initViewAlign()
	-- TODO
end

function GuildSkillThemeLevelUpView:updateUI()
	-- TODO
end

function GuildSkillThemeLevelUpView:deleteMe()
	GuildSkillThemeLevelUpView.super.deleteMe(self);
end

return GuildSkillThemeLevelUpView;
