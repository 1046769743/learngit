--[[
	Author: lichaoye
	Date: 2017-05-12
	签到-Event
]]
local NewSignEvent = {}

NewSignEvent.LUCKY_UPDATE_EVENT = "LUCKY_UPDATE_EVENT" -- 中签列表刷新
NewSignEvent.TOTALSIGN_UPDATE_EVENT = "TOTALSIGN_UPDATE_EVENT" -- 中签列表刷新
NewSignEvent.SIGN_FINISH_EVENT = "SIGN_FINISH_EVENT" -- 抽签结束
NewSignEvent.SIGN_OUT_EVENT = "SIGN_OUT_EVENT" -- 抽签结束
NewSignEvent.SIGN_LINGQUREWARD_EVENT = "SIGN_LINGQUREWARD_EVENT" -- 签到领取奖励刷新红点事件

return NewSignEvent