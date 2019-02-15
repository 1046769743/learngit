--
-- Author: xd
-- Date: 2016-02-06 15:28:04
--
local HttpServer = class("HttpServer", ServerOther)

function HttpServer:ctor()
	self.connCache = {}
	self.missCache = {}
	self.curConn = nil
	self.hasDoCache = {}
	self._isConnect = true
	self._isHttpServer = true
	self.ignoreLogArr = {
		MethodCode.get_notice_3101,					--公告忽略
		MethodCode.user_serverList_211,				--服务器列表
	}
	self._initReConnectTimes = 1 		--自动重连1次 
	self._autoReconnectTime = self._initReConnectTimes
end


-- showLoading 这里 和server 参数的 outloading 参数含义刚好是相反的所以调用请注意. 空或者false 表示不显示loading
function HttpServer:sendHttpRequest(params, methodid, callBack, httpType, showLoading, needErrorCall)
	--需要延迟一帧发送请求 ,这里是为了 避免 在 一个请求回来的时候  立刻又发送一个请求 会导致冲突
	local tempFunc = function ()
		if not params.clientInfo then
			params.clientInfo = AppInformation:getClientInfo()
		end
		if showLoading == true then
			showLoading = false
		else
			showLoading = true
		end

		local connInfo =self:turnRequestSave(params, tonumber(methodid), callBack, nil, showLoading, needErrorCall)
		--默认是post
		connInfo.httpType = httpType or "POST"
		-- 缓存请求 
		table.insert(self.connCache, {connInfo} )

		-- 当前请求正在处理中
		if self.curConn and #self.curConn > 0 then
			echo(self.curConn[1].method .. " 请求正在处理中.....")
			return
		else
			self:doRequest()
		end	
	end
	--[[
		因为经常会出现 在回调里面 去继续发送请求 这个时候 会打乱数组顺序,
		所以在请求头部 处理  延迟请求,避免发生数组被打乱
	]]
	tempFunc()
	-- WindowControler:globalDelayCall(tempFunc)
end


function HttpServer:sureSend(info)

	local needLoading =false

	local postType = "POST"

	for i,v in ipairs(info) do
		if not v.oneway then
			needLoading = true
			break
		end
		if v.postType then
			postType = v.postType
		end
	end
	
	echo(needLoading,"___httpNeedloading")
	--需要显示loading
	if needLoading then
		WindowControler:showLoading()
	end

	-- 版本号
	local ver = AppInformation:getVersion()
	
	local url =  string.format(AppInformation:getGlobalServerURL() .. "&ver=%s",tostring(ver))
	if not string.find(url,"http") then
		url = "http://"..url
	end

	echo("\nHttpServer url=",url)

	local request= network.createHTTPRequest(c_func(self.onHttpCallBack,self),url,postType)

	local jsonStr = self:turnSendRequest( info )
	self:saveLogs(jsonStr, "httpPost" .. "_" .. tostring(TimeControler:getServerTime()))

	request:setPOSTData(jsonStr)
	request:start()

end


--http请求返回
function HttpServer:onHttpCallBack( message )
	local req = message.request
	
	-- echo("\nHttpServer response the info is :",message.name)

	--如果连接失败
	if message.name =="failed"  then
		echo("http请求失败,请检查网络---")
		self:checkErrorCode(message.name,message.name)
		self:onClose()
		return
	end

	if message.name ~="completed" then
		--self:onClose()
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()
	
	echo("statusCode="..statusCode)
	-- if(S.DEBUG_CHK_VER) then
	-- 	echo("[DOWNLOAD] id",id,"state(3-OK 5-timeout)",state,"statusCode",statusCode)
	-- end
	if state==5 then --超时
		self:checkErrorCode(state,statusCode)
		self:onClose()
		return
	end

	if statusCode~=200  then --非200，说明出错了
		self:checkErrorCode(state,statusCode)
		self:onClose()
		return
	end
	-- if true then
	-- 	self:onClose()
	-- 	return
	-- end
	self._autoReconnectTime = self._initReConnectTimes
	local str = req:getResponseData()
	if DEBUG_CONNLOGS ==2 then
		--echo("responceInfo:", str)
	end
	
	-- 返回的数据不要打印日志，如果数据量很大容易导致卡死 by ZhangYanguang
	-- echo("the response data=",str)
	--做父类的callBack
	self:onCallback(ServiceData.MESSAGE_RESPONSE,str)

end


function HttpServer:onClose()
	echo("__HttpServer_onClose")
	
	
	--如果当前是有连接的
	if self.curConn ~= nil then
		if self._autoReconnectTime > 0 then
			self._autoReconnectTime = self._autoReconnectTime -1
			echo(self.__cname.. "自动重连---",self._autoReconnectTime)
			WindowControler:globalDelayCall(c_func(self.reSendRequest,self), 2)
		else
			--关掉loanding
			WindowControler:hideLoading()
			--那么设置重连函数
			WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
		end
	else
		WindowControler:hideLoading()
	end
end


-- 重新发送当前请求
function HttpServer:reSendRequest()
	echo("___-重发请求")
	if self.curConn ~= nil then
		self:sureSend(self.curConn)  
	end
end


function HttpServer:checkErrorCode( code,statusCode )
	local errorMsg = "HttpServer请求错误,statusCode:"..tostring(statusCode)  ..",code:"..code
	if self.curConn then
		errorMsg = errorMsg.."\n"..self:toConnString(self.curConn)
	end
	echoWarn(errorMsg)
	local key = ClientTagData.httpRequestError..code
	--一次登入只发送一次
	if Tool:getCacheKeyNums( key ) < 3 then
		ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.httpRequestError,errorMsg)
		Tool:addCacheKeyNums( key )
	end
	

end

--直接返回new的httpServer
return HttpServer.new()
