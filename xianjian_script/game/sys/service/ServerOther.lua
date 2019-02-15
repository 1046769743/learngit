--
-- User: ZhangYanguang
-- Date: 2015/6/25
-- 基本Server类，与服务器交互
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local ServerOther=class("ServerOther")

--[[

因为有可能某一条请求是 多条消息合并的 所以现在所有的connCache的元素 必须是一个二维数组,如果只是一个消息,也要转化成
{  {method:333,rid= 351,...}		},这样的元素结构,这样保证结构一致,便于扩展
缓存当前发送但是没有执行的消息 
格式  
{
	{ {method:333,rid= 351,...}  ,{...}	}	,
	{method:321,rid=351,...}
}

]]
ServerOther.connCache = {} 		--连接缓存 
ServerOther.missCache = {} 		--连接未完成的 消息 数组 格式和conncache一样 但是 放入这个数组的 不会主动重发 只能被动 等待服务器回馈

--缓存同一条消息自动发送的次数  最多3次
--[[
	难点: 如何记录当前的请求以备网络延迟的时候 重发 
	网络回来的时候 可能会把包进行合并
]]

ServerOther.id =1
ServerOther.curConn = nil 			--当前连接请求 一定是一个数组 至少是一维的 因为和服务器协议的就是允许多包合并
ServerOther._isConnect = false 		--标记是否连接成功 	--
--模块的model映射表
ServerOther.modelMap = nil 


