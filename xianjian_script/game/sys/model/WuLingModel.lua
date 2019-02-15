--[[
    Author: caocheng
    Date:2017-10-31
    Description: 五灵养成model
]]

local WuLingModel = class("WuLingModel",BaseModel)

function WuLingModel:init(data)
    WuLingModel.super.init(self,data)
    
    EventControler:addEventListener(UserEvent.USEREVENT_LEVEL_CHANGE, self.activateFiveSouls, self)
    EventControler:addEventListener(ItemEvent.ITEMEVENT_ITEM_CHANGE, self.dispathRedPointEvent, self)
    
    EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                    {redPointType = HomeModel.REDPOINT.DOWNBTN.FIVESOUL, isShow = self:checkRedPoint()})
end    

function WuLingModel:dispathRedPointEvent(event)
    for k,v in pairs(event.params) do
        local itemCfg = FuncItem.getItemData(k)
        if itemCfg.subType_display == ItemsModel.itemSubTypes_New.ITEM_SUBTYPE_314 then
            EventControler:dispatchEvent(HomeEvent.RED_POINT_EVENT,
                    {redPointType = HomeModel.REDPOINT.DOWNBTN.FIVESOUL, isShow = self:checkRedPoint()})
            break
        end
    end
end

function WuLingModel:getWuLingLevelById(id, fiveSouls)
    local tempLevel = 1
    if not fiveSouls then
        fiveSouls = UserModel:fivesouls()
    end
    if fiveSouls then
        for k,v in pairs(fiveSouls) do
            if tostring(k) == tostring(id) then
                tempLevel = v
            end
        end    
    end
    return tempLevel
end

function WuLingModel:getWuLingProperty(id,level)
    local allProperty = FuncWuLing.getFiveSoulSpirit(id)
    local firstProperty = 0
    local secondProperty = 0
    for k,v in pairs(allProperty) do
        if tonumber(k) <= tonumber(level) then
            firstProperty = firstProperty + v.fastness
            if v.skill then
                secondProperty = secondProperty + v.skill
           end     
        end
    end
    firstProperty = firstProperty/100
    return firstProperty,secondProperty
end

function WuLingModel:getSingleWuLing(id,level)
    local allProperty = FuncWuLing.getFiveSoulSpirit(id)
     for k,v in pairs(allProperty) do
         if tonumber(k) == tonumber(level) then
            return v
        end  
     end
end

function WuLingModel:checkWuLingLevel()
    for k = 1,5 do
        local tempLevel = self:getWuLingLevelById(k)
        if tonumber(tempLevel) > 1 then
            return true
        end
    end
    return false
end

function WuLingModel:switchTextById(id)
    local tempStr = ""
    if tonumber(id) == 1 then
        tempStr = "风抗性"
    elseif tonumber(id) == 2 then
        tempStr = "雷抗性"
    elseif tonumber(id) == 3 then
        tempStr = "水抗性"
    elseif tonumber(id) == 4 then
        tempStr = "火抗性"
    elseif tonumber(id) == 5 then
        tempStr = "土抗性"
    end
    return tempStr
end   

--五灵法阵开启规则描述  如果改了需要对应的修改这里
function WuLingModel:switchMatrixMethodByLevel(level)
    local tempStr = ""
    if tonumber(level) < 51 then
        tempStr = GameConfig.getLanguage("tid_fivesoul_rule_1")
    elseif tonumber(level) < 61 then
        tempStr = GameConfig.getLanguage("tid_fivesoul_rule_2")
    elseif tonumber(level) < 66 then
        tempStr = GameConfig.getLanguage("tid_fivesoul_rule_3")
    elseif tonumber(level) < 81 then
        tempStr = GameConfig.getLanguage("tid_fivesoul_rule_4")
    elseif tonumber(level) < 86 then
       tempStr = GameConfig.getLanguage("tid_fivesoul_rule_5")
    else
        tempStr = GameConfig.getLanguage("tid_fivesoul_rule_6")   
    end
    return tempStr
end  

