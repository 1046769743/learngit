--
--Author:      
--DateTime:    
--Description: 
--

--
--Author:      zhuguangyuan
--DateTime:    2018-06-06 17:33:26
--Description: 维护 六界游商开发
--


local ActConditionModel = class("ActConditionModel", BaseModel)


ActConditionModel.recordName_merchantData = "__wander_merchant_records_name_" -- 记录游商的数据
ActConditionModel.cdName_wander_merchant_trigger = "wander_merchant_trigger"   -- 延迟几秒 检测本次登录是否触发游商
ActConditionModel.cdName_wander_merchant_countdown = "cdName_wander_merchant_countdown"   -- 一个已经触发的游商的倒计时
ActConditionModel.delayTime__wander_merchant_trigger = 3

-- 需要客户端作统计的taskId 
ActConditionModel.specialHandleConditionIdMap = {
    "202","203",
    -- "72003","72004","72005",   --- 小额充值
    -- "80001","80002","80003","80004","80005",   --- 小额充值
    -- "73001","73002","73003","73004","73005","73006","73007", -- 六界游商,单笔充值203
    -- "78001","78002","78003","78004","78005","78006","78007", -- 单笔充值,单笔充值203
}

-- 需做特殊处理的活动 单笔充值活动id
ActConditionModel.specialMap = {"159", "160", "161", "162", "163", "164", "165"}


function ActConditionModel:init(d)
    if FuncActivity.isDebug then
        dump(d,'==dmx==ActConditionModel:init==dmx==')
    end

    --  local _params = {}
    -- ActConditionModel:saveWanderMerchantRobData( _params )

    ActConditionModel.super.init(self, d)
    self:registerEvent()
end

function ActConditionModel:updateData(d)
    ActConditionModel.super.updateData(self, d)
    if FuncActivity.isDebug then
        dump(d,"---------活动次数 变化-------",5)
    end
    EventControler:dispatchEvent(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT)
end

function ActConditionModel:registerEvent()
    -- EventControler:addEventListener(ActivityEvent.ACTEVENT_CONDITION_NUMCHANGE_EVENT,self.checkWanderMerchantRedAndFinished,self)
    -- 登录游戏不久后判断是否触发游商
    -- TimeControler:startOneCd(ActConditionModel.cdName_wander_merchant_trigger,ActConditionModel.delayTime__wander_merchant_trigger)
    -- EventControler:addEventListener(ActConditionModel.cdName_wander_merchant_trigger, self.checkIfTriggerWanderMerchant, self)
    -- 完成活动或者时间到期都需要关闭游商界面
    -- EventControler:addEventListener(ActConditionModel.cdName_wander_merchant_countdown, self.merchantTimeout, self)
    EventControler:addEventListener(ActivityEvent.ACTEVENT_FINISH_TASK_OK, self.goodsHasSoldOut, self)
    -- 跨天时要判断是否触发游商
    EventControler:addEventListener(TimeEvent.TIMEEVENT_HAS_OVER_DAY,self.oneDayPass,self)

    EventControler:addEventListener(CountEvent.COUNTEVENT_MODEL_UPDATE, self.refreshBtn, self)
end

function ActConditionModel:refreshBtn()
    local dailyBuyTimes = CountModel:getTravelShopNum()
    if dailyBuyTimes == 1 then
        EventControler:dispatchEvent(ActivityEvent.TRAVELSHOP_REFRESH_BUYBTN_STATUS)
    end
end

-- 一天过期 关闭已有游商 再次检测是否有新游商
function ActConditionModel:oneDayPass()
    self.curActData = nil
    self.targetTaskId = nil
    EventControler:dispatchEvent(ActivityEvent.TRRIGER_WANDER_MERCHANT)
    self:checkIfHasWanderMerchant()
end

