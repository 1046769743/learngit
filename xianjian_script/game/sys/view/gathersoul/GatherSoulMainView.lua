-- GatherSoulMainView
--Author:    wk
--DateTime:    2018-05-08 
--Description: 三皇台（聚魂主界面）

local GatherSoulMainView = class("GatherSoulMainView", UIBase);

function GatherSoulMainView:ctor(winName)
    GatherSoulMainView.super.ctor(self, winName)
end

-- local denglongpos = {
-- 	[1] = {x = 6.8,y = 844.5},
-- 	[2] = {x = 158,y = 754.5},
-- 	[3] = {x = 308.8,y = 789},
-- 	[4] = {x = -121.6,y = 644},
-- 	[5] = {x = -283.11,y = 702},
-- }

function GatherSoulMainView:loadUIComplete()
	self:registerEvent()

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_icon,UIAlignTypes.LeftTop)  --RightTop
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_back,UIAlignTypes.RightTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_title,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_wen,UIAlignTypes.LeftTop)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_djjx,UIAlignTypes.MiddleBottom)

	FuncCommUI.setViewAlign(self.widthScreenOffset,self.UI_res1,UIAlignTypes.RightTop)

	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.Right)


	self.btn_back:setTouchedFunc(c_func(self.clickButtonBack, self),nil,true);
	self.panel_djjx:setVisible(false)
	-- self.panel_djjx.panel_di:setVisible(false)
	self.btn_wen:setTouchedFunc(function ()
		 -- WindowControler:showWindow("NewlotteryHelp")
		local pames = {
	        title = "须臾仙境规则",
	        tid = "#tid_lottery_1021",
	    }
	    
		WindowControler:showWindow("TreasureGuiZeView",pames)


	end,nil,true);

	self.speedLevel = FuncNewLottery:getSpineSpeed() --，默认选择等级20

	FuncNewLottery.spineSpeed = 2.5--FuncNewLottery:getSpineSpeed()

	self.spineNode =  self.ctn_1

 	self.windows = {}
 	self.addEffect = false
 	
 	if TutorialManager.getInstance():isInTutorial() then
 		self.isInTutorial = true
 	else
 		self.isInTutorial = false
 	end      


 	self.xiyaoSpineScal = 1
 	self:addSceneSpine()

 	-- self:showEffectdenglong()
 	FuncNewLottery.CachePartnerdata()
 	self:initData()
 	self:viewSetTouch()
 	self:todoView()    

 	self:serversToLocalPartner()
end 

--保存伙伴数据
function GatherSoulMainView:serversToLocalPartner()
	local partnerData = PartnerModel:getAllPartner()
	self.partnerDataArr = {}
	for k,v in pairs(partnerData) do
		self.partnerDataArr[k] = v.id
	end
end


function GatherSoulMainView:rightPartnerIconAction()
	-- body
end



function GatherSoulMainView:addSchedule()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end


function GatherSoulMainView:registerEvent()
	GatherSoulMainView.super.registerEvent(self)
	EventControler:addEventListener(NewLotteryEvent.NEXT_VIEW_UI,self.nextView,self);
	-- EventControler:addEventListener(NewLotteryEvent.SHOW_ALL_BUTTON_EVENT,self.showAllBUtton,self);
	EventControler:addEventListener(NewLotteryEvent.MOVE_CELL_RUNACTION,self.effectRunAction,self);

	-- EventControler:addEventListener(NewLotteryEvent.GATHERSOUL_ALL_TODO_VIEW,self.todoView,self);

	-- EventControler:addEventListener(NewLotteryEvent.TOUCH_UI_STOP_RUNACTION,self.stopRunaction,self);
	EventControler:addEventListener(NewLotteryEvent.REFRESH_ZAOWU_FINISH_UI,self.removeAllCell,self);
	
	EventControler:addEventListener(NewLotteryEvent.REMOVE_ALL_VIEW_CELL,self.removeAllCell,self);


	EventControler:addEventListener(NewLotteryEvent.ADD_JUHUN_EFFECT,self.effectEvent,self);

	EventControler:addEventListener(NewLotteryEvent.CLOSE_FINISH_UI_TOBACK_FRAME,self.touchSure,self);
	
	EventControler:addEventListener(NewLotteryEvent.CONTINUE_BUTTON_FINISH,self.createNilWind,self);

	EventControler:addEventListener(NewLotteryEvent.ALLFINISH_JUHUN,self.allfinishEffect,self);

	EventControler:addEventListener(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT,self.showWaPanel,self)
