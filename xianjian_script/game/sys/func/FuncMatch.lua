--
-- Author: xd
-- Date: 2016-03-21 20:26:06
--
FuncMatch = {}
local matchData 
local matchSystem 

FuncMatch.SYSTEM_TYPE = {
	worldGve1 = "1",   --主线副本
	worldGve2 =  "2", --主线精英
	kindGve = "0",		--行侠仗义
	trailGve1 = "301",	--山神试炼
	trailGve2 = "302",	--火神试炼
	trailGve3 = "303",	--雷神试炼
}



function FuncMatch.init(  )
	-- matchData = Tool:configRequire("world.Match")
	-- matchSystem = Tool:configRequire("world.MatchSystem")
end

--获取匹配数据
function FuncMatch.getMatchData( poolType )
	if true then
		echoError("不应该走到这里来",poolType)
		return {}
	end
	local data = matchData[poolType]
	if not data then
		echoError("没有找到 "..tostring(poolType).." 对应的匹配信息")
		return {}
	end
	return data
end


--获取poolSystem
function FuncMatch.getPoolSystem( poolType )
	if true then
		echoError("不应该走到这里来",poolType)
		return 1
	end
	local data = FuncMatch.getMatchData( poolType )
	return data.poolSystem
end


function FuncMatch.getBattleLabelByPoolSystem( poolSystem )
	poolSystem = tostring(poolSystem)
	echoError("不应该走到这里来",poolType)
	
	for k,v in pairs(FuncMatch.SYSTEM_TYPE ) do
		if v == poolSystem then
			return GameVars.battleLabels[k]
		end
	end
	echoError("错误的poolSystem:",poolSystem)

end