function ActConditionModel:goodsHasSoldOut(event)
    local finishData = event.params
    dump(finishData, "finishData", nesting)
    local onlineId = finishData.onlineId
    local tastId = finishData.taskId
    if self.curActData and onlineId == self.curActData:getOnlineId() then
        local mercenaryData = self:getWanderMerchantRobData()
        local bornTime = CarnivalModel:getBornTime()
        echo("_________ bornTime ",bornTime)
        local age = TimeControler:getServerTime() - bornTime
        local maxOpenDate = math.floor(age/(24*3600)) + 1
        mercenaryData[tonumber(maxOpenDate)].hasBought = true 
        mercenaryData[tonumber(maxOpenDate)].satisfyCondition = true 
        dump(mercenaryData, "==== 领取奖励后mercenaryData", nesting)
        self:saveWanderMerchantRobData( mercenaryData )   
        -- 关闭今天的游商
        self.curActData = nil
        self.targetTaskId = nil
        EventControler:dispatchEvent(ActivityEvent.TRRIGER_WANDER_MERCHANT)  
    end
end

-- 活动数据发生变化的时候,检查是否达到游商领取条件
-- 若达到则发送主城红点
function ActConditionModel:checkWanderMerchantRedAndFinished()
    if not self:checkIfHasWanderMerchant() then
        return 
    end
    local isConditionOk = self:checkMerchantConditionOk()
    if isConditionOk then
        EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
            {redPointType = HomeModel.REDPOINT.ACTCONDITION, isShow = true})

        -- 完成了六界游商的充值条件,则也记录已达到要求,第二天继续触发
        if self.curActData then --and 
            local mercenaryData = self.wanderMerchantData -- self:getWanderMerchantRobData()
            local bornTime = CarnivalModel:getBornTime()
            echo("_________ bornTime ",bornTime)
            local age = TimeControler:getServerTime() - bornTime
            local maxOpenDate = math.floor(age/(24*3600)) + 1
            if mercenaryData[tonumber(maxOpenDate)] then
                mercenaryData[tonumber(maxOpenDate)].satisfyCondition = true 
            else
                mercenaryData[tonumber(maxOpenDate)] = {
                    taskId = "73001",
                    expireTime = TimeControler:getServerTime() + (24*3600),
                    hasBought = false,  -- 达到条件且领取了奖励则为true
                    satisfyCondition = true, 
                }
            end
            dump(mercenaryData, "==== 满足条件后mercenaryData", nesting)
            self:saveWanderMerchantRobData( mercenaryData )   
        end
    end
end

-- 获取六界游商是否完成
function ActConditionModel:checkMerchantConditionOk()
    if not self.curActData then
        return false
    end
    local onlineId = self.curActData:getOnlineId()
    local actInfo = self.curActData:getActInfo()
    local actType = self.curActData:getActType()
    local isConditionOk = ActConditionModel:isTaskConditionOk(onlineId, self.targetTaskId, actType)
    if isConditionOk then
        return true
    else
        return false
    end
end

