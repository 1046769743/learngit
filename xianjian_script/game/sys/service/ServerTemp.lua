--
-- User: ZhangYanguang
-- Date: 2015/6/25
-- 基本Server类，与服务器交互
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local initLogFileTimeStr = function()
	local time = os.time()
	local year = os.date("%Y",time)
	local month = os.date("%m",time)
	local day = os.date("%d",time)
	local hour = os.date("%H",time)
	local minute = os.date("%M",time)
	local second = os.date("%S",time)
	local strTime = string.format("%d_%d_%d_%02d_%02d_%02d",year,month,day,hour,minute,second)
	return strTime
end
local _logFileTimeStr = initLogFileTimeStr()
local Server=class("Server")


--调试的errorCode 如果想指定服务器某一个协议(method)一些返回指定的errorCode, 那么就在这里配置
--示例 购买体力接口返回错误码 10017
-- Server.debugMethodErrorInfo = {
-- 	method = MethodCode.user_buySp_305,
-- 	errorCode = 10017,	
-- }

Server.debugMethodErrorInfo = {
	method = 0,
	errorCode = "999711",	
}

								  
Server.SPECIAL_ERRORCODE = {
	10006, --账号被封
	10053, --服务器维护
	10054, --服务器关闭
}

local __tempSaveFileName

--[[

因为有可能某一条请求是 多条消息合并的 所以现在所有的connCache的元素 必须是一个二维数组,如果只是一个消息,也要转化成
{  {method:333,rid= 351,...}		},这样的元素结构,这样保证结构一致,便于扩展
缓存当前发送但是没有执行的消息 
格式  
{
	{ {method:333,rid= 351,...}  ,{...}	}	,
	{method:321,rid=351,id:10,params:{}}
}

]]
Server.connCache = {} 		--连接缓存 
Server.missCache = {} 		--连接未完成的 消息 数组 格式和conncache一样 但是 放入这个数组的 不会主动重发 只能被动 等待服务器回馈




--缓存同一条消息自动发送的次数  最多3次

--[[
	难点: 如何记录当前的请求以备网络延迟的时候 重发 
	网络回来的时候 可能会把包进行合并

]]
local logsfile = "logs/serverlogs"

--../../../../../svn/Resources
if device.platform =="mac" then
	logsfile = "../../../../../svn/Resources/logs/serverlogs"
end


Server.id =1
Server.curConn = nil 			--当前连接请求 一定是一个数组 至少是一维的 因为和服务器协议的就是允许多包合并
Server._isConnect = false 		--标记是否连接成功 	--

Server._isServerError= false  	--标记是否有服务器错误 如果有服务器错误 所有的请求不应该走过来

--模块的model映射表
Server.modelMap = nil 
--init消息发送
Server.OPCODE_KAKURA_INIT=1000
--心跳协议发送
Server.OPCODE_KAKURA_HEARTBEAT = 1001
--创建房间
Server.OPCODE_KAKURA_CREATEROOM = 1002
Server.OPCODE_KAKURA_JOINROOM = 1003
Server.OPCODE_KAKURA_EXITROOM = 1004
Server.OPCODE_KAKURA_REMOVEROOM = 1005
Server.OPCODE_KAKURA_GETROOMSUSERS = 1006
Server.OPCODE_KAKURA_COUNTUSERS = 1007
Server.OPCODE_KAKURA_KICKOUTUSERS = 1008
Server.OPCODE_KAKURA_KICKOUTROOMS = 1009
Server.OPCODE_KAKURA_PUSHMESSAGE = 1010
Server.OPCODE_KAKURA_TIMEEVENT = 1011
Server.OPCODE_KAKURA_REMOVEPUSHID = 1012
Server.OPCODE_KAKURA_CHECKONLINE = 1013
--//重新连接
Server.OPCODE_KAKURA_REAUTH = 1014
Server.OPCODE_KAKURA_NORESPONSEPUSHMESSAGE = 1016
        
Server.OPCODE_KAKURA_RESPONSE = 99998
Server.OPCODE_KAKURA_END = 99999

--//backend请求的opcode值，初始化之后的每个长连接请求都会发送这个code
Server.OPCODE_BACKEND_REQUEST = 100001

--//初始化的id值
Server.INIT_ID_VALUE = 1

-- 是否开启重连机制
Server.OPEN_REAUTH = true

--是否是切后台超时,因为现在切后台出去回来的时候 一般都会先serverClose
Server.isOverTimeByBackGround = false

