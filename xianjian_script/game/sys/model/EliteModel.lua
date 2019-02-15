
local EliteModel = class("EliteModel", BaseModel)

function EliteModel:init(exchangeArr)
	EliteModel.super.init(self, nil)
--    echo("奇缘挑战初始化")
    self.allConfigData = nil
    self.maxUnLockUnit = 1 
    
    self.elitesChallengeArr = EliteChanllengeModel:getData() -- 记录挑战
    self.elitesExchangeNumArr = exchangeArr or {}; -- 记录兑换的次数
    dump(self.elitesChallengeArr)
end



function EliteModel:updateData(data)
	EliteModel.super.updateData(self, data);
    for i,v in pairs(self.elitesExchangeNumArr) do
            if data[tostring(v.id)]  then
                v.count = data[tostring(v.id)].count
                return
            end
    end
    local _key = nil
    for i,v in pairs(data) do
        _key = v.id
    end
    if(_key ~=nil)then
        self.elitesExchangeNumArr[_key] = data[_key]
    end
end

-- 解析elite表 
function EliteModel:getAllCinfigData()
    if self.allConfigData == nil then
        self.allConfigData = {}
        local eliteList = {};
        for i,v in pairs(FuncElite.getConfigElite()) do
             table.insert(eliteList,v)
        end
        
        local allaAscription = {};
        local isHas = false
        for i,v in pairs(eliteList) do
            isHas = false
            for k,m in pairs(allaAscription) do
               if m == v.ascription then
                  isHas = true
                  break
               end
            end
            if not isHas then
                table.insert(allaAscription,v.ascription)
            end
        end
        local function sortFunc(a, b)
            return tonumber(a.id) < tonumber(b.id);
        end
        for i,v in pairs(allaAscription) do
            local t = {}
            for k,m in pairs(eliteList) do
                if v == m.ascription then
                   table.insert(t,m)
                end
            end
            

	        table.sort(t, sortFunc);
            table.insert(self.allConfigData,t)
        end


        --由小到大排序
	    function sortFunc(a, b)
		    return a[1].ascription < b[1].ascription;
	    end

	    table.sort(self.allConfigData, sortFunc);
        
    end

    return self.allConfigData
end

function EliteModel:getGetWayData(data)
    local eliteList = self:getAllCinfigData()
    for i,v in pairs(eliteList) do
        if v[1].ascription == tonumber(data[1]) then
            return v
        end
    end
    echo("获取途径 章节配错了")
    return nil
end
-- 得到章节开启的列表
function EliteModel:getAllVaildEliteList()
    local eliteList = self:getAllCinfigData()
    

    -- 需要一个判断 是否开启
    local vaildEliteList = {}
    for i,v in pairs(eliteList) do
        -- 添加判断
        if self:isOpenEliteUnitById(v[1].condition,v[1],true) then
            if v[1].ascription > self.maxUnLockUnit then
                self.maxUnLockUnit = v[1].ascription
            end
            
            table.insert(vaildEliteList,v)
        else
            table.insert(vaildEliteList,v)
            break
        end
        
    end
    return vaildEliteList;
end

-- 奇缘开启条件  
-- 第一章 第一关 通过问情来判断
function EliteModel:openEliteCondition()
    local eliteList = self:getAllCinfigData()
    local cond = eliteList[1][1].condition
    local con = cond[1].v
    return tostring(con)
end

-- 判断章节是否通关
function EliteModel:isTGEliteUnitById(unitData)
    local data = self.elitesChallengeArr[tostring(unitData[1].ascription)]
    if data == nil then
            return false
    end
    for i,v in pairs(unitData) do
        if data.eliteId < tonumber(v.id) then
            return false
        end
    end
    return true
    
end

-- 判断章节是否开启 
function EliteModel:isOpenEliteUnitById(condition,data , isZhangjie)
    -- 需要通过问情判断
    
    local unlockMaxPveRaidId = UserExtModel:getMainStageId() -- 寻仙
    for m,n in pairs(condition)  do
         if n.t == 4 then
            if tonumber(unlockMaxPveRaidId) < n.v then
                return false
            end
         elseif n.t == 5 then
            local _data = self.elitesChallengeArr[tostring(data.ascription)]
            if _data then
                 if tonumber(_data.eliteId) < n.v then
                     return false
                 end
            else
                local lastUnit = data.ascription - 1
                local eliteList = self:getAllCinfigData()
                if isZhangjie then
                     -- 判断 上一章节是否通关
                    for i,v in pairs(eliteList) do
                         if i == lastUnit then
                            if self:isTGEliteUnitById(v) == false then
                                return  false
                            end
                         end
                    end
                else
                    if lastUnit == 0 then
                        return false
                    end
                    for i,v in pairs(eliteList) do
                         if i == lastUnit then
                             if(self:isTGEliteUnitById(v)) then
                                local _data = self.elitesChallengeArr[tostring(lastUnit)]
                                if _data then
                                     if tonumber(_data.eliteId) < n.v then
                                         return false
                                     end
                                end
                             end
                         end
                    end
                end
            end
         end
    end
    
    return true