-- 检测是否激发六界游商
function ActConditionModel:checkIfTriggerWanderMerchant()
    self.curActData,self.targetTaskId = nil,nil
    local targetTaskId = nil
    local isActOpen = false -- 六界游商活动是否开启
    local allActs = FuncActivity.getOnlineActs()
    dump(allActs, "allActs ====================== ")
            
    -- 今天是创角第几天
    local bornTime = CarnivalModel:getBornTime()
    -- echo("_________ bornTime ",bornTime)
    local age = TimeControler:getServerTime() - bornTime
    local maxOpenDate = math.floor(age/(24*3600)) + 1
    echo("_____ 今天是创角第几天 ______ ",maxOpenDate)

    for k,oneAct in pairs(allActs) do
        local actId = oneAct:getActId()

        -- 正处于活动开启期间,可能有六界游商
        if tostring(actId) == "91" then
            isActOpen = true
            echo("_\n\n\n 六界游商活动开启! ")
            local actInfo = oneAct:getActInfo()
            -- dump(actInfo, "actInfo", nesting)

            -- 读取本地数据,判断是否有正在卖货的游商
            local mercenaryData = self:getWanderMerchantRobData()
            dump(mercenaryData, "mercenaryData=========", nesting)

            -- 今天有正在卖商品的游商
            local leftTime = nil
            if mercenaryData[tonumber(maxOpenDate)] then
                local todayMerchantData = mercenaryData[tonumber(maxOpenDate)] 
                if todayMerchantData.hasBought then 
                    return
                end
                -- leftTime = todayMerchantData.expireTime - TimeControler:getServerTime() 
                -- if leftTime <=0 then
                --     return
                -- end
                targetTaskId = todayMerchantData.taskId
                -- 开启过期定时器,六界主城监听此事件,到期隐藏游商图标
                TimeControler:startOneCd(ActConditionModel.cdName_wander_merchant_countdown,leftTime)
            else
                -- 获取随机所需数据
                local targetData = nil
                local onlineId = oneAct:getOnlineId()
                local finishedChargedData = ActConditionModel:getChargeDateData(onlineId) 
                dump(finishedChargedData, "==== 每日充值数量 finishedChargedData", nesting)

                local todayChargeNum = 0 --finishedChargedData[maxOpenDate] or 0 
                for k,v in pairs(finishedChargedData) do
                    todayChargeNum = todayChargeNum + tonumber(v)
                end

                echo("____ 历史充值数量 todayChargeNum________",todayChargeNum)
                local configData = FuncActivity.getTravelerRandomDataByBornDate(maxOpenDate)
                -- for k,v in pairs(configData) do
                --     if todayChargeNum >= v.lowerLimit and todayChargeNum <= v.upperLimit then
                --         targetData = table.deepCopy(v)
                --         break
                --     end
                -- end
                targetData = table.deepCopy(configData["1"])  --固定写死，后期修改——wk
                dump(targetData, "根据历史充值获取 随机数据 targetData", nesting)

                -- 根据概率计算是否出现游商
                -- 如果本次活动的前几天都没触发过.今天是最后一天,且充值没有超过最高值时,则今天首次登录必定触发
                local hitProbability = targetData.probability
                local actLeftTime = oneAct:getDisplayLeftTime()
                if targetData and (tonumber(actLeftTime) < (3600*24)) and (table.length(mercenaryData) == 0)then
                    hitProbability = 10000
                end
                local missProbability = 10000 - hitProbability
                echo("_______触发概率 hitProbability,missProbability ________",hitProbability,missProbability)
                local resultArr = RandomControl.getIndexGroupByGroup({tostring(hitProbability/10000),tostring(missProbability/10000)},1)
                dump(resultArr, "resultArr", nesting)
                for k,v in pairs(resultArr) do
                    if tostring(v) == "1" then
                        targetTaskId = tostring(targetData.activityTaskId)
                        break
                    end
                end
                echo(")___________ targetTaskId ",targetTaskId)
                if targetTaskId then 
                    -- 开启过期定时器,六界主城监听此事件,到期隐藏游商图标
                    leftTime = targetData.duration * 3600 
                    TimeControler:startOneCd(ActConditionModel.cdName_wander_merchant_countdown,leftTime)
                    -- 将数据保存本地
                    mercenaryData = {
                        [tonumber(maxOpenDate)] = {
                            taskId = targetTaskId,
                            expireTime = TimeControler:getServerTime() + targetData.duration * 3600,
                            hasBought = false,  -- 达到条件且领取了奖励则为true
                            satisfyCondition = false, -- 用于判断达到条件却没领奖励,下一次还要触发的情况
                        }
                    }
                    self:saveWanderMerchantRobData( mercenaryData )
                end
            end
            if targetTaskId then
                echo("\n\n\n\n\n\n\n\n\n ================  触发六界游商")
                -- 全局变量 点游商图标用到
                self.curActData = oneAct
                if FuncActivity.isDebug then
                    dump(oneAct, "触发的act oneAct", nesting)
                end
                self.targetTaskId = targetTaskId

                --dump(self.curActData,"333333333333333")
                EventControler:dispatchEvent(ActivityEvent.TRRIGER_WANDER_MERCHANT)
                self:checkWanderMerchantRedAndFinished()
            end
            -- 找到目标活动则终止for循环
            break
        end
    end

    -- 活动未开启则置空本地数据
    if not isActOpen then
        echo("__________ 游商活动未开启")
        local _params = {}
        ActConditionModel:saveWanderMerchantRobData( _params )
    end
end

