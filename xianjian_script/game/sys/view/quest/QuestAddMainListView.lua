-- QuestAddMainListView.lua


local QuestAddMainListView = class("QuestAddMainListView", UIBase)



function QuestAddMainListView:ctor(winName)
	QuestAddMainListView.super.ctor(self, winName)

	self.yeqian_type = {
		quest = 1,
		mission = 2,
		love = 3,

	}


end

function QuestAddMainListView:loadUIComplete()
	self.panel_b.panel_title:setVisible(false)
    self.panel_t.panel_red:visible(false)
    QuestAndChatModel:setOpenView(true)
	self:registerEvent()
    self._rect = self.panel_b:getContainerBox();
	self.isOpenView = true
    self.panel_t:setVisible(false)
    self.panel_t.btn_1:setTouchedFunc(c_func(self.openview, self),nil,true);
    -- self:setArrData()
    local mc_1 =  self.panel_b.mc_2:getViewByFrame(1).mc_1
    local panel_1 = mc_1:getViewByFrame(2).panel_1
    panel_1:setVisible(false)

    self:showRecommendedIcon()
end

function QuestAddMainListView:openview()
    echo("=======self.isOpenView=======",self.isOpenView)
    if self.isOpenView then
        self.isOpenView = false
        self:closeChat()
    else
        self.isOpenView = true
        self:showComplete()
    end
    self:showRecommendedIcon()
end

function QuestAddMainListView:showRecommendedIcon()
    local curRaidId = WorldModel:getNextMainRaidId()
    local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
    if not WorldModel:isRaidLock(curRaidId) then
        if  TutorialManager.getInstance():isInTutorial() then
            self.panel_t.panel_1:setVisible(false)
        else
            if self.selectButton then
                if  self.selectButton ~= FuncQuestAndChat.leafBladeType.mission then 
                    if HomeModel:isOpenPVPFile() then
                        self.panel_t.panel_1:setVisible(false)
                    else
                        self.panel_t.panel_1:setVisible(true)
                    end
                else
                    self.panel_t.panel_1:setVisible(false)
                end
            end
        end
    else
        self.panel_t.panel_1:setVisible(false)
    end
    local isRed = false
    if self.selectButton == FuncQuestAndChat.leafBladeType.mission then
        isRed = false  --六界轶事
        self.panel_t.panel_1:setVisible(false)
        local mc_1 =  self.panel_b.mc_2:getViewByFrame(1).mc_1
        local panel_1 = mc_1:getViewByFrame(2).panel_1
        panel_1:setVisible(false)
    else
        isRed = TargetQuestModel:isHaveFinishQuest() or DailyQuestModel:isHaveFinishQuest() or false
    end
    self.panel_t.panel_red:visible(isRed)





end

function QuestAddMainListView:setArrData(arrData,cellBack)

    self.cellBack = cellBack
	self.arrData = arrData or  {systemView = "home"}
    self.selectButton = nil
    
    self.first_show_UI = true

    -- if self.arrData.systemView == nil or self.arrData.systemView ~= FuncCommon.SYSTEM_NAME.LOVE then
    --     self:showComplete()
        
    -- end


    self:showSelectUI()
	
end


function QuestAddMainListView:showSelectUI()
    self:initUI()
end


function QuestAddMainListView:registerEvent()
    -- self.btn_back:setTouchedFunc(c_func(self.press_btn_back, self));
    -- EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
    --     self.setRedPoint, self);
    -- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_b, UIAlignTypes.Left)

    EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP ,self.onUIShowComp,self)
    -- EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP ,self.hideUIShowComp,self)
    EventControler:addEventListener(MissionEvent.MISSIONUI_REFRESH_DATI_NUM ,self.refreshMission,self)
    
    -- EventControler:addEventListener(UIEvent.UIEVENT_STARTHIDE ,self.starshow,self)
    EventControler:addEventListener(HomeEvent.HOMEEVENT_COME_BACK_TO_MAIN_VIEW, 
        self.onHomeShow, self);

    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID ,self.initUI,self)

    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.initUI, self)

    -- EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
    --     self.initUI, self); 
    -- EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
    --     self.initUI, self); 
        

    self.panel_b.panel_di:setTouchedFunc(GameVars.emptyFunc,nil,true)
    self.panel_b.panel_di:setTouchSwallowEnabled(true)

    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.onQuestChange, self);
     EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.onQuestChange, self);

    self.panel_b.btn_2:setTouchedFunc(c_func(self.closeChat, self),nil,true);   


    local mc_1 =  self.panel_b.mc_2:getViewByFrame(1).mc_1
    mc_1:setTouchedFunc(c_func(self.worldMapTouch, self),nil,true);   

