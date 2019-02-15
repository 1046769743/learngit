--
-- Author: ZhangYanguang
-- Date: 2015-02-02
--
--抽卡系统，网络服务类

local LotteryServer = class("LotteryServer")

LotteryServer.tokenLotteryMaxTimes = 5

-- 令牌抽卡
-- times最大为5次

function LotteryServer:doTokenLottery(_times,callBack,_isFree)
	-- 不免费
	local isFree = 0

	-- 免费
	if _isFree == true then
		isFree = 1
	else

	end

	local times = _times
	if times == nil then
		times = 1
	elseif tonumber(times) > LotteryServer.tokenLotteryMaxTimes then
		times = LotteryServer.tokenLotteryMaxTimes
	end

	local params = {
		times = times,
		isFree = isFree
	}

	Server:sendRequest(params,MethodCode.lottery_token_2101, callBack )
end

-- 钻石单抽
function LotteryServer:doGoldOneLottery(callBack,_isFree)

	-- 不免费
	local isFree = 0

	-- 免费
	if _isFree == true then
		isFree = 1
	end
	local params = {
		isFree = isFree
	}

	Server:sendRequest(params,MethodCode.lottery_gold_one_2103, callBack )
end

-- 钻石十连抽
function LotteryServer:doGoldTenLottery(callBack)
    
	local params = {
	}

	Server:sendRequest(params,MethodCode.lottery_gold_ten_2105, callBack )
end




return LotteryServer

