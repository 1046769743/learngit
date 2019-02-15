--三皇抽奖系统
--2016-12-27 10:40
--@Author:wukai



local NewLotteryModel = class("NewLotteryModel",BaseModel);

function NewLotteryModel:ctor()

end
--[[
{
	goldTimes = 1, 元宝抽卡次数
	goldLuckyCost = 1,元宝幸运值
	superPartnerTimes = 1,抽到金品伙伴次数
	superTreasureTimes = 1,-抽到法宝次数
	
	"抽奖系统数据2" = {
	    "1" = 9101
	    "2" = 9102
	    "3" = 9103
	    "4" = 9104
	    "5" = 9105
	    "6" = 9106
	}
	 "抽奖系统数据3" = {
     "1" = {
         "id"        = 1
         "lotteryId" = 9107
     }
     "2" = {
         "id"        = 2
         "lotteryId" = 9108
     }
     "3" = {
         "id"        = 3
         "lotteryId" = 9109
     }
     "4" = {
         "id"        = 4
         "lotteryId" = 9110
     }
     "5" = {
         "id"        = 5
         "lotteryId" = 9111
     }
     "6" = {
         "id"        = 6
         "lotteryId" = 9112
     }
 }
}
]]
function NewLotteryModel:init(data,freedatas,RMBdatas,newLotteryModel)

    NewLotteryModel.super.init(self, data);
    self.initDatas = data
    self.freedata = freedatas
    self.RMBdata = RMBdatas
    self.newLotteryModel = newLotteryModel
    self.endtime = 0
    self.refreshnumber = nil
    self.Lastrefreshtime = 0

    self.gatherSoulDataPos = {}

    -- dump(self.initDatas,"抽卡数据==1===============")  --nextTreasureFlag 
    -- dump(self.freedatas,"抽卡数据===2==============")  --nextTreasureFlag 
    -- dump(self.newLotteryModel,"抽卡数据==3===============")  --nextTreasureFlag 
    -- dump(self.RMBdata,"元宝数据")
    -- EventControler:addEventListener(TimeEvent.TIMEEVENT_STATIC_CLOCK_REACH_EVENT, 
        -- self.refreshitemsnumbers, self)
	-- self.diyicichouka = 0
	WindowControler:globalDelayCall(function ()
		self:sendMainLotteryRed()
	end,0.5)
	self:registListenEvent()
	self.goldnumber = LS:pub():get("SAVELOCALLINGSHI"..UserModel:rid(),nil)

	self:readLocalData()

	self:getLocalnextButtonNum()

	
end

--获取新三皇台数据
function NewLotteryModel:getLotteryNewData()
	local allData = UserModel:lotteryQueues()
	local newData = {}
	for k,v in pairs(allData) do
		if type(v) == "table" then
			newData[k] = v
		end
	end
	-- dump(allData,"获取新三皇台数据 ==== ")
	return allData
end

--是否在造物(true   1  正在造物  2 造物完成 )
function NewLotteryModel:isDoingCreation(_time)
	local serverTime = TimeControler:getServerTime() + 1  ---1秒误差
	if _time ~= nil then
		if serverTime < _time then
			return false,1
		elseif serverTime >= _time then  --造物完成
			return true,2
		end
	end
	return false
end


function NewLotteryModel:getRefreshNumber()
	self.refreshnumber = self.initDatas.shopFlushPoint or 10
	local number = self:timeGetTimes()
	if self.refreshnumber == nil then
		return nil
	end
	return tonumber(self.refreshnumber) + number
end
function NewLotteryModel:getLastrefreshtimes()
	self.Lastrefreshtime = self.initDatas.shopFlushTime or 0
	local time = FuncNewLottery.getRefreshtimes()
	local number = self:timeGetTimes()
	return tonumber(self.Lastrefreshtime)  + time*(number+1)
end
function NewLotteryModel:setrefreshtimes(number)
	self.initDatas.shopFlushTime = TimeControler:getServerTime()
end
function NewLotteryModel:timeGetTimes()
	local numbers = 0
	local refreshsumnumber = tonumber(FuncDataSetting.getOriginalData("RefreshNum3"))
	if self.initDatas.shopFlushPoint == nil then
		self.initDatas.shopFlushPoint = refreshsumnumber
	end
	if self.initDatas.shopFlushPoint ~= refreshsumnumber then
		local jiangetime =  FuncNewLottery.getRefreshtimes()
		numbers = TimeControler:countIntervalTimes(jiangetime,self.initDatas.shopFlushTime,TimeControler:getServerTime())
	end
	return numbers