end


function GatherSoulMainView:createNilWind()

	if self.windows ~= nil then
		for k,v in pairs(self.windows) do
			if v then
				v:removeFromParent()
			end
		end
	end
	self.windows = {}
	for i=1,5 do
		local boneName = "denglongtou_"..i
		local pos1 =  self.spineEffect2:getBonePos(boneName)
		self.windows[i] =  WindowControler:createWindowNode("GatherSoulHuaXingView")
		self.spineNode:addChild(self.windows[i])
		self.windows[i]:createInitIcon()
		self.windows[i]:setPosition(cc.p(pos1.x+15,pos1.y-40))	
	end
	NewLotteryModel:getRewardEffect()

end



--添加星魂Spine场景
function GatherSoulMainView:addSceneSpine()
	self.spineEffect2 = ViewSpine.new("UI_chouka",{},nil,nil)
	self.spineEffect2:playLabel("UI_chouka_stand",false)
	-- self.spineEffect2:gotoAndStop(1)
	self.playSpineName = "UI_chouka_stand"
	self.spineEffect2:addTo(self.spineNode,-1):pos(0, -60)
	self.maxFrame = self.spineEffect2:getCurrentAnimTotalFrame()


	
	self.xiyaoSpine = ViewSpine.new("UI_chouka_xiyao")
	local xiyaoPos =  self.spineEffect2:getBonePos("xiyao")
	self.xiyaoSpine:addTo(self.spineNode):pos(xiyaoPos.x,xiyaoPos.y-60)
	self.xiyaoSpine:playLabel("stand",true)

	self.dengSpine = ViewSpine.new("UI_chouka_deng",{},nil,nil)
	local dengPos =  self.spineEffect2:getBonePos("hehua")
	self.dengSpine:playLabel("UI_chouka_loop",false)
	self.dengSpine:gotoAndStop(1)
	self.dengSpine:addTo(self.spineNode):pos(dengPos.x,dengPos.y-60)

	self.panel_1:setVisible(false)
	self.waPanel = UIBaseDef:cloneOneView(self.panel_1)
	local waPos =  self.spineEffect2:getBonePos("glow_shitou")
	self.waPanel:addTo(self.spineNode):pos(waPos.x-20,waPos.y)
	self:addbubblesRunaction(self.waPanel)
	self:showWaPanel()
	-- self.waPanel:setTouchedFunc(c_func(self.toDoMonthCardView, self),nil,true);
end

function GatherSoulMainView:showWaPanel()
	if self.waPanel then

		local node = display.newNode()
		node:anchor(0.5, 0.2)
		node:size(250,150)
		node:addTo(self.waPanel)
		local isMonthCard =   MonthCardModel:getCardLeftDay( FuncMonthCard.card_xiyao )
		if isMonthCard ~= 0 then
			if isMonthCard <= 3 then
				node:setTouchedFunc(c_func(self.toDoMonthCardView, self),nil,true);
				self.waPanel.panel_3:setVisible(true)
				self.waPanel.panel_3.rich_1:setString(GameConfig.getLanguage("#tid_lottery_tips_2"))
			else
				node:setTouchedFunc(function ()end,nil,true);
				self.waPanel.panel_3:setVisible(false)
			end
		else
			node:setTouchedFunc(c_func(self.toDoMonthCardView, self),nil,true);
			self.waPanel.panel_3:setVisible(true)
		end
	end
end

function GatherSoulMainView:toDoMonthCardView()
	WindowControler:showWindow("MonthCardMainView",FuncMonthCard.CARDYEQIAN["1"])
end


