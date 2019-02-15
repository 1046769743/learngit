--
--Author:      zhuguangyuan
--DateTime:    2017-09-25 18:57:40
--Description: 情缘系统读取静态数据表类
--

FuncNewLove= FuncNewLove or {}

local config_LoveCombination = nil
local config_LoveMain = nil
local config_love = nil
local config_LoveLv = nil

FuncNewLove.maxLevel = 5
-- 情缘系统开发模式
FuncNewLove.isDebug = false

-- 情缘值等级与名字之间的映射
FuncNewLove.map_LoveValue_Name = {
    "陌生",
    "初识",
    "友好",
    "喜欢",
    "至爱",
}
-- ==================================================
-- 寻缘全局属性
-- ==================================================
-- 寻缘小格子的点亮状态
FuncNewLove.LightenStatus = {
    CANNOT_LIGHTEN = 1,
    CAN_LIGHTEN = 2,
    LIGHTENED = 3,
}
-- 全局属性 附加的奇侠目标类型
FuncNewLove.appendTarget = {
    CHAR = 0,      --主角
    OFFENSIVE = 1, -- 攻击型
    DEFENSIVE = 2, -- 防御型
    ASSISTED = 3,  -- 辅助型
}
FuncNewLove.appendTargetName = {
     [0] = "主角",      --主角
     [1] = "攻击奇侠", -- 攻击型
     [2] = "防御奇侠", -- 防御型
     [3] = "辅助奇侠",  -- 辅助型
}



function FuncNewLove.init()
	-- 主界面展示相关配置
    config_LoveCombination = Tool:configRequire("love.LoveCombination")
    -- 主奇侠相关配置
	config_LoveMain = Tool:configRequire("love.LoveMain")
	-- 情缘（两个伙伴之间的关系）
    config_love = Tool:configRequire("love.Love")
    -- 情缘升级条件相关
    config_LoveLv = Tool:configRequire("love.LoveLv")
    -- 跳转条件提示文字
    config_LoveConditionText = Tool:configRequire("love.LoveCondition")
end

--------------------------------------------------------------------------
---------------------- 主界面展示相关配置 --------------------------------
---------------------- LoveCombination    --------------------------------
--------------------------------------------------------------------------
-- 获取主题信息
function FuncNewLove.getAllThemeData()
	return config_LoveCombination
end

-- 根据主题id获取伙伴列表
function FuncNewLove.getPartnersByThemeId(themeId)
    local data = config_LoveCombination[tostring(themeId)]
    if data and data.lovePartnerGroup then
        return data.lovePartnerGroup
    else
        echoError("error: FuncNewLove.getPartnersByThemeId id " ..  tostring(themeId) .. " is nil")
    end 
end

-- 根据主题id获取背景图
function FuncNewLove.getBgByThemeId(themeId)
    local data = config_LoveCombination[tostring(themeId)]
    if data and data.loveOrnament then
        return data.loveOrnament
    else
        echoError("error: FuncNewLove.getBgByThemeId id " ..  tostring(themeId) .. " is nil")
    end 
end

-- 根据主题id获取主题名字
function FuncNewLove.getNameByThemeId(themeId)
    local data = config_LoveCombination[tostring(themeId)]
    if data and data.loveButtonName then
        return data.loveButtonName
    else
        echoError("error: FuncNewLove.getNameByThemeId id " ..  tostring(themeId) .. " is nil")
    end 
end



--------------------------------------------------------------------------
---------------------- 主奇侠相关配置 ------------------------------------
---------------------- LoveMain       ------------------------------------
--------------------------------------------------------------------------
-- 获取奇侠信息
function FuncNewLove.getPartnerData(partnerId)
    return config_LoveMain[tostring(partnerId)]
end