end
function NewLotteryModel:registListenEvent()
    EventControler:addEventListener("CD_ID_NEWLOTTERY_TOKEN_FREE",
        self.sendMainLotteryRed, self);
    EventControler:addEventListener(NewLotteryEvent.ONTIME_REFRESH_SHOP_VIEW,
        self.refreshShopData, self);
    EventControler:addEventListener(UserEvent.USEREVENT_GOLD_CHANGE,
        self.sendMainLotteryRed, self);
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, 
        self.sendMainLotteryRed, self)

    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE,
    	self.sendMainLotteryRed,self)
    
end
---刷新灵石商店数据
function NewLotteryModel:refreshShopData()
	local function _callback()
		EventControler:dispatchEvent(NewLotteryEvent.REFRESH_REPLACE_VIEW)
	end
	ShopServer:getShopInfo(_callback)
end

function NewLotteryModel:updateData(data)

	-- dump(data,"抽卡数据变化1111111")
	NewLotteryModel.super.updateData(self, data);
    -- self.initDatas = nil
    if data.commonTimes ~= nil then
    	self.initDatas.commonTimes = data.commonTimes
    end
    if data.goldTimes ~= nil then
    	self.initDatas.goldTimes = data.goldTimes
    end
    if data.nextTreasureFlag ~= nil then
    	self.initDatas.nextTreasureFlag = data.nextTreasureFlag
    end
    if data.shopFlushPoint ~= nil then
    	self.refreshnumber = data.shopFlushPoint
    end
    if data.shopFlushTime ~= nil then
    	self.Lastrefreshtime = data.shopFlushTime
    end

    
end
function NewLotteryModel:getnextTreasureFlag()
	-- dump(self.initDatas)
	return self.initDatas.nextTreasureFlag
end
function NewLotteryModel:FreeCounts()
	if self.initDatas.commonTimes == nil then
		self.initDatas.commonTimes = 0
	end
	return tonumber(self.initDatas.commonTimes)

end
function NewLotteryModel:RMBcounts()
	if self.initDatas.goldTimes == nil then
		self.initDatas.goldTimes = 0
	end
	return tonumber(self.initDatas.goldTimes)
end

--设置免费抽奖数据
function NewLotteryModel:setfreeawardpool(goodlist)
	self.freedata = goodlist
end

--设置元宝抽奖数据
function NewLotteryModel:setRMBawardpool(goodlist)
	self.RMBdata = goodlist
end
-- function function_name( ... )
-- 	-- body
-- end


function NewLotteryModel:getfreeData()
	return self.freedata
end
function NewLotteryModel:getRMBData()
	return self.RMBdata
end


--获得免费抽奖次数
function NewLotteryModel:getLotterynumber()
	return CountModel:getLotteryfreeCount()
end
--获得RMB免费单抽奖次数
function NewLotteryModel:getRMBoneLottery()
	return CountModel:getLotteryGoldFreeCount()
end
--获得RMB单抽奖次数
function NewLotteryModel:getRMBPayLottery()
	return CountModel:getLotteryGoldPayCount()
end

--免费抽奖CD
function NewLotteryModel:getCDtime()
	if UserModel:level() >= FuncNewLottery:getFreeCdLevel() then
		return 0
	end
	self.endtime = CdModel:getCdExpireTimeById(1)
	-- echo("========self.endtime====",self.endtime)
	if self.endtime ~= 0 then
		-- echo("=========TimeControler=========",TimeControler:getServerTime())
		if self.endtime - TimeControler:getServerTime() < 0 then
			return 0
		else
			return self.endtime - TimeControler:getServerTime()
		end
	else
		return 0
	end
end

-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
--             {redPointType = HomeModel.REDPOINT.NPC.LOTTERY, isShow = true});


function NewLotteryModel:setCDStime(starttime,endtime)
	if starttime ~= nil then
		self.starttime = starttime  --结束时间
	end
	if endtime ~= nil then
		self.endtime = endtime
	end
end

--获得免费普通抽卡卷
function NewLotteryModel:getordinaryDrawcard()
	local itemid = FuncNewLottery:getOrdninaryID()
	local number = ItemsModel:getItemNumById(tostring(itemid))
	-- echo("=========itemid======ordinarynumber=======",itemid,number)
	return  number
