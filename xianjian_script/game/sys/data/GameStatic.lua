--存储服务器返回来的一些设置
--
local data = {
	--some local key settings
	debugMode = false, 
	displayErrorBoard = false, --如果错误码没有对应的translate，是否弹出error_code
	kakuraHeartBeatSecend = 30, 
	battleReportVersion = 1, 	--战斗版本号 
	onLineUserHeart = 30 * 60 * 30,		--获取在线用户的心跳间隔 以帧为单位 半小时
	honorNpcPosFreshTime = 5,       ---六界结算刷新总时间
	playerOnlineTime = 3*60,           -- 聊天好友在线请求    
} 

local GameStatic = table.deepCopy(data)
GameStatic._local_data = data

--屏蔽的开关 需要在初始化函数里面去配置
GameStatic.onOffCfgs = {
	--测试时示例
	-- system = {"trail", "bag"}, 		--屏蔽的系统
	-- op = {319}, 			--屏蔽的op
	-- activity = {},  	--屏蔽的活动id
}

function GameStatic:init(  )
	--[[
		system/op/activity 三种配置协议格式如下：
		'hide_op_6001' =>
		  array (
		    'type' => 'bool',
		    'default' => true,
		    'desc' => '功能描述',
		    'createUser' => '',
		    'createTime' => '2016-08-16 15:49:11',
		    'updateUser' => '',
		    'updateTime' => '2016-08-16 15:49:11',
		  ),

		common配置协议格式如下：
		'skip_prologue' =>
		  array (
		    'type' => 'String',
		    'default' => 'configs_dev;200;300;',
		    'desc' => '序章控制哪些版本跳过功能',
	  	),
	--]]
	self.onOffCfgs = {
		--各个系统负责人在这里做屏蔽测试
		system = { }, 		--屏蔽的系统
		op = {}, 			--屏蔽的op
		activity = {},  	--屏蔽的活动id
		common = {},		--一些通用的key/value结构的数据
	}
end

--[[
	是否是AppStore审核期间
]]
function GameStatic:isInAppStoreReview()
	local isOpen = 	self.onOffCfgs.common["appstore_review"]

	if device.platform == "mac" or device.platform == "windows" then
		if isOpen or DEBUG_APP_STORE_REVIEW then
			return true
		end
	elseif device.platform == "ios" then
		if isOpen then
			return true
		end
	end

	return false
end

--[[
	检查问卷调查是否关闭
]]
function GameStatic:checkQuestionnaireClosed()
	if FORCE_CLOSE_QUEST then
		return true
	end

	local isClosed = false
	if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.QUESTION) then
		isClosed = true
		return isClosed
	end

	if self:checkClosedByVersion("close_question") then
		isClosed = true
	end

	if self:checkOpenByChannel("open_question") then
		isClosed = false
	end
	
	return isClosed
end

--[[
	检查分享系统是否关闭
]]
function GameStatic:checkShareClosed()
	local isClosed = false
	if self:checkClosedByVersion("close_share") then
		isClosed = true
	end

	if self:checkOpenByChannel("open_share") then
		isClosed = false
	end

	return isClosed
end

--[[
	通过渠道控制是否打开系统
]]
function GameStatic:checkOpenByChannel( key )
	local channelName = AppInformation:getChannelName()
	local isOpen = false

	-- 判断是否打开分享系统
	local channelStr = 	self.onOffCfgs.common[key]
	if channelStr then
		local channelArr = {}
		if string.find(channelStr, ";") then
			channelArr = string.split(channelStr,';')
		else
			channelArr[#channelArr+1] = channelStr
		end

		for i=1,#channelArr do
			if tostring(channelName) == tostring(channelArr[i]) then
				isOpen = true
				break
			end
		end
	end

	return isOpen
end

--[[
	通过版本控制是否关闭系统
]]
function GameStatic:checkClosedByVersion( key )
	local version = AppInformation:getVersion()
	-- 默认不关闭
	local isClosed = false
	-- 关闭分享的版本号
	local versionStr = self.onOffCfgs.common[key]
	-- 判断是否关闭分享系统
	if versionStr then
		local versionArr = {} 
		if string.find(versionStr, ";") then
			versionArr = string.split(versionStr,';')
		else
			versionArr[#versionArr+1] = versionStr
		end

		for i=1,#versionArr do
			if tostring(version) == tostring(versionArr[i]) then
				isClosed = true
				break
			end
		end
	end

	return isClosed
end

--判断某个opcode是否关闭
function GameStatic:checkOpCodeClosed( opCode )
	if table.find(self.onOffCfgs.op,opCode) then
		echoWarn("___这个opCode被系统禁掉了",opCode)
		return  true
	end
	return false
end

--判断某个系统是否关闭
function GameStatic:checkSystemClosed( systemName )
	if table.find(self.onOffCfgs.system,systemName) then
		echoWarn("___这个systemName被系统禁掉了",systemName)
		return  true
	end
	return false
end

--判断某个活动是否关闭
function GameStatic:checkActivityClosed( activity )
	if table.find(self.onOffCfgs.activity,activity) then
		echoWarn("___这个activity被系统禁掉了",activity)
		return  true
	end
	return false
end


--合并globalser里面的开关
function GameStatic:mergeVMSData(data )
	--先做一次初始化
	-- self:init()
	if not data or type(data) ~="table" then
		return
	end

	--截取
	for i,v in pairs(data) do
		local index = string.find(i, "hide_")
		if index ~= nil then
			local keyArr = string.split(i, "_")
			--必须是隐藏的 而且值为true
			if keyArr[1] == "hide" and v == true then
				if keyArr[2] == "system" then
					if keyArr[3] then
						table.insert(self.onOffCfgs.system, keyArr[3])
					end
				elseif keyArr[2] == "op" then
					if keyArr[3] then
						table.insert(self.onOffCfgs.op, tonumber( keyArr[3] ) )
					end

				elseif keyArr[2] == "activity" then
					if keyArr[3] then
						table.insert(self.onOffCfgs.activity, keyArr[3])
					end
				end
			end
		else
			self.onOffCfgs.common[i] = v
		end
	end

	-- dump(self.onOffCfgs,"__onOffCfgs")

end

--合并服务器配置
function GameStatic:mergeServerData(serverStaticData)
	table.deepMerge(self, serverStaticData)
end

function GameStatic:cleanStaticDataCache()
	for k,v in pairs(self) do
		if k ~= "_local_data" and type(v) ~= "function" then
			self[k] = nil
		end
	end
end

function GameStatic:restoreOriginData()
	self:cleanStaticDataCache()
	table.deepMerge(self, data)
end

function GameStatic:doPatch( str )
	if not str then
		self:updateOnOff()
		return
	end

	echo("执行patch")
	local s = loadstring(str)
	if s then
		s()
	else
		echoError("patch 失败-----",str)
	end

	self:updateOnOff()
end

function GameStatic:updateOnOff(  )
	--初始化时间控制器
    if DEBUG_LOGVIEW then
        FuncCommUI.addLogsView()
    end
    if DEBUG_GMVIEW then
        FuncCommUI.addGmEnterView()
    end
	local sharedDirector = cc.Director:getInstance()
	if DEBUG_FPS then
	    sharedDirector:setDisplayStats(true)
	else
	    sharedDirector:setDisplayStats(false)
	end
end


GameStatic:init()

return GameStatic