-- 根据主伙伴id获取可升共鸣阶的最大阶数
function FuncNewLove.getMaxResonateLvByPartnerId(partnerId)
    local data = config_LoveMain[tostring(partnerId)]
    if data and data.maxLv then
        return data.maxLv
    else
        echoError("error: FuncNewLove.getVicePartnersListByPartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end

-- 根据主伙伴id获取副伙伴列表
function FuncNewLove.getVicePartnersListByPartnerId(partnerId)
    local data = config_LoveMain[tostring(partnerId)]
    if data and data.vicePartnerGroup then
        return data.vicePartnerGroup
    else
        -- echoError("error: FuncNewLove.getVicePartnersListByPartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end

-- 根据主伙伴id和共鸣阶数获取共鸣阶属性
function FuncNewLove.getResonatePropertyBypartnerId(partnerId,rank)
    echo("partnerId,rank___________",partnerId,rank)
    if not rank or rank == 0 then
        rank = nil
    end
    local data = config_LoveMain[tostring(partnerId)]
    local property = "resonateProperty"..tostring(rank)
    if data and data[property] then
        return data[property]
    else
        echoError("error: FuncNewLove.getResonatePropertyBypartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end



-- 根据主伙伴id获取所有共鸣阶战力
function FuncNewLove.getAddAbilityBypartnerId(partnerId)
    local data = config_LoveMain[tostring(partnerId)]
    if data and data.addAbility then
        return data.addAbility
    else
        return {} ---echoError("error: FuncNewLove.getAddAbilityBypartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end

-- 根据主伙伴id和共鸣阶数获取共鸣阶战力
function FuncNewLove.getOneAddAbilityBypartnerId(partnerId,rank)
    local data = config_LoveMain[tostring(partnerId)]
    if data and data.addAbility then
        if data.addAbility[tonumber(rank)] then
            return data.addAbility[tonumber(rank)]
        end
    else
        echoError("error: FuncNewLove.getOneAddAbilityBypartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end

-- 根据主伙伴id和共鸣阶数获取共鸣阶战力
function FuncNewLove.getNameBypartnerId(partnerId)
    local data = config_LoveMain[tostring(partnerId)]
    if data and data.loveTitle then
        return data.loveTitle
    else
        echoError("error: FuncNewLove.getNameBypartnerId id " ..  tostring(partnerId) .. " is nil")
    end 
end

--------------------------------------------------------------------------
---------------------- 情缘（两个伙伴之间的关系）相关配置 ----------------
---------------------- Love                               ----------------
--------------------------------------------------------------------------
-- 根据情缘id获得情缘数据
function FuncNewLove.getLoveDataByLoveId(loveId)
    return config_love[tostring(loveId)]
end

-- 根据情缘id获得主伙伴id
function FuncNewLove.getLoveMainPartnerIdByLoveId(loveId)
    local data = config_love[loveId]
    if data and data.belongMainId then
        return data.belongMainId
    else
        echoError("error: FuncNewLove.getLoveMainPartnerIdByLoveId id " ..  tostring(loveId) .. " is nil")
    end
end

-- 根据情缘id获得副伙伴id
function FuncNewLove.getLoveVicePartnerIdByLoveId(loveId)
    local data = config_love[loveId]
    if data and data.viceLovePartner then
        return data.viceLovePartner
    else
        echoError("error: FuncNewLove.getLoveVicePartnerIdByLoveId id " ..  tostring(loveId) .. " is nil")
    end
end

-- 根据主伙伴id 和 副伙伴id 获取情缘id
function FuncNewLove.getLoveIdByPartnerId(mainPartnerId,vicePartnerId)
    -- echo("______ mainp,vicep _________",mainPartnerId,vicePartnerId)
    local loveData = FuncNewLove.getLoveByPartnerId(mainPartnerId,vicePartnerId)
    if loveData then
        return loveData.id
    end
    return nil
end

-- 根据主伙伴id 和 副伙伴id 获取情缘id
function FuncNewLove.getLoveByPartnerId(mainPartnerId,vicePartnerId)
    -- echo("______ mainp,vicep _________",mainPartnerId,vicePartnerId)
    for k,v in pairs(config_love) do
        local mainId = v.belongMainId 
        local viceId = v.viceLovePartner
        local id = v.id
        if mainId == tostring(mainPartnerId) and
             viceId == tostring(vicePartnerId) then
            return v
        end
    end
    return nil
end

-- 获取情缘关系描述文字
-- 传入情缘id 和 情缘阶
function FuncNewLove.getLoveLevelDescById(loveId,loveValueLevel)
    local data = config_love[tostring(loveId)]
    if loveValueLevel and data["tips"..loveValueLevel] then
        return data["tips"..loveValueLevel]
    end
end

--------------------------------------------------------------------------
---------------------- 情缘升级相关条件及属性配置 ------------------------
---------------------- LoveLv                     ------------------------
--------------------------------------------------------------------------
-- 根据情缘id和目标等级获得升级条件数据
-- 注意该表的主键为二值主键，有坑
function FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank(loveId,targetRank)
    -- echo("-------------- FUNC 中 loveId,targetRank ——————————————————",loveId,targetRank)
    if targetRank == 0 then
        targetRank = 1
    end
    for k,conditionK in pairs(config_LoveLv) do
        if conditionK["1"].loveId == tostring(loveId) then
            if conditionK[tostring(targetRank)] then
                return conditionK[tostring(targetRank)]
            end
        end
    end
    echoError("error: FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank id " ..  tostring(loveId) .. " is nil")
end

-- 根据情缘id和目标等级获得升级条件
function FuncNewLove.getLovelevelUpCondition(loveId,targetRank)
    local conditionK = FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank(loveId,targetRank)
    if conditionK and conditionK["lovePromoterCondition"] then
        return conditionK["lovePromoterCondition"]
    end
    echoError("error: FuncNewLove.getLovelevelUpCondition id " ..  tostring(loveId) .. " is nil")
end

-- 根据情缘id和目标等级获得升级所带来的属性提升
function FuncNewLove.getLovelevelUpProperty(loveId,targetRank)
    local conditionK = FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank(loveId,targetRank)
    if conditionK and conditionK["lovePromoterProperty"] then
        return conditionK["lovePromoterProperty"]
    end
    echoError("error: FuncNewLove.getLovelevelUpProperty id " ..  tostring(loveId) .. " is nil")
end

-- 根据情缘id和目标等级获得升级所带来的战力提升
function FuncNewLove.getLovelevelUpAddAbility(loveId,targetRank)
    local conditionK = FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank(loveId,targetRank)
    if conditionK and conditionK["addAbility"] then
        return conditionK["addAbility"]
    end
    echoError("error: FuncNewLove.getLovelevelUpAddAbility id " ..  tostring(loveId) .. " is nil")
end

-- 根据情缘id和目标等级获得该等级情缘的关系文本
-- @暂时废弃
function FuncNewLove.getLovelevelUpText(loveId,targetRank)
    local conditionK = FuncNewLove.getLovelevelUpDataByLoveIdAndTargetRank(loveId,targetRank)
    if conditionK and conditionK["loveValue"] then
        return conditionK["loveValue"]
    end
    echoError("error: FuncNewLove.getLovelevelUpText id " ..  tostring(loveId) .. " is nil")
end


-- 根据条件type和mode获得该条件的提示文本
function FuncNewLove.getConditionShowText(_type,_mode)
    for k,v in pairs(config_LoveConditionText) do
        local key = v.conditionTxt
        key = key[1]
        if tostring(key.type) == tostring(_type) and 
            tostring(key.mode) == tostring(_mode) then
            return v.loveTxt
        end
    end
    echoError("error: FuncNewLove.getConditionShowText id " ..  tostring(loveId) .. " is nil")
end
--------------------------------------------------------------------------
---------------------- 对外 属性和战力接口       -------------------------
-- 属性情缘 和 情缘全局公用一个接口
-- 战力 情缘 和情缘全局用不同接口
--------------------------------------------------------------------------
-- 根据伙伴数据获取主伙伴当前的情缘属性
-- 若有全局情缘数据则传入
-- {{共鸣属性加成},{情缘1加成},{情缘2加成},{情缘3加成}[,{情缘4加成}]}
function FuncNewLove.getMainPartnerCurrentLoveProperty(partnerData)
    -- dump(partnerData,"\n\n\n\n\n\n\n伙伴系统传进来的伙伴数据==属性")
    if not partnerData then
        return {}
    end
    local propertyTotal = {}
    -- local tempProperty = {}
    -- 共鸣阶属性
    local resonanceLv = partnerData.resonanceLv
    if resonanceLv and resonanceLv > 0 then
        local dataArr = FuncNewLove.getResonatePropertyBypartnerId(partnerData.id,resonanceLv)
        -- dump(dataArr," 主伙伴共鸣属性数据 dataArr ")
        for k,v in pairs(dataArr) do
            local tempProperty = {}
            tempProperty.key = v.property
            tempProperty.value = v.value
            tempProperty.mode = v.mode
            table.insert(propertyTotal,tempProperty)
        end
    end

    -- 多条情缘 阶属性
    local lovesData = partnerData.loves
    if lovesData then   
        for loveId,Data in pairs(lovesData) do
            local loveLevel = Data.lv
            local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,loveLevel)
            -- echo(" 奇侠奇缘 属性 ：————loveId,loveLevel-----",loveId,loveLevel)
            -- dump(dataArr," 各个情缘属性数据 dataArr") 

            for k,v in pairs(dataArr) do
                local tempProperty = {}
                tempProperty.key = v.property
                tempProperty.value = v.value
                tempProperty.mode = v.mode
                table.insert(propertyTotal,tempProperty)
            end
        end
    end
    -- dump(propertyTotal," 主伙伴总的情缘属性数据 ")
    return propertyTotal
end


-- 根据伙伴数据获取主伙伴的 当前的情缘加成总战力
-- 只给相应的伙伴加
function FuncNewLove.getMainPartnerCurrentLoveAddAbility(partnerData)
    -- dump(partnerData,"\n\n\n\n\n\n\n伙伴系统传进来的伙伴数据==战力")
    if not partnerData then
        return {}
    end

    local abilityTotal = 0
    -- 共鸣阶战力
    local resonanceLv = partnerData.resonanceLv or 0 
    local abilityArr = FuncNewLove.getAddAbilityBypartnerId(partnerData.id)
    -- echo(" 奇侠奇缘 共鸣战力 ：———— partnerData.id,resonanceLv -----",partnerData.id,resonanceLv)

    for i = 1,resonanceLv do
        -- echo(" 共鸣战力 ：———— partnerData.id,i -----",partnerData.id,i)
        abilityTotal = abilityTotal + abilityArr[i]
    end
    -- echo("战力1 === ",abilityTotal)

    -- 多条情缘 阶战力
    local lovesData = partnerData.loves
    if lovesData then
        for loveId,Data in pairs(lovesData) do
            local loveLevel = Data.lv
            local ability = 0
            -- 战力是叠加的 每条情缘的战力加成都应该从1阶累加起 到当前阶
            if loveLevel > 0 then
                for i = 1,loveLevel do
                    ability = FuncNewLove.getLovelevelUpAddAbility(loveId,i)
                    abilityTotal = abilityTotal + ability
                end
            end
        end
    end
    -- echo("战力2 === ",abilityTotal)
    -- echo(" 总战力 ：———— partnerData.id ，abilityTotal",partnerData.id,abilityTotal)
    return abilityTotal
end

-- =============================================
-- 伙伴界面显示情缘属性加成 接口
-- =============================================
-- 根据副伙伴id获取该条情缘属性数据
-- 若还没有情缘属性 则返回最低档 并返回false
-- 否则返回当前档 并返回true
-- 若主伙伴还没唤醒 则传入主伙伴id 
function FuncNewLove.getOneLoveCurrentProperty( mainPartnerData,vicePartnerId )
    -- local isHavePartner = PartnerModel:isHavedPatnner(vicePartnerId)
    local mainPartnerId = nil
    local loveId = nil
    local targetLoveLevel = 1
    local isHas = false

    if type(mainPartnerData) == "string" or (not mainPartnerData.loves) then
        mainPartnerId = mainPartnerData
        if type(mainPartnerData) == "table" then
            mainPartnerId = mainPartnerData.id
        end
        isHas = false
        loveId = FuncNewLove.getLoveIdByPartnerId(mainPartnerId,vicePartnerId)
        targetLoveLevel = 1
    else
        loveId = FuncNewLove.getLoveIdByPartnerId(mainPartnerData.id,vicePartnerId)
        lovesData = mainPartnerData.loves 
        if loveId and lovesData then 
            if lovesData[tostring(loveId)] then
                targetLoveLevel = lovesData[tostring(loveId)].lv 
                if lovesData[tostring(loveId)].lv == 0 then
                    isHas = false
                    targetLoveLevel = 1
                else
                    targetLoveLevel = lovesData[tostring(loveId)].lv
                    isHas = true
                end
            else 
                targetLoveLevel = 1
                isHas = false
            end
        else
            echoError("没有配置此两伙伴的情缘——————",mainPartnerData.id,vicePartnerId)
        end
    end

    local propertyTotal = {}
    local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,targetLoveLevel)
    if dataArr and table.length(dataArr) > 0 then
        for k,v in pairs(dataArr) do
            local tempProperty = {}
            tempProperty.key = v.property
            tempProperty.value = v.value
            tempProperty.mode = v.mode
            table.insert(propertyTotal,tempProperty)
        end
    end

    return propertyTotal,isHas
end

-- 根据伙伴id获取最高情缘属性
-- 注意主伙伴关联的副伙伴数组中 
-- 有些副伙伴和主伙伴可能没有关联情缘
-- 暂时写死 情缘阶最高阶为5
function FuncNewLove.getOneLoveTopProperty( mainPartnerId,vicePartnerId )
    local propertyTotal = {}
    local loveId = FuncNewLove.getLoveIdByPartnerId(mainPartnerId,vicePartnerId)
    -- local lovesData = mainPartnerData.loves 
    local loveLevel = FuncNewLove.maxLevel
    if loveId then 
        local dataArr = FuncNewLove.getLovelevelUpProperty(loveId,loveLevel)
        for k,v in pairs(dataArr) do
            local tempProperty = {}
            tempProperty.key = v.property
            tempProperty.value = v.value
            tempProperty.mode = v.mode
            table.insert(propertyTotal,tempProperty)
        end
        -- dump(propertyTotal," 此情缘属性数据 ")
    else
        echoError("没有配置此两伙伴的情缘——————",mainPartnerData.id,vicePartnerId)
    end
    return propertyTotal
end

--传递进来的数  attrGroup1 = { {key = 1,value =2,mode = 1},...       }  
--传递进来的数  attrGroup2 = { {key = 1,value =2,mode = 1},...       }  ...
--可以传递进来N个 属性加成数组
--计算最终属性值 多个模块的属性加成 然后 合并计算 返回 
--{  {key:1,value:1,} ,...          } 这样的结构 
-- 参考 FuncBattleBase.countFinalAttr(attrGroup1,attrGroup2,... )
-- function FuncNewLove.countFinalAttrForShow(attrGroup1,attrGroup2,... )
--     local attrDataMap = {} 
--     local allGroups  = {attrGroup1,attrGroup2,...}
--     for i,v in pairs(allGroups) do
--         for ii,vv in ipairs(v) do
--             local key = vv.key
--             local value = vv.value
--             local mode = vv.mode
--             if not attrDataMap[vv.key] then
--                 attrDataMap[key] = {
--                     [1] = 0,
--                     [2] = 0,
--                     [3] = 0,
--                     [4] = 0,
--                 }
--             end
--             local data = attrDataMap[key]
--             --加上这个属性
--             data[mode] = data[mode] + value
--         end
--     end
--     local resultInfo = {}

--     dump(attrDataMap, "attrDataMap")
--     -- for k,v in pairs(attrDataMap) do
--     --     dump(value, desciption, nesting)
--     --     -- local data = {key = k}
--     --     if 
--     --     local tempValue = v[1] + v[2] + v[3] + v[4]
--     --     if v[2] > 0 then
--     --         tempValue = (tempValue/100).."%"
--     --     end

--     --     -- local str = "key = "..k.."；基础值 = "..v[1].."；万分比部分 = "..v[2]
--     --     -- str = str.."；固定值部分 = "..v[3].."；成长系数部分 = "..v[4]
--     --     -- str = str.."；计算结果 = "..data.value
--     --     -- echo("\n\n 伙伴总属性计算 ========== ",str)
--     --     -- table.insert(resultInfo, data)
--     --     resultInfo[k] = tempValue
--     -- end
--     -- dump(resultInfo,"计算结果哈哈哈哈")
--     return resultInfo
-- end

function FuncNewLove.countFinalAttrForShow( _type,dataArr )
    if type(dataArr) == "number" then
        echo("______ 战力 dataArr_________",dataArr)
        return dataArr
    end

    local showDataArr = {}
    showDataArr.type = _type
    showDataArr.value = {}
    if dataArr and table.length(dataArr) > 0 then
        for k,v in pairs(dataArr) do
            if not showDataArr.value[v.key] then
                showDataArr.value[v.key] = {}
            end
            if not showDataArr.value[v.key][v.mode] then
                showDataArr.value[v.key][v.mode] = 0
            end
            showDataArr.value[v.key][v.mode] = showDataArr.value[v.key][v.mode] + v.value
        end
    end
    -- dump(showDataArr, "showDataArr")
    return showDataArr
end

--根据情缘id和等级获取当前情缘数据
function FuncNewLove.getLoveDataByLoveIdAndLevel(loveId, level)
    local loveData = config_LoveLv[tostring(loveId)]
    if  not loveData then
        echoError("loveData not config, loveId==", loveId)
        return 
    end

    local data_for_level = loveData[tostring(level)]
    if not data_for_level then
        echoError("loveData for level not config, level===", level)
        return 
    end

    return data_for_level
end

--根据loveId和目标等级获得升阶需要的好感值 
function FuncNewLove.getDispositionByLoveIdAndLevel(loveId, targetLevel)
    if targetLevel <= 1 or targetLevel > FuncNewLove.maxLevel then
        echoError("\n\ntargetLevel  error", targetLevel)
        return 
    end

    local data_for_level = FuncNewLove.getLoveDataByLoveIdAndLevel(loveId, targetLevel)
    local disposition = data_for_level.disposition
    if not disposition then
        echoError("This loveId do not config disposition, loveId ==", loveId, "targetLevel==", targetLevel)
    end
    return disposition
end

--根据loveId和目标等级获得开启的任务链的任务数量
function FuncNewLove.getTaskNumByLoveIdAndLevel(loveId, targetLevel)
    if targetLevel <= 1 or targetLevel > FuncNewLove.maxLevel then
        echoError("\n\ntargetLevel  error", targetLevel)
        return 
    end

    local data_for_level = FuncNewLove.getLoveDataByLoveIdAndLevel(loveId, targetLevel)
    local taskNum = data_for_level.count
    if not taskNum then
        echoError("This loveId do not config count(taskNum), loveId ==", loveId, "targetLevel==", targetLevel)
    end
    return taskNum
end

--根据loveId和目标等级获得开启的任务链的全部完成后情缘提升奖励
function FuncNewLove.getChainRewardByLoveIdAndLevel(loveId, targetLevel)
    if targetLevel <= 1 or targetLevel > FuncNewLove.maxLevel then
        echoError("\n\ntargetLevel  error", targetLevel)
        return 
    end

    local data_for_level = FuncNewLove.getLoveDataByLoveIdAndLevel(loveId, targetLevel)
    local chainReward = data_for_level.randomRingReward
    local newRewards = {}
    if not chainReward then
        echoError("This loveId do not config ringaward, loveId ==", loveId, "targetLevel==", targetLevel)
    else
        for i,v in ipairs(chainReward) do
            local str_table = string.split(v, ",")
            local reward = FuncItem.getRewardData(str_table[2]).info
            for ii,vv in ipairs(reward) do
                local newReward_table = string.split(vv, ",")
                local newReward = nil
                if #newReward_table == 4 then
                    newReward = string.format("%s,%s", newReward_table[2], newReward_table[3])
                elseif #newReward_table == 5 then
                    newReward = string.format("%s,%s,%s", newReward_table[2], newReward_table[3], newReward_table[4])
                end
                table.insert(newRewards, newReward)
            end           
        end
    end
    return newRewards
end
