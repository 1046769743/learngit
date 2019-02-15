--
-- Author: xd
-- Date: 2016-01-15 14:38:41
--

--商城相关
local ShopModel=class("ShopModel", BaseModel)

local OtherValideShop ={
			["7"] = {},
            ["8"]={},
}

function ShopModel:init( d )
	ShopModel.super.init(self,d)

	--坊市中显示的商店   如果有改动或者新增 需要在这里添加
	self.shouldShowAnimShop = {"1", "5", "6", "9", "10", "11", "12"}
	--商店对应的cd事件
	self.shopToCDEventMap = {
		["1"] ={event= TimeEvent.TIMEEVENT_CDSHOP_1},
		["2"] ={event= TimeEvent.TIMEEVENT_CDSHOP_2},
		["3"] ={event= TimeEvent.TIMEEVENT_CDSHOP_3}, 
        ["9"] ={event= TimeEvent.TIMEEVENT_CDSHOP_9}, 
        -- ["10"] ={event= TimeEvent.TIMEEVENT_CDSHOP_10, cdEndFunc="onShopCd10"}, 
        ["6"] = {event= TimeEvent.TIMEEVENT_CDSHOP_6},
        ["14"] = {event= TimeEvent.TIMEEVENT_CDSHOP_14},
	}

	self.loginAttentionStatus = {}
	--初始化开启刷新倒计时
	for shopType,info in pairs(self.shopToCDEventMap) do
		local event = info.event
		local func = c_func(self.onShopCd,self,shopType)
		EventControler:addEventListener(event, func, self)
		self:countInitLeftRefreshTime(shopType)
	end
	EventControler:addEventListener(ShopEvent.SHOPEVENT_CHECK_SHOP_DATA, self.onUserLevelChange, self)
    EventControler:addEventListener(ShopEvent.SHOPEVENT_SYS_OPEN, self.onUserLevelChange, self)
    EventControler:addEventListener(WorldEvent.WORLDEVENT_FIRST_PASS_RAID, self.onUserLevelChange, self)
    EventControler:addEventListener(GuildEvent.CLOSE_ADD_GUILD_VIEW_EVENT, self.showHomeAnimForShop, self)

    -- EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY, self.kuatianRefresh, self)
	self:showHomeAnimForShop()	     
end

--向主城发送是否需要显示新商品特效事件
function ShopModel:dispatchShowShopAnimEvent(shouldShow)
	local isShow = shouldShow or false
	EventControler:dispatchEvent(HomeEvent.SHOW_BUTTON_EFFECT,
            {
                systemName = FuncCommon.SYSTEM_NAME.SHOP_1, --系统名称
                effectType = FuncCommUI.BUTTON_EFFECT_NAME.NEWSHOP, --显示那个特效文字
                isShow = isShow --是不是显示
            })

	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
		{redPointType = HomeModel.REDPOINT.DOWNBTN.SHOP, isShow = isShow})
end

--根据当前商店数据判断是否需要显示新商品特效
function ShopModel:showHomeAnimForShop()
	local anim_table = LS:prv():get(StorageCode.SHOP_ANIM_SHOW, "{}")
	anim_table = json.decode(anim_table)

	local currentOpenShops = {}

	--
	for i,v in ipairs(self.shouldShowAnimShop) do
		if FuncShop.SHOP_TYPES.PVP_SHOP == v and FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PVP) then
			currentOpenShops[v] = 1
		elseif FuncShop.SHOP_TYPES.TOWER_SHOP == v and FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TOWER) then
			currentOpenShops[v] = 1
		elseif FuncShop.SHOP_TYPES.GUILD_SHOP == v and FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.GUILD) then
			if UserModel:guildId() and UserModel:guildId() ~= "" then
				currentOpenShops[v] = 1
			end
		elseif FuncShop.SHOP_TYPES.WONDER_SHOP == v and FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.WONDERLAND) then
			currentOpenShops[v] = 1
		else
			if self._data[tostring(v)] then
				currentOpenShops[v] = 1
			end				
		end	
	end

	if table.length(anim_table) == 0 and table.length(currentOpenShops) > 0 then
		self:dispatchShowShopAnimEvent(true)
		return
	end

	for k,v in pairs(currentOpenShops) do
		if table.find(self.shouldShowAnimShop, k) then
			if not anim_table[k] then
				self:dispatchShowShopAnimEvent(true)
				return
			else
				local lastTime = anim_table[k]
				local lastRefreshTime = self:getLastAutoRefreshTime(k)
				if lastTime < lastRefreshTime then
					self:dispatchShowShopAnimEvent(true)
					return 
				end
			end
		end
	end

	self:dispatchShowShopAnimEvent(false)
