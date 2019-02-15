



--[[
动画编辑器中的bone对象。宝箱对象
这是一个特殊的bone 宝箱 没有相应的配置
]]

AnimModelBox = class("AnimModelBox", 
		AnimModelBasic
	)


--[[

]]
function AnimModelBox:ctor(controler,view)
	

	AnimModelBox.super.ctor(self,controler)
	self:initView(view,0,"bone")


end


--[[
更新每一帧
判断如果动画播放完成

如果宝箱非打开状态都是需要循环的
如果宝箱是打开动作是不需要循环的

]]
function AnimModelBox:updateFrame()
	-- if self.curFrame == self.totalFrame then
	-- 	--local label = Fight.actions.action_stand
	-- 	local label
	-- 	if self:chkNeedLoop() then
			
	-- 		label = self.label
	-- 		--echo("循环-------",self._name,label)
	-- 	else
			
	-- 		label = Fight.actions.action_stand	
	-- 		--echo("不循环，直接站立-----",self._name,label)
	-- 	end
	-- 	self:playLabel(label)
	-- else
	-- 	self.curFrame = self.curFrame +1
	-- end

	if self.curFrame == self.totalFrame then
		self.curFrame = 0
		-- 出现完毕
		if self.label == "activate" then
			self:playLabel("lock", true)
			local func = self._activateCall
			self._activateCall = nil
			if func then func() end
		end
		-- 打开完毕
		if self.label == "open" then
			local func = self._openCall
			self._openCall = nil
			if func then func() end
		end
	else
		self.curFrame = self.curFrame + 1
	end
end

-- 设置出现回调
function AnimModelBox:setActivateCall(func)
	self._activateCall = func
end

-- 设置打开回调
function AnimModelBox:setOpenCall(func)
	self._openCall = func
end

--[[
检测是否需要循环
]]
function AnimModelBox:chkNeedLoop()
	if self.label == Fight.actions.action_stand or 
		self.label == Fight.actions.action_stand2 or
		self.label == Fight.actions.action_run or 
		self.label == Fight.actions.action_race2 or 
		self.label == Fight.actions.action_race3 
	then
		return true
	else
		return false
	end
end


--[[
播放默认动画
默认动画就是 宝箱在抖动  是需要循环播放的
]]
function AnimModelBox:playDefaultLabel()
	if self.state ~= "activate" and self.state ~= "open" and self.state ~="empty" and self.state ~="lock" then
		self.view:playLabel("lock",true,false)
		self.state = "lock"
	end
end

--[[
播放打开宝箱

打开宝箱  不能循环

]]
function AnimModelBox:playOpenBox()
	echo("打开宝箱的动画执行-------")
	if self.state ~= "activate" then
		echo("打开宝箱的动画执行-------2122222222222")
		self:playLabel("open",false,false)
		self.state = "open"
	end
end

-- 宝箱消失
function AnimModelBox:playDisplayBox( callback)	
	self.view:runAction(cc.Sequence:create(
                    act.spawn(
                            act.scaleto(0.5 ,0),
                            act.fadeout(0.5)
                        ),
                    act.callfunc(callback)
                )) 
 -- 	local tempFunc = function (  )
 -- 		self:visible(false)
 -- 		callback()
 -- 	end
	-- self.view:playLabel("open",false,false)
	-- local totalFrames = self.view:getTotalFrames(  )
	-- self:delayCall(tempFunc, totalFrames/GameVars.GAMEFRAMERATE )
end

--[[
播放打开宝箱后的动画
]]
function AnimModelBox:playOpenedBox(  )
	
end

--[[

]]


--[[
播放动画
]]
function AnimModelBox:playLabel(label, iscycle)
	
	self.view:playLabel(label, iscycle, false)

	self.totalFrame = self.view:getTotalFrames(label)
	--echo("----",label,"=============",self.curFrame,self.totalFrame)
	self.curFrame = 0
	self.label = label

	self.view:gotoAndPlay(self.curFrame)

	--开始播放
	self:updateFrame()
end


function AnimModelBox:getChatHeight()
    return self.chatHeight or 0
end

