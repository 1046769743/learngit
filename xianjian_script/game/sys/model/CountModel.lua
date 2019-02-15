--
-- Author: xd
-- Date: 2016-01-18 11:28:35
--

local CountModel = class("CountModel", BaseModel )
local PVP_CHANGE_ADD_COUNT_PER_TIME = 1 --每购买一次挑战，增加五次挑战机会

--[[

    "count"      = 1
    "expireTime" = 1454274000
    "id"         = "10"

]]

function CountModel:init(d)
	CountModel.super.init(self,d)
 
	self.countType = FuncCount.COUNT_TYPE
    --判断下时间是否过期  过期了 那么就恢复次数为0
    for i,v in pairs(self.countType) do

        d[v] = d[v] or {}
        self:checkExpireTime(d[v],v)
        --同时添加对应的事件 
        EventControler:addEventListener(i, self.pressTimeOut, self)
       
    end

end

--更新一个count
function CountModel:checkExpireTime( modelData,id )
    id = tostring(id)
    local expireTime = modelData.expireTime or 0
    modelData.id = modelData.id or id
    local serverTime = TimeControler:getServerTime()
    if serverTime >= expireTime then
        modelData.count = 0
    end

    local data = FuncCommon.getCountData( id )
    if data ~= nil then
        --开启下次刷新时间
        modelData.expireTime = TimeControler:countNextRefreshTime( data.m,data.h,data.w,data.j )
        table.deepMerge(self._data[id],modelData)
        local leftTime = modelData.expireTime -  serverTime

        local eventName 
        for k,v in pairs(self.countType) do
            if v == tostring(id) then
                eventName = k
                break
            end
        end
        if not eventName then
            echoError("这个countid没有配置到 FuncCount里去",id)
            return
        end
        --添加对应的侦听
        --echo(eventName,leftTime+1,"TimeControler:startOneCd")
        TimeControler:startOneCd(eventName,leftTime+1)
    end

end



--某种计数刷新时间到了----
function CountModel:pressTimeOut(e  )
    --需要刷新次数
    
    local v= self.countType[e.name]
    local modelData = {}
    local data = FuncCommon.getCountData( v )



    modelData.count = 0
    --开启下次刷新时间
    modelData.expireTime = TimeControler:countNextRefreshTime( data.m,data.h,data.w,data.j )
    local leftTime = modelData.expireTime - TimeControler:getServerTime()
    if leftTime < 0 then
        echoError("__为什么下次时间小于0")
    end
    --echo("刷新时间到了----",leftTime,modelData.id,e.name,"next刷新时间:",os.date("%m_%d_%H:%M",modelData.expireTime),TimeControler:getServerTime())
    --更新数据
    self:updateData({[v] = modelData},true)
    
    TimeControler:startOneCd(e.name,leftTime+1)

    
end




-- 通过type，获取counts二级属性
function CountModel:getCountByType(type)
    local countsTab = self._data
    if countsTab then
        local countTab = countsTab[tostring(type)]
        
        if not countTab  then
            -- echo("这个类型相关计时:",type)
            return 0
        end
        local expireTime = countTab.expireTime
        local serverTime = TimeControler:getTime()
        if not expireTime then
            echoError("为什么没有过期时间--")
            dump(countTab,"___countTab")
            expireTime = 0
        end
        if countTab and serverTime < expireTime then
            if not countTab.count  then
                echoError("type 没有 count")
            end
            return countTab.count
        end
    end
    return 0
end


