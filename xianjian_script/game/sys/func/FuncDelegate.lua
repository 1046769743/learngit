--[[
	Author: lichaoye
	Date: 2017-05-26
	挂机-Func
]]
FuncDelegate = FuncDelegate or {}

FuncDelegate.Type_Normal = 1 --普通任务
FuncDelegate.Type_Special = 2 --特殊


local DelegateTask = nil -- 任务表
local DelegateOpen = nil

function FuncDelegate.init()
	DelegateTask = Tool:configRequire("delegate.DelegateTask")
	DelegateOpen = Tool:configRequire("delegate.DelegateOpen")
end

function FuncDelegate.readTask(id, key)
	local data = DelegateTask[tostring(id)]
	if data == nil then
		echo("FuncDelegate.readTask id " .. tostring(id) .. " is nil.")
		return
	else
		local result = data[key]
		if result == nil then
			echo("FuncDelegate.readTask id " 
				.. tostring(id) .. " key " .. tostring(key) .. " is nil.")
			return
		else
			return table.copy(result)
		end
	end
end
-- 获取任务数据
function FuncDelegate.getTask(id)
	local data = DelegateTask[tostring(id)]
	if data == nil then
		echoError ("FuncDelegate.readTask id " .. tostring(id) .. " is nil.使用1任务代替")
		return DelegateTask["1"]
	else
		return table.copy(data)
	end
end

-- 获取vip加速基础
function FuncDelegate.getSpeedUpVip()
	return tonumber(FuncDataSetting.getDataByConstantName("DelegateVipFreeSpeedLevel"))
end

-- 获取加速次数
function FuncDelegate.getSpeedUpNum()
	return tonumber(FuncDataSetting.getDataByConstantName("DelegateVipFreeSpeedNum"))
end

-- 获取加速时间
function FuncDelegate.getSpeedUpTime()
	return tonumber(FuncDataSetting.getDataByConstantName("DelegateSpeedTime")) / 60
end
-- 获取加速花费的消耗(传入的是秒)
function FuncDelegate.getSpeedUpCast(time)
	local cTime = tonumber(FuncDataSetting.getDataByConstantName("DelegateTimeExchangePrice"))*60
	return math.ceil(time/cTime)
end

-- 获取开启条件
function FuncDelegate.getDelegateOpenById(id )
	local data = DelegateOpen[tostring(id)]
	if data == nil then
		echo("FuncDelegate.getDelegateOpenById id " .. tostring(id) .. " is nil.")
		return
	else
		return table.copy(data)
	end
end