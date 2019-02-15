local WebHttpServer = class("WebHttpServer")

WebHttpServer.POST_TYPE = {
	POST = "POST",
	GET = "GET"
}

function WebHttpServer:ctor()
	self.curConn = nil
	self.connCache = {}
	self._initReConnectTimes = 1 		--自动重连1次 
	self._autoReconnectTime = self._initReConnectTimes
end



function WebHttpServer:sendRequest(params, url, postType, headers, callBack,encryptMode)
	-- echo("WebHttpServer发送请求 WebHttpServer:sendRequest url=",url)
	local connInfo = {params = params,url = url,postType = postType,headers = headers ,callBack = callBack }
	if self.curConn then
		echo("__当前请求正在发送中 url=",self.curConn.url)
		table.insert(self.connCache, connInfo )
		return
	end

	self.curConn = connInfo

	local url = url
	--get:拼接url
	if postType == WebHttpServer.POST_TYPE.GET then
		url = self:turnGetUrl(url, params)
	end
	if DEBUG_CONNLOGS >0 then
		echo("WebHttpServer_requestUrl:", url)
	end
	local request= network.createHTTPRequest(c_func(self.onHttpCallBack,self, callBack), url, postType,encryptMode)
	
	--post
	if postType == WebHttpServer.POST_TYPE.POST then
		for k,v in pairs(params) do
			request:addPOSTValue(k,v)
		end
	end

	headers = headers or {}
	for _, header in pairs(headers) do
		request:addRequestHeader(header)
	end

	request:start()
end

function WebHttpServer:reSendRequest()
	if self.curConn then
		local connInfo = self.curConn
		self.curConn = nil
		self:sendRequest(connInfo.params, connInfo.url, connInfo.postType, connInfo.headers, connInfo.callBack)
	end
end

function WebHttpServer:onHttpCallBack(callBack, message)
	local req = message.request
	
	-- echo("WebHttpServer:onHttpCallBack message.name-------",message.name)
	--如果连接失败
	if message.name =="failed" then
		self:checkErrorCode(message.name,message.name)
		self:onClose()

		echo("WebHttpServer http请求失败,请检查网络---")
		return
	end

	if message.name ~="completed" then
		-- message 有可能是progress 这个时候 不需要判断序章
		-- if self:checkPrologue() then
		-- 	return
		-- end
		--说明请求失败--
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()
	if state==5 then --超时
		echo("WebHttpServer:http请求超时---")
		self:checkErrorCode(state,statusCode)
		-- 如果序章中的WebHttpServer请求失败，发送进入序章消息
		if self:checkPrologue() then
			return
		end
		self:onClose()
		return
	end
	self._autoReconnectTime = self._initReConnectTimes
	local responseData = req:getResponseData()
	
	if statusCode~=200  then --非200，说明出错了

		self:checkErrorCode(state,statusCode)
		-- 如果序章中的WebHttpServer请求失败，发送进入序章消息
		-- if self:checkPrologue() then
		-- 	return
		-- end

		self:onClose()
		return
	end

	if DEBUG_CONNLOGS ==2 then
		-- echo("WebHttpServer: responceInfo:", responseData)
	end
	
	local resData = {}
	resData.code = statusCode
	resData.data = json.decode(responseData)
	if not resData.data then
		echoWarn("WebHttp 返回的data不是json数据------需要做异常处理,暂时弹出超时处理")

		self:onClose()
		return

	end
	self.curConn = nil
	if callBack then
		callBack(resData)
	end
	

	if #self.connCache > 0 and not self.curConn then
		local connInfo = self.connCache[1]
		table.remove(self.connCache,1)
		self:sendRequest(connInfo.params, connInfo.url, connInfo.postType, connInfo.headers, connInfo.callBack)
	end

end

function WebHttpServer:toConnString(conninfo )
	local infoJson = {params = conninfo.params,url = conninfo.url}
	return json.encode(infoJson)
end

function WebHttpServer:checkErrorCode( code,statusCode )
	local errorMsg = "WebHttpServer请求错误,statusCode:"..tostring(statusCode)  ..",code:"..code
	if self.curConn then
		errorMsg = errorMsg.."\n"..self:toConnString(self.curConn)
	end
	echoWarn(errorMsg)

	local key = ClientTagData.webHttpRequestError..code
	--一次登入只发送3次
	if Tool:getCacheKeyNums( key ) < 3 then
		ClientActionControler:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,ClientTagData.webHttpRequestError,errorMsg)
		Tool:addCacheKeyNums( key )
	end

	

end


function WebHttpServer:onClose()
	echo("__WebHttpServer_onClose")
	echoError("sakdjsakdsa")
	
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



function WebHttpServer:turnGetUrl(url, params)
	if not params or not next(params) then
		return url
	end
	local ret = {}
	for k,v in pairs(params) do
		table.insert(ret, string.format("%s=%s", k,v))
	end
	local url = string.format("%s?%s", url, table.concat(ret, "&"))
	return url
end

return WebHttpServer.new()
