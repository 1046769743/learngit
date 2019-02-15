--三皇抽奖系统
--Date  2016-12-27 10:40
--@Author:wukai

local lotterySoulOnlineData = nil -- 魂匣开启数据
local lotteryReward = nil
local lotteryOrder = nil


FuncNewLottery = FuncNewLottery or {}
FuncNewLottery.rewardquality = {
	white = 1, --白
	green = 2, --绿
	blue = 3, --蓝
	purple = 4, --紫
	gold = 5, --金
}

FuncNewLottery.freeerrorString = {
	[1] = GameConfig.getLanguage("#tid_lottery_1001"),
	[2] = GameConfig.getLanguage("#tid_lottery_1002"),
	[3] = GameConfig.getLanguage("#tid_lottery_1003"),
}
FuncNewLottery.RMBerrorString = {
	[1] = GameConfig.getLanguage("#tid_lottery_1004"),
	[2] = GameConfig.getLanguage("#tid_lottery_1005"),
	[3] = GameConfig.getLanguage("#tid_lottery_1006"),
	[4] = GameConfig.getLanguage("#tid_lottery_1007"),
	[5] = GameConfig.getLanguage("#tid_lottery_1008"),
}
FuncNewLottery.lotterytypetable = {
	[1] = 1,
	[2] = 2,
}


FuncNewLottery.iconName = {
	[1] = "lottery_img_cailiaojin.png",
	[2] = "lottery_img_huobanjin.png"
}



FuncNewLottery.rewardDataType = {90011,90012,90013,90014,90015,90016,90017,90018,90019,90021}


FuncNewLottery.NewLotteryModelone = "NewLotteryModelOnece"
FuncNewLottery.NewLotteryModelTne = "NewLotteryModelTnece"
FuncNewLottery.NewLotteryModelones = 0
FuncNewLottery.NewLotteryModelTnes = 0
FuncNewLottery.refreshServerTime = false

FuncNewLottery.DayNumMax = GameConfig.getLanguage("#tid_lottery_1009")

FuncNewLottery.spineSpeed = 2.0


function FuncNewLottery.init()
	lotterySoulOnlineData = Tool:configRequire("lottery.LotteryBoxOnline") -- 魂匣开启数据
	lotteryReward =  Tool:configRequire("lottery.LotteryReward")
	lotteryOrder = Tool:configRequire("lottery.LotteryOrder")
end
--获取免费单抽抽卡次数
function FuncNewLottery.getFreecardnumber()
	local number = FuncDataSetting.getDataByConstantName("LotteryFreeNum") 
	return number
end

function FuncNewLottery:getSpineSpeed()
	local level = FuncDataSetting.getDataByConstantName("QuickLotterySpine")
	return level
end


--获取免费单抽CD
function FuncNewLottery.getfreeCDtime()
	local time = FuncCommon.getCdTimeById(1)
	return time
end
--满足所需等级
function FuncNewLottery.getawardLevelopenfree()
	local level = FuncDataSetting.getDataByConstantName("LotteryTreasureOpen")
	return level 
end

--元宝单抽，每次消耗RMB
function FuncNewLottery.consumeOnceRMB()
	local RMBnumber = FuncDataSetting.getDataByConstantName("LotteryCommonConsume")
	return RMBnumber 
end
--元宝十抽，每次消耗RMB
function FuncNewLottery.consumeTenRMB()
	local RMBnumber = FuncDataSetting.getDataByConstantName("LotteryGoldConsume")
	return  RMBnumber
end

--同时造物几个
function FuncNewLottery:onTimeCreation()
	local number = FuncDataSetting.getDataByConstantName("LotteryTogetherMake")
	return  number
end

--加速造物消耗道具
function FuncNewLottery:speedUpCreationCostItem()
	local number = 1
	return  number
end



--消耗造物普通体验券
function FuncNewLottery.Ordninaryfreecardnumber()
	return 1 
end
--消耗造物高级体验券
function FuncNewLottery.SeniorRMBcardnumber()
	return 1 
end
function FuncNewLottery:getOrdninaryID()
	local id = FuncDataSetting.getDataByConstantName("LotteryOrdninaryCard")
	return id
