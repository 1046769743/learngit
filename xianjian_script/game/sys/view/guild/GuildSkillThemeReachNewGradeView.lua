--
--Author:      zhuguangyuan
--DateTime:    2018-04-22 09:35:17
--Description: 仙盟科技 成员将某主题下 本阶段的技能修炼完毕 换下一等级 过渡界面
-- 展示下一阶段的技能点 右侧mc 展示的却是下下阶段的


local GuildSkillThemeReachNewGradeView = class("GuildSkillThemeReachNewGradeView", UIBase);

function GuildSkillThemeReachNewGradeView:ctor(winName,themeId,stageId)
    GuildSkillThemeReachNewGradeView.super.ctor(self, winName)
    self.selectedThemeId = themeId
    self.curStage = stageId
    echo("______ 当前阶段 ________",stageId)
end

function GuildSkillThemeReachNewGradeView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function GuildSkillThemeReachNewGradeView:registerEvent()
	GuildSkillThemeReachNewGradeView.super.registerEvent(self);
	EventControler:addEventListener(GuildEvent.CLOSE_ALL_VIEW_UI, self.press_btn_close, self)
end

function GuildSkillThemeReachNewGradeView:initData()
	self.nextStageData = FuncGuild.getGroupDataByGroupAndStageId( self.selectedThemeId,self.curStage+1 )
	dump(self.nextStageData, "精研主题数据")
end

function GuildSkillThemeReachNewGradeView:initView()
	-- 根据配置显示不同帧 不同帧只有技能位置不同 
	local showFrameIndex = tonumber(self.nextStageData.view or 1)
	self.mc_1:showFrame(showFrameIndex)
	self.currentView = self.mc_1:getCurFrameView()

	self.mc_2:showFrame(self.nextStageData.level)

	-- 显示中部四个技能及状态
	local hasLightendId = GuildModel:getHasLigntenSkillId( self.selectedThemeId )
	if not hasLightendId then
		hasLightendId = 0
	end
	local toLightenId = GuildModel:getToLigntenSkillId(self.selectedThemeId)
	local skillArr = self.nextStageData.skillId
	local len = table.length(skillArr)
	for i=1,len do
		local skillId = skillArr[i]
		local skillData = FuncGuild.getSkillDataBySkillId( skillId )
		self.currentView["panel_"..i].mc_1:showFrame(1)
		local txt = self.currentView["panel_"..i].mc_1:getCurFrameView().txt_1
		txt:setString(GameConfig.getLanguage(skillData.description))
	end

	local lockAni = self:createUIArmature("UI_xianmeng", "UI_xianmeng_jianchushengji",self.ctn_1, false,GameVars.emptyFunc)
	lockAni:visibleBone("d", false)
	lockAni:registerFrameEventCallFunc(14,1,function()
		self:registClickClose(-1, c_func(self.press_btn_close,self))
	end)
	
	-- local view = UIBaseDef:cloneOneView(self.UI_1); 
	-- FuncArmature.changeBoneDisplay(lockAni,"a",self.mc_build)
	-- FuncArmature.changeBoneDisplay(lockAni,"c",self.txt_1)
	-- FuncArmature.changeBoneDisplay(lockAni,"b",self.txt_2)
	-- FuncArmature.changeBoneDisplay(lockAni,"e",self.rich_3)
	-- FuncArmature.changeBoneDisplay(lockAni,"f",self.txt_jixu)
	-- self.mc_build:setPosition(cc.p(-275/2,189/2))
	-- self.txt_1:setPosition(cc.p(0,0))
	-- self.txt_2:setPosition(cc.p(0,0))
	-- self.rich_3:setPosition(cc.p(-100,0))
	-- self.txt_jixu:setPosition(cc.p(-40,0))
	-- self.panel_lvjian:setVisible(false)
end

function GuildSkillThemeReachNewGradeView:initViewAlign()
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_2,UIAlignTypes.MiddleTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_1,UIAlignTypes.MiddleTop) 
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.txt_1,UIAlignTypes.MiddleTop) 
end

function GuildSkillThemeReachNewGradeView:updateUI()
	-- TODO
end

function GuildSkillThemeReachNewGradeView:press_btn_close( ... )
	self:startHide()
end

function GuildSkillThemeReachNewGradeView:deleteMe()
	GuildSkillThemeReachNewGradeView.super.deleteMe(self);
end

return GuildSkillThemeReachNewGradeView;
