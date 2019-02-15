--
-- Author: xd
-- Date: 2018-03-28 18:45:52
--
local OptionsServer = class("OptionsServer")

--设置某个开关
--[[
	params = {
		key = 100
		value = 1
	}
]]
function OptionsServer:setOptions( params,callback )
	Server:sendRequest(params,MethodCode.chat_Set_inf_2803,callback,nil,nil,true);
end

return OptionsServer