-- GatherSoulSpineView:
--Author:    wk
--DateTime:    2018-05-08 
--Description: 三皇台（聚魂主界面）

local GatherSoulSpineView = class("GatherSoulSpineView", UIBase);

function GatherSoulSpineView:ctor(winName)
    GatherSoulSpineView.super.ctor(self, winName)
end

function GatherSoulSpineView:loadUIComplete()
	self:registerEvent()
	-- FuncCommUI.setViewAlign(self.widthScreenOffset,self.btn_yulan,UIAlignTypes.RightBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jvhun1ci,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_jvhun5ci,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_yijianjiasu,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_ksjh,UIAlignTypes.MiddleBottom)
	FuncCommUI.setViewAlign(self.widthScreenOffset,self.panel_2,UIAlignTypes.Right)
	
	self.panel_2.btn_yulan:setTouchedFunc(c_func(self.clickButtonPreview, self),nil,true);

	self.panel_jt:setTouchedFunc(c_func(self.touchNext, self),nil,true);


	self.panel_ksjh:setVisible(false)
	self.panel_jvhun1ci:setVisible(false)
	self.panel_jvhun5ci:setVisible(false)
	self.panel_2:setVisible(false)

	self:uiPanelRunaction()

	local alldata = NewLotteryModel:getallPreviewData()
	self.allpantner = {}
	self.beenShownArr = {}
	self.fourStar = {}
	self.remainingStar = {}
	self.saveFourStar = {}
	for i=1,#alldata do
		if alldata[i]._type == "18" then
			table.insert(self.allpantner,alldata[i])
			if alldata[i].star >= 4 then
				table.insert(self.fourStar,alldata[i])
			else
				table.insert(self.remainingStar,alldata[i])
			end
		end
	end

	self:setRightPantnerIcon()
	self:scheduleUpdateWithPriorityLua(c_func(self.updateFrame, self) ,0)
	self.frameCount = 1 
	self.fastButton = {}
	self.oneButton = {}
	self.fastButton.x = self.panel_ksjh:getPositionX()
	self.fastButton.y = self.panel_ksjh:getPositionY()

	self.oneButton.x = self.panel_jvhun1ci:getPositionX()
	self.oneButton.y = self.panel_jvhun1ci:getPositionY()

	
	self:checkButton()
	self.panel_ksjh.txt_1:setTouchedFunc(c_func(self.checkButton, self),nil,true);
	self.panel_ksjh.btn_1:getUpPanel().panel_red:visible(false)

	self:showFastButton()

end 


--勾选按钮
function GatherSoulSpineView:checkButton(pames)
	local isQuickBuy =  NewLotteryModel:checkIsQuickBuySoul(  )
	if not pames  then
		isQuickBuy =  not isQuickBuy
	end
	if isQuickBuy then
		self.panel_ksjh.panel_1:setVisible(false)
		NewLotteryModel:setQuickBuySoul(false)
	else
		self.panel_ksjh.panel_1:setVisible(true)
		NewLotteryModel:setQuickBuySoul(true)
	end
end

function GatherSoulSpineView:showGou()
	local isQuickBuy =  NewLotteryModel:checkIsQuickBuySoul()
	if isQuickBuy then
		self.panel_ksjh.panel_1:setVisible(true)
	else
		self.panel_ksjh.panel_1:setVisible(false)
	end
end


--显示快速聚魂的按钮
function GatherSoulSpineView:showFastButton(isshow)
	if isshow ~= nil then
		if type(isshow) == "boolean" and not isshow then
			return 
		end
	end
	local num = FuncDataSetting.getOriginalData("LotteryQuicklyGet")
	local lotteryConditions = FuncDataSetting.getDataArrayByConstantName("LotteryConditions")
	local str = lotteryConditions[1]
	local rechargeNum  = UserModel:rechargeTotal()   --测试
	-- echoError("========rechargeNum==============",rechargeNum)
	local res = string.split(str, ",")
	local conditionGroup = {{t = tonumber(res[1]),v = res[2]}}
	local isopen = UserModel:checkCondition( conditionGroup)

	if not isopen and rechargeNum >= num then
		self.panel_ksjh:setVisible(true)
		local x = self.panel_jvhun1ci:getPositionX()
		if x ~= self.oneButton.x then
			self.panel_jvhun1ci:setPosition(cc.p(self.oneButton.x,self.oneButton.y))
		end
	else
		local x = self.panel_jvhun1ci:getPositionX()
		if x ~= self.fastButton.x then
			self.panel_jvhun1ci:setPosition(cc.p(self.fastButton.x,self.fastButton.y))
		end
		self.panel_ksjh:setVisible(false)
	end
