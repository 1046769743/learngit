local CdServer = class("CdServer")

-- 清除cd
function CdServer:clearCD(cdID,callBack,p1,p2,errorCall)
	local params = {
		id = cdID
	}
	Server:sendRequest(params, MethodCode.user_clearCD_313, callBack,p1,p2,errorCall)
end

return CdServer
