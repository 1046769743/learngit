--[[
	Author: 张燕广
	Date:2017-10-11
	Description: 语音sdk工具类
]]

VoiceSdkHelper = {}

-- 语音模式
VoiceSdkHelper.VOICE_MODE = {
	RealTime = 0,   --实时模式,realtime mode for TeamRoom or NationalRoom
	Messages = 1,   --离线消息模式,voice message mode
	Translation = 2 --翻译模式,speach to text mode
}

-- 语音sdk相关消息
-- 录音失败-可能是没有权限
VoiceSdkHelper.EVENT_RECORD_FAIL = "VoiceSdkHelper.EVENT_RECORD_FAIL"

-- 上传完成消息
VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE = "VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE"
-- 下载完成消息
VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE = "VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE"
-- 翻译完成消息
VoiceSdkHelper.EVENT_STT_DONE = "VoiceSdkHelper.EVENT_STT_DONE"
-- 播放完成消息
VoiceSdkHelper.EVENT_PLAYFILE_DONE = "VoiceSdkHelper.EVENT_PLAYFILE_DONE"

-- 实时语音消息
-- 加入房间成功
VoiceSdkHelper.EVENT_JOIN_ROME_SUCCESS = "VoiceSdkHelper.EVENT_JOIN_ROME_SUCCESS"
-- 加入房间超时
VoiceSdkHelper.EVENT_JOIN_ROME_TIMEOUT = "VoiceSdkHelper.EVENT_JOIN_ROME_TIMEOUT"
-- 加入房间其他错误
VoiceSdkHelper.EVENT_JOIN_ROME_ERROR = "VoiceSdkHelper.EVENT_JOIN_ROME_ERROR"

-- 退出房间成功
VoiceSdkHelper.EVENT_QUIT_ROME_SUCCESS = "EVENT_QUIT_HOME_SUCCESS"
-- 房间中成员状态变化
VoiceSdkHelper.EVENT_ROME_MEMBER_CHANGE = "EVENT_ROME_MEMBER_CHANGE"

-- 语言接口执行结果
VoiceSdkHelper.ACTION_SUCCESS = 1
VoiceSdkHelper.ACTION_FAIL = 0
-- 比如无权限导致的报错等
VoiceSdkHelper.ACTION_ERROR = -1

-- 接口行为编码
VoiceSdkHelper.ACTION_CODE = {
	GV_ON_JOINROOM_SUCC = 1,		--加入房间成功
	GV_ON_JOINROOM_TIMEOUT = 2,  	--加入房间失败
	GV_ON_JOINROOM_SVR_ERR = 3,  	--加入房间通信失败
	GV_ON_JOINROOM_UNKNOWN = 4, 	--加入房间未知错误

	GV_ON_NET_ERR = 5,  			--加入房间网络错误

	GV_ON_QUITROOM_SUCC = 6, 		--退出房间成功

	GV_ON_UPLOAD_RECORD_DONE = 11,		--上传成功
	GV_ON_UPLOAD_RECORD_ERROR = 12,		--上传出错(一般是指上传过程中失败)

	GV_ON_DOWNLOAD_RECORD_DONE = 13,	--下载成功
	GV_ON_DOWNLOAD_RECORD_ERROR = 14,	--下载出错

	GV_ON_STT_SUCC = 15, 				--翻译成功,speech to text successful
    GV_ON_STT_TIMEOUT = 16, 			--翻译超时,speech to text with timeout
    GV_ON_STT_APIERR = 17, 				--翻译服务器出错,server's error

	GV_ON_PLAYFILE_DONE = 18,  			--播放结束,the record file played end

	GV_ROOM_MEMBER_STATUS = 31,			--房间中成员状态

	GV_ON_RECORD_FAIL = 32,				--录制失败

	GV_ON_UPLOAD_FILE_ERROR = 33,		--上传语音文件出错(一般是指录制的文件有问题，可能是无录音权限)
}

-- 文本翻译语言
VoiceSdkHelper.LANGUAGE ={
    China       = 0,
    Korean      = 1,
    English     = 2,
    Japanese    = 3
};

-- 实时语音，成员角色类型
VoiceSdkHelper.MEMBER_ROLE ={
	Anchor = 1,				--主播，既可以发送语音也可以收听语音
	Audience = 2,			--听众，只能收听语音不能发送语音
}

