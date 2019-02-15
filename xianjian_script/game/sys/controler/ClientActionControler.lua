--[[
	guan
	2016.5.5
	数据中心 发数据 接口
	todo ios Android 真机测试
]]

local ClientActionControler = class("ClientActionControler");

-- 游戏名称
local GAME_NAME = AppInformation:getGameName();

-- 行为日志收集WebCenterUrl
local WebCenterUrl = AppInformation:getActionLogServerURL();

--错误收集WebCenterUrl
local errorLogCenterUrl = AppInformation:getErrorLogServerURL();

local RequestMode = "POST";

--每生成一个文件，fileNameIndex+1
--每次进游戏，来发送之前没有发送成功的数据
-- TODO 临时解决文件冲掉的问题
-- local fileNameIndex = 1;
local fileNameIndex = TimeControler:getTime() + 1000

local dataCenterFilePreFix = "DataCenterSend";
local errorCenterFilePreFix = "errorCenterSend";

local cErrorPreFix = "cCrashData";

local dirInWritablePath = "DataCenterTemp";


-- 错误日志类型
ClientActionControler.LOG_ERROR_TYPE = {
	TYPE_C = "c",
	TYPE_LUA = "lua",
	TYPE_DOWNLOAD = "download",
	TYPE_OTHER = "other"
};

function ClientActionControler:ctor()

end

--新设备数据统计 
--详见/svn/Design/yuping/客户端-登录流程打点
--action:ActionConfig中的配置，不能有下划线_
function ClientActionControler:sendNewDeviceActionToWebCenter(action)
	if not action or action == "" then
		return
	end

	local devId = AppInformation:getDeviceID()
	local keyAction = devId .. action

	--check 本地 sqlite 中是否有数据
	if LS:pub():get(keyAction, "defaultValue") == "defaultValue" then
		LS:pub():set(keyAction, action);

		local baseInfo = self:getBaseInfo();
		local infoToSend = table.copy(baseInfo);

		infoToSend["module"] = "action";
		infoToSend["action"] = tostring(action);

		self:sendDataToWebCenter(infoToSend);
	end 
end

--[[
	给数据中心发网络状态数据
]]
function ClientActionControler:sendNetworkStatusToWebCenter(action)
	if action == nil or device.platform == "windows" then
		return
	end

	local newAction = ""

	local status = network.getInternetConnectionStatus()
	if status == network.status.kCCNetworkStatusNotReachable then
		newAction = action .. "none"
	elseif status == network.status.kCCNetworkStatusReachableViaWiFi then
		newAction = action .. "wifi"
	elseif status == network.status.kCCNetworkStatusReachableViaWWAN then
		-- 移动网络都设置为4g
		newAction = action .. "4g"
	end

	self:sendTutoralStepToWebCenter(newAction)
end

--[[
	给数据中心发新手引导数据 action 是新手引导步骤
]]
function ClientActionControler:sendTutoralStepToWebCenter(action)
	echo("发送打点 action=",action)
	
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);

	local rid = UserModel:rid()
	local moduleName = "roleaction"
	if UserModel:isDefaultRid(rid) then
		moduleName = "action"
	end

	--登陆后在新手界面，不可能没有rid
	infoToSend["module"] = moduleName;
	infoToSend["rid"] = UserModel:rid();
	infoToSend["action"] = tostring(action);

	-- dump(infoToSend,"info-------------")
	
	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发登录数据
]]
function ClientActionControler:sendLoginDataToWebCenter()
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);
	infoToSend["module"] = "login"
	infoToSend["rid"] = UserModel:rid()
	infoToSend["vip"] = UserModel:vip()

	self:sendDataToWebCenter(infoToSend);
end

--[[
	给数据中心发充值数据
	cash:充值金额
]]
function ClientActionControler:sendChargeDataToWebCenter(cash)
	local baseInfo = self:getBaseInfo();
	local infoToSend = table.copy(baseInfo);
	infoToSend["module"] = "cash"
	infoToSend["rid"] = UserModel:rid()
	infoToSend["cash"] = cash

	self:sendDataToWebCenter(infoToSend);
end


