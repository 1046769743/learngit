--
--Author:      zhuguangyuan
--DateTime:    2018-03-10 10:26:12
--Description: 搜刮事件界面
--1.商人
--2.占卜
--1.钓鱼
--1.猜人
-- 传入要处理的事件id 和 当前事件处理完之后是否自动跳到下一个待处理事件


local TowerCollectionEventView = class("TowerCollectionEventView", UIBase);

function TowerCollectionEventView:ctor(winName,toHandleEventId,isAutoJumpNext)
    TowerCollectionEventView.super.ctor(self, winName)
    self:initData(toHandleEventId)
    self.isAutoJumpNext = isAutoJumpNext
end

function TowerCollectionEventView:loadUIComplete()
	-- local finishTimes = TowerMainModel:checkFishingTimes()
	-- TowerMainModel:recordFishingTimes(0)
	self:registerEvent()
	self:initData()
	self:initViewAlign()
	self:initView()
	self:updateUI()
end 

function TowerCollectionEventView:handleNextEvent(_finishedEventId)
	-- echo("________ 处理完一个事件 发送消息 1111  ________________",_finishedEventId)
	EventControler:dispatchEvent(TowerEvent.TOWER_HANDLE_ONE_EVENT_SUCCEED,{finishedEventId = _finishedEventId})
	-- echo("________ 处理完一个事件 发送消息 2222  ________________")

	if not self.isAutoJumpNext then
		self:startHide()
		return
	end
	local toHandleEventId = TowerMainModel:getToHandleEvent()
	if not toHandleEventId then
		self:startHide()
	end
	-- echo("________ 处理下一个事件 _______________",toHandleEventId)
	self:initData(toHandleEventId)
	self:initView()
	self:updateUI()
end

function TowerCollectionEventView:registerEvent()
	TowerCollectionEventView.super.registerEvent(self);
	self:registClickClose("out")
	self.UI_1.btn_close:setTap(c_func(self.press_btn_close, self))

	-- 再次购买 重新占卜
	EventControler:addEventListener(TowerEvent.TOWER_GO_TO_BUY_GOODS_CONFIRMED,self.reBuyGoods,self)
	EventControler:addEventListener(TowerEvent.TOWER_GO_TO_RE_DIVINATION_CONFIRMED,self.reZhanbu,self)
end

-- 再次购买商品
function TowerCollectionEventView:reBuyGoods( event )
	local params = event.params.params
	self:handleThisEvent(params)
end

-- 再次占卜
function TowerCollectionEventView:reZhanbu( event )
	local params = event.params.params
	self:handleThisEvent(params)
end
function TowerCollectionEventView:initData(toHandleEventId)
	if toHandleEventId and (self.curEventId ~= toHandleEventId) then
		self.curEventId = toHandleEventId
		self.eventData = FuncTower.getCollectionEventDataByID(toHandleEventId)
		dump(self.eventData, "事件数据 ")
		self.guess_Status = {
			["BEGIN"] = 1,
			["GUESSING"] = 2,
			["GUESS_END"] = 3,
			["DONE"] = 4,
		}
	end
end

-- 设置立绘形象和说话内容
-- 传入立绘图片 和 说话的内容
-- 不同事件和事件的不同状态 人物说话的内容不一样
function TowerCollectionEventView:initSpineAndDialog(txtContent,png1)
	if png1 then
		local sprite = display.newSprite(FuncRes.iconTowerEvent(png1))
		self.ctn_1:removeAllChildren()
		self.ctn_1:addChild(sprite)
	end
	if txtContent then
		local text = GameConfig.getLanguage(txtContent)
		self.panel_qipao.txt_1:setString(text)
	end
end