--获取商店刷新次数
function CountModel:getShopRefresh(shopId)
    shopId = tostring(shopId)
    if shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_1 then
        return self:getCountByType(self.countType.COUNT_TYPE_JUNIOR_SHOP_FLUSH_TIMES) -- 低级普通商店
    elseif shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_2 then
        return self:getCountByType(self.countType.COUNT_TYPE_MEDIUM_SHOP_FLUSH_TIMES) -- 中级普通商店
        --废弃
	-- elseif shopId == FuncShop.SHOP_TYPES.NORMAL_SHOP_3 then
 --        return self:getCountByType(self.countType.COUNT_TYPE_SENIOR_SHOP_FLUSH_TIMES) -- 高级普通商店
	elseif shopId == FuncShop.SHOP_TYPES.PVP_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_PVP_SHOP_REFRESH_TIMES) -- 竞技场商店
	elseif shopId == FuncShop.SHOP_TYPES.CHAR_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_CHAR_SHOP_REFRESH_TIMES) -- 侠义值商店
    elseif shopId == FuncShop.SHOP_TYPES.LOTTER_PARTNER_SHOP then
        return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES) -- 三皇替换商店
    elseif shopId == FuncShop.SHOP_TYPES.ARTIFACT_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_ARTIFACt_SHOP_TIMES) -- 神器商店
    elseif shopId == FuncShop.SHOP_TYPES.TOWER_SHOP then
		return self:getCountByType(self.countType.COUNT_TYPE_TOWERSHOP_DAY_TIMES) -- 锁妖塔商店
    elseif shopId == FuncShop.SHOP_TYPES.WONDER_SHOP then
        return self:getCountByType(self.countType.COUNT_TYPE_WONDERSHOP_DAY_TIMES) -- 须臾商店
    elseif shopId == FuncShop.SHOP_TYPES.MALL_XINANDANG then
        return CountModel:getMallXinAnDangNum()	                           -- 月卡商城
    end
end


-- 获得体力当前购买次数
function CountModel:getSpBuyCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_SP)
    if buyCount == nil then
        return 0
    end
    return buyCount
end
--//获取铜钱购买次数
function  CountModel:getCoinBuyTimes()
    local  _buy_count=self:getCountByType(self.countType.COUNT_TYPE_USER_BUY_COIN_TIMES);
    if( _buy_count==nil)then
        return  0;
    end
    return    _buy_count;
end

-- 获取每周领取声望奖励次数
function CountModel:getMagicEventFinishCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_GET_RENOWM_TIMES)
    return buyCount
end

-- 获得PVP购买次数    
function CountModel:getPVPBuyCount()
    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)
    return buyCount/PVP_CHANGE_ADD_COUNT_PER_TIME
end

--获得购买过的pvp 挑战次数
function CountModel:getPVPBuyChallengeCount()
    return self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)
end

function CountModel:getPVPChallengeCount()
	local count = self:getCountByType(self.countType.COUNT_TYPE_PVPCHALLENGE)
	return count
end
--获取爬塔剩余扫荡重置次数
function CountModel:getTowerResetCount()
    return self:getCountByType(self.countType.COUNT_TYPE_TOWER_RESET)
end

-- 判断能否购买竞技场挑战次数
--目前已经和VIP的关系脱离了
function CountModel:canBuyPVPSn()
 --   local vipLevel = UserModel:vip()
--    local maxBuyTimes = FuncCommon.getVipPropByKey(vipLevel,"buySn")

--    local buyCount = self:getCountByType(self.countType.COUNT_TYPE_BUY_PVP)

--    if tonumber(buyCount/PVP_CHANGE_ADD_COUNT_PER_TIME) >= tonumber(maxBuyTimes) then
--        return false
--    end
 --   return vipLevel>=3;
 return true
end
--//判断最大铜钱可以购买的次数
function CountModel:getMaxCoinBuyTimes()
	local _vip_level = UserModel:vip()
	return FuncCommon.getVipPropByKey(_vip_level, "buyGoldLimit")
end

--更新事件
function CountModel:updateData ( data, isCountBack )
	CountModel.super.updateData(self,data)

   
    
    for k,v in pairs(data) do
         --如果是服务器同步数据回来 比如跨天了 或者其他情况 需要重置过期时间
        if not isCountBack and v.expireTime then                                               
            self:checkExpireTime(v,k)
        end

        if k == self.countType["COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES"] then
            EventControler:dispatchEvent(NewLotteryEvent.ONTIME_REFRESH_SHOP_VIEW)
        end
        
        if k == self.countType["COUNT_TYPE_SHAREBOSS_CHALLENGE"] then
            EventControler:dispatchEvent(ShareBossEvent.SHAREBOSS_CHALLENGE_RESET)
        end
    end
    
	EventControler:dispatchEvent(CountEvent.COUNTEVENT_MODEL_UPDATE,data)