end

function QuestAddMainListView:worldMapTouch()
    
    EventControler:dispatchEvent(WorldEvent.TOUCHTRIAK_ICON_PLOT)

end


function QuestAddMainListView:onUIShowComp()
    local titledata = QuestAndChatModel:getAllData(self.arrData)
    local isOpen = false
    -- dump(titledata,"=======onUIShowComp========")
    for k,v in pairs(titledata) do
        if v == 2 then
            isOpen = true
        end
    end
    if not isOpen then
        self:initUI()
    end
end


function QuestAddMainListView:onHomeShow(event)

    local currentVieName = event.params.currentVieName
    if currentVieName == "WorldMainView"  then
        self:showRecommendedIcon()
        self:setjuqinReommended()
        local level = FuncDataSetting.getOriginalData("NewPlayerLevel")  
        if  UserModel:level() < level then
            if not self.isOpenView then
                self:showComplete()
            end
        end
    end
    


end



function QuestAddMainListView:initUI()
	-- local data = {
	-- 	systemView = "",--系统
	-- 	view = self,---界面
    --  system = "",--系统名称
	-- }
    -- echoError("111111111111111111")

    -- if  TutorialManager.getInstance():isInTutorial() then
    -- end
    self.panel_b:setVisible(true)
    self.selectButton = 2

    self.titledata = QuestAndChatModel:getAllData(self.arrData)
    -- dump(self.titledata,"0000000000000")
    if self.arrData.systemView == FuncCommon.SYSTEM_NAME.MISSION then
        if self.arrData.data ~= nil then
            self.selectButton = FuncQuestAndChat.leafBladeType.mission
            local mc_1 =  self.panel_b.mc_2:getViewByFrame(1).mc_1
            local panel_1 = mc_1:getViewByFrame(2).panel_1
            panel_1:setVisible(false) 
        end
    end
    if #self.titledata <= 1 then
        self.selectButton = 1
    else
        local data = DailyQuestModel:getTrackData()
        if data and #data == 0 then
            self.selectButton = 1 
        end
    end



	local offX,width = FuncQuestAndChat.getWithAndHight(self.titledata)

	local createFunc = function(itemData)
		local view = UIBaseDef:cloneOneView(self.panel_b.panel_title)
		self:updateViewItem(view, itemData)
		return view
	end
	local updateCellFunc = function (itemData,view)
        self:updateViewItem(view,itemData)
    end


	local  _scrollParams = {
 		{
            data = self.titledata,
            createFunc = createFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 1,    
            widthGap = 0,
            heightGap = 0,
            itemRect = {x = 0, y = -width, width = 40, height = width},
            perFrame = 5,
        }
    }    
	self.panel_b.scroll_1:styleFill(_scrollParams);
    self.panel_b.scroll_1:hideDragBar()
    self.panel_b.scroll_1:refreshCellView(1)

    if table.length(self.titledata) < 3 then
    	self.panel_b.scroll_1:setCanScroll( false )
    end
    if self.titledata[1] and self.titledata[1] == FuncQuestAndChat.leafBladeType.mission then
        self:showUI(self.titledata[1])
    else
        if self.selectButton ~= nil then
            self:showUI( self.selectButton)
        else
            if #self.titledata ~= 0 then
                -- self.selectButton = self.titledata[1]
                self:showquestView()
            end
        end
    end

end

function QuestAddMainListView:updateViewItem(view,itemData)


   
    self:showViewMc(view,itemData)

    -- local panel_red = view.mc_1.currentView.panel_red
    -- if panel_red ~= nil then
	   -- -- panel_red:visible(false)
    -- end

	
    
