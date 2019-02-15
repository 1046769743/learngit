-- GatherSoulHuaXingView
--Author:    wk
--DateTime:    2018-05-08 
--Description: 三皇台（化形主界面）

local GatherSoulHuaXingView = class("GatherSoulHuaXingView", UIBase);

function GatherSoulHuaXingView:ctor(winName)
    GatherSoulHuaXingView.super.ctor(self, winName)
end

function GatherSoulHuaXingView:loadUIComplete()
	self:registerEvent()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yijianjiasu,UIAlignTypes.Middle)  --RightTop
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_xialajiantou,UIAlignTypes.LeftBottom)
end 


function GatherSoulHuaXingView:registerEvent()
	GatherSoulHuaXingView.super.registerEvent(self)
	-- EventControler:addEventListener(NewLotteryEvent.REFRESH_CREATE_VIEW,self.iniData,self);
	-- EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.setSpeedUpFu, self)

	-- self.btn_xialajiantou:setTouchedFunc(c_func(self.nextView, self),nil,true);

	-- self:showNextButton()
	-- self:iniData()
	self.frameCount = 1
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
end

function GatherSoulHuaXingView:createInitIcon()
	
	local spineEffect = ViewSpine.new("UI_chouka_zhuangtai",{},nil,nil)
	spineEffect:addTo(self.ctn_press)
	spineEffect:playLabel("UI_chouka_loop3")
	self.panel_zaowuzhuangtai2:setVisible(false)
end

function GatherSoulHuaXingView:cellSortData()
	if self._indexPos == nil then
		return 
	end

	local allData = NewLotteryModel:getGatherSoulData()
	local sortFunc = function (a,b)
		if tonumber(a.id) < tonumber(b.id) then
			return true
		end
		return false
	end
	table.sort(allData,sortFunc)
			
	-- dump(allData,"22222222")
	local maxNumber = 0
	-- for k,v in pairs(allData) do
	for i=1,table.length(allData) do
		local v = allData[i]
		if v.finishTime > TimeControler:getServerTime() then
			maxNumber = maxNumber + 1
		end
		if maxNumber > FuncNewLottery:onTimeCreation() then
			v.isCreation = true
		else
			v.isCreation = false
		end
		-- end
	end

	local havedata = nil
	for k,v in pairs(allData) do
		if v.pos == self._indexPos then
			havedata = v
		end
	end
	
	self.posdata = havedata
end

--初始化数据
function GatherSoulHuaXingView:initData(_index)
	-- if not self.posdata then
	-- 	return 
	-- end
-- 

	self.panel_zaowuzhuangtai2:setVisible(false)
	self._indexPos = _index
	-- echo("========self._indexPos=======",self._indexPos)
	self:cellSortData()
	if not self.spineEffect then
		self.spineEffect = ViewSpine.new("UI_chouka_zhuangtai",{},nil,nil)
		self.spineEffect:addTo(self.ctn_press)
	end
	-- local sumrotation = 10
	-- local guding = 8
	-- local mathNum = math.random(1,sumrotation)
	-- local rotation = 0
	-- if mathNum > sumrotation/2 then
	-- 	rotation = -guding
	-- else
	-- 	rotation = guding
	-- end

	-- self.ctn_press:setRotation(rotation)

	self.touchNode = display.newNode()
	self.touchNode:addTo(self.spineEffect)
	self.touchNode:anchor(0.5,0.5)
	self.touchNode:setContentSize(cc.size(90,90))

	local itemData = self.posdata
	local panel = self.panel_zaowuzhuangtai2
	-- panel.mc_2:setVisible(false)
	local pos = itemData.pos or 1
	local finishTime = itemData.finishTime
	if TimeControler:getServerTime() >= finishTime then --完成
		panel.mc_wenzitishi:showFrame(3)
		-- local button = panel.mc_wenzitishi:getViewByFrame(3)
		self.touchNode:setTouchedFunc(c_func(self.finshCreationButton,self,itemData),nil,true);

		local text = panel.mc_wenzitishi.currentView.txt_1
		text:setVisible(false)
		panel.panel_tu2:setVisible(false)
		self.spineEffect:playLabel("UI_chouka_loop3")
		-- self.spineEffect:setSlotVisible("ninju", true)
		-- self.spineEffect:gotoAndStop(0)
	else
		--等待造物和时间
		-- local length =  table.length(self.isCreation)
		-- if length < FuncNewLottery:onTimeCreation() then
			-- self.isCreation[v.id] = v
		if not itemData.isCreation  then
			panel.mc_wenzitishi:showFrame(2)
			local time = self:calculateTime(itemData.finishTime)
			local text = panel.mc_wenzitishi.currentView.txt_1
			-- text:setVisible(false)
			text:setString(time)
			-- local button = panel.mc_wenzitishi:getViewByFrame(2)
			self.touchNode:setTouchedFunc(c_func(self.showCDButton,self,itemData),nil,true);
			self.spineEffect:playLabel("UI_chouka_loop2")
			self.spineEffect:play()
		else
			self.spineEffect:playLabel("UI_chouka_loop5")
			panel.mc_wenzitishi:showFrame(1)  --显示在造物
			-- local button = panel.mc_wenzitishi:getViewByFrame(1)
			self.touchNode:setTouchedFunc(c_func(self.showdengdai,self,itemData),nil,true);
			local text = panel.mc_wenzitishi.currentView.txt_1
			text:setVisible(false)
			panel.panel_tu2:setVisible(false)
		end
	end



