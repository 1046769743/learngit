local MultiStateExpand = class("MultiStateExpand", function()
--设置contentSize0,0 可以修复缩放的bug
	return display.newNode()
end )


--初始化的时候 只用显示空帧
MultiStateExpand.viewFrames = nil 	--装载所有view的数组
MultiStateExpand.totalFrames = 1 	--总帧数
MultiStateExpand.currentView = nil --当前显示的view
MultiStateExpand.currentFrame = nil --当前帧数
function MultiStateExpand:ctor( cfgs,doNothing )
	self.viewFrames = {}
	self.uiCfgs = cfgs
	self.totalFrames = #cfgs[UIBaseDef.prop_frames]


	self.area = cc.size(cfgs[UIBaseDef.prop_width],cfgs[UIBaseDef.prop_height])
	--self.size = cc.size(cfgs[UIBaseDef.prop_width],cfgs[UIBaseDef.prop_height])

	--默认显示第一帧  因为没必要初始化就显示全部 根据程序逻辑来控制 跳到哪一帧
	--如果没有必要dothing 的 那么就不跳帧 这样可以节省效率
	if not doNothing then
		self:showFrame(1)
	end
	
	
end

-- 获得MC 的大小
function MultiStateExpand:getFrameSize()
	return self.area
end

function MultiStateExpand:getTotalFrameNum()
	return self.totalFrames;
end

--获取某一帧的某个属性
function MultiStateExpand:getViewByFrame(frame)
	local lastFrame = self.currentFrame
	self:showFrame(frame)
	local view = self.viewFrames[frame]
	if lastFrame then
		self:showFrame(lastFrame)
	end
	
	return view 
end

function MultiStateExpand:setShowAllFrame(isShowAll)
	self.isShowAll = isShowAll
end

--当前帧界面
function MultiStateExpand:getCurFrameView()
	return self.currentView;
end

--当前是第几帧
function MultiStateExpand:getCurFrame()
	return self.currentFrame
end

--显示某一帧
function MultiStateExpand:showFrame( frame )
	--如果当前帧一样 那么就不用操作了
	if self.currentFrame == frame then
		return
	end

	self.currentFrame = frame
	if self.currentView and not self.isShowAll then
		--那么隐藏当前帧
		self.currentView:visible(false)
	end
	local view = self.viewFrames[frame]
	if not view then
		view = display.newNode()
		local cfgsFrame = self.uiCfgs[UIBaseDef.prop_frames][frame]
		if not cfgsFrame then
			--dump(self.uiCfgs,"MultiStateExpandCfgs")
			echoError("没有找到对应的frame信息:"..tostring(frame))
			frame = 1
			cfgsFrame = self.uiCfgs[UIBaseDef.prop_frames][1]
			self.currentFrame = frame
		end
		UIBaseDef:createChildArr(view,cfgsFrame):addTo(self)
		self.viewFrames[frame] = view
		
	else
		view:visible(true)
	end
	self.currentView = view
end


--下一帧
function MultiStateExpand:nextFrame(  )
	if not self.currentFrame then
		self:showFrame(1)
	else
		if self.currentFrame == self.totalFrames then
			self:showFrame(1)
		else
			self:showFrame(self.currentFrame +1)
		end
	end
end

--上一帧
function MultiStateExpand:lastFrame(  )
	if not self.currentFrame then
		self:showFrame(1)
	else
		if self.currentFrame == 1 then
			self:showFrame(self.totalFrames)
		else
			self:showFrame(self.currentFrame -1)
		end
	end
end

return MultiStateExpand