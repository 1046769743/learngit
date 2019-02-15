
--guan 
--2016.4.20

FuncBattleBase = FuncBattleBase or {}

local battleBase = nil
local SkillData = nil
local AttackData = nil
local BuffData = nil
local attributeData = nil
local treasureData = nil
-- local attrConfigData = nil

function FuncBattleBase.init()
	-- battleBase = Tool:configRequire("battle.BattleBase");
    SkillData   = Tool:configRequire("battle.Skill")
    treasureData   = Tool:configRequire("level.EnemyTreasure")
    AttackData  = Tool:configRequire("battle.Attack")
    BuffData    = Tool:configRequire("battle.Buff")
    attributeData = Tool:configRequire("common.AttributeConvert")
    -- attrConfigData = Tool:configRequire("common.Battleconfig")
end



-- 获取技能信息
function FuncBattleBase.getSkillCfg( id )
    local valueRow = SkillData[tostring(id)];
    if valueRow == nil then 
        echo("error: FuncBattleBase.getValue id " .. 
            tostring(id) .. " is nil;");
        return nil;
    end
    return valueRow
end

-- 读取技能表中的字段数据
function FuncBattleBase.getValueByKS(id, key)
    local valueRow = SkillData[tostring(id)];
    if valueRow == nil then 
        echo("error: FuncBattleBase.getValue id " .. 
            tostring(id) .. " is nil;");
        return nil;
    end 

    local value = valueRow[tostring(key)];
    if value == nil then 
        echo("error: FuncBattleBase.getValue key " .. 
            tostring(key) .. " is nil");
    end 
    return value;
end

-- 特殊技能的显示数据
-- function FuncBattleBase.getAttrConfigData( key )
--     if not key then
--         return nil
--     end
--     return attrConfigData[key]
-- end


------------------------创建战斗数据相关----------------------------------------


--属性映射表  右边的属性是 系统需要的属性 左边的是 战斗需要的属性
local propMapObj = {
    ["atk"]         = "atk", 
    ["crit"]        = "crit",
    ["critR"]       = "critR",
    ["def"]         = "def",
    ["dodge"]       = "dodge",
    ["energy"]      = "energy",
    ["maxenergy"]   = "maxenergy",
    ["hit"]         = "hit",
    ["maxhp"]       = "maxhp",
    
    ["reflect"]     = "reflect",--buf 产生          
    ["resist"]      = "resist",    
    ["vampire"]     = "vampire",--buf 产生
}

--[[
    每一个属性 是一个数组,里面分数值加成和百分比加成 ,
    数值是num, 百分比是per 
    {
        atk = {num = 100,per = 10 },
        crit = {num = 100,per = 10 },
        ...
    }

]]

--增加属性  obj 战斗属性obj, data 某模块增加的属性
local addObjDatas = function ( obj,data )
    if not data then
        error("message")
    end
    data = numEncrypt:decodeObject(data)

    local num0 = numEncrypt:getNum0()

    for i,v in pairs(propMapObj) do
        local propInfo = obj[i]
        local value = data[i]
        if value then
            if type(value) == "number" or type(value) =="string" then
                propInfo.num = propInfo.num + numEncrypt:getNum(value)
            else
                if value.num then
                    propInfo.num = propInfo.num + value.num
                end
                if value.per then
                    propInfo.per = propInfo.per + value.per
                end
            end
        end   
    end
end

--初始化基础属性
function FuncBattleBase.initProp(obj)
    local num0 = numEncrypt:getNum0()
    for k,v in pairs(propMapObj) do
        obj[k] = {num =num0,per = num0}
    end
end


--计算等级属性加成
function FuncBattleBase.countLvProp( obj,lv )
    local data = FuncChar.getCharBaseData(lv)

    addObjDatas(obj,data)
end

--计算pointAtt属性加成
function FuncBattleBase.countPointAttProp(obj, hid ,level  )
     --获取对应pointAtt的数据
    local data = FuncChar.getOriginPointAttData()[tostring(hid)]

    --如果没有data
    if not data then
        echo("hid:"..hid,"level:"..level,"没有数据 pointAtt数据1111")
        return
    end

    data = data[tostring(level)]

    --如果没有data
    if not data then
        echo("hid:"..hid,"level:"..level,"没有数据 pointAtt数据")
        return
    end
    addObjDatas(obj,data)
