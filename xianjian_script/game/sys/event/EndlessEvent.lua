--
-- Author: lxh
-- Date: 2018-01-19 16:59:05
--

--无底深渊相关事件

local EndlessEvent = EndlessEvent or {}

EndlessEvent.ENDLESS_DATA_CHANGED = "ENDLESS_DATA_CHANGED"
EndlessEvent.CLOSE_BOSS_DETAIL_VIEW = "CLOSE_BOSS_DETAIL_VIEW"
EndlessEvent.ENDLESS_BOX_STATUS_CHANGED = "ENDLESS_BOX_STATUS_CHANGED"
--购买无底深渊次数成功
EndlessEvent.BUY_ENDLESS_SUCCESS = "BUY_ENDLESS_SUCCESS"
--刷新购买次数
EndlessEvent.COUNT_TYPE_BUY_ENDLESS = "COUNT_TYPE_BUY_ENDLESS"
--战斗结束回来后
EndlessEvent.CAMEBACK_FROM_BATTLE = "CAMEBACK_FROM_BATTLE"
--恢复点击
EndlessEvent.RESUME_UI_CLICK = "RESUME_UI_CLICK"
--点击打开详情界面
EndlessEvent.OPEN_ONE_DETAIL_VIEW = "EndlessEvent.OPEN_ONE_DETAIL_VIEW"
return EndlessEvent