end

--根据商店id 判断该商店按钮上是否要显示新商品特效
function ShopModel:showShopBtnAnimById(shopId)
	local anim_table = LS:prv():get(StorageCode.SHOP_ANIM_SHOW, "{}")
	anim_table = json.decode(anim_table)
	if table.length(anim_table) == 0 then
		return true
	else
		local lastRefreshTime = self:getLastAutoRefreshTime(shopId)
		if not anim_table[shopId] or anim_table[shopId] < lastRefreshTime then
			return true
		end
	end

	return  false
end

--点击了商店按钮后 设置当前点击的时间戳
function ShopModel:setShopAnimStatus(shopId)
	local curTime = TimeControler:getServerTime()
	local anim_table = LS:prv():get(StorageCode.SHOP_ANIM_SHOW,"{}")

	if not anim_table then
		anim_table = {}
		anim_table[tostring(shopId)] = curTime
	else
		anim_table = json.decode(anim_table)
		anim_table[tostring(shopId)] = curTime
	end

	LS:prv():set(StorageCode.SHOP_ANIM_SHOW, json.encode(anim_table))
end

--商店的某个cd到了
function ShopModel:onShopCd(shopType)
	--延迟一帧请求刷新商店,如果成功会修改底层数据
	WindowControler:globalDelayCall(c_func(ShopServer.getShopInfo, ShopServer, c_func(self.onRefreshShopEnd, self, shopType)))
	self:showHomeAnimForShop()
end



function ShopModel:onRefreshShopEnd(shopType)
	-- echoError("__onRefreshShopEnd__")
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, {currentShopId = shopType})
end

--1.vip等级达到XXX
--2.主角等级达到xxx
--3.工会等级达到xxx

function ShopModel:isUnlock(condition)
    condition = string.split(condition,",") 
    local str = nil
    local getwayFunc = nil
    if tonumber(condition[1]) == 1 then  
    	local vipLever = UserModel:vip()
        str = GameConfig.getLanguageWithSwap("#tid_shop_1015", condition[2]) --"需要仙尊特权达到"..condition[2].."级"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if vipLever >= tonumber(condition[2]) then
            return true ,str
        else
            getwayFunc = function ()
                --vip 跳转
                WindowControler.showTips(GameConfig.getLanguage("#tid_shop_1003"))
            end
            return false ,str,getwayFunc
        end
        
    elseif tonumber(condition[1]) == 2 then
    	local userLever = UserModel:level()
        str = GameConfig.getLanguageWithSwap("#tid_shop_1016", condition[2])  --"需要主角等级达到"..condition[2].."级"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if userLever >= tonumber(condition[2]) then
            return true ,str
        else
            getwayFunc = function ()
                WindowControler:showWindow("WorldMainView")
            end
            return false ,str,getwayFunc
        end
    elseif tonumber(condition[1]) == 3 then
    	local gonghuiLever = 1000
        str = GameConfig.getLanguageWithSwap("#tid_shop_1017", condition[2])  --"需要工会等级达到"..condition[2].."级"
        getwayFunc = function ()
            WindowControler:showTips(str)
        end
        if gonghuiLever >= tonumber(condition[2]) then
            return true ,str
        else
            getwayFunc = function ()
                --工会跳转
                WindowControler.showTips(GameConfig.getLanguage("#tid_shop_1004"))
            end
            return false ,str,getwayFunc
        end
    else
    	return true
    end
end
--判断商店道具是否开启
function ShopModel:checkItemByIndexAndShopId( shopId,index )
	local condtion = FuncShop.getItemCondtion( shopId,index)
    if condtion then
        for i,v in pairs(condtion) do
            local isUnLock,str = ShopModel:isUnlock(v);
            if not isUnLock then
                return false,str
            end
        end
    end

	return true
