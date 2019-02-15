



--[[
动画编辑器中的bone对象。也是body对象
]]

AnimModelBody = class("AnimModelBody", 
		AnimModelBasic
	)


--[[

]]
function AnimModelBody:ctor(controler,view,cfg)
	AnimModelBody.super.ctor(self,controler)
	self:initView(view,0,"bone")
	--Source张的配置文件，可以获取
	self.cfgData = cfg
    self.isChar = false
    --[[
		{
			{
				callfunc,
				sysname
			}
		}
    ]]
    self.allCallFunc = {}
end

function AnimModelBody:isCharBody(_isChar)
    self.isChar = _isChar
end

-- 动作计时开关
function AnimModelBody:setTimeSwitch(isOpen)
    self.timeSwitch = isOpen 
end
--[[
更新每一帧
判断如果动画播放完成，不是stand or walk 则只播放一次
self.cfgData中可以读取到对应的方法属性
]]
function AnimModelBody:updateFrame()
	if self.curFrame == self.totalFrame then
		--local label = Fight.actions.action_stand
--		echo("动作 == ",self.label,"  时长 ==",self.totalFrame)
		local label
		if self:chkNeedLoop() then
			
			label = self.label
			--echo("循环-------",self._name,label)
		else
			
			label = Fight.actions.action_stand	
			--echo("不循环，直接站立-----",self._name,label)
		end
		self.curFrame = 0
		self:playLabel(label,self.actionCircle,true)
	else
		self.curFrame = self.curFrame + 1
	end
end

--[[
检测是否需要循环
]]
function AnimModelBody:chkNeedLoop()
    if self.actionCircle == 1 then
        return true
    end
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
function AnimModelBody:playLabel(label,_circle,restar)
	if self.label == label and self:chkNeedLoop() and (not restar) then 
		return
	end
	self.curFrame = 0
	self.view:playLabel(self.cfgData[label], false, false)
	self.totalFrame = self.view:getTotalFrames(self.cfgData[label])
	--echo("----",label,"=============",self.curFrame,self.totalFrame)
	self.label = label
    self.actionCircle = _circle

 --    if label == Fight.actions.action_run and self.curFrame > 0 then
	-- else
	-- 	self.view:gotoAndPlay(self.curFrame)
	-- end
	

	--开始播放
	-- self:updateFrame()
end



--[[
放养角色身上是否可以显示菜单
-- 目前废弃的扩展不进行考虑
]]
function AnimModelBody:setMenuClick(enable,item1CallBack,item2CallBack)
	if false then  -- 现在关闭放羊人物身上菜单显示
		self.item1CallBack = item1CallBack
		self.item2CallBack = item2CallBack
		if not self.touchMenuNode then
			local size = self.cfgData.viewSize
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
				c_func( self.doShowMenuClick,self),
				nil,
				true 
				)
			self.touchMenuNode = nd
		end
	else
		if self.touchMenuNode then
			self.touchMenuNode:setTouchEnabled(false)
			self.touchMenuNode:clear()
			self.touchMenuNode = nil
		end
	end
end

-- 添加主角脚下光环
function AnimModelBody:addJiaoxiaGuanghuan( )
	if self.isChar and self.controler:getNameShow() then
		local guanghuanAni = self.controler.view:createUIArmature("common",
			"common_juese_xia",
			nil, false, GameVars.emptyFunc)
		self:addChild(guanghuanAni,-1)
	end
	
end

--[[
隐藏 动画播放
]]
function AnimModelBody:doHideMenu()
	--echo("隐藏动画-----------")
	--回调方法
		local callBack
		callBack = function()
		--echo("动画回调-----")
			if self.menuAni then
				self.menuAni:removeFrameCallFunc()
				self.menuAni:clear()
				self.menuAni= nil
				--echo("移除了动画  不能在播放了。---------")	
			end

		end

		if self.menuAni then
			self.menuAni:removeFrameCallFunc()
			self.menuAni:registerFrameEventCallFunc(8,1,callBack)
			self.menuAni:playWithIndex(1,false)
		end

