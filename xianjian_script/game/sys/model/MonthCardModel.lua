local MonthCard = class("MonthCard")
function MonthCard:init( data )
	self.data = data
	self:updateTime(self.data.time)
	-- self:sendHomeRed()
end

--没用了
function MonthCard:sendHomeRed()
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
		{ redPointType = HomeModel.REDPOINT.ACTIVITY.MONTHCARD, isShow = self:isCanGetReward()})
end


function MonthCard:updateTime( time )
	self.data.time = time
	local leftTime = self:getLeftTime()
	if leftTime > 0 then
		TimeControler:startOneCd("MonthCardTimeOverEvent"..self.data.id, leftTime + 1 );
	end
end


function MonthCard:getId( )
	return self.data.id
end
function MonthCard:getLeftTime()
	if self.data.id == "4" then
		return 9999999
	end
	local currentTime = TimeControler:getServerTime()
	local passTime = self.data.time
	local leftTime = passTime - currentTime
	if leftTime < 0 then
		leftTime = 0
	end
	return leftTime
end
function MonthCard:getLeftTimeDay()
	local leftTime = self:getLeftTime()
	return math.ceil(leftTime/(24*3600))
end
-- 奖励是否已领取
function MonthCard:isCanGetReward(  )
	if self:getLeftTime() == 0 then
		return false
	end
	if self:getId() == "4" then
		return false
	end

	local leftNum = CountModel:getCardMonthNum( self.data.id ) or 0
	if leftNum == 0 then
		return true
	else
		return false
	end
end
--判断是否有此权限
function MonthCard:isHasQuanxian(id)
	local dataCfg = FuncMonthCard.getMonthCardById( self:getId())
	for i,v in pairs(dataCfg.additionId) do
		if tostring(v) == tostring(id) then
			return true
		end
	end
	return false

end


function MonthCard:checkCanBuy(  )
	
	if self:getId() == "4" then
		return false
	else
		local leftTime = self:getLeftTimeDay()
		local renewalTime = FuncMonthCard.getRenewalTime(self:getId()) 
		if leftTime >  renewalTime then
			return false
		end
		return true
	end
end






local MonthCardModel = class("MonthCardModel",BaseModel)
function MonthCardModel:init(d)
	MonthCardModel.super.init(self, d)
	self:initData( )

	--跨天 灵石不再清0
	-- self:startCdTimeGoldConsumeCoinInner()

	EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE,self.onCountRefresh,self)
end

function MonthCardModel:onCountRefresh( event )
	--当次数发生变化的时候 判断下红点
	local data = event.params
	for k,v in pairs(data) do
		local cardId  = nil

		if FuncCount.COUNT_TYPE.COUNT_TYPE_GET_MONTHCARD_74_TIMES == k  then
	        cardId = "1"
	    elseif FuncCount.COUNT_TYPE.COUNT_TYPE_GET_MONTHCARD_75_TIMES == k then
	        cardId = "2"
	    elseif FuncCount.COUNT_TYPE.COUNT_TYPE_GET_MONTHCARD_76_TIMES == k then
	        cardId = "3"
	    end

		-- if cardId  and  self.allData[cardId] then
		-- 	self.allData[cardId]:sendHomeRed()
		-- end
	end
	self:checkSendRedPoint()
end


-- 跨天清零 灵石
function MonthCardModel:startCdTimeGoldConsumeCoinInner()
    if self:checkLingShiShopOpen(  ) then
        return
    end
    local expireTime = UserModel:goldConsumeExpireTime()
    if not expireTime then
        return
    end
    local currentTime = TimeControler:getServerTime()
    local leftTime = expireTime - currentTime
    if leftTime > 0 then
        TimeControler:startOneCd("lingshiOverTime",leftTime+1 )
        EventControler:addEventListener("lingshiOverTime", self.clearGoldConsumeCoinInner, self)
    end
end
--灵石跨天清0
function MonthCardModel:clearGoldConsumeCoinInner()
	if self:checkLingShiShopOpen(  ) then
		return
	end
    UserModel._data.goldConsumeCoinInner = 0
    EventControler:dispatchEvent(WelfareEvent.LINGSHICLEARE_EVENT)
end

function MonthCardModel:initData( )
	self.allData = {}
	self.guoqiData = {}
	for i,v in pairs(self._data) do
		local data = {
			id = i,
			time = v,
		}
		local monthCard = MonthCard.new()
		monthCard:init( data )
		self.allData[i] = monthCard
	end

	for i=1,4 do
		EventControler:addEventListener("MonthCardTimeOverEvent"..i, self.clearData, self);
	end

	self:checkSendRedPoint()
	
end

function MonthCardModel:clearData(  )
	EventControler:dispatchEvent(MonthCardEvent.MONTH_CARD_TIME_OVER_EVENT);
end


function MonthCardModel:updateData(data)
    MonthCardModel.super.updateData(self, data)
    dump(data, "月卡 刷新----", 5)
    for i,v in pairs(data) do
    	local _dd = nil
    	for m,n in pairs(self.allData) do
    		if tostring(n:getId()) == tostring(i) then
    			_dd = n
    			break
    		end
    	end
    	if _dd then
    		_dd:updateTime(v)
    		-- _dd:sendHomeRed()
    	else
    		local data = {
		    	id = i,
				time = v,
		    }
		    local monthCard = MonthCard.new()
			monthCard:init( data )
			self.allData[i] = monthCard
    	end
    	
    	-- 68元特权 请求商店信息
    	-- if i == "3" then
    	-- 	ShopServer:getShopInfo( nil )
    	-- end
	    EventControler:dispatchEvent(MonthCardEvent.MONTH_CARD_BUY_SUCCESS_EVENT,i)


	    local monthData = FuncMonthCard.getMonthCardById( i )
	    WindowControler:showTips(FuncMonthCard.getMonthCardName( i ) .."激活成功" )
	    --如果是首次购买
	    -- if  RechargeModel:getMonthCardBuyTime( i ) == 1 then
	        -- 奖励
		    local reward = monthData.firstBuyGift
		    FuncCommUI.startFullScreenRewardView(reward, nil)
	    -- end
    end
    self:checkSendRedPoint()
