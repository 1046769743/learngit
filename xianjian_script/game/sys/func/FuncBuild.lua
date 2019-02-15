--[[
	guan
	2017.2.27
]]

FuncBuild = FuncBuild or {}

local build = nil

function FuncBuild.init()
	build = Tool:configRequire("home.Build");
end

function FuncBuild.getValue(id, key)
	local valueRow = build[tostring(id)];
	if valueRow == nil then 
		echo("error: FuncBuild.getValue id " .. 
			tostring(id) .. " is nil;");
		return nil;
	end 

	local value = valueRow[tostring(key)];
	if value == nil then 
		echo("error: FuncBuild.getValue key " .. 
			tostring(key) .. " is nil");
	end 
    return value;
end

function FuncBuild.getPos(id)
	return FuncBuild.getValue(id, "pos");
end