end

function QuestAddMainListView:showViewMc(view,itemData)
    local num = table.length(self.titledata)
    local frame = 1
    if num == 1 then
        frame = 1
        view.mc_1:showFrame(frame)
    elseif num == 2 then
        frame = 3
        view.mc_1:showFrame(frame)
        if self.selectButton ~= nil then
            if self.selectButton == itemData then
                view.mc_1:showFrame(frame)
            else
                frame = 2
                view.mc_1:showFrame(frame)
            end
        else
            if self.selectButton == itemData then
                view.mc_1:showFrame(frame)
            else
                frame = 3
                view.mc_1:showFrame(frame)
            end
        end
    elseif num >= 3 then
        frame = 5
        view.mc_1:showFrame(frame)
        if self.selectButton ~= nil then
            if self.selectButton == itemData then
                view.mc_1:showFrame(4)
            else
                frame = 5
                view.mc_1:showFrame(frame)
            end
        end

    end
    view.mc_1:getViewByFrame(1).panel_red:setVisible(false)
    view.mc_1:getViewByFrame(frame).txt_1:setString(FuncQuestAndChat.leafBladeTitle[itemData])
    view.mc_1:getViewByFrame(frame):setTouchedFunc(c_func(self.showUI, self,itemData),nil,true);

    return view.mc_1:getViewByFrame(frame)
end

--剧情推荐
function QuestAddMainListView:setjuqinReommended()
    self.panel_b.mc_2:showFrame(1)
    local mc_1 =  self.panel_b.mc_2:getViewByFrame(1).mc_1
    mc_1:showFrame(2)
    local curRaidId = WorldModel:getNextMainRaidId()
    local curRaidData = FuncChapter.getRaidDataByRaidId(curRaidId)
    local npcId = curRaidData.storyNpc
    local headName = curRaidData.head
    local ctn_1 = mc_1:getViewByFrame(2).ctn_1
    if ctn_1.headName ~= headName then
        ctn_1.headName = headName
        local npcHead = display.newSprite(FuncRes.iconHead(headName))
        ctn_1:removeAllChildren()
        local artMaskSprite = display.newSprite(FuncRes.iconOther("partner_tou"))
        local headSprite = FuncCommUI.getMaskCan(artMaskSprite,npcHead)
        headSprite:setScale(0.65)
        ctn_1:addChild(headSprite)
    end
    
    local panel_1 = mc_1:getViewByFrame(2).panel_1
    ---加特效
    if not self.lockAni1 then
        local ctn_s = mc_1:getViewByFrame(2).ctn_s
        ctn_s:removeAllChildren()
        self.lockAni1 = self:createUIArmature("UI_liujie","UI_liujie_di", ctn_s, true, function ()
        end)
        self.lockAni1:setScaleX(1.15)
        self.lockAni1:setScaleY(0.8)
    end
    if not self.lockAni2 then
        self.lockAni2 = self:createUIArmature("UI_liujie","UI_liujie_jiantou", panel_1, true, function ()
        end)
    end
    if not self.lockAni3 then
        self.lockAni3 = self:createUIArmature("UI_liujie","UI_liujie_jiantou", self.panel_t.panel_1, true, function ()
        end)
        -- self.lockAni3:setVisible(false)
    end

    local raidData = FuncChapter.getRaidDataByRaidId(curRaidId)
    local chat = raidData.chat
    local desStr = ""
    
    if not WorldModel:isRaidLock(curRaidId) then
        if chat and chat[1] then
            desStr = FuncTranslate._getLanguageWithSwap(chat[1], UserModel:name())
        end         
        -- panel_1:setVisible(true)
        if self.lockAni1 then
            self.lockAni1:setVisible(true)
        end

        if self.lockAni2 then
            -- if HomeModel:isOpenPVPFile() then
            --     self.lockAni2:setVisible(false)
            -- else
                self.lockAni2:setVisible(true)
            -- end
        end 
         
        if  TutorialManager.getInstance():isInTutorial() then
            panel_1:setVisible(false)
        else
            if HomeModel:isOpenPVPFile() then
                panel_1:setVisible(false)   
            else
                panel_1:setVisible(true)
            end
        end

      

    else
        if chat and chat[2] then            
            local openLevel = raidData.condition[2].v 
            desStr = FuncTranslate._getLanguageWithSwap(chat[2], openLevel)
        end
        panel_1:setVisible(false)
        if self.lockAni1 then
            self.lockAni1:setVisible(false)
        end
        if self.lockAni2 then
            self.lockAni2:setVisible(false)
        end
    end
    local rich_1 = mc_1:getViewByFrame(2).rich_1
    rich_1:setString(desStr or "")