end

--判断shop是否开启，包括临时开启
function ShopModel:checkIsOpen(shopId )
	local data = self._data[shopId]
	if not data then
		return false
	end
	local now = TimeControler:getServerTime()
	if data.isTempShop == 1  then 
		local expireTime = data.expireTime or 0
		if now >= expireTime then
			return false
		end
	end
	return true
end

function ShopModel:isHasShopItemList(shopId)
	-- dump(self._data,"LLLLLLLLLLLLLLLLLLLLLLLL===",8)
	local data = self._data[shopId]
	if data then
		return true
	else
		return false
	end
end
--获取某个商店的列表信息
function ShopModel:getShopItemList(shopId)
    -- dump(self._data,"LLLLLLLLLLLLLLLLLLLLLLLL",8)
	local data = self._data[shopId]
	local ret = {}
	if data then
		data = data.goodsList
	else
		echoError("====不存在该商店   shopId =====",shopId)
		return {}
	end
	local keys = table.keys(data)
	local sortById = function(a, b)
		return tonumber(a) < tonumber(b)
	end
	table.sort(keys, sortById)
	for i, index in ipairs(keys) do
		data[index].index = i
		table.insert(ret, data[index])
	end
	return ret
-- 	"shops":{
-- "1":{"goodsList":{
-- "1":{"id":"2006","buyTimes":0},
-- "2":{"id":"104","buyTimes":0},
-- "3":{"id":"2009","buyTimes":0},
-- "4":{"id":"2003","buyTimes":0},
-- "5":{"id":"2001","buyTimes":0},
-- "6":{"id":"2004","buyTimes":0}}
-- ,"lastFlushTime":1452935298}},

end

function ShopModel:isShopItemAllSoldOut(shopId)
	shopId = tostring(shopId)
	local data = self._data[shopId]
	if data == nil then return false end
	local goods = data.goodsList
	local soldOut = true
	for k,v in pairs(goods) do
		if v.buyTimes<=0 then
			soldOut = false
		end
	end
	return soldOut
end
--//判断某个给定的商品是否已经售出
function ShopModel:isSomeItemSoldOut(shopId,_goodsId)
  local   shop_data=self._data[shopId];
  if(shop_data == nil)then  return false end;
--  assert(shop_data ~=nil,"error on query shop data ,param is illegal.");
  for key,value in pairs(shop_data.goodsList)do
       if(value.id== _goodsId )then
                 return   value.buyTimes<=0;
       end
  end
  return false;
 --// assert(false,"gooldsId is illegal :".._goodsId);
end
function ShopModel:setCurrentNewOpenTempShop(shopType)
	self._new_open_temp_shop = shopType
end

function ShopModel:getCurrentNewOpenTempShop()
	return self._new_open_temp_shop 
end

function ShopModel:clearCurrentNewOpenTempShop()
	self._new_open_temp_shop = nil
end

--获取某个商店上次更新时间
function ShopModel:getLastRefreshTime( shopId )

	if not self:checkIsOpen(shopId) then
		return 0
	end

	return self._data[shopId].lastFlushTime
end

--获取初始化某个商店剩余刷新时间 并开启倒计时
function ShopModel:countInitLeftRefreshTime(shopId)
	local targetTime,leftTime = self:getNextRefreshTime(shopId)

	-- echo("\n\ntargetTime===", targetTime, "leftTime==", leftTime)
	if leftTime < 0 then
		return 
	end

	if leftTime ==0 then
		self:onShopCd(shopId)
		return
	end

	--开启计时
	if self.shopToCDEventMap[shopId] ~= nil then
		local eventName = self.shopToCDEventMap[shopId].event
		TimeControler:startOneCd(eventName, leftTime)
	end
end

function ShopModel:_getDayInitTimeStamp(time)
	local d = os.date("*t", time)
	d.hour = 0
	d.min = 0
	d.sec = 0
	return os.time(d)
end

