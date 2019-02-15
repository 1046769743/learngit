-- 
--称号系统相关事件
local TitleEvent = {}

--天赋发生了变化
TitleEvent.TitleEvent_TOUCH_NOTTYPE = "TitleEvent_TOUCH_NOTTYPE"  ---点击不同类型数据
TitleEvent.TitleEvent_ONTIME_CALLBACK = "TitleEvent_ONTIME_CALLBACK"  ---时限穿戴中，到时发送消息
TitleEvent.TitleEvent_C_X_CALLBACK = "TitleEvent_C_X_CALLBACK" --穿戴，卸下 
TitleEvent.INFOPLAYER_RED_SHOW = "INFOPLAYER_RED_SHOW"   ---详情界面红点回调
TitleEvent.HONOR_GET_COM = "HONOR_GET_COM"  --完成六界第一
TitleEvent.HONOR_REFRESH_TITLE = "HONOR_REFRESH_TITLE"
TitleEvent.REFRESH_POWER_CHANRE_UI = "REFRESH_POWER_CHANRE_UI"  --称号界面战力变化


return TitleEvent