end
-- npc 详情
function EliteModel:getNpcDefailInfos(npcId)
--	local npcConfig = FuncCommon.getNpcDataById(npcId)
--	local spineName = npcConfig.spine

--	return spineName
end
-- 
function EliteModel:getMaxUnlockUnit()
    return self.maxUnLockUnit
end
function EliteModel:isPlayUnlockUnitEffect()
    --取解锁的最大章节
    local _key = UserModel:_id() .. "ELITE_UNLOCK_UNIT"
    local _unit = LS:pub():get(_key, 1) 
    if self.maxUnLockUnit > tonumber(_unit) then
        return true
    else
        return false
    end   
end

-------------------------------------------
----------------详情逻辑-------------------

-- 判断小关是否开启
function EliteModel:isOpenXiaoGuanByCondition(condition,data)
    return self:isOpenEliteUnitById(condition,data)
end
function EliteModel:isOpenXiaoGuanById(dataId)
    local data = nil
    for i,v in pairs(FuncElite.getConfigElite()) do
       if tostring(v.id) == tostring(dataId) then
           data = v
           break
       end
    end
    
    return self:isOpenXiaoGuanByCondition(data.condition,data)
end

-- 获得 小关挑战的状态 true 挑战过 false 没有挑战
function EliteModel:hasChangeFinish(data)
    local b = self.elitesChallengeArr[tostring(data.ascription)]
    if b then
        if tonumber(data.id) <= b.eliteId then
            return true
        else
            return false
        end
    else    
        return false   
    end

    
    
end
-- 判断是否开启 一键兑换
function EliteModel:isYJDH()
    local vipLevel = UserModel:vip();
    local setVipLevel =  FuncDataSetting.getDataByHid("RomanceFast").num
    if vipLevel >= setVipLevel then
         return true
    end
    return false
end
-- 判断体力是否足够
function EliteModel:isTiliSatisfy(recard,_type)
    local hasSp = UserExtModel:sp()
    local constSp = self:getxiaohaotiliNumById(recard,_type)
    if constSp == 0 then
       return false
    end
    return _yuan3(hasSp >= constSp ,true,false)
end

-- 判断是否 vip满级
function EliteModel:isVipManji()
    local vipLevel = UserModel:vip();
    local vipmax = FuncCommon.getMaxVipLevel();
    if vipLevel == vipmax then
       return true
    end
    return false
end

-- 兑换的总次数
function EliteModel:getExchangeAllNums()
    local vipLevel = UserModel:vip();
    local extra = FuncCommon.getVipPropByKey(vipLevel, "interactTimes");
    return (FuncDataSetting.getDataByHid("RomanceExchangeNum").num + extra)
end

-- 得到 兑换的剩余次数
function EliteModel:getExchangeNumsById(_id)
    local dayNums =  self:getExchangeAllNums()
    if self.elitesExchangeNumArr then
        
        for i,v in pairs(self.elitesExchangeNumArr) do
            if v.id == _id then
                return (dayNums - v.count)
            end
        end
    end
    return dayNums
end


-- 一键兑换 1, 单次 0 消耗的总体力
function EliteModel:getxiaohaotiliNumById(data,_type)
        if _type == 0 then
          return data.consume2
        end

        local num = 0 ;
        local dayNums =  self:getExchangeAllNums()
        for i,v in pairs(self.elitesExchangeNumArr) do
            if v.id == data.id then
                num =  v.count
            end
        end

        --一键兑换只能兑换自身金币允许的次数
        local canDHNums = math.floor(UserExtModel:sp() / data.consume2) --可以兑换的次数
        if (dayNums - num) >= canDHNums then
            return canDHNums * data.consume2
        end

        return  (dayNums - num) * data.consume2
end

-- 兑换回调
function EliteModel:duihuanHuidian(_id,isAll)
--    self.elitesExchangeNumArr = UserModel:romanceInteracts()
end
-- tiaozhan 
function EliteModel:tiaozhanHuidian(_id)
    self.elitesChallengeArr = EliteChanllengeModel:getData()
end
-- index
function EliteModel:getIndexInArrByData(arr,data)
   
    for m,n in pairs(arr) do
        if n == data then
            return m;
        end
    end 
    dump(data,"_data")
    echoWarn("EliteModel:getIndexInArrByData(arr,data) not find in arr");
    return #arr or 1
end


--初始化时 小关默认显示第几个
function EliteModel:initXiaoguanByData(_data)
    local b = self.elitesChallengeArr[tostring(_data[1].ascription)]
    if b then
        for m,n in pairs(_data) do
            if b.eliteId < tonumber(n.id) then
               return n,m
            end
        end
    else    
        return _data[1],1
    end
    
    if table.isEmpty(self.elitesChallengeArr) then
        return _data[1],1
    end
    return _data[#_data],#_data
end
function  EliteModel:getIndexByDataInUnits(unitsData,selectData)
    for m,n in pairs(unitsData) do
        if n.id == selectData.id then
            return m
        end
    end
    return 1
end

return EliteModel