end
--获得高级抽卡卷
function NewLotteryModel:getseniorDrawcard()
	local itemid = FuncNewLottery:getSeniorcardID()
	local number = ItemsModel:getItemNumById(tostring(itemid))
	-- echo("=========itemid======seniorDrawcard=======",itemid,number)
	return number
end
--获得刷新令
function NewLotteryModel:getshopRefreshcard()
	return UserModel:getShopToken() or 0
end
--判断免费是否可以抽卡--(1,2,3表示错误ID在func里面)
function NewLotteryModel:FreeCanlottery()
	local items = FuncNewLottery.getlotteryFreeType()   -- 1 ，5  
	local ordinarycard = NewLotteryModel:getordinaryDrawcard()
	local time = NewLotteryModel:getCDtime()

	if items == 1 then --一次
		if time ~= 0 then
			if ordinarycard > 0 then
				return true,2   --2 
			
			else
				return false,1   --1 时间CD
			end
		else
			local loterynumber = CountModel:getLotteryfreeCount()
			if loterynumber >= FuncNewLottery.getFreecardnumber() then
				if ordinarycard > 0 then
					return true,2
				else
					return false,2
				end
			else
				return true,2

			end
		end
	else   --五次
		if ordinarycard >= tonumber(items) then
			return true,2
		else
			return false,2
		end
	end
end
--普通抽显示红点
function NewLotteryModel:getfreelotteryshowRed()
	local time = NewLotteryModel:getCDtime()
	if time == 0 then
		if NewLotteryModel:getLotterynumber() >= 5 then
			if NewLotteryModel:getordinaryDrawcard() >= 1 then
				return true
			else
				return false
			end
		else
			return true
		end
	else
		return false
	end
end
--花元宝显示红点
function NewLotteryModel:getRMBlotteyShowRed()
	local RMBonce = NewLotteryModel:getRMBoneLottery() 
	local data = self:getLotteryNewData()
	local sumNum = FuncNewLottery.getMaxCreateAllItem()
	if RMBonce ~= 0 then
		if NewLotteryModel:getseniorDrawcard() > 0 then
			if table.length(data) < sumNum then
    			return true
    		else
    			return false
    		end
    	else
    		return false
    	end
    else
    	return true
    end
    return false
end

function NewLotteryModel:newGetRMBlotteyShowRed(_type)
	--高级造物福的数量
	local itemNum =  NewLotteryModel:getseniorDrawcard()
	if itemNum <= 0 then
		return false
	end
	--所有造物的数据
	local allcreaData = self:getLotteryNewData()
	local sumNum = FuncNewLottery.getMaxCreateAllItem()
	if table.length(allcreaData) >= sumNum then
		return false
	end
	
	local count = sumNum - table.length(allcreaData)
	if _type == 1 then
		local RMBonce = NewLotteryModel:getRMBoneLottery()
		if RMBonce == 0 then
			return true
		end
		if count > 0 then
			if itemNum > 1 then
				return true
			end
		else
			return false
		end
	elseif _type  == 2 then
		if itemNum >= count then
			return true
		end
	end
	return false
end

--造物是否可以领取
function NewLotteryModel:isgetRewardRed()
	local allcreaData = self:getLotteryNewData()
	local serverTimre = TimeControler:getServerTime()
	for k,v in pairs(allcreaData) do
		if type(v) == "table" then
			local _finishTime = v.finishTime
			if serverTimre >= _finishTime then
				return true
			end
		end
	end
	return false
end



function NewLotteryModel:RMBandFreeLotteryItemsShowRed()
	local time = NewLotteryModel:getCDtime()
	if time == 0 then
		if NewLotteryModel:getLotterynumber() < 5 then
			return true
		end
	end
	local RMBonce = NewLotteryModel:getRMBoneLottery() 
	if RMBonce == 0 then
    	return true
    end


	return false