end

---界面的动画
function GatherSoulSpineView:uiPanelRunaction()
	local panelArr = {
		[1] = self.panel_ksjh,
		[2] = self.panel_jvhun1ci,
		[3] = self.panel_jvhun5ci,
	}
	
	for i=1,#panelArr do
		panelArr[i]:setVisible(true)
		local dx = panelArr[i]:getPositionX()
		local dy = panelArr[i]:getPositionY()
		panelArr[i]:setPositionY(dy - 150)
		local act1 = act.moveto(0.3, dx ,dy)
		panelArr[i]:runAction(act1)
	end
	self.panel_2:setVisible(true)
	local dx1 = self.panel_2:getPositionX()
	local dy2 = self.panel_2:getPositionY()
	self.panel_2:setPositionX(dx1 + 200)
	local act = act.moveto(0.3, dx1-10 ,dy2)
	self.panel_2:runAction(act)

end


function GatherSoulSpineView:updateFrame()
	if self.frameCount then
		if self.frameCount % (GameVars.GAMEFRAMERATE*3) == 0 then
			self:rightPartnerIconAction()
			self:setRightPantnerIcon()
	    end 
	    self.frameCount = self.frameCount + 1
	end
end

--播放动画
function GatherSoulSpineView:rightPartnerIconAction()
	if self.pantnerIconArr  then
		local num = table.length(self.pantnerIconArr)
		if num ~= 0 then
			for k,v in pairs(self.pantnerIconArr) do
				local dx = v:getPositionX()
				local dy = v:getPositionY()
				local act1 = act.moveto(0.5, dx + 100,dy)
				local act2 = act.fadeto(0.5,0)
				local actque = act.spawn(act1,act2)
				v:runAction(actque)
			end
		end
	end
end

function GatherSoulSpineView:setPantnerData(newarr)
	for i=1,3 do
		if not newarr[i] then
			for k,v in pairs(self.remainingStar) do
				local issave = false
				for _k,_v in pairs(self.beenShownArr) do
					if v.itemID == _v.itemID  then
						issave = true
					end
				end
				for key,valuer in pairs(newarr) do
					if valuer.itemID == v.itemID then
						issave = true
					end
				end
				if not newarr[i] then
					if not issave then
						newarr[i] = v
					end
				end
			end
		end
	end
	if #newarr <= 3 then
		for i=1,3 do
			if not newarr[i] then
				newarr[i] = self.remainingStar[i]
			end
		end
	end
	return newarr
end