-- 六界游商活动过期
function ActConditionModel:merchantTimeout()
    TimeControler:removeOneCd(ActConditionModel.cdName_wander_merchant_countdown)
    self.curActData = nil
    self.targetTaskId = nil

    -- local _params = {}
    -- ActConditionModel:saveWanderMerchantRobData( _params )
    EventControler:dispatchEvent(ActivityEvent.TRRIGER_WANDER_MERCHANT)
end

--获取六界游商是否存在
function ActConditionModel:checkIfHasWanderMerchant()

    local reward,startTime = FuncTravelShop.getSystemHide()
    if startTime ~= 0 then
        return true
    else
        return false
    end
end

-- 六界主城点击游商图标 
function ActConditionModel:openWanderMerchantView()
    local reward,startTime = FuncTravelShop.getSystemHide()
    if startTime ~= 0 then
        WindowControler:showWindow("WanderMerchantMainView")--self.targetTaskId)
    else
        WindowControler:showTips("活动结束")
    end
end

-- 游商结束时间
function ActConditionModel:getTravelShopEndTime()
    local tmp,startTime,endTime = FuncTravelShop.getSystemHide()
    local time = endTime - TimeControler:getServerTime()
    if time <= 0 then
        time = 0
    end
    return time
end

-- 抽折扣接口
function ActConditionModel:travelTakeDiscount( id )
    local function _callback(event)
        if event.result then
            dump(event.result,"=============抽折扣数据返回==============")
            EventControler:dispatchEvent(ActivityEvent.TRAVELSHOP_PLAY_ANIMATION_EVENT)
            
        end

        
    end
    local params = {
            id = id
        }
    ActivityServer:travelShopTakeDiscount(params, _callback)
end

--是否还可以抽折扣
function ActConditionModel:countIsOk()
    local count = CountModel:getTravelShopTakeNum()
    local maxcount =  FuncTravelShop.getMaxTakeDiscount()

    if count >= maxcount then
        return false
    end
    return true
end

function ActConditionModel:saveWanderMerchantRobData( _params )
    self.wanderMerchantData = _params
    if (not LSChat:byNameGetTable(ActConditionModel.recordName_merchantData)) then
        LSChat:createTable(ActConditionModel.recordName_merchantData)
    end
    dump(_params, "==== 存六界游商信息", 5)
    if _params then
        local new_params = {}
        for k,v in pairs(_params) do
            v.id  = k
            table.insert(new_params,v)
        end
        _params = json.encode( new_params ) 
        LSChat:setData(ActConditionModel.recordName_merchantData,"_params",_params)
    end
end  

-- 
function ActConditionModel:getWanderMerchantRobData()
    -- if not self.wanderMerchantData then
        local listtable = LSChat:byNameGetTable(ActConditionModel.recordName_merchantData)
        if listtable ~= nil then
            local list = LSChat:getData(ActConditionModel.recordName_merchantData,"_params")
            if tostring(list) ~= "nil" then
                dump(list, "==== 取六界游商信息", 5)
                local arr = json.decode( list )
                self.wanderMerchantData = {}
                if arr then
                    for k,v in pairs(arr) do
                        if v and v.id ~= nil then
                            self.wanderMerchantData[v.id] = v
                        end
                    end
                end
            end
        end


    -- end
    dump(self.wanderMerchantData, " 获取 六界游商触发及 的数据 self.wanderMerchantData ")
    return self.wanderMerchantData or {}
end  