end

function GatherSoulHuaXingView:showCDButton(itemData)
	-- WindowControler:showTips("正在聚魂倒计时")
	WindowControler:showWindow("NewLotterySpeedUpView",true,nil,itemData)

end

function GatherSoulHuaXingView:showdengdai(itemData)
	-- WindowControler:showTips("聚魂等待中")
	-- WindowControler:showWindow("NewLotterySpeedUpView",true,nil,itemData)
	WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1027"))
	-- if not self.playSpineLabel  then
	-- 	self.spineEffect:playLabel("UI_chouka_loop3")
	-- 	-- self.spineEffect:setSlotVisible("ninju", false)
	-- 	self.spineEffect:play()
	-- 	self.playSpineLabel = true
	-- end
end







function GatherSoulHuaXingView:showNextButton()
	---新手引导，和新系统开启
	if TutorialManager.getInstance():isHomeExistGuide() then
		self.btn_xialajiantou:setVisible(true)
	else
		local count =  NewLotteryModel:getnextButtonNum()
		-- echoError("=====count========",count)
		if count == 0 then
			self.btn_xialajiantou:setVisible(true)
			LS:prv():set(StorageCode.lottery_pos_save,1)
			NewLotteryModel.nextButton = 1
		else
			self.btn_xialajiantou:setVisible(false)
		end
    end
end






--播放灯聚魂的动画
function GatherSoulHuaXingView:playSpineDengEffect(pos)
	self.playDengEffect = nil

	if not self.spineEffect then
		self.spineEffect = ViewSpine.new("UI_chouka_zhuangtai",{},nil,nil)
		self.spineEffect:addTo(self.ctn_press)
	end

	self.dengEffectpos = pos


	self._indexPos = pos
	self:cellSortData()

	local itemData = self.posdata
	if itemData then
		local finishTime = itemData.finishTime
		if TimeControler:getServerTime() >= finishTime then --完成
		else
			if not itemData.isCreation  then
				self.spineEffect:playLabel("UI_chouka_loop1")
				self.playDengEffect = "UI_chouka_loop1"
				
			else
				self.spineEffect:playLabel("UI_chouka_loop5")
				-- self.spineEffect:setSlotVisible("ninju", false)
				-- self.spineEffect:gotoAndStop(0)
				self.playDengEffect = "UI_chouka_loop5"
			end
		end
	else
		self.spineEffect:playLabel("UI_chouka_loop5")
		-- self.spineEffect:setSlotVisible("ninju", false)
		-- self.spineEffect:gotoAndStop(0)
		self.playDengEffect = "UI_chouka_loop5"
	end
	self.spineEffect:play()

	self.panel_zaowuzhuangtai2:setVisible(false)

end
function GatherSoulHuaXingView:setposData( pos )
	self._indexPos = pos
	-- echo("========self._indexPos====11111=====",self._indexPos)
end



function GatherSoulHuaXingView:updateFrame()

	if self.playDengEffect then
		if self.spineEffect then
			local currentFrame = self.spineEffect:getCurrentFrame()
			-- echo("1=======1111111111======",self._indexPos,currentFrame)
			if self.playDengEffect == "UI_chouka_loop1" then
				if currentFrame >= (44 - 1) then
					self.playDengEffect = nil
					self:initData(self._indexPos)
				end
			elseif self.playDengEffect == "UI_chouka_loop5" then
				if currentFrame == 0 then
					self.playDengEffect = nil
					self:initData(self._indexPos)
				end
			end
		end
		return 
	end

	self:cellSortData()
	if self.posdata ~= nil then
		local v = self.posdata
		local pos = v.pos or 1
		local finishTime = v.finishTime
		local panel = self.panel_zaowuzhuangtai2
		local serverTime = TimeControler:getServerTime() 
		panel:setVisible(true)
		if serverTime < finishTime then --未完成
			if  self.posdata.isCreation then
				panel.mc_wenzitishi:showFrame(1)  --显示在造物
			
				if  self.playSpineLabel then
					local currentFrame = self.spineEffect:getCurrentFrame()
					-- echo("======currentFrame========",currentFrame,self.maxFrame)
					if currentFrame >= (40 - 1) then
						self.playSpineLabel = false
						self.spineEffect:stop()
					end
				else
					-- self.spineEffect:play()
					self.spineEffect:playLabel("UI_chouka_loop6")
					-- self.spineEffect:setSlotVisible("ninju", false)
					-- self.spineEffect:gotoAndStop(0)
				end
				local text = panel.mc_wenzitishi.currentView.txt_1
				text:setVisible(true)
				panel.panel_tu2:setVisible(true)
			else
				-- echo("222222222=========",pos)
				panel.mc_wenzitishi:showFrame(2)
				local time = self:calculateTime(finishTime)
				local text = panel.mc_wenzitishi.currentView.txt_1
				text:setVisible(true)
				text:setString(time)
				panel.panel_tu2:setVisible(true)
				panel:setVisible(true)
				if self.touchNode then
					self.touchNode:setTouchedFunc(c_func(self.showCDButton,self,self.posdata),nil,true);
				end
				self.spineEffect:playLabel("UI_chouka_loop2")
				-- self.spineEffect:setSlotVisible("ninju", true)
				self.spineEffect:play()
			end
		else
			if not self.getnewReward then
				self.spineEffect:playLabel("UI_chouka_loop3")
				-- self.spineEffect:setSlotVisible("ninju", true)
				panel.mc_wenzitishi:showFrame(3)
				if self.touchNode then
					self.touchNode:setTouchedFunc(c_func(self.finshCreationButton,self,self.posdata),nil,true);
				end
				-- panel:setTouchedFunc(c_func(self.finshCreationButton,self,v));
				local text = panel.mc_wenzitishi.currentView.txt_1
				text:setVisible(true)
				panel.panel_tu2:setVisible(true)
			end
		end
	end
	if self.getnewReward then
		local currentFrame = self.spineEffect:getCurrentFrame()
		if currentFrame >= 39 then
			self.spineEffect:gotoAndStop(0)
			self:finshCreationButton(self.getnewReward)
		end
	end
