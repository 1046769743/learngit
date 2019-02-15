
local LoveServer = class("LoveServer")

--情缘激活 
function LoveServer:LoveActivate(_Id,callBack)
	Server:sendRequest({ loveId = _Id }, MethodCode.love_activite_5101, callBack );
end


return LoveServer