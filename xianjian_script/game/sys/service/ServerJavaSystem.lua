-- 多人玩法连接java 服的入口
--[[
	
	把他和 ServerRealTime区别开来
]]
local ServerJavaSystem=class("ServerJavaSystem",ServerBasic).new()

ServerJavaSystem._serverType = ServiceData.serverTypeMap.javaSystem
--自动重连次数变为3
ServerJavaSystem._initReConnectTimes = 3


--每个系统退出这个玩法的时候一定要记得手动调用ServerRealTimeSystem:handleClose()

function ServerJavaSystem:init( ... )
	ServerJavaSystem.super.init(self,...)
	EventControler:addEventListener(LoginEvent.SERVEREVENT_INIT_SUCCESS, self.onGameServerConnect, self)
end


--当游戏服连上的时候 我这边需要做重连
function ServerJavaSystem:onGameServerConnect(  )
	--必须是掉线才去处理
	if not self._isClose then
		return
	end
	if self._state == 0 then
		return
	end
	--那么这里需要重新初始化
	self:init(self.serverParams)

end




function ServerJavaSystem:doInitRequest( )
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

function ServerJavaSystem:onReconnectFail( ... )
	--如果server 不是连接状态 那么肯定是走GameServer断线重连 重连之后  会通知其他server重连
	--做所有请求的错误回调
	--如果server没有连上 那么其他服也不需要连
	if not Server._isConnect then
		return
	end

	if self._state == 0 then
		return
	end

	echo("java服连接失败-----做异常回调")
	local errorInfo = {error ={code = ErrorCode.sys_error,message = "system error" } }
	-- self:checkError(errorInfo)
	WindowControler:showTips(GameConfig.getLanguage("#tid_battle_serverError"))
	self:doAllRequestErrorCall( errorInfo )
	self:doConnectCallBackError()
	--获取最近的100行数据
	local errorStr =LogsControler:getNearestLogs(100) .."\n ServerJavaSystem connectFail".. (json.encode(self._battleParams))

	ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.socketServerError,errorStr)
	--那么直接重连
	-- WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
end

function ServerJavaSystem:doConnectCallBackError( ... )
	if self._onConnectCallBack then
		local callFunc = self._onConnectCallBack
		self._onConnectCallBack =nil
		callFunc(errorInfo)
	end
end



function ServerJavaSystem:afterServerOnConnect(  )
	--连接成功后 通知分系统重新登入
	if self._onConnectCallBack then
		self._onConnectCallBack()
	end

end

function ServerJavaSystem:isInBattleState(  )
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


function ServerJavaSystem:getInitReqeustId(  )
	return "connector.init"
end


function ServerJavaSystem:startConnect( serverBackParams,callBack )
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
	self._onConnectCallBack = callBack
end


--手动关闭
function ServerJavaSystem:handleClose()
	ServerJavaSystem.super.handleClose(self)
	self._onConnectCallBack = nil
end


ServerJavaSystem:__init()
return ServerJavaSystem;
