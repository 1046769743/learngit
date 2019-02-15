--[[
	Author: lichaoye
	Date: 2017-05-10
	签到-Func
]]
FuncNewSign = FuncNewSign or {}

local totalSignConfig = nil
local totalSignTable = nil
local signDescrip = nil

FuncNewSign.LABEL = {
	BEST = 1, -- 上上签
	UP = 2, -- 上签
	MID = 3, -- 中签
	NORMAL = 4, -- 平签
}



function FuncNewSign.init()
	totalSignConfig = Tool:configRequire("sign.TotalSign")
	signDescrip = Tool:configRequire("sign.SignDescrip")
	signConfig = Tool:configRequire("sign.Sign")

	-- 转换一下
	totalSignTable = {}
	for k,v in pairs(totalSignConfig) do
		local tmp = table.copy(v)
		tmp.day = tonumber(v.day)
		tmp.vip = tonumber(v.vip)
		tmp.index = tonumber(v.index)
		tmp.reward = v.reward[1] -- string.split(v.reward[1], ",")
		table.insert(totalSignTable, tmp)
	end

	table.sort(totalSignTable, function( a, b )
		return a.index < b.index
	end)
end

function FuncNewSign.test()
	dump(totalSignTable, "totalSignTable")
end

-- 获取累计奖励day
function FuncNewSign.getTotalByDay( day )
	local maxDay = tonumber(FuncDataSetting.getDataByConstantName("TotalSignMaxNum"))
	local maxVip = tonumber(FuncDataSetting.getDataByConstantName("TotalSignMaxVipLimite"))
	if tonumber(day) <= maxDay then
		local data = totalSignConfig[tostring(day)]
		if data then
			return table.copy(data)
		end
		return nil
	else
		-- 超过【TotalSignMaxNum】天后，就每增加10天按照+1,~TotalSignMaxVipLimite的顺序进行循环
		local dif = day - maxDay
		if dif % 10 == 0 then
			local baseData = table.copy(totalSignConfig[tostring(maxDay)])
			baseData.day = day
			baseData.vip = (baseData.vip + dif / 10 - 1) % maxVip + 1
			baseData.index = day

			return baseData
		else
			return nil
		end
	end
end

-- 获取累计奖励idx
function FuncNewSign.getTotalByIdx( idx )
	-- todo 大于maxnum
	return totalSignTable[tonumber(idx)]
end

-- 获取整月奖励表
function FuncNewSign.getMonthTable( year, month )
	-- local year, month, day = NewSignModel:getYearMonthDay()

	-- local s = string.format("%d%02d", tonumber(year), tonumber(month))

	-- return Tool:configRequire("sign.Sign" .. s)
	return signConfig
end

function FuncNewSign.getMonthValue(year, month, day, key)
	local monthTable = FuncNewSign.getMonthTable(year, month)
	if not monthTable then return nil end

	return monthTable[tostring(day)][tostring(key)]
end

-- 获取签的描述
--[[
	sType 1-4 上上签 上签 中签 平签
]]
function FuncNewSign.getSignDes( sType )
	local data = signDescrip[tostring(sType)]
	
	if not data then return end

	local text = GameConfig.getLanguage(data.txt)
	local content1 = GameConfig.getLanguage(data.content)
	local content2 = GameConfig.getLanguage(data.content1)
	dump(data,"data = = = = = =")

	return text, content1, content2
end

-- 获取中奖文本 1普通抽 2摇一摇
function FuncNewSign.getBroadCast( tType, name, reward )
	local tid = tonumber(tType) == 1 and "tid_sign_1101" or "tid_sign_1102"
	if name == "" then
		name = GameConfig.getLanguage("tid_common_2001")
	end
	
	local text = GameConfig.getLanguageWithSwap(tid, name, FuncCommon.getNameByReward( reward ))
	return text
end

-- 获取中签背景
--[[
	sType 1-4 上上签 上签 中签 平签
]]
function FuncNewSign.getGetQianBg( sType )
	local data = signDescrip[tostring(sType)]
		
	if not data then return end

	return FuncRes.bgNewSign( data.bg )
end