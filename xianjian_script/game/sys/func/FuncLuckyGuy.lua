-- 幸运转盘功能
FuncLuckyGuy = FuncLuckyGuy or {}

FuncLuckyGuy.PLAYTYPE = {
	PLAY_FREE = 0,     ---免费
	PLAY_ONE = 1,	---一次
	PLAY_FIVE = 5,		--五次
}

local systemHide = nil
local roulette = nil
local rouletteReward = nil


function FuncLuckyGuy.init()
	systemHide = Tool:configRequire("common.SystemHide")
	roulette = Tool:configRequire("roulette.Roulette");
	rouletteReward = Tool:configRequire("roulette.RouletteReward");
end

function FuncLuckyGuy.getSystemHide()
	local luckyActArr = {}
	for k,v in pairs(systemHide) do
		if tonumber(v.type) == 2 then
			table.insert(luckyActArr,systemHide[k])
		end
	end
	local subId
	local id
	-- dump(luckyActArr,"luckyActArr ================ \n\n\n")
	for k,v in pairs(luckyActArr) do
		local startTime,endTime = FuncCommon.getOpenTimeAndExpireTimeById(v.id,FuncCount.COUNT_TYPE.COUNT_TYPE_LUCKYGUY_FREETIMES)
		local now = TimeControler:getServerTime()
		subId = v.subId
		id = v.id
		if now >= startTime and now <= endTime then
		-- echo("111111111111=========  ========== ",v.subId,now,startTime,endTime,v.id)
			return v.subId,endTime,startTime,v.id
		end
	end
	return subId,0,0,id
end

function FuncLuckyGuy.getRoulette()
	local reward = roulette[tostring(FuncLuckyGuy.getSystemHide())].rewardArray
	return reward
end

function FuncLuckyGuy.getRouletteBestReward()
	local bestReware = roulette[tostring(FuncLuckyGuy.getSystemHide())].bestReward
	return bestReware
end

function FuncLuckyGuy.getPartnerId()
	local partnerId = roulette[tostring(FuncLuckyGuy.getSystemHide())].partnerId
	return partnerId
end

function FuncLuckyGuy.getPartnerPos()
	local pos = roulette[tostring(FuncLuckyGuy.getSystemHide())].spineControl
	return pos
end

function FuncLuckyGuy.getEffectRewards()
	
end

function FuncLuckyGuy.getRouletteReward()
	local data = FuncLuckyGuy.getRoulette()
	local arr = {}
	for k,v in pairs(data) do
		table.insert(arr,tostring(v.k))
	end

	local best = FuncLuckyGuy.getRouletteBestReward()
	table.insert(arr,1,best)
	return arr
end

function FuncLuckyGuy.getRewardList()
	local data = FuncLuckyGuy.getRouletteReward()
	local tmp = nil
	local listArr = {}
	for k,v in pairs(data) do
		table.insert(listArr,rouletteReward[tostring(v)].reward)
		-- table.insert(listArr,rouletteReward[tostring(v)].isDisposable)
		if rouletteReward[tostring(v)].isDisposable ~= nil then  -- 一次性奖励标识
			listArr[k][2] = rouletteReward[tostring(v)].isDisposable
		end
		if rouletteReward[tostring(v)].isTreasure ~= nil then  -- 稀有标识
			listArr[k][3] = rouletteReward[tostring(v)].isTreasure
		end
		if rouletteReward[tostring(v)].isEffect ~= nil then  -- 奖励特效标识
			listArr[k][4] = rouletteReward[tostring(v)].isEffect
		end
	end

	return listArr
end

function FuncLuckyGuy.getRouletteRewardById( id )
	id = tostring(id)
	local reward = string.split(rouletteReward[id].reward[1],",")
	local rewardId = reward[2]
	return rewardId
end

function FuncLuckyGuy.getMaxLuck()
	local maxLucky = roulette[tostring(FuncLuckyGuy.getSystemHide())].maxLuck
	return maxLucky
end


function FuncLuckyGuy.getIsEnough( type )
    if type == FuncLuckyGuy.PLAYTYPE.PLAY_ONE then
        if UserModel:getRouletteCoin() >= FuncDataSetting.getDataByConstantName("RouletteOnceCost") then
        	return true
        else
        	return false
        end
    elseif type == FuncLuckyGuy.PLAYTYPE.PLAY_FIVE then
    	if UserModel:getRouletteCoin() >= FuncDataSetting.getDataByConstantName("RouletteFiveCost") then
    		return true
    	else
    		return false
    	end
    end
end