end


function QuestAddMainListView:showUI( itemData )

    -- echoError("======itemData=========",itemData)
   self.selectButton = itemData
    if itemData == FuncQuestAndChat.leafBladeType.quest then
        self:showquestView(itemData)
        self.panel_b.mc_2:showFrame(1)
        self:setjuqinReommended()
    elseif itemData == FuncQuestAndChat.leafBladeType.evertDay then
        self:showquestView(itemData)
        self.panel_b.mc_2:showFrame(1)
        self:setjuqinReommended()
    elseif itemData == FuncQuestAndChat.leafBladeType.mission then
        self.panel_b.mc_2:showFrame(2)
        self:showMissionView() 
        -- self.panel_b.btn_2:setVisible(false)
    end
    QuestAndChatModel:setselectViewName(itemData)
    self.selectButton  = itemData
    if itemData ~= FuncQuestAndChat.leafBladeType.mission then
        for k,v in pairs(self.titledata) do
            local _cell = self.panel_b.scroll_1:getViewByData(v);
            if _cell then
                local view = self:showViewMc(_cell,v)
                local panel_red = _cell.mc_1.currentView.panel_red
                local isshow = QuestAndChatModel:getTitleRed(v)
                panel_red:visible(isshow)
            end
        end
    end

    -- self.panel_b.mc_2:getViewByFrame(self.selectButton).scroll_1:setVisible(false)
    -- self.panel_b.mc_2:getViewByFrame(itemData):setVisible(true)

end
	

--当事件变化 延迟一帧显示
function QuestAddMainListView:onQuestChange(e)
    self.panel_b:stopAllActions()
    self.panel_b:delayCall(c_func(self.showquestView,self), 0.01)
end


--目标界面
function QuestAddMainListView:showquestView(_type)
    -- echoError("66666666666666666666-=====",self.selectButton)
    -- if tonumber(self.selectButton) ~= tonumber(FuncQuestAndChat.leafBladeType.quest) 
    --     or tonumber(self.selectButton) ~= tonumber(FuncQuestAndChat.leafBladeType.evertDay) then
    --     return 
    -- end
    -- echoError("777777777777777777======",self.selectButton)
    if  self.titledata then
        for k,v in pairs(self.titledata) do
            local _cell = self.panel_b.scroll_1:getViewByData(v);
            if _cell then
                local panel_red = _cell.mc_1.currentView.panel_red
                local isshow = QuestAndChatModel:getTitleRed(v)
                panel_red:visible(isshow)
            end
        end
    end



    QuestAndChatModel:setselectViewName(self.selectButton)
	self.panel_b.mc_2:showFrame(1)
    self.panel_b.mc_2:setVisible(true)
	
    local alldata = {}
    local dailytrue = nil

    -- echoError("========self.selectButton========",self.selectButton)
    if self.selectButton == FuncQuestAndChat.leafBladeType.quest then
        -- echoError("222222222222222222")
        local isOpenQuest = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST)
        if isOpenQuest then
            local  _tabKind = TargetQuestModel.TAB_KIND.ALL;
            alldata = TargetQuestModel:getAllShowMainQuestId(_tabKind);
            dailytrue = false
        end
    elseif self.selectButton == FuncQuestAndChat.leafBladeType.evertDay then
        -- echoError("33333333333333333")
        local isOpenEvery = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.EVERY_DAY_QUEST)
        if isOpenEvery then
            local allDailyQuestIds = DailyQuestModel:getTrackData()  --DailyQuestModel:getAllShowDailyQuestId();
            alldata = allDailyQuestIds  ---目标数据
            dailytrue = true
        end
    end

    -- if #alldata == 0  then
    --     self.panel_b.rich_1:setVisible(true)
    -- else
        -- self.panel_b.rich_1:setVisible(false)
    -- end


    -- dump(alldata,"任务数据结构======")
	local mc_1 = self.panel_b.mc_2:getViewByFrame(1).mc_1
	local createFunc = function(itemData)
		local view = UIBaseDef:cloneOneView(mc_1)
		self:updateCellView(view, itemData,dailytrue)
		return view
	end
	 local updateCellFunc = function (itemData,view)
        self:updateCellView(view,itemData,dailytrue)
    end


	local  _scrollParams = {
 		{
            data = alldata,
            createFunc = createFunc,
            updateCellFunc = updateCellFunc,
            perNums = 1,
            offsetX = 0,
            offsetY = 6,
            widthGap = 0,
            heightGap = 2,
            itemRect = {x = 0, y = -79, width = 220, height = 79},
            perFrame = 5,
        }
    }    
    
    local scroll_1 = self.panel_b.mc_2:getViewByFrame(1).scroll_1
    scroll_1:refreshCellView(1)
	scroll_1:styleFill(_scrollParams);
    scroll_1:hideDragBar()