function Server:init(ip,port)
	-- self.connCache = {}
	-- self.missCache = {}
	self.curConn = nil

	-- 需要同步玩家数据的错误码
	self.syncDataErrorCodeArr = ServiceData.syncDataErrorCodeArr

	--忽略输出日志的 code
	self.ignoreLogArr = {
		MethodCode.test_getJsonDesc_100105, 		--忽略测试信息
		MethodCode.test_getJsonDesc2_100103, 	--忽略测试信息2
		MethodCode.user_getUserInfo_301 , 		--忽略掉用户信息
		MethodCode.user_getOnlinePlayer_319 , 	
		MethodCode.mail_requestMail_1501  , 		--忽略邮件 	
		MethodCode.friend_page_list2903,			--忽略好友列表
		MethodCode.battle_receiveFragment_711,		--上报时间片
		MethodCode.battle_reveiveBattleResult_717,	--上传战斗结果
		MethodCode.friend_recommend_list2907,        --好友推荐列表
	}
	--//关于发送的消息与opcode之间的映射表
    self.opcodeMap={
	--//初始化映射
      [MethodCode.sys_init]=Server.OPCODE_KAKURA_INIT,
      [MethodCode.sys_reauth] = Server.OPCODE_KAKURA_REAUTH,
	--//心跳映射
       [MethodCode.sys_heartBeat]=Server.OPCODE_KAKURA_HEARTBEAT,
    };
	self._isConnect =false
	--//当前是否被挤掉线了
    self._isOffline=false;
	--请求返回数据中base数据与model的映射
	self.modelMap = {}
	local dataMap = ServiceData:getModelToServerMap(  )
	for i,v in ipairs(dataMap) do
		if v.keys and #v.keys >= 1 then
			local key = v.keys[1]
			if not v.noSeverMap then
				if self.modelMap[key] then
					echoError("___已经有modelMap映射了 重复了",key,"old:",self.modelMap[key].__cname,"new:",v.model.__cname)
				end
				self.modelMap[key] = v.model
			end
		end
	end

	
	if self.socket   then
		if tolua.isnull(self.socket) then
		else
			self.socket:close()
		end
		self.socket = nil
	end

	self.socket = pc.PCWebSocket:create()

	local signSalt = ServiceData.SIGN_SALT

	--目前sign的计算方法
	signSalt = "/?sign=" .. signSalt
	--//初始化id值
	self.id = 0;
	-- self.socket:init(ServiceData.IP,ServiceData.PORT,signSalt,1)
	self.socket:init(ip, port, signSalt, 0)
	-- echo(ServiceData.IP,ServiceData.PORT,signSalt,"_-dsadsafdfdsfdsf")
	self.socket:setCallBack(0,c_func(self.onCallback,self))

	local clientInfo = AppInformation:getClientInfo()

	--移除所有的初始化 和reauth请求
	self:clearByMethodId(MethodCode.sys_init  )
	self:clearByMethodId(MethodCode.sys_reauth  )
	if not self:checkHasMethod(self:getInitReqeustId()) then
		local initRequestId = self:getInitReqeustId()
		local   _init_param={
		     rid = UserModel:rid(),
		     battleId = "101",
		};
		if initRequestId == MethodCode.sys_init  then
			_init_param.token =  LoginControler:getToken(  )
		else
			_init_param.token =  self.token
		end


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

	return self;
end

--判断是否拥有哪个请求
function Server:checkHasMethod( method )
	if self.curConn then
		for i,v in ipairs(self.curConn) do
			if v.method == method then
				return true
			end
		end
	end

	--从缓存表里面判断
	for i,v in ipairs(self.connCache) do
		for ii,vv in ipairs(v) do
			if vv.method == method then
				return true
			end
		end
	end
	return fals
end


--移除某个请求
function Server:clearByMethodId( method )
	if self.curConn then
		for i,v in ipairs(self.curConn) do
			if v.method == method then
				self.curConn = nil
				echo("_移除curConn消息成功",method)
				return
			end
		end
	end

	local length = #self.connCache
	for i=length,1,-1 do
		local v = self.connCache[i]
		for ii,vv in ipairs(v) do
			if vv.method == method then
				table.remove(self.connCache,i)
				echo("_移除消息成功",method)
				break
			end
		end
	end
end

--连接完成后的回调
function Server:onConnectBack( result )
	dump(result,"____onConnectBack__")
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end

	--如果是错误回调的 那么return.
	if not  result.result then
		--那么一定要弹到主界面
		 self:checkError( result)
		return
	end

	EventControler:dispatchEvent(LoginEvent.SERVEREVENT_INIT_SUCCESS)

	self._isClose = false
	self._isConnect = true
	-- dump(result,"________initBack")
	if self.socket.initComplete then
		-- dump(result,"___connectback")
--//注意,目前已经没有了result.aesKey,所以需要传空字符串,而非result.result.aesKey
		self.socket:initComplete("",result.result.rid,tonumber(result.result.initRequestId) )
	end
	
	self.token = result.result.token

	self.id = result.result.initRequestId;--(tonumber(result.result.initRequestId) +1 ) or self.id                
	echo("Server:onConnectBack 连接返回---是否获取过用户信息:", self:isGetUserInfo() ,"initId:",result.result.initRequestId)
	
	self:checkRequestId()

	local getUserInfo = {}

	--需要把这个请求插到最前面去
	self:doRequest()

end

--判断所有请求是否被服务器处理过,没被处理过的请求,需要重置id
function Server:checkRequestId(  )
	for i,v in pairs(self.connCache) do
		for ii,vv in pairs(v) do
			if vv.id then
				--如果这个请求的id大于服务器处理的进度id ,那么就把这个id置空,否则表示这个请求缓存过了
				if vv.id > self.id then
					vv.id = nil
					vv.uniqueId = nil
					echo("__这个请求id服务器还没处理,需要把id重置",vv.method)
				end
			end
		end
	end
	if self.curConn then
		for ii,vv in pairs(self.curConn) do
			if vv.id then
				--如果这个请求的id大于服务器处理的进度id ,那么就把这个id置空,否则表示这个请求缓存过了
				if vv.id > self.id then
					echo("__这个请求id服务器还没处理,需要把id重置",vv.method)
					vv.id = nil
					vv.uniqueId = nil
				end
			end
		end
	end

