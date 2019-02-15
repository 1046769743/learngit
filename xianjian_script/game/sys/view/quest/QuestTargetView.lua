--guan
--2017.4.8 

local QuestTargetView = class("QuestTargetView", UIBase)

function QuestTargetView:ctor(winName)
	echo("__________QuestUpgradeView________")
	QuestTargetView.super.ctor(self, winName)

    self._showIdx = 1 -- 1显示目标，2显示成就
end

function QuestTargetView:loadUIComplete()
	self:registerEvent()
    self.addeffectArr = {}
	self._targetList = self.panel_1.scroll_1;
	self._cell = self.panel_1.panel_1;
	self._cell:setVisible(false);
	self._tabKind = TargetQuestModel.TAB_KIND.ALL;
	self._lastTabMc = nil;
    self._downTabShow = false;
    self.selectIndex = TargetQuestModel.selectIndex
	self.panel_1.panel_san:setVisible(false);
    self.UI_1.txt_1:setString(GameConfig.getLanguage("#tid_quest_ui_006"))

	self:initUI();
end

function QuestTargetView:registerEvent()
    --主线任务有变化
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.targetQuestChangeCallBack, self);

    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.updateAchievement, self);

    EventControler:addEventListener(QuestEvent.AFTER_QUEST_GET_REWARD,
        self.updateAchievement, self);
    EventControler:addEventListener(QuestEvent.ACHIEVEMENT_GET_REWARD,
        self.updateAchievement, self);
end

function QuestTargetView:initUI()
	self:initMainLineList();
	self:initTabUI();
    self:updateAchievement()
end

function QuestTargetView:initTabUI()
	local needLvl = FuncDataSetting.getOpenQuestTabLvl();

	if UserModel:level() < needLvl then 
		self.panel_1.panel_mubiao:setVisible(false);
		return;
	end 

	self.panel_1.panel_mubiao:setVisible(true);

	self.panel_1.panel_mubiao.mc_1:setTouchedFunc(c_func(self.setSelectBtns, 
		self, TargetQuestModel.TAB_KIND.ALL));
	self.panel_1.panel_mubiao.mc_2:setTouchedFunc(c_func(self.setSelectBtns, 
		self, TargetQuestModel.TAB_KIND.TRAIN));
	self.panel_1.panel_mubiao.mc_3:setTouchedFunc(c_func(self.setSelectBtns, 
		self, TargetQuestModel.TAB_KIND.CHANELLAGE));
	self.panel_1.panel_mubiao.mc_4:setTouchedFunc(c_func(self.setSelectBtns, 
		self, TargetQuestModel.TAB_KIND.OTHER));


    self.panel_1.panel_mubiao.mc_all:getCurFrameView().mc_1:showFrame(2);

    self.panel_1.panel_mubiao.mc_all:setTouchedFunc(c_func(self.onMcAllTouch, self));

    if self._downTabShow == false then 
        self.panel_1.panel_mubiao.mc_1:setVisible(false);
        self.panel_1.panel_mubiao.mc_2:setVisible(false);
        self.panel_1.panel_mubiao.mc_3:setVisible(false);
        self.panel_1.panel_mubiao.mc_4:setVisible(false);
    else 
        self.panel_1.panel_mubiao.mc_1:setVisible(true);
        self.panel_1.panel_mubiao.mc_2:setVisible(true);
        self.panel_1.panel_mubiao.mc_3:setVisible(true);
        self.panel_1.panel_mubiao.mc_4:setVisible(true);
    end 
end

function QuestTargetView:onMcAllTouch()
    if self._downTabShow == true then 
        self.panel_1.panel_mubiao.mc_1:setVisible(false);
        self.panel_1.panel_mubiao.mc_2:setVisible(false);
        self.panel_1.panel_mubiao.mc_3:setVisible(false);
        self.panel_1.panel_mubiao.mc_4:setVisible(false);
        self._downTabShow = false;
    else 
        self.panel_1.panel_mubiao.mc_1:setVisible(true);
        self.panel_1.panel_mubiao.mc_2:setVisible(true);
        self.panel_1.panel_mubiao.mc_3:setVisible(true);
        self.panel_1.panel_mubiao.mc_4:setVisible(true);
        self._downTabShow = true;

    end 
