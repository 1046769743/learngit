--[[
	Author: lichaoye
	Date: 2017-6-1
	挂机-Event
]]
local DelegateEvent = {}

DelegateEvent.DELEGATE_TASK_UPDATE = "DELEGATE_TASK_UPDATE" -- 任务状况刷新

DelegateEvent.DELEGATE_FINISH_CHANGE = "DELEGATE_FINISH_CHANGE" -- 挂机任务达成[主要用于红点展示]

DelegateEvent.DELEGATE_VIEW_CLOSE = "DELEGATE_VIEW_CLOSE" --关闭挂机界面

return DelegateEvent