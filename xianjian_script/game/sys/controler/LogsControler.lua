local LogsControler = LogsControler or {}

--一行支持的文本数最大值 ,一个中文算2个字节
local messageLength = 95
local _tempClientLogFileName = nil
local _tempSpineLogFileName = nil

-- 日志类型
LogsControler.logType = {
    LOG_TYPE_NORMAL = 1,
    LOG_TYPE_WARN = 2,
    LOG_TYPE_ERROR = 3,
    }

-- 每类日志最大行数
LogsControler.maxLineMap = {
    [LogsControler.logType.LOG_TYPE_NORMAL] = 2000,
    [LogsControler.logType.LOG_TYPE_WARN] = 500,
    [LogsControler.logType.LOG_TYPE_ERROR] = 500,
    }

--logs内容数组
LogsControler._logsInfo = { 
    [LogsControler.logType.LOG_TYPE_NORMAL] = {},
    [LogsControler.logType.LOG_TYPE_WARN] =  {},
    [LogsControler.logType.LOG_TYPE_ERROR] = {}    
}

--根据日志类型添加日志信息
-- logType:日志类型
-- log内容为不定参数链接后的字符串
local tempFilePath = nil
function LogsControler:addLog(logType,args)

    -- if not DEBUG_LOGVIEW then
    --     return
    -- end

    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return
    end

    local logMsg 
    if type(args) == "string" then
        logMsg = args 
    else
        logMsg = table.concat(args," ")
    end
    -- for k,v in pairs(args) do
    --     logMsg = logMsg .. " " .. tostring(v)
    -- end

    -- 把关于spineCheck的Log输入到一个文件
    if IS_CHECK_SPINE_ATTACHMENTSIZE and string.find(logMsg, "Spine size warning") then
        local logfile = self:getSpineCheckLogFile()
        if device.platform == "windows" or device.platform =="mac" then
         local targetFile = io.open(logfile,"a")

            if targetFile == nil then
                return
            end

            targetFile:write(logMsg.."\n")
            targetFile:close()
        end
    end

    if logType == self.logType.LOG_TYPE_NORMAL then
        self:addNormal(logMsg)
    elseif logType == self.logType.LOG_TYPE_WARN then
        self:addWarn(logMsg)
    elseif logType == self.logType.LOG_TYPE_ERROR then
        self:addError(logMsg)
    end
end

--添加普通log日志
function LogsControler:addNormal(str )
	self:joinOneMessage(str,self.logType.LOG_TYPE_NORMAL)
end

--添加警告log日志
function LogsControler:addWarn( str )
    self:joinOneMessage(str,self.logType.LOG_TYPE_WARN)
    self:joinOneMessage(str,self.logType.LOG_TYPE_NORMAL)
end

--添加错误log日志
function LogsControler:addError( str )
	self:joinOneMessage(str,self.logType.LOG_TYPE_ERROR)
    self:joinOneMessage(str,self.logType.LOG_TYPE_NORMAL)
    --解决当开启日志时,切换账号会报错的bug
    if GameLuaLoader:isGameDestory() then
        return
    end
    if DEBUG_LOGVIEW   then
        if WindowControler then
            WindowControler:showTips({text= "有错误,请打开日志窗口,把报错信息截屏发给技术"})
        end
    end


end

--根据类型，清空log
function LogsControler:clearLogByType( logType )
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return logsArr
    end

    self._logsInfo[logType] = {}
    --清除日志的时候需要做一次回收
    collectgarbage("collect")
    EventControler:dispatchEvent(LogEvent.LOGEVENT_LOG_CHANGE,{logType=logType});
end

-- 获取log数据
function LogsControler:getLogs( logType )
    local logsArr = {}
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return logsArr
    end
    
    logsArr = self._logsInfo[logType]

    if #logsArr <= 0 then
        return {"没有找到该类型日志"}
    end

    return logsArr
end

