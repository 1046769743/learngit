--[[
	Author: lcy
	Date:2018.03.26
	Description: 视频播放弹窗（设计为引导使用）
]]

local GuideVideoView = class("GuideVideoView", UIBase);

function GuideVideoView:ctor(winName)
    GuideVideoView.super.ctor(self, winName)

    self._title = "default"
    self._describe = "default"
    self._videoName = "test.mp4"
    self._videoPlayer = nil
end

function GuideVideoView:loadUIComplete()
	self:registerEvent()
	-- self:initData()
	-- self:initViewAlign()
	-- self:initView()
	-- self:updateUI()
	-- self:setUI("1")
end 

function GuideVideoView:registerEvent()
	GuideVideoView.super.registerEvent(self);

	self.btn_1:setTap(c_func(self.playComplete,self))

	self:setMask()
end

-- 创建一个吞噬层
function GuideVideoView:setMask()
	WindowControler:createCoverLayer():addto(self,-2)
end

-- 引导调用
function GuideVideoView:setUI(vId)
	self._title = FuncGuide.getVideoDataByIdAndKey(vId,"title")
	self._describe = FuncGuide.getVideoDataByIdAndKey(vId,"description")
	self._videoName = FuncGuide.getVideoDataByIdAndKey(vId,"video")

	self:updateUI()
end

function GuideVideoView:updateUI()
	local mp4File = "movie/" .. self._videoName

	local videoPlayer = FuncCommUI.createVideoView(self.ctn_1,mp4File,cc.size(590, 280),cc.p(0,0),function(sener, eventType)
		if eventType == FuncCommUI.VideoPlayerEvent.PLAYING then

		elseif eventType == FuncCommUI.VideoPlayerEvent.COMPLETED then
		    self:playComplete() -- 播放完成
		end
	end,false,false)
	
	if videoPlayer then
		videoPlayer:play()
	else
		echoWarn("没有文件或无法创建videoPlayer",mp4File)
		local size = cc.size(590, 280)
		videoPlayer = display.newRect(cc.rect(0, 0,size.width, size.height),
			{fillColor = cc.c4f(1,1,1,0.8), borderColor = cc.c4f(0,1,0,1), borderWidth = 1})
		videoPlayer:pos(-size.width/2,-size.height/2)
		self.ctn_1:addChild(videoPlayer)

		self:delayCall(function()
			self:playComplete()
		end, 10)
	end

	self._videoPlayer = videoPlayer

	self.txt_1:setString(GameConfig.getLanguage(self._title))
	self.txt_3:setString(GameConfig.getLanguage(self._describe))
end

function GuideVideoView:playComplete()
	echo("播放完成")
	EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_VIDEO)
	self:stopAllActions()
	self:deleteVideo()
end

function GuideVideoView:clickClose()
	self:startHide()
end

-- 销毁视频对象
function GuideVideoView:deleteVideo()
	if self._videoPlayer then
		self._videoPlayer:setVisible(false)
		-- 延迟一帧删除
		self:delayCall(function()
			self._videoPlayer:removeFromParent()
			self._videoPlayer = nil
		end,1/GameVars.ARMATURERATE)
	end
end

function GuideVideoView:deleteMe()
	GuideVideoView.super.deleteMe(self);
end

return GuideVideoView;