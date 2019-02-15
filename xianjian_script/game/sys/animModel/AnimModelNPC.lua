



--[[
动画编辑器中的bone对象。也是body对象
]]

AnimModelNPC = class("AnimModelNPC", 
		AnimModelBasic
	)


--[[

]]
function AnimModelNPC:ctor(controler,view,cfgSource,cfg)
	AnimModelBody.super.ctor(self,controler)
	self:initView(view,10,"bone")
	--Source张的配置文件，可以获取
	self.cfgSourceData = cfgSource

	self.cfgData = cfg

	self:setScale((self.cfgData and self.cfgData.sourceZoom or 100) / 100)

	self:onInitComplete()
end


--[[
更新每一帧
判断如果动画播放完成，不是stand or walk 则只播放一次
self.cfgData中可以读取到对应的方法属性
]]
function AnimModelNPC:updateFrame()
	if self.curFrame == self.totalFrame then
		--local label = Fight.actions.action_stand
		local label
		if self:chkNeedLoop() then
			
			label = self.label
			--echo("循环-------",self._name,label)
		else
			
			label = Fight.actions.action_stand	
			--echo("不循环，直接站立-----",self._name,label)
		end
		self:playLabel(label)
	else
		self.curFrame = self.curFrame +1
	end

	if self.effectModel then
		self.effectModel:updateFrame()
	end
end

--[[
检测是否需要循环
]]
function AnimModelNPC:chkNeedLoop()
	if self.label == Fight.actions.action_stand or 
		self.label == Fight.actions.action_stand2 or
		self.label == Fight.actions.action_run or 
		self.label == Fight.actions.action_race2 or 
		self.label == Fight.actions.action_race3 or
		self.label == Fight.actions.action_uncontrol
	then
		return true
	else
		return false
	end
end

--[[
播放动画
]]
function AnimModelNPC:playLabel(label)
	--echoError("当前播放的动作",label,"===============")
	self.view:playLabel(self.cfgSourceData[label], false, false)

	self.totalFrame = self.view:getTotalFrames(self.cfgSourceData[label])
	--echo("----",label,"=============",self.curFrame,self.totalFrame)
	self.curFrame = 0
	self.label = label

	self.view:gotoAndPlay(self.curFrame / 2)

	--开始播放
	-- self:updateFrame()
end

--[[
加载人物头顶上的气泡
]]
function AnimModelNPC:setChatDialog( dialog1,dialog2,dialog3 )
	if self.bulleAni then
		self.bulleAni:clear()
		self.bulleAni = nil
	end
	--echo("updateChat=-=------")
	--dump(self.cfgData)
	local size = self.cfgSourceData.viewSize
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
    		self.bulleAni:delayCall(callBack, 2)
    	elseif self.bulleAni.idx == 1 then
    		self.bulleAni:playWithIndex(2, false)
    		self.bulleAni.idx = 2
    		self.bulleAni:registerFrameEventCallFunc(9, 1, callBack)
    	elseif self.bulleAni.idx ==2 then
    		--echo("删除气泡-------")
    		self.bulleAni:clear()
    		self.bulleAni = nil
    		self:playChat()
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
播放动画特效  特殊
]]
function AnimModelNPC:playEffect(effectName, bLoop,stopFrame,z)
	local effectName =  effectName
	local isLoop = bLoop or 0
	local frames = stopFrame or 100
	local zorder = z or 1
	local name = FuncArmature.getSpineName(effectName)
	local effSpine = ViewSpine.new(name,{},nil,nil,name)
	local model =  AnimModelEffect.new(self,effSpine):addto(self)
	self.effectModel = model
	model:zorder(tonumber(zorder * 10))
	-- self.view:zorder(10)
	local totalFrame = effSpine:getTotalFrames(effectName)
	model:setTimeSwitch(true)
	model:playLabel(effectName,tonumber(isLoop),tonumber(stopFrame))  
