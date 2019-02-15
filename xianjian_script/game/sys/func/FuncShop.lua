--
-- Author: xd
-- Date: 2016-01-15 17:00:23
--

--shop相关函数
FuncShop = FuncShop or {}

local shopData =  nil 		--商店配置表
local goodsData = nil 		--道具配置表
local shopWeightData = nil      --道具开启表（前端只需要用的是否开启显示用）

local buyData = nil 		--购买配置
local config_pvp_shop = nil --pvp商城
local config_tower_shop = nil -- 爬塔商店
local config_guild_shop = nil --仙盟商店
local config_wonder_shop = nil --须臾商店
local config_shop_tips = nil

--策划说暂时隐藏掉 4,6这两个商店
FuncShop.SHOP_TYPES = {
	NORMAL_SHOP_1 = "1", -- 永安商店
	NORMAL_SHOP_2 = "2", -- 低V商店
	NORMAL_SHOP_3 = "3", -- 高V商店
	PVP_SHOP = "5",      -- pvp商店
	CHAR_SHOP = "6", -- 侠义值商店
	LOTTER_PARTNER_SHOP = "7", -- 抽奖伙伴商店
	LOTTER_MAGIC_SHOP = "8",	--抽奖法宝商店
    ARTIFACT_SHOP = "9",    --神器商店
    TOWER_SHOP = "10",      --锁妖塔商店
    GUILD_SHOP = "11",      --仙盟商店
    WONDER_SHOP = "12",     --须臾商店

    -- 商城中的商店
    MALL_YONGANDANG = "13" ,--永安当
    MALL_XINANDANG = "14" , --新安当

}

--定义为单独的充值商店
FuncShop.SHOP_CHONGZHI ="chongzhi"

--商店的标题与商店的ID之间的映射关系
--目前暂时设定为4个
FuncShop.ShopTitleMap = {
    [FuncShop.SHOP_TYPES.NORMAL_SHOP_1] = 7,--永安商店
    [FuncShop.SHOP_TYPES.NORMAL_SHOP_2] = 8,--贵宾楼，现在是临时商店（低V）
    [FuncShop.SHOP_TYPES.PVP_SHOP] = 3, --登仙台
    [FuncShop.SHOP_TYPES.NORMAL_SHOP_3] = 8,--聚宝阁(原名承天剑台)， 现在是临时商店（高V）
    [FuncShop.SHOP_TYPES.ARTIFACT_SHOP] = 10,--神器商店
    [FuncShop.SHOP_TYPES.TOWER_SHOP] = 2,--锁妖塔商店
    [FuncShop.SHOP_TYPES.CHAR_SHOP] = 6,  --侠义值
    [FuncShop.SHOP_TYPES.GUILD_SHOP] = 1,  ---暂时用7代替
    [FuncShop.SHOP_TYPES.WONDER_SHOP] = 5, --须臾商店
}

FuncShop.NO_RAND_SHOP_IDS = {
	FuncShop.SHOP_TYPES.PVP_SHOP,
    FuncShop.SHOP_TYPES.TOWER_SHOP,
    FuncShop.SHOP_TYPES.GUILD_SHOP,
    FuncShop.SHOP_TYPES.WONDER_SHOP,
    FuncShop.SHOP_TYPES.MALL_YONGANDANG,
}

FuncShop.SHOP_NAMES = {
	["1"] = "#tid_shop_2001",
	["2"] = "#tid_shop_2002",
	["3"] = "#tid_shop_2003",
	["4"] = "#tid_shop_2004",
	["5"] = "#tid_shop_2005",
	["6"] = "#tid_shop_2006",
    ["7"] = "#tid_shop_2007",
    ["8"] = "#tid_shop_2008",
    ["9"] = "#tid_shop_2009",
    ["10"] = "#tid_shop_2010",
    ["11"] = "#tid_group_name_104",  ---暂时用
    ["12"] = "#tid_shop_2010",
}
FuncShop.ShopName = {
	[1] = "shop1",
	[2] = "shop2",
	[3] = "shop3",
	[4] = "shop9",
	[5] = "shop7",
	[6] = "shop6",
}

