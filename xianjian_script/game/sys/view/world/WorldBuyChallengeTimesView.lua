-- Author: ZhangYanguang
-- Date: 2017-02-23
-- 精英副本购买挑战次数

local WorldBuyChallengeTimesView = class("WorldBuyChallengeTimesView", UIBase);

function WorldBuyChallengeTimesView:ctor(winName,raidId)
    WorldBuyChallengeTimesView.super.ctor(self, winName);

    self.raidId = raidId
end

function WorldBuyChallengeTimesView:loadUIComplete()
	self:initData()
	self:initView()
	self:registerEvent()
end 

function WorldBuyChallengeTimesView:registerEvent()
	self.UI_1.btn_close:setTap(c_func(self.startHide,self))
	self.UI_1.mc_1.currentView.btn_2:setTap(c_func(self.startHide,self))

	self.UI_1.mc_1.currentView.btn_1:setTap(c_func(self.doBuyTimes,self))

	EventControler:addEventListener(UserEvent.USEREVENT_TEQUAN_CHANGE, self.initView, self)
end

function WorldBuyChallengeTimesView:initData()
	self.buyElite = 37
end

function WorldBuyChallengeTimesView:initView()
	self:registClickClose("out")
	
	-- 购买次数
	self.UI_1.txt_1:setString(GameConfig.getLanguage("tid_story_10118"))
	self.UI_1.mc_1:showFrame(2)

	local buyTimes = WorldModel:getEliteBuyTimes(self.raidId)
	-- 判断是否开启半价特权
	local privilegeData = UserModel:privileges()
    local additionType = FuncCommon.additionType.decrement_buyChallengeTimesCost_elite 
    local curTime = TimeControler:getServerTime()
    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil )
	if buyTimes == 0 and isHas then
		self.mc_1:showFrame(2)
		self.currentView = self.mc_1:getCurFrameView()
		local cost = FuncChapter.getBuyCost(buyTimes + 1)
		self.currentView.txt_4:setString(GameConfig.getLanguageWithSwap("tid_story_10121",buyTimes))
		local banjia = math.floor(cost/2)-- 半价
		self.currentView.txt_2:setString(banjia.."(原价"..cost..")") -- 原价
	else
		self.mc_1:showFrame(1)
		self.currentView = self.mc_1:getCurFrameView()
		self.currentView.txt_4:setString(GameConfig.getLanguageWithSwap("tid_story_10121",buyTimes))
		local cost1 = buyTimes
		if buyTimes + 1 <= WorldModel:getEliteMaxBuyTimes() then
			cost1 = buyTimes + 1
		end
		self.currentView.txt_2:setString(FuncChapter.getBuyCost(cost1))

		self.currentView.btn_go:setTap(function (  )
			-- 跳转到月卡  五测改为 财神送宝 激活特权
			WindowControler:showWindow("MonthCardMainView", FuncMonthCard.CARDYEQIAN[FuncMonthCard.card_caishen] )
		end)

		if buyTimes == 0 then
			self.currentView.txt_5:visible(true)
			self.currentView.btn_go:visible(true)
			self.currentView.scale9_1:visible(true)
		else
			self.currentView.txt_5:visible(false)
			self.currentView.btn_go:visible(false)
			self.currentView.scale9_1:visible(false)
		end
	end

	self.buyTimes = buyTimes
end

function WorldBuyChallengeTimesView:doBuyTimes()
	local leftTimes = WorldModel:getEliteRaidLeftTimes(self.raidId)
	if tonumber(leftTimes) > 0 then
		-- WindowControler:showTips("剩余次数为0，才能重置")
		return
	end

	self.buyTimes = WorldModel:getEliteBuyTimes(self.raidId)
	local maxBuyTimes = WorldModel:getEliteMaxBuyTimes()
	-- 已经购买的次数
	if self.buyTimes >= maxBuyTimes then
		echo("今日购买次数已经用完")
		WindowControler:showTips(GameConfig.getLanguage("tid_story_10119"))
		return
	end

	local myGold = UserModel:getGold()
	local goldCost = FuncChapter.getBuyCost(self.buyTimes + 1)

	if self.buyTimes == 0 then
		-- 判断是否开启半价特权
		local privilegeData = UserModel:privileges()
	    local additionType = FuncCommon.additionType.decrement_buyChallengeTimesCost_elite 
	    local curTime = TimeControler:getServerTime()
	    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil)
	    if isHas then
	    	goldCost = math.floor(goldCost / 2)
	    end
	end
	

	if tonumber(myGold) < tonumber(goldCost) then
		WindowControler:showWindow("CompGotoRechargeView")
		return
	end

	local buyCallBack = function(event)
		if event.result then
			EventControler:dispatchEvent(WorldEvent.WORLDEVENT_BUY_CHALLEGE_TIMES)
			self:startHide()
		else
			-- WindowControler:showTips("重置购买次数失败")
			echoError("WorldBuyChallengeTimesView:doBuyTimes 重置购买次数失败")
		end
	end

	WorldServer:buyChalengeTimes(self.raidId,buyCallBack)
end

return WorldBuyChallengeTimesView