end


function CountModel:getTrialCountTime(kind)
    return self:getCountByType(self.countType["COUNT_TYPE_TRIAL_TYPE_TIMES_" .. tostring(kind)]);
end

function CountModel:getHonorCountTime()
    return self:getCountByType(self.countType.COUNT_TYPE_HONOR_COUNT);
end
function CountModel:getDefenderCountTime()
    -- return self:getCountByType(self.countType.COUNT_TYPE_DEFENDER_COUNT);
    return 0
end
--获取伙伴技能点购买次数
function CountModel:getPartnerSkillPointTime()
    return self:getCountByType(self.countType.COUNT_TYPE_PARTNER_SKILL_POINT_TIMES)
end

--获取免费抽奖次数
function CountModel:getLotteryfreeCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_FREE_TIMES);
end
--获取元宝免费抽奖次数
function CountModel:getLotteryGoldFreeCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_GOLD_FREE_TIMES);
end
--获取元宝付费单抽抽奖次数
function CountModel:getLotteryGoldPayCount()
   return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_GOLD_FAY_TIMES);
end
--获得铜钱刷新次数
function CountModel:getLotterymanyrefreshCount()
    return self:getCountByType(self.countType.COUNT_TYPE_NEWLOTTERY_MANY_REFRESH_TIMES);
end


--神器当天免费的次数
function CountModel:getArtifactCount()
    return self:getCountByType(self.countType.COUNT_TYPE_ARTIFACt_TIMES);
end
--当天神器的次数
function CountModel:getArtifactDayCount()
    return self:getCountByType(self.countType.COUNT_TYPE_ARTIFACt_DAY_TIMES);
end

--获取神器快捷购买次数
function CountModel:getArtifactQuickBuyTimes(  )
    return self:getCountByType(self.countType.COUNT_TYPE_ARTIFACT_QUICK_TIMES);
end


--获取当天公会签到次数
function CountModel:getGuildSignCount()
    return self:getCountByType(self.countType.COUNT_GUILD_SIGN);
end

--获取公会红利1
function CountModel:getGuildbonusOneCount()
    local count = self:getCountByType(self.countType.COUNT_GUILD_EVERYDAY_REWARD_ONE);
    -- dump(count,"==============每日公会红利次数表现==============")
    return count
end
--获取公会红利2
-- function CountModel:getGuildbonusTowCount()
--     return self:getCountByType(self.countType.COUNT_GUILD_EVERYDAY_REWARD_TWO);
-- end
-- --获取公会红利3
-- function CountModel:getGuildbonusThreeCount()
--     return self:getCountByType(self.countType.COUNT_GUILD_EVERYDAY_REWARD_THREE);
-- end

--获取祈福宝箱1
function CountModel:getGuildPrayReOneCount()
    local count = self:getCountByType(self.countType.COUNT_GUILD_PRAY_REWARD_ONE);
    -- dump(count,"==============每日公会祈福宝/箱2==============")
    return count
end
--获取祈福宝箱2
-- function CountModel:getGuildPrayReTowCount()
--     return self:getCountByType(self.countType.COUNT_GUILD_PRAY_REWARD_TWO);
-- end
-- --获取祈福宝箱3
-- function CountModel:getGuildPrayReThreeCount()
--     return self:getCountByType(self.countType.COUNT_GUILD_PRAY_REWARD_THREE);
-- end
--获取祈福次数
function CountModel:getGuildPrayCount()
    return self:getCountByType(self.countType.COUNT_GUILD_PRAY_REWARD);
end

--获取捐献次数
function CountModel:getGuildDonationCount()
    return self:getCountByType(self.countType.COUNT_DONATION_COUNT);
end

---获取公会每天踢人次数
function CountModel:getGuildCountPeople()
    return self:getCountByType(self.countType.COUNT_TYPE_LEADER_KICK);
end


-- 共享副本挑战次数
function CountModel:getShareBossChallengeCount()
    return self:getCountByType(self.countType.COUNT_TYPE_SHAREBOSS_CHALLENGE);
end