--加入一组信息
function LogsControler:joinOneMessage(str,logType )
    if logType < self.logType.LOG_TYPE_NORMAL or logType > self.logType.LOG_TYPE_ERROR then
        return
    end


    if not IS_IGNORE_LOG then
        local originLogArr = self._logsInfo[logType]
        local newLogArr = self:turnOneStr(str)
        local maxLine = self.maxLineMap[logType]
        
        if (#newLogArr + #originLogArr) > maxLine then
            local deleteLinesNum = #newLogArr + #originLogArr - maxLine
            -- 顺序删除log
            for i=1,#originLogArr,(#originLogArr - deleteLinesNum + 1) do
                table.remove(originLogArr,1)
            end


            -- for i = #originLogArr,(#originLogArr - deleteLinesNum + 1),-1 do
            --     table.remove(originLogArr,i)
            -- end
        end
        
        -- 插入log
        for i=1,#newLogArr do
            table.insert(originLogArr, newLogArr[i])
        end
        -- for i=#newLogArr,1,-1 do
        --     table.insert(originLogArr, newLogArr[i])
        -- end

        if DEBUG_LOGVIEW and EventControler then
            EventControler:dispatchEvent(LogEvent.LOGEVENT_LOG_CHANGE,{logType=logType});
        end
    end
    if logType == self.logType.LOG_TYPE_NORMAL then
        self:saveLocalLog(str)
    end
	
end

--获取最近的日志 默认获取30行的
function LogsControler:getNearestLogs( lines )
    lines = lines or 30
    local resultArr = {}
    local logsArr = self._logsInfo[LogsControler.logType.LOG_TYPE_NORMAL]
    local length = #logsArr
    if lines > length then
        lines = length
    end
    local str = table.concat(logsArr,"\n", length - lines +1,length)
    return str
 
end


function LogsControler:genLocalLogFileName()
	local time = os.time()
	local year = os.date("%Y",time)
	local month = os.date("%m",time)
	local day = os.date("%d",time)
	local hour = os.date("%H",time)
	local minute = os.date("%M",time)
	local second = os.date("%S",time)
	return string.format("%d_%d_%d_%02d_%02d_%02d",year,month,day,hour,minute,second)
end


local saveCacheLogs = {}
local lastSaveTime = 0
--本地存储log
function LogsControler:saveLocalLog(str)

    if device.platform == "windows" or device.platform == "mac" then
        table.insert(saveCacheLogs,str)
    end

    
        

	-- if str == "" or str == nil then return end
	-- local logfile = self:getClientLogFile()
	-- if device.platform == "windows" or device.platform =="mac" then
	-- 	local targetFile = io.open(logfile,"a")

 --        if targetFile == nil then
 --            return
 --        end

 --        targetFile:write(str.."\n")
 --        targetFile:close()
	-- end
end

--确定本地存储
function LogsControler:sureSaveLogs(  )
    if #saveCacheLogs == 0   then
        return
    end
    local str = table.concat(saveCacheLogs,"\n")
    -- if str == "" or str == nil then return end
    local logfile = self:getClientLogFile()
    if device.platform == "windows" or device.platform =="mac" then
     local targetFile = io.open(logfile,"a")

        if targetFile == nil then
            return
        end

        targetFile:write(str.."\n")
        targetFile:close()
    end
    table.clear(saveCacheLogs)
    saveCacheLogs = {}
end


function LogsControler:getClientLogFile()
	local logPath = "logs/clientlogs"
	if device.platform == "mac" then
		logPath = AppHelper:getResourcesRoot() .."/logs/clientlogs"
	end
	if not cc.FileUtils:getInstance():isDirectoryExist(logPath) then 
		cc.FileUtils:getInstance():createDirectory(logPath)
	end
	if not _tempClientLogFileName then
		_tempClientLogFileName = self:genLocalLogFileName()
	end
	local logFile = logPath..'/'.._tempClientLogFileName..'.txt'
	return logFile
end

function LogsControler:getSpineCheckLogFile()
    local logPath = "/logs/spineChecklogs"
    if device.platform == "mac" then
        logPath = AppHelper:getResourcesRoot() ..logPath
    end

    if not cc.FileUtils:getInstance():isDirectoryExist(logPath) then 
        cc.FileUtils:getInstance():createDirectory(logPath)
    end
    if not _tempSpineLogFileName then
        _tempSpineLogFileName = self:genLocalLogFileName()
    end
    local logFile = logPath..'/'.._tempSpineLogFileName..'.txt'
    return logFile
end

--将一个字符串转化成数组
function LogsControler:turnOneStr( str )
    --如果是忽略日志的 那么不做转化了
    if IS_IGNORE_LOG then
        return {str}
    end
	str = string.gsub(str, "\\n", "\n")
	local arr = string.split(str, "\n")
	local result ={}

	for i,v in ipairs(arr) do
		local tempArr =  string.splitCharsStr(v,messageLength) --self:splitOneStr(v)
		-- echo(v,string.len(v),"string.len(v)")
		for k,s in ipairs(tempArr) do
			table.insert(result, s)
		end
	end

	return  result
end

--中文匹配符
local chiReq = "[\128-\255][\128-\255][\128-\255]"
function LogsControler:splitOneStr( input, lineChars )
    lineChars = lineChars or messageLength
	local pos,arr = 1, {}
	local len = string.len(input)
	local resultArr = {}
	if len ==0 then
		return resultArr
	end
    -- 先把这个字符串按照字符拆分 中文字符也算一个字符拆分 同时记录长度
    for st,sp in function() return string.find(input, chiReq, pos) end do
    	if st >1 and pos < st then

    		for i=pos,st-1 do
    			table.insert(arr, { string.sub(input, i, i)  ,1 } )
    		end
    	end
        table.insert(arr, {string.sub(input, st, sp) ,2 } )
        pos = sp + 1
    end

    if pos <= len then
    	for i=pos,len do
			table.insert(arr, {string.sub(input, i, i) ,1 })
		end
    end


    local utfLength =0

    local tempStr = ""

    local arrleng = #arr

    for i,v in ipairs(arr) do
    	local str = v[1]
    	local len =v[2]
    	--如果大于一行的长度了
    	--echo(i,str,len, arrleng,"___aa",tempStr,utfLength)
    	if utfLength + len > lineChars then
    		table.insert(resultArr, tempStr)
    		tempStr = str
    		utfLength = len
    	else
    		
    		utfLength = utfLength + len
    		tempStr = tempStr ..str
    	end

    	if i == arrleng then
			table.insert(resultArr, tempStr)
		end
    end

    return resultArr
end


--保存本地所有注册过的用户名
function LogsControler:saveUserInfo( username,password )
    if device.platform ~= "mac" and device.platform ~= "windows" then
        return
    end
    local key = "用户名:".. username .. ",密码:" ..  password ..",注册时间:"..os.date("%Y-%m-%d %H:%M:%S")
    local filePath = "logs/userNameCache.txt"
    if device.platform == "mac" then
        filePath = AppHelper:getResourcesRoot() .."/logs/userNameCache.txt"
    end
    local targetFile = io.open(filePath,"a")

    if targetFile == nil then
        return
    end
    echo("缓存账号密码,",key)
    targetFile:write(key.."\n")
    targetFile:close()

end



return LogsControler