--[[
设置chat图标
]]
function AnimModelBox:setChatIcon(type,clickCallBack)
	
	type = 2
	local height = 120
    self.chatHeight = height
	local img = FuncRes.icon("chat/chat"..type..".png")

	local wid = 120 
	local hei = 140

	local nd1 = FuncRes.a_white( 70,60)
	nd1:addto(self)
	nd1:opacity(0)
	nd1:setTouchEnabled(true)
	nd1:pos(0+10,hei-10)

	nd1:setTouchedFunc(
		c_func( clickCallBack,self:getNameStr()),
		nil,
		true 
		)

    self.chatIconSp = self.controler.view:createUIArmature("UI_shijieditu", "UI_shijieditu_baoxiang",self, 
			true, GameVars.emptyFunc)
    self.chatIconSp:pos(0,height-20)
    self.chatIconSp:scale(0.7)
    self.chatIconSp:playWithIndex(0, false)
    local _callBack = function ( ... )
    	self.chatIconSp:playWithIndex(1, true)
    end
    self.chatIconSp:doByLastFrame(false, false,_callBack)


	local nd = display.newNode()
	nd:setContentSize(cc.size(wid,hei) )
	nd:addto(self)
	--nd:pos()
	--注册点全部放到脚下
	nd:anchor(0,0.1)

	nd:pos(-wid* 0.5,0)
	nd:setTouchEnabled(true)
	nd:setTouchedFunc(
		c_func( clickCallBack,self:getNameStr()),
		nil,
		true 
		)

	self.touchNode = nd
end





--[[
加载宝箱上边的气泡
]]
function AnimModelBox:setChatDialog( dialog1,dialog2,dialog3 )

	--echo("updateChat=-=------")
	local size = self.cfgData.viewSize
	local width,height = size[1],size[2]

	local txtTab = {}
	if dialog1 then
		table.insert(txtTab,dialog1)
	end
	if dialog2 then
		table.insert(txtTab,dialog2)
	end
	if dialog3 then
		table.insert(txtTab,dialog3)
	end
	local idx = math.random(1,#txtTab)
	local str = txtTab[idx]

	local view = WindowControler:createWindowNode("BulleTip")
	view:setTxt(FuncPlot.getLanguage(str,UserModel:name(  )))
    --view:setTxt("测试测试测试测试测试今天星期六明天星期七今天星期六明天星期七今天星期六明天星期七")

    local callBack
    callBack = function (  )
    self.bulleAni:removeFrameCallFunc()
    	if self.bulleAni.idx == 0 then
    		self.bulleAni:playWithIndex(1, true)
    		self.bulleAni.idx = 1
    		self.bulleAni:delayCall(callBack, 0.5)
    	elseif self.bulleAni.idx == 1 then
    		self.bulleAni:playWithIndex(2, false)
    		self.bulleAni.idx = 2
    		self.bulleAni:registerFrameEventCallFunc(nil, 1, callBack)
    	elseif self.bulleAni.idx ==2 then
    		echo("删除气泡-------")
    		self.bulleAni:clear()
    		self.bulleAni = nil

    	end
    end


    self.bulleAni= self.controler.view:createUIArmature("UI_lihuibiaoqing", "UI_lihuibiaoqing_tanhua",self, true, GameVars.emptyFunc)
    self.bulleAni:registerFrameEventCallFunc(nil, 1, callBack)
    self.bulleAni:pos(0,height)
    self.bulleAni.idx = 0
    view:pos(0,0)
    FuncArmature.changeBoneDisplay( self.bulleAni,"layer1",view )
    self.bulleAni:playWithIndex(0, false)
end








--[[
清除宝箱上面的气泡
]]
function AnimModelBox:clearChatIcon()
	echo("清楚clearChatIcon=-=======")
	if self.chatIconSp then
		self.chatIconSp:doByLastFrame( true, true ,nil)
		self.chatIconSp:removeFromParent()
		self.chatIconSp = nil
	end
	if self.chatIconSp1 then
		self.chatIconSp1:clear()
		self.chatIconSp1 = nil
	end
	if self.touchNode then
		self.touchNode:clear()
		self.touchNode = nil
	end
end






return AnimModelBox