--获得侠义值资源
function CountModel:getLimitNum()
    echoError("----11")
    return  0
    --废弃-
   -- return self:getCountByType(self.countType.COUNT_TYPE_TRIAL_LIMIT_NUM);
end

--获得须臾仙境火魔兽次数
function CountModel:getWonderLandFireNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_FIRE_NUM);
end

--获得山神
function CountModel:getLimitSSNum()
   return self:getCountByType(self.countType.COUNT_TYPE_TRIAL_TYPE_TIMES_1);
end
--获得火神
function CountModel:getLimitHSSum()
   return self:getCountByType(self.countType.COUNT_TYPE_TRIAL_TYPE_TIMES_2);
end
--获得盗宝贼
function CountModel:getTrialDBNum()
   return self:getCountByType(self.countType.COUNT_TYPE_TRIAL_TYPE_TIMES_3);
end


--获得须臾仙境水魔兽次数
function CountModel:getWonderLandWriterNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_WRTER_NUM);
end

--获得须臾仙境风魔兽次数  五灵风
function CountModel:getWonderLandWindNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_WIND_NUM);
end





-- 五灵雷
function CountModel:getWonderLandRayWindNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_RAY_NUM);
end

-- 五灵水
function CountModel:getWonderLandWaterNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_WRTER_A_NUM);
end

-- 五灵活
function CountModel:getWonderLandLiveNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_LIVE_NUM);
end

-- 五灵土
function CountModel:getWonderLandSoilNum()
   return self:getCountByType(self.countType.COUNT_TYPE_WONDERLAND_SOIL_NUM);
end



-- 须臾的第8种类
function CountModel:getWonderLandEightNum()
   return self:getCountByType(self.countType.COUNT_TYPE_GAMBLE_COUNT);
end

-- 须臾的第9种类
function CountModel:getWonderLandWomanNum()
   return self:getCountByType(self.countType.COUNT_TYPE_GAMBLE_CHANGE_FATE_COUNT);
end




--每日巅峰竞技场购买次数
function CountModel:getCrossBuyNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_BUY_NUM);
end
--每日巅峰竞技场挑战次数
function CountModel:getCrossZhanNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_ZHAN_NUM);
end
--每日巅峰竞技场胜利次数
function CountModel:getCrossWinNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_WIN_NUM);
end
--当日击杀奇侠数量
function CountModel:getCrossKillPartnerNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_KILLPARTNER_NUM);
end
--当日巅峰竞技场主界面宝箱领取数量
function CountModel:getCrossGetBoxNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_GETBOX_NUM);
end
--当日巅峰竞技场小任务刷新次数
function CountModel:getCrosTaskRefreshNum()
   return self:getCountByType(self.countType.COUNT_TYPE_CROSS_TASKREFRESH_NUM);
end


-- 每日仙灵委托任务完成次数
function CountModel:getDeleagteNum( )
   return self:getCountByType(self.countType.COUNT_TYPE_DELEGATE_SPECIAL_TASK_REFRESH_TIMES);
end

--每日体力领取的状态
function CountModel:getTiLiNum()
   return self:getCountByType(self.countType.COUNT_TYPE_GET_TILI);
end

function CountModel:getTiLiNum()
   return self:getCountByType(self.countType.COUNT_TYPE_GET_TILI);
end

--无底深渊挑战次数
function CountModel:getEndlessChallengeCount()
    return self:getCountByType(self.countType.COUNT_TYPE_ENDLESS_TIMES);
end

--购买无底深渊挑战的次数
function CountModel:getBuyEndlessCount()
    return self:getCountByType(self.countType.COUNT_TYPE_BUY_ENDLESS);
end

--每日抢红包次数
function CountModel:getRedPacketNum()
   return self:getCountByType(self.countType.COUNT_TYPE_RED_PACKET_TIMES);
end

-- 获取每日委托可做次数
function CountModel:getDelegateCont( )
    return self:getCountByType(self.countType.COUNT_TYPE_DELEGATE_TASK_REFRESH_TIMES)
end

-- 获取每日聊天购买次数
function CountModel:getTlakItems( )
    return self:getCountByType(self.countType.COUNT_TYPE_CHAT_BUY_ITEMS)