end



function QuestAddMainListView:finishCallBack(event)
    if event.result then
        -- function callBack()
			EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD); 
			local rewards = FuncQuest.getQuestReward(1, self._lastFinishQuest);
			FuncCommUI.startRewardView(rewards)
			FuncCommUI.ShowRecordTips(self._lastFinishQuest)
            if UserModel:isLvlUp() == true then 
                EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
            end
			 -- if TargetQuestModel:isHaveFinishQuest() == true then 
	   --          EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
	   --              {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
	   --      else 
	   --          EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
	   --              {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
	   --      end 
            TargetQuestModel:mainQuestChangeCallBack()

	        if TargetQuestModel:isQuestComplete(self._lastFinishQuest) == true then 
	        	--在发送一个任务变化消息
	        	EventControler:dispatchEvent(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT, {questType = TargetQuestModel.Type.RAID}); 
	        end
	        self:showquestView()
		-- end
    end
end


--完成目标的方法
function QuestAddMainListView:finishBtnClick( questId )
	self._lastFinishQuest = questId
	QuestServer:getMainQuestReward(questId, c_func(self.finishCallBack, self))

end

function QuestAddMainListView:goToTargetView(questId)

    local view2 = WindowControler:checkCurrentViewName( "AnimDialogView" )
    if view2 then
        return 
    end
    -- echo("goToView " .. tostring(questId));
    local questType = FuncQuest.readMainlineQuest(questId, "conditionType");

    local jumpInfo = TargetQuestModel.JUMP_VIEW[tostring(questType)];

    if jumpInfo ~= nil then
        TargetQuestModel:setSelectIndex(questId)
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
        end 

        --发送显示tips事件
        EventControler:dispatchEvent(QuestEvent.JUMP_FROM_QUEST,
            {questId = questId, questType = 2});
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_008"));
    end 

end
function QuestAddMainListView:issystemUpOpen(systemname)
    local level =  UserModel:level()
    local openData =  FuncCommon.isSystemOpen(systemname) --FuncCommon.getSysOpenData()[tostring(systemname)]
    if openData then
        return true
    end
    return false
end


function QuestAddMainListView:updateCellView(view,questId,dailytrue)
	if dailytrue then
        self:dailyQuestData(view,questId)
    else
        self:targetQuestData(view,questId)
    end
end


function QuestAddMainListView:finishDailyCallBack( event )
    function callBack()
        EventControler:dispatchEvent(QuestEvent.AFTER_QUEST_GET_REWARD);
        local rewards = FuncQuest.getQuestReward(2, self._lastDAilyFinishQuest);
        if rewards == nil then
            return 
        end
        FuncCommUI.startRewardView(rewards)
        -- FuncCommUI.startFullScreenRewardView(rewards,callfun );

        if UserModel:isLvlUp() == true then 
            EventControler:dispatchEvent(UserEvent.USEREVENT_LEVEL_CHANGE); 
        end 

        -- if TargetQuestModel:isHaveFinishQuest() == true or 
        --     DailyQuestModel:isHaveFinishQuest() == true then 
        --     EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        --         {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = true});
        -- else 
        --     EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
        --         {redPointType = HomeModel.REDPOINT.NPC.QUEST, isShow = false});
        -- end 
        TargetQuestModel:mainQuestChangeCallBack()

        self:showquestView()
    end
    if event.result then
        callBack()
    end