function GatherSoulMainView:addbubblesRunaction(panel)
	self:bubbles(panel)
	-- local delaytime_1 = act.delaytime(0.2)
	local scaleto_1 = act.scaleto(0.1,1.2,1.2)
	local scaleto_2 = act.scaleto(0.05,1.0,1.0)
	local delaytime_2 = act.delaytime(3.0)
 	local scaleto_3 = act.scaleto(0.1,0)
 	local delaytime_3 = act.delaytime(2.0)
 	local callfun = act.callfunc(function ()
 	end)
	local seqAct = act.sequence(act.spawn(callfun,scaleto_1),scaleto_2,delaytime_2,scaleto_3,delaytime_3)
	panel.panel_3:runAction(act._repeat(seqAct))

end
function GatherSoulMainView:bubbles(panel)
	local str = GameConfig.getLanguage("#tid_lottery_tips_1")
	panel.panel_3.rich_1:setString(str)
end




function GatherSoulMainView:todoView()
	self:addSchedule()
	local isGatherSoul  = NewLotteryModel:judgeTODOVivew()
	local isSoulOnTreeTop = TutorialManager.getInstance():isGatherSoulOnTreeTop()
	if isGatherSoul or isSoulOnTreeTop then
		-- self.spineEffect2:gotoAndStop(self.maxFrame)
		self.UI_button:showAllBUtton(false)
		self.UI_button:showyijianjiasu(true)
		self.playSpineName = "UI_chouka_loop"
		self.spineEffect2:playLabel("UI_chouka_loop")
		self.waPanel:setVisible(false)
	else
		self.UI_button:showAllBUtton(true)
		self.UI_button:showyijianjiasu(false)
		-- self.spineEffect2:gotoAndStop(1)
		self.spineEffect2:playLabel("UI_chouka_stand")
		self.playSpineName = "UI_chouka_stand"

		if self.isInTutorial then
			self.waPanel:setVisible(false)
		else
			self.waPanel:setVisible(true)
		end

	end

end





function GatherSoulMainView:initData()

	if self.windows ~= nil then
		for k,v in pairs(self.windows) do
			v:removeFromParent()
		end
		self.windows = {}
	end
	NewLotteryModel:getAllJuHunData()
	local alldata = table.copy(NewLotteryModel:getGatherSoulData())
	for i=1,#alldata do
		local _posIndex = alldata[i].pos
		if _posIndex then
			local boneName = "denglongtou_".._posIndex
			local pos1 =  self.spineEffect2:getBonePos(boneName)
			self.windows[_posIndex] =  WindowControler:createWindowNode("GatherSoulHuaXingView")
			self.spineNode:addChild(self.windows[_posIndex],100)
			self.windows[_posIndex]:setVisible(false)
			self.windows[_posIndex]:initData(_posIndex)
			self.windows[_posIndex]:setPosition(cc.p(pos1.x + 15,pos1.y - 40))
		end
	end
end

function GatherSoulMainView:finshCreationButton( data )
	-- echo("造物完成的数据 ==========1111111111=======")
	-- dump(data,"造物完成的数据 =======1===========")
end





--刷新造物的最大帧的界面	
function GatherSoulMainView:refreshMaxUI(event)
	local pos = event.params
	-- echo("=======pos=======",pos)
	dump(self.windows,"完成前的造物数据结构 =======")
	-- dump(pos,"完成前的造物数据结构 ===11111111====")
	if self.windows then
		for k,v in pairs(self.windows) do
			for _,index in pairs(pos) do
				if tonumber(k) == tonumber(index) then
					v:removeFromParent()
					self.windows[k] = nil
				end
			end
		end
	end
	-- NewLotteryModel:readLocalData()
	dump(self.windows,"完成后的造物数据结构 =======")
	if table.length(self.windows) == 0 then
		self:todoView()
	end

end