--设置右侧
function GatherSoulSpineView:setRightPantnerIcon()
	local percentage = 30
	local newarr = {}
	if #self.beenShownArr ~= 0 then
		if #self.beenShownArr >= #self.allpantner then
			self.beenShownArr = {}
		end
		local int  = RandomControl.getOneRandomInt(100,1)
		-- echo("=========int==========",int)
		if int >= percentage  then
			local pos = math.random(1,3)
			local index = 1 --math.random(1,#self.fourStar)
			if #self.saveFourStar >= #self.fourStar then
				self.saveFourStar = {}
			end
			local function checkPartner(index)
				-- echo("=========index===11111====",index)
				local data = self.fourStar[index]
				if data then
					local issave = false
					for k,v in pairs(self.saveFourStar) do
						if v.itemID == data.itemID then 
							issave = true
						end
					end
					if issave then
						index = index + 1
						checkPartner(index)
					else
						if not issave then
							newarr[pos] = self.fourStar[index]
							table.insert(self.saveFourStar,self.fourStar[index])
						end
					end
				end
			end
			checkPartner(index)
			newarr = self:setPantnerData(newarr)
		else
			newarr = self:setPantnerData(newarr)
		end
	else
		for i=1,3 do
			newarr[i] = self.remainingStar[i]
		end
		local int  = RandomControl.getOneRandomInt(100,1)
		if int >= percentage then
			local pos = math.random(1,3)
			local index = math.random(1,#self.fourStar)
			newarr[pos] = self.fourStar[index]
			table.insert(self.saveFourStar,self.fourStar[index])
		end
	end

	-- dump(newarr,"所有奇侠数据=======")
	self:rightPartnerIconAction()
	self.pantnerIconArr = {}
	for i=1,3 do
		local partnerData = newarr[i]
		table.insert(self.beenShownArr,partnerData)
		self.panel_2["mc_"..i]:setVisible(false)
		local _mc =  UIBaseDef:cloneOneView(self.panel_2["mc_"..i]);
		local x = self.panel_2["mc_"..i]:getPositionX()
		local y = self.panel_2["mc_"..i]:getPositionY()
		_mc:setPosition(cc.p(x,y))
		self.panel_2:addChild(_mc)
		self.pantnerIconArr[i] = _mc
		_mc:setTouchedFunc(c_func(self.showPartnerListUI, self,partnerData),nil,true);
		FuncNewLottery.setpartnerIconById(partnerData,_mc)
		_mc:setOpacity(0)
		local act2 = act.fadeto(0.8,255)
		_mc:runAction(act2)
	end

end

--显示伙伴详情列表
function GatherSoulSpineView:showPartnerListUI(partnerData)
	echo("=======partnerData=======",partnerData.itemID)
	-- WindowControler:showWindow("GatherSoulSpinePartnerListView",partnerData.itemID)--{id = partnerData.itemID},UserModel:data(),false)
	WindowControler:showWindow("NewLotteryPreviewListView",partnerData.itemID)
end


function GatherSoulSpineView:touchNext()
	if not self.touch_event then
		self:showyijianjiasu(false)
		EventControler:dispatchEvent(NewLotteryEvent.NEXT_VIEW_UI)
		self.touch_event = true
	end	
end

function GatherSoulSpineView:clickButtonPreview()
	echo("====预览==按钮==")
	WindowControler:showWindow("NewLotteryPreviewListView")
end

function GatherSoulSpineView:registerEvent()
	GatherSoulSpineView.super.registerEvent(self)
	-- EventControler:addEventListener(FriendEvent.FRIEND_APPLY_REQUEST,self.notifyFriendApply,self);
	-- self:setLanternIsShow() 
	EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.refreshUICount, self)
	EventControler:addEventListener(NewLotteryEvent.SHOW_SPEEDUP_BUTTON, self.showyijianjiasu, self)

	EventControler:addEventListener(NewLotteryEvent.REFRESH_ZAOWU_FINISH_UI,self.setButtonCount,self);

	EventControler:addEventListener(RechargeEvent.FINISH_RECHARGE_EVENT,self.showFastButton,self);
	EventControler:addEventListener(NewLotteryEvent.QUICK_BUY_SOUL,self.showGou,self);
	EventControler:addEventListener(NewLotteryEvent.CONTINUE_BUTTON,self.fastBuyButton,self);

	

	self:showNextButton()
	self:setGatherSoulButton()
end

function GatherSoulSpineView:refreshUICount()
	self:setSpeedUpFu()
	self:setButtonCount(true)
end

function GatherSoulSpineView:showNextButton()
	---新手引导，和新系统开启
	self.panel_jt:setVisible(false)
	if TutorialManager.getInstance():isInTutorial() then
		self.panel_jt:setVisible(true)
	else
		local count =  NewLotteryModel:getnextButtonNum()
		-- echoError("=====count========",count)
		if count == 0 then
			self.panel_jt:setVisible(true)
			LS:prv():set(StorageCode.lottery_pos_save,1)
			NewLotteryModel.nextButton = 1
		else
			self.panel_jt:setVisible(false)
		end
    end
end

function GatherSoulSpineView:setLanternIsShow()
	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	for i=1,maxCount do
		self["panel_deng"..i]:setVisible(false)
	end
