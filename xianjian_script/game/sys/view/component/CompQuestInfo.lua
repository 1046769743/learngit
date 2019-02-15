--guan
--2017.4.19
local CompQuestInfo = class("CompQuestInfo", UIBase);

--界面对应的任务类型
local winNameQuestIdMap = {
	Target = {
		WorldMainView = {1, 32, 94},
		CharMainView = {3,11,12},
		PartnerView = {4,5,6, 7,8, 9},
		TrialNewEntranceView = {17, 18, 19, 34, 91},
		GatherSoulMainView = {93, 97},
		FriendMainView = {95, 96},
		ShopView = {98},
		PartnerEquipView = {10}
	},
	Daily = {
		TrialNewEntranceView = {9},
		ArenaMainView = {11},
		-- CompBuyCoinMainView = {13},
		GatherSoulMainView = {4},
		PartnerView = {5,6,7,8},
		-- CompBuySpMainView = {12},
	},
}

local QuestKind = {
	DAILY = 1,
	TARGET = 2,
}

function CompQuestInfo:ctor(winName, onWinName)
    CompQuestInfo.super.ctor(self, winName);
    self._onWinName = onWinName;
end

function CompQuestInfo:loadUIComplete()
	self:registerEvent();
	self._rewardCell = self.panel_reward;
	self._rewardCell:setVisible(false);
	self._tipsCell = self.panel_not;
	self._tipsCell:setVisible(false);

	self._dailyQuestTypeArray = self:getDailyQuestTypeArray()
	self._targetQuestTypeArray = self:getTargetQuestTypeArray()

	self.ctn_1:setVisible(false);

	self:initUI();
end 

function CompQuestInfo:registerEvent()
	CompQuestInfo.super.registerEvent();
    EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP, 
        self.onCheckWhenShowWindow, self);

    --从任务跳转过来的
    EventControler:addEventListener(QuestEvent.JUMP_FROM_QUEST,
        self.onJumpFromQuest, self); 

    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.initUI, self); 

    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.initUI, self); 

end

function CompQuestInfo:initUI()
	if LoginControler:isLogin() == false then 
		return ;
	end 

	if self._dailyQuestTypeArray == {} and self._targetQuestTypeArray == {} then 
		self.ctn_1:setVisible(false);
		return;
	else 
		self.ctn_1:setVisible(true);
	end 

	-- dump(self._dailyQuestTypeArray, "--self._dailyQuestTypeArray--");
	-- dump(self._targetQuestTypeArray, "--self._targetQuestTypeArray--");

	local questType, questId = self:getCurShowQuestTypeAndId();
	if questType == nil then 
		self.ctn_1:setVisible(false);
		return 
	else 
		self.ctn_1:setVisible(true);
		if questType == QuestKind.DAILY then 
			self:initInfoDaily(questId);
		else 
			self:initInfoTarget(questId);
		end 
	end 
end
function CompQuestInfo:updataTime()
	self.times = self.times + 1
	if self.times == 90 then
		self.ctn_1:removeAllChildren();
		-- local 

		-- local alphaInAction = act.fadein(0.5)
	 --    self.ctn_1:stopAllActions()
	 --    self.ctn_1:runAction(
	 --        cc.Sequence:create(alphaInAction)
	 --    )
		self.times = 0
		self:unscheduleUpdate()
	end
end

function CompQuestInfo:initInfoTarget(questId)
	local isFinsh = TargetQuestModel:isMainLineQuestFinish(questId);
	-- echo("---initInfoTarget---", tostring(questId));

	if isFinsh == false then 
		local ui = UIBaseDef:cloneOneView(self._tipsCell);
		self.ctn_1:removeAllChildren();
		self.ctn_1:addChild(ui);
		ui:setVisible(true);
		ui:setPosition(cc.p(0, 0));
		ui:setOpacity(0)

		self:UIfadeIn(ui)
		

		local desTid = FuncQuest.readMainlineQuest(questId, "taskDescription");
		local desStr = GameConfig.getLanguage(desTid);
		ui.rich_1:setString(desStr);

	else 
		-- echo("========33333========",questId)
		-- local ui = UIBaseDef:cloneOneView(self._rewardCell);
		-- self.ctn_1:removeAllChildren();
		-- self.ctn_1:addChild(ui);
		-- ui:setVisible(true);
		-- ui:setPosition(cc.p(0, 0));

		-- local desTid = FuncQuest.readMainlineQuest(questId, "taskDescription");
		-- local desStr = GameConfig.getLanguage(desTid);
		-- -- echo("========444444=====",desStr)

		-- ui.rich_1:setString(desStr);

		-- ui.btn_1:setTouchedFunc(c_func(self.targetRewardClick, self, questId));
	end 
