--guan
--2017.4.8 
local QuestEveryDayView = class("QuestEveryDayView", UIBase)

function QuestEveryDayView:ctor(winName)
	echo("__________QuestEveryDayView________")
	QuestEveryDayView.super.ctor(self, winName);
end

function QuestEveryDayView:loadUIComplete()
	self:registerEvent()
    self:viewAdjust();
    self.addeffectArr = {}
	self._dailyList = self.panel_1.scroll_1;
	self.panel_1.panel_1:setVisible(false);

	self.panel_1.panel_san:setVisible(false);
	self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_quest_ui_003"))
	self:initUI();
end

function QuestEveryDayView:registerEvent()
    --每日任务有变化
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.initUI, self);

    --接受sp任务发生变化的事件
    EventControler:addEventListener(QuestEvent.QUEST_CHECK_SP_EVENT,
        self.spCheckCallBack, self, 1);
end

function QuestEveryDayView:viewAdjust()
 
end 

function QuestEveryDayView:initUI()
	self:initDailyQuest();

end

function QuestEveryDayView:initDailyQuest()
    local allDailyQuestIds = DailyQuestModel:getAllShowDailyQuestId();
    local createRankItemFunc = function(itemData,index)
        local baseCell = UIBaseDef:cloneOneView(self.panel_1.panel_1);
        -- baseCell:setBtnClickEff(3)
        self:updateDailyListCell(baseCell, itemData, index)
        return baseCell;
    end

    local function updateCellFunc( itemData, view, idx )
        self:updateDailyListCell(view, itemData, idx)
    end

    if #allDailyQuestIds == 0 then
        self.panel_1.panel_san:setVisible(true)
    else
        self.panel_1.panel_san:setVisible(false)
    end


    self._dailyScrollParams = {
        {
            data = allDailyQuestIds,
            createFunc = createRankItemFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 8,
            offsetY = 40,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -134, width = 812, height = 116},
            perFrame = 1,
        }
    }

    self._dailyList:styleFill(self._dailyScrollParams);
    self._dailyList:refreshCellView(1)
    -- local quildid = DailyQuestModel:getJumToquestId()
    -- if quildid ~= nil then
    --     for i=1,#allDailyQuestIds do
    --         if quildid == allDailyQuestIds[i] then
    --             self._dailyList:gotoTargetPos(i,1,1);
    --         end
    --     end
    -- end
end

--[[
    传入任务id
]]
function QuestEveryDayView:updateDailyListCell(baseCell, questId,index)
    if baseCell == nil then 
        return 
    end 

    --是否完成
    local isFinish = DailyQuestModel:isDailyQuestFinish(questId); 
    self:initCellWithoutRightBtn(baseCell, questId, false, isFinish);

    baseCell = baseCell.panel_cell;
    -- baseCell.ctn_title:setVisible(false)
    if isFinish == true then 
        baseCell.mc_2:showFrame(1);
        baseCell.mc_2:setVisible(true);
        local finishBtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish;
        finishBtn:setTouchSwallowEnabled(true);
        finishBtn:setVisible(true)
        --特效
        local btn = baseCell.mc_3:getViewByFrame(1).ctn_1
        local btneffect = btn:getChildByName("effect") 
        if btneffect == nil then
            local lockAni = self:createUIArmature("UI_task","UI_task_tuijiansaoguang", btn, true, function ()
            end)
            -- self.addeffectArr[index] = lockAni
            lockAni:setName("effect")
            local nams = lockAni:getBone("zhezhao1")
            nams:setVisible(false)
            lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1_copy"):playWithIndex(1,false,false)
            lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1"):playWithIndex(1,false,false)
        else
            btneffect:setVisible(true)
        end

        finishBtn:setTap(c_func(self.finishDailyBtnClick, self, questId, 
            baseCell.mc_2));   
    else 
    	--没有完成
        local questType = FuncQuest.readEverydayQuest(questId, "conditionType");
        if DailyQuestModel:isSpQuest(questId) == true then
            baseCell.mc_2:setVisible(false);
        else 
        	baseCell.mc_2:showFrame(2);
        	baseCell.mc_2:setVisible(true);
            local gotoBtn = baseCell.mc_2.currentView.btn_1
            gotoBtn:setTap(c_func(self.goToDailyView, self, questId))

            local countLabel = baseCell.mc_2:getCurFrameView().panel_progress.txt_1; 
            local needCount = DailyQuestModel:needCount(questId);
            local completeCount = DailyQuestModel:finishCount(questId);

            local showStr = GameConfig.getLanguageWithSwap(
                "quest_complete_count", completeCount, needCount);

            countLabel:setString(showStr);

            --进度条
            local progress = baseCell.mc_2:getCurFrameView().panel_progress.progress_blue;
            local percent = (completeCount / needCount) * 100; 
            progress:setPercent( math.abs(percent) );
        end
        local btn = baseCell.mc_3:getViewByFrame(1).ctn_1
        local btnseffect = btn:getChildByName("effect")
        if btnseffect ~= nil then
            btnseffect:setVisible(false)
        end
    end 

    return baseCell;