FuncShop.btns_Type = {
	type_left = 1,
	type_right = 2,
}

--刷新时不同资源对应的不同帧数
FuncShop.RES_MC_MAP = {
	[FuncDataResource.RES_TYPE.DIAMOND] = 1,
	[FuncDataResource.RES_TYPE.ARENACOIN] = 2,
	[FuncDataResource.RES_TYPE.CHIVALROUS] = 3,
    [FuncDataResource.RES_TYPE.CIMELIACOIN] = 4,
    [FuncDataResource.RES_TYPE.DIMENSITY] = 5,
	[FuncDataResource.RES_TYPE.LINGSHI] = 6,  ---灵石加一帧
	[FuncDataResource.RES_TYPE.XIANFU] = 7,
}

--初始化
function FuncShop.init(  )
	shopData = Tool:configRequire("shop.Shop")
	goodsData = Tool:configRequire("shop.Goods")
	buyData = Tool:configRequire("shop.BuyShopFlush")
	config_pvp_shop = Tool:configRequire('shop.PvpShop')
    config_tower_shop = Tool:configRequire('shop.TowerShop')
	shopWeightData = Tool:configRequire("shop.ShopWeight")
	config_guild_shop = Tool:configRequire('guild.GuildShop')
	config_wonder_shop = Tool:configRequire('shop.WonderLandShop')
	config_shop_tips = Tool:configRequire("shop.ShopTips")
end

-- 通过商店ID和index获取开启条件
function FuncShop.getItemCondtion( shopId,index)
	local shopsData = shopWeightData[tostring(shopId)]
	if not shopsData then
		--echoError("表 shop.ShopWeight 中未找到商店ID =",shopId)
        return nil
	end
	local data = shopsData[tostring(index)]
	if not data then
        return nil
		--echoError("表 shop.ShopWeight 商店ID =",shopId," 未找到index == ",index)
	end
	return data.condition
end

function FuncShop.getTowerShopGoods()
    local config = config_tower_shop
	local sortById = function(a, b)
		return a.id < b.id
	end
	local keys = table.sortedKeys(config, sortById)
	local ret = {}
	for _, key in ipairs(keys) do
		table.insert(ret, config[key]) 
	end
	return ret
end

function FuncShop.getPvpShopGoods()
	local config = config_pvp_shop
	local sortById = function(a, b)
		return a.id < b.id
	end
	local keys = table.sortedKeys(config, sortById)
	local ret = {}
	for _, key in ipairs(keys) do
		table.insert(ret, config[key])
	end
	return ret
end

--获取PVP商店中需要解锁的商品数据
function FuncShop.getPvpShopLockedGoods()
	local pvp_shop_data = FuncShop.getPvpShopGoods()
	local locked_data = {}
	for i,v in ipairs(pvp_shop_data) do
		if v.condition then
			table.insert(locked_data, v)
		end
	end

	local sortByCondition = function (a, b)
		return a.condition < b.condition
	end

	table.sort(locked_data, sortByCondition)
	return locked_data
end

-- 通关id获取一个锁妖塔商品数据
-- 20180319 用于锁妖塔主界面解锁商品 的展示
function FuncShop.getOneTowerShopGoodsById( id )
	if config_tower_shop and config_tower_shop[tostring(id)] then
		return config_tower_shop[tostring(id)]
	end
end

--仙盟商店所有数据  --wk
function FuncShop.getGuildShopGoods()
	local config = config_guild_shop

	local ret = {}
	for k,v in pairs(config) do
		ret[tonumber(v.id)] = v
	end
	return ret