end

--下面的选择页签
function QuestTargetView:setSelectBtns(kind)
    self.panel_1.panel_mubiao.mc_1:setVisible(false);
    self.panel_1.panel_mubiao.mc_2:setVisible(false);
    self.panel_1.panel_mubiao.mc_3:setVisible(false);
    self.panel_1.panel_mubiao.mc_4:setVisible(false);
    self._downTabShow = false;
    
	if kind == self._tabKind then 
		return;
	end 

	local needLvl = FuncDataSetting.getOpenQuestTabLvl();
	if UserModel:level() < needLvl then 
		self.panel_1.panel_mubiao:setVisible(false);
		return;
	end 

	self.panel_1.panel_mubiao:setVisible(true);
	self._tabKind = kind;

	if kind == TargetQuestModel.TAB_KIND.ALL then 
        self.panel_1.panel_mubiao.mc_all:showFrame(1)
	elseif kind == TargetQuestModel.TAB_KIND.TRAIN then 
        self.panel_1.panel_mubiao.mc_all:showFrame(2)
	elseif kind == TargetQuestModel.TAB_KIND.CHANELLAGE then
        self.panel_1.panel_mubiao.mc_all:showFrame(3)
	elseif kind == TargetQuestModel.TAB_KIND.OTHER then
        self.panel_1.panel_mubiao.mc_all:showFrame(4)
	end 

    self.panel_1.panel_mubiao.mc_all:getCurFrameView().mc_1:showFrame(2)
	--更新list
	self:scrollUpdate();
	--滚到最上面
	self._targetList:gotoTargetPos(1, 1);
end

--[[
    初始化主线任务的list
]]
function QuestTargetView:initMainLineList()
    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(self._tabKind);

    -- dump(allMainLineQuestIds, "----QuestTargetView:initMainLineList-----");

    if #allMainLineQuestIds == 0 then
        self.panel_1.panel_san:setVisible(true)
    else
        self.panel_1.panel_san:setVisible(false)
    end



    local createRankItemFunc = function(itemData,index)
        local baseCell = UIBaseDef:cloneOneView(self._cell);
        -- baseCell:setBtnClickEff(3)
        self:updateTargetListCell(baseCell, itemData,index)
        return baseCell;
    end
    local function updateCellFunc( itemData, view, idx )
        self:updateTargetListCell(view, itemData, idx)
    end

    self._scrollParams = {
        {
            data = allMainLineQuestIds,
            createFunc = createRankItemFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 12,
            offsetY = 40,
            widthGap = 0,
            heightGap = 10,
            itemRect = {x = 0, y = -134, width = 812, height = 116},
            perFrame = 1,
        }
    }
    self.index_eff = 0
    self._targetList:setItemAppearType(1, true);
    self._targetList:styleFill(self._scrollParams);
    self._targetList:refreshCellView(1)
    if self.selectIndex  then
        for k,v in pairs(allMainLineQuestIds) do
            if tostring(self.selectIndex) == tostring(v) then
                self._targetList:gotoTargetPos(tonumber(k),1,1);
            end
        end 
    end
end