end


--[[
    初始化信息，除了最左边的信息
]]
function QuestEveryDayView:initCellWithoutRightBtn(baseCell, questId, isMainLine, isFinish)
    if baseCell == nil then
        return;
    end 

    -- if isFinish == true then 
    --     -- echo("11111111111111111111111111111111111")
    --     baseCell:setTap(c_func(self.finishDailyBtnClick, self, questId, 
    --         baseCell.panel_cell.mc_2));
    -- else 
    --     -- echo("22222222222222222222222222222222")
    --     baseCell:setTap(c_func(self.goToDailyView, self, questId));
    -- end 

    baseCell = baseCell.panel_cell;

    local typeIndex = isMainLine == true and 1 or 2;
    --初始化基本信息
    --任务名字
    local questNameId = FuncQuest.getQuestName(typeIndex, questId);
    baseCell.txt_1:setString(GameConfig.getLanguage(questNameId));
    --描述
    local desId = FuncQuest.getQuestDes(typeIndex, questId);
    baseCell.rich_2:setString(GameConfig.getLanguage(desId));  

    --奖励
    local rewards = FuncQuest.getQuestReward(typeIndex, questId);

    --最多3个奖励
    for i = 1, 3 do
        local mcReward = baseCell["mc_reward" .. tostring(i)];
        if rewards[i] == nil then 
            mcReward:setVisible(false);
        else 
            self:initRewardMc(mcReward, rewards[i]);
        end 
    end

    --隐藏称号
    -- baseCell.panel_chenghao:setVisible(false);

    local iconName = FuncQuest.readEverydayQuest(questId, "icon");
    -- echo("======iconName============",iconName)
    local iconPath = FuncRes.iconQuest(iconName) --FuncRes.getIconResByName(iconName) --
    local iconSp = display.newSprite(iconPath); 

    local color = FuncQuest.readEverydayQuest(questId, "color");

    baseCell.mc_ui:showFrame(1);

    function isExpReward(reward)
        local itemType = nil;
        local itemId = nil;
        local itemNum = nil;

        local reward = string.split(reward, ",");

        --是货币
        if tostring( reward[1] ) == FuncDataResource.RES_TYPE.EXP then 
            return true;
        else 
            return false;
        end 

    end

    --是不是经验
    if  isExpReward(rewards[1]) then 
        -- baseCell.UI_1:setVisible(false);
        baseCell.mc_ui:showFrame(2);
        -- iconSp:anchor(0,1)
        baseCell.mc_ui:getViewByFrame(2).ctn_1:removeAllChildren()
        baseCell.mc_ui:getViewByFrame(2).ctn_1:addChild(iconSp)


    else 
        baseCell.mc_ui:showFrame(1);

        local iconUI = baseCell.mc_ui.currentView.UI_item;

        iconUI:setResItemData({reward = rewards[1]});
        iconUI:showResItemNum(false);
    end 
end

function QuestEveryDayView:finishDailyBtnClick(questId, cell)
    echo("finishDailyBtnClick " .. tostring(questId));
    if DailyQuestModel:isDailyQuestFinish(questId) == true then 
        UserModel:cacheUserData()

        cell:getCurFrameView().panel_3.btn_finish:setVisible(false);

        self._lastFinishQuest = questId;
        self:disabledUIClick();

        self._notActionToEvent = true;
        self._lastFinishCtn = cell:getCurFrameView().ctn_stamp;

        QuestServer:getEveryQuestReward(questId, c_func(self.finishDailyCallBack, self))

        self._preX = self._dailyList.position_.x;
        self._preY = self._dailyList.position_.y;
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_004"));
    end 
end

function QuestEveryDayView:finishDailyCallBack(event)
    function callBack()
        self._notActionToEvent = false;
        
        EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD);
        echo("finishDailyCallBack " .. tostring(self._lastFinishQuest)); 

        local rewards = FuncQuest.getQuestReward(2, self._lastFinishQuest);
        local callfun = GameVars.emptyFunc
        if self then
            if self.lvlUpCheck  then
                callfun =  c_func(self.lvlUpCheck, self)
            end
        else
            return
        end
        --当奖励不存在时，直接return
        if rewards == nil then
            return 
        end
        FuncCommUI.startRewardView(rewards)
        callfun()
        -- FuncCommUI.startFullScreenRewardView(rewards,callfun );
        if not self.dailyScrollUpdate then
            return 
        end
        self:dailyScrollUpdate();
        self:resumeUIClick();

        if TargetQuestModel:isHaveFinishQuest() == true or 
            DailyQuestModel:isHaveFinishQuest() == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
        else 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
        end 
    end

    -- local ani = self:createUIArmature("UI_task",
    --     "UI_task_yilingqu", self._lastFinishCtn, true); 

    -- ani:registerFrameEventCallFunc(12, 1, function ( ... )
    --     ani:gotoAndPause(6);
    --     callBack();
    -- end );

    if event.result then
        callBack()
    end
