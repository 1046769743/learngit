--
-- Author: ZhangYanguang
-- Date: 2016-02-03
-- 抽卡相关数据表功能类

FuncLottery = FuncLottery or {}

local lotteryFreeData = nil
local lotteryOneData = nil
local lotteryTenData = nil

function FuncLottery.init()
	-- lotteryFreeData = Tool:configRequire("lottery.LotteryFree")
	-- lotteryOneData = Tool:configRequire("lottery.LotteryOne")
	-- lotteryTenData = Tool:configRequire("lottery.LotteryTen")
end

-- 获取令牌抽数据
function FuncLottery.getLotteryFreeData()
	return lotteryFreeData
end

-- 获取单抽令牌抽数据
function FuncLottery.getLotteryOneData()
	return lotteryOneData
end

-- 获取十连抽令牌抽数据
function FuncLottery.getLotteryTenData()
	return lotteryTenData
end