--获取商店上次刷新时间
function ShopModel:getLastAutoRefreshTime(shopId)
	local now = TimeControler:getServerTime()
	local todayBegin = self:_getDayInitTimeStamp(now)
	local refreshTimes = FuncShop.getShopRefresh(shopId)
	local targetTime = 0

    local _select_index=0;
    local lastRefreshTime = 0
    for k = 1, #refreshTimes do
        local timeOffset = refreshTimes[k];
		targetTime = timeOffset
		local t = todayBegin + timeOffset
		if t < now then
			lastRefreshTime = t
           _select_index = k;
		else
			break
		end
	end

	if lastRefreshTime == 0 then
		lastRefreshTime = (todayBegin - 24 * 60 * 60) + refreshTimes[#refreshTimes]
	end

	return lastRefreshTime
end

--获取商店下次刷新时间
function ShopModel:getNextRefreshTime(shopId )
	--如果是未开启的  返回0
	if tostring(shopId) ~= FuncShop.SHOP_TYPES.GUILD_SHOP then
		if not self:checkIsOpen(shopId) then
			return 14400 ,-1
		end
	end
	local now = TimeControler:getServerTime()
	local todayBegin = self:_getDayInitTimeStamp(now)
	local refreshTimes 
    -- if OtherValideShop[shopId] then
    -- 	echo("22222222222222222222")
    --     return 0,-1
    -- end
     refreshTimes= FuncShop.getShopRefresh(shopId)
	local targetTime = 0
--	for k,timeOffset in ipairs(refreshTimes) do
    local    _select_index=0;
    for  k=1,#refreshTimes do
        local   timeOffset=refreshTimes[k];
		targetTime = timeOffset
		local t = todayBegin+timeOffset
		if t > now then
           _select_index=k;
			break
		end
	end
	local targetAbsoluteTime = 0
	if _select_index==0 then
		local nextDayBegin = self:_getDayInitTimeStamp(now + 86400)
		targetTime = refreshTimes[1]
		targetAbsoluteTime = targetTime + nextDayBegin
	else
		targetAbsoluteTime = targetTime + todayBegin
	end
	local leftTime = targetAbsoluteTime - now
	return targetTime, leftTime
end

function ShopModel:updateData(data)

    -- 过滤掉 4 熔炼商店信息
    local _data = {}
    for i,v in pairs(data) do
        _data[i] = v
    end
    data = _data

	ShopModel.super.updateData(self,data)

	for k,v in pairs(data) do
		--如果商店倒计时发生变化
		if v.lastFlushTime then
			--那么重新启动商店倒计时
			self:countInitLeftRefreshTime(tostring(k))
		end

		if FuncShop.isVipShop(k) and self:isTempShop(k) then
			self:setCurrentNewOpenTempShop(k)
			if not self:isShopViewShowing() then
				EventControler:dispatchEvent(ShopEvent.SHOPEVENT_TEMP_SHOP_OPEN, {shopType=k})
			end
		end
	end

	dump(self._data, "\n\nself._data====updateData====")
	--商店数据刷新, 那么通知ui界面刷新 可能包括道具 倒计时 等等
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_MODEL_UPDATE, data)
end

function ShopModel:getTempShopLeftTime(shopId)
	local expireTime = self._data[shopId].expireTime
	local now = TimeControler:getServerTime()
	local delta = expireTime - now
	if delta <0 then delta = 0 end
	return delta
end

--根据数据判断商店是否临时开启
function ShopModel:isTempShop(shopId)
	local data = self._data[shopId]
	if not data then return false end

	if data.isTempShop or data.expireTime then 
		return true
	end

	return false
end

function ShopModel:onUserLevelChange()
	self:tryGetShopInfo()
end

function ShopModel:tryGetShopInfo()
	for i=1,#FuncShop.ShopName do
		local open, value, valueType = FuncCommon.isSystemOpen(FuncShop.ShopName[i])
		-- echo("\n\nFuncShop.ShopName=", FuncShop.ShopName[i], "open=", open)
		if open then
			ShopServer:getShopInfo(function ()
					self:showHomeAnimForShop()
				end)
			return
		end
	end
end

function ShopModel:setShopIsShow(show)
	self._shop_is_show = show
end

function ShopModel:isShopViewShowing()
	return self._shop_is_show == true