function TowerCollectionEventView:initView()
	self.UI_1.mc_1:visible(false)

	self:initSpineAndDialog(self.eventData.dialog[1],self.eventData.png)
	local eventType = self.eventData.type
	if eventType == FuncTower.COLLECTION_EVENT_TYPE.MERCHANT then
		local title = GameConfig.getLanguage("#tid_tower_ui_090")
		self.UI_1.txt_1:setString(title)

		self:updateViewMerchant()
	elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.SOOTHSAYER then
		local title = GameConfig.getLanguage("#tid_tower_ui_091")
		self.UI_1.txt_1:setString(title)

		local eventDatas = TowerMainModel:getCollectionDataById( self.curEventId )
		local rewardIndex = nil
		local rewardData = nil
		if eventDatas.type then
			rewardIndex = eventDatas.type
			rewardData = self:getRewardByRewardIndex(self.curEventId,self.eventData,rewardIndex)
			dump(rewardData, "===占卜奖励===")
			local rewardStr = string.split(rewardData,",")
			rewardData = rewardStr[2]..","..rewardStr[3]
			if rewardStr[4] then
				rewardData = rewardData..","..rewardStr[4]
			end
		end

		self:updateViewSoothsayer(rewardData)
	elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.FISHING then
		local title = GameConfig.getLanguage("#tid_tower_ui_092")
		self.UI_1.txt_1:setString(title)

		self.mc_1:showFrame(FuncTower.COLLECTION_EVENT_TYPE.FISHING)
		self.curView = self.mc_1:getCurFrameView()
		self.canTryTimes = 3
		self.haveTryTimes = TowerMainModel:checkFishingTimes() 
		if self.haveTryTimes < self.canTryTimes then
			self:initFishingStatus()
		end
	elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.GUESS then
		local title = GameConfig.getLanguage("#tid_tower_ui_093")
		self.UI_1.txt_1:setString(title)
		self.partnerArr = self:getThreePartners(self.eventData.riddler_partner)
		self:updateViewGuess(self.guess_Status.BEGIN)
	end
end

function TowerCollectionEventView:updateViewMerchant()
	self.mc_1:showFrame(FuncTower.COLLECTION_EVENT_TYPE.MERCHANT)
	self.curView = self.mc_1:getCurFrameView()
	local totalReward = self.eventData.reward
	for k,v in pairs(totalReward) do
		self:setOneRewardData(v,self.curView.UI_1)
	end
	
	-- 展示价格
	local price = 0
	local count = TowerMainModel:getHandleTimes( self.curEventId )
	-- dump(self.eventData.price, "商人货物价格数组")
	price = self.eventData.price[count+1]
	local params = {eventId = self.curEventId}
	-- 第一次免费购买
	if price and price == 0 and count < 1 then
		self.curView.mc_1:showFrame(1)
		local contentView = self.curView.mc_1:getCurFrameView() 
		contentView.btn_2:setTap(c_func(self.handleThisEvent,self,params))
	-- 第一次之后 按价格购买 没有购买次数则隐藏价格和
	else
		self.curView.mc_1:showFrame(2)
		local contentView = self.curView.mc_1:getCurFrameView() 
		local leftTimes = #self.eventData.price - count
		contentView.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_088",leftTimes))
		local finishedEventId = self.curEventId
		contentView.btn_1:setTap(c_func(self.handleNextEvent,self,finishedEventId))
		if price then
			FilterTools.clearFilter(contentView.btn_2)
			contentView.panel_1:visible(true)
			if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, price, false) then
				contentView.panel_1.txt_1:setColor(cc.c3b(255,0,0))
			else
				contentView.panel_1.txt_1:setColor(cc.c3b(0x7D,0x56,0x3c))
			end
			contentView.panel_1.txt_1:setString(price)

			-- 花钱再次购买二次确认
			local function gotoConfirm( price )
				WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.BUY_GOODS_CONFIRM,{needNum = price,params = table.deepCopy(params)})
			end
			contentView.btn_2:setTap(c_func(gotoConfirm,price))
			-- contentView.btn_2:setTap(c_func(self.handleThisEvent,self,params))
		else
			contentView.panel_1:visible(false)
			FilterTools.setGrayFilter(contentView.btn_2)
			local function callBack()
				WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_083"))
			end
			contentView.btn_2:setTap(c_func(callBack))
		end
	end
end

