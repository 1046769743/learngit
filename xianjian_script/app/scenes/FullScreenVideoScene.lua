
--
-- User: Zhangyanguang
-- Date: 2015/10/29
-- 游戏全屏视频播放界面

local FullScreenVideoScene = class("FullScreenVideoScene", SceneBase)

function FullScreenVideoScene:ctor()
    self:initData()
end

function FullScreenVideoScene:initData()
	pc.VideoPlayerEvent = {
	    PLAYING = 0,
	    PAUSED = 1,
	    STOPPED= 2,
	    COMPLETED =3,
	    SKIP =4,
	}
	local mp4File = "asset/movie/cocosvideo.mp4"
	local fileUtils = cc.FileUtils:getInstance()
	self.videoFullPath = fileUtils:fullPathForFilename(mp4File)
	print("videoFullPath=",self.videoFullPath)
end

function FullScreenVideoScene:onEnter()
	self:showVideo()
end

-- 播放视频
function FullScreenVideoScene:showVideo()
	if device.platform == "ios" then
		self:initVideoPlayer()
		WindowControler:globalDelayCall(function()
	        self.videoPlayer:createBtn("",cc.c4f(255,0,0,255),"asset/test/skip.png",cc.rect(display.widthInPixels/2 - 120, 50 ,100,100),10);
	    end,0.1)
	elseif device.platform == "android" then
		self:initVideoPlayer()
	end
end

--初始化VideoPlayer
function FullScreenVideoScene:initVideoPlayer()
	local videoPlayer = pc.VideoPlayer:create()
	self.videoPlayer = videoPlayer

    videoPlayer:setPosition(cc.p(display.widthInPixels/2, display.heightInPixels/2))
    videoPlayer:setAnchorPoint(cc.p(0.5, 0.5))
    videoPlayer:setContentSize(cc.size(display.widthInPixels, display.heightInPixels))
    videoPlayer:setKeepAspectRatioEnabled(true)
    videoPlayer:setFullScreenEnabled(true)
    videoPlayer:setVisible(true)

    self:addChild(videoPlayer)

    local function onVideoEventCallback(sener, eventType)
        if eventType == pc.VideoPlayerEvent.PLAYING then
            print("PLAYING")
        elseif eventType == pc.VideoPlayerEvent.SKIP then
            print("SKIP")
            self:skipVideo()
        end
    end

    videoPlayer:addEventListener(onVideoEventCallback)
    videoPlayer:setFileName(self.videoFullPath)
    videoPlayer:play()
end

function FullScreenVideoScene:skipVideo()
	WindowControler:chgScene("SceneMain",false);
end

function FullScreenVideoScene:onExit()
end

return FullScreenVideoScene


