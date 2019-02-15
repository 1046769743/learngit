--guan
--2016.03.26
--2016.06.05 换ui 特效
--2017.4.8 改成目标系统 

local QuestMainView = class("QuestMainView", UIBase)

local QUEST_TYPE = FuncQuest.QUEST_TYPE

function QuestMainView:ctor(winName, showType)
	echo("__________QuestMainView________")
	QuestMainView.super.ctor(self, winName)
	self._showQuestType = nil;

	if showType ~= nil then
		self._forceShow = tonumber(showType);
	else
		local _type =  TargetQuestModel.selectQuestIndex
		if _type then
			self._forceShow = tonumber(_type)
		end
	end

	self._btnPos = {} -- 存四个页签的位置
end

function QuestMainView:onSelfPop(showType)
	if showType then
		self._forceShow = showType
		self:initUI()
	end
end

function QuestMainView:loadUIComplete()
	self:registerEvent()
	self:initUI();


	-- local sysOpenTable = FuncCommon.getSysOpenData();
	-- dump(sysOpenTable.PartnerView,"系统开启")
end

--当退出战斗时 需要缓存的数据 以便 恢复这个ui时 记录数据
function QuestMainView:getEnterBattleCacheData()
    local retTable = {};
    retTable.lastSelect = self._showQuestType;

    return retTable;
end

--当退出战斗后 恢复这个ui时 ,会把这个cacheData传递给ui
function QuestMainView:onBattleExitResume(cacheData)
    -- dump(cacheData, "-----cacheData------");
    self:setLeftListUI(cacheData.lastSelect) 
end

function QuestMainView:registerEvent()
    self.btn_back:setTouchedFunc(c_func(self.press_btn_back, self));
    self.panel_yeqian.mc_1:setTouchedFunc(c_func(self.setLeftListUI, self, QUEST_TYPE.TARGET));
    self.panel_yeqian.mc_2:setTouchedFunc(c_func(self.setLeftListUI, self, QUEST_TYPE.EVERYDAY));
    self.panel_yeqian.mc_3:setTouchedFunc(c_func(self.setLeftListUI, self, QUEST_TYPE.ACHIEVEMENT));
    self.panel_yeqian.mc_4:setTouchedFunc(c_func(self.setLeftListUI, self, QUEST_TYPE.UPGRAGE));

    EventControler:addEventListener(QuestEvent.ACHIEVEMENT_GET_REWARD,
        self.setRedPoint, self);
    EventControler:addEventListener(QuestEvent.AFTER_QUEST_GET_REWARD,
        self.setRedPoint, self);
    EventControler:addEventListener(QuestEvent.UPGRADE_GET_REWARD,
        self.setRedPoint, self);
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.setRedPoint, self);
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.setRedPoint, self);

    EventControler:addEventListener(BiographyUEvent.EVENT_REFRESH_UI, self.refreshUI, self)
    self:viewAdjust();
end

function QuestMainView:viewAdjust()
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back, UIAlignTypes.RightTop);
    
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_1, UIAlignTypes.RightTop);
    FuncCommUI.setViewAlign(self.widthScreenOffset,self.mc_title, UIAlignTypes.LeftTop);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yeqian, UIAlignTypes.LeftTop, 0.7);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_zhui, UIAlignTypes.LeftTop,0.7);

    -- FuncCommUI.setScale9Align(self.widthScreenOffset,self.scale9_resdi, UIAlignTypes.MiddleTop, 1, nil);
end

-- 刷新界面
function QuestMainView:refreshUI()
	local questType = TargetQuestModel.selectQuestIndex
	if not self:isTabOpen(questType) then
		questType = self:getEntryShowQuestType()
	end
	
	self:setLeftListUI(questType, true)
end

function QuestMainView:initUI()
	if self._forceShow and self:isTabOpen(self._forceShow) then
		self:setLeftListUI(self._forceShow)
	else
		local questType = self:getEntryShowQuestType()
		self:setLeftListUI(questType)
	end
end