end
function CompQuestInfo:UIfadeIn(_object)
	-- local act_3 = cc.CallFunc:create()
	local alphaInAction = cc.FadeTo:create(1.0,255)
	local alphaInAction1 = act.fadeout(0)
	local act_3 = cc.CallFunc:create(function ()
		self:delayCall(function ()
			self:UIfadeOut(_object)
		end,2)
	end)
	local act_s = cc.Sequence:create(alphaInAction,act_3)
	_object:runAction(act_s)
end
function CompQuestInfo:UIfadeOut(_object)
	local alphaInAction = cc.FadeOut:create(1.0)
	local act_3 = cc.CallFunc:create(function ()
		DailyQuestModel:setquestId(nil)
		self:startHide()
	end)
	local act_s = cc.Sequence:create(alphaInAction,act_3)
	self:runAction(act_s)
end

function CompQuestInfo:targetRewardClick(questId)
    QuestServer:getMainQuestReward(questId, 
        c_func(self.finishMainLineCallBack, self, questId));
end

function CompQuestInfo:finishMainLineCallBack(questId)
    local rewards = FuncQuest.getQuestReward(1, questId);
    FuncCommUI.startFullScreenRewardView(rewards, function ( ... )
            FuncCommUI.ShowRecordTips(questId)
        end
    );

    if TargetQuestModel:isQuestComplete(questId) == true then 
        LS:prv():set(tostring(questId), tostring(questId));
        --在发送一个任务变化消息
        EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID}); 
    else 
    	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {});
    end

    EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD);
end

function CompQuestInfo:initInfoDaily(questId)
	local isFinsh = DailyQuestModel:isDailyQuestFinish(questId);
	echo("---initInfoDaily---", tostring(questId));

	if isFinsh == false then 
		local ui = UIBaseDef:cloneOneView(self._tipsCell);
		self.ctn_1:removeAllChildren();
		self.ctn_1:addChild(ui);
		ui:setVisible(true);
		ui:setPosition(cc.p(0, 0));

		local alphaInAction2 = act.fadein(1.5)
		local alphaInAction1 = act.fadeout(0)
	    local func = function ()
	    	-- self:scheduleUpdateWithPriorityLua(c_func(self.updataTime,self,ui),0)
	    	-- self:delayCall(function ()
	    		-- local alphaInAction2 = act.fadein(0.5)
				local alphaInAction1 = act.fadeout(0.5)
	    		local act_3 = cc.CallFunc:create(function ()
	    			DailyQuestModel:setquestId(nil)
	    			self.ctn_1:removeAllChildren();
	    		end)
				local act_s = cc.Sequence:create(alphaInAction1,act_3)
				if ui ~= nil then
					ui:runAction(act_s)
				end
			-- end,0.5)
		end
		local act_t = act.delaytime(0.5)
		local act_3 = cc.CallFunc:create(func)
		local act_s = cc.Sequence:create(alphaInAction1,alphaInAction2,act_t,act_3)
		ui:runAction(act_s)

		local desTid = FuncQuest.readEverydayQuest(questId, "taskDescription");
		local desStr = GameConfig.getLanguage(desTid);

		ui.rich_1:setString(desStr);
	else 
		echo("========11111========",questId)
		-- local ui = UIBaseDef:cloneOneView(self._rewardCell);
		-- self.ctn_1:removeAllChildren();
		-- self.ctn_1:addChild(ui);
		-- ui:setVisible(true);
		-- ui:setPosition(cc.p(0, 0));

		-- local desTid = FuncQuest.readEverydayQuest(questId, "taskDescription");
		-- local desStr = GameConfig.getLanguage(desTid);
		-- echo("========22222======",desStr)
		-- ui.rich_1:setString(desStr);
		-- --点击
		-- ui.btn_1:setTouchedFunc(c_func(self.dailyRewardClick, self, questId));
	end 
end

function CompQuestInfo:dailyRewardClick(questId)
	echo("---dailyRewardClick----");
    QuestServer:getEveryQuestReward(questId, 
        c_func(self.finishDailyCallBack, self, questId));
end

function CompQuestInfo:finishDailyCallBack(questId)
    local rewards = FuncQuest.getQuestReward(2, questId);
    FuncCommUI.startFullScreenRewardView(rewards, function ( ... )
            FuncCommUI.ShowRecordTips(questId);

            if UserModel:isLvlUp() == true then 
                EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
            end 
        end
    );

    EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD);
    EventControler:dispatchEvent(QuestEvent.DAILY_QUEST_CHANGE_EVENT, {});
end