function TowerCollectionEventView:updateViewSoothsayer( rewardData )
	self.mc_1:showFrame(FuncTower.COLLECTION_EVENT_TYPE.SOOTHSAYER)
	self.curView = self.mc_1:getCurFrameView()
	local count = TowerMainModel:getHandleTimes( self.curEventId )
	if count > 0 then
		self:initSpineAndDialog(self.eventData.dialog[2])
		-- self:initSpineAndDialog(self.eventData.png,self.eventData.dialog[2])
		self.curView.mc_1:showFrame(2)
		local contentView = self.curView.mc_1:getCurFrameView()
		local resultReward = rewardData
		if resultReward then
			self:setOneRewardData(resultReward,contentView.UI_1)
		end

		-- 展示价格
		local price = 0
		local count = TowerMainModel:getHandleTimes( self.curEventId )
		-- dump(self.eventData.price, "占卜价格数组")
		price = self.eventData.price[count+1]
		if price == 0 and count < 1 then
			contentView.mc_1:showFrame(1)
		elseif price then
			contentView.mc_1:showFrame(2)
			if not UserModel:tryCost(FuncDataResource.RES_TYPE.DIAMOND, price, false) then
				contentView.mc_1:getCurFrameView().txt_1:setColor(cc.c3b(255,0,0))
			else
				contentView.mc_1:getCurFrameView().txt_1:setColor(cc.c3b(0x7D,0x56,0x3c))
			end
			contentView.mc_1:getCurFrameView().txt_1:setString(price)
		end

		-- 领取奖励并离开
		local params1 = {eventId = self.curEventId}
		params1.type = 1
		contentView.btn_1:setTap(c_func(self.handleThisEvent,self,params1))
		-- 继续占卜
		local params2 = {eventId = self.curEventId}
		params2.type = 0  
		local needMoney = self.eventData.price[count+1]
		local leftTimes = #self.eventData.price - count
		contentView.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_087",leftTimes))

		if needMoney then
			FilterTools.clearFilter(contentView.btn_2)
			local function gotoConfirm( needMoney )
				WindowControler:showWindow("TowerChooseTipsView",FuncTower.VIEW_TYPE.ZHANBU_CONFIRM,{needNum = needMoney,params = table.deepCopy(params2)})
			end
			contentView.btn_2:setTap(c_func(gotoConfirm,needMoney))
		else
			contentView.mc_1:visible(false)
			FilterTools.setGrayFilter(contentView.btn_2)
			local function callBack()
				WindowControler:showTips(GameConfig.getLanguage("#tid_tower_UI_collection_22"))
			end
			contentView.btn_2:setTap(c_func(callBack))
		end
	else
		self.curView.mc_1:showFrame(1)
		local contentView = self.curView.mc_1:getCurFrameView()
		local params2 = {eventId = self.curEventId}
		params2.type = 0  
		contentView.btn_1:setTap(c_func(self.handleThisEvent,self,params2))
	end
end

