-- FuncBarrage
-- 弹幕
-- Author = wk
-- time = 2018/01/30 



FuncBarrage = {}

local barrage = nil
local danmuSystem = nil


FuncBarrage.SystemType = {
	plot = 1,--剧情
	crosspeak = 2,--巅峰竞技场
	tower = 3,--锁妖塔
	world = 4, --六界
	guild = 5, --仙盟
}


--弹幕类型
FuncBarrage.BarrageType = {
	plot = 0,--剧情
	chat = 1,--聊天  --巅峰竞技场
	comments = 2,--排行评论弹幕
	PVE = 3,--六界弹幕
	
}

FuncBarrage.BarrageSystemName = {
	plot = "plot",--剧情
	crossPeak = "crossPeak",--聊天  --巅峰竞技场
	comments = "comments",--排行评论弹幕
	world = "world",--六界弹幕
}


FuncBarrage.Maxlength = 30 --最大字符30个字节

FuncBarrage.MaxShowUINum = 30  --最大显示15个控件

FuncBarrage.SendItems = 5  --没10秒发送一次

FuncBarrage.TextString   = "请输入30个字符以内的内容"

function FuncBarrage.init()
   barrage = Tool:configRequire("danmu.Danmu")
   danmuSystem= Tool:configRequire("danmu.DanmuSystem")
end

--根据系统ID获取 弹幕弹出间隔
function FuncBarrage.getBarrageTimeInterval(systemID)
	local time = 1
	if barrage[tostring(systemID)] ~= nil then
		time = barrage[tostring(systemID)].time
	end
	return time
end



--根据系统ID获取 弹幕栏位数量
function FuncBarrage.getBarrageRowsNum(systemID)
	local num = 1
	if barrage[tostring(systemID)] ~= nil then
		num = barrage[tostring(systemID)].num
	end
	return num
end

function FuncBarrage.getBarrageSpecial(systemID)
	local special = nil
	local newspecial = {}
	if barrage[tostring(systemID)] ~= nil then
		special = barrage[tostring(systemID)].special
		if special ~= nil then
			for k,v in pairs(special) do
				local res = string.split(v, ",")
				newspecial[tonumber(res[1])] = {
					[1] = res[2],
					[2] = res[3],
				}
			end
		end
	end
	return newspecial
end

--根据系统ID获取 弹幕的基础速度
function FuncBarrage.getBarrageSpeed(systemID)
	local speed = 1
	local speedArr = {}
	if barrage[tostring(systemID)] ~= nil then
		speed = barrage[tostring(systemID)].speed
		if speed ~= nil then
			local res = string.split(speed[1], ",")
			speedArr = {[1] = res[1],[2] = res[2]}
		end
	end
	return speedArr
end

--根据系统ID获取 弹幕的类型
function FuncBarrage.getBarrageType(systemID)
	local _type = 0
	if barrage[tostring(systemID)] ~= nil then
		_type = barrage[tostring(systemID)].type
	end
	return _type
end

--根据剧情ID获得本地剧情多文本
function FuncBarrage.getBarrageSystemDataByPlotID(plotId)
	if plotId == nil then
		echo("=========剧情ID 是=========",plotId)
		return nil 
	end
	local data = danmuSystem[tostring(plotId)]
	if data ~= nil then
		return data
	end
	return nil
end



 

return FuncBarrage  