end


--设置聚魂按钮
function GatherSoulSpineView:setGatherSoulButton()

	local panel1 =  self.panel_jvhun1ci
	self.buttonPos = panel1:getPositionX()

	self:setButtonCount()
	self:setSpeedUpFu()

end

--设置加速符的数量
function GatherSoulSpineView:setSpeedUpFu()
	local remainingNum = NewLotteryModel:speedUpItremData()
	if tonumber(remainingNum) >= 9999 then
		remainingNum = 9999
	end



	local alldata = NewLotteryModel:getGatherSoulData()
	local num = table.length(alldata)


	self.panel_yijianjiasu.txt_1:setString(remainingNum.."/"..num)
	-- self.panel_yijianjiasu:setVisible(true)
	
	local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
	if isAllfinish then
		self.panel_yijianjiasu.btn_yijianjiasu:setTouchedFunc(c_func(self.allFinish, self),nil,true);
		self.panel_yijianjiasu.btn_yijianjiasu:getUpPanel().mc_1:showFrame(2)
		self.panel_yijianjiasu.panel_tu1:setVisible(false)
		self.panel_yijianjiasu.txt_1:setVisible(false)
	else
		self.panel_yijianjiasu.btn_yijianjiasu:setTouchedFunc(c_func(self.sureButton, self),nil,true);
		self.panel_yijianjiasu.btn_yijianjiasu:getUpPanel().mc_1:showFrame(1)
		self.panel_yijianjiasu.panel_tu1:setVisible(true)
		self.panel_yijianjiasu.txt_1:setVisible(true)
	end
end






--一键加速
function GatherSoulSpineView:allFinish()
	
	local alldata = NewLotteryModel:getGatherSoulData()
	self:finshCreationButton(alldata[1])


end


-- --批量造物
-- function GatherSoulSpineView:batchCreationButton()
-- 	echo("=========批量造物==========")
-- 	local function _callback( ... )
-- 		self:setButtonCount()
-- 	end


-- 	WindowControler:showWindow("NewLotterySpeedUpView",true,_callback)

-- end



--完成造物按钮
function GatherSoulSpineView:finshCreationButton(itemdata)

	-- echo("========完成造物按钮===========")


	-- local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
	local alldata = NewLotteryModel:getGatherSoulData()
	local serverTime = TimeControler:getServerTime()
	local pos = {}
	for k,v in pairs(alldata) do
		if serverTime >=  v.finishTime - 3 then
			table.insert(pos,v.pos)
		end
	end
	local posSort = function(a, b)
		return tonumber(a) < tonumber(b)
	end
	table.sort(pos, posSort)

			

	local function _cllback(event)
		if event.result then
			local reward = event.result.data.reward

			EventControler:dispatchEvent(NewLotteryEvent.ADD_JUHUN_EFFECT,{pos = pos ,reward = reward})
			self:setSpeedUpFu()

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

