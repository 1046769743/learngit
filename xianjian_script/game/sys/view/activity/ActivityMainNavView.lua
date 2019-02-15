local ActivityMainNavView = class("ActivityMainNavView", UIBase)
local TITLE_LEN_FRAME_MAP = {
	[4] = 1,
	[5] = 2,
	[6] = 3,
	[7] = 4,
	[8] = 4,
}
function ActivityMainNavView:ctor(winName)
	ActivityMainNavView.super.ctor(self, winName)
	self.defaultIndex = 1
end

function ActivityMainNavView:loadUIComplete()
	self.mc_1:visible(false)
	self:registerEvent()
	self.mc_buttons = {}
end

--初始化按钮
function ActivityMainNavView:initMcButtons()
	local createFunc = function(actRecord, index)
		local mc = UIBaseDef:cloneOneView(self.mc_1)
		self:initOneMcButton(mc, actRecord, index)
		return mc
	end
	local params = {
		{
			data = self.acts,
			createFunc = createFunc,
			perNums = 1,
			offsetX =0,
			offsetY = 10,
			widthGap = 0,
			heightGap = 20,
			itemRect = {x=0,y= -112,width = 230,height = 112},
			perFrame=1
		}
	}
	self.scroll_list:styleFill(params)
	self.scroll_list:easeMoveto(0,0,0)
end

function ActivityMainNavView:setMainView(mainView)
	self.mainView = mainView
end

function ActivityMainNavView:setActivities(info)
	self.acts = info
end

function ActivityMainNavView:updateUI(index)
	self:initMcButtons()
	if index == nil then index = self.defaultIndex end
	self:doSelectMcButton(index)
end

function ActivityMainNavView:initOneMcButton(mc, actRecord, index)
	self.mc_buttons[index] = mc
	local btn_1 = mc:getViewByFrame(1).btn_1
	local btn_2 = mc:getViewByFrame(2).btn_2

	local actTitle = actRecord:getActTitle()
	if UserModel:isTest() then
		actTitle = string.format("%s-%s", actRecord:getOnlineId(), actRecord:getActId())
	end
	local titleLen = string.len4cn2(actTitle)/2
	local titleFrame = TITLE_LEN_FRAME_MAP[titleLen]
	if titleFrame == nil then
		titleFrame = 1
	end
	--echo(titleLen, titleFrame, actTitle, 'initOneMcButton000000000000000000000000000000')
	btn_1:getUpPanel().mc_name:showFrame(titleFrame)
	btn_1:getUpPanel().mc_name.currentView.txt_1:setString(actTitle)
	btn_1:getDownPanel().mc_name:showFrame(titleFrame)
	btn_1:getDownPanel().mc_name.currentView.txt_1:setString(actTitle)

	btn_2:getUpPanel().mc_name:showFrame(titleFrame)
	btn_2:getUpPanel().mc_name.currentView.txt_1:setString(actTitle)
	btn_2:getDownPanel().mc_name:showFrame(titleFrame)
	btn_2:getDownPanel().mc_name.currentView.txt_1:setString(actTitle)

	local hasTodo = actRecord:hasTodoThings()
	local showRed = _yuan3(hasTodo, true, false)
	mc:getViewByFrame(1).panel_red:visible(showRed)
	mc:setTouchedFunc(c_func(self.doSelectMcButton, self, index))

	local iconName = actRecord:getActIcon()
	local iconFullPath = FuncRes.iconSkill(iconName)
	btn_1:getUpPanel().ctn_icon:addChild(display.newSprite(iconFullPath):scale(0.5))
	btn_1:getDownPanel().ctn_icon:addChild(display.newSprite(iconFullPath):scale(0.5))
	btn_2:getUpPanel().ctn_icon:addChild(display.newSprite(iconFullPath):scale(0.5))
	btn_2:getDownPanel().ctn_icon:addChild(display.newSprite(iconFullPath):scale(0.5))
end

function ActivityMainNavView:doSelectMcButton(index)
	if self.scroll_list:isMoving() then
		return
	end

	if index == self.currentSelectedIndex then
		return
		
	end
	local lastMc = self.mc_buttons[self.currentSelectedIndex]
	if lastMc then
		lastMc:showFrame(1)
	end
	self.currentSelectedIndex = index
	
	
	local mc = self.mc_buttons[index]
	mc:showFrame(2)

	self.currentSelectedIndex = index
	if self.mainView then
		self.mainView:showActivity(index)
	end
end

function ActivityMainNavView:registerEvent()
	EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.onTaskFinished, self)
    EventControler:addEventListener(UserEvent.USEREVENT_MODEL_UPDATE, self.onUserDataUpdate, self)
end

function ActivityMainNavView:onUserDataUpdate()
	for index, mc in pairs(self.mc_buttons) do
		local actRecord = self.acts[index]
		if actRecord then
			local hasTodo = actRecord:hasTodoThings()
			mc:getViewByFrame(1).panel_red:visible(hasTodo)
		end
	end
end

function ActivityMainNavView:refreshCurrentView()
	if self.mainView then
		self.mainView:showActivity(self.currentSelectedIndex)
	end
end

function ActivityMainNavView:onTaskFinished(event)
	if not self.acts then return end
	local params = event.params
	local actRecord = self.acts[self.currentSelectedIndex]
	if not actRecord then return end
	if actRecord:getOnlineId() == params.onlineId then
		local mc = self.mc_buttons[self.currentSelectedIndex]
		local hasTodo = actRecord:hasTodoThings()
		local showRed = _yuan3(hasTodo, true, false)
		mc:getViewByFrame(1).panel_red:visible(showRed)
	end
end

function ActivityMainNavView:close()
	self:startHide()
end

function ActivityMainNavView:beginClose(call)
end

return ActivityMainNavView
