--[[
    Author: caocheng
    Date:2017-10-31
    Description: 五灵养成func
]]

FuncWuLing= FuncWuLing or {}

local FiveSoulInfo = nil
local FiveSoulLevel = nil

FuncWuLing.CHOOSE_TYPE = {
    MatrixMethod = 6,
}

FuncWuLing.FIVE_TYPE = {
    FENG = 1,
    LEI = 2,
    SHUI = 3,
    HUO = 4,
    TU = 5,
}

FuncWuLing.ANIM_NAME = {
    [1] = "UI_wulingchuzhan_feng",
    [2] = "UI_wulingchuzhan_lei",
    [3] = "UI_wulingchuzhan_shui",
    [4] = "UI_wulingchuzhan_huo",
    [5] = "UI_wulingchuzhan_tu",
}

function FuncWuLing.init() 
    FiveSoulInfo = Tool:configRequire("fivesoul.FiveSoulInfo")
    FiveSoulLevel = Tool:configRequire("fivesoul.FiveSoulLevel")
end    

function FuncWuLing.getFiveSoulMatrixMethodByLevel(level)
    local tempMatrixMethod = FiveSoulLevel[tostring(level)]
    return tempMatrixMethod
end

function FuncWuLing.getFiveSoulSpirit(id)
    local tempDetail = {}
    for k,v in pairs(FiveSoulInfo) do 
        if tostring(k) == tostring(id) then
            for n,m in pairs(v) do
                table.insert(tempDetail,m)
            end
        end
    end
   
    table.sort(tempDetail,function (a,b)
        return a.lv < b.lv
    end)
    return tempDetail
end

function FuncWuLing.getFiveSoulInfoByLevel(id,level)
    local tempAbility = 0
    for k,v in pairs(FiveSoulInfo) do 
        if tostring(k) == tostring(id) then
            for n,m in pairs(v) do
                if tonumber(level) == tonumber(m.lv) then
                    tempAbility = m.addAbility
                end
            end
        end
    end
    return tempAbility
end
function FuncWuLing.getFiveSoulPromoteAbilityLevel(id,level)
    local tempAbility = 0
    for k,v in pairs(FiveSoulInfo) do 
        if tostring(k) == tostring(id) then 
            for n,m in pairs(v) do
                if tonumber(level) >= tonumber(m.lv) then
                    tempAbility = tempAbility + m.promoteAbility
                end
            end
        end
    end
    return tempAbility
end

-- 获取当前五灵对应的布阵加成
function FuncWuLing.getWuLingZhenForBattle(wulingData)
    local wuxingT = {}
    for k,v in pairs(wulingData) do
        local data = FuncWuLing.getWuLingChange(tonumber(k),tonumber(v))
        wuxingT[tonumber(k)] = data
    end
    -- dump(wuxingT, "-----wuling---------", 4)
    return wuxingT
end
-- 根据五灵属性和等级获取对应的五行技能强化等级、属性防御力
function FuncWuLing.getWuLingChange( id,level )
    local addLevel = 0
    local kang = 0
    for i=1,level do
        local dataCfg = FiveSoulInfo[tostring(id)][tostring(i)]
        addLevel = addLevel + dataCfg.skill
        kang = kang + dataCfg.fastness
    end
    local data = {}
    data.element = tonumber(id) -- 五行属性
    data.exDef = kang -- 技能强化等级，便于扩展
    data.exLv = addLevel -- 属性防御力，便于扩展
    return data
end

--废弃
-- function FuncWuLing.getWuLingCoin(level)
--     local tempMatrixMethod = FiveSoulLevel[tostring(level)]
--     if tempMatrixMethod then
--         if tempMatrixMethod.cost then
--             return tempMatrixMethod.cost
--         else
--             return 0
--         end    
--     else
--         echo("五灵法阵没有配这个等级"..level)
--     end
-- end

--废弃
-- function FuncWuLing.getWuLingPoint(id,level)
--     for k,v in pairs(FiveSoulInfo) do 
--         if tostring(k) == tostring(id) then
--             for n,m in pairs(v) do
--                 if tonumber(level) == tonumber(m.lv) then
--                     if m.cost then
--                         return m.cost
--                     else
--                         return 0
--                     end    
--                 end
--             end
--         end
--     end
-- end

function FuncWuLing.getCostByIdAndLevel(id, level)
    for k,v in pairs(FiveSoulInfo) do 
        if tostring(k) == tostring(id) then
            for n,m in pairs(v) do
                if tonumber(level) == tonumber(m.lv) then
                    if m.cost then
                        return m.cost
                    end    
                end
            end
        end
    end  
    return nil  
end
