
local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")

local VerControler = VerControler or {}

echo(device.writablePath,"device.writablePath")
--下载根目录
VerControler.baseDownloadDir = device.writablePath.."dl"
--安装根目录
VerControler.baseInstallDir = device.writablePath.."new"

--初始化目标版本号和server下载列表
function VerControler:init(targetVer,dlList,msgListener)
	--初始化
	self.STATE_INIT = 1
	--工作开始
	self.STATE_START = 2
	--下载开始
	self.STATE_DOWNLOAD_START = 3
	--下载成功
	self.STATE_DOWNLOAD_SUCCESS = 4
	--安装开始
	self.STATE_INSTALL_START = 5
	--安装完成
	self.STATE_INSTALL_SUCCESS = 6
	--工作完成 最终成功
	self.STATE_SUCCESS= 7
	--下载失败
	self.STATE_DOWNLOAD_FAIL = 8
	--安装失败
	self.STATE_INSTALL_FAIL = 9
	--工作完成 最终失败
	self.STATE_FAIL = 10
	self._state = self.STATE_INIT
	self.targetVer = targetVer
	--事件监听注册
	self._msgListener = msgListener
	--单个下载文件的最大次数
	self._httpSingleMaxCnt = 3
	--最大并发下载数
	self._httpMaxCnt = 4
	--最大并发安装数
	self._intallMaxCnt = 4
	--http connect超时时间
	self._httpTimeoutForConnect = 10
	--http 支持最小下载速度byte/s
	self._httpMinDlSpeed = 5*1024
	--安装中消息最多支持格数
	self._installingMaxCnt = 100
	--校验md5
	self._chkMd5 = false
	--[[
	if S.DEBUG_CHK_VER then
		echo("@VerControler:init dlList")
		dump(dlList)
	end
	--]]
	--服务器端的下载列表，为每一个下载分配一个id
	self._serverDlList = {}
	for _,dl in pairs(dlList) do
		--if empty(dl.plat) or dl.plat == device.platform then
			self._serverDlList[dl.patch] = dl
		--end
	end
	--从sqlite中读取所有已下载完成的列表
	self._finishList = LS:ver():getAll()

	local lsVer = self._finishList["__ver"]
	local rightVer = RELEASE_VER.."_"..targetVer
	if not lsVer then
		--数据库版本不存在
		if table.nums(self._finishList) > 0 then
			--删除垃圾数据
			LS:ver():delAll()
			self._finishList = {}
		end
		--设置正确的版本号
		LS:ver():set("__ver" ,rightVer)
	else
		if lsVer~=rightVer then
			--数据库版本与正确版本不一致,删除垃圾数据
			LS:ver():delAll()
			self._finishList = {}
			--设置正确的版本号
			LS:ver():set("__ver" ,rightVer)
		end
	end

	--所有要下载文件的总大小
	self._totalDownloadSize = 0

	--缓存的未下载完成的列表
	self._restList = {}
	for id,dl in pairs(self._serverDlList) do
		if not self._finishList[id] then
			dl.cnt = 0
			self._restList[id] = dl
			self._totalDownloadSize = self._totalDownloadSize + dl.size
		end
	end
	--[[
	if S.DEBUG_CHK_VER then
		echo("@VerControler:init restList")
		dump(self._restList)
	end
	--]]
	self._totalDownloadFiles = table.nums(self._restList)

	--安装的文件数
	self._totalInstalls = #dlList
	--当前安装文件数
	self._curInstalls = 0
	--msg安装文件每次递增数，达到该数时发消息
	if self._totalInstalls<=self._installingMaxCnt then
		--保证消息数不超过installingMaxCnt
		self._msgAddInstalls = 1
	else
		self._msgAddInstalls = self._totalInstalls/self._installingMaxCnt
	end
	--当前msg安装文件临界数
	self._msgCurInstalls = self._msgAddInstalls
	--下载等待队列,按顺序下载
	self._httpWaitQueue = {}
	--http连接池
	self._httpReqList = {}

	--安装等待队列,按顺序安装
	self._installWaitQueue = {}
	--安装池
	self._installList = {}

	--消息队列 确保每个消息在不同的timer发送
	self._msgQueue = {}
	--下载重试次数
	self._dlCnt = 0
end

--返回下载包数据
function VerControler:getTotalDownloads()
	return self._totalDownloadFiles,self._totalDownloadSize
end