end
function NewLotteryModel:sendMainLotteryRed()
	
	-- local showRed = self:RMBandFreeLotteryItemsShowRed()

	local isshow1 = self:newGetRMBlotteyShowRed(1)
	local isshow2 = self:newGetRMBlotteyShowRed(2)
	local isshow3 = self:isgetRewardRed()
	local isshow4 = self:getRMBlotteyShowRed()
	local showRed = false

	-- echoError("=======isshow1=======",isshow1,isshow2,isshow3,isshow4,showRed)
	local serverTime =  TimeControler:getServerTime()
	local data = self:getLotteryNewData()
	for k,v in pairs(data) do
		if v.finishTime > serverTime then
			TimeControler:startOneCd("LOTERY_ONTIME"..k,v.finishTime - serverTime + 2 )
			EventControler:addEventListener("LOTERY_ONTIME"..k, self.sendMainLotteryRed, self);
		end
	end

	showRed = isshow1 or isshow2 or isshow3 or isshow4 or showRed
	EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.NPC.LOTTERY, isShow = showRed});


end
function NewLotteryModel:sendHomeRed()
	-- local singred = NewSignModel:isNewSignRedPoint()
	-- local lingshired = self:fuliIsShowRed()
	-- EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
	-- {redPointType = HomeModel.REDPOINT.MAPSYSTEM.WELFARE, isShow = singred or lingshired})
end	


function NewLotteryModel:setrepleacedata(data)
	self.repleacedata = data
end
function NewLotteryModel:getrepleacedata()
	return self.repleacedata
end

function NewLotteryModel:settouchreplacedata(itemdata)
	self.replaceitemdata = itemdata
end
function NewLotteryModel:gettouchreplacedata()
	return self.replaceitemdata
end
function NewLotteryModel:setServerData(reward)
	self.serverdata = reward
end
function NewLotteryModel:getServerData()
	return self.serverdata 
end
-- 魂匣抽奖奖励
function NewLotteryModel:setSoulReward( rewards )
	local result = {}

	for i,group in ipairs(rewards) do
		result[i] = {}
		local hIdx = nil -- 整卡的位置
		for _,reward in ipairs(group) do
			local tmp = string.split(reward, ",")
			table.insert(result[i], tmp)
			if tonumber(tmp[1]) == 18 then -- 抽到英雄
				hIdx = #result[i]
			end
		end
		if hIdx then -- 将英雄卡调整到最后
			local tmp = result[i][hIdx]
			table.remove(result[i], hIdx)
			table.insert(result[i], tmp)
		end
	end

	self.soulReward = result
end
-- 获取魂匣抽奖奖励
function NewLotteryModel:getSoulReward()
	return self.soulReward
end
-- 清空魂匣抽奖数据
function NewLotteryModel:clearSoulRewardData()
	self.soulReward = nil
end

function NewLotteryModel:setihuangIndex( _index )
	self.tihuangID = _index
end
function NewLotteryModel:getihuangIndex( )
	return self.tihuangID,1--tonumber(self.quality)
end
-- function NewLotteryModel:setLastrefreshtimes( time )
-- 	self.Lastrefreshtimes = time
-- end
-- function NewLotteryModel:getLastrefreshtimes()
-- 	return self.Lastrefreshtimes
-- end
function NewLotteryModel:isLotterySoulOpen()
	local vip = tonumber(FuncDataSetting.getDataByConstantName("LotteryBoxVip"))
	-- 获取本服魂匣信息
	local soulData = FuncNewLottery.getMyServerLotterySoulData()
	if soulData and tonumber(UserModel:vip()) >= vip then
		return true
	else
		return false
	end
end

--保存本地领取的灵石数量
function NewLotteryModel:saveLocalGold(goldnumber)
	self.goldnumber = goldnumber
end
function NewLotteryModel:getLocalGold()
	return self.goldnumber or 0
end
--可以替换的灵石数量
function NewLotteryModel:fuliIsShowRed()
	local systemname = FuncCommon.SYSTEM_NAME.SHOP_7
	local isopen = FuncCommon.isSystemOpen(systemname)
	if not isopen then
		return false
	end
	
	-- 特权未开
	-- if not MonthCardModel:checkLingShiShopOpen( ) then
	-- 	return false
	-- end

	local number = UserModel:getGoldConsumeCoinInner()
	local isshowred =false
	if number ~= 0 then
		isshowred = true
	end
	return isshowred
end



