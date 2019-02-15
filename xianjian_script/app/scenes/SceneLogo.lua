--
-- Author: ZhangYanguang
-- 主场景  游戏logo界面

require("game.sys.view.tutorial.TutorialLayer")

SceneLogo = class("SceneLogo", SceneBase)

function SceneLogo:ctor(...)
	SceneLogo.super.ctor(self, ...)

	self._viewRoot = self.__doc
end

function SceneLogo:onEnter()
    -- SceneLogo.super.onEnter(self)
    
    self:showSDKLogos()
end

-- 掌趣sdk展示logo逻辑
function SceneLogo:showSDKLogos()
	-- 2018.07.09 去掉防沉迷提醒 by ZhangYanguang
	--[[
	self:showGameWarning()

	local hideGameWarning = function()
		self:hideLogoAnim(self.gameWarning,0.5)
	end
	
	-- 防沉迷提醒
	self._viewRoot:delayCall(c_func(hideGameWarning), 2)
	

	-- 进入游戏
	self._viewRoot:delayCall(c_func(self.playMemoryAnim,self),2.5)
	]]

	self:playMemoryAnim()
end

function SceneLogo:showLogos()
	-- 公司logo
	self:showCorpLogo()

	local hideCorpLogo = function()
		self:hideLogoAnim(self.corpLogo,0.5)
	end

	self._viewRoot:delayCall(c_func(hideCorpLogo), 1.5)

	--[[

	-- ip logo
	self._viewRoot:delayCall(c_func(self.showIPLogo,self), 0.5)

	local hideIpLogo = function()
		self:hideLogoAnim(self.ipLogo,0.2)
	end
	
	self._viewRoot:delayCall(c_func(hideIpLogo), 1)
	]]

	-- 2018.07.09 去掉防沉迷提醒 by ZhangYanguang
	--[[
	local hideGameWarning = function()
		self:hideLogoAnim(self.gameWarning,0.5)
	end

	-- 防沉迷提醒
	self._viewRoot:delayCall(c_func(self.showGameWarning,self),2)
	self._viewRoot:delayCall(c_func(hideGameWarning), 4)
	-- 进入游戏
	self._viewRoot:delayCall(c_func(self.playMemoryAnim,self),4.5)
	]]

	self._viewRoot:delayCall(c_func(self.playMemoryAnim,self),2)
end

-- 播放情怀动画
function SceneLogo:playMemoryAnim()
	if self:checkMemoryAnim() then
		FuncArmature.loadOneArmatureTexture("UI_xuzhang", nil, true)
		local anim = FuncArmature.createArmature("UI_xuzhang_01", self._viewRoot, false, GameVars.emptyFunc)
		anim:pos(GameVars.width/2,GameVars.height/2)
		FuncArmature.setArmaturePlaySpeed(anim,0.6)
		anim:registerFrameEventCallFunc(anim.totalFrame, 1, c_func(self.onPlayMemoryAnimEnd,self))		
	else
		self:onPlayMemoryAnimEnd()
	end
end

-- 播放情怀动画结束
function SceneLogo:onPlayMemoryAnimEnd()
	LS:pub():set(StorageCode.star_play_memory_anim, 1)
	self:playCGVideo()
end

-- 播放CG视频
function SceneLogo:playCGVideo()
	if self:checkCGVideo() then
		if (device.platform ~= "ios" and device.platform ~= "android") then
			self._viewRoot:delayCall(c_func(self.onPlayCGVideoEnd,self),1)
			return
		end

		-- WindowControler:showTips("正在播放CG视频，1秒后结束")
		local videoName = "movie/CGVideo.mp4"
		local size = cc.size(GameVars.width,GameVars.height)
		local pos = cc.p(GameVars.width/2,GameVars.height/2)

		local eventCallBack = function(sener, eventType)
            if eventType == 3 or eventType == 4 then
                self:onPlayCGVideoEnd()
            end
        end

		local videoPlayer = FuncCommUI.createVideoView(self._viewRoot,videoName,size,pos,eventCallBack,true,true)
		videoPlayer:play()
	else
		self:onPlayCGVideoEnd()
	end
end

-- 播放CG视频结束
function SceneLogo:onPlayCGVideoEnd()
	LS:pub():set(StorageCode.star_play_cgvideo, 1)
	self:enterGame()
end

-- true表示播放/false表示不播放
function SceneLogo:checkMemoryAnim()
	if DEBUG_FORCE_MOMERY_CG then
		return true
	end
	
	local value = LS:pub():get(StorageCode.star_play_memory_anim, 0)
	return value == 0
end

-- true表示播放/false表示不播放
function SceneLogo:checkCGVideo()
	if DEBUG_SKIP_CG_VIDEO then
		return false
	end

	if DEBUG_FORCE_MOMERY_CG then
		return true
	end

	local value = LS:pub():get(StorageCode.star_play_cgvideo, 0)
	return value == 0
end

-- 公司logo
function SceneLogo:showCorpLogo()
	self.corpLogo = self:showLogoAnim("logo/logo.png",0.2)
end

-- 展示IP logo
function SceneLogo:showIPLogo()
	self.ipLogo = self:showLogoAnim("logo/iplogo.png",0.5)
end

-- 防沉迷提醒
function SceneLogo:showGameWarning()
	self.gameWarning = self:showLogoAnim("logo/zhonggao.png",0.5)
end

-- 隐藏logo动画
function SceneLogo:hideLogoAnim(logoSprite,fadeOutTime)
	local alphaOutAction = act.fadeout(fadeOutTime)
	logoSprite:stopAllActions()
    logoSprite:runAction(
        cc.Sequence:create(alphaOutAction)
    )
end

-- 展示logo动画
function SceneLogo:showLogoAnim(fileName,fadeInTime)
	local logoSprite = display.newSprite(fileName)
	logoSprite:anchor(0.5,0.5)
	logoSprite:opacity(0)
	logoSprite:pos(GameVars.cx,GameVars.cy)
	self._viewRoot:addChild(logoSprite)
	
	local alphaInAction = act.fadein(fadeInTime)
    -- local appearAnim = cc.Spawn:create(alphaInAction) 
    logoSprite:stopAllActions()
    logoSprite:runAction(
        cc.Sequence:create(alphaInAction)
    )

    return logoSprite
end

function SceneLogo:enterGame()
	-- WindowControler:chgScene("SceneMain")
	WindowControler:chgScene("SceneMain");
end

function SceneLogo:onExit()
	SceneLogo.super.onEnter(self)
	FuncArmature.clearOneArmatureTexture("UI_xuzhang",  true)
end

return SceneLogo