function CompQuestInfo:getDailyQuestTypeArray()
	local dailyQuestArray = {};
	for viewName, array in pairs(winNameQuestIdMap.Daily) do
		if self._onWinName == viewName then 
			dailyQuestArray = array
			break;
		end 
	end
	return dailyQuestArray;
end

function CompQuestInfo:getTargetQuestTypeArray()
	local targetQuestArray = {};
	for viewName, array in pairs(winNameQuestIdMap.Target) do
		if self._onWinName == viewName then 
			targetQuestArray = array;
			break;
		end
	end
	return targetQuestArray;
end

--返回 每日或目标，id
function CompQuestInfo:getCurShowQuestTypeAndId()
	local dailyIds = self:getThisViewDailyQuestIds();
	for _, id in pairs(dailyIds) do
		if DailyQuestModel:isDailyQuestFinish(id) == true then 
			return QuestKind.DAILY, id;
		end 
	end

	local targetIds = self:getThisViewTargetQuestIds();
	local notFinishTargetId = nil;
	for _, id in pairs(targetIds) do
		if TargetQuestModel:isMainLineQuestFinish(id) == true then 
			return QuestKind.TARGET, id;
		end 
	end

	if self._notFinishId ~= nil then 
		--看是每日任务还是目标
		if self._notFinishIdType == QuestKind.DAILY then
			local isFinish = DailyQuestModel:isDailyQuestFinish(self._notFinishId);
			if isFinish == true then 
				self._notFinishId = nil;
				self._notFinishIdType = nil;
				return nil, nil;
			end 
			return QuestKind.DAILY, self._notFinishId;
		else 
			local isFinish = TargetQuestModel:isMainLineQuestFinish(self._notFinishId);
			if isFinish == true then 
				self._notFinishId = nil;
				self._notFinishIdType = nil;
				return nil, nil;
			end 
			return QuestKind.TARGET, self._notFinishId;
		end  

	end 


	return nil, nil;
end

function CompQuestInfo:getThisViewTargetQuestIds()
	local targetQuestViewIds = {};

	--登录后才有
	if LoginControler:isLogin() == false then 
		return targetQuestViewIds;
	end 

	local allShowTargetIds = TargetQuestModel:getAllShowMainQuestId();

	for k, v in pairs(allShowTargetIds) do
		local conditionType = FuncQuest.readMainlineQuest(v, "conditionType");
		for i, j in pairs(self._targetQuestTypeArray) do
			if j == conditionType then 
				table.insert(targetQuestViewIds, v);
			end 
		end
	end
	return targetQuestViewIds;
end

function CompQuestInfo:getThisViewDailyQuestIds()
	local dailyQuestViewIds = {};
	--登录后才有
	if LoginControler:isLogin() == false then 
		return dailyQuestViewIds;
	end 

	local allShowDailyIds = DailyQuestModel:getAllShowDailyQuestId();

	for k, v in pairs(allShowDailyIds) do
		local conditionType = FuncQuest.readEverydayQuest(v, "conditionType");
		for i, j in pairs(self._dailyQuestTypeArray) do
			if j == conditionType then 
				table.insert(dailyQuestViewIds, v);
			end 
		end
	end

	-- dump(dailyQuestViewIds, "---dailyQuestViewIds--");

	return dailyQuestViewIds;
end

function CompQuestInfo:onJumpFromQuest(event)
	local questId = event.params.questId;
	local questBigType = event.params.questType;

	echo("--questId--questBigType--", questBigType, questBigType);
	--看看这个任务是不是本界面负责的
	if questBigType == QuestKind.TARGET then 
		local isIn = false;
		local conditionType = FuncQuest.readMainlineQuest(questId, "conditionType");
		for i, j in pairs(self._targetQuestTypeArray) do
			if j == conditionType then 
				isIn = true;
				break;
			end 
		end	

		if isIn == false then 
			return;
		end 
	else
		local isIn = false;
		local conditionType = FuncQuest.readEverydayQuest(questId, "conditionType");
		for i, j in pairs(self._dailyQuestTypeArray) do
			if j == conditionType then 
				isIn = true;
				break;
			end 
		end	

		if isIn == false then 
			return;
		end 
	end 

	if questBigType == QuestKind.DAILY then 
		self._notFinishIdType = QuestKind.DAILY
	else 
		self._notFinishIdType = QuestKind.TARGET;
	end 

	self._notFinishId = questId;

	echo("--11111---");

	self:initUI();

end


function CompQuestInfo:onCheckWhenShowWindow(event)
	local curViewName = event.params.ui.windowName;
	-- echo("--curViewName--", curViewName);


end


function CompQuestInfo:updateUI()
    
end


return CompQuestInfo;
