function NewLotteryModel:getallPreviewData()
	local alldata = FuncNewLottery.getRewardArr()

	local partnerData = {}
	local itremData = {}


	local parType = FuncDataResource.RES_TYPE.PARTNER
	for i=1,#alldata do
		local data = string.split(alldata[i], ",");
		local rewardtype = data[1]
		local rewardId  = data[2]
		local quality =  FuncDataResource.getQualityById( rewardtype,rewardId )
		local lastdata = {
			_type = rewardtype,
			itemID = rewardId,
			quality = quality,
		}
		if rewardtype == parType then
			local partnerId = lastdata.itemID
			local star = FuncPartner.getPartnerById(partnerId)
			lastdata.star = tonumber(star.initStar)
			partnerData = FuncNewLottery.commSelectItemData(partnerData,lastdata)
		else
			lastdata.star = 1
			itremData = FuncNewLottery.commSelectItemData(itremData,lastdata)
		end

	end
	local partnerdebris,allitemdata = FuncNewLottery.debrisAndItem(itremData)

	-- dump(partnerData,"3333333333333333333333")

	partnerData =  self:tableSort(partnerData)
	partnerdebris =  self:tableSort(partnerdebris)
	-- itremData =  self:tableSort(itremData)

	-- for i=1,#partnerdebris do
	-- 	table.insert(partnerData,partnerdebris[i])
	-- end
	for i=#partnerdebris,1,-1 do
		table.insert(allitemdata,1,partnerdebris[i])
	end

	return partnerData,allitemdata
end



function NewLotteryModel:tableSort(arrdata)

   	table.sort(arrdata,function(a,b)
        local rst = false
        if a.star > b.star then
        	rst = true
        else
        	if a.quality > b.quality then
	            rst = true
	        else
	        	if a.itemID > b.itemID then
	        		rst = true
	        	end
	            rst = false
	        end
	    end
        return rst
    end)
   return arrdata
end

function NewLotteryModel:setselectIndex(_index)
	self.selectIndex = _index
end
function NewLotteryModel:getselectIndex()
	return self.selectIndex
end

--加速道具
function NewLotteryModel:speedUpItremData()
	local id = FuncNewLottery.getCostItemId()   
	local num = ItemsModel:getItemNumById(id)
	return num
end


--显示瞬时显不显示
function NewLotteryModel:setGougouShow(isshow)
	self.gougouShow = isshow
end

function NewLotteryModel:getGougouShow()
	return self.gougouShow or false
end

--判断造物是否全部完成
function NewLotteryModel:getAddDataIsCreateOk()
	local data = self:getLotteryNewData()
	local allData = {}
	local index = 1
	for k,v in pairs(data) do
		if type(v) == "table" then
			v.id = k
			allData[index] = v
			index = index + 1 
		end
	end

	local serveTime  = TimeControler:getServerTime()
	local num = 0
	for k,v in pairs(allData) do
		if serveTime >= v.finishTime then
			num = num + 1
		end
	end

	if num == table.length(allData) then
		return true
	else
		return false
	end

end


--获得可以当前里面有几个造物的东西
function NewLotteryModel:getAllDataNum()
	local data = self:getLotteryNewData()
	local allData = {}
	local index = 1
	for k,v in pairs(data) do
		if type(v) == "table" then
			v.id = k
			allData[index] = v
			index = index + 1 
		end
	end

	return table.length(allData)
end

--设置造物的数据和位置
function NewLotteryModel:setZaoWuDataAndPos(data,pos)
	


	-- dump(self.gatherSoulDataPos,"设置造物的数据和位置==11111===")
	if pos ~= nil and type(pos) ~= "table" then
		for k,v in pairs(data) do
			local newData = {}
			newData = v
			newData.id = k
			newData.pos = pos
			table.insert(self.gatherSoulDataPos,newData)
		end
	else
		local index = 1
		for k,v in pairs(data) do
			local newData = {}
			newData = v
			newData.id = k
			newData.pos = pos[index]
			index = index + 1
			table.insert(self.gatherSoulDataPos,newData)
		end
	end
	-- dump(self.gatherSoulDataPos,"设置造物的数据和位置==2222===")
	self:posSaveTolocal()
end


function NewLotteryModel:removegatherSoulData()

	-- dump(self.gatherSoulDataPos,"删除前 ========")
	local data = self:getLotteryNewData()
	local newgatherSoulData = {}
	for k,v in pairs(data) do
		for _k,_v in pairs(self.gatherSoulDataPos) do
			if k == _v.id then
				local newData = {}
				newData = v
				newData.id = k
				newData.pos = _v.pos
				table.insert(newgatherSoulData,newData)
			end
		end
	end
	self.gatherSoulDataPos = {}
	self.gatherSoulDataPos = newgatherSoulData
	-- dump(self.gatherSoulDataPos,"删除后 ========")
	self:posSaveTolocal()
