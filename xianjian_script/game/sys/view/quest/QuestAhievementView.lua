--guan
--2017.4.8 

local QuestAhievementView = class("QuestAhievementView", UIBase)


function QuestAhievementView:ctor(winName)
	echo("__________QuestAhievementView________")
	QuestAhievementView.super.ctor(self, winName)
end

function QuestAhievementView:loadUIComplete()
	self:registerEvent()

	self._achievementItem = self.panel_1.panel_copy;
	self._achievementItem:setVisible(false);

	self._list = self.panel_1.scroll_1;
	self:initUI();
end

function QuestAhievementView:registerEvent()
    EventControler:addEventListener(QuestEvent.AFTER_QUEST_GET_REWARD,
        self.resetUI, self);
end

function QuestAhievementView:resetUI()
	self:initUI();
end

function QuestAhievementView:initUI()
	local allAchievements = self:getAllAchievement();
	local fakeAchieveMent = {1};

	self._allAchievements = allAchievements;


	local createAchievementItemFunc = function (itemData)
		local baseCell = UIBaseDef:cloneOneView(self._achievementItem);
		self:updateAchievementUI(baseCell, itemData);
		return baseCell;
	end

	local scrollParams = { 
		{
	        data = allAchievements,
	        createFunc = createAchievementItemFunc,
	        offsetX = 70,
	        offsetY = 15,
	        widthGap = 0,
	        heightGap = 0,
	        itemRect = {x = 0, y = -100, width = 773, height = 100},
	    },	    
	};

	self._list:styleFill(scrollParams);
	self._list:hideDragBar();

	-- 没有则显示伞 有则不显示
	self.panel_1.panel_san:visible(#allAchievements == 0)
end

function QuestAhievementView:updateAchieveCell(baseCell, itemData)
	local questId = itemData;

    local iconName = FuncQuest.readMainlineQuest(questId, "icon");
    local iconPath = FuncRes.iconQuest(iconName)
    local iconSp = display.newSprite(iconPath); 

    baseCell.ctn_1:addChild(iconSp);

    FuncCommUI.regesitShowRecordView(baseCell, questId, true, 
    	c_func(self.onAchievementTouch, self, baseCell, questId))

	if TargetQuestModel:isNewAchievementQuestId(questId) == nil then
		baseCell.panel_new:setVisible(false);
	end  

end

function QuestAhievementView:onAchievementTouch(baseCell, questId)
    TargetQuestModel:defNewAchievementQuestId(questId)
    baseCell.panel_new:setVisible(false);
end

function QuestAhievementView:updateAchievementUI(baseCell, achieveData)
	local timeStr = achieveData.date;
	local timeLabel = baseCell.txt_1;

	timeLabel:setString(timeStr);

	--list
	baseCell.panel_1:setVisible(false);
	local createFunc = function (itemData)
		local baseCell = UIBaseDef:cloneOneView(baseCell.panel_1);
		self:updateAchieveCell(baseCell, itemData);
		return baseCell;
	end

	local scrollParams = { 
		{
	        data = achieveData.achievedId,
	        createFunc = createFunc,
	        -- perNums = 4,
	        offsetX = 10,
	        offsetY = 5,
	        widthGap = 25,
	        heightGap = 0,
	        itemRect = {x = 0, y = 0, width = 78, height = 82},
	    },	    
	};

	baseCell.scroll_list:styleFill(scrollParams);
	baseCell.scroll_list:hideDragBar();
	baseCell.scroll_list:setCanScroll(false)

	--是第一个
	if self._allAchievements[1] == achieveData then 
		baseCell.panel_lashen1.panel_4:setVisible(false);
	end 

	--是最后一个
	if self._allAchievements[#self._allAchievements] == achieveData then 
		baseCell.panel_lashen1.panel_2:setVisible(false);
	end 
end

--得到所有的成就
function QuestAhievementView:getAllAchievement()
	return TargetQuestModel:getAchievementData();
end

return QuestAhievementView