end
--仙盟商店单个数据  --wk
function FuncShop.getGuildData(_index)
	local data = config_guild_shop
	if data[tostring(_index)] == nil then
		return data["1"]
	end
	return  data[tostring(_index)]
end

--须臾商店所有数据  --lxh
function FuncShop.getWonderShopGoods()
	local config = config_wonder_shop

	local ret = {}
	for k,v in pairs(config) do
		ret[tonumber(v.id)] = v
	end
	return ret
end

function FuncShop.isNoRandShop(shopId)
	if table.find(FuncShop.NO_RAND_SHOP_IDS, shopId) then
		return true
	end
	return false
end

function FuncShop.getNoRandShopCoinType(shopId)
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.PVP_SHOP then
		return FuncDataResource.RES_TYPE.ARENACOIN
	elseif shopId == ALLTYPES.CHAR_SHOP then
		return FuncDataResource.RES_TYPE.CHIVALROUS
    elseif shopId == ALLTYPES.TOWER_SHOP then
		return FuncDataResource.RES_TYPE.DIMENSITY
	end
end

--needtodaytime = true的话，返回的是今日刷新时间
function FuncShop.getNoRandShopRefreshTime(shopId, needTodayTime)
	local ALLTYPES = FuncShop.SHOP_TYPES
	local countType = nil
	if shopId == ALLTYPES.PVP_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES
	-- elseif shopId == ALLTYPES.CHAR_SHOP then
	-- 	countType = FuncCount.COUNT_TYPE.COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES
    elseif shopId == ALLTYPES.TOWER_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_TOWERSHOP_DAY_TIMES
	elseif shopId == ALLTYPES.GUILD_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_TOWERSHOP_DAY_TIMES 
	elseif shopId == ALLTYPES.WONDER_SHOP then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_WONDERSHOP_DAY_TIMES
	elseif shopId == ALLTYPES.MALL_YONGANDANG then
		countType = FuncCount.COUNT_TYPE.COUNT_TYPE_WONDERSHOP_DAY_TIMES
	end
	local now = TimeControler:getServerTime()
	--配置表中商店的刷新时间m:minute, h:hour
	local m = FuncCount.getMinute(countType)
	local h = tonumber(FuncCount.getHour(countType))
	local d = os.date("*t", now)
	d.hour = h
	d.min = m
	d.sec = 0
	local t1 = os.time(d)
	local refresh_t = t1
	local isToday = true
	--如果不需要返回今日时间，会返回约定的下一次自动刷新时间
	if now > t1 and not needTodayTime then
		refresh_t = t1 + 86400
		isToday = false
	end
	return refresh_t, isToday
end

--获取道具购买信息
function FuncShop.getGoodsInfo(shopId, goodsId)
	local data = goodsData
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.PVP_SHOP then
		data = config_pvp_shop
    elseif shopId == ALLTYPES.TOWER_SHOP then
		data = config_tower_shop
	elseif shopId == ALLTYPES.GUILD_SHOP then
		data = config_guild_shop
	elseif shopId == ALLTYPES.WONDER_SHOP then
		data = config_wonder_shop
	end
	local info = data[goodsId]
	if not info then
		echoError("没有这个道具信息,goodsId:"..tostring(goodsId))
	end
	return info
end

--获取商店名称
function FuncShop.getShopNameById(shopId)
	if not shopId then return "" end
	local shopNameTids = FuncShop.SHOP_NAMES
	local tid = shopNameTids[shopId]
	local str = GameConfig.getLanguage(tid)
	return str
end


--获取道具价值 返回 类型_价格 字符串
function FuncShop.getGoodsCost(shopId, id)
	local info = FuncShop.getGoodsInfo(shopId, id)
	cost = info.cost[1]
	return cost
end

--获取商店信息
function FuncShop.getShopInfo( shopId )
	local info = shopData[shopId]
	if not info then
		echoError("没有这个商店信息,id:"..tostring(shopId))
	end
	return info
