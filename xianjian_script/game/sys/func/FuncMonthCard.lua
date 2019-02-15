-- 月卡功能
FuncMonthCard = FuncMonthCard or {}

local config_MonthCard = nil
local config_MonthCardShop = nil
local config_Mall = nil

local config_recharge = nil


FuncMonthCard.CARDTYPE = {
    [1] = "1",
    [2] = "2",
    [3] = "3",
}
FuncMonthCard.CARDYEQIAN = {
	["1"] = 1,
    ["2"] = 2,
    ["3"] = 3,
}

--充值类型
FuncMonthCard.RECHARGE_TYPE = {
	GOLD = 1,			--仙玉
	CARD = 2,			--月卡，周卡
	FUND = 3,			--基金
	PURCHASE = 4,		--直购
	DISCOUNT = 5,		--折扣
}

FuncMonthCard.RECHARGE_DATA_TYPE = {
	RECHARGE = "recharge",
	MONTHCARD = "monthCard",
	PURCHASE = "purchase",
}

----用下面的这个  不要用数字
FuncMonthCard.card_lingshi = "4"  --灵石特权id   已废弃
FuncMonthCard.card_xiyao = "1"   --夕瑶神灯  6元
FuncMonthCard.card_caiyi = "2"   -- 彩依送玉id  30元
FuncMonthCard.card_caishen = "3"   -- 财神送宝id  68元


function FuncMonthCard.init()
	config_MonthCard = Tool:configRequire("monthCard.MonthCard")
	config_MonthCardShop = Tool:configRequire("monthCard.MonthCardShop")
	config_Mall = Tool:configRequire("monthCard.Mall")

	config_recharge = Tool:configRequire("recharge.Recharge")
end

function FuncMonthCard.getRechargeConfig()
	return config_recharge
end

function FuncMonthCard.getRechargeConfigByType(_type)
	local data = {}
	for i,v in pairs(config_recharge) do
		if v.type == _type then
			table.insert(data, v)
		end
	end
	return data
end

function FuncMonthCard.getMonthCardById( id )
	id = tostring(id)
	local data = config_MonthCard[id]
	if data then
		return data
	end
	echoError("monthcard 表里未找到id== ",id,"  暂时用id=1 代替")

	return config_MonthCard["1"]
end

function FuncMonthCard.getXinAnDangData(  )
	return config_MonthCardShop
end

function FuncMonthCard.getMallGoods()
	local data = {}
	for i,v in pairs(config_Mall) do
		data[tonumber(v.position)] = v
		v.id = v.position
	end

	return data
end 	

--根据类型获取对应的充值数据
function FuncMonthCard.getRechargeDataByType(_type)
	local rechargeData = {}
	for i,v in pairs(config_recharge) do
		if v.type == _type then
			table.insert(rechargeData, v)
		end
	end

	local sortFunc = function ( a,b )
		if a.locate < b.locate then
			return true
		end
		
		return false
	end

	table.sort(rechargeData, sortFunc)

	return rechargeData
end

function FuncMonthCard.getRechargeData( )
	local allData = {}
	for i,v in pairs(config_recharge) do
		if v.type == 1 then
			local data = {}
			data._type = FuncMonthCard.RECHARGE_DATA_TYPE.RECHARGE
			data._data = v
			if v.isShown then
				table.insert(allData,data)
			end
			
		end
		if v.type == 2 then
			local data = {}
			data._type = FuncMonthCard.RECHARGE_DATA_TYPE.MONTHCARD
			data._data = v
			table.insert(allData,data)
		end
		if v.type == 4 then
			local data = {}
			data._type = FuncMonthCard.RECHARGE_DATA_TYPE.PURCHASE
			data._data = v
			table.insert(allData,data)
		end
	end
	-- for i,v in pairs(config_MonthCard) do
		
	-- end


	-- local sortFunc = function ( a,b )
	-- 	if a._data.locate < b._data.locate then
	-- 		return true
	-- 	end
		
	-- 	return false
	-- end

	-- table.sort(allData,sortFunc)

	return allData
end

function FuncMonthCard.checkHasNewShop( id )
	local data = FuncMonthCard.getMonthCardById( id )
	if data.additionId then
		for i,v in pairs(data.additionId) do
			if v == "2005" then
				return true
			end
		end
	end
	return false
end

function FuncMonthCard.getconfig_MonthCard()
	return config_MonthCard
end

--获取提前购买时间
function FuncMonthCard.getRenewalTime(monthId )
	local data =  FuncMonthCard.getMonthCardById( monthId )
	return data.renewalTime
end


function FuncMonthCard.getMonthCardName( monthId )
	local data =  FuncMonthCard.getMonthCardById( monthId )
	return GameConfig.getLanguage(data.monthCardName)
end

