--[[
	guan
	2016.5.17
	非强制引导配表

	--废弃
]]

FuncTriggerGuide = FuncTriggerGuide or {}

local triggerGuideData = nil

function FuncTriggerGuide.init()
	triggerGuideData = Tool:configRequire("guide.TriggerGuide");
end

function FuncTriggerGuide.getValueByKey(id1, id2, key)
	local t1 = triggerGuideData[tostring(id1)];
	if t1 == nil then 
		echo("FuncTriggerGuide.getValueByKey id1 not found " .. id1);
		return nil;
	end 

	local t2 = t1[tostring(id2)];
	if t2 == nil then 
		echo("FuncTriggerGuide.getValueByKey id2 not found " .. id2);
		return nil;
	end 

	local value = t2[tostring(key)]

	if value == nil then 
		echo("FuncTriggerGuide.getValueByKey key not found " .. key);
		return nil;
	end 

	return value;
end

function FuncTriggerGuide.getWinName(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "Currentinterface");
end

function FuncTriggerGuide.getToCenterId(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "toCenterId");
end

function FuncTriggerGuide.getLast(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "last");
end

function FuncTriggerGuide.getKeypoint(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "keypoint");
end


function FuncTriggerGuide.isGroundExist(groundId)
	local t1 = FuncTriggerGuide[tostring(groundId)];

	if t1 == nil then 
		return false;
	end 
	return true;
end

function FuncTriggerGuide.getPlotId(groundId, step)
	local plotId = FuncTriggerGuide.getValueByKey(groundId, step, "plotid");
	return plotId;
end

function FuncTriggerGuide.getRect(groundId, step)
	local t = FuncTriggerGuide.getValueByKey(groundId, step, "Rect");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncTriggerGuide.getClickPos(groundId, step)
	local t = FuncTriggerGuide.getValueByKey(groundId, step, "origin");
	return {tonumber(t[1]), tonumber(t[2])};
end

function FuncTriggerGuide.getAdaptation(groundId, step)
	local adaptation = FuncTriggerGuide.getValueByKey(groundId, step, "Adaptation");

	if adaptation == nil then 
		return 0, 0;
	else 
		return adaptation[1], adaptation[2];
	end 
end

function FuncTriggerGuide.getNpcskin(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "npcskin");
end

function FuncTriggerGuide.getTextcontentIndex(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "TextcontentIndex");
end

function FuncTriggerGuide.getNpcPos(groundId, step)
	local t = FuncTriggerGuide.getValueByKey(groundId, step, "npcorigin");
	if t ~= nil then  
		return {tonumber(t[1]), tonumber(t[2])};
	else 
		return {150, 540};
	end 
end

function FuncTriggerGuide.getJump(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "Jump");
end

function FuncTriggerGuide.getArrowPicName(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "arrow");
end

function FuncTriggerGuide.getArrowDirection(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "directiondirection") or 0;
end

function FuncTriggerGuide.getMaskskin(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "Maskskin") or "0";
end

function FuncTriggerGuide.getTime(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, step, "time");
end

function FuncTriggerGuide.getBubblePosition(groundId, step)
	return FuncTriggerGuide.getValueByKey(groundId, 
		step, "BubblePosition");
end