end


--[[
显示时装和布阵按钮
]]
function AnimModelBody:doShowMenuClick()
	--echo("显示  时装  和布阵  菜单==-========")


	local size = self.cfgData.viewSize
	local width,height = size[1],size[2]


	--这里也要有个加载比较好。这样做不太好  这里暂时这么做
	if not self.menuAni then
		--echo("重新加载-----")
		
		local menuAni = self.controler.view:createUIArmature("UI_shijieditu","UI_shijieditu_gongnenganniu",self, false, GameVars.emptyFunc)

		menuAni:pos(width/2+30,height/2)


		local menu1Display  = menuAni:getBoneDisplay("layer1"):addto(menuAni:getBone("layer1"))

	    menu1Display:setTouchedFunc(function()
	        if self.item1CallBack then
	        	self.item1CallBack()
	        end

	    end,nil,true)


	    local menu2Display = menuAni:getBoneDisplay("layer4"):addto(menuAni:getBone("layer4"))

	    menu2Display:setTouchedFunc(function()
	        if self.item2CallBack then
	        	self.item2CallBack()
	        end
	    end,nil,true)

	    

	    self.menuAni = menuAni
	end
	self.menuAni:removeFrameCallFunc()
	self.menuAni:playWithIndex(0,false)	
	self:updateFuncMenuRedPoint()
end

-- 更新功能菜单红点状态
function AnimModelBody:updateFuncMenuRedPoint()
	if self.menuAni then
		local garmentRedPoint = self.menuAni:getBone("hongdian1")
		garmentRedPoint:setVisible(false)

		local formationRedPoint = self.menuAni:getBone("hongdian2")
		local isOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.ARRAY)
		if isOpen then
			local hasIdlePosition = TeamFormationModel:hasIdlePosition()
			formationRedPoint:setVisible(hasIdlePosition)
		end
	end
end


function AnimModelBody:getChatHeight()
    return self.chatHeight or 0
end
--[[
设置chat图标
]]
function AnimModelBody:setChatIcon(_type,offsetX,offsetY,clickCallBack)
	local size = self.cfgData.viewSize
	local width,height = size[1]+offsetX,size[2]+offsetY
	local img = FuncRes.icon("chat/chat".._type..".png")
    self.chatHeight = size[2]/2+offsetY

    local nd1 = display.newNode()
    nd1:setContentSize(cc.size(80,80) )
	nd1:addto(self)
	nd1:pos(-width* 0.5,height)

	-- self.chatIconSp1 = display.newSprite(img):addto(self):pos(0,height)
	-- self.chatIconSp1:setTouchEnabled(true)
	-- self.chatIconSp1:opacity(100)
	if clickCallBack then
		nd1:setTouchEnabled(true)
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

	local nd = display.newNode()
	--local viewSize 
	-- local figure = self.cfgData.figure
	-- local wid = math.ceil(figure/2)
	-- local hei = figure >1 and 1.5 or 1
	local wid = width --*Fight.position_xdistance
	local hei = height

	nd:setContentSize(cc.size(wid,hei+15) )
	nd:addto(self)
	--nd:pos()
	--注册点全部放到脚下
	nd:anchor(0,0.1)

	nd:pos(-wid* 0.5,-15)
	if clickCallBack then
		nd:setTouchEnabled(true)
		nd:setTouchedFunc(c_func( clickCallBack,self:getNameStr()),nil,true)
	end

	self.touchNode = nd

end

-- function function_name( ... )
-- 	-- body
-- end



--[[
设置头顶上的表情
]]
function  AnimModelBody:setEmoi( type)
	
	--echo("222222",type)
	if self.emoiAni  then
		self.emoiAni:clear()
		self.emoiAni = nil
	end

	local size = self.cfgData.viewSize
	local width,height = size[1],size[2]


	local callBack
	callBack = function()
		if self.emoiAni then
			self.emoiAni:clear()
			self.emoiAni = nil
		end	
	end

	local aniName = "UI_lihuibiaoqing_"..type
	--echo(aniName,"=========")