end

function QuestAddMainListView:finishDailyBtnClick(questId)
    if DailyQuestModel:isDailyQuestFinish(questId) == true then 
        -- UserModel:cacheUserData()
        self._lastDAilyFinishQuest = questId
        QuestServer:getEveryQuestReward(questId, c_func(self.finishDailyCallBack, self))
    else 
        WindowControler:showTips(GameConfig.getLanguage("#tid_quest_ui_004"));
    end 
end

--日常
function QuestAddMainListView:goToDailyView(questId)

    local view2 = WindowControler:checkCurrentViewName( "AnimDialogView" )
    if view2 then
        return 
    end


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
end


function QuestAddMainListView:dailyQuestData(cellview,questId)
    local view = cellview:getViewByFrame(1)
    -- self.panel_b.mc_2:setVisible(true)
    -- view.panel_kuang:setVisible(true)
    -- view.ctn_1:removeAllChildren()

    local ctn = view.ctn_s
    -- ctn:removeAllChildren()
    local btneffect = ctn:getChildByName("effect")
    local isFinish = DailyQuestModel:isDailyQuestFinish(questId); 
    if isFinish then
        view.mc_1:setVisible(true)
        view.mc_1:showFrame(2)
        view.panel_bg:setTouchedFunc(c_func(self.finishDailyBtnClick, self,questId),nil,true);
         
        if btneffect == nil then
            local lockAni = self:createUIArmature("UI_task","UI_task_renwu05", ctn, true, function ()
            end)
            lockAni:setName("effect")
             lockAni:setScaleX(1.05)
            lockAni:setScaleY(0.96)
        else
            btneffect:setVisible(true)
        end
    else
        if btneffect ~= nil then
            btneffect:setVisible(false)
        end
        view.mc_1:setVisible(false)
        view.panel_bg:setTouchedFunc(c_func(self.goToDailyView, self,questId),nil,true);
    end


    -- local iconName = FuncQuest.readEverydayQuest(questId, "icon");
    -- local iconPath = FuncRes.iconQuest(iconName) --FuncRes.iconRes(FuncDataResource.RES_TYPE.EXP,FuncDataResource.RES_TYPE.EXP)
    -- local iconSp = display.newSprite(iconPath); 
    -- iconSp:setScale(0.5)
    -- view.ctn_1:addChild(iconSp);


    local needCount = TargetQuestModel:needCount(questId);
    local completeCount = TargetQuestModel:finishCount(questId);

    if isFinish then
        completeCount = needCount
    end

    local needCount = DailyQuestModel:needCount(questId);
    local completeCount = DailyQuestModel:finishCount(questId);
    -- view.progress_1:setPercent( math.abs(100 * completeCount / needCount) );


    -- view.txt_3:setString(string.format("%d/%d", completeCount, needCount));\



    local str = "【<color = ff0000 >"..completeCount.."/"..needCount.."<->】"
    if tonumber(completeCount) >= needCount then
        str = "【<color = 00ff00 >"..needCount.."/"..needCount.."<->】"
    end

    local typeIndex = 2
    local desId = FuncQuest.getQuestDes(typeIndex, questId);
    view.rich_2:setString(GameConfig.getLanguage(desId)..str);  


    local questNameId = FuncQuest.getQuestName(typeIndex, questId);
    view.txt_1:setString(GameConfig.getLanguage(questNameId));


end