end

function MonthCardModel:getDataById( id )
	id = tostring(id)
	-- dump(self.allData, "======kanyix  shuju ", 5)
	for i,v in pairs(self.allData) do
		if v:getId() == id then
			return v
		end
	end
	-- echo("并没有 找到 -==== id== ",id)
	return nil
end

-- 判断灵石商店是否开启  灵石商店兑换条件改为购买 彩依送礼  30元月卡 FuncMonthCard.card_caiyi  “2”
function MonthCardModel:checkLingShiShopOpen(  )
	-- local privilegeData = UserModel:privileges() 
 --    local additionType = FuncCommon.additionType.switch_getEqualNumStone_whenUseGold 
 --    local curTime = -1
 --    local isHas,value,subType = FuncCommon.checkHasPrivilegeAddition( privilegeData,additionType,curTime,nil )
 	local model = self:getDataById(FuncMonthCard.card_caiyi)
 	if model and model:getLeftTime() > 0 then
 		return true
 	else
 		return false
 	end
end




-- 判断权限是否开启
function MonthCardModel:checkQuanXianOpen( id )
	if not self.allData then
		return false
	end
	for i,v in pairs(self.allData) do
		if v:isHasQuanxian(id) then
			return true
		end
	end
	return false
end

--判断能否购买月卡
function MonthCardModel:checkCanBuyCard( id )
	local model = self:getDataById(id)
	if not model then
		return true
	end
	return model:checkCanBuy()
end

function MonthCardModel:getCardLeftDay( id )
	local model = self:getDataById(id)
	if not model then
		return 0
	end
	return model:getLeftTimeDay()
end


-- 充值的数据
function MonthCardModel:setChargeData(data)
	self.chargeData = data
end
function MonthCardModel:getChargeData()
	return self.chargeData
end

--是否是灵石月卡
function MonthCardModel:isLingshi( id )
	return  tostring(id) == "4"
end



--获取月卡购买次数
function MonthCardModel:getCarBuyTimes( id )
	return RechargeModel:getMonthCardBuyTime( id )

end


--月卡红点显示
function MonthCardModel:isShowRedPoint( id )
    local model = self:getDataById( id )
    if model and model:isCanGetReward() then
        return true
    else
        return false
    end
end


--主城月卡红点刷新
function MonthCardModel:checkSendRedPoint(  )
	local sendStatus = false
	for i=1,3 do
		local model = self:getDataById( i )
    	if model and model:isCanGetReward() then
			sendStatus = true
		end
	end
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
		{ redPointType = HomeModel.REDPOINT.ACTIVITY.MONTHCARD, isShow = sendStatus})
end


----判断三皇赐福特权是否开启  根据不同的条件来做事情   后续往里加
function MonthCardModel:isOpenSanHuangCiFu( monthCardId )
	local tip = nil
    local tipWindow = nil

    if ShopModel:isHasShopItemList(FuncShop.SHOP_TYPES.MALL_XINANDANG) then
    	tipWindow = "MallMainView"
    else
    	tip = "充值任意金额开启新安当"
    end



    if tip then
        WindowControler:showTips(tip)
    end
    if tipWindow then
        WindowControler:showWindow(tipWindow,FuncShop.SHOP_TYPES.MALL_XINANDANG)
    end
end

function MonthCardModel:checkCardIsActivity(id)
	local leftTime = self:getCardLeftDay( id )
	if leftTime == 0 then
		return false
	end
	return true
end

--获取可以购买的月卡数组  按照价格从低到高排序 如果返回的table长度为0 则已经购买了所有的月卡 monthCardId月卡id  
function MonthCardModel:getUnpurchasedMonthCards()
	local cards = {}
	local allCardData = FuncMonthCard.getconfig_MonthCard()
	for k,v in pairs(allCardData) do
		if not self:checkCardIsActivity(k) then
			local temp = {}
			local price_table = string.split(v.firstBuyGift[1], ",")
			temp.monthCardId = k
			temp.price = tonumber(price_table[2])
			table.insert(cards, temp)
		end
	end

	table.sort(cards, function (a, b)
			if a.price < b.price then
				return true
			else
				return false
			end
		end)

	return cards
end

--获取进入月卡界面时 需要选中的页签
function MonthCardModel:getCurrentType()
	for i = 1, 3 do
		local model = self:getDataById(i)
    	if model and model:isCanGetReward() then
			return i
		end
	end

	for i = 1, 3 do
		local model = self:getDataById(i)
		local data = FuncMonthCard.getMonthCardById(i)
    	if model and not model:isCanGetReward() then
    		local tqt = data.renewalTime
    		if model:getLeftTime() > 0 and model:getLeftTimeDay() <= tqt then
				return i
			end
		end
	end

	for i = 1, 3 do
		local model = self:getDataById(i)
    	if (model and model:checkCanBuy()) or not model then
			return i
		end
	end

	return 1
end

return MonthCardModel