--scheduleId, taskId, 活动类型(兑换/领取) 是不是完成了
--======
-- 增加参数 finishTimes ,检查完成次数是否满足.这个目前只用在单笔充值里
-- 单笔充值里的每一个任务可以完成多次,所以传入检测次数看是否满足
--======
function ActConditionModel:isTaskConditionOk(onlineId, taskId, actType,finishTimes)

    local conditionId = FuncActivity.getTaskConditionId(taskId)
    if not FuncActivity.checkTaskCanDoByLevel(taskId) then
        return false
    end

    local key = string.format("%s_%s", onlineId, conditionId)
    -- if table.isValueIn(ActConditionModel.specialHandleConditionIdMap,tostring(conditionId)) then
    --     echo("\n________ onlineId, taskId, actType ",onlineId, taskId, actType)
    -- end

    if actType == FuncActivity.ACT_TYPE.EXCHANGE then  --兑换类
        local conditionParam = FuncActivity.getTaskConditionParam(taskId)
        for _, res in pairs(conditionParam) do
            local needNum,hasNum,isEnough,resType,resId = UserModel:getResInfo(res)
            if not isEnough then
                return false
            end
        end
        return true
    elseif actType == FuncActivity.ACT_TYPE.TASK then  --完成任务领取类的(追溯、非追溯)
        local currentCondition = self:getConditionByKey(key)
        local configConditionNum = FuncActivity.getTaskConditionNum(taskId)
        local dataIsTrace = FuncActivity.isTaskDataTrace(taskId)
        local conditionParam = FuncActivity.getTaskConditionParam(taskId)

        if dataIsTrace or table.isValueIn(ActConditionModel.specialHandleConditionIdMap,tostring(conditionId)) then
            --追溯类的，单独处理
            local conditionId = FuncActivity.getTaskConditionId(taskId)
            local handleFuncKey = FuncActivity.TRACE_TASK_FUNCS[tonumber(conditionId)]
            local funcKey = nil

            if handleFuncKey then
                funcKey = string.format("%sConditionOk", handleFuncKey)
            end

            if handleFuncKey and self[funcKey] then
                local func = self[funcKey]
                local isOk = func(self, configConditionNum, conditionParam,onlineId,finishTimes)
                -- echo("\n\ntaskId====", taskId, "isOk=====", isOk)
                return isOk
            end
        else
            --非追溯的读取服务器的进度
            if tonumber(configConditionNum) <= currentCondition then
                return true
            else
                return false
            end
        end
    end
    return false
end

--每一项的结构是：
--scheduleId
--conditionId
--count
--params
--expireTime
function ActConditionModel:getConditionByKey(key)
    local data = self._data[key]
    if not data then return 0 end
    local num = data.count or 0
    if data.scheduleId ~= 150  and data.expireTime then
        if data.expireTime < TimeControler:getServerTime() then
            num = 0
        end
    end
    return num
end

--只针对领取类任务的
function ActConditionModel:getTaskConditionProgress(onlineId, taskId)
    local conditionId = FuncActivity.getTaskConditionId(taskId)
    local key = string.format("%s_%s", onlineId, conditionId)
    local dataIsTrace = FuncActivity.isTaskDataTrace(taskId)
    local configConditionNum = FuncActivity.getTaskConditionNum(taskId)
    local conditionParam = FuncActivity.getTaskConditionParam(taskId)

    local count = 0
    if dataIsTrace then --追溯类的，单独处理
        local conditionId = FuncActivity.getTaskConditionId(taskId)
        local handleFuncKey = FuncActivity.TRACE_TASK_FUNCS[tonumber(conditionId)]
        local funcKey = nil
        if handleFuncKey then
            funcKey = string.format("%sCurrentConditionNum", handleFuncKey)
        end

        if handleFuncKey and self[funcKey] then
            local func = self[funcKey]
            count = func(self, configConditionNum, conditionParam)
        end
    else --非追溯的读取服务器的进度
        count = self:getConditionByKey(key)
    end
    return count, configConditionNum
end

--玩家等级
function ActConditionModel:userLevelCurrentConditionNum()
    return UserModel:level()
end

function ActConditionModel:userLevelConditionOk(conditionNum)
    local current = self:userLevelCurrentConditionNum()
    if current >= tonumber(conditionNum) then
        return true
    end
    return false
end

--法宝最高等级
function ActConditionModel:treasureMaxLevelCurrentConditionNum()
    return 1 -- 有这个 要求再跟张强 提
end
-- 锁妖塔的层数
function ActConditionModel:towerFloorConditionOk(conditionNum)
    local current = UserModel:getTowerFloor() or 0
    if tonumber(current) >= tonumber(conditionNum) then
        return true
    end
    return false
end
-- 
function ActConditionModel:towerFloorCurrentConditionNum(conditionNum)
    local current = UserModel:getTowerFloor() or 0
    return current