function QuestAddMainListView:targetQuestData(cellview,questId)
    -- self.panel_b.mc_2:setVisible(true)
    local view = cellview:getViewByFrame(1)
    -- view.panel_kuang:setVisible(false)
    -- view.ctn_1:removeAllChildren()
    local ctn = view.ctn_s
    -- ctn:removeAllChildren()
    local btneffect = ctn:getChildByName("effect")
    local isFinish = TargetQuestModel:isMainLineQuestFinish(questId); 
    -- 是不是推荐
    if TargetQuestModel:isRecommendQuest(questId) == true then 
        view.mc_1:setVisible(true)
         
        if  isFinish then
            view.mc_1:showFrame(2)
            view.panel_bg:setTouchedFunc(c_func(self.finishBtnClick, self,questId),nil,true);
            if btneffect == nil then
                local lockAni = self:createUIArmature("UI_task","UI_task_renwu05", ctn, true, function ()
                end)
                lockAni:setName("effect")
                lockAni:setScaleX(1.05)
                lockAni:setScaleY(0.96)
            else
                btneffect:setVisible(true)
            end
        else
            if btneffect ~= nil then
                btneffect:setVisible(false)
            end
            view.mc_1:showFrame(1)
            view.panel_bg:setTouchedFunc(c_func(self.goToTargetView, self,questId),nil,true);
        end
    else
        view.mc_1:setVisible(false)
        if isFinish then
            view.mc_1:setVisible(true)
            view.mc_1:showFrame(2)
            view.panel_bg:setTouchedFunc(c_func(self.finishBtnClick, self,questId),nil,true);
            local ctn = view.ctn_s
            -- ctn:removeAllChildren()
            if btneffect == nil then
                local lockAni = self:createUIArmature("UI_task","UI_task_renwu05", ctn, true, function ()
                end)
                lockAni:setScaleX(1.01)
                lockAni:setName("effect")
            else
                btneffect:setVisible(true)
            end
        else
            if btneffect ~= nil then
                btneffect:setVisible(false)
            end
            view.panel_bg:setTouchedFunc(c_func(self.goToTargetView, self,questId),nil,true);
        end
    end
    -- local iconName = FuncQuest.readMainlineQuest(questId, "icon");
    -- local iconPath = FuncRes.iconQuest(iconName)
    -- local iconSp = display.newSprite(iconPath); 
    -- iconSp:setScale(0.5)
    -- view.ctn_1:addChild(iconSp);


    local needCount = TargetQuestModel:needCount(questId);
    local completeCount = TargetQuestModel:finishCount(questId);

    if isFinish then
        completeCount = needCount
    end


    -- view.txt_3:setString(string.format("%d/%d", completeCount, needCount));
    -- view.progress_1:setPercent( math.abs(100 * completeCount / needCount) );
    local typeIndex = 1
    local questNameId = FuncQuest.getQuestName(typeIndex, questId);
    view.txt_1:setString(GameConfig.getLanguage(questNameId));

    local str = "【<color = ff0000 >"..completeCount.."/"..needCount.."<->】"
    if tonumber(completeCount) >= needCount then
        str = "【<color = 00ff00 >"..completeCount.."/"..needCount.."<->】"
    end
   
    local desId = FuncQuest.getQuestDes(typeIndex, questId);
    view.rich_2:setString(GameConfig.getLanguage(desId)..str);  


end

function QuestAddMainListView:refreshMission()
    if self.arrData.data == nil then
        return
    end
    self:showMissionView()
end