-- SDK引擎回调该方法
function G_AppSDKCallBackFromNative(jsonData)
	echo("voice-jsonData=",jsonData)

	if jsonData == nil or jsonData == "" then
		echoError("G_AppSDKCallBackFromNative jsonData=",jsonData)
		return
	end

	local actionData = nil
	actionData = json.decode(jsonData)
	local code = tonumber(actionData.code)
	echo("voice-code=",code)

	-- 加入房间成功
	if code == VoiceSdkHelper.ACTION_CODE.GV_ON_JOINROOM_SUCC then
		echo("voice-加入房间成功")
		-- {"code":"1","roomName":"cz_test2","memberID":"1"}
		local memberId = actionData.memberID
		local roomName = actionData.roomName
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_JOIN_ROME_SUCCESS
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,roomName=roomName,memberId=memberId})

	-- 加入房间超时
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_JOINROOM_TIMEOUT then
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_JOIN_ROME_TIMEOUT
			,{result = VoiceSdkHelper.ACTION_FAIL})

	-- -- 加入房间失败
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_JOINROOM_SVR_ERR
		or code == VoiceSdkHelper.ACTION_CODE.GV_ON_JOINROOM_UNKNOWN
		or code == VoiceSdkHelper.ACTION_CODE.GV_ON_NET_ERR then
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_JOIN_ROME_ERROR 
			,{result = VoiceSdkHelper.ACTION_FAIL})

	-- 退出房间成功
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_QUITROOM_SUCC then
		echo("voice-退出房间成功")
		local roomName = actionData.roomName

		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_QUIT_ROME_SUCCESS
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,roomName=roomName})

	-- 房间中成员状态
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ROOM_MEMBER_STATUS then
		-- dump(actionData,"voice-data--------")
		-- {"code":"31","count":"1","3":"2"}
		-- count 其他玩家数量
		-- 3:memberID
		-- 2:状态(“0”：停止说话 “1”：开始说话 “2”:继续说话)
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_ROME_MEMBER_CHANGE
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,data=actionData})
	-- 上传成功
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_UPLOAD_RECORD_DONE then
		local fileID = actionData.fileID
		local filePath = actionData.filePath
		echo("voice fileID=",fileID)
		echo("voice filePath=",filePath)
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,fileID=fileID,filePath=filePath})

	-- 上传失败
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_UPLOAD_RECORD_ERROR then
		echo("voice-语音上传失败")
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE
			,{result = VoiceSdkHelper.ACTION_FAIL})

	-- 上传报错
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_UPLOAD_FILE_ERROR then
		echo("voice-语音上传报错")
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE
			,{result = VoiceSdkHelper.ACTION_ERROR})

	-- 下载成功
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_DOWNLOAD_RECORD_DONE then
		local fileID = actionData.fileID
		local filePath = actionData.filePath
		echo("voice fileID=",fileID)
		echo("voice filePath=",filePath)

		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,fileID=fileID,filePath=filePath})

	-- 下载失败
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_DOWNLOAD_RECORD_ERROR then
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE
			,{result = VoiceSdkHelper.ACTION_FAIL})

	-- 翻译成功
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_STT_SUCC then
		local fileID = actionData.fileID
		local content = actionData.content
		echo("翻译 voice content=",content)
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_STT_DONE
			,{result = VoiceSdkHelper.ACTION_SUCCESS ,fileID=fileID,content=content})

	-- 翻译失败
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_STT_TIMEOUT 
		or code == VoiceSdkHelper.ACTION_CODE.GV_ON_STT_APIERR then
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_STT_DONE
			,{result = VoiceSdkHelper.ACTION_FAIL ,fileID=fileID})

	-- 播放完成
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_PLAYFILE_DONE then
		echo("播放完成 voice content")
		local filePath = actionData.filePath
		echo("voice filePath=",filePath)
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_PLAYFILE_DONE
			,{result = VoiceSdkHelper.ACTION_SUCCESS,filePath=filePath})
	-- 录音失败
	elseif code == VoiceSdkHelper.ACTION_CODE.GV_ON_RECORD_FAIL then
		echo("录音失败")
		EventControler:dispatchEvent(VoiceSdkHelper.EVENT_RECORD_FAIL)
	end
end

--延迟一帧恢复语音状态
function VoiceSdkHelper:resetVoicemode(  )
	local tempfunc = function (  )
		PCSdkHelper:setVoicemode( mode )
	end
	WindowControler:globalDelayCall(tempfunc, 0.1)
end


