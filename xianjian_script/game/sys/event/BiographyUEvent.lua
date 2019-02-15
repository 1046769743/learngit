--[[
	奇侠传记消息枚举
	author: lcy
	add: 2018.7.20

	改成 BiographyUEvent 是为了区分表名（有一个同名表）
]]
local BiographyUEvent = {}
-- 参数plotId
BiographyUEvent.EVENT_PLOT_FINISH = "ON_PLOT_FINISH"	-- 对话完成
BiographyUEvent.EVENT_COLLECT_FINISH = "EVENT_COLLECT_FINISH"	-- 收集完成
BiographyUEvent.EVENT_POSITION_FINISH = "EVENT_POSITION_FINISH"	-- 走到指定位置事件完成
-- 参数gametype 游戏类型
BiographyUEvent.EVENT_GAME_FINISH = "EVENT_GAME_FINISH"

-- 更新界面
BiographyUEvent.EVENT_REFRESH_UI = "EVENT_REFRESH_UI" -- 更新UI

return BiographyUEvent