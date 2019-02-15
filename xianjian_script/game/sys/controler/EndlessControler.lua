--
-- Author: Your Name
-- Date: 2018-01-24 15:53:45
--
local EndlessControler = EndlessControler or {}


function EndlessControler:enterEndlessMainView(_endlessId)
	echo("\n\n_endlessId===", _endlessId)
	EndlessModel:setCurEndlessId(_endlessId)
	EndlessServer:getFriendAndGuildData(function (event)
			if event.result then
				local data = event.result.data or {}
				EndlessModel:setFriendAndGuildData(data)
				WindowControler:showWindow("EndlessMainView", data)
			else
				echoError("无底深渊返回好友和盟友数据错误")
			end			
		end)
	-- if GuildModel:isInGuild() then
	-- 	GuildControler:getMemberList("", function ()
	-- 			WindowControler:showWindow("EndlessMainView")
	-- 		end) 
	-- else
	-- 	GuildControler:getMemberList("")
		
	-- end
	 
end

return EndlessControler