--返回安装文件数
function VerControler:getTotalInstalls()
	return self._totalInstalls
end

--返回已下载数据， 第一个返回值为已下载文件数， 第2个返回值为已下载大小
function VerControler:getCurDownloads()
	local restSize = 0
	for _,dl in pairs(self._restList) do
		restSize = restSize + dl.size
	end
	local restFiles = table.nums(self._restList)
	return self._totalDownloadFiles-restFiles, self._totalDownloadSize - restSize
end

--返回状态
function VerControler:getState()
	return self._state
end

--开始工作
function VerControler:start()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler start")
	-- end
	self._state = self.STATE_START
	local msg = {
		name="start",
	}
	self:newMsg(msg)

	if table.nums(self._serverDlList) == 0 then
		--没有可下载的跳过所有步骤 直接成功
		self:success()
		return
	end
	if self:chkDownloadSuccess() then
		return
	end
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler download start")
	-- end
	self._state = self.STATE_DOWNLOAD_START
	--创建目录
	FS.mkDir(self.baseDownloadDir)
	--开始下载
	for id,dl in pairs(self._restList) do
		if table.nums(self._httpReqList) >= self._httpMaxCnt then
			--达到下载最大并发数，插入下载等待队列
			table.insert(self._httpWaitQueue,id)
		else
			self._httpReqList[id] = self:createHttpReq(id)
		end
	end
	local msg = {
		name="downloadStart",
	}
	self:newMsg(msg)
end

--检测是否需要重试下载
function VerControler:chkRetryDownload(id)
	local dl = self._restList[id]
	if not dl then
		echoError("@VerControler chkRetryDownload error id",id)
		return
	end
	if dl.cnt>=self._httpSingleMaxCnt then
		echoWarn("@VerControler chkRetryDownload id",id,"dl.cnt over _httpSingleMaxCnt",dl.cnt)
		--释放连接
		self._httpReqList[id] = nil
		self:downloadFail()
		return
	end
	dl.cnt = dl.cnt+1
	echoWarn("@VerControler chkRetryDownload id",id,"dl.cnt",dl.cnt)
	self._httpReqList[id] = self:createHttpReq(id)
end

--创建一个指定id的下载
function VerControler:createHttpReq(id)
	local dl = self._restList[id]
	if not dl then
		echoError("@VerControler dl error id",id)
		return
	end
	local function onDownloaded(msg)
		--dump(msg)
		--echo(self._state)
		if self._state > self.STATE_DOWNLOAD_START then
			echoWarn("@VerControler onDownloaded already finish self._state",self._state,"id",id,"msg.name",msg.name)
			return
		end
		local req = msg.request
		-- if(S.DEBUG_CHK_VER) then
		-- 	echo("[DOWNLOAD] id",id,"msg.name",msg.name)
		-- end
		if(msg.name ~= "completed") then -- 失败
			echoWarn("@VerControler onDownloaded fail id",id,"msg.name",msg.name)
			--self:chkRetryDownload(id)
			return
		end
		local state = req:getState()
		local statusCode = req:getResponseStatusCode()
		--echo("statusCode="..statusCode)
		-- if(S.DEBUG_CHK_VER) then
		-- 	echo("[DOWNLOAD] id",id,"state(3-OK; 5-timeout)",state,"statusCode",statusCode)
		-- end
		if state==5 then --超时
			echoWarn("@VerControler onDownloaded fail id",id,"state",state)
			self:chkRetryDownload(id)
			return
		end
		if statusCode~=200 then --非200，说明出错了
			echoWarn("@VerControler onDownloaded fail id",id,"statusCode",statusCode)
			--self:chkRetryDownload(id)
			return
		end
		local downloadPath = self:getDownloadPath(id)
		local prePath = FS.getDir(downloadPath)
		if prePath then
			FS.mkDir(prePath)
		end
		-- if S.DEBUG_CHK_VER then
		-- 	echo("[DOWNLOAD] id",id,"saveResponseData downloadPath",downloadPath)
		-- end
		echo("downloadPath"..downloadPath)
		req:saveResponseData(downloadPath)
		if self._chkMd5 then
			local md5 = crypto.md5File(downloadPath)
			if md5 ~= dl.m then
				echoWarn("@VerControler onDownloaded fail id",id,"md5",md5)
				self:chkRetryDownload(id)
				return
			end
		end
		--下载完成处理
		--更新数据库记录
		LS:ver():set(id,"1")
		--删除http连接池的指定位置
		self._httpReqList[id] = nil
		--从未完成下载中删除此条
		self._restList[id] = nil
		-- if S.DEBUG_CHK_VER then
		-- 	echo("[DOWNLOAD] id",id,"success")
		-- end
		local files,size = self:getCurDownloads()
		local msg = {
			name="downloading",
			files = files,
			size = size
		}
		self:newMsg(msg)
		--检查下一条下载逻辑
		self:chkNextDownload()
	end
	local url = self:getDownloadUrl(id)
	
	--local request = CCHTTPRequest:createWithUrl(onDownloaded, url, kCCHTTPRequestMethodGET)
	local request = network.createHTTPRequest(onDownloaded, url, "GET")
	local maxDlTime = math.ceil(dl.size/self._httpMinDlSpeed)+self._httpTimeoutForConnect
	-- if S.DEBUG_CHK_VER then
	-- 	echo("[DOWNLOAD] url",url,"size",dl.size,"maxDlTime",maxDlTime)
	-- end
	if request.setTimeoutForRead then
		request:setTimeoutForRead(maxDlTime)
	end
	request:start()
	return request