function GatherSoulMainView:removeAllCell(event)

	
	local data = NewLotteryModel:getGatherSoulData()

	-- dump(data,"removeAllCell ========= ")
	if data then
		if #data ~= 0 then
			if self.windows then
				for k,v in pairs(self.windows) do
					local isHave = false
					for i=1,#data do
						if tonumber(k) == tonumber(data[i].pos) then
							isHave = true
						end
					end
					if not isHave then
						if v ~= nil then
							v:removeFromParent()
						end
						self.windows[k] = nil
					end
				end
			end
		else
			if self.windows ~= nil then
				for k,v in pairs(self.windows) do
					v:removeFromParent()
				end
				self.windows = {}
			end
		end
	else
		if self.windows ~= nil then
			for k,v in pairs(self.windows) do
				v:removeFromParent()
			end
			self.windows = {}
		end
	end

	self.UI_button:showAllBUtton(false)
	self.UI_button:showyijianjiasu(true)
	if self.isInTutorial then
		self.waPanel:setVisible(false)
	else
		self.waPanel:setVisible(true)
	end

	-- self.waPanel:setVisible(true)
	if self.spineEffect2 then 
		if table.length(self.windows) == 0 then
			self:todoView()
		end
	end

end

function GatherSoulMainView:setWindowsPos()
	if self.windows ~= nil then
		-- dump(self.windows,"3333333333333")
		if table.length(self.windows ) ~= 0 then
			-- if currentFrame ~= 0 then
				local data = NewLotteryModel:getGatherSoulData()
				for k,v in pairs(data) do
					local posIndex = v.pos
					if posIndex then
						local boneName = "denglongtou_"..posIndex
						local pos1 =  self.spineEffect2:getBonePos(boneName)
						if self.windows[posIndex] then
							self.windows[posIndex]:setVisible(true)
							self.windows[posIndex]:setPosition(cc.p(pos1.x+15,pos1.y-40))
						end
					end
				end
			-- end
		end
	end
	if self.xiyaoSpine then
		local xiyaoPos =  self.spineEffect2:getBonePos("xiyao")
		self.xiyaoSpine:pos(xiyaoPos.x,xiyaoPos.y-60)
	end
	if self.waPanel then
		local waPos =  self.spineEffect2:getBonePos("glow_shitou")
		self.waPanel:pos(waPos.x-20,waPos.y)
	end
end