end
--[[
注册点击事件
]]
function AnimModelNPC:registerClickEvent()
	echo("注册NPC的点击事件")
	if not self.touchMenuNode then
		local size = self.cfgSourceData.viewSize
		local wid,hei = size[1],size[2]
		local nd = display.newNode()

		nd:setContentSize(cc.size(wid,hei) )
		nd:addto(self)
		--nd:pos()
		--注册点全部放到脚下
		nd:anchor(0,0.1)

		nd:pos(-wid* 0.5,0)
		nd:setTouchEnabled(true)
		nd:setTouchedFunc(
			c_func( self.doNPCClick,self),
			nil,
			true 
			)
		self.touchMenuNode = nd
	end

end


--[[
点击事件
]]
function AnimModelNPC:doNPCClick()

	echo("点击事件  根据 cfgData中的配置显示不同的点击事件================================")
    -- if true then
    --     return
    -- end
 	
 	local clickBackAction = function ()    			
		if self.cfgData.plotEvent then -- 对话事件
			PlotDialogControl:init() 
			PlotDialogControl:showPlotDialog(self.cfgData.plotEvent, GameVars.emptyFunc);
		end
		if self.cfgData.actionEvent then -- 动作事件
			self:playLabel(self.cfgData.actionEvent)
		end
		if self.cfgData.effectEvent then -- 特效事件
			local events = string.split(self.cfgData.effectEvent,",")
			self:playEffect(events[1],events[2],events[3],events[4])
		end
		-- if self.cfgData.chatEvent then -- 聊天泡泡
		-- 	local events = string.split(self.cfgData.chatEvent,",")
		-- 	self:setChatDialog(events[1],events[2],events[3])
		-- 	-- self:setChatDialog("#tid_plot_502004","#tid_plot_502005","#tid_plot_502006")
		-- end
 	end

	-- echo("\n\nposX==", self.posX, "posY==", self.posY)
	AnimDialogControl:moveBodyToPoint(self.posX, self.posY, clickBackAction, true)	
end

function AnimModelNPC:setPositionForMove(x, y)
	self.posX = x
	self.posY = y
end

-- 自动播放气泡
function AnimModelNPC:playChat()
	if self.cfgData.chatEvent then -- 聊天泡泡
		local delayTime = math.random(3,6) + math.random(0,9)/10

		self:delayCall(function()
			local events = string.split(self.cfgData.chatEvent,",")
			self:setChatDialog(events[1],events[2],events[3])
			-- self:setChatDialog("#tid_plot_502004","#tid_plot_502005","#tid_plot_502006")
		end, delayTime)		
	end
end

-- 头顶icon
function AnimModelNPC:setChatIcon(_type,offsetX,offsetY,clickCallBack)
	local size = self.cfgSourceData and self.cfgSourceData.viewSize or {75,165}	
	local width,height = size[1]+offsetX,size[2]+offsetY
	self.chatHeight = size[2]/2+offsetY

	local nd1 = display.newNode()
    nd1:setContentSize(cc.size(80,80) )
	nd1:addto(self)
	nd1:setTouchEnabled(true)
	nd1:pos(-width* 0.5,height)

	if clickCallBack then
		nd1:setTouchedFunc(c_func( clickCallBack,self:getNameStr()),nil,true)
	end

	local animName = "UI_shijieditu_duihua"
    if tonumber(_type) == 1 then
        animName = "UI_shijieditu_duihua"
    elseif tonumber(_type) == 2 then 
        animName = "UI_shijieditu_zhandou"
    elseif tonumber(_type) == 3 then
    	animName = "UI_shijieditu_baoxiang"
	elseif tonumber(_type) == 4 then
		animName = "UI_shijieditu_zhandou_wenhao2"
    else
        echoError("目前只支持两种，若想继续加 策划找张强对")
    end
    self.chatIconSp = self.controler.view:createUIArmature("UI_shijieditu",animName,self, true, GameVars.emptyFunc)
    self.chatIconSp:pos(0,height)
    self.chatIconSp:scale(0.7)
    self.chatIconSp:playWithIndex(0, false)
    local _callBack = function ( ... )
    	self.chatIconSp:playWithIndex(1, true)
    end
    self.chatIconSp:doByLastFrame(false, false,_callBack)
end

-- 初始化一些内容
function AnimModelNPC:onInitComplete()
	-- 开启对话
	self:playChat()
end

return AnimModelNPC