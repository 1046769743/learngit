--
-- Author: xd
-- Date: 2017-12-12 16:53:12
--
local CommonServer = class("CommonServer")

--同步用户信息
function CommonServer:updateUserState( callBack )
	if not callBack then
		callBack = false
	end
	if Server:checkHasMethod(MethodCode.sys_updateUserState) then
		return
	end
	Server:sendRequest({},MethodCode.sys_updateUserState, c_func(self.onUpdateStateBack,self,callBack ))
end


--同步状态回来
function CommonServer:onUpdateStateBack(callBack, backData )
	if not backData.result then
		return
	end

	LoginInfoControler:onBattleStatus( backData.result.data,true )
	if callBack then
		callBack(backData)
	end
end

return CommonServer