end


--获取商店购买 服务器数据 1608
function ShopModel:getBuydataServerCallBack(shopType,goodsId,key)
    local fakeServerData = {
		u = {
			_id = UserModel:_id(),
		}
	}
    -- shops
    local shops = {}
    local goodsList = {}
    goodsList[tostring(key)] = { buyTimes = 1 }
    shops[shopType] = goodsList
    fakeServerData.u.shops = shops
    --items
    local items = {};
    local info = FuncShop.getGoodsInfo(shopType, goodsId)
    items[info.itemId] = {}
    items[info.itemId].num = ItemsModel:getItemNumById(info.itemId) + info.goodsNumber
    items[info.itemId].id = info.itemId
    -- items[tostring(info.itemId)] = {num = ItemsModel:getItemNumById(info.itemId) + info.goodsNumber}
    fakeServerData.u.items = items
    -- 消耗 
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(info.cost[1])
    if resType == FuncDataResource.RES_TYPE.COIN then
        local finance = {}
        finance = {coin = hasNums - needNums }
        fakeServerData.u.finance = finance
    elseif  resType == FuncDataResource.RES_TYPE.DIAMOND then
        fakeServerData.u.giftGold = hasNums - needNums
    end

    dump(fakeServerData,"商店购买 客户端构造服务器数据")
    return fakeServerData
end
--获取商店购买 服务器数据 3904
function ShopModel:getNoRandBuydataServerCallBack(shopType,goodsId)
    local fakeServerData = {
		u = {
			_id = UserModel:_id(),
		}
	}
    -- shops
    local noRandShops = {}
    local buyGoodsTimes = {
        buyGoodsTimes = {}
    }
    buyGoodsTimes.buyGoodsTimes[tostring(goodsId)] = 1
    noRandShops[shopType] = buyGoodsTimes
--    noRandShops[lastFlushTime] = self._data[tostring(shopType)].lastFlushTime
    fakeServerData.u.noRandShops = noRandShops
    --items
    local items = {};
    local info = FuncShop.getGoodsInfo(shopType, tostring(goodsId))
    items[info.itemId] = {}
    items[info.itemId].num = ItemsModel:getItemNumById(info.itemId) + info.num
    items[info.itemId].id = info.itemId
    fakeServerData.u.items = items
    -- 消耗 
    local finance = {}
    finance = {arenaCoin = UserModel:getArenaCoin() - info.cost }
    fakeServerData.u.finance = finance

    dump(fakeServerData,"商店购买 ---客户端构造服务器数据")
    return fakeServerData
end

function ShopModel:setSelectdShopId(_shopId)
	self.selectedShopId = _shopId
end

function ShopModel:getSelectdShopId()
	return self.selectedShopId
end


--仙盟商店道具是否解锁  --wk
function ShopModel:getGuildItemUnlock(_index)
	local data = FuncShop.getGuildData(_index)
	local bLevelTab = GuildModel:getBuildsLevel()
	local buildid = FuncGuild.Help_Type.SHOP
	local str = GameConfig.getLanguageWithSwap("#tid_shop_lock_001", data.condition)
	if bLevelTab[buildid] == nil or bLevelTab[buildid] == 0 then
		return false,str
	else
		if bLevelTab[buildid] >= data.condition then
			return true
		else
			return false,str
		end
	end
end

function ShopModel:getGuildModelData()
	local levelTab  = GuildModel:getBuildsLevel()
	if table.length(levelTab) == 0 then
		GuildControler:getMemberList("")
	end
end

--设置商店开门特效是否已播放
function ShopModel:setOpenAnimStatus(_boolean)
	self.isOpenAnimEnd = _boolean
end

function ShopModel:getOpenAnimStatus()
	return self.isOpenAnimEnd
end

--判断登仙台商店某个位置是否解锁
function ShopModel:getPvpShopItemUnLock(_index)
	local shop_data = FuncShop.getPvpShopGoods()
	local data = shop_data[_index]
	local pvp_chanllenge_count = PVPModel:challengeTimes()
	if data.condition then
		local str = GameConfig.getLanguageWithSwap("#tid_shop_lock_002", (data.condition - pvp_chanllenge_count))
		if pvp_chanllenge_count >= data.condition then			
			return true
		else
			return false, str
		end
	else
		return true
	end
