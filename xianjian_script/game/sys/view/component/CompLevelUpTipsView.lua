--[[
	Author: TODO
	Date:2018-08-06
	Description: TODO
]]

local CompLevelUpTipsView = class("CompLevelUpTipsView", UIBase);

function CompLevelUpTipsView:ctor(winName, isLevelUp)
    CompLevelUpTipsView.super.ctor(self, winName)

    self.isLevelUp = isLevelUp
end

function CompLevelUpTipsView:loadUIComplete()
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function CompLevelUpTipsView:registerEvent()
	CompLevelUpTipsView.super.registerEvent(self);

	self:registClickClose("out")
	self.btn_close:setTouchedFunc(c_func(self.startHide, self))
end

function CompLevelUpTipsView:initData()
	-- TODO
end

function CompLevelUpTipsView:initView()
	if self.isLevelUp then
		self.mc_1:showFrame(1)
		self.mc_1.currentView.panel_1:setTouchedFunc(c_func(self.gotoEveryDayTask, self))
		self.mc_1.currentView.panel_2:setTouchedFunc(c_func(self.gotoJDHY, self))
		self.mc_1.currentView.panel_3:setTouchedFunc(c_func(self.gotoJingYing, self))
	else
		self.mc_1:showFrame(2)
		self.mc_1.currentView.panel_1:setTouchedFunc(c_func(self.gotoJDHY, self))
		self.mc_1.currentView.panel_2:setTouchedFunc(c_func(self.gotoJingYing, self))
	end
end

function CompLevelUpTipsView:gotoEveryDayTask()
	local isOpen, conditionValue, conditionType, lockTip = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST)
	if isOpen then
		WindowControler:showWindow("QuestMainView", FuncQuest.QUEST_TYPE.EVERYDAY)
	else
		WindowControler:showTips(lockTip)
	end
end

function CompLevelUpTipsView:gotoJingYing()
	local isOpen, lockedTips = WorldModel:isOpenElite()
    if isOpen then
        EliteMainModel:enterEliteExploreScene()
    else
        -- local raidData = FuncChapter.getRaidDataByRaidId("10306")
        -- local str1 = GameConfig.getLanguage(raidData.name)
        -- local chapter = FuncChapter.getChapterByStoryId(tostring(raidData.chapter))
        -- local section = FuncChapter.getSectionByRaidId("10306")
        -- local str2 = chapter.."-"..section 
        -- local _str = string.format(GameConfig.getLanguage("#tid_partner_ui_001"),str2,str1)
        WindowControler:showTips(lockedTips)
    end
end

function CompLevelUpTipsView:gotoJDHY()
    if WorldModel:isOpenPVEMemory() then
        WorldControler:showPVEListView()
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_partner_ui_002"))
    end
end

function CompLevelUpTipsView:initViewAlign()
	-- TODO
end

function CompLevelUpTipsView:updateUI()
	-- TODO
end

function CompLevelUpTipsView:deleteMe()
	-- TODO

	CompLevelUpTipsView.super.deleteMe(self);
end

return CompLevelUpTipsView;
