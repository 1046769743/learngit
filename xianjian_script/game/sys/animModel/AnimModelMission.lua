--[[
动画编辑器中的missionBone对象。
]]

AnimModelMission = class("AnimModelMission", AnimModelBasic)
--[[

]]
function AnimModelMission:ctor(controler,view,cfgSource,cfg,noAutoMove)
	AnimModelBody.super.ctor(self,controler)
	self:initView(view,10,"missionBone")
	--Source张的配置文件，可以获取
	self.cfgSourceData = cfgSource

	self.cfgData = cfg

	self.noAutoMove = noAutoMove

	self:moveAction()
end
-- 创建之后要判断是否需要监听
function AnimModelMission:registerMissionEvent( data )
	-- EventControler:addEventListener("notify_mission_quest_quit_body_5524", self.quitMissionEvent, self)
end
-- //5522 进入答题 服务器主动推送给房间里的其他人
-- //5524 退出答题 服务器主动推送给房间里的其他人
-- //5526 答题广播 服务器主动推送给房间里的其他人
function AnimModelMission:quitMissionEvent(event)
	-- body
end

function AnimModelMission:setMissionData( data )
		self.missionData = data
	end
function AnimModelMission:getMissionData(  )
	return self.missionData
end

function AnimModelMission:setMissionIndex( index )
		self.missionIndex = index
end
function AnimModelMission:getMissionIndex(  )
	return self.missionIndex
end

function AnimModelMission:setModelVisible( isShow )
	self.isShow = isShow
end
function AnimModelMission:getModelVisible(  )
	return self.isShow
end

function AnimModelMission:setAnimMissionView( view )
	self.animMissionView = view
end
--[[
更新每一帧
判断如果动画播放完成，不是stand or walk 则只播放一次
self.cfgData中可以读取到对应的方法属性
]]
function AnimModelMission:updateFrame()
	if self.curFrame == self.totalFrame then
		local label
		if self:chkNeedLoop() then
			label = self.label
		else
			label = Fight.actions.action_stand	
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
function AnimModelMission:chkNeedLoop()
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
function AnimModelMission:playLabel(label)
	--echoError("当前播放的动作",label,"===============")
	if self.stopModelLable then
		return
	end
	self.view:playLabel(self.cfgSourceData[label], false, false)

	self.totalFrame = self.view:getTotalFrames(self.cfgSourceData[label])
	--echo("----",label,"=============",self.curFrame,self.totalFrame)
	self.curFrame = 0
	self.label = label

	self.view:gotoAndPlay(self.curFrame )

end

-- 停止播放
function AnimModelMission:stop()
	self.stopModelLable = true
	self.view:stop(0)
end

--[[
加载人物头顶上的气泡
]]
function AnimModelMission:setChatDialog( dialog1,dialog2,dialog3 )
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

	FuncArmature.loadOneArmatureTexture("UI_lihuibiaoqing", nil, true)
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

    self.bulleAni= FuncArmature.createArmature("UI_lihuibiaoqing_tanhua",self, true, GameVars.emptyFunc)
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
function AnimModelMission:playEffect(effectName, bLoop,stopFrame,z)
	local effectName =  effectName
	local isLoop = bLoop or 0
	local frames = stopFrame or 100
	local zorder = z or 1
	local name = FuncArmature.getSpineName(effectName)
	local effSpine = ViewSpine.new(name,{},nil,nil)
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
function AnimModelMission:registerClickEvent()
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
function AnimModelMission:doNPCClick()
	echo("点击事件  进布阵 准备战斗================================") 
end

--[[
模拟运动
]]
function AnimModelMission:moveAction()
	if self.noAutoMove then
		return
	end

	local _parent = self.view:getParent()
	local minX = -1500
	local maxX = 300
	local minY = -240
	local maxY = 40
	local speed = 180
	if _parent then
		local delayTime = math.random(3,50)
		_parent:delayCall(function ( ... )
			
			if self.label == Fight.actions.action_stand then
				local posX = math.random(minX,maxX)
			    local posY = math.random(minY,maxY)
				local curX = self:getPositionX()
				local curY = self:getPositionY()
				if posX < curX then
					self.view:setScaleX(-1)
				else
					self.view:setScaleX(1)
				end
				local runTime = math.sqrt((posX-curX)*(posX-curX) + (posY-curY)*(posY-curY))/speed
				self:playLabel(Fight.actions.action_run)
				self:runAction(cc.Sequence:create(
                    act.moveto(runTime , posX, curY),
                    act.callfunc(function ( ... )
                    	self:playLabel(Fight.actions.action_stand)
                    	self:moveAction()
                    end)
                ))
			end
			
		end, delayTime)
	end
end

-- 获取随机位置
function AnimModelMission:questAnswerActionPos( _type )
	local datiPos = self.animMissionView.datiPos
	local minX = -1900
	local maxX = 160
	local minY = -220
	local maxY = 0
	local speed = 220
	local posX = 0
	local posY = 0
	local off = 80
	if _type == 1 then --左答案区域
		posX = math.random(datiPos.zuo.x1,datiPos.zuo.x2)
	    posY = math.random(datiPos.gao.y1,datiPos.gao.y2)
	elseif _type == 2 then --右答案区域
		posX = math.random(datiPos.you.x1,datiPos.you.x2)
	    posY = math.random(datiPos.gao.y1,datiPos.gao.y2)
	else -- 未答题区域
		local quyu = math.random(1,3)
		if quyu == 1 then
			posX = math.random(-minX,datiPos.zuo.x1 - off)
			posY = math.random(minY,maxY)
		elseif quyu == 2 then
			posX = math.random(datiPos.zuo.x2+off,datiPos.you.x1 - off)
			posY = math.random(minY,maxY)
		elseif quyu == 3 then
			posX = math.random(datiPos.you.x2 + off,150)
			posY = math.random(minY,maxY)
		end
	end
	if posX > 200 then
		return self:questAnswerActionPos(_type)
	end
	-- echo("===========_type ======== ",_type,posX,posY)
	return posX,posY
