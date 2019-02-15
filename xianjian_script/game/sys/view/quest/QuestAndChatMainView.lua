-- QuestAndChatMainView.lua

--在主界面添加聊天和目标系统的按钮

local QuestAndChatMainView = class("QuestAndChatMainView", UIBase)



function QuestAndChatMainView:ctor(winName)
    QuestAndChatMainView.super.ctor(self, winName)
    
end

function QuestAndChatMainView:loadUIComplete()
    self.questView = nil
    -- self:registerEvent()
    -- self:initUI()
end


function QuestAndChatMainView:registerEvent()
    -- self.btn_back:setTouchedFunc(c_func(self.press_btn_back, self));
    -- EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
    --     self.setRedPoint, self);
    -- EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
    --     self.setButtonRed, self);
    EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
        self.setButtonRed, self); 

    EventControler:addEventListener(QuestEvent.CLOSE_UI_TRACK,
        self.setViewIsHave, self);
    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
        self.setButtonRed, self); 

    EventControler:addEventListener(ChatEvent.SHOW_RED_TRACK,
        self.setButtonRed, self);

    EventControler:addEventListener(QuestEvent.TOP_COMP_HOME_BUTTON,
        self.onShowquestAndChat, self);    


    EventControler:addEventListener(UIEvent.UIEVENT_SHOWCOMP,self.onUIShowComp,self)
    EventControler:addEventListener(UIEvent.UIEVENT_HIDECOMP,self.onShowComp,self)

    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.openButton, self)

    -- self.panel_1.panel_qi:setVisible(false)

end


function QuestAndChatMainView:onUIShowComp(event)
    -- dump(event.params,"某个ui开始显示")
    local view1 = WindowControler:checkCurrentViewName( "WorldMainView" )
    -- local view2 = WindowControler:checkCurrentViewName( "ChatMainView" )
    -- local view3 = WindowControler:checkCurrentViewName( "AnimDialogView" )

    -- echo("=====view1====view2====view3==",view1,view2,view3)
    if view1  then
        if  not self.openQuestView then
            self.btn_1:setVisible(true)
            -- self.panel_1.panel_11:setVisible(true)
        end
        -- self.panel_2:setVisible(true)
        self:setUIzorder()
        self.arrData = {
            systemView = "world",--系统
        }
        self:openButton()
        return 
    end
end

function QuestAndChatMainView:setUIzorder()

end

function QuestAndChatMainView:onShowComp(event)

    -- self.panel_1:setVisible(true)
    -- self.panel_2:setVisible(true)
    local currentWindw =  WindowControler:checkCurrentViewName("WorldMainView")
    -- local view2 = WindowControler:checkCurrentViewName( "ChatMainView" )
    -- local view3 = WindowControler:checkCurrentViewName( "AnimDialogView" )
    if currentWindw   then
        if  not self.openQuestView then
            self.btn_1:setVisible(true)
            -- self.panel_2:setVisible(true)
            -- self:showRewardQiPaoView()
            
        end
    end
    self:openButton()
end



function QuestAndChatMainView:onShowquestAndChat()
    self:openQuestAndChatMainView()
end




function QuestAndChatMainView:setView(arrData)
    -- self.arrData = arrData
    -- self:showRewardQiPaoView()
end

function QuestAndChatMainView:initUI()  
    self.arrData = {
        systemView = "home",--系统
    }


    -- self:openButton()
    -- self:questButton()
    -- self:chatButton()
    -- self:setButtonRed()
end

function QuestAndChatMainView:openButton()
    local open_1 = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST) 
    local buttonArr = {}
    if open_1 then
        self.btn_1:setVisible(true)
        local cloneBtn = {cloneBtn = self.btn_1 ,name = "quest11"}
        table.insert(buttonArr,cloneBtn)
    else
        self.btn_1:setVisible(false)
    end

    -- local open_1 = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT) 
    -- if open_1 then
    --     local cloneBtn = {cloneBtn = self.panel_2 ,name = FuncCommon.SYSTEM_NAME.CHAT}
    --     table.insert(buttonArr,cloneBtn)
    --     self.panel_2:setVisible(true)
    -- else
    --     self.panel_2:setVisible(false)
    -- end
    HomeModel:insertCtnToclone(buttonArr)
end

function QuestAndChatMainView:chatButton()

	    local function onTouchBegan(touch, event)
			-- dump(touch,"开始 ======")
			self.chatviewButton = false
            return true
        end

        local function onTouchMove(touch, event)
            self.chatviewButton = true
        end

        local function onTouchEnded(touch, event)  
            if not self.chatviewButton then
                WindowControler:showWindow("ChatMainView");
            end
        end

    self.panel_2:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchMove,
         GameVars.emptyFunc, onTouchEnded)

end

function QuestAndChatMainView:questButton()


	   local function onTouchBegan(touch, event)
			-- dump(touch,"开始 ======")
			self.chatviewButton = false
                return true
        end

        local function onTouchMove(touch, event)
            self.chatviewButton = true
        end

        local function onTouchEnded(touch, event)  
            if not self.chatviewButton then
                -- self.panel_1.panel_qi:setVisible(false)
                self:openQuestAndChatMainView()
            end
        end

        self.btn_1:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchMove,
         GameVars.emptyFunc, onTouchEnded)