function GatherSoulMainView:updateFrame()
	
	-- local currentFrame = self.spineEffect2:getCurrentFrame()
	-- echo("111111============",currentFrame,self.playSpineName)

	self:setWindowsPos()


	if self.addEffect then
		local isContinue =  NewLotteryModel:getIsContinueSoulButton()
		if isContinue then
			return 
		end
		local dengFrame = self.dengSpine:getCurrentFrame()
		if dengFrame >= 256 then
			-- self:showEffectdenglong()
			self.dengSpine:gotoAndStop(1)
			self.dengSpine:stop()
			self.xiyaoSpine:playLabel("stand",true)
			self.xiyaoSpine:play()
		-- end
		-- if currentFrame >= self.maxFrame - 1 then
			if self.gatherSoulpos then
				for k,v in pairs(self.gatherSoulpos) do
					local boneName = "denglongtou_"..v
	    			local pos1 =  self.spineEffect2:getBonePos(boneName)
					self.windows[v] =  WindowControler:createWindowNode("GatherSoulHuaXingView")
					self.spineNode:addChild(self.windows[v])
					self.windows[v]:playSpineDengEffect(v)
					self.windows[v]:setposData( v )
					self.windows[v]:setPosition(cc.p(pos1.x+15,pos1.y-40))
				end
			end
			self:showEffectdenglong()
			EventControler:dispatchEvent(NewLotteryEvent.SHOW_SPEEDUP_BUTTON,true)
			self.addEffect = false
			self.moveEffect = false

			local showTime = 0.02
			if TutorialManager.getInstance():isInTutorial() then
				showTime = 0.5
			end
			if TutorialManager.getInstance():isInTutorial() then
				EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_JUHUN)
			end
			self:delayCall(function()
				self:setTopButTopinisShow(true)
			end,showTime)
			self.spineEffect2:setPlaySpeed(1.0);
			self.spineEffect2:playLabel("UI_chouka_loop")
			self.playSpineName = "UI_chouka_loop"
			self.spineEffect2:play()
			NewLotteryModel:getRewardEffect()

		end
	else
		-- echo("========self.playSpineName========",self.playSpineName)
		if self.playSpineName == "UI_chouka_shangsheng" or self.playSpineName == "UI_chouka_xiaojiang" then
			local currentFrame = self.spineEffect2:getCurrentFrame()
			-- echo("=======currentFrame======",currentFrame)
			local endcurrentFrame = 256
			local xiacurrentFrame = 0
			if self.moveEffect then
				if  UserModel:level() >=  self.speedLevel then
					endcurrentFrame = endcurrentFrame - FuncNewLottery.spineSpeed
					xiacurrentFrame = 1
				end
			end

			if currentFrame <= xiacurrentFrame then
				if TutorialManager.getInstance():isInTutorial() then
					EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_JUHUN)
				end
				self.moveEffect = false
				-- self.waPanel:setVisible(true)
				if self.isInTutorial then
					self.waPanel:setVisible(false)
				else
					self.waPanel:setVisible(true)
				end
				self.UI_button:showAllBUtton(true)
				self.UI_button:showyijianjiasu(false)
				self.UI_button.touch_event = false
				self.spineEffect2:setPlaySpeed(1.0);
				self.spineEffect2:playLabel("UI_chouka_stand")
				self.playSpineName = "UI_chouka_stand"
				self:setWindowsPos()
				self:unscheduleUpdate()
			elseif currentFrame >= endcurrentFrame  then
				self.moveEffect = false
				if TutorialManager.getInstance():isInTutorial() then
					EventControler:dispatchEvent(TutorialEvent.TUTORIAL_FINISH_JUHUN)
					self.isInTutorial = true
				end
				-- self.spineEffect2:stop()
				self.UI_button:showAllBUtton(false)
				self.UI_button:showyijianjiasu(true)
				self.isInTutorial = false
				self:unscheduleUpdate()
				self.spineEffect2:setPlaySpeed(1.0);
				self.spineEffect2:playLabel("UI_chouka_loop",true)
				self.playSpineName = "UI_chouka_loop"
				-- echo("========1111111111=======UI_chouka_loop==========")
				self.UI_button:showAllBUtton(false)
				self.UI_button:showyijianjiasu(true)
				-- self.waPanel:setVisible(true)
				if self.isInTutorial then
					self.waPanel:setVisible(false)
				else
					self.waPanel:setVisible(true)
				end
				self:setWindowsPos()
			end
		end
	end
end



function GatherSoulMainView:setTopButTopinisShow(isShow)
	self.btn_back:setVisible(isShow)
	self.UI_backhome:setVisible(isShow)
	self.panel_title:setVisible(isShow)
	self.btn_wen:setVisible(isShow)
	self.UI_res1:setVisible(isShow)
end

function GatherSoulMainView:allfinishEffect()
	local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
	local alldata = NewLotteryModel:getGatherSoulData()
	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	if isAllfinish or table.length(alldata) == maxCount then
		self:addSchedule()
		self.spineEffect2:setPlaySpeed(1.0);
		self.spineEffect2:playLabel("UI_chouka_shangsheng",false)
		self.dengSpine:playLabel("UI_chouka_shangsheng",false)
		self.addEffect = true
		self.spineEffect2:play()
		self.dengSpine:play()
		self.xiyaoSpine:play()

		self:showEffectdenglong()
		self.spineEffect2:gotoAndStop(self.maxFrame)
		self.dengSpine:gotoAndStop(257)
		if isAllfinish then
			-- echo("==========1111111========isAllfinish====")
			self.UI_button:allFinish()
		elseif  table.length(alldata) == maxCount then 
			-- echo("==========2222222222========maxCount====")
			-- NewLotteryModel:getRewardEffect()
			self.UI_button:showAllBUtton(false)
			-- self.waPanel:setVisible(true)
			if self.isInTutorial then
				self.waPanel:setVisible(false)
			else
				self.waPanel:setVisible(true)
			end
		end
	end

end