end

--计算pointAtt属性加成
--计算pointAtt属性加成
function FuncBattleBase.countAdvPointAttProp(obj, advId  )
     --获取对应pointAtt的数据

    local num0 = numEncrypt:getNum0()

    --如果是0 那么不添加
    if advId == 0 then
        return
    end

    --获取advId
    local data = FuncChar.getOriginAdvPointAttData()[tostring(advId)]
    if not data then
        echoError("没有对应的advPointData:advid:"..advId)
        return
    end
    addObjDatas(obj,data)
end



function FuncBattleBase.getRobotData( serverData )
    local obj = {
        lv = { num = serverData.lv or numEncrypt:getNum1() }
    }
    local num0 = numEncrypt:getNum0()

    for k,v in pairs(propMapObj) do
        if serverData[v] then
            obj[k] = {num =serverData[v]}
        else
            obj[k] = {num = num0}
        end
    end
    obj.critR.num = obj.critR.num + FuncDataSetting.getDataByConstantName("BattleCritRadio")
    return obj
end




--获取英雄详细数据 这个不是战斗数据所以不需要进行数据转化 和不加密  serverData不传的话表示获取 自己的详细数据,否则是获取 其他玩家的数据
function FuncBattleBase.getUserDetailData( serverData )
    --先解密数据
    local data = numEncrypt:decodeObject(serverData)

    local obj = {
        lv ={num =  data.level or numEncrypt:getNum1() }
    }

    --初始化基础属性
    FuncBattleBase.initProp(obj)
    
    --计算等级属性加成
    FuncBattleBase.countLvProp(obj,data.level)

    --这里暴击需要单独算一下
    obj.critR.num = obj.critR.num + FuncDataSetting.getDataByConstantName("BattleCritRadio")
 
    return obj
end

-- 本命法宝
function FuncBattleBase.anaTreasureNatal(treaNatal,subsystemLabel)
    if not treaNatal then
        return nil
    end
    --dump(data,subsystemLabel)
    local key = nil
    for k,v in pairs(GameVars.battleLabels) do
        if v == subsystemLabel then
            key = k
        end
    end

    if(subsystemLabel=="pvp" and type(treaNatal)~="table")then
          return   treaNatal;
    end
    for k,v in pairs(treaNatal) do
        if k == GameVars.sysLabelToTreaNatal[key] then
            return v
        end
    end
    return nil
end


--根据服务器数据 创建战斗所需要的数据 格式  serverData,用户数据,  treasures法宝数据
function FuncBattleBase.createBattleData( serverData ,treasures,subsystemLabel)
	local turnData
    if serverData.userBattleType == Fight.people_type_robot then
        turnData = FuncBattleBase.getRobotData(serverData)
    else
        turnData = FuncBattleBase.getUserDetailData(serverData)
    end

    local num0 = numEncrypt:getNum0()
    local num1 = numEncrypt:getNum1()
    local obj = {}
    --这里要把属性进行转化
    --先把基础属性添加 ,在按照百分比添加
    for k,v in pairs(turnData) do
        obj[k] = v.num
    end
    for i,v in ipairs(turnData) do
        obj[k] = obj[k]*(num1+v.per)
    end

    obj.hp = obj.maxhp
    obj.sec = serverData.sec
    obj.rid = serverData._id
    -- obj.lv = serverData.level
    obj.hid = serverData.hid
    obj.camp = serverData.team
    obj.name = serverData.name or "未命名" --这个必须有
    obj.avatar = serverData.avatar
    obj.enterBattleFrame = serverData.enterBattleFrame or 0 -- 进入战斗的时刻
    obj.peopleType = serverData.userBattleType --人物的类型
    obj.ability = serverData.abilityNew or obj.atk -- 战力
    --称号相关
    if serverData.titleId then
        obj.titleId = serverData.titleId -- 称号
    end

    obj.moveSpd = FuncDataSetting.getDataByConstantName("BattleCharMoveSpeed")
    obj.hitTrigger = FuncDataSetting.getDataByConstantName("BattleHitActionHp") 
    obj.viewScale = 100

    -- 本命法宝
    -- echo("____________________________jisuan",serverData.hid)
    -- dump(serverData.treasureNatal)
    local treaNatal = FuncBattleBase.anaTreasureNatal(serverData.treasureNatal,subsystemLabel)

    obj.treasures = {}

    local igoneArr = {  
                        -- "302","303","304","307","308",
                        -- "309","314","319","320","321",
                        -- "401","402","403","404","406",
                        -- "407","409","410","413","414",
                        -- "501","502","504","505","506",
                        -- "509","601","602","603","301",
                        -- "306",
                        -- "305","310","302","307",
                        }

    for k,v in pairs(treasures) do
        local tmp = {}
        
        tmp.hid = k 
        tmp.state = v.state
        tmp.star = v.star
        tmp.strengthen = v.level
        if not v.treaType then
            tmp.treaType = Fight.treaType_normal
        else
            tmp.treaType = v.treaType
        end

        if treaNatal == k then
            obj.treasureNatal = clone(tmp)
            obj.treasureNatal.treaType = "natal"
        end
        if table.indexof(igoneArr, tostring(k)) then
        else
             table.insert(obj.treasures,tmp)
        end
        
    end
    return obj