end

--服务器返回 
--[[
	event 时间类型  分  error 网络错误 ,close 网络关闭   responce 网络返回
	data 网络返回数据  只有在 event == responce的时候 data 才有值
]]
--//加入了对requestId的直接的支持,以
function Server:onCallback(event, data, uniqueId) 
	dump(data,"event:",event)
	if event ==ServiceData.MESSAGE_ERROR  then
		if data and data ~= "error" then
			local jsonData = json.decode(data)
			if not table.isEmpty( jsonData) then
				self:onError(jsonData)
			else
				echo("onerrorMessage:",data)
				self:onError()
			end
			
		else
			echo("onerrorMessage:",data)
			self:onError()
		end
		
		return
	elseif event == ServiceData.MESSAGE_CLOSE  then
		self:onClose()
		return
	end
	-- echo("data------{"..string.sub(data, 1, 500).."}=======", type(data))
	local jsonData = json.decode(data)
	if not jsonData then
		echo(data,"_this is not json")
	end

	--
	--判断是单包 还是多包
	if not jsonData[1] then
--modify ,目前由于网络框架的改变,已经不能使用这种方法来判断是否是初始化成功的 标志,需要使用新的
        local  _new_data=jsonData
        _new_data.id = _requestId; --//加上新标志,和旧版的协议保持兼容
        if self.debugMethodErrorInfo.method == self:getInitReqeustId() then
 			jsonData.result = nil
        	jsonData.error = {code = self.debugMethodErrorInfo.errorCode,message = "这是手动调试错误method:"..self:getInitReqeustId() ..",error:"..self.debugMethodErrorInfo.errorCode}
        	jsonData.error.lang = jsonData.error.message
 		end


 		if self.curConn and self.curConn[1].method == self:getInitReqeustId() then
 			if not jsonData.result then
 				self.curConn=nil;
 				WindowControler:hideLoading()
 				self:onConnectBack(jsonData);
 				return
 			end
 		end

        if(jsonData.result and jsonData.result.initRequestId~=nil and jsonData.result.token ~=nil)then
             self.curConn=nil;
             self:onConnectBack(jsonData);
             return;
        end