--确定按钮
--批量造物
function GatherSoulSpineView:sureButton()
	echo("=========批量造物==========")

	local alldata = NewLotteryModel:getGatherSoulData()
	local count = FuncNewLottery.getMaxCreateAllItem()

	if table.length(alldata) <= 0 then
		WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1013"))
		return
	end
	local remainingNum = NewLotteryModel:speedUpItremData()

	if remainingNum <= 0 then
		-- WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1026"))
		-- WindowControler:showWindow("GetWayListView",FuncNewLottery.getCostItemId())
		WindowControler:showWindow("QuickBuyItemMainView", FuncNewLottery.getCostItemId())
		return 
	end

	local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()

	if isAllfinish then
		self:finshCreationButton(alldata[1])
		return
	end
	

	local finishPos = {}
	local notFinishPos = {}
	local arrID = {}
	if remainingNum >= count then
		remainingNum = count
	end
	local serverTime = TimeControler:getServerTime() 
	for i=1,5 do
		if alldata[i] then
			if alldata[i].finishTime <= serverTime then
				table.insert(finishPos,alldata[i].pos)
			else
				table.insert(arrID,alldata[i].id)
				table.insert(notFinishPos,alldata[i].pos)
			end
		end
	end

	local newArrId = {}
	-- local newPos = {}
	for i=1,remainingNum do
		if arrID[i] then
			table.insert(newArrId,arrID[i])
			if notFinishPos[i] then
				table.insert(finishPos,notFinishPos[i])
			end
		end
	end


	local posSort = function(a, b)
		return tonumber(a) < tonumber(b)
	end
	table.sort(finishPos, posSort)

	local function _cllback(event)
		if event.result then
			-- dump(event.result,"=======--加速造物据数据返回=======")
			self:showyijianjiasu(false)
			-- WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1014"))
			local reward = event.result.data.reward
			-- local newReward = {}
			-- for k,v in pairs(reward) do
			-- 	local datas = string.split(v, ",")
			-- 	table.insert(newReward,datas)
			-- end
			-- NewLotteryModel:setServerData(newReward)
			-- NewLotteryModel:removegatherSoulData()
			-- WindowControler:showWindow("NewLotteryJieGuoView")
			-- EventControler:dispatchEvent(NewLotteryEvent.REMOVE_ALL_VIEW_CELL)
			EventControler:dispatchEvent(NewLotteryEvent.ADD_JUHUN_EFFECT,{pos = finishPos ,reward = reward})
			self:setButtonCount()
			self:setSpeedUpFu()
		else
			local error_code = event.error.code
			local tip = GameConfig.getErrorLanguage("#error"..error_code)
			WindowControler:showTips(tip)
		end
	end



	local params = {
		ids = newArrId,
	}
	NewLotteryServer:speedUpLottery(params,_cllback)
end

--设置按钮显示的次数
function GatherSoulSpineView:setButtonCount(isrefresh)
	local maxCount = FuncNewLottery.getMaxCreateAllItem() ---聚魂本地的最大次数和可以造物的最大数
	local panel1 =  self.panel_jvhun1ci
	local panel2 = self.panel_jvhun5ci

	-- self:showyijianjiasu(false)

	--高级造物符的数量
	local count = NewLotteryModel:getseniorDrawcard()

	local zaoWuNum =  NewLotteryModel:getLotteryNewData() --正在造物的数量 panel

	local isokZW =   maxCount - table.length(zaoWuNum) --剩余造物的数量
	local houZuiCount = isokZW
	-- echoError("CountModel:getLotteryGoldFreeCount() ====== ",houZuiCount)
	
	if count == 0 then
		local RMBonce = NewLotteryModel:getRMBoneLottery() --花费元宝抽
	    if RMBonce ~= 0 then
	    	panel1.txt_1:setString(count.."/1")
	    	panel1.panel_tu:setVisible(true)

	    	panel1.txt_2:setVisible(false)
	        panel1.txt_1:setVisible(true)

	    elseif RMBonce == 0 then
	        panel1.txt_2:setString("本次免费")
	        panel1.panel_tu:setVisible(false)
	        panel1.txt_2:setVisible(true)
	        panel1.txt_1:setVisible(false)
	    end

	    if houZuiCount == 0 then
	    	houZuiCount = maxCount
	    end

	    if isokZW == 0 then
	    	isokZW = maxCount
	    end

		panel2.txt_1:setString(count.."/"..isokZW)
		local frame = houZuiCount - 1
		if  frame == 0 then
			frame = maxCount - 1
		end

		panel2.btn_2:getUpPanel().mc_1:showFrame(frame)
	else
		
		if count >= isokZW then
			houZuiCount = isokZW
		else
			houZuiCount = count
		end


	    if houZuiCount == 0 or houZuiCount == 1 then
	    	houZuiCount = maxCount
	    end


		local RMBonce = NewLotteryModel:getRMBoneLottery() --花费元宝抽
	    if RMBonce ~= 0 then
	    	panel1.txt_1:setString(count.."/1")
	    	-- panel1.panel_tu:setVisible(true)
	    	panel1.txt_2:setVisible(false)
	        panel1.txt_1:setVisible(true)
	    elseif RMBonce == 0 then
	        panel1.txt_2:setString("本次免费")
	       	-- panel1.panel_tu:setVisible(false)
	       	panel1.txt_2:setVisible(true)
	        panel1.txt_1:setVisible(false)
	    end

		panel2.txt_1:setString(count.."/"..houZuiCount)

		local frame = houZuiCount - 1
		if  frame == 0 then
			frame = maxCount - 1
		end
		panel2.btn_2:getUpPanel().mc_1:showFrame(frame)
	end

	panel1.btn_1:setTouchedFunc(c_func(self.clickButtonOne, self,1),nil,true);
	panel2.btn_2:setTouchedFunc(c_func(self.clickButtonFive, self,houZuiCount),nil,true);
	-- echoError("========houZuiCount=======",houZuiCount,isokZW)
	-- if houZuiCount == 1 then
		-- panel1:setPositionX(self.buttonPos + 200)
		-- if isrefresh and type(isrefresh) == "boolean" then
			-- panel2:setVisible(false)
		-- end
	-- else
		-- panel1:setPositionX(self.buttonPos)
		-- if isrefresh and type(isrefresh) == "boolean" then
			-- panel2:setVisible(true)
		-- end
	-- end

	self.panel_ksjh.btn_1:setTouchedFunc(c_func(self.fastBuyButton, self),nil,true);

	self:setButtonRed()