--服务器返回 
--[[
	event 时间类型  分  error 网络错误 ,close 网络关闭   responce 网络返回
	data 网络返回数据  只有在 event == responce的时候 data 才有值
]]
function ServerOther:onCallback(event, data ) 
	if event ==ServiceData.MESSAGE_ERROR  then
		self:onError()
		return
	elseif event == ServiceData.MESSAGE_CLOSE  then
		self:onClose()
		return
	end
	local jsonData = json.decode(data)
	if not jsonData then
		echo(data,"_this is not json")
	end
	--
	--判断是单包 还是多包
	if not jsonData[1] then
		if type(jsonData.result) =="string" then
			echo("_这是初始化init返回",jsonData.result)
			if self.curConn[1].method == MethodCode.sys_init  then
				self.curConn = nil
			end
			self:doRequest()
			return
		end
		--那么包一层把他变成多包
		jsonData = {jsonData}
	end

	if DEBUG_CONNLOGS > 0  then
		self:saveLogs(data,"callBack" .. "_" .. tostring(TimeControler:getServerTime()));
	end

	data = jsonData

	self.hasErrorCode = false

	--把消息分类 把期中的通知 摘出来
	local notifyArr = {}
	local responceArr = {}
	local baseData = nil

	--更新时间
	local dataTime = data[#data]
	if dataTime.result and dataTime.result.serverInfo and  dataTime.result.serverInfo.serverTime then
		-- TimeControler:updateServerTime(dataTime.result.serverInfo.serverTime);
		--服务器没传时区，暂时按北京时间来算
		-- TimeControler:setTimeZone(TimeControler.TIME_ZONE.GMT8);
	end

	for i,v in ipairs(data) do
		--如果是 底层数据变化的 优先处理
		if tonumber(v.method) == (MethodCode.base_dataUpdate_308) then
			baseData = v
		-- elseif not v.result or not v.result.serverInfo then
		-- 	--说明有错误信息
		-- 	echo(json.encode(v).."__error_info")
		else
			if not  v.id and v.method ~= MethodCode.user_state_315+1   then
				table.insert(notifyArr, v)
			else
				table.insert(responceArr, v)
			end
		end
	end

	--如果有通知 处理通知
	self:onNotify(notifyArr)

	self:checkError(baseData)

	--如果有回调 做回调
	self:onRequestBack(responceArr)
	--如果有错误信息 但是当前的curConn 不为空 表示是重大错误 这个时候应该销毁所有的任务列表 保证其他系统能正常进行

	if self.hasErrorCode then
		if self.curConn or #self.connCache >0 then
			if self.curConn then
				echo("ServerOther 遗失消息:".. self:toConnString(self.curConn))
			end
			if #self.connCache >0 then
				echo("ServerOther 遗失消息"..self:toConnString(self.connCache[1]))
			end
		end
	end

	--在继续判断未完成的请求
	self:doRequest()
end

--执行通知
function ServerOther:onNotify( notifyArr )
	for k,v in pairs(notifyArr) do
		self:checkError(v)
		--让通知管理器接受一条通知
		NotifyControler:receivenNotify(v)
	end
end

--执行回调
function ServerOther:onRequestBack( respone )
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
		self:excuteOneResponceGroup(respone,self.curConn,1)
		--如果当前剩余请求数大于0 表示还有请求没有完成 那么存入遗失消息列表

		-- if self.curConn  and  #self.curConn >0 then
		-- 	table.insert(self.missCache, self.curConn)
		-- 	echo("消息遗失:\n"..self:toConnString(self.curConn))
		-- end
		-- self.curConn = nil
	end

	self:doRequest()
end

--解析一个消息组
function ServerOther:excuteOneResponceGroup(responceArr, connInfo ,groupType)
	if #connInfo ==0 then
		return
	end

	--先做一次数据克隆 
	local cl_connInfo = table.copy(connInfo)
	local length = #cl_connInfo

	--记录匹配上的信息 然后做回调 一定要先把消息从队列移除 在 执行回调,否则可能在回调里面又 发请求
	--这样会错乱堆栈

	local matchResArr = {}

	--这里需要按照先后顺序 去判断 然后删除
	for i=1,length do
		local info = cl_connInfo[i]
		--如果是单向请求的 那么直接清除掉这个请求
		if info.oneway == true then
			table.removebyvalue(connInfo, info)
		else
			local result,resInfo = self:excuetOneResponce(info,responceArr)

			if result then
				table.removebyvalue(connInfo, info)
				table.insert(matchResArr,{info,resInfo})

			end
		end
	end

	--如果是 curConn 当前连接
	if groupType == 1 then
		if #connInfo > 0 then
			table.insert(self.missCache, self.curConn)
			echo("消息遗失:\n"..self:toConnString(self.curConn))
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
function ServerOther:excuetOneResponce(info, responceArr )
	local length = #responceArr
	if length == 0 then
		return false
	end
	local result =false
	local resInfo = nil
	for i=length,1,-1 do
		local resp = responceArr[i]
		--如果需要分系统错误回调，那么就不弹通用提示
		local hideCommonTips = info.call and info.needErrorCall
		self:checkError(resp, hideCommonTips)
		local id = tonumber(resp.id)
		--如果是同一个id
		--服务器传递回来的 method会比客户端的method高1

		local methodid = tonumber(resp.method) 
		if not methodid then
			echoWarn("返回的method不是数字,",resp.method)
			dump(resp,"__resp")
			methodid = 0
		end
		methodid = methodid -1
		if ( (info.id and  id == info.id)  or  (not info.id) ) and methodid == tonumber(info.method)  then
			--判断这个消息是否已经处理过
			local canDo =true

			--先判断是否消息重复处理 重复处理过的 就让cando为false
			--目前消息机制是 处理完一条 就删除一条  所以不会有重复执行的消息
			if canDo then
				--回调不能在这里执行 否则 如果回调里面又有新的请求,那么 堆栈就会错乱
				-- if info.call then
				-- 	--如果有错误结果的 ,那么 只有当需要错误的返回结果时才执行回调函数
				-- 	if not resp.result then
				-- 		if info.needErrorCall then
				-- 			info.call(resp)
				-- 		end
				-- 	else
				-- 		info.call(resp)
				-- 	end
				-- end
				resInfo = resp
				result = true
				break
			end
		end
	end
	return result,resInfo
end

--判断异常
function ServerOther:checkError( responseInfo, hideCommonTips)
	if not responseInfo then
		return
	elseif not responseInfo.error then
		return 
	end
	Server.checkError(self, responseInfo, hideCommonTips)
end


--判断当前是否正在请求
function ServerOther:checkIsSending(  )
	if self.curConn then
		return true
	end
	return false
end


--发送一组请求 --结构
--[[
	{ request1,request2,request3 }
]]
function ServerOther:sendGroupRequest( paramsGroup )
	-- body
	table.insert(self.connCache,paramsGroup)
	if self.curConn then
		return
	end
	self:doRequest();
end

--转化成 保存的请求格式
function ServerOther:turnRequestSave(params, methodid, callBack, oneway, outLoading, needErrorCall)
	--self.id = self.id + 1 
	local info = {}
	--info.id = self.id
	info.params = params

	if  methodid == MethodCode.sys_init or methodid ==MethodCode.sys_heartBeat   then
		info.method = methodid
	else
		if tonumber(methodid) then
			info.method = tonumber(methodid)
		else
			info.method = methodid
		end
		
		if not params.clientInfo then
			params.clientInfo = {}
		end
	end
	
	info.call = callBack
	info.oneway = oneway
	info.outLoading = outLoading
	info.needErrorCall = needErrorCall

	return info  --{ method = methodid,data = params,id = self.id ,call =callBack,oneway = oneway}
end

--转化保存的格式 为 请求发送格式
function ServerOther:turnSendRequest( connInfo )
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
		if not tempObj.id then
			--init  连接 和心跳 不需要id自增
			if tempObj.method ~= MethodCode.sys_init and tempObj.method ~= MethodCode.user_state_315 
			 then
				self.id = self.id +1
				v.id = self.id
			else
				v.id = nil
			end
			
			
			tempObj.id = v.id 
		end

		--tempObj.clientInfo = table.copy(v.clientInfo)  
		if tempObj.method == MethodCode.sys_init or tempObj.method ==MethodCode.sys_heartBeat   then
			isEaseData = true
		end

		table.insert(result, tempObj)
	end

	if isEaseData then
		result = result[1]
	end

	local str = json.encode(result)


	if DEBUG_CONNLOGS >0 then

		self:saveLogs(str, "connectinfo" .. "_" .. tostring(TimeControler:getServerTime()))

		if DEBUG_CONNLOGS ==2 then
			--心跳请求 不输出log ,请求拉人 不输出log
			echo("turnSendRequest rid:"..UserModel:rid().. "_connectinfo" .. "_time" .. tostring(TimeControler:getServerTime()) ..  ":" .. string.sub(str, 1,1000))
		end
	end
	return str
end

-- 发送请求到服务器
function ServerOther:doRequest()
	if self.curConn then
		return
	end
	if #self.connCache > 0 then
		local cacheConn = self.connCache[1]
		if not self._isConnect then
			if cacheConn[1].method ~= MethodCode.user_state_315 and cacheConn[1].method ~= MethodCode.sys_init  then
				echo(cacheConn[1].method ,"___cacheConn[1].method ")
				return
			end
		end

		--移除第一个数
		table.remove(self.connCache,1)
		self.curConn = cacheConn
		local methodid = cacheConn[1].method

		-- if conn[1].method == MethodCode.sys_init or conn[1].method == MethodCode.sys_heartBeat  then
		if methodid == MethodCode.sys_heartBeat  then
			self.curConn = nil
			self:sureSend(cacheConn)
		else
			self._delayCallId = scheduler.performWithDelayGlobal(c_func(self.checkOverTime,self,info),ServiceData.overTimeSecond )
			self:sureSend(self.curConn)
		end
	else
		self.curConn = nil
	end
end

function ServerOther:checkOverTime(  )
	--关闭loading
	WindowControler:hideLoading()

	self._delayCallId = nil

	if self.curConn then
		--table.insert(self.missCache, self.curConn)
		echo("消息超时:\n"..self:toConnString(self.curConn))

		--重发当前消息
		self:reSendRequest()
	end
end

-- 网络连接已关闭
function ServerOther:onClose(jsonData)
	--如果还没连接成功的时候 那么是不需要close的
	-- echo("ServerOther:onClose",self._isConnect);
	-- if not self._isConnect then
	-- 	return
	-- end
	--移除掉这个延迟事件
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end
	echo("ServerOther:onClose",self._isConnect,self.curConn);
	self.socket = nil
	self._isClose = true
	--取消连接
	self._isConnect =false

	self:saveLogs("server on close", "warn")

	--关掉loanding
	WindowControler:hideLoading()
	
	--如果当前有连接 才触发重连
	if self.curConn ~= nil then
		--那么设置重连函数
		WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
	end
end

-- 没有网络
function ServerOther:onError(jsonData)
	if not self._isConnect then
		return
	end
	echo("ServerOther:onError");

	self.socket = nil
	self._isClose = true
	--取消连接
	self._isConnect =false
	--清除超时请求
	if self._delayCallId then
		scheduler.unscheduleGlobal(self._delayCallId)
		self._delayCallId = nil
	end

	self:saveLogs("server on close", "warn")

	--关掉loanding
	WindowControler:hideLoading()
	
	if self.curConn ~= nil then
		--那么设置重连函数
		WindowControler:showHighWindow("CompServerOverTimeTipView"):setCallFunc(c_func(self.reSendRequest,self))
	end
end

--输出一个消息组信息
function ServerOther:toConnString( conninfo )
	local str = ""
	for i,v in ipairs(conninfo) do
		str = "消息"..i ..": method:" ..v.method..",reqid:"..tostring(v.id)  .."\n"

	end
	return str
end

function ServerOther:isConnect()
	return self._isConnect
end

function ServerOther:deleteMe()
	if self.socket then
		self.socket:release()
		--self.socket:release()
		self.socket = nil
	end
end

--保存日志
function ServerOther:saveLogs( str,title )
	--如果是调试日志的
	Server:saveLogs(str,title)
end

return ServerOther;