--播放造物灯笼的动画
function GatherSoulMainView:effectRunAction(event)
	self.waPanel:setVisible(false)
	self:addSchedule()
	self.gatherSoulpos = event.params or {1}
	local denglongArr = self:showEffectdenglong()
	self:setTopButTopinisShow(false)

	for k,v in pairs(self.gatherSoulpos) do
		for i=1,23 do
			self.dengSpine:setSlotVisible(denglongArr[v][i], true)
		end
	end

	local num = table.length(self.gatherSoulpos)
	if num == 1 then
		self.xiyaoSpine:playLabel("deng_"..self.gatherSoulpos[1],false)
	else
		self.xiyaoSpine:playLabel("deng_6",false)
	end


	self.dengSpine:playLabel("UI_chouka_shangsheng",false)
	self.playSpineName = "UI_chouka_shangsheng"
	self.spineEffect2:setPlaySpeed(1.0);
	self.spineEffect2:playLabel("UI_chouka_shangsheng",false)
	self.spineEffect2:play()
	self.dengSpine:play()
	self.xiyaoSpine:play()

	self.moveEffect = true
	--开始播特效
	self.addEffect = true


end

function GatherSoulMainView:showEffectdenglong()

	local denglongArr = {}
	local denglongtou = {}
	for i=1,5 do
		denglongArr[i] = {}
		for x=1,23 do
			denglongArr[i][x] = "deng"..i.."_"..x
			self.dengSpine:setSlotVisible(denglongArr[i][x], false)
		end
	end
	return denglongArr
end



function GatherSoulMainView:clickButtonBack()
	NewLotteryModel:sendMainLotteryRed()
    self:startHide()
end

function GatherSoulMainView:deleteMe()
	-- TODO
	GatherSoulMainView.super.deleteMe(self);
end

function GatherSoulMainView:touchSure()
	self:removeAllCell()
	self.viewIsSureTouch = false	
	self:setTopButTopinisShow(true)
	self.panel_djjx:setVisible(false)

	-- self:todoView()

end

function GatherSoulMainView:viewSetTouch()
		local function onTouchBegan(touch, event)
			-- echo("11111111111111111111111")
			-- dump(touch," onTouchBegan======")
			self.move = false
			self.firstPosX = touch.x
        	self.firstPosY = touch.y
            return true
        end

        local function onTouchMove(touch, event)
        	-- dump(touch,"移动 ======")
    		local x = touch.x
    		local y = touch.y
    		self.moveY =  y - self.firstPosY
    		self.move = true
        end

        local function onTouchEnded(touch, event)  
        	-- dump(touch,"结束 ======")
        	if TutorialManager.getInstance():isInTutorial() then
        		return
        	end
        	
        	if self.viewIsSureTouch then
        		return
    		end


        	if not self.move then
 				if self.addEffect then
 					-- echo("=========self.moveEffect===00000000000=====",self.moveEffect)
					self:showEffectdenglong()
 					self.spineEffect2:gotoAndStop(257)
 					self.dengSpine:gotoAndStop(257)
 				end
 			else

 				local frame = self.spineEffect2:getCurrentFrame()
 				if self.moveY <= 0 then
 					-- echo("=========self.moveEffect====111111====",self.moveEffect)
					if not self.moveEffect then
						if self.playSpineName  == "UI_chouka_stand" then
							self.UI_button:showAllBUtton(false)
							self.waPanel:setVisible(false)
							self:showEffectdenglong()
							-- self.dengSpine:gotoAndStop(130)
							if UserModel:level() >= self.speedLevel  then
								self.spineEffect2:setPlaySpeed(FuncNewLottery.spineSpeed);
							else
								self.spineEffect2:setPlaySpeed(1.0);
							end

							self.spineEffect2:playLabel("UI_chouka_shangsheng",true)
							self.dengSpine:playLabel("UI_chouka_shangsheng",false)
							self.playSpineName = "UI_chouka_shangsheng"
							self.xiyaoSpineScal = 1
							self.spineEffect2:gotoAndStop(130)
							self.spineEffect2:play()
							self.moveEffect = true
						end
					end
 				else
 					-- echo("=========self.moveEffect====222222222====",self.moveEffect)
	 				if not self.moveEffect then 
	 					-- if frame ~= 0 then
	 					if self.playSpineName  == "UI_chouka_loop" then
	 						self.UI_button:showyijianjiasu(false)
	 						if UserModel:level() >= self.speedLevel  then
								self.spineEffect2:setPlaySpeed(FuncNewLottery.spineSpeed);
							else
								self.spineEffect2:setPlaySpeed(1);
							end
		 					self.spineEffect2:playLabel("UI_chouka_xiaojiang",true)
		 					self.dengSpine:playLabel("UI_chouka_xiaojiang",false)
		 					self.playSpineName = "UI_chouka_xiaojiang"
		 					self.xiyaoSpineScal = 1
		 					self.spineEffect2:play()
		 					self.moveEffect = true
		 				end
	 				end
 				end
        	end
        	self:addSchedule()
        end

        self:setTouchedFunc(GameVars.emptyFunc, nil, true, 
        onTouchBegan, onTouchMove,
         GameVars.emptyFunc, onTouchEnded)