end

-- 月卡
function CountModel:getCardMonthNum( mcId )
    local num = 0
    if tonumber(mcId) == 1 then
        num = self:getCountByType(self.countType.COUNT_TYPE_GET_MONTHCARD_74_TIMES);
    elseif tonumber(mcId) == 2 then
        num = self:getCountByType(self.countType.COUNT_TYPE_GET_MONTHCARD_75_TIMES);
    elseif tonumber(mcId) == 3 then
        num = self:getCountByType(self.countType.COUNT_TYPE_GET_MONTHCARD_76_TIMES);
    end
    return num
end

function CountModel:getMallXinAnDangNum()
    return self:getCountByType(self.countType.COUNT_TYPE_MALL_XINANDANG_77_TIMES);
end

--完成仙盟任务的次数
function CountModel:getFinishGuildTaskNum()
    return self:getCountByType(self.countType.COUNT_TYPE_FINISH_GUILD_TIMES);
end

--仙盟任务消费体力的数量
function CountModel:getGuildTaskCostSPNum()
    return self:getCountByType(self.countType.COUNT_TYPE_EVERYDAY_SPEND_SP_TIMSE);
end


--仙盟任务的组队的次数
function CountModel:getGuildTaskTeamNum()
    return self:getCountByType(self.countType.COUNT_TYPE_GUILD_TEAM_TIMSE);
end

--幸运转盘免费
function CountModel:getLuckyGuyFreeTimes()
    return self:getCountByType(self.countType.COUNT_TYPE_LUCKYGUY_FREETIMES)
end

--六界游商每日购买次数
function CountModel:getTravelShopNum()
    -- return self:getCountByType(tostring(FuncTravelShop.getRechargeForCountId()))
    return self:getCountByType(self.countType.COUNT_TYPE_TRAVELSHOP_EVERYDAY_TIME);
end

--六界游商抽折扣次数
function CountModel:getTravelShopTakeNum()
    return self:getCountByType(self.countType.COUNT_TYPE_TRAVEL_SHOP_TIMES)
end

function CountModel:getBuyCountCost( countId,buyNums )
    local currentNums = self:getCountByType(countId)
    local cfgs = FuncCount.getBuyCountCostData(countId  )
    local length = table.length(cfgs)
    local maxCost = cfgs[tostring(length)].price

    --判断超出多少
    local overNums =  (currentNums + buyNums) - length 
    local overCost =0
    local addCost = 0
    if overNums > 0 then
        if overNums > buyNums then
            overNums = buyNums
        end
        overCost = overNums * maxCost
        buyNums = buyNums - overNums
    end

    for i=currentNums+1,currentNums + buyNums  do
        addCost = addCost + cfgs[tostring(i)].price
    end
    return overCost + addCost

end 
--获取能够购买的最大次数
function CountModel:getCanBuyMaxCount( countId )
    local currentNums = self:getCountByType(countId)
    local currentCost= 0
    local buyCount = 0
    local cfgs = FuncCount.getBuyCountCostData(countId  )
    local mapCfgs = FuncCount.getCountCostMapData( countId )

    local length = table.length(cfgs) 
   
    local info = cfgs[tostring(length)]
    local maxCost = info.price
    local _,resNums = UserModel:getResInfo( mapCfgs.costResId )
    
    while true do 
        buyCount = buyCount + 1
        local price
        if buyCount + currentNums > length then
            price = maxCost
        else
            price= cfgs[tostring(buyCount)].price
        end
        if currentCost + price > resNums then
            buyCount = buyCount - 1
            break
        end
        currentCost = currentCost + price
    end
    --返回最大购买次数以及需要消耗的次数
    return buyCount,currentCost

end

--获取直购礼包购买次数
function CountModel:getPurchaseGiftBagNumById(_id)
    if tostring(_id) == "package_101" then
        return self:getCountByType(self.countType.COUNT_TYPE_RECHARGE_PURCHASE_1001_TIMES)
    elseif tostring(_id) == "package_102" then
        return self:getCountByType(self.countType.COUNT_TYPE_RECHARGE_PURCHASE_1003_TIMES)
    end 
end

return CountModel
