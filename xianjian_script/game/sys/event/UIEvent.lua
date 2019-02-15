--
-- Author: xd
-- Date: 2016-04-06 17:27:40
--
local UIEvent = {}

--目前4个ui事件 带的参数都是 uiView 返回的是这个{ui = uiView,data = data }
-- uiView 是一个uibase对象, datat 是附带的参数
UIEvent.UIEVENT_STARTSHOW = "UIEVENT_STARTSHOW" 	--某个ui开始显示
UIEvent.UIEVENT_SHOWCOMP = "UIEVENT_SHOWCOMP"		--某个ui显示完毕
UIEvent.UIEVENT_STARTHIDE = "UIEVENT_STARTHIDE"		--某个ui开始隐藏
UIEvent.UIEVENT_HIDECOMP = "UIEVENT_HIDECOMP"		--某个ui隐藏完毕



return UIEvent