end


function GatherSoulMainView:showCell(_show)

	self:showEffectdenglong()
	if self.windows ~= nil then
		for k,v in pairs(self.windows) do
			v:setVisible(_show)
		end
	end
	
end


function GatherSoulMainView:nextView()

		self:addSchedule()

		self:showCell(false)

		self.spineEffect2:playLabel("UI_chouka_xiaojiang",false)
		self.playSpineName = "UI_chouka_xiaojiang"
		self.spineEffect2:play()

end


function GatherSoulMainView:effectEvent(event)
	self.posArr = event.params.pos
	self.reward = event.params.reward
	self:disabledUIClick()
	self.UI_button:showyijianjiasu(false)
	self:setTopButTopinisShow(false)
	-- dump(self.posArr,"播特效的点=2222===")
	-- dump(self.reward,"奖励数据=2222===")
	-- echoError("99999999999999999999999999999")
	self.saverpartnerdata = {}
	self.effectIndex = 1
	self:addGetRewardEffect(self.reward,self.posArr,self.effectIndex)
end

function GatherSoulMainView:uiBackToEffectEvent()
	self:addGetRewardEffect(self.reward,self.posArr,self.effectIndex)
end

function GatherSoulMainView:addGetRewardEffect(reward,arrPos,index)
	
	-- dump(arrPos,"播特效的点==33、3333==")
	-- dump(self.windows,"播特效的点==444444444444==")
	-- echo("=======index=======",index)
	local pos = arrPos[index]
	local panelView = self.windows[pos]
	if  self.ctn_eff then
		self.ctn_eff:removeAllChildren()
	end

	local arrReward = reward[index]
	if panelView == nil or not arrReward then
		NewLotteryModel:removegatherSoulData()
		-- EventControler:dispatchEvent(NewLotteryEvent.REMOVE_ALL_VIEW_CELL)
		self:delayCall(function( )
			-- self:removeAllCell()
			self:resumeUIClick()
			self.viewIsSureTouch = true
			self.panel_djjx:setVisible(true)
			self.isInTutorial = false
			self.UI_button.panel_jt:setVisible(false)
			NewLotteryModel:setquickJuHunReward()
			NewLotteryModel:setIsContinueSoulButton()
		end,0.2)
		NewLotteryModel:setquickJuHunReward()
		NewLotteryModel:setIsContinueSoulButton()

		return
	end

	panelView:unscheduleUpdateHx()
	panelView.ctn_press:setVisible(false)
	panelView.panel_zaowuzhuangtai2:setVisible(false)
	
	local data = string.split(arrReward,",")
	local _type = data[1]
	local rewardID = data[2]
	
	local newReward,isSaveNum = self:getPartnerData(arrReward)
	if not newReward then
		newReward = arrReward --reward[index]
	end
	

	local rewardUI =  WindowControler:createWindowNode("GatherSoulRewardUIView",newReward)
	rewardUI:setVisible(false)
	rewardUI.panel_bd:setVisible(false)
	rewardUI:initData(newReward)
	panelView:addChild(rewardUI)