function QuestTargetView:updateTargetListCell(baseCell, questId,idx)
    -- if idx == nil then
        self.index_eff = idx
    -- end
    --是否完成
    local isFinish = TargetQuestModel:isMainLineQuestFinish(questId); 
    self:initCellWithoutRightBtn(baseCell, questId, true, isFinish);
    baseCell = baseCell.panel_cell; 

    if TargetQuestModel:isRecommendQuest(questId) == true then 
    	-- echo("--isRecommendQuest questId--", tostring(questId));
        baseCell.mc_3:showFrame(2);
        ------加特效 ------------
        local btn = baseCell.mc_3:getViewByFrame(2).ctn_1
        local tuijian_effect = btn:getChildByName("tuijian_effect") 
        if isFinish then
            -- if self.tuijian_lockAni == nil then  --特效是不是存在
            if  not tuijian_effect then
                local tuijian_lockAni  = self:createUIArmature("UI_task","UI_task_tuijiansaoguang", btn, true, function ()
                end)
                tuijian_lockAni:setName("tuijian_effect")
                local nams = tuijian_lockAni:getBone("zhezhao1")
                nams:setVisible(false)
                tuijian_lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1_copy"):playWithIndex(1,false,false)
                tuijian_lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1"):playWithIndex(1,false,false)
            else
                tuijian_effect:setVisible(true)
            end
        else
            if tuijian_effect ~= nil then 
                tuijian_effect:setVisible(false)
            end
        end
    else
        local easyType = FuncQuest.readMainlineQuest(questId, "EasyType") or 1
        local perFrame = 1
        if easyType == 3 then 
            baseCell.mc_3:showFrame(3);
            perFrame  =  3
        else    
            baseCell.mc_3:showFrame(1);
            perFrame = 1
        end 
        local btn = baseCell.mc_3:getViewByFrame(perFrame).ctn_1
        local but_effect = btn:getChildByName("but_effect") 
        if isFinish then
            if not but_effect then
                local lockAni = self:createUIArmature("UI_task","UI_task_tuijiansaoguang", btn, true, function ()
                end)
                lockAni:setName("but_effect")
                self.addeffectArr[self.index_eff] = lockAni
                local nams = lockAni:getBone("zhezhao1")
                nams:setVisible(false)
                lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1_copy"):playWithIndex(1,false,false)
                lockAni:getBoneDisplay("layer2"):getBoneDisplay("layer1"):playWithIndex(1,false,false)
            else
                but_effect:setVisible(true)
            end
        else
            if but_effect ~= nil then
                but_effect:setVisible(false)
            end
        end
    end 

    if isFinish == true then 
        baseCell.mc_2:showFrame(1);
        baseCell.mc_2:setVisible(true);
        local finishBtn = baseCell.mc_2:getCurFrameView().panel_3.btn_finish;
        finishBtn:setVisible(true)
        finishBtn:setTouchSwallowEnabled(false);


        finishBtn:setTap(c_func(self.finishBtnClick, self, questId, 
            baseCell.mc_2)); 
        finishBtn:setTouchSwallowEnabled(false); 
    else 
        baseCell.mc_2:showFrame(2);
        local gotoBtn = baseCell.mc_2.currentView.btn_1
        gotoBtn:setTouchSwallowEnabled(false)
        gotoBtn:setTap(c_func(self.goToTargetView, self, questId))
        
        local countLabel = baseCell.mc_2:getCurFrameView().panel_progress.txt_1;

        local needCount = TargetQuestModel:needCount(questId);
        local completeCount = TargetQuestModel:finishCount(questId);
        countLabel:setString(string.format("%d/%d", completeCount, needCount));

        --百分比
        local processBar = baseCell.mc_2:getCurFrameView().panel_progress.progress_blue;
        processBar:setPercent( math.abs(100 * completeCount / needCount) );

        if TargetQuestModel:isShowNumInfo(questId) == false then 
            baseCell.mc_2:setVisible(false);
        else 
            baseCell.mc_2:setVisible(true);
        end 
    end 

    return baseCell;
end