--[[
	给数据中心发错误日志数据
	errorType:ClientActionControler.LOG_ERROR_TYPE 中定义的类型
	functionName:出错函数名称
	errorStack:错误信息或错误堆栈信息
]]
function ClientActionControler:sendErrorLogToWebCenter(errorType,functionName,errorStack)
	--todo UserModel TimeControler 等等 还没有就报错 如何是好
	if UserModel == nil or TimeControler == nil or AppInformation == nil or LoginControler == nil then 
		return;
	end 

	local uname = UserModel._data and UserModel._data.name or "no login"

	
	local errorData = {
		module = "error",

		game = GAME_NAME,
		platform = AppInformation:getAppPlatform(),
		pid = AppInformation:getMostId(),
		
		uid = UserModel:uid(),
		version_base = AppInformation:getClientVersion(),
		version_current = AppInformation:getVersion(),
		sys_version = AppInformation:getOSPlatform() or "None",
		devices_id = AppInformation:getDeviceID(),
		log_time = TimeControler:getServerTime(),
		section_id = LoginControler:getServerId() or "None",

		error_code = errorType,
		function_name = functionName,
		error_stack = errorStack.."\n deviceIp:".. AppInformation:getDeviceIp(  ) .. tostring(uname) .."_device:".. tostring(PCSdkHelper:getDeviceInfo().model) ,
	}
    
    -- dump(errorData, "--error_stack--");

	self:sendDataToWebCenter(errorData, errorLogCenterUrl);
end

-- 发送Lua Error到服务器
function ClientActionControler:sendLuaErrorLog(args)
    local logMsg = ""
    local count = 1
    -- dump(args,"____ffsfargs")
    local length = math.min(10,#args)
    local str = table.concat(args,"",1,length)
    --获取最近80数据
    str = LogsControler:getNearestLogs(100).."\n" .. str

    local funcName = args[#args]


    self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,funcName,str)
end

-- 发送Lua日志到平台(以错误日志格式)
function ClientActionControler:sendLuaLogToPlatform(errorMsg,funcName)
	local funcName = funcName or ""
	self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,funcName,errorMsg)
end

---发送错误数据到平台
function ClientActionControler:sendLuaErrorLogToPlatform(funcTitle)
	-- if device.platform == "mac" or device.platform == "windows" then
	-- 	return 
	-- end
	funcTitle = funcTitle or "sendLuaErrorLogToPlatform"
	local curLogType = LogsControler.logType.LOG_TYPE_NORMAL
	local  logArr = LogsControler:getLogs(curLogType)
	
	if logArr == nil or #logArr == 0 then
		return
	end
	local logMsg = table.concat(logArr,"\n")
	-- for i=1,#logArr do
	-- 	logMsg = logMsg..tostring(logArr[i]).."\n"
	-- end
	if funcTitle ~= "sendLuaErrorLogByFeedBack" then
		WindowControler:showTips(GameConfig.getLanguage("#tid_client_001"))
	end
	
	self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_LUA,funcTitle,logMsg)
end

-------------------------霸气分割线-------------------------
--给数据中心发消息
--todo 可能需要callback
function ClientActionControler:sendDataToWebCenter(infoToSend, serverUrl)
	local url = serverUrl or WebCenterUrl;

	--写个文件
	self:ifSaveDirNotExistThenMkSaveDir();

	if url == WebCenterUrl then 
		-- echo("---serverUrl == WebCenterUrl----");
		--给数据中心的文件
		filePath = self:dataCenterfilePathGen();
	else 
		-- echo("---serverUrl ~= WebCenterUrl----");
		--给错误中心发的
		filePath = self:errorCenterfilePathGen();
	end 

	local file = io.open(filePath, "w");
	if file then
		local jsonStr = json.encode(infoToSend) .. "\n";
		-- echo("zygdebug jsonStr=" .. jsonStr)
		file:write(jsonStr);
		file:close();

		self:justSendFile(filePath, url);
	end

	fileNameIndex = fileNameIndex + 1;
end

function ClientActionControler:justSendFile(filePath, serverUrl)
	local status = network.getInternetConnectionStatus()
	if status == network.status.kCCNetworkStatusNotReachable  then
		-- echo("没有网络,取消上传文件")
		if device.platform ~= "windows" then 
			return
		end
	end
	
	local datas = {
		fileFieldName = "filepath",
		filePath = filePath,
		contentType = "text/plain",
		headers = {"Expect:"}  --不要  100 continue
	};

	if device.platform == "android" then
		-- Content-Type与Java端名称保持一致
		datas.headers = {"Content-Type:multipart/form-data","connection:keep-alive","Charsert:UTF-8"}
	end

	local url = serverUrl or WebCenterUrl;

	-- echo("上传文件filePath---", filePath, url);

	network.uploadFile(c_func(self.onHttpCallBack, self, filePath), url, datas);
end