end

--检查下一个下载
function VerControler:chkNextDownload()
	if self:chkDownloadSuccess() then
		return
	end
	if #self._httpWaitQueue > 0 then
		if table.nums(self._httpReqList) > self._httpMaxCnt then
			echoError("@VerControler chkNextDownload fail")
			return
		end
		local id = self._httpWaitQueue[1]
		self._httpReqList[id] = self:createHttpReq(id)
		table.remove(self._httpWaitQueue,1)
	end
end

--检查是否下载成功
function VerControler:chkDownloadSuccess()
	if table.nums(self._restList) == 0 then
		if self._state < self.STATE_DOWNLOAD_SUCCESS then
			--锁定 不能重复成功
			self:downloadSuccess()
		end
		return true
	end
	return false
end

--安装(全部下载完后安装)
function VerControler:installStart()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler installStart")
	-- end
	self._state = self.STATE_INSTALL_START
	local msg = {
		name = "installStart",
	}
	self:newMsg(msg)

	local installQueue = {}
	local atsQueue = {}
	-- local binExtension = App:getBinExtension()
	for id,_ in pairs(self._serverDlList) do
		-- local endStr = string.sub(id,-8)
		-- if endStr == "game."..binExtension then
			-- table.insert(atsQueue,id)
		-- else
			table.insert(installQueue,id)
		-- end
	end
	--保证game.ats最后拷贝，防止拷贝一半后退出重启后变成新版本不继续拷贝bug
	--table.insertTo(installQueue, atsQueue)

	--开始安装
	for _,id in ipairs(installQueue) do
		if table.nums(self._installList) >= self._intallMaxCnt then
			--达到最大并发数，插入等待队列
			table.insert(self._installWaitQueue,id)

		else
			local res = self:installFile(id)
			self._installList[id] = 1
			if not res then
				--安装失败，说明本地文件存在问题直接失败
				self:installFail()
				return
			end
		end
	end
	--[[
	dump(installQueue)
	echo("#installQueue",#installQueue)
	echo("table.nums(self._serverDlList)",table.nums(self._serverDlList))
	dump(self._installWaitQueue)
	--]]
	self._installList = {}
	WindowControler:globalDelayCall(c_func(self.chkNextInstall, self))
end


--安装下一批
function VerControler:chkNextInstall()
	if table.nums(self._installList) > self._intallMaxCnt then
		echoError("@VerControler chkNextInstall fail")
		return
	end
	if #self._installWaitQueue == 0 then
		if self._state < self.STATE_INSTALL_SUCCESS then
			--锁定 不能重复成功
			self:installSuccess()
		end
		return
	end
	while #self._installWaitQueue>0 do
		local id = self._installWaitQueue[1]
		local res = self:installFile(id)
		self._installList[id] = 1
		if not res then
			--安装失败，说明本地文件存在问题直接失败
			WindowControler:globalDelayCall(c_func(self.installFail,self))
			return
		end
		table.remove(self._installWaitQueue,1)
		if table.nums(self._installList) >= self._intallMaxCnt then
			break
		end
	end
	self._installList = {}
	WindowControler:globalDelayCall(c_func(self.chkNextInstall, self))
end

function VerControler:installFile(id)
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler installFile id",id)
	-- end
	local downloadPath = self:getDownloadPath(id)
	local installPath = self:getInstallPath(id)
	local res = FS.copy(downloadPath,installPath)
	if res then
		self._curInstalls = self._curInstalls+1
		if self._curInstalls>=self._msgCurInstalls then
			local msg = {
				name = "installing",
				installs = self._curInstalls
			}
			self:newMsg(msg)
			self._msgCurInstalls = self._msgCurInstalls+self._msgAddInstalls
		end
	end
	return res
end

--下载成功
function VerControler:downloadSuccess()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler downloadSuccess")
	-- end
	self._state = self.STATE_DOWNLOAD_SUCCESS
	local msg = {
		name="downloadSuccess"
	}
	self:newMsg(msg)
	if table.nums(self._finishList) == 0 then
		--数据库记载的已下载完的列表为空, 说明都安装完成了
		self:installSuccess()
	else
		self:installStart()
	end
end

--下载失败
function VerControler:downloadFail()
	echoWarn("@VerControler downloadFail")
	--断掉所有的下载
	for id,httpReq in pairs(self._httpReqList) do
		echo("@VerControler downloadFail httpReq cancel id",id)
		httpReq:cancel()
	end
	self._httpReqList = {}

	self._state = self.STATE_DOWNLOAD_FAIL
	local msg = {
		name="downloadFail"
	}
	self:newMsg(msg)
	self:fail()
end

--删除临时数据
function VerControler:delTmp()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler delTmp")
	-- end
	LS:ver():delAll()
	FS.removeDir(self.baseDownloadDir)
end

--删除版本
function VerControler:delVer()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler delVer")
	-- end
	LS:ver():delAll()
	FS.removeDir(self.baseDownloadDir)
	FS.removeDir(self.baseInstallDir)
end

--安装成功
function VerControler:installSuccess()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler installSuccess")
	-- end
	self._state = self.STATE_INSTALL_SUCCESS
	self:delTmp()
	local msg = {
		name="installSuccess"
	}
	self:newMsg(msg)
	self:success()
end

--安装失败
function VerControler:installFail()
	echoWarn("@VerControler installFail")
	self._state = self.STATE_INSTALL_FAIL
	self:delTmp()
	local msg = {
		name="installFail"
	}
	self:newMsg(msg)
	self:fail()
end

function VerControler:fail()
	echoWarn("@VerControler fail")
	self._state = self.STATE_FAIL
	local msg = {
		name="fail"
	}
	self:newMsg(msg)
end

--成功
function VerControler:success()
	-- if S.DEBUG_CHK_VER then
	-- 	echo("@VerControler success")
	-- end
	self._state = self.STATE_SUCCESS
	local msg = {
		name="success"
	}
	self:newMsg(msg)
end

--处理msg
function VerControler:onMsgTimerSchedule()
	--echo("@VerControler:onMsgTimerSchedule")
	if #self._msgQueue > 0 then
		local msg = self._msgQueue[1]
		if self._msgListener then
			self._msgListener(msg)
		end
		table.remove(self._msgQueue,1)
		if msg.name == "success" or msg.name=="fail" then
			self._msgQueue = {}
		end
	end
	if #self._msgQueue == 0 then
		if self._msgTimerHandle then
			--echo("unscheduleGlobal")
			scheduler.unscheduleGlobal(self._msgTimerHandle)
			self._msgTimerHandle = nil
		end
	end
end

--产生一个新的msg
function VerControler:newMsg(msg)
	if msg.name == "start" then
		self._msgQueue = {}
		table.insert(self._msgQueue,msg)
	else
		table.insert(self._msgQueue,msg)
	end
	if not self._msgTimerHandle then
		self._msgTimerHandle = scheduler.scheduleGlobal(c_func(self.onMsgTimerSchedule,self),0.02)
	end
end

--根据id返回安装路径
function VerControler:getInstallPath(id)
	local dl = self._serverDlList[id]
	return self.baseInstallDir.."/"..dl.save
end

--根据id返回下载路径
function VerControler:getDownloadPath(id)
	local dl = self._serverDlList[id]
	return self.baseDownloadDir.."/"..dl.patch
end

--根据id返回下载url
function VerControler:getDownloadUrl(id)
	local dl = self._serverDlList[id]
	return ServiceData.URL_RES..dl.patch.."?v="..self.targetVer
end

return VerControler