--		if type(jsonData.result) =="string" then
--			echo("_这是初始化init返回",jsonData.result)
--			if self.curConn[1].method == MethodCode.sys_init  then
--				self.curConn = nil
--			end
--			self:doRequest()
--			return
--		end
		--那么包一层把他变成多包
		jsonData = {jsonData}
	end

	if DEBUG_CONNLOGS > 0  then
		self:saveLogs(data,"callBack" .. "_" .. tostring(TimeControler:getServerTime()));
		if DEBUG_CONNLOGS == 2 then
			if self.ignoreLogArr then
				if table.indexof(self.ignoreLogArr, toint( jsonData[1].method) -1 )  then
					--不是心跳请求
					if jsonData[1].method ~= 320 then
						echo("_callBack:".."忽略掉输出的信息,method:"..jsonData[1].method)
					end
					 
				else
					--如果不是心跳返回
					if jsonData[1].result ~= "success" then
						local length = string.len(data)
						local targetIndex = 500
						if length > targetIndex then
							for i=targetIndex,1,-1 do
								local code = string.byte(data,i)
								if code < 128 then
									targetIndex = i
									break
								end
							end
						end
						--最多截取1000字节
						echo("rid:"..UserModel:rid().."_callBack" .. "_time" .. tostring(TimeControler:getServerTime()) .. ":" .. string.sub(data, 1,targetIndex))
					end
					
				end
			end
		end
	end

	data = jsonData

	self.hasErrorCode = false

	--把消息分类 把期中的通知 摘出来
	local notifyArr = {}
	local responceArr = {}
	local baseData = nil

	--更新时间
	local dataTime = data[#data]
	

	for i,v in ipairs(data) do
		--如果是 底层数据变化的 优先处理
		if tonumber(v.method) == (MethodCode.base_dataUpdate_308) then
			baseData = v
		-- elseif not v.result or not v.result.serverInfo then
		-- 	--说明有错误信息
		-- 	echo(json.encode(v).."__error_info")
		else
			if NotifyEvent[tostring(v.method)] then-- and v.method ~= MethodCode.user_state_315+1  then--//同时将init消息排除掉
				table.insert(notifyArr, v)
			else
				-- 在这里判断调试可以测试服务器返回的接口  比如 购买商店道具 ,返回error 
				if self.debugMethodErrorInfo and self.debugMethodErrorInfo.method ~= 0 then
					if type(self.debugMethodErrorInfo.method) == "number" and v.method == self.debugMethodErrorInfo.method +1 then
						v.error = {code = self.debugMethodErrorInfo.errorCode,message = "这是手动调试错误method:"..v.method ..",error:"..self.debugMethodErrorInfo.errorCode}
						--清空result
						v.result = nil
						-- v.method = nil
						-- v.uniqueId = nil
					end
				end
				
				table.insert(responceArr, v)
			end
		end
	end

	--如果有通知 处理通知
	self:onNotify(notifyArr)

	self:checkError(baseData)

	if baseData ~= nil and baseData.params ~= nil and baseData.params.data ~= nil then
		--更新底层数据
		self:updateBaseData(baseData.params.data)
	end

	--判断返回的消息里面是否有底层数据更新
	for i,v in ipairs(responceArr) do
		if v.result and v.result.data and v.result.data.dirtyList then
			self:updateBaseData(v.result.data.dirtyList)
		end
	end
	
	--如果有回调 做回调
	self:onRequestBack(responceArr)

	if dataTime.result and dataTime.result.serverInfo and  dataTime.result.serverInfo.serverTime then
		TimeControler:updateServerTime(dataTime.result.serverInfo.serverTime);
		--服务器没传时区，暂时按北京时间来算
		TimeControler:setTimeZone(TimeControler.TIME_ZONE.GMT8);
	end
	
end

--执行通知
function Server:onNotify( notifyArr )
	for k,v in pairs(notifyArr) do
		self:checkError(v)
		--让通知管理器接受一条通知
		NotifyControler:receivenNotify(v)

	end

end

--执行回调
function Server:onRequestBack( respone )
	-- if not respone then
	-- 	return
	-- end
	respone = respone or {}
	if #respone == 0 then
		return
	end
	WindowControler:hideLoading()

	--每当有请求回来的时候 移除掉超时信息
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end
	
	
	--WindowControler:hideLoading()
	local length = #self.missCache
	--匹配遗失的消息
	for i=length,1,-1 do
		local group = self.missCache[i]

		self:excuteOneResponceGroup(respone,group,2)
		local oldGrou = table.copy(group)
		--如果这个组完成了 那么就 移除掉
		if #group == 0 then
			table.remove(self.missCache,i)
			echo("处理miss消息成功:"..self:toConnString(oldGrou))
		end
	end

	if self.curConn then
		--判断当前回调
		self:excuteOneResponceGroup(respone, self.curConn, 1)
		--如果当前剩余请求数大于0 表示还有请求没有完成 那么存入遗失消息列表

	end

	self:doRequest()

end

--解析一个消息组
function Server:excuteOneResponceGroup(responceArr, connInfo ,groupType)
	if #connInfo ==0 then
		return
	end

	--先做一次数据克隆 
	local cl_connInfo = table.copy(connInfo)
	local length = #cl_connInfo

	--记录匹配上的信息 然后做回调 一定要先把消息从队列移除 在 执行回调,否则可能在回调里面又 发请求
	--这样会错乱堆栈

	local matchResArr = {}
	local isHeartBeat =false
	--这里需要按照先后顺序 去判断 然后删除
	for i=1, length do
		local info = cl_connInfo[i]
		--如果是单向请求的 那么直接清除掉这个请求
		if info.oneway == true then
			table.removebyvalue(connInfo, info)
		else
			local result, resInfo 
			result, resInfo ,isHeartBeat = self:excuetOneResponce(info,responceArr)

			if result then
				table.removebyvalue(connInfo, info)
				table.insert(matchResArr,{info,resInfo})

			end
		end
	end

	--如果是 curConn 当前连接
	if groupType == 1 and (not isHeartBeat) then

		--如果是有错误的
		if self.hasErrorCode then
			self:doAllRequestErrorCall(self.cacheErrorInfo)
		else
			if #connInfo > 0 then
				table.insert(self.missCache, self.curConn)
				echo("消息遗失:\n"..self:toConnString(self.curConn))
			end
		end

		if self.curConn then
			self.curConn = nil
		end
	end

	for i,v in ipairs(matchResArr) do
		local info = v[1]
		local resInfo = v[2]
		-- --执行回调
		if info.call then
			--如果有错误结果的 ,那么 只有当需要错误的返回结果时才执行回调函数
			if not resInfo.result then
				if info.needErrorCall then
					info.call(resInfo)
				end
			else
				info.call(resInfo)
			end
		end
	end
end

--解析一条返回信息
function Server:excuetOneResponce(info, responceArr )
	local length = #responceArr
	local isHeartBeat = false
	if length == 0 then
		return false ,nil ,isHeartBeat
	end

	local result =false
	local resInfo = nil
	for i=length,1,-1 do
		local resp = responceArr[i]
		local methodid = (resp.method) 

		local hideCommonTips = false--info.call and info.needErrorCall
		--如果 是不弹errorTips的
		if methodid and  table.find(NoErrorTipsCode,methodid) then
			hideCommonTips = true
		end

		
		self:checkError(resp, hideCommonTips)
		local id = tonumber(resp.id)
		--如果是同一个id
		--服务器传递回来的 method会比客户端的method高1

		
		if not methodid then
			
			--比如不是心跳请求的时候 才dump
			if resp.result and resp.result == "success" then
				echo("_心跳返回------")
				isHeartBeat = true
			else
				echoWarn("返回的method不是数字,", resp.method)
				dump(resp,"__resp")
			end
			
			methodid = 0
		end


		if (  (not info.uniqueId) or (info.uniqueId and resp.uniqueId == info.uniqueId ) ) 
				and methodid == info.method  then
		-- if  methodid == tonumber(info.method)  then
			--判断这个消息是否已经处理过
			local canDo =true

			--先判断是否消息重复处理 重复处理过的 就让cando为false
			--目前消息机制是 处理完一条 就删除一条  所以不会有重复执行的消息
			if canDo then

				resInfo = resp
				result = true

				break
			end
		end
	end
	return result, resInfo ,isHeartBeat
end

-- 更新baseData
--[[
	更新底层数据 
	数据结构
	baseData = {
		
		--需要更新的数据, 和UserModel._data数据结构一直 
		u = {
			...
		},
		--需要删除的数据  比如要删除 道具id为1001的, 删除什么key 就让对应的key为1
		d = {
			items= {["1001"] = 1}
		}
	}
]]
--如果是isServerBack 是true 表示 是服务器返回的  客户端手动模拟数据 不要传这个
function Server:updateBaseData(baseData,isServerBack)
	-- echo("--------------------------------------")
	-- dump(baseData)
	-- echo("--------------------------------------")
	--先把 非userdata的数据拆开
	local changeData = baseData.u
	local delData = baseData.d

	--如果是server 服务器返回的 需要把这个数据和本地数据对比 只有不一样的才update,
	if isServerBack then
		--比较table
		table.compareTable(changeData,UserModel._data )

	end

	local userChange = {}
	local userDel = {}
	local userHasChange =false
	if changeData then
		userHasChange =false
		for k,v in pairs(changeData) do
			--如果是有模块数据变化的
			if self.modelMap[k] then
				self.modelMap[k]:updateData(v)
			else
				userHasChange = true
				userChange[k] = v
			end
		end

		--如果有用户数据改变了 通知用户数据改变
			if userHasChange == true then
			UserModel:updateData(userChange)
		end
	end

	if delData then
		local userDel = {}
		userHasChange =false
		for k,v in pairs(delData) do
			--如果是有模块数据变化的
			if k ~= "_id" then 
				if self.modelMap[k] then
					self.modelMap[k]:deleteData(v)
				else
					userHasChange = true
					userDel[k] =v
				end
			end
			
		end
		if userHasChange then
			UserModel:deleteData(delData)
		end
	end

	for key,value in pairs(baseData) do
		local dataModel = self.modelMap[key];
		if dataModel ~= nil then
			dataModel:updateData(value);
		end
	end
end

--判断异常
function Server:checkError( responseInfo, hideCommonTips,isInitError)
	if not responseInfo then
		return
	elseif not responseInfo.error then
		return 
	end

	local errorInfo = responseInfo.error

	local errorCode = tonumber(errorInfo.code)
	local txterror = ""..tostring(errorInfo.code).."_错误信息:"..tostring(errorInfo.message)
	local transError = 
	echoWarn("错误码:", txterror)

	--标记含有错误 如果没有method,那么表示系统级的错误,后续需要把当前的连接全部销毁,并按照错误返回去做
	if not responseInfo.method then
		self.hasErrorCode = true
		self.cacheErrorInfo = responseInfo
	end
	--判断战斗校验错误
	if BattleControler then
		BattleControler:checkBattleServerError(errorInfo)
	end
	-- 检查是否需要更新版本
	if errorCode == ErrorCode.kakura_needClientUpdate then
		VersionControler:onReceiveUpdateNotify(errorCode)
		self._isServerError = true
		return
	elseif errorCode == ErrorCode.duplicate_login then
		echo("-------------------你已经被挤掉线了-------------------");
        self._isOffline=true;
        WindowControler:showHighWindow("CompServerOverTimeTipView",true):setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler),false,errorInfo)
		self._isServerError = true 
		return
	--被服务器踢下线 或者是 其他的需要客户端重新登入的异常
    elseif errorCode == ErrorCode.kickouted_by_server or  errorCode == ErrorCode.need_client_relogin 
    	or  errorCode == ErrorCode.other_client_response 
    	then
		self.curConn = nil
		self._isOffline=true;
        WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler),false,errorInfo)
        self._isServerError = true
        return
    --服务器关闭的消息 暂未开服
    elseif errorCode == ErrorCode.sec_close or  errorCode == ErrorCode.sec_maintain 
    	or errorCode == ErrorCode.sec_no_open
    	then
		self.curConn = nil
		self._isOffline=true;
        local ui =WindowControler:showHighWindow("CompServerOverTimeTipView")
        ui:setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler),true,errorInfo)
        self._isServerError = true
        return
    --kakura服务器异常
    elseif errorCode == ErrorCode.kakura_server_error then
    	VersionControler:onReceiveUpdateNotify(errorCode)
		self._isServerError = true
		-- TODO 2017-12-15 kakura有问题暂时屏蔽下面的逻辑
		
    	--[[
		self.curConn = nil
		self._isOffline=true;
        local ui =WindowControler:showHighWindow("CompServerOverTimeTipView")
        ui:setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler),true)
        -- TODO 之后加到配表中
        -- local errorTip = GameConfig.getLanguage("login_server_is_maintain_1002")
        local errorTip = "服务器异常，请重新登录"
        ui:setTipContent(errorTip)
        self._isServerError = true
    	--]]
        return
    --token错误 需要重新登入
    elseif errorCode == ErrorCode.logintoken_expire
    	then
		self.curConn = nil
		self._isOffline=true;
        local ui =WindowControler:showHighWindow("CompServerOverTimeTipView")
        ui:setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler),true,errorInfo)
       	self._isServerError = true
        return
	end

	if  isInitError then
		echo("_初始化错误 需要重启vms")
		self:handleClose()
 		local ui =WindowControler:showHighWindow("CompServerOverTimeTipView")
 		if LoginControler:isInLoginView() then
 			ui:setCallFunc(c_func(LoginControler.reStartVms,WindowControler))
 		else
 			self._isServerError = true
 			ui:setCallFunc(c_func(WindowControler.goBackToEnterGameView,WindowControler))
 		end
   	  	ui:setTipContent(FuncTranslate.getServerErrorMessage(errorInfo)  )
	end
	

	--提示优先级:
	--errorInfo.lang --服务端的错误信息语言
	--errorInfo.error -- errorCode, 本地根据errorCode 显示对应的Lang
	--errorInfo.message
	local tip 
	if not hideCommonTips then
		tip = ServerErrorTipControler:checkShowTipByError(errorInfo) 
	end
	
	if tip then
		echoWarn("error信息:"..tip)
	end

	if self.curConn then
		-- local sendStr= self:turnSendRequest(self.curConn,true) 
		echoWarn("rid:",UserModel:rid().. ",method:" .. self.curConn[1].method)
	end