end
-- 主线副本
function ActConditionModel:mainLineConditionOk(raidId)
    local current = UserExtModel:getMainStageId()
    if tonumber(current) >= tonumber(raidId) then
        return true
    end
    return false
end
-- 参加过仙界对决
function ActConditionModel:hasCrosspeakConditionOk()
    if CrossPeakModel:checkedDuijue( ) then
        return true
    end
    return false
end

--竞技场排行
function ActConditionModel:pvpRankConditionOk(conditionNum)
    local current = self:pvpRankCurrentConditionNum()
    if tonumber(current) <= tonumber(conditionNum) then
        return true
    end
    return false
end
function ActConditionModel:pvpRankCurrentConditionNum()
    local isOpen = FuncCommon.isSystemOpen("pvp")
    if not isOpen then
        return FuncPvp.DEFAULT_RANK
    end
    -- echo(" ===== 等仙台排名 === ",PVPModel:getHistoryTopRank())
    return PVPModel:getHistoryTopRank()
end

function ActConditionModel:treasureMaxLevelConditionOk(conditionNum)
    local current = self:treasureMaxLevelCurrentConditionNum()
    return current >= tonumber(conditionNum)
end

--拥有X套X颜色的神器
--判断是否完成目标条件
function ActConditionModel:haveArtifactGroupConditionOk(conditionNum, conditionParam)
    local haveNum = self:haveArtifactGroupCurrentConditionNum(conditionNum,conditionParam)
    return haveNum >= conditionNum and true or false;
end
--判断指定颜色的神器拥有多少件
function ActConditionModel:haveArtifactGroupCurrentConditionNum(conditionNum,conditionParam)
    local tragetColor = conditionParam[1]
    local carnivalType = FuncArtifact.carnivalType.COLOR_TYPE
    local haveNum = ArtifactModel:getArtifactCountByQualityOrAdvance(carnivalType, tragetColor)
    return haveNum
end

--拥有X个X星的伙伴
function ActConditionModel:haveStarOverPartnerConditionOk(conditionNum, conditionParam)

    local paramArray = string.split(conditionParam[1],",");

    local starNum = tonumber(paramArray[1]);

    --获得有几个大于star参数星级的伙伴
    local haveNum = PartnerModel:partnerNumGreaterThenParamStar(starNum - 1); 

    return haveNum >= conditionNum and true or false;
end
    --x个伙伴达到XX品质
function ActConditionModel:haveQualityOverPartnerConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local qualityNum = tonumber(paramArray[1]);
    
    --获得有几个大于quality参数星级的伙伴
    local haveNum = PartnerModel:partnerNumGreaterThenParamQuality(qualityNum - 1); 

    return haveNum >= conditionNum and true or false;
end

    --拥有X个XX等级的绝技 
function ActConditionModel:haveUniqueSkillOverPartnerConditionOk(conditionNum, conditionParam)

    local paramArray = string.split(conditionParam[1],",");
    local lvl = tonumber(paramArray[1]);

    local num = PartnerModel:getUniqueSkillLevelOverThenParamNum(lvl - 1);
    return num >= conditionNum and true or false;
end

    --拥有某某伙伴
function ActConditionModel:havePartnerConditionOk(conditionNum, conditionParam)
    local isOk = true
    for i,v in ipairs(conditionParam) do
        if not PartnerModel:isHavedPatnner(v) then
            isOk = false
            break
        end
    end
    return isOk
end

    --XX伙伴等级达到XX级
function ActConditionModel:partnerLevelOverConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local partnerId = tonumber(paramArray[1]);
    if PartnerModel:isHavedPatnner(partnerId) == false then
        return false;
    end 

    local partner = PartnerModel:getPartnerDataById(partnerId);
    return partner.level >= conditionNum and true or false;
end

    --XX伙伴达到X星
function ActConditionModel:partnerStarOverConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local partnerId = tonumber(paramArray[1]);
    if PartnerModel:isHavedPatnner(partnerId) == false then
        return false;
    end 

    local partner = PartnerModel:getPartnerDataById(partnerId);
    return partner.star >= conditionNum and true or false;