-- panelView:setVisible(false)

	---[[
	--不是完成伙伴的时候
	if _type ~= FuncDataResource.RES_TYPE.PARTNER then
		local flaName = "UI_wupinbao_02"
		local armatureName = "UI_wupinbao_02_wupin"
		local ctn = panelView
		local aim = self:createUIArmature(flaName, armatureName ,ctn, false ,function ()
			 
		end )

		aim:registerFrameEventCallFunc(15,1,function ()
			self.effectIndex = self.effectIndex + 1
			self:addGetRewardEffect(reward,arrPos,self.effectIndex)
		end)

		rewardUI:setPosition(cc.p(0,0))
		rewardUI.panel_zi:setPosition(cc.p(-130,13))
		FuncArmature.changeBoneDisplay(aim:getBoneDisplay("tubiao"), "node", rewardUI)  --替换
		FuncArmature.changeBoneDisplay(aim:getBoneDisplay("zi01"):getBoneDisplay("layer1"), "node", rewardUI.panel_zi)  --替换
		aim:startPlay(false,true)

	else ---是完整的伙伴
		local aimPos = pos
		-- local flaNameArr = {
		-- 	[1]  = "UI_chouka_bao01",
		-- 	[2]  = "UI_chouka_bao02",
		-- 	[3]  = "UI_chouka_bao03",
		-- 	[4]  = "UI_chouka_bao04",
		-- 	[5]  = "UI_chouka_bao05",
		-- }
		local armatureName = {
			[1] = "UI_chouka_bao_tw03",
			[2] = "UI_chouka_bao_tw04",
			[3] = "UI_chouka_bao_tw05",
			[4] = "UI_chouka_bao_tw01",
			[5] = "UI_chouka_bao_tw02",
		}

		local ctn = panelView
		local flaName = "UI_chouka_bao"
		local aim1 = self:createUIArmature(flaName, "UI_chouka_bao01" ,ctn, false ,function ()
		end)
		aim1:registerFrameEventCallFunc(10,1,function ()
			local aim2 = self:createUIArmature(flaName, armatureName[aimPos] ,self.ctn_eff, false ,function ()
				self:delayCall(function ()
					-- echo("======是完整的伙伴========")
					rewardUI:setPosition(cc.p(0,0))
					-- rewardUI.panel_zi:setPosition(cc.p(-130,13))
					local function callBack()
						panelView:setVisible(true)
						rewardUI:setVisible(true)
						rewardUI.panel_bd:setVisible(true)
						rewardUI.panel_zi:setVisible(true)
						self.effectIndex = self.effectIndex + 1
						self:addGetRewardEffect(reward,arrPos,self.effectIndex)
						if isSaveNum then
							WindowControler:showTips(FuncTranslate._getLanguageWithSwap("#tid_lottery_gettips_1", isSaveNum))--"该奇侠已拥有,转换为"..isSaveNum.."个命魂")
						end
					end

					local partnerID = data[2]
					local param = {
			            id = partnerID,
			            skin = "1",
			       	}
			       	WindowControler:showTutoralWindow("PartnerSkinFirstShowView",param,callBack)
				end)
			end)
		end)
	end
	--]]
end


function GatherSoulMainView:getPartnerData(reward)
	-- self:serversToLocalPartner()
	local data = string.split(reward,",")
	local awardstring = nil
	local rewardtype = data[1]
	local partnerID = data[2]
    local partnerData = self.partnerDataArr
    local rewardnumber = 1
    local isSaveNum =  nil
    if rewardtype ==  FuncDataResource.RES_TYPE.PARTNER then

	    if partnerData and partnerData[tostring(partnerID)] == nil then  --伙伴数据库里是否存在该伙伴
	    	if self.saverpartnerdata[tostring(partnerID)] ~= nil then
		    	rewardnumber = FuncPartner.getPartnerById(partnerID).sameCardDebris
	    		rewardtype = 1
	    		isSaveNum = rewardnumber
	    	else
	    		self.saverpartnerdata[tostring(partnerID)] = partnerID
		    end
		    self.partnerDataArr[tostring(partnerID)] = partnerID
		    
	    else
	    	rewardnumber = FuncPartner.getPartnerById(partnerID).sameCardDebris
	    	rewardtype = 1
	    	isSaveNum = rewardnumber
	    end
	    return   rewardtype..","..partnerID..","..rewardnumber,isSaveNum
	end

	return nil,isSaveNum
end







return GatherSoulMainView;
