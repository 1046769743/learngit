--
--Author:      zhuguangyuan
--DateTime:    2018-05-22 16:28:36
--Description: 名册系统网络交互类
--

local HandbookServer = class("HandbookServer")

-- 服务器推送信息接收及处理
function HandbookServer:init()

end


--=================================================================================
-- 客户端和服务端交互接口
--=================================================================================
-- MethodCode.handbook_getUp_7501 = 7501 -- 上阵
-- MethodCode.handbook_getDown_7503 = 7503 -- 下阵
-- MethodCode.handbook_upLevel_7505 = 7505 -- 提升名册等级
-- MethodCode.handbook_buyPosition_7507 = 7507 -- 解锁册系内的阵位

-- 上阵
function HandbookServer:enterTheField(dirId,partnerArr,_callBack)
    local params = {
        type = dirId,
        partners = partnerArr,
    }
    Server:sendRequest(params, MethodCode.handbook_getUp_7501, _callBack )
end

-- 下阵
function HandbookServer:leaveTheField(dirId,posIndex,_callBack)
    local params = {
        type = dirId,
        index = posIndex,
    }
    Server:sendRequest(params, MethodCode.handbook_getDown_7503, _callBack )
end

-- 提升一个名册
function HandbookServer:upgradeOneDir(dirId,_callBack)
    local params = {
        type = dirId,
    }
    Server:sendRequest(params, MethodCode.handbook_upLevel_7505, _callBack )
end

-- 解锁一个阵位
function HandbookServer:unlockOnePosition(dirId,posIndex,_callBack)
    local params = {
        type = dirId,
        index = posIndex,
    }
    Server:sendRequest(params, MethodCode.handbook_buyPosition_7507, _callBack )
end

HandbookServer:init()
return HandbookServer