end

-- 发送请求 oneway是否是单项  默认 非单项  true单项,表示这个请求 是不需要等待服务器反馈的
-- outLoading 默认false nil,表示需要loading   true表示不需要loading

-- atOneRun 是否立刻执行这个请求,默认都是延迟请求一帧,为了请求安全,
--needErrorCall  标记是否在请求发生错误的时候 也需要回调 绝大多数情况走默认配置 bool值,默认不返回错误回调,
--(错误回调和正确回调都是调用同一个函数)
function Server:sendRequest(params, methodid, callBack, oneway, outLoading, needErrorCall)
	--如果是心跳 而且,没连上 那么不重连
	if self._isClose and methodid == MethodCode.sys_heartBeat then
		return
	end
	if self._isServerError then
		return
	end
	--如果是请求协议被临时关闭
	if GameStatic:checkOpCodeClosed(methodid) then
		echoWarn("这个请求被系统关闭",methodid)
		local errorLanguage = GameConfig.getLanguage("tid_common_2017")
		WindowControler:showTips({text = errorLanguage  })
		if callBack then
			local errorInfo = {
				error = {
					code = 1,
					message = errorLanguage,
				}
			}
			callBack(errorInfo)
		end
		return;
	end

	--强制需要错误回调 避免战斗近程卡住
	needErrorCall = true

	--需要延迟一帧发送请求 ,这里是为了 避免 在 一个请求回来的时候  立刻又发送一个请求 会导致冲突
	local tempFunc = function ()
		local connInfo
		
		connInfo =self:turnRequestSave(params, methodid,callBack, oneway,outLoading,needErrorCall)
		-- 缓存请求 
		table.insert(self.connCache, {connInfo} )
		-- 当前请求正在处理中
		if self.curConn and #self.curConn > 0 then
			echo(self.curConn[1].method , " 请求正在处理中...缓存:..",methodid);
			--必须不是在弹重连窗口的过程中
			if not outLoading and (not WindowControler:getWindow( "CompServerOverTimeTipView" ) ) then
				WindowControler:showLoading()
			end

			return;
		else

			local methodid = connInfo.method
			if self._isClose and not self._isOffline and  methodid ~= self:getInitReqeustId()  then
				echo("__发送请求时 还没连上 ---------",methodid)
				self:init()
				return
			end

			self:doRequest();
		end	
	end

	--[[
		因为经常会出现 在回调里面 去继续发送请求 这个时候 会打乱数组顺序,
		所以在请求头部 处理  延迟请求,避免发生数组被打乱
	]]
	tempFunc()
	-- WindowControler:globalDelayCall(tempFunc)
	-- if not  atOneRun then
		
	-- else
	-- 	tempFunc()
	-- end
