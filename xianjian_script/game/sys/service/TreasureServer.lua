--
-- Author: ZhangYanguang
-- Date: 2016-01-05
--
--法宝系统，网络服务类

local TreasureServer = class("TreasureServer")

-- 设置法宝阵型
function TreasureServer:setFormula(formulaType,treasureIdList,callBack)
	local params = {
		type = formulaType,
		formula = treasureIdList
	}
	Server:sendRequest(params, MethodCode.treasure_setFormula_407, callBack)
end

function TreasureServer:plusStar(treasureId, callBack)
	echo("plusStar " .. tostring(treasureId));
	local params = {
		treasureId = treasureId
	}
	Server:sendRequest(params, MethodCode.treasure_upgradeStar_403, callBack)
end

function TreasureServer:enhance(treasureId, count, callBack)
	echo("enhance " .. tostring(treasureId));
	echo("count " .. tostring(count));
	local params = {
		treasureId = treasureId,
		times = count
	}
	Server:sendRequest(params, MethodCode.treasure_upgradeLevel_401, callBack);
end

function TreasureServer:refine(treasureId, callBack)
	echo("refine " .. tostring(treasureId));
	local params = {
		treasureId = treasureId
	}
    Server:sendRequest(params,
        MethodCode.treasure_upgradeState_405, callBack);
end

return TreasureServer











