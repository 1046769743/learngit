-- ChatShareControler
--
-- Author: wukai
-- Date: 2017-05-18 18:49
--

--通知管理
local ChatShareControler = ChatShareControler or  {}
ChatShareControler.ChatSharetype = {
	CHAT_TYPE_TEXT = 1, --聊天 
	CHAT_TYPE_GARMENT = 2, --时装
	CHAT_TYPE_PARTNER = 3,--伙伴
	CHAT_TYPE_PVP = 4, --战报
	CHAT_TYPE_PARTNER_SKIN = 5,   ---伙伴皮肤
}
ChatShareControler.Chatsubtypes = {
    system = 1, ---系统
	world = 2, --世界
	guild = 3, --公会
	friend = 4,  --好友
	private = 5, --私聊

}

ChatShareControler.sendChattypes = {
	sendchat= 1,
	sendgarment = 2, --时装
	sendpartner = 3, --伙伴
	sendpartnerskin = 5, -- 伙伴时装
	sendpvp = 4,  --战报

}
---数据格式
--[[
	data = {
		_type = ChatShareControler.ChatSharetype.CHAT_TYPE_TEXT,  ---类型
		subtypes = 1,2,3,  ----世界，公会，好友列表
		data = {  id = 1001 }  ---替换1001
	}

]]

function ChatShareControler:iniData()
	if device.platform == "windows" or device.platform =="mac" then
		return 
	end
	
	VoiceSdkHelper:initVoiceSdk()
    -- 多人语音
    EventControler:addEventListener(VoiceSdkHelper.EVENT_JOIN_ROME_SUCCESS,self.updateMulityVoice,self)
    -- 加入房间超时
    EventControler:addEventListener(VoiceSdkHelper.EVENT_JOIN_ROME_TIMEOUT,self.jointRoomTimeOut,self)
    -- 加入房间其他错误
    EventControler:addEventListener(VoiceSdkHelper.EVENT_JOIN_ROME_ERROR,self.jointRoomError,self)
	-- 退出房间成功
    EventControler:addEventListener(VoiceSdkHelper.EVENT_QUIT_ROME_SUCCESS,self.quitRoomSucc,self)


 	if not self.tempNode then
		local scene = WindowControler:getCurrScene()
		self.tempNode = display.newNode():addto(scene._topRoot)
	end
    self.tempNode:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0) 
end
function ChatShareControler:jointRoomTimeOut(event)
	-- echo ("加入房间超时")
	self:joinRealTimeRoom()
end
function ChatShareControler:jointRoomError( event )
	-- echo ("加入房间错误")
	self:joinRealTimeRoom()
end
function ChatShareControler:quitRoomSucc( )
	-- echo ("退出房间成功")
end
function ChatShareControler:updateFrame()
    -- 必须每帧调用
    VoiceSdkHelper:update()
    -- echo("语音----必须每帧调用")
end


-- function ChatShareControler:updateFrame()
--     -- 必须每帧调用
--     VoiceSdkHelper:update()
-- end

function ChatShareControler:SendPlayerShareGood(_data)
	-- dump(_data,"11111111111111111111111111")
	if _data == nil then
		echo("===========该数据是 nil==============")
		return
	end
	ChatModel:getfriendData()
	EventControler:dispatchEvent(ChatEvent.CHAT_SHARE_EVENT,_data)

end
--接收到一个通知
function ChatShareControler:receivenNotify()

	local  eventName = NotifyEvent[tostring(notify.method)]
	local result = notify.result
	
	--echo("获取一条通知-----:",notify.method,eventName)
	--dump(notify)
	
	--如果对应了 通知名称  那么 发送这个通知出去 
	if eventName then
		EventControler:dispatchEvent(eventName,notify)
	end

	--如果有pushId  那么必须给一个反馈

end


function ChatShareControler:getGuildNotlineData(callback)
	 local isaddGuild = GuildModel:isInGuild()
    if not isaddGuild then
        return 
    end
	local function _callback( _param )
		-- dump(_param.result,"公会离线列表数据",8)
		if _param.result ~= nil then
			local contdata = _param.result.data.data
			if ChatModel.leagueMessage ~= nil  and table.length(ChatModel.leagueMessage) ~= 0 then
				for k,v in pairs(contdata) do
					local ishave = false
					if ChatModel.leagueMessage ~= nil then
						for key,valuer in pairs(ChatModel.leagueMessage) do
							if valuer.time == v.time then
								ishave = true
							end
						end
					end
					if not ishave then
						table.insert(ChatModel.leagueMessage,v)
					end
				end
			else
				ChatModel.leagueMessage = contdata or {}
			end
		end
		self.getGuilddata = true
		if callback then
			callback()
		end
	end

	if self.getGuilddata then
		if callback then
			callback()
		end
		return 
	end
	local param = {}
	ChatServer:sendgetGuildNotline(param,_callback)