end


function FuncBattleBase.getBuffTypeByHid( hid )
    local buffData = Tool:configRequire("battle.Buff")
    local info = buffData[hid]
    if not info then
        echoError(hid .."_没有相关buff信息")
        return 1
    end
    return  info.type
end


--获取属性描述数据
function FuncBattleBase.getAttributeData( key )
    local data = attributeData[tostring(key) ]
    if not data then
        echoError("这个属性key没有:",key)
        return {}
    end
    return data
end

--获取属性的名字
function FuncBattleBase.getAttributeName( key )
    local data = FuncBattleBase.getAttributeData(key)
    return GameConfig.getLanguage(data.name)
end

--获取属性的显示顺序
function FuncBattleBase.getAttributeOrder( key )
    local data = FuncBattleBase.getAttributeData(key)
    return data.order
end


--传递进来的数  attrGroup1 = { {key = 1,value =2,mode = 1},...       }  
--传递进来的数  attrGroup2 = { {key = 1,value =2,mode = 1},...       }  ...
--可以传递进来N个 属性加成数组
--计算最终属性值 多个模块的属性加成 然后 合并计算 返回 
--{  {key:1,value:1,} ,...          } 这样的结构 
function FuncBattleBase.countFinalAttr(attrGroup1,attrGroup2,... )
    local attrDataMap = {} 
    --[[
        {
            key1:    { 
                    mode1:     {value1,value2,...}    ,     基础值部分
                    mode2:     {value1,value2,...}    ,   万分比部分 所有的值 最后还要加上1   
                    mode3:     {value1,value2,...}    ,  常量部分
                    mode4:     {value1,value2,...}    ,   成长系数部分 所有的值最后还要加上1 

            }
        }
    ]]

    local allGroups  = {attrGroup1,attrGroup2,...}
    -- dump(allGroups,"传进来的数据好好好")
    for i,v in pairs(allGroups) do
        for ii,vv in ipairs(v) do
            local key = vv.key
            local value = vv.value
            local mode = vv.mode
            if not attrDataMap[vv.key] then
                attrDataMap[key] = {
                    [1] = 0,
                    [2] = 10000,
                    [3] = 0,
                    [4] = 10000,
                    [5] = 0,
                    [6] = 10000,
                }
            end
            local data = attrDataMap[key]
            --加上这个属性
            data[mode] = data[mode] + value
            -- echo("\n key ===",key)
            -- dump(data,"类加数据——————")
            -- dump(attrDataMap[key],"类加数据 attrDataMap———— ")
        end
    end
    local resultInfo = {}
    for k,v in pairs(attrDataMap) do
        local data = {key = k}
        data.value = math.floor((v[1] *v[2] + v[3] * 10000 + v[5] * v[6] ) * v[4]/10000/10000)

        -- local str = "key = "..k.."；基础值 = "..v[1].."；万分比部分 = "..v[2]
        -- str = str.."；固定值部分 = "..v[3].."；成长系数部分 = "..v[4]
        -- str = str.."；计算结果 = "..data.value
        -- echo("\n\n 伙伴总属性计算 ========== ",str)
        
        -- dump(v,"v数据")
        -- dump(data,"单挑数据")
        table.insert(resultInfo, data)
    end

    -- dump(resultInfo,"计算结果哈哈哈哈",5)
    return resultInfo