-- 更新页签位置
function QuestMainView:updateTabPos()
	if empty(self._btnPos) then
		-- 存一下页签位置
		for i=1,4 do
			local redPosX, redPosY = self.panel_yeqian["panel_red" .. i]:getPosition()
			local mcPosX, mcPosY = self.panel_yeqian["mc_"..i]:getPosition()

			self._btnPos[i] = {
				redPos = cc.p(redPosX, redPosY),
				mcPos = cc.p(mcPosX, mcPosY),
			}
		end
	end

	local idx = 0
	for i=1,4 do
		local mc = self.panel_yeqian["mc_" .. i]
		local red = self.panel_yeqian["panel_red" .. i]
		if self:isTabOpen(i) then
			idx = idx + 1

			mc:visible(true)
			red:visible(true)

			mc:setPosition(self._btnPos[idx].mcPos)
			red:setPosition(self._btnPos[idx].redPos)
		else
			mc:visible(false)
			red:visible(false)
		end
	end

	if idx ~= 0 then
		self.panel_yeqian.panel_biao:setPositionY(self._btnPos[idx].mcPos.y - 81)
	end
end

-- 返回每个页签是否显示
function QuestMainView:isTabOpen(idx)
	if idx == QUEST_TYPE.EVERYDAY then
		return DailyQuestModel:isOpen()
	elseif idx == QUEST_TYPE.ACHIEVEMENT then
		return BiographyModel:isHasTaskInHand()
	end

	return true
end

function QuestMainView:setLeftListUI(index,force)
	if not force and index == self._showQuestType then 
		return
	end
	
	TargetQuestModel:selectQuestType(index)

	local yeqian = self.panel_yeqian;
	--都整成不选中状态
	for i = 1, 4 do
		yeqian["mc_" .. tostring(i)]:showFrame(1);
	end

	--第index帧搞成选中的
	yeqian["mc_" .. tostring(index)]:showFrame(2);
	--中间的界面
	self:showUI(index);

	self._showQuestType = index;
	
	self:updateTabPos()

	self:setRedPoint();
end

function QuestMainView:setRedPoint()
	local yeqian = self.panel_yeqian;
	--都整成不选中状态
	for i = 1, 4 do
		local redPointVisible = self:isRedPointShowByIndex(i);
		yeqian["panel_red" .. tostring(i)]:setVisible(redPointVisible);
	end
	yeqian["panel_red" .. tostring(self._showQuestType)]:setVisible(false);
end

function QuestMainView:isRedPointShowByIndex(index)
	if index == QUEST_TYPE.ACHIEVEMENT then 
		-- return TargetQuestModel:isCurAchievementIndexFinish();
		-- 奇侠传记一定不显示
		return false
	elseif index == QUEST_TYPE.TARGET then 
		return TargetQuestModel:isHaveFinishQuest() or TargetQuestModel:ishasAchieveCanGet()
	elseif  index == QUEST_TYPE.EVERYDAY then 
		return DailyQuestModel:isHaveFinishQuest();
	else
		return TargetQuestModel:isHaveUpgradeReward();
	end  

end

--第一次进入应该显示哪个
function QuestMainView:getEntryShowQuestType()
	if TargetQuestModel:isHaveFinishQuest() or TargetQuestModel:ishasAchieveCanGet() then 
		return QUEST_TYPE.TARGET;
	end 

	if DailyQuestModel:isHaveFinishQuest() then 
		return QUEST_TYPE.EVERYDAY;
	end

	if TargetQuestModel:isHaveUpgradeReward() then 
		return QUEST_TYPE.UPGRAGE;
	end

	return QUEST_TYPE.TARGET;
end

function QuestMainView:showUI(index)
	self.mc_1:showFrame(index);
	local ctn = self.mc_1.currentView.ctn_1;

	local viewName = "QuestTargetView";
	
	if index == QUEST_TYPE.ACHIEVEMENT then 
		viewName = "QuestBiographyView";
	elseif index == QUEST_TYPE.TARGET then
		viewName = "QuestTargetView";
	elseif index == QUEST_TYPE.EVERYDAY then
		viewName = "QuestEveryDayView";
	elseif index == QUEST_TYPE.UPGRAGE then
		viewName = "QuestUpgradeView";
	else 
		local warningStr = string.format("warning!!!!!!!!QuestMainView:showUI(index) index = %d", index);
		echoWarn(warningStr);
	end 

	local childNum = ctn:getChildrenCount();
	if childNum == 0 then 
	    local viewName = WindowsTools:createWindow(viewName);
	    -- viewName:setPosition( cc.p(0, 0) )
	    ctn:addChild(viewName);

	end 
end
function QuestMainView:press_btn_back()
	DailyQuestModel:setquestId(nil)
	TargetQuestModel:setSelectIndex(nil)
	DailyQuestModel:setJumToquestId(nil)
	TargetQuestModel:mainQuestChangeCallBack()
	self:startHide()
end

return QuestMainView