--	aniName = "UI_lihuibiaoqing_17"
	self.emoiAni = self.controler.view:createUIArmature("UI_lihuibiaoqing",aniName,self, false, GameVars.emptyFunc):pos(0,height)
	-- self.emoiAni:registerFrameEventCallFunc(nil, nil, callBack)
	self.emoiAni:playWithIndex(0,false,true)
	--self.emoiAni:startPlay(false)



end

-- 标记采集效果
function AnimModelBody:setCollect(flag)
	if flag then
		if self.collectAni then return end

		local size = self.cfgData.viewSize
		local width,height = size[1],size[2]

		local aniName = "UI_lihuibiaoqing_caijizhong"
		self.collectAni = self.controler.view:createUIArmature("UI_lihuibiaoqing",aniName,self, false, GameVars.emptyFunc):pos(0,height)
		self.collectAni:playWithIndex(0,true)
	else
		if not self.collectAni then return end

		self.collectAni:clear()
		self.collectAni = nil
	end
end

--[[
加载人物头顶上的气泡
]]
function AnimModelBody:setChatDialog( dialog1,dialog2,dialog3 )
	if self.bulleAni then
		self.bulleAni:clear()
		self.bulleAni = nil
	end
	--echo("updateChat=-=------")
	--dump(self.cfgData)
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
    		self.bulleAni:delayCall(callBack, 2)
    	elseif self.bulleAni.idx == 1 then
    		self.bulleAni:playWithIndex(2, false)
    		self.bulleAni.idx = 2
    		self.bulleAni:registerFrameEventCallFunc(9, 1, callBack)
    	elseif self.bulleAni.idx ==2 then
    		--echo("删除气泡-------")
    		self.bulleAni:clear()
    		self.bulleAni = nil

    	end
    end

    self.bulleAni= self.controler.view:createUIArmature("UI_lihuibiaoqing", "UI_lihuibiaoqing_tanhua",self, true, GameVars.emptyFunc)
    self.bulleAni:registerFrameEventCallFunc(nil, 1, callBack)
    self.bulleAni:pos(0,height + 10)
    self.bulleAni.idx = 0
    view:pos(0,0)
    FuncArmature.changeBoneDisplay( self.bulleAni,"layer1",view )
    self.bulleAni:playWithIndex(0, false)
end

-- function AnimModelBody:setTouchClick()
-- 	echo("点击头像上的Chat---")
-- end

--[[
清除头顶上的chatIcon
]]
function AnimModelBody:clearChatIcon()
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

--function AnimModelBody:clearChatIco

-- 扩展一个注册点击事件的方法（没有改继承的方法，以后随用随改吧）
-- sysname 作为标识以删除
function AnimModelBody:setBodyTouchFunc(func,sysname)
	if not self.touchMenuNode then
		local size = self.cfgData.viewSize
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
			c_func( self.onBodyTouch,self),
			nil,
			true 
			)
		self.touchMenuNode = nd
	end

	if not sysname then
		echoError("没有系统标识，无法管理",sysname)
		return
	end

	-- 先清掉以前的
	self:clearBodyTouchFunc(sysname)

	table.insert(self.allCallFunc, {
		callFunc = func,
		sysname = sysname,
	})
end

-- 清掉注册的点击方法
function AnimModelBody:clearBodyTouchFunc(sysname)
	if sysname then
		for i,info in ripairs(self.allCallFunc) do
			if info.sysname == sysname then
				table.remove(self.allCallFunc, i)
				break
			end
		end
	else
		self.allCallFunc = {}
	end
end

function AnimModelBody:onBodyTouch()
	-- 挨个做
	for _,info in ipairs(self.allCallFunc) do
		info.callFunc(self)
	end
end

return AnimModelBody