end

function QuestEveryDayView:dailyScrollUpdate()
    echo("-----dailyScrollUpdate-----");

    local allDailyQuestIds = DailyQuestModel:getAllShowDailyQuestId();

    --都
    if #allDailyQuestIds == 0 then 
        self.panel_1.panel_san:setVisible(true);
        self._dailyList:setVisible(false);
        return;
    end 

    self.panel_1.panel_san:setVisible(false);
    self._dailyList:setVisible(true);

    self._dailyScrollParams[1].data = allDailyQuestIds;

    self._dailyList:styleFill(self._dailyScrollParams);
    self._dailyList:refreshCellView(1)
    -- for k, v in pairs(allDailyQuestIds) do
    --     local cellView = self._dailyList:getViewByData(v);
    --     if cellView ~= nil then 
    --         self:updateDailyListCell(cellView, v);
    --     end 
    -- end
end
--日常
function QuestEveryDayView:goToDailyView(questId)
    local questType = FuncQuest.readEverydayQuest(questId, "conditionType");
    DailyQuestModel:setJumToquestId(questId)
    local jumpInfo = DailyQuestModel.JUMP_VIEW[tostring(questType)];
    if jumpInfo ~= nil then 
        if jumpInfo.jumpFunc ~= nil then 
            jumpInfo.jumpFunc();
        else 
            WindowControler:showWindow(jumpInfo.viewName);
        end 
        EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
            {questId = questId, questType = 1}); 
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_005"));
    end 

    self._lastGotoDailyQuestId = questId;
    self._lastquestType = questType;
end

--[[
    初始化奖励弹框
]]
function QuestEveryDayView:initRewardMc(mcReward, reward)
    local itemType = nil;
    local itemId = nil;
    local itemNum = nil;

    local reward = string.split(reward, ",")

    local isCurrency = false;
    --是货币
    if table.length(reward) == 2 then 
        itemType = reward[1];
        itemId = reward[1];
        itemNum = reward[2];
    else 
        itemType = reward[1];
        itemId = reward[2];
        itemNum = reward[3];
    end 

    if FuncDataResource.RES_TYPE.ITEM ~= itemType then 
        isCurrency = true;
    else 
        isCurrency = false;
    end 

    mcReward:showFrame(1);

    local iconPath = FuncRes.iconRes(itemType, itemId);

    -- echo("-----iconPath----" .. tostring(iconPath));

    local sp = display.newSprite(iconPath);
    local ctn = mcReward.currentView.ctn_1;

    if self._ctnPosX == nil then 
        self._ctnPosX = ctn:getPositionX();
    end 

    if self._txtPosX == nil then 
        self._txtPosX = mcReward.currentView.txt_1:getPositionX();
    end 

    ctn:removeAllChildren();
    ctn:addChild(sp);
    if FuncDataResource.RES_TYPE.EXP ~= itemType then 
        sp:size(ctn.ctnWidth, ctn.ctnHeight);
    else 
        -- mcReward.currentView.txt_1:setPositionX(self._txtPosX + 50);
        -- ctn:setPositionX(self._ctnPosX + 20);
        sp:size(ctn.ctnWidth, ctn.ctnHeight)
    end 
    --数量
    mcReward.currentView.txt_1:setString("x " .. tostring(itemNum));

end

function QuestEveryDayView:dailyQuestChangeCallBack(event)
    local questType = event.params.questType;
    echo("----dailyQuestChangeCallBack----", tostring(questType));

    if questType == DailyQuestModel.Type.BuyCoin then 
        self:dailyScrollUpdate();

        if DailyQuestModel:isDailyQuestFinish(1016) == true 
                and DailyQuestModel:isHaveReceiveReward(1016) == false then 
            --滚到最上
            self._dailyList:gotoTargetPos(1, 1);
        end 
    elseif questType == DailyQuestModel.Type.BuyVigour then 

        self:dailyScrollUpdate();

        if DailyQuestModel:isDailyQuestFinish(1015) == true 
                and DailyQuestModel:isHaveReceiveReward(1015) == false then 
            --滚到最上
            self._dailyList:gotoTargetPos(1, 1);
        end 

    else 
        -- if self._notActionToEvent ~= true and self._lastGotoDailyQuestId ~= nil then 
            self:dailyScrollUpdate();
        --     if DailyQuestModel:isDailyQuestFinish(self._lastGotoDailyQuestId) == true then 
        --         --滚到最上
        --         self._dailyList:gotoTargetPos(1, 1);
        --     end 
        -- end 
    end 
    -- self:rewPointCheck();
end

function QuestEveryDayView:spCheckCallBack()
    echo("--QuestView:spCheckCallBack--");
    self:initDailyQuest();
    -- self:rewPointCheck(); 
end

function QuestEveryDayView:lvlUpCheck()
    echo("---lvlUpCheck---");
    if UserModel:isLvlUp() == true then 
        EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
    end 
end

return QuestEveryDayView



