end


--随机取pos
function NewLotteryModel:randomPos(_type,count)
	if _type == 1 then
		-- self.gatherSoulDataPos
		if table.length(self.gatherSoulDataPos) == 0 then
			return math.random(1,5)
		else
			local arrPos = {}
			for k,v in pairs(self.gatherSoulDataPos) do
				if v.pos then
					arrPos[tonumber(v.pos)] = true
				end
			end
			while true do
				local random = math.random(1,5)
				if not arrPos[tonumber(random)]  then
					return random
				end 
			end
		end
	else
		if table.length(self.gatherSoulDataPos) == 0 then
			local posArr = {}
			if count == 5 then
				for i=1,5 do
					posArr[i] = i
				end
			else
				for i=1,count do
					posArr[i] = i
				end
			end
			return posArr
		else
			local arrPos = {}
			for k,v in pairs(self.gatherSoulDataPos) do
				if v.pos then
					arrPos[tonumber(v.pos)] = true
				end
			end
			local pos = {}
			for i=1,5 do
				if arrPos[i] == nil then
					table.insert(pos,i)
				end
			end
			local newpos = {}
			for i=1,count do
				if pos[i] then
					table.insert(newpos,pos[i])
				end
			end
			return newpos
		end
	end

end

--保存位置到本地
function NewLotteryModel:posSaveTolocal()
	local data  = self.gatherSoulDataPos
	LS:prv():set(StorageCode.lottery_pos_save,json.encode(data))
end


--获得聚魂的所有数据
function NewLotteryModel:getAllJuHunData( localdata )
	if not localdata then
		localdata = {}
	end
	local data = self:getLotteryNewData()

	-- dump(data,"222222222222222222222")
	if table.length(self.gatherSoulDataPos) == 0 then
		self.gatherSoulDataPos = {}
		local index = 1
		for k,v in pairs(data) do
			-- if table.length(localdata) ~= 0 then
			-- 	for _k,_v in pairs(localdata) do
			-- 		if k == _v.id then
			-- 			local newData = {}
			-- 			newData = v
			-- 			newData.id = k
			-- 			newData.pos = _v.pos
			-- 			table.insert(self.gatherSoulDataPos,newData)
			-- 		end
			-- 	end
			-- else
				local newData = {}
				newData = v
				newData.id = k
				newData.pos = index
				index = index + 1

				table.insert(self.gatherSoulDataPos,newData)
			-- end
		end
		for k,v in pairs(self.gatherSoulDataPos) do
			if table.length(localdata) ~= 0 then
				for key,_v in pairs(localdata) do
					if v.id == _v.id then
						v.pos = _v.pos
					end
				end
			end
		end

	end
end


function NewLotteryModel:readLocalData()
	local jsondata = LS:prv():get(StorageCode.lottery_pos_save,"")
	local localdata = {}
	-- echo("=======jsondata==========",jsondata,type(jsondata))
	if jsondata ~= "" then
		localdata = json.decode(jsondata)
	end
	-- dump(localdata,"=====获取本地造物的数据======")
	if type(localdata) ~= "table" then
		localdata = {}
	end

	self:getAllJuHunData( localdata )
	
end

function NewLotteryModel:getGatherSoulData()
	local data  = self.gatherSoulDataPos
	local function sortFunc(a, b)
		return a.finishTime < b.finishTime
	end

	table.sort(data, sortFunc)

	return data
end


--是否全部完成CD
function NewLotteryModel:allherSoulDataIsFinish()
	local data  = self.gatherSoulDataPos
	if data ~=  nil  then
		for k,v in pairs(data) do
			local serverTime = TimeControler:getServerTime()
			if v.finishTime > serverTime then
				return false
			end
		end
		if table.length(data) <= 0 then
			return false
		end
	end
	return true
end


--跳转到界面的方法 false 跳转到聚魂界面，   true跳转到化形界面
function NewLotteryModel:judgeTODOVivew()
	local data = self:getLotteryNewData()
	local num = self:getseniorDrawcard()
	local sumNum = FuncNewLottery.getMaxCreateAllItem()
	if table.length(data) == 0  then
		return false
	else
		if table.length(data) >=  sumNum then
			return true
		else
			local ishas = self:isgetRewardRed()  --有可领取的
			if ishas then
				return true
			else
				if num == 0 then
					return true
				else
					return false
				end
			end
		end

	end
	return false
end