function TowerCollectionEventView:initFishingStatus()
	if self.eventData.type ~= FuncTower.COLLECTION_EVENT_TYPE.FISHING then
		-- #323行 的延迟一秒调用 此处要判断 是不是已经到下一个事件了
		return
	end
	self.curView.mc_1:showFrame(1)
	self.contentView = self.curView.mc_1:getCurFrameView() 
	self.contentView.panel_gou1:visible(true)
	-- 剩余钓鱼次数
	local leftTimes = self.canTryTimes - self.haveTryTimes
	self.contentView.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_089",leftTimes))
	local actNode = self.contentView.panel_circle

	local easeTimeArr = {0.01,0.05,0.5,0.02,0.3,0.05,0.01,0.05,0.5,0.02,0.3,0.05,0.01,0.05,0.5,0.02,0.3,0.05,0.01,0.05,0.5,0.02,0.3,0.05}
	local actionTimes = math.random(15, 20)
	local actArr = {}
	self.contentView.panel_diaoyu2:visible(true)
	self.contentView.panel_diaoyu3:visible(false)

	local lastTimeIsShrink = false
	actionTimes = 10

	-- 动画时间
	local actTime = nil
	local targetScale = nil

	for i=1,actionTimes do
		-- 随机一个数 用于判断该次动作是变大还是变小
		local target = math.random(7, 15)
		-- echo("-------target===",target,lastTimeIsShrink)
		if target > 9 or lastTimeIsShrink then
			lastTimeIsShrink = false
	
			actTime = math.random(1, 2) / 10
			targetScale = 1.1
			-- 变大一小段 钓不到鱼
		    actArr[#actArr+1] = act.scaleto(actTime,targetScale,targetScale)

		    actTime = math.random(4, 7) / 10
			targetScale = targetScale + math.random(20, 30) / 100
		    actArr[#actArr+1] = act.scaleto(actTime,targetScale,targetScale)

		    actTime = math.random(2, 6) / 10
		    actArr[#actArr+1] = act.delaytime(actTime)

		    actArr[#actArr+1] = act.callfunc(function()
						    		self.isGotFish = false
						    		echo("__self.isGotFish actNode.getScale() ______",self.isGotFish,actNode:getScale())
						    		self.contentView.panel_diaoyu2:visible(true)
						    		self.contentView.panel_diaoyu3:visible(false)
						    	end)

		    -- 0.5-0.7
		    actTime = math.random(2, 7) / 10
			-- local s1 = math.random(14, 15)/10
			-- 1.0 + (0.4-0.6)
			targetScale = 1.0 + math.random(40, 70) / 100

		    actArr[#actArr+1] = act.scaleto(actTime,targetScale,targetScale)
		    -- 最大处的停顿
		    actArr[#actArr+1] = act.delaytime(math.random(15,40)/100)

		elseif not lastTimeIsShrink then
			lastTimeIsShrink = true
		    -- 变小一小段 钓到鱼
		    actTime = 0
		    if i == 1 then
		    	actTime = 0
		    else
		    	actTime = 1
		    end

		    targetScale = 0.95
		    actArr[#actArr+1] = act.scaleto(actTime,targetScale,targetScale)
		    actArr[#actArr+1] = act.callfunc(function()
						    		self.isGotFish = true
						    		echo("__self.isGotFish _______",self.isGotFish,actNode:getScale())
						    		self.contentView.panel_diaoyu2:visible(false)
						    		self.contentView.panel_diaoyu3:visible(true)
						    	end)

		    actTime = 0.1 + math.random(10, 20) / 100
		    targetScale = math.random(6, 8)/10
		    actArr[#actArr+1] = act.scaleto(actTime,targetScale,targetScale)

		    -- 最小处的停顿
		    actArr[#actArr+1] = act.delaytime(math.random(50,100)/100)
		    actArr[#actArr+1] = act.callfunc(function()
						    		self.isGotFish = false
						    		echo("__self.isGotFish actNode.getScale() ______",self.isGotFish,actNode:getScale())
						    		self.contentView.panel_diaoyu2:visible(true)
						    		self.contentView.panel_diaoyu3:visible(false)
						    	end)
		end
	end
	
	actArr[#actArr+1] = act.callfunc(function()
						    	self:initFishingStatus()	
						    	end)

    self.contentView.panel_gou1:setTouchedFunc(c_func(self.checkIsGotFish,self))

    actNode:stopAllActions()
	-- dump(actArr, "动作集")
	local seqAct = act.sequence(unpack(actArr))
    actNode:runAction(seqAct)
end

function TowerCollectionEventView:checkIsGotFish()
	self.haveTryTimes = self.haveTryTimes + 1
	TowerMainModel:recordFishingTimes(self.haveTryTimes)
	self.contentView.panel_circle:stopAllActions()
	echo("__________ 钓鱼结果 _____________")
	if self.isGotFish then
		local params = {eventId = self.curEventId}
		params.type = 1
		TowerMainModel:recordFishingTimes(0)
		self:handleThisEvent(params)
	else
		WindowControler:showTips(GameConfig.getLanguage("#tid_tower_ui_084"),1)
		if self.haveTryTimes < self.canTryTimes then
			self:delayCall(c_func(self.initFishingStatus,self),1)
		else
			local params = {eventId = self.curEventId}
			params.type = 0
			local leftTimes = self.canTryTimes - self.haveTryTimes
			self.contentView.rich_1:setString(GameConfig.getLanguageWithSwap("#tid_tower_ui_089",leftTimes))
			TowerMainModel:recordFishingTimes(0)
			self:handleThisEvent(params)
		end
	end
end

function TowerCollectionEventView:updateViewFisher( fishReward )
	if fishReward then
		dump(fishReward, "服务器已经给了奖励,客户端才做展示,没有领取也算领取了")
		self:initSpineAndDialog(self.eventData.dialog[2])
		self.curView.mc_1:showFrame(2)
		local contentView = self.curView.mc_1:getCurFrameView()
		self:setOneRewardData(fishReward,contentView.UI_1)
		contentView.btn_1:setTap(function()
			local finishedEventId = self.curEventId
			WindowControler:showWindow("RewardSmallBgView", {self.fishReward},c_func(self.handleNextEvent,self,finishedEventId))
			self.fishReward = nil
		end)
	end
end

-- 随机配表里的三个奇侠用于备猜
function TowerCollectionEventView:getThreePartners( allConfigPartners )
	return RandomControl.getNumsByGroup(allConfigPartners,3)
end

function TowerCollectionEventView:updateViewGuess(status)
	self.mc_1:showFrame(FuncTower.COLLECTION_EVENT_TYPE.GUESS)
	self.curView = self.mc_1:getCurFrameView()
	dump(partnerArr, "备猜伙伴idArr")

	if status ==  self.guess_Status.BEGIN then
		self.curView.mc_1:showFrame(1)
		self.curView.mc_btn:showFrame(1)
		-- self.curView.mc_btn:getCurFrameView().btn_1:
		local partnerContentView = self.curView.mc_1:getCurFrameView()
		partnerContentView.UI_1.panel_lv:visible(false)
	    partnerContentView.UI_1.mc_dou:visible(false)

		self.curView.mc_btn:getCurFrameView().btn_1:setTap(function()
			self:updateViewGuess(self.guess_Status.GUESSING)
		end)

	elseif status ==  self.guess_Status.GUESSING then
		self:initSpineAndDialog(self.eventData.dialog[2])
		self.costTime = TimeControler:getServerTime()
		self.curView.mc_1:showFrame(1)
		self.curView.mc_btn:showFrame(2)

		-- 随机猜的人
		self.correctIndex = math.random(1,#self.partnerArr) 
		local correctPartnerId = self.partnerArr[self.correctIndex]
		echo("_____ 正确伙伴 id_________",correctPartnerId)
		self.partnerData = FuncPartner.getPartnerById(correctPartnerId)
		local partnerContentView = self.curView.mc_1:getCurFrameView()

	    -- 已经投放的伙伴
		local _quality = "1"
		local _skin = ""
	    -- 奇侠头像
	    local _spriteIcon = FuncPartner.getPartnerIconByIdAndSkin( correctPartnerId, _skin)
	    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
	    headMaskSprite:anchor(0.5,0.5)
	    headMaskSprite:pos(-1,0)
	    headMaskSprite:setScale(0.99)
	    _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,_spriteIcon)
	    partnerContentView.UI_1.ctn_1:removeAllChildren()
	    partnerContentView.UI_1.ctn_1:addChild(_spriteIcon)
	    partnerContentView.UI_1.panel_lv:visible(false)
	    partnerContentView.UI_1.mc_dou:visible(false)
	    _spriteIcon:scale(1.2)

		-- 移动遮罩
		self.guessDuration = self.eventData.riddler_time[3] or 3
		self.movingActNode = partnerContentView.panel_hei
		local actArr = {act.scaleto(self.guessDuration,1,0)}
		local seqAct = act.sequence(unpack(actArr))
		self.movingActNode:runAction(seqAct)
		-- 猜人
		local btnContentView = self.curView.mc_btn:getCurFrameView()
		for k,partnerId in pairs(self.partnerArr) do
			local partnerName = FuncPartner.getPartnerName(partnerId)
			btnContentView["panel_"..k].mc_txt:visible(false)
			btnContentView["panel_"..k].btn_1:setBtnStr( partnerName,"txt_1")
			btnContentView["panel_"..k].btn_1:setTap(function()
				self.selectedIndex = k
				self.costTime = TimeControler:getServerTime() - self.costTime
				self.movingActNode:stopAllActions()
				self:updateViewGuess(self.guess_Status.GUESS_END)
			end)
		end
	elseif status == self.guess_Status.GUESS_END then
		self:disabledUIClick()
		self.curView.mc_1:showFrame(1)
		self.curView.mc_btn:showFrame(2)

		self.grade = 0
		if self.selectedIndex == self.correctIndex then
			self:initSpineAndDialog(self.eventData.dialog[3])
			if self.costTime < (tonumber(self.eventData.riddler_time[1]) or self.guessDuration/8) then
				self.grade = 0
			elseif self.costTime < (tonumber(self.eventData.riddler_time[2]) or self.guessDuration/4) then
				self.grade = 1
			else
				self.grade = 2
			end
		else
			self:initSpineAndDialog(self.eventData.dialog[4])
			self.grade = 3
		end

		-- 猜人
		local btnContentView = self.curView.mc_btn:getCurFrameView()
		for k,partnerId in pairs(self.partnerArr) do
			if k == self.selectedIndex then
				btnContentView["panel_"..k].mc_txt:visible(true)
				btnContentView["panel_"..k].mc_txt:showFrame(self.grade+1)
			else
				btnContentView["panel_"..k].mc_txt:visible(false)
			end
			local partnerName = FuncPartner.getPartnerName(partnerId)
			-- btnContentView["panel_"..k].btn_1:setTouchEnabled(false)
			btnContentView["panel_"..k].btn_1:setBtnStr( partnerName,"txt_1")
			self.movingActNode:stopAllActions()
			self.movingActNode:visible(false)
		end
		self:delayCall(c_func(self.updateViewGuess,self,self.guess_Status.DONE),3)

	elseif status ==  self.guess_Status.DONE then
		self:resumeUIClick()
		self.curView.mc_1:showFrame(2)
		self.curView.mc_btn:showFrame(3)

		echo("______ 选中的,正确的 __________",self.selectedIndex,self.correctIndex)
		local rewardArr = self.eventData.reward
		-- dump(rewardArr, "猜人成绩对应奖励")

		local reward = rewardArr[self.grade+1]
		local partnerContentView = self.curView.mc_1:getCurFrameView()
		self:setOneRewardData(reward,partnerContentView.UI_1)

		local params = {eventId = self.curEventId}
		params.type = tonumber(self.grade)
		self.curView.mc_btn:getCurFrameView().btn_1:setTap(c_func(self.handleThisEvent,self,params))
	end
end

function TowerCollectionEventView:setOneRewardData(itemData,itemView)
	-- dump(itemData, "一个奖励的数据 用于显示")
	local isCoin = false
	local rewardArr = string.split(itemData,",")
	dump(rewardArr, "rewardArr===")
	local rewardId,rewardType,rewardNum,rewardStr
	if #rewardArr > 3 then
		rewardType = rewardArr[2]
		rewardId = rewardArr[3]
		rewardNum = rewardArr[4]
		rewardStr = rewardType..","..rewardId..","..rewardNum
	elseif #rewardArr < 3 then
		rewardType = rewardArr[1]
		rewardNum = rewardArr[2] 
		rewardStr = rewardType..","..rewardNum
		isCoin = true
	else
		rewardType = rewardArr[1]
		rewardId = rewardArr[2]
		rewardNum = rewardArr[3] 
		rewardStr = rewardType..","..rewardId..","..rewardNum
	end
	local rewardUI = itemView
    rewardUI:visible(true)
    rewardUI:setResItemData({reward = rewardStr})
    rewardUI:showResItemName(false)
    FuncCommUI.regesitShowResView(rewardUI,rewardType,rewardNum,rewardId,rewardStr,true,true)
end

function TowerCollectionEventView:handleThisEvent(params)
	local function callBack( serverData )
		if serverData.error then
		else
			local data = serverData.result.data
			-- dump(data, "处理事件反回")

			local eventType = self.eventData.type
			if eventType == FuncTower.COLLECTION_EVENT_TYPE.MERCHANT then
				TowerMainModel:updateData(data)
				WindowControler:showWindow("RewardSmallBgView",self.eventData.reward)
				self:updateViewMerchant()
			elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.SOOTHSAYER then
				local eventDatas = data.towerCollection.events
				local rewardIndex = nil
				if eventDatas and table.length(eventDatas)>0 then
					for k,v in pairs(eventDatas) do
						if v.type then
							TowerMainModel:updateData(data)
							local rewardIndex = v.type
							local rewardData = self:getRewardByRewardIndex(self.curEventId,self.eventData,rewardIndex)
							-- dump(rewardData, "===占卜奖励===")
							local rewardStr = string.split(rewardData,",")
							rewardData = rewardStr[2]..","..rewardStr[3]
							if rewardStr[4] then
								rewardData = rewardData..","..rewardStr[4]
							end

							self:updateViewSoothsayer(rewardData)
						elseif v.count > 0 then
							local data1 = TowerMainModel:getCollectionDataById( self.curEventId )
							local rewardIndex = data1.type
							local rewardData = self:getRewardByRewardIndex(self.curEventId,self.eventData,rewardIndex)
							-- dump(rewardData, "===已经领取的占卜奖励,弹展示界面===")
							local rewardStr = string.split(rewardData,",")
							rewardData = rewardStr[2]..","..rewardStr[3]
							if rewardStr[4] then
								rewardData = rewardData..","..rewardStr[4]
							end
							WindowControler:showWindow("RewardSmallBgView", {rewardData})
							TowerMainModel:updateData(data)
							local finishedEventId = self.curEventId
							self:handleNextEvent(finishedEventId)
						end
					end
				end
			elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.FISHING then
				-- 展示奖励
				TowerMainModel:updateData(data)
				local events = data.towerCollection.events
				local rewardIndex = events[tostring(self.curEventId)].type
				if rewardIndex then
					self.fishReward = self:getRewardByRewardIndex(self.curEventId,self.eventData,rewardIndex)
					self.finishEventId = self.curEventId
					-- dump(self.fishReward, "===钓鱼奖励,防去展示 ,点击领取再弹展示界面===")
					local rewardStr = string.split(self.fishReward,",")
					self.fishReward = rewardStr[2]..","..rewardStr[3]
					if rewardStr[4] then
						self.fishReward = self.fishReward..","..rewardStr[4]
					end
					self:updateViewFisher( self.fishReward )
				else
					echo("___________ 下一个 !!!!!!!!__________________")
					local finishedEventId = self.curEventId
					self:handleNextEvent(finishedEventId)
				end
				
			elseif eventType == FuncTower.COLLECTION_EVENT_TYPE.GUESS then
				local eventDatas = data.towerCollection.events
				if eventDatas and table.length(eventDatas)>0 then
					for k,v in pairs(eventDatas) do
						if v.type then
							local rewardIndex = v.type
							local rewardData = self.eventData.reward[rewardIndex + 1]
							-- dump(rewardData, "===猜人奖励,弹界面展示 ===")
							WindowControler:showWindow("RewardSmallBgView", {rewardData})
							TowerMainModel:updateData(data)
							local finishedEventId = self.curEventId
							self:handleNextEvent(finishedEventId)
						end
					end
				else
					TowerMainModel:updateData(data)
				end
			end
		end
	end
	TowerServer:handleCollectionEvents(params,callBack)
end

-- 通过服务器给的奖励index 读取配表中的奖励数据
function TowerCollectionEventView:getRewardByRewardIndex(curEventId,curEventData,index)
	local configRewardArr = curEventData.rewardWeight
	local rewardIndex = index
	if not rewardIndex then
		return nil
	end

	local rewardData = configRewardArr[rewardIndex + 1]  -- 服务器返回的奖励下标是从0开始的
	return rewardData
end
function TowerCollectionEventView:initViewAlign()
	-- TODO
end

function TowerCollectionEventView:updateUI()
	-- TODO
end

function TowerCollectionEventView:deleteMe()
	if self.fishReward then
		WindowControler:showWindow("RewardSmallBgView", {self.fishReward})
		EventControler:dispatchEvent(TowerEvent.TOWER_HANDLE_ONE_EVENT_SUCCEED,{finishedEventId = self.finishEventId})
		self.fishReward = nil
		self.finishEventId = nil
	elseif self.finishMercenaryId then
		EventControler:dispatchEvent(TowerEvent.TOWER_HANDLE_ONE_EVENT_SUCCEED,{finishedEventId = self.finishMercenaryId})
	end

	TowerCollectionEventView.super.deleteMe(self);
end

function TowerCollectionEventView:press_btn_close()
	self:startHide()
end


return TowerCollectionEventView;
