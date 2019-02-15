--
--Author:      zhuguangyuan
--DateTime:    2017-09-25 18:59:12
--Description: 情缘系统 与服务器交互类
--

local NewLoveServer = class("NewLoveServer")

function NewLoveServer:init()

end

--------------------------------------------------------------------------
-------------------------- 服务器接口 ------------------------------------
--------------------------------------------------------------------------
-- 情缘阶升级 
function NewLoveServer:loveLevelUp(_loveId,callBack)
    echo("发送情缘升级请求——————————————————",_loveId)
	local params = {
		loveId = _loveId
	}
	Server:sendRequest(params, MethodCode.love_levelUp_5103, callBack )
end

-- 奇侠共鸣阶升级 
function NewLoveServer:loveResonanceUp(_partnerId,callBack)
    echo("发送共鸣升级请求——————————————————",_partnerId)

	local params = {
		partnerId = _partnerId
	}
	Server:sendRequest(params, MethodCode.love_resonanceUp_5105, callBack )
end

-- 进入剧情战斗
function NewLoveServer:enterPlotBattle(_plotId,callBack,_formation)
    echo("发送剧情战斗请求——————————————————",_plotId)
    self.currentRaidId = _plotId
	local params = {
		plotId = _plotId,
        formation = _formation
	}
	Server:sendRequest(params,MethodCode.love_enterPlotBattle_5107 , callBack )
end

-- 汇报战斗结果
-- battleParams 结构
--[[
	battleId
	frame
	fragment
	operation
	rt
	star
]]
function NewLoveServer:reportBattleResult(battleParams,callBack)
	local params = {
		battleResultClient = battleParams
	}

	Server:sendRequest(params,MethodCode.love_reportBattleResult_5109 , callBack)
end

-- 点亮全局属性 
function NewLoveServer:lightenOneCell(_searchId,_cellId,callBack)
    echo("发送点亮全局属性请求————— _searchId,_cellId —————————",_searchId,_cellId)
    local params = {
        puzzle = tostring(_searchId),
        atom = tonumber(_cellId),
    }
    Server:sendRequest(params, MethodCode.love_Lighten_One_Cell_5111, callBack )
end

NewLoveServer:init()
return NewLoveServer