end

-- **************  多人语音相关
local RealState = {
	open=1, --开启状态
	connect=2, --链接状态
	close = 3 --关闭状态
}

-- 退出实时语音
function ChatShareControler:closeRealTimeVoice( ... )
	if device.platform == "windows" or device.platform =="mac" then
		return 
	end
	VoiceSdkHelper:quitRealTimeMode()
end
-- 加入语音房间(roomId= battleId)
function ChatShareControler:joinRealTimeRoom( roomId )
	if device.platform == "windows" or device.platform =="mac" then
		return 
	end
	self._realState = RealState.open
	VoiceSdkHelper:setRealTimeMode()
	echo ("进入房间开始实时语音",roomId,self._receRoodId)
	if roomId then
		VoiceSdkHelper:joinTeamRoom(roomId)
		self:resetRECE(roomId)
		return
	end
	-- 尝试重连五次
	if self._receRoodId and self._receNum < 5 then
		self._receNum = self._receNum + 1
		VoiceSdkHelper:joinTeamRoom(self._receRoodId)
		echo("重连语音房间===",self._receRoodId,self._receNum,self._realState)
	else
		self:resetRECE()
	end
end
function ChatShareControler:resetRECE(roomId)
	self._receRoodId = roomId
	self._receNum = 0
end
-- 退出语音房间
function ChatShareControler:quitRealTimeRoom( roomId )
	if device.platform == "windows" or device.platform =="mac" then
		return 
	end
	self._realState = RealState.close
	VoiceSdkHelper:quitRoom(roomId)
	self:closeRealTimeVoice()
	echo  ("退出多人语音房间",roomId)
	VoiceSdkHelper:resetVoicemode(  )
end
-- 打开或关闭麦克风或者喇叭
function ChatShareControler:updateMicOrSpeak(_t,b )
	if device.platform == "windows" or device.platform =="mac" then
		return 
	end
	if self._realState ~= RealState.connect then
		-- echo("状态不对===",self._realState)
		return
	end
	if _t == 1 then
		-- 麦克风
		if b then
			VoiceSdkHelper:openMic()
		else
			VoiceSdkHelper:closeMic()
			VoiceSdkHelper:resetVoicemode(  )
		end
	elseif _t == 2 then
		if b then
			VoiceSdkHelper:openSpeaker()
		else
			VoiceSdkHelper:closeSpeaker()
			VoiceSdkHelper:resetVoicemode(  )
		end
	end
end

-- 收到实时语音进入房间结束后成功后再调用打开或者关闭麦克风
function ChatShareControler:updateMulityVoice( event )
	self._realState = RealState.connect
	self:resetRECE()

    -- 先将所有的玩家调用一次打开麦克风，然后再根据保存的值设置对应的麦克风和听筒状态
	-- self:updateMicOrSpeak(1,true)
	-- self:updateMicOrSpeak(2,true)
    if self.tempNode then
	    self.tempNode:delayCall(function( )
	    	self:updateMicOrSpeak(1,true)
	        local micFrame = tonumber(LS:prv():get(StorageCode.realTime_mic, 1))
	        if micFrame == 2 then
	        	self.tempNode:delayCall(function( )
	        		self:updateMicOrSpeak(1,false)
	        	end,1)
	        end
	    end, 2)
	    self.tempNode:delayCall(function( )
	    	self:updateMicOrSpeak(2,true)
	        local staFrame = tonumber(LS:prv():get(StorageCode.realTime_voice, 1))
	        if staFrame == 2 then
	        	self.tempNode:delayCall(function( )
		        	self:updateMicOrSpeak(2,false)
	        	end,1)
	        end
	    end, 4)
    end

	-- echoError ("语音房间创建成功====话筒：",micFrame," 听筒:",staFrame," 状态")
    -- 先将所有的玩家调用一次打开麦克风，然后再根据保存的值设置对应的麦克风和听筒状态
	-- self:updateMicOrSpeak(1,true)
	-- self:updateMicOrSpeak(2,true)
    
end


return ChatShareControler
