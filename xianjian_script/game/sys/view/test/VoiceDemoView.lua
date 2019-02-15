local VoiceDemoView = class("VoiceDemoView", UIBase);

function VoiceDemoView:ctor(winName)
    VoiceDemoView.super.ctor(self, winName);
end

function VoiceDemoView:loadUIComplete()
	self:registerEvent();

    -- 此处为演示，SDK初始化，适合在玩家登陆成功后调用
    VoiceSdkHelper:init()
    
    -- -- 设置语音模式
    VoiceSdkHelper:setMode(VoiceSdkHelper.VOICE_MODE.Translation)

  	local callBack = function()
  		self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame,self),0)
  	end
    
    self:delayCall(callBack, 1 / 30)
    self:updateUI()
end 

function VoiceDemoView:updateFrame()
	-- 必须每帧调用
	VoiceSdkHelper:update()
end

function VoiceDemoView:registerEvent()
	self.txt_key:setTouchedFunc(c_func(self.onClickAuthKey,self))
	self.txt_recrod:setTouchedFunc(c_func(self.onClickRecrod,self))

	self.txt_upload:setTouchedFunc(c_func(self.onClickUpload,self))
	self.txt_download:setTouchedFunc(c_func(self.onClickDownload,self))
	self.txt_play:setTouchedFunc(c_func(self.onClickPlay,self))

	self.txt_stt:setTouchedFunc(c_func(self.onClickSTT,self))

	EventControler:addEventListener(VoiceSdkHelper.EVENT_UPLOAD_RECORD_DONE,self.onUploadDone,self)
	EventControler:addEventListener(VoiceSdkHelper.EVENT_DOWNLOAD_RECORD_DONE,self.onDownloadDone,self)
	EventControler:addEventListener(VoiceSdkHelper.EVENT_STT_DONE,self.onSTTDone,self)
end

-- 上传完成回调
function VoiceDemoView:onUploadDone(event) 
	echo("voice-上传回调")
	if event then
		local params = event.params
		local fileID = params.fileID 
		local filePath = params.filePath 
		echo("上传 voice-result ==",fileID)
		echo("上传 voice-filePath ==",filePath)
		dump(params,"params-------------")
		self.fileID = fileID

		if fileID then
			self.txt_content:setString("上传成功 fileID=" .. fileID)
		else
			self.txt_content:setString("上传失败")
		end
	end
end

-- 下载完成回调
function VoiceDemoView:onDownloadDone(event) 
	echo("voice-下载回调")
	if event then
		local params = event.params
		local fileID = params.fileID 
		local filePath = params.filePath 
		echo("voice- fileID==",fileID)
		echo("voice- filePath==",filePath)

		if fileID then
			self.txt_content:setString("下载成功 filePath=" .. filePath)
		else
			self.txt_content:setString("下载失败")
		end
	end
end

-- 翻译完成回调
function VoiceDemoView:onSTTDone(event) 
	echo("voice-翻译回调")
	if event then
		local params = event.params
		local content = params.content 
		echo("voice-content ==",content)
		self.txt_content:setString(content)

		if content then
			self.txt_content:setString(content)
		else
			self.txt_content:setString("翻译失败")
		end
	end
end

-- sdk初始化时已经调用该接口，具体业务中不必再调用
function VoiceDemoView:onClickAuthKey()  
	echo("voice-onClickAuthKey")
	self.txt_content:setString("AuthKey...")

	VoiceSdkHelper:applyMessageKey(6000)
end

-- 开始录音
function VoiceDemoView:onClickRecrod()  
	echo("voice-onClickRecrod")
	self.isRecord = not self.isRecord
	if self.isRecord then
		self.txt_recrod:setString("停止录音")
		self.txt_content:setString("开始录音...")

		-- local filePath = "/sdcard/aa/audio.dat"
		-- 音频文件名称根据具体业务进行规划
		local filePath = cc.FileUtils:getInstance():getWritablePath() .. "audio.dat"

		echo("voice-filePath=",filePath)
		VoiceSdkHelper:startRecording(filePath)

		self.filePath = filePath
	else
		self.txt_recrod:setString("录音")
		self.txt_content:setString("停止录音...")

		VoiceSdkHelper:stopRecording()

		local rt = cc.FileUtils:getInstance():isFileExist(self.filePath)
		echo("voice------文件是否存在",rt)
	end
end

-- 开始上传文件
function VoiceDemoView:onClickUpload()  
	echo("voice-上传")
	self.txt_content:setString("开始上传...")

	VoiceSdkHelper:uploadRecordedFile(self.filePath)
end

-- 开始下载文件
function VoiceDemoView:onClickDownload()  
	echo("voice-下载")
	self.txt_content:setString("开始下载...")

	-- 音频文件名称根据具体业务进行规划
	local filePath = cc.FileUtils:getInstance():getWritablePath() .. "audio2.dat"
	VoiceSdkHelper:downloadRecordedFile(self.fielID,filePath)
end

-- 开始播放文件
function VoiceDemoView:onClickPlay()  
	echo("voice-播放")
	self.txt_content:setString("开始播放...")

	VoiceSdkHelper:playRecordedFile(self.filePath)
end

-- 开始翻译
function VoiceDemoView:onClickSTT()  
	echo("voice-翻译")
	self.txt_content:setString("开始翻译...")
	echo("voice-self.fileID=","!" .. self.fileID .. "!")
	VoiceSdkHelper:speechToText(self.fileID)
end

function VoiceDemoView:updateUI()  

end

return VoiceDemoView;