--[[
    初始化信息，除了最左边的信息
]]
function QuestTargetView:initCellWithoutRightBtn(baseCell, questId, isMainLine, isFinish)
    if baseCell == nil then
        return;
    end 

    -- if isFinish == true then 
    --     baseCell:setTap(c_func(self.finishBtnClick, self, questId, 
    --         baseCell:getUpPanel().panel_cell.mc_2));
    -- else
    --     baseCell:setTap(c_func(self.goToTargetView, self, questId));
    -- end 

    baseCell = baseCell.panel_cell;

    local typeIndex = isMainLine == true and 1 or 2;
    --初始化基本信息
    --任务名字
    local questNameId = FuncQuest.getQuestName(typeIndex, questId);

    if DEBUG_ENTER_SCENE_TEST == true then 
        baseCell.txt_1:setString(GameConfig.getLanguage(questNameId))-- .. tostring(questId));
    else 
        baseCell.txt_1:setString(GameConfig.getLanguage(questNameId));
    end
     
    --描述
    local desId = FuncQuest.getQuestDes(typeIndex, questId);
    baseCell.rich_2:setString(GameConfig.getLanguage(desId));  

    --奖励
    local rewards = FuncQuest.getQuestReward(typeIndex, questId);

    --最多2个奖励
    for i = 1, 3 do
        local mcReward = baseCell["mc_reward" .. tostring(i)];
        if rewards[i] == nil then 
            mcReward:setVisible(false);
        else 
            self:initRewardMc(mcReward, rewards[i]);
        end 
    end

    --称号 
    local title = FuncQuest.readMainlineQuest(questId, "title", false);

    if title == nil then 
    	baseCell.ctn_title:setVisible(false);
    else 
        if isFinish == true then 
            baseCell.ctn_title:setVisible(false);
        else
            -- baseCell.ctn_title:setVisible(false);
            local titlepng = FuncTitle.bytitleIdgetpng(title[1])
            local titleicon = display.newSprite(titlepng)
            baseCell.ctn_title:addChild(titleicon)
            titleicon:setScale(0.7)
            titleicon:setPosition(cc.p(30,-10))
        end
    	-- local tid = FuncQuest:readTitleQuest(title, "titleName");
    	-- local str = GameConfig.getLanguage(tid);
    	
    	-- baseCell.panel_chenghao.txt_1:setString(str);

           -- -- local rewardNum = #rewards;
           -- -- local positionX = baseCell.mc_reward1:getPositionX() + 100 * rewardNum;
           -- -- baseCell.panel_chenghao:setPositionX(positionX);
    end 
    -- baseCell.panel_chenghao:setVisible(false);

    local iconName = FuncQuest.readMainlineQuest(questId, "icon");
    local iconPath = FuncRes.iconQuest(iconName)
    local iconSp = display.newSprite(iconPath); 

    baseCell.mc_ui:showFrame(1);
    
    local curMc = baseCell.mc_ui:getCurFrameView();
    curMc.panel_1.ctn_1:removeAllChildren()
    curMc.panel_1.ctn_1:addChild(iconSp);
    curMc.UI_item:setVisible(false);
end

--[[
    初始化奖励弹框
]]
function QuestTargetView:initRewardMc(mcReward, reward)
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
        mcReward.currentView.txt_1:setPositionX(self._txtPosX + 50);
        ctn:setPositionX(self._ctnPosX + 20);
    end 
    --数量
    mcReward.currentView.txt_1:setString("x " .. tostring(itemNum));

end

function QuestTargetView:finishBtnClick(questId, cell)
    echo("finishBtnClick " .. tostring(questId));
    if TargetQuestModel:isMainLineQuestFinish(questId) == true then
        cell:getCurFrameView().panel_3.btn_finish:setVisible(false);
        UserModel:cacheUserData()
        self._lastFinishQuest = questId;
        self:disabledUIClick();
        self._lastFinishCtn = cell:getCurFrameView().ctn_stamp;
        QuestServer:getMainQuestReward(questId, c_func(self.finishCallBack, self))
    else 
        WindowControler:showTips( { text = "未完成" });
    end 
end
function QuestTargetView:issystemUpOpen(systemname)
    local level =  UserModel:level()
    local openData =  FuncCommon.isSystemOpen(systemname) --FuncCommon.getSysOpenData()[tostring(systemname)]
    if openData then
        return true
    end
    return false
    -- local conditions = openData.condition
    -- if (tonumber(conditions[1].v) <= tonumber(level)) then--, conditions[1].v
    --     return true
    -- else
    --     return false
    -- end