end


--判断当前是否正在请求
function Server:checkIsSending(  )
	if self.curConn then
		return true
	end
	return false
end

--发送一组请求 --结构
--[[
	{ request1,request2,request3 }
]]
function Server:sendGroupRequest( paramsGroup )
	-- body
	table.insert(self.connCache,paramsGroup)
	if self.curConn then
		return
	end
	self:doRequest();
end


--转化成 保存的请求格式
--此时生成uniqueId
function Server:turnRequestSave(params, methodid, callBack, oneway, outLoading, needErrorCall)
	--self.id = self.id + 1 
	local info = {}
	-- info.id = self.id
	info.params = params

	if  methodid == self:getInitReqeustId() or methodid ==MethodCode.sys_heartBeat   then
		info.method = methodid
	else
		info.method = methodid
		if not params.clientInfo then
			params.clientInfo = {}
		end
	end

	-- local uniqueId = UniqueIdCreater:createUniqueId(methodid);
	info.call = callBack
	info.oneway = oneway
	info.outLoading = outLoading
	info.needErrorCall = needErrorCall
	-- info.uniqueId = uniqueId;


	return info  --{ method = methodid,data = params,id = self.id ,call =callBack,oneway = oneway}
end

--转化保存的格式 为 请求发送格式
function Server:turnSendRequest( connInfo,onlyStr )
	local sourceArr 
	--如果是单个请求 那么需要包装一下
	if connInfo.method then
		sourceArr = {connInfo}
	else
		sourceArr = connInfo
	end

	local isEaseData = false

	local result = {}
	for i,v in ipairs(sourceArr) do
		local tempObj = table.copy(v)
		tempObj.call = nil  --{method = v.method,data = v.data,id =v.id }
		tempObj.oneway = nil
		tempObj.outLoading =nil 
		tempObj.needErrorCall = nil
		--只有重连的时候才需要使用token
		-- tempObj.token = self.token


		if tempObj.method == self:getInitReqeustId() or tempObj.method == MethodCode.sys_heartBeat then
			tempObj.id = Server.INIT_ID_VALUE	
		else
			if not tempObj.id then
				--init  连接 和心跳 不需要id自增
				self.id = self.id +1
				v.id = self.id
				
				tempObj.id = v.id 
				
			elseif tempObj.id <=  self.id then
				-- echoError("___为什么id 会比我的id小,method:%d,id:%d,globalId:%d",tempObj.method,tempObj.id,self.id)
				-- self.id = self.id+1
				-- tempObj.id  = self.id
				-- v.id = self.id

			end
		end
		if not tempObj.uniqueId then
			tempObj.uniqueId = UniqueIdCreater:createUniqueId(tempObj.method,tempObj.id)
		end
		
		v.uniqueId = tempObj.uniqueId

	--	tempObj.params = json.encode(tempObj.params)
		--tempObj.clientInfo = table.copy(v.clientInfo)  
		if tempObj.method == self:getInitReqeustId() or tempObj.method ==MethodCode.sys_heartBeat   then
			isEaseData = true
		end

		table.insert(result, tempObj)
	end

	-- if isEaseData then
	-- 	result = result[1]
	-- end
	result = result[1]
    local   _otherId=result.id;
	local str = json.encode(result);
	local uniqueId = result.uniqueId;

	if DEBUG_CONNLOGS >0 then
		self:saveLogs(str, "connectinfo" .. "_" .. tostring(TimeControler:getServerTime()))
		if DEBUG_CONNLOGS ==2 then
			result.token = nil
			--输出没有token的信息
			local logStr = json.encode(result);
			--心跳请求 不输出log ,请求拉人 不输出log
			if sourceArr[1].method ~= MethodCode.sys_heartBeat and  sourceArr[1].method ~= MethodCode.user_getOnlinePlayer_319  then
				echo("rid:"..UserModel:rid().. "_connectinfo" .. "_time" .. tostring(TimeControler:getServerTime()) ..  ":" .. string.sub(logStr, 1,1000))
			end
		end
	end

	return str, _otherId, uniqueId;