end

function GatherSoulSpineView:fastBuyButton()
	local pames = nil
	local data = nil
	NewLotteryModel:setIsQucikSoul( true )
	local isLogin = NewLotteryModel:getIsFirstQuickSoulButton()  --本次登录不在提示  
	-- echoError("=====isLogin=======",isLogin)
	if not isLogin then
		pames,data = NewLotteryModel:showGatherSoulQuickCostView(4)
		self:notFirstQuick(pames,data)
	else
		pames,data = NewLotteryModel:showGatherSoulQuickCostView()
		self:yesFirstQuick(pames,data)
	end
end

function GatherSoulSpineView:yesFirstQuick(pames,data)

	if data.needGold == 0 then
		local function cellFunc(eventData)
			-- dump(eventData,"yesFirstQuick ===eventData===")
			local eventData = eventData.result
			self:playjuhunAction(eventData)
		end

		NewLotteryServer:doQuickLottery(cellFunc)
		return
	end

	local isQuickBuy =  NewLotteryModel:checkIsQuickBuySoul(  )
	if isQuickBuy  then
		if data.needGold ~= 0 then
			if UserModel:getGold() <  data.needGold then
				WindowControler:showWindow("MallMainView",FuncShop.SHOP_CHONGZHI)
				return 
			end
		end
		local isEnough = nil
		local data1 = data.items[1]
		local data2 = data.items[2]
		local speedItemId = FuncNewLottery.getCostItemId()  
		local drawCarditemid = FuncNewLottery:getSeniorcardID()
		local speedNum =  NewLotteryModel:speedUpItremData()  --加速符数量
		local drawcardNum = NewLotteryModel:getseniorDrawcard()   ---聚魂灯
		if data1 then
			if drawcardNum < data1.needNums then
				isEnough = drawCarditemid
			end
		end
		if data2 then
			if speedNum< data2.needNums then
				isEnough = speedItemId
			end
		end

		if  not NewLotteryModel:getIsContinueSoulButton() then
			if isEnough  then---资源不足
				WindowControler:showWindow("QuickBuyItemMainView", isEnough)
				return
			end
		end

		local function cellFunc(eventData)
			-- dump(eventData,"yesFirstQuick ===eventData===")
			local eventData = eventData.result
			self:playjuhunAction(eventData)
		end

		NewLotteryServer:doQuickLottery(cellFunc)
	else
		local function cellFunc(eventData)

			-- echo("=========是自动购买=======播放动画==33333333333=")
			-- dump(eventData,"33333333333333")
			self:playjuhunAction(eventData)
		end
		-- echo("5555555555555555555555")
		WindowControler:showWindow("GatherSoulQuickCostView",pames,data,cellFunc);
	end