--传入他人数据fivesouls可获取对应——id的五灵战力
function WuLingModel:getTempAbility(_id, fivesouls)
   local tempAbility = 0 
    if not FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) then 
        return tempAbility
    end
    local fivesoulsT = UserModel:fivesouls()
    if fivesouls then
        fivesoulsT = fivesouls
    end

    if not fivesoulsT  or table.length(fivesoulsT) == 0 then
        return tempAbility
    end

    local tempLevel =self:getWuLingLevelById(_id, fivesouls)
    for m = 1,tempLevel do
        local tempNum = FuncWuLing.getFiveSoulInfoByLevel(_id, m)
        tempAbility = tempAbility + tempNum
    end 

    return tempAbility
end
-- 五灵激活元素战力  fivesouls为获取他人战力时传入的参数
function WuLingModel:getTempAwakenAbility(partnerElement, _id, fivesouls)
    local ability = 0
    if tonumber(partnerElement) == tonumber(_id) then
        local tempLevel = self:getWuLingLevelById(_id, fivesouls)
        local promoteAbility = FuncWuLing.getFiveSoulPromoteAbilityLevel(_id, tempLevel)
        ability = ability + promoteAbility
    end
    return ability
end

--检查红点  并返回可提升五灵的列表
function WuLingModel:checkRedPoint()
    -- echoError("_______--1111-_________")
    local redPoint = false
    local canPromoteTable = {}
    if FuncCommon.isSystemOpen("fivesoul") then
        for k = 1,5 do
            local tempLevel = self:getWuLingLevelById(k)
            local itemId = FuncTeamFormation.getItemIdByFiveSoul(k)
            local haveItemNum = ItemsModel:getItemNumById(itemId)
            echo("\n\ntempLevel===", tempLevel)
            local cost = FuncWuLing.getCostByIdAndLevel(k, tempLevel)
            if cost then
                local cost_table = string.split(cost[1], ",")
                local needItemNum = cost_table[3]
                -- local tempUserPoint = UserExtModel:fiveSoulPoint()
                if needItemNum and tonumber(haveItemNum) >= tonumber(needItemNum) then
                    redPoint = true
                    table.insert(canPromoteTable, k)
                end
            end
            
        end
    end

    return redPoint, canPromoteTable
end


function WuLingModel:getWuLingNumByLevel(level)
    local tempNum = 0 
    for k = 1,5 do
       local templevel = self:getWuLingLevelById(k)
       if tonumber(templevel) >= tonumber(level) then
            tempNum = tempNum +1
        end
    end
    return tempNum 
end

function WuLingModel:getWuLingLevelSort()
    local tempLevelGroup = {}
    for k = 1,5 do
        local tempLevl = self:getWuLingLevelById(k)
        local tempMap  = {}
        tempMap.id = k
        tempMap.level = tempLevl
        table.insert(tempLevelGroup,tempMap)
    end
    table.sort(tempLevelGroup,function (a,b)
        local rst =false
        if a.level > b.level then
            rst = true 
        elseif  a.level == b.level then
            if a.id < b.id then
                rst = true 
            end
        end   
        return rst
    end)
    return tempLevelGroup
end

function WuLingModel:getWuLingGroup()
    local wulingGroup = {}
    local tempMap = self:getWuLingLevelSort()
    local wulingNum  = FuncWuLing.getFiveSoulMatrixMethodByLevel(UserModel:level()).same

    for k,v in pairs(tempMap) do
        for n = 1,wulingNum do
            table.insert(wulingGroup,v.id)
        end
    end
    return wulingGroup
end

--根据id检查对应五灵是否激活
function WuLingModel:checkFiveSoulActiveById(_id)
    local fiveSouls = UserModel:fivesouls()

    for k,v in pairs(fiveSouls) do
        if tostring(_id) == tostring(k) then
            return true
        end
    end
    return false
end

--发送请求激活五灵
function WuLingModel:activateFiveSouls()
    if FuncCommon.isSystemOpen(FuncCommon.SYSTEM_NAME.FIVESOUL) and 
        table.length(UserModel:fivesouls()) == 0 then
        WuLingServer:activateFiveSouls({}, nil)
    end
end

return WuLingModel