end

--完成造物按钮
function GatherSoulHuaXingView:finshCreationButton(itemdata)
	-- if not self.getnewReward then
	-- 	self.spineEffect:playLabel("UI_chouka_loop4")
	-- 	self.spineEffect:play()
	-- 	self.getnewReward = itemdata
	-- 	return
	-- end
	local allData = NewLotteryModel:getGatherSoulData()
	local serverTime = TimeControler:getServerTime()
	local pos = {}
	for k,v in pairs(allData) do
		if serverTime >=  v.finishTime then
			table.insert(pos,v.pos)
		end
	end

	local function _cllback(event)
		if event.result then
			local reward = event.result.data.reward
			dump(reward,"=======--完成造物数据返回=======")
			-- local newReward = {}
			-- for k,v in pairs(reward) do
			-- 	 local data = string.split(v, ",")
			-- 	 table.insert(newReward,data)
			-- end
			-- NewLotteryModel:setServerData(newReward)
			-- NewLotteryModel:removegatherSoulData()
			-- WindowControler:showWindow("NewLotteryJieGuoView")


			EventControler:dispatchEvent(NewLotteryEvent.ADD_JUHUN_EFFECT,{pos = pos ,reward = reward})
			-- self.getnewReward = nil
			-- EventControler:dispatchEvent(NewLotteryEvent.REFRESH_ZAOWU_FINISH_UI,{itemdata.pos})
		else
			local error_code = event.error.code 
			local tip = GameConfig.getErrorLanguage("#error"..error_code)
			WindowControler:showTips(tip)
		end
		
	end
	local params = {}
	params = {
		id = itemdata.id,
		isAll = 1,
	}

	NewLotteryServer:finishLottery(params,_cllback)


end


function GatherSoulHuaXingView:calculateTime(_finishTime)
	local times = _finishTime - TimeControler:getServerTime()
	if times > 0 then
		times = TimeControler:turnTimeSec(times, TimeControler.timeType_hhmmss)
	else
		times = nil
	end
	return times
end


--批量造物
function GatherSoulHuaXingView:batchCreationButton()
	echo("=========批量造物==========")


	local data = NewLotteryModel:getGatherSoulData()
	local count = FuncNewLottery.getMaxCreateAllItem()

	if table.length(data) <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1013"))
		return
	end
	local remainingNum = NewLotteryModel:speedUpItremData()
	echo("======remainingNum========",remainingNum)
	if remainingNum <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1026"))
		WindowControler:showWindow("GetWayListView",FuncNewLottery.getCostItemId())
		return 
	end

	local function _cllback(event)
		if event.result then
			dump(event.result,"=======--加速造物据数据返回=======")
			WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1014"))
			local reward = event.result.data.reward
			local newReward = {}
			for k,v in pairs(reward) do
				local data = string.split(v, ",")
				table.insert(newReward,data)
			end
			NewLotteryModel:setServerData(newReward)
			NewLotteryModel:removegatherSoulData()
			WindowControler:showWindow("NewLotteryJieGuoView")
			EventControler:dispatchEvent(NewLotteryEvent.GATHERSOUL_ALL_TODO_VIEW)
		else
			local error_code = event.error.code 
			local tip = GameConfig.getErrorLanguage("#error"..error_code)
			WindowControler:showTips(tip)
		end
		self:iniData()
	end
	local arrID = {}
	if remainingNum >= count then
		remainingNum = count
	end
	for i=1,remainingNum do
		if data[i] then
			arrID[i] = data[i].id
		end
	end

	local params = {
		ids = arrID,
	}
	NewLotteryServer:speedUpLottery(params,_cllback)

end

function GatherSoulHuaXingView:unscheduleUpdateHx()
	self:unscheduleUpdate()
end




	


return GatherSoulHuaXingView;