end

-- 重新发送当前请求
function Server:reSendRequest()
	--有系统错误的时候 return掉
	if self._isServerError then
		return
	end
	if self._isClose then
		echo("__重新初始化---------")

		--如果当前有连接
		if self.curConn then
			table.insert(self.connCache, 1,self.curConn )
			self.curConn  = nil
		end

		self:init()
		return
	end

	if self.curConn ~= nil then
		echo("reSendRequest self.curConn=",self:toConnString(self.curConn));
		self:sureSend(self.curConn)  
	end
end

-- 取消当前请求
function Server:cancelRequest()
	echo("cancelRequest self.curConn=");
end

-- 发送请求到服务器
function Server:doRequest()
	if self.curConn then
		return
	end
	if #self.connCache > 0 then
		local cacheConn = self.connCache[1]
		if not self._isConnect then
			if cacheConn[1].method ~= MethodCode.user_state_315 and cacheConn[1].method ~= self:getInitReqeustId()  then
				echo(cacheConn[1].method ,"___cacheConn[1].method ")
				return
			end
		end

	    --如果已经被挤掉线
		if self._isOffline then
             echo("---------Offline already--------------");
             return;
        end
		--移除第一个数
		table.remove(self.connCache,1)

		self.curConn = cacheConn
		local methodid = cacheConn[1].method

		-- if conn[1].method == MethodCode.sys_init or conn[1].method == MethodCode.sys_heartBeat  then
        if( methodid ~= MethodCode.sys_heartBeat and methodid ~= MethodCode.user_getOnlinePlayer_319)then
		    echo("request  ",methodid,"is sent.");
        end
		if methodid == MethodCode.sys_heartBeat then
			self.curConn = nil
			self:sureSend(cacheConn)
		else
			self._delayCallId = scheduler.performWithDelayGlobal(c_func(self.checkOverTime,self,self.curConn),ServiceData.overTimeSecond )
			self:sureSend(self.curConn)
		end
	else
		self.curConn = nil
	end
end

--确定发送
function Server:sureSend( info )
	local needLoading =false

	for i,v in ipairs(info) do
		if not v.outLoading then
			needLoading = true
			break
		end
	end
	
	-- echo(needLoading,info[1].outLoading)
	--需要显示loading
	if needLoading then
		WindowControler:showLoading()
	end

	--需要经过一道数据转化
	--//获取opcode 
	local   _opceode=self.opcodeMap[info[1].method]   or Server.OPCODE_BACKEND_REQUEST;
	local   _send_format ,_id, uniqueId = self:turnSendRequest(info);
	self.socket:sendRequest(_opceode, _id, _send_format, uniqueId);
end

function Server:checkOverTime( curConn )
	--关闭loading
	WindowControler:hideLoading()

    if(self._isOffline )then
         return
    end
	self._delayCallId = nil
	-- if self.curConn ~= nil then
	-- 	--那么设置重连函数
	-- 	WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
	-- end

	if curConn then
		--table.insert(self.missCache, self.curConn)
		echo("消息超时:\n"..self:toConnString(curConn))
		echo("是否当前消息",curConn == self.curConn)
		--重发当前消息
		self:reSendRequest()
	end