end
function FuncNewLottery:getSeniorcardID()
	local id = FuncDataSetting.getDataByConstantName("LotterySeniorCard")
	return id
end


--获得刷新消耗铜钱次数
function FuncNewLottery.getlotteryShoprefreshitems()
	local numberstring = FuncDataSetting.getDataVector("LotteryRefreshCost")
	-- dump(numberstring,"刷新金币数量")
	local refreshitems =  tonumber(CountModel:getLotterymanyrefreshCount())
	local  sumnumber = 0
	for k,v in pairs(numberstring) do
		sumnumber = sumnumber + 1
	end
	-- echo("===========refreshitems=======",refreshitems)
	local index = nil --math.fmod(refreshitems,sumnumber)
	if refreshitems >=  3 then
  		index = 0
  	elseif refreshitems == 0 then
  		index = 1
  	elseif refreshitems == 1 then
  		index = 2
  	elseif refreshitems == 2 then
  		index = 3
	end
	-- echo("======获得刷新消耗次数=index==",refreshitems,sumnumber,index,numberstring[tostring(index)])
	return numberstring[tostring(index)]
end

-- function FuncNewLottery.setselectlotteryitems(itmes)
-- 	self.selectlotteryitem = itmes
-- end
-- function FuncNewLottery.getselectlotteryitems()
-- 	return self.selectlotteryitem
-- end

--免费抽奖类型（1）（5）
function FuncNewLottery.setlotteryFreeType( typeitmes )
	FuncNewLottery.lotteryFreeitems = typeitmes

end

function FuncNewLottery.getlotteryFreeType()
	return FuncNewLottery.lotteryFreeitems 
end

--元宝抽奖类型（1）（10)
function FuncNewLottery.setlotteryRMBType( typeitmes )
	FuncNewLottery.lotteryRMBitems = typeitmes
end

function FuncNewLottery.getlotteryRMBType()
	return FuncNewLottery.lotteryRMBitems 
end

--- 抽奖商店类型
function FuncNewLottery.setTouchawardtype(awardtype)
	if tonumber(awardtype) ==  1 then 
		FuncNewLottery.shoptype = FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP
	elseif tonumber(awardtype) ==  2 then
		FuncNewLottery.shoptype = FuncShop.SHOP_TYPES.LOTTER_MAGIC_SHOP
	end
	echo("========FuncNewLottery.shoptype=============",FuncNewLottery.shoptype)
end
function FuncNewLottery.getTouchawardtype()
	return FuncNewLottery.shoptype
end

--设置抽奖类型
function FuncNewLottery.setlotterytype(typeid)
	FuncNewLottery.lotterytype = typeid
end
--获得抽奖类型
function FuncNewLottery.getlotterytype()
	return FuncNewLottery.lotterytype
end
function FuncNewLottery.getfreeIDerror(errorid)
	if errorid ~= nil then
		local errorstring = FuncNewLottery.freeerrorString[tonumber(errorid)]
		if tonumber(errorid) == 2 then
			WindowControler:showWindow("GetWayListView","3008")
		end
		WindowControler:showTips(errorstring)
	end
end

function FuncNewLottery.getRMBIDerror(errorid)
	if errorid ~= nil then
		local errorstring = FuncNewLottery.RMBerrorString[tonumber(errorid)]
		if tonumber(errorid) == 2 then
			WindowControler:showWindow("GetWayListView",FuncNewLottery:getSeniorcardID())
		elseif tonumber(errorid) == 6 then
			WindowControler:showWindow("GetWayListView",FuncNewLottery:getSeniorcardID())
		end
		WindowControler:showTips(errorstring)
	end
end
-------------------- 初始NPC ---------------------
function FuncNewLottery.initNpc(_partnerId)
    local t1 = os.clock()
    local partnerData = FuncPartner.getPartnerById(_partnerId);
    local bossConfig = partnerData.dynamic
    local arr = string.split(bossConfig, ",");
--    local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncPartner.getHeroSpine(_partnerId)
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    if arr[4] ~= nil then -- 缩放
        local scaleNum = tonumber(arr[4])
        if scaleNum > 0 then
            scaleNum = 0 - scaleNum    
        end
        sp:setScaleX(scaleNum)
        sp:setScaleY(-scaleNum)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    
    sp:setShadowVisible(false)
    -- echo(os.clock() - t1,"-------- spin ddddd 消耗时间");
    return sp
