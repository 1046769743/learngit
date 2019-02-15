local LogsItem = class("LogsItem", ItemBase);

--[[
    self.mc_1,
]]

function LogsItem:ctor(winName)
    LogsItem.super.ctor(self, winName);
end

function LogsItem:loadUIComplete()
	self:registerEvent();
end 

function LogsItem:registerEvent()
	LogsItem.super.registerEvent();

end

function LogsItem:updateUI(index,adapter)
	local msg = adapter:getDataByIndex(index);
	local logType = adapter:getUIView():getLogType()

	self.mc_1:showFrame(logType)
	self.mc_1.currentView.txt_1:setString(msg)

	return self
end

function LogsItem:setMessage( logsType,message )
	self.mc_1.currentView.txt_1:setString("")
	self.mc_1:showFrame(logsType)
	self.mc_1.currentView.txt_1:setString(message)
end


return LogsItem;
