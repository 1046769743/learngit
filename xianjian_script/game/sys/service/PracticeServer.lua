-- PracticeServer
local PracticeServer = class("PracticeServer")

function PracticeServer:init()

end
MethodCode.practice_shengji_4601  = 4601   
MethodCode.practice_tupo_4603  = 4603   
MethodCode.practice_startpractice_4605  = 4605   
MethodCode.practice_getreward_4607  = 4607   
MethodCode.practice_CDpractice_4609  = 4609   ---秒CD

---升级
function PracticeServer:practiceshengjiRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.practice_shengji_4601, _callFunc, nil, nil, true)
end
---突破
function PracticeServer:practicetupoRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.practice_tupo_4603, _callFunc, nil, nil, true)
end
---修炼
function PracticeServer:practicestartRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.practice_startpractice_4605, _callFunc, nil, nil, true)
end
---获得数据
function PracticeServer:practicegetrewardRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.practice_getreward_4607, _callFunc, nil, nil, true)
end
 ---秒CD
function PracticeServer:practiceCDpracticeRequest(_param, _callFunc)
    Server:sendRequest(_param, MethodCode.practice_CDpractice_4609, _callFunc, nil, nil, true)
end

return PracticeServer;