end

-- 答题运动
function AnimModelMission:questAnswerAction( _type )
	if self.answerType and self.answerType == _type then
		return
	end
	self.answerType = _type
	local _parent = self.view:getParent()
	local speed = 300

	if _parent then
		self:playLabel(Fight.actions.action_stand)
		local posX , posY = self:questAnswerActionPos( _type )
		local curX = self:getPositionX()
		local curY = self:getPositionY()
		if posX < curX then
			self.view:setScaleX(-1)
		else
			self.view:setScaleX(1)
		end
		local runTime = math.sqrt((posX-curX)*(posX-curX) + (posY-curY)*(posY-curY))/speed
		self:stopAction()
		self:playLabel(Fight.actions.action_run)
		self:runAction(cc.Sequence:create(
	        act.moveto(runTime , posX, posY),
	        act.callfunc(function ( ... )
	        	self:playLabel(Fight.actions.action_stand)
	        end)
	    ))
	end
end

-- 判断当前在哪个答题区
function AnimModelMission:getQuestType( )
	local curX = self:getPositionX()
	local curY = self:getPositionY()
	echo("\n\n 其他玩家位置  curX,curY === ",curX,curY)
	if -985 >= curX and -1364 <= curX  and 
		-220 <= curY and  -95 >= curY then
		return 1
	elseif -304 >= curX and -687 <= curX  and 
		-220 <= curY and  -95 >= curY then
		return 2
	end
	return 0
end

function AnimModelMission:stopAction(  )
	self:stopAllActions()
	self:playLabel(Fight.actions.action_stand)
	self:moveAction()
end

--
--[[
设置chat图标
]]
function AnimModelMission:setChatIcon(_type,offsetX,offsetY,clickCallBack)
	local size = self.cfgSourceData.viewSize
	local width,height = size[1]+offsetX,size[2]+offsetY
	local img = FuncRes.icon("chat/chat".._type..".png")
    self.chatHeight = size[2]/2+offsetY

    local nd1 = display.newNode()
    nd1:setContentSize(cc.size(80,80) )
	nd1:addto(self)
	nd1:setTouchEnabled(true)
	nd1:pos(-width* 0.5,height)

	nd1:setTouchedFunc(c_func( clickCallBack,self:getNameStr()),nil,true)

	FuncArmature.loadOneArmatureTexture("UI_shijieditu", nil, true)
    local animName = "UI_shijieditu_duihua"
    if tonumber(_type) == 1 then
        animName = "UI_shijieditu_duihua"
    elseif tonumber(_type) == 2 then 
        animName = "UI_shijieditu_zhandou"
    else
        echoError("目前只支持两种，若想继续加 策划找张强对")
    end
    self.chatIconSp = FuncArmature.createArmature(animName,self, 
			true, GameVars.emptyFunc)
    self.chatIconSp:pos(0,height)
    self.chatIconSp:scale(0.7)
    self.chatIconSp:playWithIndex(0, false)

	local nd = display.newNode()
	--local viewSize 
	-- local figure = self.cfgData.figure
	-- local wid = math.ceil(figure/2)
	-- local hei = figure >1 and 1.5 or 1
	wid = width --*Fight.position_xdistance
	hei = height

	nd:setContentSize(cc.size(wid,hei+15) )
	nd:addto(self)
	--nd:pos()
	--注册点全部放到脚下
	nd:anchor(0,0.1)

	nd:pos(-wid* 0.5,-15)
	nd:setTouchEnabled(true)
	nd:setTouchedFunc(c_func( clickCallBack,self:getNameStr()),nil,true)

	self.touchNode = nd
end

-- 
--[[
答对或答错的表情
]]
function  AnimModelMission:setEmoi( _type)
	if self.emoiAni  then
		self.emoiAni:clear()
		self.emoiAni = nil
	end

	local size = self.cfgSourceData.viewSize
	local width,height = size[1],size[2]

	local callBack = function()
		if self.emoiAni then
			self.emoiAni:clear()
			self.emoiAni = nil
		end	
	end
	local aniName = "UI_lihuibiaoqing_".._type
	self.emoiAni = self.controler.view:createUIArmature("UI_lihuibiaoqing",aniName,self, false, GameVars.emptyFunc):pos(0,height)
	self.emoiAni:playWithIndex(0,false,true)
end

-- 添加冰冻效果
function AnimModelMission:addBingdongEffect(  )
	local shangName = "eff_30004_zhaolinger_attack3_buff_chixu_shang"
	local xiaName = "eff_30004_zhaolinger_attack3_buff_chixu_xia"
	local spineEffect1 = ViewSpine.new("eff_30004_zhaolinger",{},nil,nil)
	spineEffect1:playLabel(xiaName)
	local spineEffect2 = ViewSpine.new("eff_30004_zhaolinger",{},nil,nil)
	spineEffect1:playLabel(shangName)
	spineEffect1:addTo(self, 10):pos(0,0)
	spineEffect2:playLabel(xiaName)
	spineEffect2:addTo(self, 0):pos(0,0)
	self.view:zorder(5)
end

function AnimModelMission:deleteMe()
     --销毁事件
    EventControler:clearOneObjEvent( self )
end
return AnimModelMission