end

function QuestAndChatMainView:openQuestAndChatMainView()
    if not self.questView then
        self.openQuestView = true
        -- self.panel_1.panel_qi:setVisible(false)
        self.questView = WindowControler:createWindowNode("QuestAddMainListView")
        self.questView:setArrData(self.arrData,c_func(self.closeView, self))
        local scene = display.getRunningScene()
        scene._topRoot:addChild(self.questView)
    else
        if  not self.openQuestView then
            self.openQuestView = true
            self.questView:setVisible(true)
            self.questView:showComplete()
        end
    end
end

function QuestAndChatMainView:closeView()


    self.openQuestView = false
    local currentWindw =  WindowControler:checkCurrentViewName("WorldMainView")
    -- local view2 = WindowControler:checkCurrentViewName( "ChatMainView" )
    -- local view3 = WindowControler:checkCurrentViewName( "AnimDialogView" )
    if currentWindw or view2 or view3 then
        if self.btn_1 and not self.openQuestView then
            self.btn_1:setVisible(true)
            -- self.panel_1.panel_11:setVisible(true)
            -- self.panel_1.panel_qi:setVisible(true)
            -- self:showRewardQiPaoView()
        end
        -- if self.panel_2 then
        --     self.panel_2:setVisible(true)
        -- end 
    end
end


function QuestAndChatMainView:setButtonRed()
    local questred = false

    local  _tabKind = TargetQuestModel.TAB_KIND.ALL;
    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(_tabKind);
    local allDailyQuestIds = DailyQuestModel:getTrackData() --DailyQuestModel:getAllShowDailyQuestId();
    -- if #allDailyQuestIds ~= 0 then
    --     questred = DailyQuestModel:isHaveMainFinishQuest()
    -- else
    --     questred = TargetQuestModel:isHaveFinishQuest()
    -- end
    questred = DailyQuestModel:isHaveMainFinishQuest() or TargetQuestModel:isHaveFinishQuest() or false
    -- local chatred = ChatModel:getPrivateDataRed()
    -- self.btn_1:getUpPanel().panel_red:setVisible(questred)

    -- self:showRewardQiPaoView()

end

function QuestAndChatMainView:setViewIsHave(event)


end




function QuestAndChatMainView:showRewardQiPaoView()

    local  _tabKind = TargetQuestModel.TAB_KIND.ALL;
    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(_tabKind);
    local allDailyQuestIds = DailyQuestModel:getTrackData() 
    local alldata = allDailyQuestIds
    local dailytrue = true
    if #allDailyQuestIds == 0 then
        alldata = allMainLineQuestIds
        dailytrue = false
    end
    self.rewardArr = {}
    if dailytrue then
        for k,v in pairs(alldata) do
            local isFinish = DailyQuestModel:isDailyQuestFinish(v);
            if isFinish then  
                local questNameId = FuncQuest.getQuestName(2, v);
                local data = {str =  GameConfig.getLanguage(questNameId)}
                table.insert(self.rewardArr,data)
            end
        end
    else
        for k,v in pairs(alldata) do
            local isFinish = TargetQuestModel:isMainLineQuestFinish(v); 
            if isFinish then
                local questNameId = FuncQuest.getQuestName(1, v);
                local data = {str =  GameConfig.getLanguage(questNameId)}
                table.insert(self.rewardArr,data)
            end
        end
    end
    if table.length(self.rewardArr) == 0 then
        self.panel_1.panel_qi:setVisible(false)
        return 
    end
    self.panel_1.panel_qi:setVisible(true)
    self.index = 0
    self:addbubblesRunaction()
end
function QuestAndChatMainView:addbubblesRunaction()
    self.panel_1.panel_qi:stopAllActions()
    -- local delaytime_1 = act.delaytime(0.2)
    local scaleto_1 = act.scaleto(0.1,1.2,1.2)
    local scaleto_2 = act.scaleto(0.05,1.0,1.0)
    local delaytime_2 = act.delaytime(4.4)
    local scaleto_3 = act.scaleto(0.1,0)
    local delaytime_3 = act.delaytime(2.0)
    local callfun = act.callfunc(function ()
        self:setBubbleData()
    end)
    local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
    self.panel_1.panel_qi:runAction(act._repeat(seqAct))

end

function QuestAndChatMainView:setBubbleData()
    
    self.index = self.index  +  1
    if self.index > table.length(self.rewardArr)  then
        self.index = 1
    end
    local dataArr = self.rewardArr[self.index]
    if dataArr  ~= nil then 
        local str = GameConfig.getLanguageWithSwap("#tid_Talk_201",dataArr.str)
        self.panel_1.panel_qi.rich_1:setString(str)   
    end

    
end



function QuestAndChatMainView:press_btn_back()

    self:startHide()
end

return QuestAndChatMainView



