end

-- 网络连接已关闭
function Server:onClose(jsonData)
	echo("Server onClose...")
	--如果还没连接成功的时候 那么是不需要close的
	-- echo("Server:onClose",self._isConnect);
	-- if not self._isConnect then
	-- 	return
	-- end

	-- 发送Server连接关闭消息
	EventControler:dispatchEvent(NetworkEvent.SERVER_ON_CLOSE)

	--移除掉这个延迟事件
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end
	echo("Server:onClose",self._isConnect,self.curConn);
	self.socket = nil
	self._isClose = true
	--取消连接
	self._isConnect =false

	--标记是否需要重连
	self._needReconn = true

	self:saveLogs("server on close", "warn")

	--关掉loanding
	WindowControler:hideLoading()
	
	--如果当前有连接 ,并且没有处于被挤掉线 才触发重连
	if self.curConn ~= nil and not self._isOffline then
		--如果是serverError的时候 是不弹窗的
		if self._isServerError then
			return
		end
		--那么设置重连函数
		WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
	end
	--WindowControler:hideLoading()
end

-- 没有网络
function Server:onError(jsonData)
	echo("Server:onError");
	if not self._isConnect then
		return
	end

	-- self.socket = nil
	-- self._isClose = true
	-- --取消连接
	-- self._isConnect =false
	--清除超时请求
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end
	-- dump(jsonData,"___jsonData")
	self:saveLogs("server on close", "warn")
	
	--关掉loanding
	WindowControler:hideLoading()
	
    --如果版本问题
    if jsonData and jsonData.error then
    	self:checkError(jsonData)
    end
    if not  jsonData then
    	jsonData =  {error = {code = ErrorCode.sys_error,message = "system error"} }
    end
    self:doAllRequestErrorCall(jsonData)
end

--如果收到error信息 那么销毁所有的请求,并执行错误回调,这样可以让进程不卡住
function Server:doAllRequestErrorCall( errorInfo )
	if type(errorInfo) == "string" then
		errorInfo =  {error = {code = ErrorCode.sys_error,message = "system error"} }
	end


	local doCallFunc = function (connInfo  )
		for i,v in ipairs(connInfo) do
			if v.call then
				v.call(errorInfo)
			end
		end
	end

	if self.curConn then
		local conn = self.curConn
		doCallFunc(conn)
		conn = nil
		echoWarn("___有系统错误的时候 做所有消息的错误回调,保证不会卡死")
	end

	for i,v in ipairs(self.missCache) do
		doCallFunc(v)
		echoWarn("__做missle消息的错误回调")
	end
	self.missCache = {}

end

--输出一个消息组信息
function Server:toConnString( conninfo )
	local str = ""
	for i,v in ipairs(conninfo) do
		str = "消息"..i ..": method:" ..v.method..",reqid:"..tostring(v.id)  .."\n"

	end
	return str
end

--输出一个responcestring
function Server:toResponceString( responce )
	local str =""
	if not responce then
		return "::没有收到任何消息"
	end
	for i,v in ipairs(responce) do
		if not v.result.serverInfo then
			str = "收到消息:"..i ..": method:" ..tostring(v.method)..",reqid:".. json.encode(v)  .."\n"
		else
			str = "收到消息:"..i ..": method:" ..v.method..",reqid:"..v.id  .."\n"
		end
		
	end
	return str
end

--手动关闭
function Server:handleClose()
	if self.socket then
		self._isConnect = false
		self._isClose = true

		-- TODO Windows平台手动close会导致进程卡死
		if device.platform ~= "windows" then
			self.socket:close()
		end
		
		--self.socket:release()
		self.socket = nil
	end
end

function Server:isConnect()
	return self._isConnect
end

function Server:deleteMe()
	if self.socket then
		self.socket:release()
		--self.socket:release()
		self.socket = nil
	end
end

--保存日志
function Server:saveLogs( str,title )
	--如果是调试日志的

	if DEBUG_CONNLOGS > 0 then

		if not str then
			echoError("警告:保存的日志为空")
			return
		end

		if device.platform == "windows" or device.platform =="mac" then

			local time = os.time()
    

   			local  lastTimeStr = os.date("%d-%H:%M:%S",time)

			local targetStr =  lastTimeStr.. "_rid: "..   UserModel:rid().."_" .. title..": " .. str .. "\n"

			if LogsControler and DEBUG  and DEBUG  > 0 then
				LogsControler:saveLocalLog(targetStr)
			end
		end
	end
end


--获取初始化请求协议和参数
function Server:getInitReqeustId(  )
	
	return "init" 
end

function Server:getUserInfoRequestId(  )
	if  self:isGetUserInfo() then 
		return  MethodCode.user_relogin_359
	end
	return  MethodCode.user_getUserInfo_301
end




--是否已经获取过用户信息
function Server:isGetUserInfo(  )
	return self._hasGetUserInfo
end

--设置都去过用户信息
function Server:setHasGetUserInfo(value )
	self._hasGetUserInfo = value
end


function Server:resetServerError(  )
	self._isServerError =false
end

return Server;
