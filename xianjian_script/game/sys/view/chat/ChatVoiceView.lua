-- ChatVoiceView
-- wk
-- time  ： 2017/09/22/10:00
--语音界面  


local ChatVoiceView = class("ChatVoiceView", UIBase)


function ChatVoiceView:ctor(winName)
    ChatVoiceView.super.ctor(self, winName)
    self.sumtime = FuncChat.voiceTalkTime() * 30
    self.started = false
    self.timeNum = 0  ---默认初始化时间是0秒


end


function ChatVoiceView:loadUIComplete()
    self:registerEvent()
    self:addGrayCircle()
    self:scheduleUpdateWithPriorityLua(c_func(self.updateVoiceTime, self) ,0)

end
function ChatVoiceView:addGrayCircle()
	local sprite =  display.newSprite(FuncRes.iconQuest("task_progress_jindu1.png"))
   	self.circleProgress = display.newProgressTimer(sprite,0)
   	local _ctn = self.panel_1.ctn_kai
    _ctn:addChild(self.circleProgress)
    -- self.circleProgress:size(_ctn.ctnWidth, _ctn.ctnHeight);
   	local size = self.circleProgress:getContentSize()
    self.circleProgress:setPercentage(100)
    self.circleProgress:setScaleY(_ctn.ctnHeight/size.height)
    self.circleProgress:setScaleX(-(_ctn.ctnWidth/size.height))
end

--开始录音
function ChatVoiceView:startedTiming(select)
	self.select = select
	self.started = true
	ChatServer:startRecording()
end

--结束录音发送
function ChatVoiceView:endTiming(selectType)
	local sendtime =  self.timeNum - FuncChat.shortestSendTime() * 30
	ChatServer:stopRecording()  ---停止录音
	if sendtime < 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_chat_015"));
		self.started = false
		self.timeNum = 0
		return false
	end
	echo("=======---停止录音 ----==========")
	WindowControler:globalDelayCall(function ()
		ChatServer:onClickUpload(math.floor(self.timeNum/30),selectType)  --上传录音文件
		self.timeNum = 0
	end,0.2)
	
	-- ChatServer:sendRecording(math.floor(self.timeNum/30),nil,selectType)
	-- WindowControler:showTips("发送成功");
	self.started = false
	return true
end

--移动结束不发送
function ChatVoiceView:moveEndSendVoice()
	self.started = false
	self.timeNum = 0
	ChatServer:stopRecording()

end

function ChatVoiceView:updateVoiceTime()
 	if not self.started then
 		return 
 	end

 	self.timeNum = self.timeNum + 1

 	if self.timeNum >= FuncChat.voiceTalkTime()* GameVars.GAMEFRAMERATE then
 		-- ChatServer:sendRecording(math.floor(self.timeNum/30),nil,self.select)
 		ChatServer:stopRecording()  ---停止录音
		ChatServer:onClickUpload(math.floor(self.timeNum/30),self.select)  --上传录音文件
 		self.started = false
 		self.timeNum = 0
 		EventControler:dispatchEvent(ChatEvent.REMOVE_VOICE_UI)
 		return 
 	end
 	local percen = self:tiemToAngle()
 	self.circleProgress:setPercentage(100 - percen)
end 
function ChatVoiceView:tiemToAngle()
	if self.timeNum >= FuncChat.voiceTalkTime() * GameVars.GAMEFRAMERATE then
		self.timeNum = FuncChat.voiceTalkTime() * GameVars.GAMEFRAMERATE
	end
	return  (self.timeNum * 100)/(FuncChat.voiceTalkTime() * GameVars.GAMEFRAMERATE)
end

 
function ChatVoiceView:registerEvent()
    -- EventControler:addEventListener(ChatEvent.REMOVE_VOICE_UI, self.clickButtonClose, self)

end 
function ChatVoiceView:updateCombineState()
 
end 
function ChatVoiceView:clickButtonClose()
    self:startHide()
end


function ChatVoiceView:deleteMe()
    ChatVoiceView.super.deleteMe(self)
end

return ChatVoiceView  

