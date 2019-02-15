--guan
--2016.5.3

FuncWorshipevent = FuncWorshipevent or {}

local worshipEvent = nil

function FuncWorshipevent.init()
	worshipEvent = Tool:configRequire("home.Worshipevent");
end

function FuncWorshipevent.getValue(id, key)
	local valueRow = worshipEvent[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncWorshipevent.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncWorshipevent.getValue key " .. 
			tostring(key) .. " is nil");
	end 

    return value;
end

function FuncWorshipevent.getCost(id)
	local cost = FuncWorshipevent.getValue(id, "cost");
	return cost or {};
end

function FuncWorshipevent.getGainSp(id)
	local sp = FuncWorshipevent.getValue(id, "sp");
	return sp;	
end






