
-- //通用回主城栏
-- //2018-5-15
local CompGoHome = class("CompGoHome", UIBase);


function CompGoHome:loadUIComplete(  )
	
	self:alignChildView()
	self:registerEvent()
	self:setButton()
	self:buttonIsShow()
end

-- 适配对齐
function CompGoHome:alignChildView( ... )
	-- 注册事件
	--适配
	if self.btn_tophome then
		ScreenAdapterTools.setViewAlign(self.widthScreenOffset,self.btn_tophome,UIAlignTypes.LeftTop)
	end
	if self.btn_topchat then
		ScreenAdapterTools.setViewAlign(self.widthScreenOffset,self.btn_topchat,UIAlignTypes.RightTop)
	end
	if self.btn_topmubiao then
		ScreenAdapterTools.setViewAlign(self.widthScreenOffset,self.btn_topmubiao,UIAlignTypes.RightTop)
	end
	if self.scale9_background then
		ScreenAdapterTools.setScale9Align(self.widthScreenOffset,self.scale9_background,UIAlignTypes.MiddleTop,1)
	end
end

function CompGoHome:setButton()
	if self.btn_tophome then
		self.btn_tophome:setTap(c_func(self.onBackHome,self))
	end
	if self.btn_topchat then

		self.btn_topchat:setTap(c_func(self.pressChatBtn,self))
	end
	
	if self.btn_topmubiao then

		self.btn_topmubiao:setTap(c_func(self.pressTaskBtn,self))
	end
	self:setButtonRed()
end

function CompGoHome:registerEvent()

	if self.btn_topmubiao then
		EventControler:addEventListener(QuestEvent.DAILY_QUEST_CHANGE_EVENT,
	        self.setButtonRed, self); 
	    EventControler:addEventListener(QuestEvent.MAINLINE_QUEST_CHANGE_EVENT,
	        self.setButtonRed, self); 

	    EventControler:addEventListener(ChatEvent.PRIVATE_CHAT_CONTENT_UPDATE,
	    	self.setButtonRed,self);

	    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
	        self.buttonIsShow, self)
	end
	

end

function CompGoHome:buttonIsShow()
	if self.btn_topchat then
		local open_1 = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.CHAT) 
		if open_1 then
			self.btn_topchat:setVisible(true)
		else
			self.btn_topchat:setVisible(false)
		end
	end
	
	if self.btn_topmubiao then
		local open_2 = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.MAIN_LINE_QUEST)
		if open_2 then
			self.btn_topmubiao:setVisible(true)
		else
        	self.btn_topmubiao:setVisible(false)
    	end
	end
end


--点击聊天按钮
function CompGoHome:pressChatBtn(  )
	WindowControler:showWindow("ChatMainView", 1);
end

--点击目标按钮
function CompGoHome:pressTaskBtn(  )
	WindowControler:showWindow("QuestMainView");
	-- EventControler:dispatchEvent(QuestEvent.TOP_COMP_HOME_BUTTON)
end

function CompGoHome:closeView()

    -- self:showRewardQiPaoView()
end


function CompGoHome:setButtonRed()
   

    if self.btn_topmubiao then
    	local questred = false --TargetQuestModel:isHaveFinishQuest()
	    local  _tabKind = TargetQuestModel.TAB_KIND.ALL;
	    local allMainLineQuestIds = TargetQuestModel:getAllShowMainQuestId(_tabKind);
	    local allDailyQuestIds = DailyQuestModel:getTrackData() --DailyQuestModel:getAllShowDailyQuestId();
	    if #allDailyQuestIds ~= 0 then
	        questred = DailyQuestModel:isHaveMainFinishQuest()
	    else
	        questred = TargetQuestModel:isHaveFinishQuest()
	    end

	    local panel_red = self.btn_topmubiao:getUpPanel().panel_red
    	panel_red:setVisible(questred)
    end

    if self.btn_topchat then
    	local chatred = ChatModel:getPrivateDataRed()
    	local panel_red = self.btn_topchat:getUpPanel().panel_red
    	panel_red:setVisible(chatred)
    end 


end


function CompGoHome:onBackHome(  )
	if self.backHomeFunc then
		self.backHomeFunc()
	end

	--关闭所有非相关ui直接回主城
	WindowControler:goBackToHomeView()
	EventControler:dispatchEvent(HomeEvent.CLICK_GOHOME_EVENT) 
end

--针对单独ui单独设置的回调函数,主要处理关闭界面时触发的事件或者控制器
function CompGoHome:setBackHomeFumc( func )
	self.backHomeFunc = func
end

return CompGoHome;