--获取抽卡总次数
function NewLotteryModel:getLotterSumCount()
   local data =  UserModel:lotteryExt()
   return data.goldTimes or 0
end



function NewLotteryModel:getnextButtonNum()
	local count = self.nextButton or 0
	return count
end

function NewLotteryModel:getLocalnextButtonNum()
	self.nextButton = tonumber(LS:prv():get(StorageCode.lottery_next_btton,0))
end

--设置是否快速聚魂
function NewLotteryModel:setIsQucikSoul( value )
	self._isQuickSole = value

end



function NewLotteryModel:checkIsQuickSoul()
	return self._isQuickSole
end



--设置是否第一次点击快速聚魂
function NewLotteryModel:setIsFirstQuickSoulButton( value )
	self._isFirstQuickSole = value

end


function NewLotteryModel:getIsFirstQuickSoulButton()
	return self._isFirstQuickSole
end


--设置继续聚魂
function NewLotteryModel:setIsContinueSoulButton( value )
	self._isContinueQuickSole = value

end


function NewLotteryModel:getIsContinueSoulButton()
	return self._isContinueQuickSole
end



function NewLotteryModel:setQuickBuySoul( value )
	echo("=====value====",value)
	if value == true then
		LS:prv():set(StorageCode.gatherSoul_autoBuy,"1")
	else
		LS:prv():set(StorageCode.gatherSoul_autoBuy,"0")
	end
end

--判断是否是快捷购买
function NewLotteryModel:checkIsQuickBuySoul(  )
	return LS:prv():get(StorageCode.gatherSoul_autoBuy) == "1"
end


--设置聚魂快速聚魂奖励
function NewLotteryModel:setquickJuHunReward(reward)
	self.quickJuHunReward = reward
	-- if  not reward then
	-- 	self.gatherSoulDataPos = {}
	-- end
end

function NewLotteryModel:getquickJuHunReward()
	return self.quickJuHunReward
end

function NewLotteryModel:getRewardEffect()
	local reward = NewLotteryModel:getquickJuHunReward()--是不是快速聚魂
	if reward then
		local finishPos = {}
		for i=1,5 do
			finishPos[i] = i
		end
		EventControler:dispatchEvent(NewLotteryEvent.ADD_JUHUN_EFFECT,{pos = finishPos ,reward = reward})
	end
	
end


--设置继续聚魂
function NewLotteryModel:setanyButton( value )
	self._isContinueQuickSole = value

end


function NewLotteryModel:getanyButton()
	return self._isContinueQuickSole
end


--播放聚魂动画
function NewLotteryModel:playjuhunAction(data)
	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	local alldata = NewLotteryModel:getGatherSoulData()
	local count = maxCount - table.length(alldata)  --剩余空位
	local serveTime = TimeControler:getServerTime()
	local reward = data.data.reward
	-- dump(data,"播放动画的数据返回=======")
	-- echo("======count=========",count)
	local newData = {}
	local newReward = {}
	for i=1,#reward do
		local rewardStr  = reward[i][1]..","..reward[i][2]..","..reward[i][3]
		table.insert(newReward,rewardStr)
	end
	if count ~= 0 then
		for i=1,count do
			if reward[i] then
				newData[i] = {
					finishTime = serveTime + 3600/2,
			        reward     = newReward[i]..","..newReward[i]..","..newReward[i],
			        time       = 2100,
				}
			end
		end
	end

	NewLotteryModel:setquickJuHunReward(newReward)
	return count,newData
end


