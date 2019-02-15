local WuLingServer = class("WuLingServer")

--五灵法阵提升    5701协议 根据新方案 改为激活五灵
-- function WuLingServer:upgradeMatrixMethod(params,callBack)
--     Server:sendRequest(params, MethodCode.fivesouls_upgradeLevel_5701, callBack);
-- end

--激活五灵
function WuLingServer:activateFiveSouls(params,callBack)
    Server:sendRequest(params, MethodCode.fivesouls_activate_5701, callBack);
end

--五灵提升
function WuLingServer:upgradeFiveSouls(params,callBack)
    Server:sendRequest(params, MethodCode.fivesouls_upgradeSoulsLevel_5703, callBack);
end


--五灵重置   新方案已弃置 重置功能
function WuLingServer:resetWuLing(params,callBack)
    Server:sendRequest(params, MethodCode.fivesouls_resetSoulsLevel_5705, callBack );
end

return WuLingServer