end

-- 判断锁妖塔商品是否解锁 -- zhuguangyuan
-- 解锁返回true 未解锁返回fasle 和解锁条件
function ShopModel:checkIsTowerShopItemUnlock(goodsId)
	local curPassFloor = UserModel:towerExt().maxClearFloor or 0
	echo("____usermodel 下 curPassFloor___________",curPassFloor)
	local dd = TowerMainModel:getMaxClearFloor()
	if dd then
		echo("____usermodel 下 dd ___________",dd)
		curPassFloor = dd
	end

	local isUnlock = false
	local data = FuncShop.getOneTowerShopGoodsById( goodsId )
	if data and data.unlockFloor then
		local needToPassFloor = tonumber(data.unlockFloor)
		if curPassFloor < needToPassFloor then
			local tips = GameConfig.getLanguageWithSwap("#tid_tower_ui_096", needToPassFloor)
			-- local tips = "通关"..needToPassFloor.."可解锁"
			return false,tips
		else
			return true
		end
	else
		return true
	end
end

--判断须臾仙境商店某个位置是否解锁
function ShopModel:getWonderShopItemUnlock(_index)
	local shop_data = FuncShop.getWonderShopGoods()
	local data = shop_data[_index]
	local minFloor = WonderlandModel:getAllMinFloor()
	if data.condition then
		local str = GameConfig.getLanguageWithSwap("#tid_wonderland_shop_001", data.condition)
		if minFloor >= (data.condition) then			
			return true
		else
			return false, str
		end
	else
		return true
	end
end

--设置是否需要 提醒刷新 的状态
function ShopModel:setLoginAttentionStatus(_bool, _shopId)
	self.loginAttentionStatus[tostring(_shopId)] = _bool
end

function ShopModel:getLoginAttentionStatus(_shopId)
	return self.loginAttentionStatus[tostring(_shopId)]
end

--不需要弹出刷新框时 的刷新逻辑走这里
function ShopModel:onBtnRefreshTap(currentShopId)
    local refreshTimes = CountModel:getShopRefresh(currentShopId) or 0
    local constantName = "RefreshNum1"
    if currentShopId == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
    	constantName = "RefreshNum3"
    elseif currentShopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
    	constantName = "MonthCardShopFlushTime"
    end

    --判断刷新次数是否超过最大值
    local maxRefreshNum = FuncDataSetting.getDataByConstantName(constantName);
    if maxRefreshNum <= refreshTimes then
        WindowControler:showTips(GameConfig.getLanguage("tid_common_2058")) 
        return
    end
    --每次都需要+1
    local needMoneyInfo = FuncShop.getRefreshCost(currentShopId, refreshTimes+ 1)
    local needNum,hasNum,isEnough,resType = UserModel:getResInfo(needMoneyInfo)
    local shopId = currentShopId
	if not UserModel:tryCost(resType, needNum, true, FuncCommon.CostType.REFRESH) then
		return
	else
		if FuncShop.isNoRandShop(shopId) then
			ShopServer:flushNoRandShop(shopId, c_func(self.onRefreshOk, self, shopId))
		else
			--刷新
			ShopServer:refreshShop(shopId, c_func(self.onRefreshOk, self, shopId))
		end
	end
end

--刷新完之后需要更新界面
function ShopModel:onRefreshOk(shopId)
	WindowControler:showTips(GameConfig.getLanguage("tid_common_1010"))
	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, {currentShopId = shopId})
end

-- --新安当跨天刷新
-- function ShopModel:kuatianRefresh(  )
-- 	local shopId = FuncShop.SHOP_TYPES.MALL_XINANDANG
-- 	ShopServer:getShopInfo( c_func(self.onRefreshOk, self))
-- end

-- function ShopModel:onRefreshOk( event )
-- 	echoError("_onRefreshOk_")
-- 	EventControler:dispatchEvent(ShopEvent.SHOPEVENT_REFRESH_SHOP_END, {currentShopId = FuncShop.SHOP_TYPES.MALL_XINANDANG})
-- end

return ShopModel