end

    --XX伙伴达到XX品质
function ActConditionModel:partnerQualityOverConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local partnerId = tonumber(paramArray[1]);
    if PartnerModel:isHavedPatnner(partnerId) == false then
        return false;
    end 

    local partner = PartnerModel:getPartnerDataById(partnerId);
    return partner.quality >= conditionNum and true or false;
end

    --XX伙伴绝技达到XX级 
function ActConditionModel:partnerUniqueSkillOverConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local partnerId = tonumber(paramArray[1]);

    if PartnerModel:isHavedPatnner(partnerId) == false then
        return false;
    end 

    local partner = PartnerModel:getPartnerDataById(partnerId);
    local totalUniqueSkillLvl = PartnerModel:getUniqueSkillTotalLevelByPartnerId(partnerId);

    return totalUniqueSkillLvl >= conditionNum and true or false;
end

    --拥有XX个伙伴
function ActConditionModel:partnerHaveConditionOk(conditionNum, conditionParam)
    return PartnerModel:getPartnerNum() >= conditionNum and true or false;
end

    --拥有XX个XX等级的伙伴
function ActConditionModel:haveLevelOverPartnerConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local levelNum = tonumber(paramArray[1]);
    
    --获得有几个大于quality参数星级的伙伴
    local haveNum = PartnerModel:partnerNumGreaterThenParamLvl(levelNum - 1); 

    return haveNum >= conditionNum and true or false;
end

    --X件装备达到XX品质
function ActConditionModel:haveQualityOverEquipsConditionOk(conditionNum, conditionParam)
    local paramArray = string.split(conditionParam[1],",");
    local qualityNum = tonumber(paramArray[1]);

    local haveNum = PartnerModel:getEquipmentNumByMorethanquality(qualityNum - 1);

    return haveNum >= conditionNum and true or false;
end

-- 无底深渊打到第几层
function ActConditionModel:reachEndlessFloorConditionOk( conditionNum, conditionParam )
    local haveNum = self:reachEndlessFloorCurrentConditionNum( conditionNum, conditionParam )
    return haveNum >= conditionNum and true or false;
end

-- 无底深渊打到第几层
function ActConditionModel:reachEndlessFloorCurrentConditionNum( conditionNum, conditionParam )
    local haveNum = UserExtModel:endlessId();
    return haveNum 
end

-- 连续x天充值达到60仙玉
-- 传入 conditionNum = 1,2,3,4,5 表示累计的天数,conditionParam = 60表示需要每日需要充值的数量
function ActConditionModel:accumulateChargeConditionOk(conditionNum, conditionParam,onlineId)
    -- echo("______conditionNum___________",conditionNum)
    -- dump(conditionParam, "conditionParam", nesting)
    local satisfiedNum = 0 -- 满足的天数
    local paramArray = string.split(conditionParam[1],",")
    local needChargesNum = tonumber(paramArray[1]);
    local chargeDateData = {}


    for scheduleId_conditionId,v in pairs(self._data) do
        if tostring(v.conditionId) == "202" then
            local bornTime = nil
            local onlineData = FuncActivity.getOnlineConfig(onlineId)
            if tonumber(onlineData.timeType) == FuncActivity.ACT_TIME_LIMIT_TYPE.SERVEROPEN_T then
                bornTime = LoginControler:getServerInfo().openTime
            elseif tonumber(onlineData.timeType) == FuncActivity.ACT_TIME_LIMIT_TYPE.USERINIT_T then 
                bornTime = CarnivalModel:getBornTime()
            end

            if v.param then
                local params = json.decode(v.param)
                for chargeDate,chargeNum in pairs(params) do
                    local durationSec = tonumber(chargeDate) - tonumber(bornTime)
                    local duration = math.floor(durationSec/(3600*24)) + 1
                    -- if (durationSec >= timeStart) and (durationSec < timeEnd) then
                        if not chargeDateData[duration] then
                            chargeDateData[duration] = 0
                        end
                        chargeDateData[duration] = chargeDateData[duration] + tonumber(chargeNum)
                        -- table.insert(chargeDateData[duration], chargeNum)
                    -- end
                end
            end
        end
    end
    self.chargeDateData = chargeDateData
    local scheduleData = FuncActivity.getOnlineConfig(tostring(onlineId))
    local timeStart =  math.floor(tonumber(scheduleData.start)/(3600*24)) 
    local timeEnd = math.floor(tonumber(scheduleData["end"])/(3600*24))
    for k,v in pairs(chargeDateData) do
        if (k > timeStart) and (k <= timeEnd) then
            if v >= needChargesNum then
                satisfiedNum = satisfiedNum + 1
            end
        end
    end

    if satisfiedNum >= conditionNum then
        return true
    else
        return false
    end