end
function GatherSoulSpineView:notFirstQuick(pames,data)
	local function cellFunc(eventData)
		-- dump(eventData,"======data==11111111====")
		local isQuickBuy = NewLotteryModel:checkIsQuickBuySoul(  )
		if isQuickBuy then  --是自动购买  --播放动画
			self:playjuhunAction(eventData)
		else
			local function callBack(eventData)
				-- echo("=========是自动购买=======播放动画==222222=")
				-- dump(eventData,"===是自动购买=======播放动画==2=")
				self:playjuhunAction(eventData)
			end
			local pames,data = NewLotteryModel:showGatherSoulQuickCostView()
			local view =  WindowControler:getWindow( "GatherSoulQuickCostView" )
			if view then
				view:initData(pames,data ,callBack)
			else
				self:playjuhunAction(eventData)
			end
		end
	end
	WindowControler:showWindow("GatherSoulQuickCostView",pames,data,cellFunc);
end

--播放聚魂动画
function GatherSoulSpineView:playjuhunAction(data)


	local count,newData = NewLotteryModel:playjuhunAction(data)

	self:setReward(count,newData)
end


--聚魂一次
function GatherSoulSpineView:clickButtonOne()
	 -- NewLotteryModel:getseniorDrawcard()
	 self:onceGatherSoul()
end

--聚魂五次
function GatherSoulSpineView:clickButtonFive(createCount)
	self:fiveGatherSoul(createCount)
end



function GatherSoulSpineView:onceGatherSoul()
	-- if 1 then
	-- 	EventControler:dispatchEvent(NewLotteryEvent.MOVE_CELL_RUNACTION,{5})
	-- 	return 
	-- end

	--高级造物卷
	local drawcard = NewLotteryModel:getseniorDrawcard()
	local rmbOnce = NewLotteryModel:getRMBoneLottery() --花费元宝抽

	local allcreaData = NewLotteryModel:getLotteryNewData()
	local sumNum = FuncNewLottery.getMaxCreateAllItem()
	if table.length(allcreaData) >= sumNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1023"))
		return
	end
	if rmbOnce ~= 0 then
		if drawcard < 1 then
			WindowControler:showWindow("QuickBuyItemMainView", "3009")
			return
		end
	end

	local function _cllback(event)
		if event.result then
			-- dump(event.result,"造物一次返回数据==========")
			-- WindowControler:showTips("造物一次成功")
			local data = event.result.data.dirtyList.u.lotteryQueues
			local alldata = NewLotteryModel:getGatherSoulData()
			local posIndex = 1
			if not alldata or table.length(alldata) == 0 then
				posIndex = 1
			else
				posIndex = NewLotteryModel:randomPos(1)
			end
			-- dump(posIndex,"=====造物一次成功  de 位置======")
			NewLotteryModel:setZaoWuDataAndPos(data,posIndex)
			self:setButtonCount()
			EventControler:dispatchEvent(NewLotteryEvent.MOVE_CELL_RUNACTION,{posIndex})
			
			self:showAllBUtton(false)
		end
	end

	local _type
	if rmbOnce == 0 then
		_type = 0
	else
		_type = 1
	end
	NewLotteryServer:consumeDrawcard(_type,false,_cllback)
end

function GatherSoulSpineView:fiveGatherSoul(count)
		--高级造物卷
	local drawcard = NewLotteryModel:getseniorDrawcard()
	local rmbOnce = NewLotteryModel:getRMBoneLottery() --花费元宝抽

	local allcreaData = NewLotteryModel:getLotteryNewData()
	local sumNum = FuncNewLottery.getMaxCreateAllItem()
	if table.length(allcreaData) >= sumNum then
		WindowControler:showTips(GameConfig.getLanguage("#tid_lottery_1023"))
		return
	end
	echo("======drawcard======",drawcard,count)
	if drawcard <= 0  or drawcard < 2   then
		WindowControler:showWindow("QuickBuyItemMainView", "3009")
		return
	end

	local function _cllback(event)
		if event.result then
			-- dump(event.result,"造物"..count.."次返回数据==========")
			-- WindowControler:showTips("造物"..count.."次成功")
			local data = event.result.data.dirtyList.u.lotteryQueues

			self:setReward(count,data)
		end
	end

	local _type = count
	NewLotteryServer:consumeDrawcard(_type,false,_cllback)