end


--根据法宝id 获取对应的sourceId
function FuncBattleBase.getSourceByTreasureId( treasureId )
    local data = treasureData[treasureId]
    if not data then
        echoError("__没有找到对应的source,treasureId:%s,暂时用主角素颜代替",treasureId)
        for k,v in pairs(treasureData) do
            data = v
            break
        end
    end
    return data.source
end



--对一组属性排序 {  {key:1,value:2},...       }
-- 格式化战斗属性，加入属性名称及排序及删除不显示的属性
function FuncBattleBase.formatAttribute( attrInfoArr )
    local attrDatas = {}
    for k,v in pairs(attrInfoArr) do
        local attrData =  FuncBattleBase.getAttributeData(v.key)
        local attrName = FuncBattleBase.getAttributeName(v.key)
        local attrOrderId = attrData.order

        local info = {}
        info.name = attrName
        info.value = FuncBattleBase.getFormatFightAttrValue(v.key,v.value)
        info.attrOrderId = attrOrderId
        info.mode = v.mode
        info.key = v.key
        -- 小于0的属性不显示
        if info.attrOrderId > 0 then
            attrDatas[#attrDatas+1] = info 
        end
    end

    table.sort(attrDatas , function(a,b) 
        if a.attrOrderId < b.attrOrderId then
            return true
        end
    end)

    return attrDatas

end


-- 获取格式化的战斗属性值 比如 是免伤率  attrValue 传进来的是500 那就 返回 5%  如果是 攻击力 返回500
function FuncBattleBase.getFormatFightAttrValue(key,attrValue)
    local newAttrValue = attrValue
    local attrData = FuncBattleBase.getAttributeData(key)
    -- dump(attrData, "\n\nattrData======")
    local attrKeyName = attrData.keyName
    local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_buffHit,
        Fight.value_buffResist
    }

    -- echo("\n\nattrKeyName=====", attrKeyName, "newAttrValue====", newAttrValue)
    --判断哪些是百分比属性
    if table.indexof(percentKeyArr, attrKeyName) then
        newAttrValue = (newAttrValue /100)
        -- 百分比的保留2位小数
        newAttrValue = newAttrValue * 1.00
        if newAttrValue >= 0 then
            newAttrValue = string.format("%0.1f", newAttrValue) 
        end
        
        newAttrValue = newAttrValue .. "%"
    else
        -- 非百分比舍弃小数部分
        newAttrValue = newAttrValue * 1.00
        newAttrValue = string.format("%0.0f", newAttrValue) 
    end

    return newAttrValue
end


-- 锁妖塔专用
-- 根据mode格式化属性名字
-- mode为2 或者带"率"的属性 都显示百分比形式
function FuncBattleBase.getFormatFightAttrValueByMode(key,attrValue,attrMode)
    local newAttrValue = attrValue
    local attrData = FuncBattleBase.getAttributeData(key)
    local attrKeyName = attrData.keyName

    local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
        Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist
    }

    --判断哪些是百分比属性
    if attrMode == 2 or table.indexof(percentKeyArr, attrKeyName) then
        newAttrValue = (newAttrValue /100)
        -- 百分比的保留2位小数
        newAttrValue = newAttrValue * 1.00
        if newAttrValue >= 0 then
            newAttrValue = string.format("%0.2f", newAttrValue) 
            local arr = string.split(newAttrValue,".")
            if arr[2] == "00" then
                newAttrValue = arr[1]
            end
        end
        
        newAttrValue = newAttrValue .. "%"
    else
        -- 非百分比舍弃小数部分
        newAttrValue = newAttrValue * 1.00
        newAttrValue = string.format("%0.0f", newAttrValue) 
    end

    return newAttrValue
end


--判断一个属性是基础属性还是高级属性 返回1 是基础属性 2是高级属性
function FuncBattleBase:getOneKeyProp( keyInt )
    keyInt =toint(keyInt)
    if keyInt == 2 or keyInt==10 or keyInt ==11 or keyInt ==12 then
        return 1
    end
    return 2

end