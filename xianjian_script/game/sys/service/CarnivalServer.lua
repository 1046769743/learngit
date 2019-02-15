--
--Author:      zhuguangyuan
--DateTime:    2017-09-14 16:22:19
--Description: 嘉年华网络服务类
--


local CarnivalServer = class("CarnivalServer")

function CarnivalServer:init()
end

--领取任务奖励
function CarnivalServer:getTaskReward(themeId, taskId, callBack, index)
    local params = {
        scheduleId = themeId,
        taskId = taskId,
        index = index
    }
    Server:sendRequest(params,MethodCode.activity_getTaskReward_3601, callBack)
end

--领取全目标奖励
function CarnivalServer:getWholeTargetReward(themeId,taskId,callBack)
    local params = {
        scheduleId = themeId,
        taskId = taskId
    }
    Server:sendRequest(params,MethodCode.activity_getWholeTaskReward_3603, callBack)
end

return CarnivalServer