end
--目标
function QuestTargetView:goToTargetView(questId)
    echo("goToView " .. tostring(questId));
    local questType = FuncQuest.readMainlineQuest(questId, "conditionType");

    local jumpInfo = TargetQuestModel.JUMP_VIEW[tostring(questType)];

    if jumpInfo ~= nil then
        TargetQuestModel:setSelectIndex(questId)
        echo("jumpView.viewName =====000=====" .. tostring(jumpInfo.viewName));
        if jumpInfo.viewName ~= nil then
            local systemname = jumpInfo.systemname
            if self:issystemUpOpen(systemname) then
                DailyQuestModel:setquestId(questId)
                local pames = nil
                local  pames1,pames2
                if systemname == "partner" then
                    pames1 = UserModel:avatar()
                    pames2 = FuncPartner.PartnerIndex.PARTNER_QUALILITY
                end
                WindowControler:showWindow(jumpInfo.viewName,pames2,pames1)
            else
                WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_007"));
            end
        elseif jumpInfo.funName ~= nil  then 
            jumpInfo.funName(questId);
        else 
            -- self:startHide();
        end 

        -- self:delayCall(function ( ... )
        --     echo("----delaycall function--");
        --     EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
        --         {questId = questId, questType = 2});
        -- end, 1)
        --发送显示tips事件
        EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
            {questId = questId, questType = 2});
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_008"));
    end 

    self._lastGotoMainLineQuestId = questId;
end

--[[
    主线任务完成回调
]]
function QuestTargetView:finishCallBack(event)
    function callBack()
        echo("finishCallBack " .. tostring(self._lastFinishQuest));
        if self._lastFinishQuest == nil then
            return 
        end

        EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD); 
        
        local rewards = FuncQuest.getQuestReward(1, self._lastFinishQuest);
        if rewards == nil then
            echo("========目标任务 奖励数据 is nil======任务完成  ID =====",self._lastFinishQuest)
            rewards = { [1]= "3,1" }
        end

        -- FuncCommUI.startFullScreenRewardView(rewards, function ( ... )
                -- FuncCommUI.ShowRecordTips(self._lastFinishQuest)
        --     end
        -- );
        dump(rewards,"领取奖励===")
        -- for i=1,#rewards do
            FuncCommUI.startRewardView(rewards)
        -- end
        FuncCommUI.ShowRecordTips(self._lastFinishQuest)

        --任务列表
        -- self:scrollUpdate();
        self:initUI()
        self:resumeUIClick();

        -- self:rewPointCheck();
        if TargetQuestModel:isHaveFinishQuest() == true or 
            DailyQuestModel:isHaveFinishQuest() == true then 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
        else 
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
        end 

        if TargetQuestModel:isQuestComplete(self._lastFinishQuest) == true then 
        	LS:prv():set(tostring(self._lastFinishQuest), 
        		tostring(self._lastFinishQuest));
        	--在发送一个任务变化消息
        	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID}); 
        end
    end

    -- local ani = self:createUIArmature("UI_task",
    --     "UI_task_yilingqu", self._lastFinishCtn, true); 
    -- ani:registerFrameEventCallFunc(12, 1, function ( ... )
    --     ani:gotoAndPause(6);
        -- callBack();
    -- end );   
    if event.result then
        callBack()
    end

end


function QuestTargetView:scrollUpdate()
    -- echo("-----scrollUpdate-----");

    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(self._tabKind);
    -- dump(allMainLineQuestIds, "--allMainLineQuestIds ！！--");
    -- for k, v in pairs(allMainLineQuestIds) do
    --     local cellView = self._targetList:getViewByData(v); 
    --     if cellView ~= nil then 
    --         self:updateTargetListCell(cellView, v); 
    --     end 
    -- end

    self._scrollParams[1].data = allMainLineQuestIds;
    self._targetList:styleFill(self._scrollParams);
    self._targetList:refreshCellView(1)
end

function QuestTargetView:targetQuestChangeCallBack()
    -- echoError("---------------QuestTargetView:targetQuestChangeCallBack-----------------" .. tostring(self._lastGotoMainLineQuestId));
    -- self:initUI();
    if self._lastGotoMainLineQuestId ~= nil then 
        self:scrollUpdate();
        if TargetQuestModel:isMainLineQuestFinish(self._lastGotoMainLineQuestId) == true then 
            --滚到最上
            echo("gotoTargetPos targetQuestChangeCallBack");
            self._targetList:gotoTargetPos(1, 1);
        end
    else 
        self:scrollUpdate();
    end 

