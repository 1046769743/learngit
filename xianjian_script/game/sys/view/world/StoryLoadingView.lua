local StoryLoadingView = class("StoryLoadingView", UIBase)

local DEFAULT_BG = "bg_denglu.png"

local BG_IMAGES = {
	[2]="bg_denglu.png",
	[3]="bg_denglu.png",
	[4]="bg_denglu.png",
	[5]="bg_denglu.png",
}

function StoryLoadingView:ctor(winName, storyId, processActions, processEndCfunc)

	StoryLoadingView.super.ctor(self, winName)

	self.storyId = storyId


	--self.initTweenPercentInfo = initTweenPercentInfo or {percent=25, frame=20}
	self.processActions = processActions
	self.processEndCfunc = processEndCfunc

end

function StoryLoadingView:setViewAlign()
end

function StoryLoadingView:loadUIComplete()
	self:setViewAlign()
	self:loadAni()

	if #self.processActions>0 then
		self:delayCall(c_func(self.startLoad, self), 1.0/GameVars.GAMEFRAMERATE*20)
	end
end

--[[
加载动画效果
]]
function StoryLoadingView:loadAni()
	self.juanzhouAni = self:createUIArmature("UI_shijieditu", "UI_shijieditu_zhangjiejieshu",self,false,GameVars.emptyFunc)

	self.juanzhouAni:pos(0,GameVars.UIbgOffsetY)
	self.juanzhouAni:getBoneDisplay("juanzhoukai"):playWithIndex(0,false)
	self.juanzhouAni:playWithIndex(0, false,false)

	self.juanzhouAni:delayCall(
		function()
			if #self.processActions>0 then
				if self.loadCompeletFlag then
					--echoError("动画播放完成，并且 加载完成了")
					self:close()
				else
					--echoError("动画播完成但是加载没有玩阿城------")
					self.aniComplete = true
				end
			else
				--echoError("没有加载项，直接关闭")
				--没有加载项，直接关闭
				self:close()
			end

			self:close()

		end
		,(345+20)/GameVars.GAMEFRAMERATE )
end




function StoryLoadingView:initBg(bgImage)
	local bgImagePath = FuncRes.iconBg(bgImage)
	local bgImageSprite = display.newSprite(bgImagePath)
	self._bgImage = bgImage
	FuncCommUI.setBgScaleAlign(bgImageSprite)
	self.ctn_bg:addChild(bgImageSprite)
end

function StoryLoadingView:registerEvent()

end

-- function StoryLoadingView:showRandomTips()
-- 	local tips = FuncLoading.getRandomTips()
-- 	self.txt_random_tips:setString(tips)
-- 	self:delayCall(c_func(self.showRandomTips, self), 3)
-- end

function StoryLoadingView:startLoad()
	local processActions = self.processActions
	local frame = 0
	for _, info in ipairs(processActions) do
	 	if frame  == 0 then
	 		self:tweenToPercentWithAction(info.percent, info.frame, info.action)
	 	else
	 		self:delayCall(c_func(self.tweenToPercentWithAction,self,info.percent, info.frame, info.action), frame/GameVars.GAMEFRAMERATE )
	 	end
	 	frame = frame + info.frame
		
	 end
end

function StoryLoadingView:tweenToPercentWithAction(percent, frame, actionCFunc)
	--echo("播放动画---------")
	local tweenArgs = {percent, frame}
	if percent == 100 then
		local endFunc = c_func(function() 
			if self.aniComplete  then
				--echoError("动画播放完成了-00---要关闭---------")
				self:close()
			else
				--echoError("加载完成--------------")
				self.loadCompeletFlag = true
			end
		end)
		table.insert(tweenArgs, endFunc)
	end

	if actionCFunc then
		--echoError("===执行函数==========")
		actionCFunc()
	end
end



function StoryLoadingView:close()
	--echoError("执行关闭---------------")
	if self.processEndCfunc then
		self.processEndCfunc()
	end
	self:startHide()
end


--[[
章节结束收释放的资源
]]
function StoryLoadingView:deleteMe(  )
	if self._bgImage then
		FuncRes.removeBgTexture(self._bgImage)
	end
	StoryLoadingView.super.deleteMe(self)

end

return StoryLoadingView
