

--[[
剧情编辑器的特效
]]


AnimModelEffect = class("AnimModelEffect", AnimModelBasic)




--[[

]]
function AnimModelEffect:ctor(controler,view)
	AnimModelEffect.super.ctor(self)
    self.timeSwitch = true
    self.circleNum = 0
	self:initView(view,0,"effect")
end

--[[
一处特效
]]
function AnimModelEffect:deleteMe()
    self.view:deleteMe()
end

-- 特效计时开关
function AnimModelEffect:setTimeSwitch(isOpen)
    self.timeSwitch = isOpen 
end

--[[
	
]]
function AnimModelEffect:playLabel(label,isCircle,totalFrame)
	
    self.effectCircle = tonumber(isCircle) 
	self.stopTotalFrame = tonumber(totalFrame)
	if self.effectCircle == 1 then
		self.view:playLabel(label)
		self.labelAllFrame = self.view:getTotalFrames(label)
		local _func = function ( ... )

			local playFrameNum = self.currentFrame
			if self.stopTotalFrame > 0 and playFrameNum >= self.stopTotalFrame then
				self.view:visible(false)
			else
				self:delayCall(c_func(self.playLabel,self,label,isCircle,totalFrame), self.labelAllFrame/GameVars.GAMEFRAMERATE)
				-- self:playLabel(label,isCircle,totalFrame)
			end
			-- echoError("self.circleNum == ",self.circleNum,"  self.labelAllFrame ==",self.labelAllFrame," self.stopTotalFrame == ",self.stopTotalFrame)
			-- echo("playFrameNum == ",playFrameNum)
		end
		_func()
	else
		self.view:playLabel(label, false, true)
		self.labelAllFrame = self.view:getTotalFrames(label)
	end
end

function AnimModelEffect:deleteMe()
	self.view:deleteMe()
end

--[[
更新每一帧
判断如果动画播放完成，不是stand or walk 则只播放一次
self.cfgData中可以读取到对应的方法属性
]]
function AnimModelEffect:updateFrame(currentFrame)
	self.currentFrame = currentFrame or 0
    if self.stopTotalFrame and self.stopTotalFrame > 0 
    	and self.stopTotalFrame <= self.currentFrame 
    	and self.effectCircle and self.effectCircle == 1 then
        self.view:visible(false)
    end
	-- if self.curFrame == self.totalFrame then
	-- 	local label
	-- 	if tonumber(self.effectCircle) == 1 then
	-- 		if self.stopTotalFrame == 0 then -- 不停止
	-- 			label = self.label
 --            	self:playLabel(label,self.effectCircle,self.stopTotalFrame,self.allFrame)
	-- 		else
	-- 			if self.stopTotalFrame <= self.allFrame then
	-- 				self.curFrame = 0
	-- 				self.view:visible(false)
	-- 			else
	-- 				label = self.label
 --            		self:playLabel(label,self.effectCircle,self.stopTotalFrame,self.allFrame)
	-- 			end
	-- 		end
 --        else
 --            self.curFrame = 0
 --            if self.stopTotalFrame == 0 then
 --            	self.view:visible(false)
 --            end
	-- 	end
		
	-- else
	-- 	self.curFrame = self.curFrame + 1
 --        if self.timeSwitch then
 --            self.allFrame = self.allFrame + 1
 --            if self.stopTotalFrame <= self.allFrame and self.stopTotalFrame > 0 then
	-- 			-- echoError("-----------",self.allFrame,"=====self.stopTotalFrame====",self.stopTotalFrame)
	-- 			self.curFrame = 0
	-- 			self.view:visible(false)
	-- 		end
 --        end
	-- end
end
return AnimModelEffect