end
function FuncNewLottery.CachePartnerdata()
	local data = PartnerModel:getAllPartner()

	-- dump(data,"33333333333333333333333")
	
	FuncNewLottery.PartnerData = {}
	for k,v in pairs(data) do
		FuncNewLottery.PartnerData[tostring(k)] = k
	end
end
function FuncNewLottery.addCachePartnerdata(partnermodeoID)
	local partnermodeo = {}
	-- partnermodeo[tostring(partnermodeoID)] = partnermodeoID
	-- table.insert(FuncNewLottery.PartnerData,partnermodeo)
	if not FuncNewLottery.PartnerData then
		FuncNewLottery.PartnerData = {}
	end
	FuncNewLottery.PartnerData[tostring(partnermodeoID)] = tostring(partnermodeoID)
end
--设置提换的位置
function FuncNewLottery.tihuangIndex(index)
	FuncNewLottery.tihuangobjectIndex = index
end
--获得提换的位置
function FuncNewLottery.gettihuangIndex()
	return tonumber(FuncNewLottery.tihuangobjectIndex)
end
function FuncNewLottery.getRefreshtimes()
	local time = FuncDataSetting.getOriginalData("LotteryShopRefreshInterval") 
	return time
end
--面CD时间的等级
function FuncNewLottery:getFreeCdLevel()
	return FuncDataSetting.getDataByConstantName("LotteryFreeLv") 
end
function FuncNewLottery.test()
	-- dump(lotterySoulOnlineData, "lotterySoulOnlineData")
	-- dump(FuncNewLottery.getMyServerLotterySoulData(), "FuncNewLottery.getMyServerLotterySoulData()")
	-- dump(FuncDataSetting.getDataByConstantName("LotteryBoxVip"), "FuncDataSetting.getDataByConstantName(constantName)")
	-- echo("FuncDataSetting.getDataByConstantName", FuncDataSetting.getDataByConstantName("LotteryBoxVip"))
end
-- 获取本服魂匣信息
function FuncNewLottery.getMyServerLotterySoulData()
	local result = nil
	for k,v in pairs(lotterySoulOnlineData) do
		if FuncNewLottery.checkOpen(v) then
			result = table.copy(v)
			break
		end
	end
	return result
end

-- 根据限制条件判断活动是否开启
function FuncNewLottery.checkOpen(onlineInfo)
	local info = onlineInfo
	-- 一键开关
	local isOpen = FuncActivity.onlineActVisibleOpenCondition(info)
	if not isOpen then return false end
	-- 平台
	local platformOk = FuncActivity.onlineActVisiblePlatformCondition(info)
	if not platformOk then return false end
	-- 渠道
	local channelOk = FuncActivity.onlineActVisibleChannelCondition(info)
	if not channelOk then return false end
	-- 开启时间
	local timeOk = FuncActivity.onlineActVisibleTimeCondition(info)
	if not timeOk then return false end
	-- 服务器
	local serverOk = FuncActivity.onlineActVisibleServerCondition(info)
	if not serverOk then return false end

	return true
end

--获得抽卡奖励的数据库
function FuncNewLottery.getRewardData()
	-- local lotteryReward = lotteryReward
	local alldataID = FuncNewLottery.rewardDataType
	local reward = {}
	for k,v in pairs(alldataID) do
		local dataInfo = FuncItem.getRewardData(v)
		table.insert(reward,dataInfo.info)
	end

	local newtable = {}
	for k,v in pairs(reward) do
		local sigedata = v
		for _x=1,#sigedata do
			local data = string.split(sigedata[_x],",")
			local quality =  FuncDataResource.getQualityById( data[2],data[3] )
			local dataTab = {
				_type = data[2],
				itemID = data[3],
				quality = quality,
			}
			if #newtable == 0 then
				table.insert(newtable,dataTab)
			else
				local issave = false
				for i=1,#newtable do
					if newtable[i].itemID == dataTab.itemID and newtable[i]._type == dataTab._type then
						issave = true
					end
				end
				if not issave then
					table.insert(newtable,dataTab)
				end
			end
		end
	end
	local partnerData = {}
	local itremData = {}
	for i=1,#newtable do
		local parType = FuncDataResource.RES_TYPE.PARTNER
		if newtable[i]._type == parType then
			local partnerId = newtable[i].itemID
			local star = FuncPartner.getPartnerById(partnerId)
			newtable[i].star = star.initStar
			table.insert(partnerData,newtable[i])
		else
			newtable[i].star = 1
			table.insert(itremData,newtable[i])
		end
	end
	return partnerData,itremData
