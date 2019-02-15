--
-- Author: ZhangYanguang
-- Date: 2015-12-26
--PVE系统相关事件
local PveEvent = {}

-- 选择一个节点
PveEvent.PVEEVENT_SELECT_ONE_RAID = "PVEEVENT_SELECT_ONE_RAID"

-- 更新一个节点数据
PveEvent.PVEEVENT_UPDATE_ONE_RAID = "PVEEVENT_UPDATE_ONE_RAID"


--pve战斗结果  返回一个结果 参数 1表示胜利 0表示失败 
PveEvent.PVEEVENT_BATTLERESULT = "PVEEVENT_BATTLERESULT"

return PveEvent