end

-- 获取充值数据
-- 开服第几天充值的仙玉数量
function ActConditionModel:getChargeDateData(onlineId)
    -- if not self.chargeDateData or table.length(self.chargeDateData) <=0 then
        self:accumulateChargeConditionOk(1, {60},onlineId)
    -- end
    return self.chargeDateData
end

-- 今日 单笔充值达到多少 conditionNum 钱    "203"为单笔充值条件类型
-- 单笔充值活动里 会传入完成次数检测是否达到要求
function ActConditionModel:oneChargeConditionOk(conditionNum, conditionParam,onlineId,finishTimes)
    -- echo("\n\n________conditionNum________",conditionNum)
    -- dump(conditionParam, "conditionParam")
    -- 目标完成次数默认为1
    local targetFinishTimes = 1
    if finishTimes then
        targetFinishTimes = finishTimes
    end
    local hasFinishTimes = 0
    for scheduleId_conditionId,v in pairs(self._data) do
        local conditionId = string.split(scheduleId_conditionId, "_")
        if tostring(conditionId[1]) == tostring(onlineId) and tostring(v.conditionId) == "203" then
            -- 有效日期,今天
            local validDate = nil
            local onlineData = FuncActivity.getOnlineConfig(onlineId)
            if tonumber(onlineData.timeType) == FuncActivity.ACT_TIME_LIMIT_TYPE.SERVEROPEN_T then
                validDate = LoginControler:getServerInfo().openTime
            elseif tonumber(onlineData.timeType) == FuncActivity.ACT_TIME_LIMIT_TYPE.USERINIT_T then 
                validDate = CarnivalModel:getBornTime() --去掉了服务器时间，暂时不用
            end
 
            if v.param then
                local params = json.decode(v.param)
                for chargeDate,chargeNum in pairs(params) do
                    local start_t = FuncActivity.getOnlineActTime(onlineData)
                    if table.isValueIn(ActConditionModel.specialMap, tostring(onlineId)) then
                        validDate = start_t
                    end

                    --服务端key值改成了 毫秒时间戳 所以有效时间需要*1000
                    local duration = tonumber(chargeDate) - tonumber(validDate * 1000)
                    if (duration >= 0) then
                        if tonumber(chargeNum) == tonumber(conditionNum) then
                            hasFinishTimes = hasFinishTimes + 1
                        end
                    end
                end
            end
        end
    end

    -- echo("\n\nhasFinishTimes===", hasFinishTimes, "targetFinishTimes===", targetFinishTimes)
    if hasFinishTimes >= targetFinishTimes then
        return true
    else
        return false
    end
end

-- - "==dmx==ActConditionModel:init==dmx==" = {
-- -     "149_202" = {
-- -         "conditionId" = 202
-- -         "count"       = 0
-- -         "param"       = "{"1529092800":30}"
-- -         "scheduleId"  = 149
-- -     }
-- -     "150_200" = {
-- -         "conditionId" = 200
-- -         "count"       = 30
-- -         "expireTime"  = 1529179200
-- -         "scheduleId"  = 150
-- -     }
-- -     "156_200" = {
-- -         "conditionId" = 200
-- -         "count"       = 30
-- -         "scheduleId"  = 156
-- -     }
-- -     "158_202" = {
-- -         "conditionId" = 202
-- -         "count"       = 0
-- -         "param"       = "{"1529092800":30}"
-- -         "scheduleId"  = 158
-- -     }
-- - }
-- [echo:05-17:01:02]

return ActConditionModel