end

--区分伙伴碎片和道具
function FuncNewLottery.debrisAndItem(alldata)
	if alldata == nil then
		return {}
	end
	local partnerdebris = {}
	local allitemdata = {}
	for i=1,#alldata do
		local itemId = alldata[i].itemID
		local itemdata = FuncItem.getItemData(itemId)
		local subType = itemdata.subType_display
		if subType == 202 then
			-- table.insert(partnerdebris,alldata[i])
		else
			table.insert(allitemdata,alldata[i])
		end
	end
	return partnerdebris,allitemdata
end


function FuncNewLottery.commSelectItemData(allData ,singdata)
	if allData == nil or singdata == nil then
		return {}
	end
	local isshave = false
	for i=1,#allData do
		if singdata.itemID == allData[i].itemID then
			isshave = true
		end
	end
	if not isshave  then
		table.insert(allData,singdata)
	end
	return allData
end

-- ---消耗加速道具几个
function FuncNewLottery.costCreateNumResoure()
	-- body
end

--获取最大造物的数量
function FuncNewLottery.getMaxCreateAllItem()
	return 5
end

--瞬时符ID
function FuncNewLottery.getCostItemId()
	local itemID = FuncDataSetting.getDataByConstantName("LotterySpeededUpCost")
	return itemID
end

--获得随机奖励的数据
function FuncNewLottery.lotteryRewardOrder()
	local orderArr = {}
	for k,v in pairs(lotteryReward) do
		if v.order then
			table.insert(orderArr,v.order)
		end
	end
	return orderArr
end


function FuncNewLottery.getOrderDataById(orderArr)
	local rewardIdArr = {}
	for k,v in pairs(orderArr) do
		local data = lotteryOrder[tostring(v)]
		for _,valuer in pairs(data.reward) do
			local reward = string.split(valuer, ",")
			local _type = reward[1]
			local id = reward[2]
			local num = reward[3]
			if _type == "99" then
				rewardIdArr[id] = num
			end
		end
	end
	return rewardIdArr
end


function FuncNewLottery.getRewardArr()
	local newReward = {}
	local orderarr = FuncNewLottery.lotteryRewardOrder()

	local rewardIdArr = FuncNewLottery.getOrderDataById(orderarr)
	for k,v in pairs(rewardIdArr) do
		local id = k
		FuncNewLottery.getRewardDataByItemId(id,newReward)
	end

	return newReward
end

function FuncNewLottery.getRewardDataByItemId(id,newReward)
	local data = FuncItem.getRewardData(id)
	for _,valuer in pairs(data.info) do
		local reward = string.split(valuer, ",")
		local _type = reward[2]
		local rewardId = reward[3]
		local num = reward[4]
		if _type ~= "99" then
			local strReward = _type..","..rewardId..","..num
			table.insert(newReward,strReward)
		else
			FuncNewLottery.getRewardDataByItemId(rewardId,newReward)
		end
	end
end



---设置头像
function FuncNewLottery.setpartnerIconById(partnerData,_mc)
	if _mc then
		_mc:showFrame(1)
		local _ctn = _mc:getViewByFrame(1).ctn_1
		local star = _mc:getViewByFrame(1).mc_1
		_ctn:removeAllChildren()
		local partnerDdata  = FuncPartner.getPartnerById(partnerData.itemID)
		local icon = partnerDdata.icon
		local iconHero = FuncRes.iconHero( icon )
		local sprite = display.newSprite(iconHero)
		sprite:size(86,86)
		_ctn:addChild(sprite)
		star:showFrame(partnerData.star or 2)

		local mcName = _mc:getViewByFrame(1).mc_name
		mcName:showFrame(2)
		mcName.currentView.txt_1:setString(GameConfig.getLanguage(partnerDdata.name))
	end
end