--六界轶事
function QuestAddMainListView:showMissionView()

    if self.arrData.data == nil then
        self.panel_b.mc_2:setVisible(false)
        return
    end

    self.panel_b.mc_2:setVisible(true)
	local data = self.arrData.data
    local missionId = data.id
    local panel = self.panel_b.mc_2:getViewByFrame(2)
    panel.txt_1:setString(FuncMission.getMissionName(missionId)) --任务名称
   

    for i=1,5 do  --奖励
        panel["UI_"..i]:setVisible(false)
    end

    panel.panel_help:setTouchedFunc(c_func(self.missionHelpButton, self),nil,true);

        -- 任务描述
        local desStr = FuncMission.getMissionDes(missionId)
    
        
        local missionData = FuncMission.getMissionDataById( missionId )
        local total = missionData.goalParam
        
        -- 任务目标
        local jindu = MissionModel:getMissionJindu(missionId,data.startTime)
        panel.rich_2:setString(FuncMission.getMissionGoal(missionId,jindu))
        panel.txt_3:setString(jindu.."/"..total)--FuncMission.getMissionGoal(missionId,jindu))
        panel.progress_1:setPercent( math.abs(100 * jindu / total) );

        local _rewards = MissionModel:getMissionReward(missionId)
        -- 获取需要的格式
        for i,v in pairs(_rewards) do
            local strT = string.split(v,",")
            local str = v
            local datas = {}
            datas.reward = str
            local itemView = panel["UI_"..i]
            if itemView then
                itemView:visible(true)
                itemView:setRewardItemData(datas)
                -- itemView:showResItemName(true)
                -- itemView:showResItemNum(false)
                -- 注册点击事件
                FuncCommUI.regesitShowResView(itemView,strT[1],0,strT[2],str,true,true)
            end
        end
        
end

function QuestAddMainListView:missionHelpButton()
    
    WindowControler:showWindow("MissionMiaoshuView",self.arrData.data)
end






---退出
function QuestAddMainListView:closeChat()
    if not self.close_UI then

        -- local pos = self.panel_b:getContainerBox();

        -- dump(pos,"追踪栏的位置 ====1111===== ")
        -- dump(self._rect,"追踪栏的位置 ====22222222===== ")
        -- echoError("222222222222222222222")
        local  _otherx,_othery=self.panel_t:getPosition();
        QuestAndChatModel:setOpenView(false)
    	local function _closeCallback()
            self.close_UI = true
            self.first_show_UI = false
    	    self:press_btn_back();
            self.isOpenView = false
            self:showRecommendedIcon()
            -- self.panel_t.btn_1:setScaleX(-1)
    	end
    	-- local  _rect=self.panel_b:getContainerBox();
        -- local  _otherx,_othery=self.panel_b:getPosition()
    	local  _mAction=cc.MoveTo:create(0.2,cc.p(self._rect.x - 500,_othery))-- - _rect.width*1.5,_othery));
    	local  _mSeq=cc.Sequence:create(_mAction,cc.CallFunc:create(_closeCallback));
    	self.panel_b:runAction(_mSeq);
        self.panel_t.panel_red:visible(false)
        self.panel_t:setVisible(true)
        if self.selectButton then
            if  self.selectButton == FuncQuestAndChat.leafBladeType.mission then 
                self.panel_t.panel_1:setVisible(false)
            end
        end
    end
    
end     

--打开
function QuestAddMainListView:showComplete()
    -- self.close_UI = false

    -- local pos = self.panel_b:getContainerBox();

    -- dump(pos,"追踪栏的位置 ========= ")
    -- echoError("111111111111111")
    if self.close_UI then
    	QuestAddMainListView.super.showComplete(self);
        ---界面加入弹出动画
        local  _otherx,_othery=self.panel_t:getPosition();
        -- echo("=======_otherx========",_otherx,_other)
        -- self.panel_b:setPosition(cc.p(_otherx - _rect.width,_othery+GameVars.UIOffsetY));
        local  _mAction = cc.MoveTo:create(0.2,cc.p(self._rect.x,_othery));
        local time = act.delaytime(0.5)
        local function _closeCallback()
                self.close_UI = false
                self.first_show_UI = false
                self.panel_t:setVisible(false)
                self.isOpenView = true
                -- self.panel_t.btn_1:setScaleX(-1)
        end
        self.panel_b:runAction(cc.Sequence:create(_mAction,time,cc.CallFunc:create(_closeCallback)));
        -- self.panel_t.btn_1:setVisible(false)
        self.panel_t:setVisible(false)
        -- self.panel_t.btn_1:setPositionX(15)
    end
end





function QuestAddMainListView:press_btn_back()
    
    -- EventControler:dispatchEvent(QuestEvent.CLOSE_UI_TRACK)
    -- if self.cellBack then
    --     self.cellBack()
    -- end
	-- self:startHide()
end

return QuestAddMainListView



























