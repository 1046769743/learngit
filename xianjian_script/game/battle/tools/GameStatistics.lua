

GameStatistics = {}

GameStatistics.operationInfo =  nil

-- 初始化
function GameStatistics:init(fileName)
end

-- 获取log信息的路径
function GameStatistics:getLogsFullPath()
	local logsfile = "logs/battlelogs"

	if DEBUG_SERVICES and (not IS_LOCAL_RUN_BATTLE) then
		return "logs/battlelogs/"
	end

	if device.platform =="mac" then
		-- logsfile = "../../../logs/battlelogs"
		logsfile = AppHelper:getResourcesRoot() .."/logs/battlelogs"
	end

	if (not cc.FileUtils:getInstance():isDirectoryExist(logsfile) ) then
		cc.FileUtils:getInstance():createDirectory(logsfile)
	end

	self._fulPath = logsfile.."/"
	return  self._fulPath 
end


-- 获取当前时间
function GameStatistics:getFileName(rid)
	local time = os.time()
	local year = os.date("%Y",time)
	local month = os.date("%m",time)
	local day = os.date("%d",time)
	local hour = os.date("%H",time)
	local minute = os.date("%M",time)
	local second = os.date("%S",time)

	local fileName,logFileName
	if rid then
		fileName = string.format("bt_%d_%d_%d_%02d_%02d_%02d_%s.txt",year,month,day,hour,minute,second,tostring(rid))
		logFileName = string.format("bt_%d_%d_%d_%02d_%02d_%02d_%s_log.txt",year,month,day,hour,minute,second,tostring(rid))
	else
		fileName = string.format("bt_%d_%d_%d_%02d_%02d_%02d.txt",year,month,day,hour,minute,second)
		logFileName = string.format("bt_%d_%d_%d_%02d_%02d_%02d_log.txt",year,month,day,hour,minute,second)
	end
	
	return fileName,logFileName
end


-- 读取战斗信息
function GameStatistics:getLogsBattleInfo( fileName )
	if not self._fulPath then
		self:getLogsFullPath()
	end
	local name = self:getLogsFullPath()..fileName..".txt"
	-- if not cc.FileUtils:getInstance():isFileExist(name) then
	-- 	echo("______读取的操作文件不存在")
	-- 	return
	-- end

	-- local str =  FS.readFileContent(name)

	local sourceFile =  io.open(name,"rb");
	
	if not sourceFile then
		echoError("__no battleInfo files",fileName)
		return {}
	end
	local str = sourceFile:read("*a")
	sourceFile:close()

	local obj = json.decode(str)
	-- 另一种结构（竞技场的完整数据）
	--[[
	obj = json.decode(obj.result.data.report)
	obj.gameMode = Fight.gameMode_pvp
	obj.battleLabel = GameVars.battleLabels.pvp
	obj.battleId = "1"
	obj.levelId = "103"
	]]
	-- for k,v in pairs(obj) do
	-- 	echo(k,v,"____aaadhsajdsh")
	-- end
	return obj
end

function GameStatistics:saveBattleInfo(battleInfo,isCheck)
	if DEBUG_SERVICES and (not IS_LOCAL_RUN_BATTLE)  then
		return
	end
	if device.platform == "windows" or device.platform =="mac" then

		local logsInfo = battleInfo.dataString
		battleInfo.dataString = nil
		local fileName,logsFileName = self:getFileName(BattleControler._battleInfo.userRid)
		local targetFileName = self:getLogsFullPath()..fileName
		local targetFile, errorMsg = io.open(targetFileName, "a")
		local targetStr = json.encode(battleInfo)

		if not targetStr or targetStr == "" then
			echoWarn("____错误的battleInfo")
		end
		targetFile:write(targetStr)
		targetFile:close()
		if isCheck then
			logsFileName = string.gsub(logsFileName,".txt","_check.txt")
		end
		logsFileName = self:getLogsFullPath()..logsFileName
		local targetFile, errorMsg = io.open(logsFileName, "a")
		targetFile:write(logsInfo)
		targetFile:close()
		return fileName 
	end
	
end


local callTimesMap = {}
function GameStatistics:statisticeCallTimes( key )
	if DEBUG_SERVICES then
		return 0
	end
	if not callTimesMap[key] then
		callTimesMap[key] = 0
	end
	callTimesMap[key] = callTimesMap[key] +1
end

local callCostTimemap = {}
function GameStatistics:costTimeBegin( key )

	if DEBUG_SERVICES and (not IS_LOCAL_RUN_BATTLE) then
		return 0
	end

	if not callCostTimemap[key] then
		callCostTimemap[key] = {cost =0,run = 0 }
	end
	return TimeControler:getTempTime()
end

function GameStatistics:costTimeEnd( key,startTime )
	if DEBUG_SERVICES and (not IS_LOCAL_RUN_BATTLE)  then
		return 
	end
	local dis = TimeControler:getTempTime() - startTime
	callCostTimemap[key].cost = callCostTimemap[key].cost + dis
	callCostTimemap[key].run = callCostTimemap[key].run+1
end

function GameStatistics:dumpStatitistice(  )
	for k,v in pairs(callCostTimemap) do
		print(k,v.run,v.cost,"__funcCostTime")
	end
	
	for k,v in pairs(callTimesMap) do
		print(k,v,"funcRunNum")
	end

end

function GameStatistics:clearStatistics( )
	callCostTimemap = {}
	callTimesMap = {}
end


return GameStatistics