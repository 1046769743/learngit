--
-- Author: guanfeng
-- Date: 2016-4-28
--

local TutorServer = class("TutorServer")

--message 是 unlockId + ";" + groupId + ; + stepId 
--eg 4;5
function TutorServer:beginTutorStep(message, callBack)
	echo("TutorServer " .. tostring(message));

	local params = {
		key = message
	}

	local function serverCallBack(...)
		-- 记录一下当前存的步骤
		local infoArray = string.split(message, ";")
		local step = infoArray[3] or 1

		-- wtf 写死，为了剧情内点击，严重！！！--
		if message ~= "2;2;4" and message ~= "3;32;4" and message ~= "7;10006;4" then
			-- 把步骤记一下
			TutorialManager.getInstance():setStepInServer(tonumber(step))
		end
		-- wtf 写死，为了剧情内点击，严重！！！--

		if callBack then
			callBack(...)
		end
	end

	Server:sendRequest(params, 
		MethodCode.tutor_finish_groupId_333, serverCallBack)
end

function TutorServer:unLockUpdate( unlockId, isOn, callBack )
	if isOn == false then
		isOn = "off"
	else 
		isOn = "on"
	end

	echo("---unLoclUpdate----", tostring(unlockId), isOn);
	local params = {
		guideId = unlockId,
		flag = isOn,
	}
	Server:sendRequest(params, 
		MethodCode.tutor_save_unlockId_335, callBack)	
end

return TutorServer