end


--获取商店开启条件
function FuncShop.getShopOpenCond( shopId )
	local info = FuncShop.getShopInfo(shopId)
	return info.condition
end

--获取商店开启花费
function FuncShop.getShopOpenCost( shopId )
	local info = FuncShop.getShopInfo(shopId)
	return info.openCostGold
end

--获取商店刷新时间
function FuncShop.getShopRefresh(shopId )
	local info =  FuncShop.getShopInfo(shopId)
	return info.ShopTime
end

-- for shop
function FuncShop.getShopOpenVipLevel(shopId)
	local condition = FuncShop.getShopOpenCond(shopId)
	if not condition then return 0 end
    local conditionGroup = numEncrypt:decodeObject(condition) 
    local v = conditionGroup[1]
    local vlevel = v.v
    return tonumber(vlevel)
end

--根据level or vip level 检查是否显示对应商店的按钮
function FuncShop.checkShopBtnCanShowByLevel(shopId)
	shopId = tostring(shopId)
	local ALLTYPES = FuncShop.SHOP_TYPES
	if shopId == ALLTYPES.NORMAL_SHOP_1 then --普通商店
		return true
	elseif shopId == ALLTYPES.NORMAL_SHOP_2 or shopId == ALLTYPES.NORMAL_SHOP_3 then --vip shop
		local vipLevel = UserModel:vip()
		local openVipLevel = FuncShop.getShopOpenVipLevel(shopId) 
		return tonumber(openVipLevel) <= tonumber(vipLevel)
	elseif shopId == ALLTYPES.PVP_SHOP then
		local arenaIsOpen = FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.PVP)
		return arenaIsOpen
    elseif shopId == ALLTYPES.ARTIFACT_SHOP then 
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_9) 
    elseif shopId == ALLTYPES.TOWER_SHOP then 
        return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.TOWER) 
	elseif shopId == ALLTYPES.CHAR_SHOP then
		return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.SHOP_6) 
	elseif shopId == ALLTYPES.GUILD_SHOP then
		return GuildModel:isInGuild()
	elseif shopId == ALLTYPES.WONDER_SHOP then
		return FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.WONDER_SHOP) 
	end
	return false
end

function FuncShop.checkVipShopCanOpen(shopId)
	local condition = FuncShop.getShopOpenCond(shopId)
	local canOpen = not UserModel:checkCondition(condition)
	return canOpen
end

function FuncShop.getShopKaiqiDisplayItems(shopId)
	local shopInfo = shopData[shopId..'']
	return shopInfo.displayBetterGoods
end

--获取商店 对应刷新次数的花费
function FuncShop.getRefreshCost( shopId,times )
	times = tostring(times)
	local info = buyData[shopId]
	--没有获取到 就拿0对应的数字
	if not info[times] then
		info = info["0"]
	else
		info = info[times]
	end

	--[1是货币类型  2是需要的货币单位]
	return info.cost[1];
end

function FuncShop.getShopItemResCostInfo(shopId, shopData)
    local shopItemId = shopData.id
    local costInfo = FuncShop.getGoodsCost(shopId, shopItemId)
    local needNums,hasNums,isEnough,resType = UserModel:getResInfo(costInfo)
    return resType, needNums
end

function FuncShop.isShopItemSoldOut(shopId, shopData)
	if shopData.buyTimes > 0 then
		return true
	end
	return false
end

function FuncShop.isVipShop(shopId)
	shopId = tostring(shopId)
	if shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_2 or shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_3 then
		return true
	end
	return false
end

function FuncShop.isQiPaoVisibleById(_itemId)
	local tips_data = config_shop_tips[tostring(_itemId)]
	if tips_data then
		return true, tips_data.translateTips
	end
	return false
end

-- 判断商店商品是否售罄
function FuncShop.isSoldOut( shopId,index,buyTimes )
	if shopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
		
	end
end