end
-- 下面的成就
function QuestTargetView:updateAchievement()
    -- 成就点数
    local curIndex = TargetQuestModel:curAchievementIndex()
    local havePoint = UserModel:getAchievementPoint()

    self.panel_2.txt_1:setString(havePoint)

    -- 拳头可点击
    self.panel_2.btn_1:setTap(c_func(self.onClickFist,self))

    -- 三个箱子
    -- 根据当前的成就idx获取需要显示的宝箱
    local base = math.floor((curIndex - 1) / 3)
    local flag = 0
    for i=1,3 do
        local view = self.panel_2["mc_"..i]
        local idx = base * 3 + i
        local condition = FuncQuest:readAchiment(idx, "condition")
        local rewards = FuncQuest:readAchiment(idx, "reward")
        -- 是否已领
        self.panel_2["mc_" .. i]:showFrame(TargetQuestModel:hasAchieveGet(idx) and 2 or 1)
        self.panel_2["mc_" .. i].currentView.txt_1:setString(condition)

        -- 是否可领
        if havePoint >= condition then
            flag = i
            local touchview = self:playBoxAnim(i,true)

            if not TargetQuestModel:hasAchieveGet(idx) then
                touchview:setTouchedFunc(c_func(self.onBoxClick,self,idx,1),nil,true)
            else
                touchview:setTouchedFunc(c_func(self.onBoxClick,self,idx,2),nil,true)
            end
        else
            local touchview = self:playBoxAnim(i,false)
            touchview:setTouchedFunc(c_func(self.onBoxClick,self,idx,2),nil,true)
        end
    end

    -- 进度条
    local p = {0,35,65,100}
    self.panel_2.panel_1.progress_1:setPercent(p[flag+1])

    self:achievementSwitch()
end

-- 处理特效
function QuestTargetView:playBoxAnim(idx, isplay)
    local ctnBox = self.panel_2["mc_"..idx].currentView.ctn_1
    local mc_box = self.panel_2["mc_"..idx].currentView.panel_box
    if not ctnBox then return mc_box end

    ctnBox:removeAllChildren()

    if isplay then
        mc_box:visible(false)
        local mcView = UIBaseDef:cloneOneView(mc_box)
        mcView:pos(-20,20)
        local anim = self:createUIArmature("UI_xunxian","UI_xunxian_xingjibaoxiang",ctnBox, false, GameVars.emptyFunc)
        FuncArmature.changeBoneDisplay(anim,"node",mcView)
        anim:startPlay(true)

        return mcView
    else
        mc_box:visible(true)
        ctnBox:removeAllChildren()
    end

    return mc_box
end

-- 更新显示
function QuestTargetView:achievementSwitch()
     -- 显示哪一个
    if self._showIdx == 1 then
        self.panel_1:visible(true)
        self.UI_2:visible(false)
    elseif self._showIdx == 2 then
        self.panel_1:visible(false)
        self.UI_2:visible(true)
    end
end

-- 点成就拳头
function QuestTargetView:onClickFist()
    self._showIdx = self._showIdx == 1 and 2 or 1
    self:achievementSwitch()
end

-- 点击箱子 1 可领 2 不可领
function QuestTargetView:onBoxClick(idx,flag)
    if flag == 1 then
        QuestServer:getAchievementReward(idx, function()
            -- 弹奖励
            local rewards = FuncQuest:readAchiment(idx, "reward");
            local res = string.split(rewards[1], ",")
            if res[1] == FuncDataResource.RES_TYPE.USERHEADFRAME  then
                rewards = {res[1]..","..res[2]..",1"}
            end
            FuncCommUI.startFullScreenRewardView(rewards)
            -- self:updateAchievement()
            EventControler:dispatchEvent(QuestEvent.ACHIEVEMENT_GET_REWARD, {})
        end)
    elseif flag == 2 then
        local rew = FuncQuest:readAchiment(idx, "reward")
        WindowControler:showWindow("QuestAchieveRewardView",rew)
    end
end

return QuestTargetView