end


function GatherSoulSpineView:setReward(count,data)
	-- echo("=====GatherSoulSpineView===setReward=====11111111====")
	local num = table.length(data)
	local max = FuncNewLottery.getMaxCreateAllItem()
	if num >= max then
		NewLotteryModel.gatherSoulDataPos = {}
	end

	local posIndex = NewLotteryModel:randomPos(5,count)
	-- dump(posIndex,"造物"..count.."次成功 de 位置========")
	NewLotteryModel:setZaoWuDataAndPos(data,posIndex)
	self:setButtonCount()
	local isContinue =  NewLotteryModel:getIsContinueSoulButton()
	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	local alldata = NewLotteryModel:getGatherSoulData()
	if not isContinue then
		if NewLotteryModel:checkIsQuickSoul() then
		-- 	-- EventControler:dispatchEvent(NewLotteryEvent.CONTINUE_BUTTON_FINISH)
			-- echo("=========当前有5个聚魂=正在聚魂=====",table.length(alldata),count)
			EventControler:dispatchEvent(NewLotteryEvent.ALLFINISH_JUHUN)
		else
			-- echo("====非快速聚魂=====当前有5个聚魂======")
			EventControler:dispatchEvent(NewLotteryEvent.MOVE_CELL_RUNACTION,posIndex)
		end
	else
		-- echo("===========GatherSoulSpineView===isContinue=====11111111=========")
		NewLotteryModel:setIsContinueSoulButton()
		EventControler:dispatchEvent(NewLotteryEvent.CONTINUE_BUTTON_FINISH)
	end
	self:showAllBUtton(false)
end




--设置按钮的红点
function GatherSoulSpineView:setButtonRed()
	local panel1 =  self.panel_jvhun1ci
	local panel2 = self.panel_jvhun5ci
	-- local panel3 = self.panel_yijianjiasu

	panel1.btn_1:getUpPanel().panel_red:setVisible(false)
	panel2.btn_2:getUpPanel().panel_red:setVisible(false)
end


--按钮是否显示
function GatherSoulSpineView:showAllBUtton(_isShow)
	if type(_isShow) == "table" then
		_isShow =  _isShow.params
	end
	self.panel_jvhun1ci:setVisible(_isShow)
	-- self.btn_yulan:setVisible(_isShow)
	local maxCount = FuncNewLottery.getMaxCreateAllItem() ---聚魂本地的最大次数和可以造物的最大数
	local zaoWuNum =  NewLotteryModel:getLotteryNewData() --正在造物的数量 panel
	local isokZW =   maxCount - table.length(zaoWuNum) --剩余造物的数量
	self.panel_jvhun5ci:setVisible(_isShow)
	self.panel_2:setVisible(_isShow)
	self.panel_ksjh:setVisible(_isShow)
	self:showFastButton(_isShow)
	local count = NewLotteryModel:getseniorDrawcard()
	if count == 1 then
		isokZW = 1
	end
	-- if isokZW == 1 then
	-- 	self.panel_jvhun5ci:setVisible(false)
	-- end
	
	self.panel_jt:setVisible(false)
	self:setButtonCount()
	-- EventControler:dispatchEvent(NewLotteryEvent.SHOW_ALL_BUTTON_EVENT,_isShow)
end

--显示一键加速按钮
function GatherSoulSpineView:showyijianjiasu(_isShow)
	if type(_isShow) == "table" then
		_isShow =  _isShow.params
	end
	local zaoWuNum =  NewLotteryModel:getLotteryNewData() --正在造物的数量 panel
	local num = table.length(zaoWuNum) 
	if num ~= 0 then
		self.panel_yijianjiasu:setVisible(_isShow)
	else
		self.panel_yijianjiasu:setVisible(false)
	end

	if _isShow then
		self.panel_ksjh:setVisible(false)
	end
	-- self.panel_2:setVisible(not _isShow)
	self:showNextButton()
	self:setSpeedUpFu()
	self:setButtonCount()
end



return GatherSoulSpineView;