function VoiceSdkHelper:initVoiceSdk()
	local key = "sdk_voice_init"
	if AppHelper:getValue(key) ~= "" then
		return
	end

	-- 此处为演示，SDK初始化，适合在玩家登陆成功后调用
    self:init()
	------ 设置语音模式
    self:setMode(VoiceSdkHelper.VOICE_MODE.Translation)
    AppHelper:setValue(key,"true")
end

--[[
	设置普通模式，离线语音和翻译
]]
function VoiceSdkHelper:setNormalMode()
	self:setMode(VoiceSdkHelper.VOICE_MODE.Translation)
end

--[[
	设置实时模式
]]
function VoiceSdkHelper:setRealTimeMode()
	self:setMode(VoiceSdkHelper.VOICE_MODE.RealTime)
end

--[[
	退出实时模式
]]
function VoiceSdkHelper:quitRealTimeMode()
	self:closeMic()
	self:closeSpeaker()
	self:setNormalMode()
end

-- SDK初始化
function VoiceSdkHelper:init()
	-- echoError("voice-初始化语音sdk111111111")
	-- local appID = "gcloud.test"
	-- local appKey = "test_key"
	-- local openID = "gzyg-dev"

	local appID = "1387800780"
	local appKey = "9ab4554af9d12a7379cba28ad3bf4b95"
	
	local openID = UserModel:rid() or "gzyg-dev"
	-- VoiceSdkHelper:initVoiceSDK("1567082240","c2754341d9a6f1df6f3fbc86bc68c232","gzyg-dev")
	-- AppSDKHelper:initCallBack(G_AppSDKCallBackFromNative)
	VoiceSdkHelper:initVoiceSDK(appID,appKey,openID)
		
	local tempFunc = function (  )
		PCSdkHelper:setVoicemode( 1  )
	end	

	WindowControler:globalDelayCall(tempFunc, 0.3)
end

--[[
	appID:开通业务页面中的游戏ID
	appKey:开通业务页面中的游戏Key
	openID:玩家唯一标示，比如从手Q或者微信获得到的OpenID
		   或者我们业务中的roleID
]]
function VoiceSdkHelper:initVoiceSDK(appID,appKey,openID)
	echo("voice-初始化语音sdk")
	AppSDKHelper:initVoiceSDK(appID,appKey,openID)

	-- 设置语音长度
	local maxLength = 60000
	VoiceSdkHelper:setMaxMessageLength(maxLength)

	-- 音频SDK是否工作状态
	VoiceSdkHelper.isWork = true
end

--[[
	设置音频sdk是否是工作模式，默认是工作模式
	isWork:是否是工作模式，如果离开了音频使用场景(比如关闭了聊天主界面)，可以将工作状态设置为false
]]
function VoiceSdkHelper:setVoiceWork(isWork)
	VoiceSdkHelper.isWork = isWork
end

--[[
	设置语音模式
	mode:VoiceSdkHelper.VOICE_MODE中的枚举值
]]
function VoiceSdkHelper:setMode(mode)
	echo("lua voice-mode=",mode)
	AppSDKHelper:setMode(mode)
end

--[[
	设置最大消息长度
	maxLength:最大消息长度，毫秒，范围[1000, 120*1000]
]]
function VoiceSdkHelper:setMaxMessageLength(maxLength)
	echo("lua setMaxMessageLength =",setMaxMessageLength)
	AppSDKHelper:setMaxMessageLength(maxLength)
end

--[[
	请求消息key
	msTimeout:超时毫秒,范围5000 - 60000
]]
function VoiceSdkHelper:applyMessageKey(msTimeout)
	echo("voice-applyMessageKey")
	msTimeout = msTimeout or 60000
	AppSDKHelper:applyMessageKey(msTimeout)
end

--[[
	开始录制音频
	filePath:录制的音频文件路径
]]
function VoiceSdkHelper:startRecording(filePath)
	echo("voice-startRecording")
	PCSdkHelper:setVoicemode( 2  )
	AppSDKHelper:startRecording(filePath)
end

--[[
	停止录制音频
]]
function VoiceSdkHelper:stopRecording(delay)
	echo("voice-stopRecording")
	AppSDKHelper:stopRecording()

	local tempfunc = function (  )
		PCSdkHelper:setVoicemode( 1  )
	end
	WindowControler:globalDelayCall(tempfunc,0.1)
	
end

--[[
	上传音频文件
	filePath:音频文件路径
]]
function VoiceSdkHelper:uploadRecordedFile(filePath)
	AppSDKHelper:uploadRecordedFile(filePath)
