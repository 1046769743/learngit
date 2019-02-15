--
-- Author: zq
-- Date: 2016-08-15 20:02:07
--

FuncHappySign = FuncHappySign or {}
local happySignData = nil

FuncHappySign.periodId = {
	FIRST = 1,
	SECOND = 2,
}

function FuncHappySign.init(  )
	happySignData = Tool:configRequire("happySign.HappySign")
end

function FuncHappySign.getItemDataById(_id)
    local itemData = happySignData[tostring(_id)];
    if itemData then
       return itemData
    end

    echoWarn("happySign.happySign cannot find id = ".._id)
    return nil;
end

function FuncHappySign.getHappySignData()
    return happySignData;
end

function FuncHappySign.getHappySignDays()
	return table.length(happySignData)
end

function FuncHappySign.getPeriodData(_period)
	local periodData = {}

	for k,v in pairs(happySignData) do
		if v.periods == tonumber(_period) then
			periodData[tostring(k)] = v
		end
	end
	return periodData
end

function FuncHappySign.getPeriodDays(_period)
	local periodData = FuncHappySign.getPeriodData(_period)
	return table.length(periodData)
end





