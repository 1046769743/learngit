--
-- Author: ZhangYanguang
-- Date: 2017-01-04
--
--主角模块，网络服务类
local CharServer = class("CharServer")

-- 主角升品
function CharServer:qualityLevelUp(params,callBack)
	Server:sendRequest(params,MethodCode.char_qualitry_levelup_349, callBack)
end
-- 主角升品道具装备
function CharServer:qualityEquip(params,callBack)
	Server:sendRequest(params,MethodCode.char_qualitry_equip_357, callBack)
end

-- 主角升星
function CharServer:starUpLevel(params,callBack)
    Server:sendRequest(params,MethodCode.char_star_levelUp_353, callBack)
end

-- 主角装备升级
function CharServer:equipUpLevel(params,callBack)
    Server:sendRequest(params,MethodCode.char_equip_levelUp_355, callBack)
end
function CharServer:equipAwake(params,callBack)
    Server:sendRequest(params,MethodCode.char_equip_awake_373, callBack)
end

function CharServer:SendTouXianShengJi(callBack)
	local params = {}
	Server:sendRequest(params,MethodCode.char_Buy_touxian_351, callBack)
end
return CharServer