end

--[[
	下载音频文件
	fileID:文件上传成功后生成的唯一ID
	filePath:下载文件保存路径
]]
function VoiceSdkHelper:downloadRecordedFile(fileID,filePath)
	AppSDKHelper:downloadRecordedFile(fileID,filePath)
end

--[[
	播放音频文件
	filePath:音频文件路径
]]
function VoiceSdkHelper:playRecordedFile(filePath)
	PCSdkHelper:setVoicemode( 3  )
	AppSDKHelper:playRecordedFile(filePath)
end

--[[
	停止播放音频
]]
function VoiceSdkHelper:stopPlayFile(delay)
	echo("====停止播放语音=11111111=====",delay)
	local tempfunc = function (  )
		AppSDKHelper:stopPlayFile()
		PCSdkHelper:setVoicemode( 1  )
	end
	if delay then
		WindowControler:globalDelayCall(tempfunc,delay)
	else
		tempfunc()
	end
	
end

--[[
	语音转文本
	fileID:文件上传成功后生成的唯一ID
	msTimeout:翻译超时毫秒，最大600000
	language:翻译的目标语音
]]
function VoiceSdkHelper:speechToText(fileID,msTimeout,language)
	local maxMsTimeout = 600000
	msTimeout = msTimeout or maxMsTimeout
	language = language or VoiceSdkHelper.LANGUAGE.China

	AppSDKHelper:speechToText(fileID,msTimeout,language)
end

--[[
	每帧调用，poll音频sdk消息
]]
function VoiceSdkHelper:update()
	if VoiceSdkHelper.isWork then
		AppSDKHelper:update()
	end
end

--[[
	加入小队语音房间
	roomName:房间名称
	msTimeout:超时毫秒，可选

	加入房间成功后，根据需求openMic/openSpeaker
]]
function VoiceSdkHelper:joinTeamRoom(roomName,msTimeout)
	echo("voice-joinTeamRoom")
	msTimeout = msTimeout or 5000
	AppSDKHelper:joinTeamRoom(roomName,msTimeout)
end

--[[
	加入国战语音房间
	roomName:房间名称
	role:角色类型，见VoiceSdkHelper.MEMBER_ROLE
	msTimeout:超时毫秒，可选

	加入房间成功后，根据需求openMic/openSpeaker
]]
function VoiceSdkHelper:joinNationalRoom(roomName,role,msTimeout)
	echo("voice-joinNationalRoom")

	role = role or VoiceSdkHelper.MEMBER_ROLE.Audience

	msTimeout = msTimeout or 5000
	AppSDKHelper:joinNationalRoom(roomName,role,msTimeout)
end

--[[
	退出语音房间
	roomName:房间名称
	msTimeout:超时毫秒，可选
]]
function VoiceSdkHelper:quitRoom(roomName,msTimeout)
	echo("voice-quitRoom")
	msTimeout = msTimeout or 5000
	AppSDKHelper:quitRoom(roomName,msTimeout)
end

--[[
	打开麦克风，可以发布语音
	1.加入房间成功后再执行
	2.如果是国战模式中的听众角色，不要打开麦克风(听众角色只能收听，不能说话)
]]
function VoiceSdkHelper:openMic()
	echo("voice-openMic")
	AppSDKHelper:openMic()
end

--[[
	关闭麦克风
]]
function VoiceSdkHelper:closeMic()
	echo("voice-closeMic")
	AppSDKHelper:closeMic()
end

--[[
	打开扬声器，可以收听语音
	加入房间成功后再执行
]]
function VoiceSdkHelper:openSpeaker()
	echo("voice-openSpeaker")
	AppSDKHelper:openSpeaker()
end

--[[
	关闭扬声器
]]
function VoiceSdkHelper:closeSpeaker()
	echo("voice-closeSpeaker")
	AppSDKHelper:closeSpeaker()
end

--[[
	测试实时语音
]]
function VoiceSdkHelper:testRealTime()
	self:setRealTimeMode()
	-- self:joinTeamRoom("cz_test2")
	if device.platform == "ios" then
		self:joinNationalRoom("cz_test2",VoiceSdkHelper.MEMBER_ROLE.Anchor)
	elseif device.platform == "android" then
		self:joinNationalRoom("cz_test2",VoiceSdkHelper.MEMBER_ROLE.Anchor)
	end
end

return VoiceSdkHelper
