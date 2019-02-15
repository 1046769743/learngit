
local WelfareActSevView = class("WelfareActSevView", UIBase);

function WelfareActSevView:ctor(winName)
    WelfareActSevView.super.ctor(self, winName);
end

function WelfareActSevView:loadUIComplete()
	self:registerEvent();
	
end 

function WelfareActSevView:registerEvent()
	WelfareActSevView.super.registerEvent();
	
end
function WelfareActSevView:updateWinthActInfo(actData)
	self:registerEvent();
	self.actData = actData
	local actInfo = actData:getActInfo()
	self.actTaskId = actInfo.taskList[1]

	local title = actInfo.title
	local titTxt = self.panel_1.txt_1

	-- titTxt:setString(GameConfig.getLanguage(title))
	
	local btn = self.btn_1
	btn:setTap(c_func(self.btnTap,self))

	-- 开始时间 结束时间
	local timeInfo = self.actData:getTimeInfo()
	local startTime = timeInfo.start_t
	local endTime = timeInfo.end_t
	local stData = os.date("*t", startTime)
	local edData = os.date("*t", endTime)
	local monStr = "月"
	local dayStr = "日"
	local hourStr = "时"
	local stStr = stData.month..monStr..stData.day..dayStr..stData.hour..hourStr
	local etStr = edData.month..monStr..edData.day..dayStr..edData.hour..hourStr
	-- self.txt_3:setString(stStr.."--"..etStr)

	self.currentFrame = 30
	self:updateTime( )
	self:scheduleUpdateWithPriorityLua(c_func(self.updateTime,self), 0)
end

function WelfareActSevView:updateTime( )
	if self.currentFrame >= 30 then
		self.currentFrame = 0
		local leftTime = self.actData:getDisplayLeftTime()
		self.txt_3:setString(fmtSecToLnDHHMMSS(leftTime))
	end
	self.currentFrame = self.currentFrame + 1
end

function WelfareActSevView:btnTap( )
	local actTaskData = FuncActivity.getActivityTaskConfig(self.actTaskId) 
	local conditionId = actTaskData.condition
	local conditonData = FuncActivity.getConditionById(conditionId)

	-- 跳转
	-- ActTaskModel:jumpToTaskLinkView(self.actTaskId)
	WorldControler:showPVEListView()
end

return WelfareActSevView;