function ClientActionControler:onHttpCallBack(filePath, message)
	-- echo("---ClientActionControler:onHttpCallBack----");
	local req = message.request;
	-- echo("message.name", message.name);

	--如果连接失败
	if message.name == "failed" then
		echo("---filePath error-- ClientActionControler http请求失败, 请检查网络---",filePath)
		return
	end

	if message.name == "progress" then
		----说明请求在路上---
		return
	end

	local state = req:getState()
	local statusCode = req:getResponseStatusCode()
	local resString = req:getResponseString()

	-- echo("state", state);
	-- echo("statusCode", statusCode);
	-- echo("\n--------resString----------",resString)
	-- echo("zygdebug resString=" .. resString)
	
	if state == 5 then --超时
		echo("ClientActionControler http请求超时---")
		return
	end

	if statusCode == 200 then 
		FS.removeFile(filePath);
		-- echo("----send file finish----", filePath);
		-- echo(" --send file finish--statusCode == 200---");
		return;
	else 
		echoWarn("ClientActionControler http请求错误, statusCode", statusCode)
		return;
	end
end

--生成文件放置路径
function ClientActionControler:dataCenterfilePathGen()
	-- local dir = "/Users/playcrab/Documents/";
	local fileName = dataCenterFilePreFix .. tostring(fileNameIndex) .. ".txt";
	local writablePath = self:getSaveDir();

	return writablePath .. fileName;
end

function ClientActionControler:errorCenterfilePathGen()
	-- local dir = "/Users/playcrab/Documents/";
	local fileName = errorCenterFilePreFix .. tostring(fileNameIndex) .. ".txt";
	local writablePath = self:getSaveDir();

	return writablePath .. fileName;
end


function ClientActionControler:getSaveDir()
	return device.writablePath .. dirInWritablePath .. "/";
end

--[[
	ret {
		device_id = 08478676-C198-45EC-B1DF-1F1605BBC40F,
		time = 1453780310,
		game = xianpro,
		platform = dev,
		section = s2,
		channel = baidu,

	}
]]
function ClientActionControler:getBaseInfo()
	local time = TimeControler:getServerTime();
	local deviceID = AppInformation:getDeviceID();

	local platform = AppInformation:getAppPlatform();
	-- setion不能为nil,否则为非法日志后台不会统计
	local section = LoginControler:getServerId() or "";
	local channel = AppInformation:getChannelName();

	return {device_id = deviceID, 
			time = time, 
			game = GAME_NAME,
			platform = platform,
			section = section,
			channel = channel};
end

--[[
	发送没有发送的数据给数据中心
	可能是之前发送失败或是出错大退了
]]
function ClientActionControler:sendStorageFileToDataCenter()
	local saveDirPath = self:getSaveDir();
	self:ifSaveDirNotExistThenMkSaveDir();
	local fileArray = FS.getFileList(saveDirPath);

	-- 如果日志文件，直接返回
	if fileArray and #fileArray == 0 then
		return
	end

	local fileSendToDataCenterArray = {};
	local fileSendToErrorCenterArray = {};
	local cErrorArray = {};

	for _, v in pairs(fileArray) do
		if string.isContainSubStr(v, dataCenterFilePreFix) == true then 
			table.insert(fileSendToDataCenterArray, v);
		end 

		if string.isContainSubStr(v, errorCenterFilePreFix) == true then 
			table.insert(fileSendToErrorCenterArray, v);
		end 

		if string.isContainSubStr(v, cErrorPreFix) == true then 
			table.insert(cErrorArray, v);
		end 
	end

	--发送
	for _, v in pairs(fileSendToDataCenterArray) do
		self:justSendFile(v, WebCenterUrl);
	end

	--发送
	for _, v in pairs(fileSendToErrorCenterArray) do
		self:justSendFile(v, errorLogCenterUrl);
	end

	--发送
	for _, v in pairs(cErrorArray) do
		self:sendCppCrashFile(v);
	end
end

function ClientActionControler:ifSaveDirNotExistThenMkSaveDir()
	--创建个给数据中心发消息的专门文件夹
	local saveDirPath = self:getSaveDir();
	-- echo("----saveDirPath:getSaveDir-----", saveDirPath);
	local isExist = FS.exists(saveDirPath)
	if isExist == nil or isExist == false then 
		FS.mkDir(saveDirPath);
	end 
end

function ClientActionControler:sendCppCrashFile(filePath)
	--local dir = "/Users/playcrab/Documents/";
	local errorFileStr = FS.readFileContent(filePath);

	FS.removeFile(filePath);

	self:sendErrorLogToWebCenter(ClientActionControler.LOG_ERROR_TYPE.TYPE_C, 
		"", errorFileStr);

end

return ClientActionControler;