function NewLotteryModel:showGatherSoulQuickCostView(pames,cellFunc)

	local pames = pames

	local maxCount = FuncNewLottery.getMaxCreateAllItem()
	local serveTime = TimeControler:getServerTime()
	local alldata = NewLotteryModel:getGatherSoulData()
	
	local data = {}
	local speedItemId = FuncNewLottery.getCostItemId()  
	local drawCarditemid = FuncNewLottery:getSeniorcardID()
	local speedNum =  NewLotteryModel:speedUpItremData()  --加速符数量
	local drawcardNum = NewLotteryModel:getseniorDrawcard()   ---聚魂灯
	local speedBuyItemData = FuncItem.getQuickBuyItemData( speedItemId )
	local drawCardbuyItemData = FuncItem.getQuickBuyItemData( drawCarditemid )
	local needGold = 0
	local finishCount = 0
	local count = maxCount - table.length(alldata)  --剩余空位
	local data = {}		
	if pames and pames == 4  then
		if count == 0 then

			local isAllfinish = NewLotteryModel:allherSoulDataIsFinish()
			-- echo("=====count======",count,isAllfinish)
			if isAllfinish then  --全部完成
				data = {
					needGold =  0,
					items = {
						{needNums = 0,hasNums = drawcardNum },
						{needNums = 0,hasNums = speedNum },
					}
				}
			else
				local datas = NewLotteryModel:getGatherSoulData()
				local num = 0
				for k,v in pairs(datas) do
					if v.finishTime <= TimeControler:getServerTime() then
						num = num + 1
					end
				end

				data = {
					needGold =  0,
					items = {
						{needNums = count,hasNums = drawcardNum },
						{needNums = maxCount - num ,hasNums = speedNum },
					}
				}

			end
		else
			data = {
				needGold =  0,
				items = {
					{needNums = count,hasNums = drawcardNum },
					{needNums = 5,hasNums = speedNum },
				}
			}

		end
		
	else
		local counts1 = 0
		local counts2 = 0
		if maxCount - drawcardNum < 0  then
			counts1 = 0
		else
			counts1 = drawCardbuyItemData.cost * (maxCount - drawcardNum)
		end
		if maxCount - speedNum < 0  then
			counts2 = 0
		else
			counts2 = speedBuyItemData.cost * (maxCount - speedNum)
		end
		if count > 0 and count <= maxCount then  ---聚魂和加速  5个空位

			if drawcardNum  >= maxCount then  --聚魂灯足够
				if speedNum >= maxCount then  --加速符足够
					pames = 1
					-- needGold = drawCardbuyItemData.cost * (maxCount - drawcardNum) +  speedBuyItemData.cost * (maxCount - speedNum)
					items = {
						{needNums = csount,hasNums = drawcardNum },
						{needNums = count,hasNums = speedNum },
					}
				else
					pames = 3
					-- needGold = drawCardbuyItemData.cost * (maxCount - drawcardNum) +  speedBuyItemData.cost * (maxCount - speedNum)
					items = {
						{needNums = maxCount,hasNums = speedNum },
						-- {needNums = maxCount,hasNums = speedNum },
					}
				end
			else                              --聚魂灯不够
				if speedNum >= maxCount then  --加速符足够
					pames = 2
					-- needGold = drawCardbuyItemData.cost * (maxCount - drawcardNum) +  speedBuyItemData.cost * (maxCount - speedNum)
					items = {
						{needNums = maxCount,hasNums = drawcardNum },
						-- {needNums = maxCount,hasNums = speedNum },
					}
				else
					pames = 1
					-- needGold = drawCardbuyItemData.cost * (maxCount - drawcardNum) +  speedBuyItemData.cost * (maxCount - speedNum)
					items = {
						{needNums = maxCount,hasNums = drawcardNum },
						{needNums = maxCount,hasNums = speedNum },
					}
				end
			end
			
			data = {
				needGold =  counts1 +  counts2 ,
				items = items,
			}

		elseif count == 0 then   --直接加速5个 

			local counts1 = 0
			local counts2 = 0
			if maxCount - drawcardNum < 0  then
				counts1 = 0
			else
				counts1 = drawCardbuyItemData.cost * (maxCount - drawcardNum)
			end
			if maxCount - speedNum < 0  then
				counts2 = 0
			else
				counts2 = speedBuyItemData.cost * (maxCount - speedNum)
			end

			-- if drawcardNum >= maxCount then
			if speedNum >= maxCount then  --加速符足够
				pames = 1
				needGold =  0
				data = {
					needGold =  needGold,
					items  = {
						{needNums = maxCount,hasNums = drawcardNum },
						{needNums = maxCount,hasNums = speedNum },
					},
				}
			else
				pames = 3
				data = {
					needGold =  counts2,
					items  = {
						{needNums = maxCount,hasNums = speedNum },
						-- {needNums = maxCount,hasNums = speedNum },
					},
				}
			end


			-- pames = 1
			-- needGold = counts1 +  counts2 
			-- data = {
			-- 	needGold =  counts1 +  counts2,
			-- 	items  = {
			-- 		{needNums = maxCount,hasNums = drawcardNum },
			-- 		{needNums = maxCount,hasNums = speedNum },
			-- 	},
			-- }
		end
	end
	
	return pames,data

end

return NewLotteryModel





















