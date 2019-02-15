-- 战斗服realTimeServer
local ServerRealTime=class("ServerRealTime",ServerBasic).new()

ServerRealTime._serverType = ServiceData.serverTypeMap.realTimeServer
--自动重连次数变为3
ServerRealTime._initReConnectTimes = 3



function ServerRealTime:init( ... )
	ServerRealTime.super.init(self,...)
	EventControler:addEventListener(LoginEvent.SERVEREVENT_INIT_SUCCESS, self.onGameServerConnect, self)
end


--当游戏服连上的时候 我这边需要做重连
function ServerRealTime:onGameServerConnect(  )
	--如果不是在战斗状态中
	if not self:isInBattleState() then
		return
	end
	--必须是掉线才去处理
	if not self._isClose then
		return
	end
	--那么这里需要重新初始化
	self:init(self.serverParams)


end




function ServerRealTime:doInitRequest( )
	local clientInfo = AppInformation:getClientInfo()

	--移除所有的初始化 和reauth请求	
	self:clearByMethodId(self:getInitReqeustId())
	if not self:checkHasMethod(self:getInitReqeustId()) then
		local initRequestId = self:getInitReqeustId()
		local   _init_param={
		     rid = UserModel:rid(),
		     battleId = self.serverParams.battleId or 1001 ,
		     token = self.serverParams.token,
		};
	
		connInfo = self:turnRequestSave( _init_param, self:getInitReqeustId(),c_func(self.onConnectBack, self ),false,false,false)

		table.insert(self.connCache, 1,{connInfo} )
	end
	-- self._isClose = false
	
	if self.curConn then
		if not table.indexof(self.connCache, self.curConn) then
			table.insert(self.connCache, self.curConn)
		end
		self.curConn = nil
	end
	self:doRequest()
end

function ServerRealTime:onReconnectFail( ... )
	--如果server 不是连接状态 那么肯定是走GameServer断线重连 重连之后  会通知其他server重连
	--做所有请求的错误回调
	
	if not Server._isConnect then
		return
	end
	echo("战斗服连接失败-----做异常回调")
	local errorInfo = {error ={code = ErrorCode.sys_error,message = "system error" } }
	-- self:checkError(errorInfo)
	WindowControler:showTips(GameConfig.getLanguage("#tid_battle_serverError"))
	self:doAllRequestErrorCall( errorInfo )
	--重置用户状态试下 
	Server:sendRequest({},MethodCode.user_resetUserStatus,nil,true,true,false )
	--如果不是在战斗中
	if not self:isInBattleState() then
		return
	end


	--那么直接重连
	WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
end


function ServerRealTime:isInBattleState(  )
	if not BattleControler:isInBattle() then
		return false
	end
	--如果已经出结果了 那么不处理
	local controler = BattleControler.gameControler
	if controler._gameResult ~= 0 then
		return  false
	end
	return true

end


function ServerRealTime:getInitReqeustId(  )
	return "connector.init"
end


function ServerRealTime:startConnect( serverBackParams,callBack )
	self._battleParams = serverBackParams
	local ip = serverBackParams.realTimeServerUrl
	local ipArr = string.split(ip, ":")
	local battleServerParams = {
		ip = ipArr[1],
		port = ipArr[2],
		battleId = serverBackParams.battleId,
		token = serverBackParams.realTimeServerToken
	}
	
	-- echo(ip,"___ip")
	--初始化战斗连接服
	self:init(battleServerParams)

	local enterParams = {
		battleId = serverBackParams.battleId,
	}
	self:sendRequest(enterParams, MethodCode.battle_battleEnter, callBack )
end


ServerRealTime:__init()
return ServerRealTime;
