FuncMemoryCard= FuncMemoryCard or {}

FuncMemoryCard.TARGET_TYPE = {
    ZHUJUE = 0,  -- 主角
    GONGJI = 1,  -- 攻击类奇侠
    FANGYU = 2,  -- 防御类奇侠
    FUZHU = 3,   -- 辅助类奇侠
}
FuncMemoryCard.CHIP_LIGHT = {
    LIGHT = "LIGHT",
    NO_LIGHT = "NO_LIGHT",
}

local config_memory = nil
local config_memoryCard = nil

function FuncMemoryCard.init()
	config_memory = Tool:configRequire("memory.Memory")
    config_memoryCard = Tool:configRequire("memory.MemoryCard")
	
end
-- 情景卡系列数据
function FuncMemoryCard.getMemoryData()
	return config_memory
end

-- 通过id 获取情景卡系列数据
function FuncMemoryCard.getMemoryDataById(id)
    if not id then
        echoError("FuncMemoryCard 传入的id是 nil")
        return
    end
    local data = config_memory[id]
    if not data then
        echoError("config_memory 表中没有 此id == ",id)
        return
    end
    return data
end
-- 系列带来的战力
function FuncMemoryCard.getMemoryPowerById( id )
    local data = FuncMemoryCard.getMemoryDataById(id)
    return data.addAbility -- 战力 还要找张超确认
end
-- 情景卡带来的战力
function FuncMemoryCard.getMemoryCardPowerById( id )
    local data = FuncMemoryCard.getMemoryCardDataById(id)
    return data.addAbility -- 战力 还要找张超确认
end
-- 系列带来的属性
function FuncMemoryCard.getMemoryAttrById( id )
    local data = FuncMemoryCard.getMemoryDataById(id)
    local attrT = FuncBattleBase.formatAttribute( data.initAttr )
    return attrT
end
-- 情景卡带来的属性
function FuncMemoryCard.getCardAttrById( id )
    local data = FuncMemoryCard.getMemoryCardDataById(id)
    local attrT = FuncBattleBase.formatAttribute( data.initAttr )
    return attrT
end

-- 情景卡系统 给奇侠带来的属性
function FuncMemoryCard.getAttrByPartnerId( partnerId ,memory )
    if not memory then
        return {}
    end

    local attr = {}
    attr["0"] = {}
    attr["1"] = {}
    attr["2"] = {}
    attr["3"] = {}
    -- 点亮的系列
    local T1 = {}
    local data = FuncMemoryCard.getMemoryData()
    for i,v in pairs(data) do
        local cards = v.pictureId
        local isFinish = true
        for ii,vv in pairs(cards) do
            if not memory[vv] then
                isFinish = false
                break
            end
        end
        if isFinish then
            table.insert(T1,v)
        end
    end
    
    for i,v in pairs(T1) do
        local id = v.id
        local data = FuncMemoryCard.getMemoryDataById(id)
        local targets = data.target
        for m,n in pairs(targets) do
            for key,value in pairs(data.initAttr) do
               table.insert(attr[n],value)
            end
        end
    end
    -- 激活的情景卡带来的属性
    for i,v in pairs(memory) do
        local cardData = FuncMemoryCard.getMemoryCardDataById(i)
        local targets = cardData.target
        for m,n in pairs(targets) do
            for key,value in pairs(cardData.initAttr) do
               table.insert(attr[n],value)
            end
        end
    end
    local partnerAttr = {}
    if FuncPartner.isChar(partnerId) then
        partnerAttr = attr[tostring(0)]
    else
        local partnerData = FuncPartner.getPartnerById(partnerId)
        local _type = partnerData.type
        partnerAttr = attr[tostring(_type)]
    end
    return partnerAttr
end
-- 情景卡系统 给奇侠带来的战力
function FuncMemoryCard.getPowerByPartnerId( memory )
    if not memory then
        return 0
    end 
    -- dump(memory, "请经---- ", 5)

    local ability = 0
    -- 点亮的系列
    local T1 = {}
    local data = FuncMemoryCard.getMemoryData()
    for i,v in pairs(data) do
        local cards = v.pictureId
        local isFinish = true
        for ii,vv in pairs(cards) do
            if not memory[vv] then
                isFinish = false
                break
            end
        end
        if isFinish then
            table.insert(T1,v)
        end
    end
    
    for i,v in pairs(T1) do
        local id = v.id
        local data = FuncMemoryCard.getMemoryDataById(id)
        ability = ability + data.addAbility
    end
    -- 激活的情景卡带来的属性
    for i,v in pairs(memory) do
        local cardData = FuncMemoryCard.getMemoryCardDataById(i)
        ability = ability + cardData.addAbility     
    end
    return ability
end

-- 加成类型描述
function FuncMemoryCard.getTypeDes( id )
    local data = FuncMemoryCard.getMemoryDataById(id)
    -- 先强行只取第一个
    return  FuncMemoryCard.getTypeDesByTarget( data.target[1] )
end
function FuncMemoryCard.getCardTypeDes( id )
    local data = FuncMemoryCard.getMemoryCardDataById(id)
    -- 先强行只取第一个
    return  FuncMemoryCard.getTypeDesByTarget( data.target[1] )
end
function FuncMemoryCard.getTypeDesByTarget(target)
    local target = tonumber(target) 
    if FuncMemoryCard.TARGET_TYPE.ZHUJUE == target then
        return GameConfig.getLanguage("#tid_memory_target_0") 
    elseif FuncMemoryCard.TARGET_TYPE.GONGJI == target then
        return GameConfig.getLanguage("#tid_memory_target_1") 
    elseif FuncMemoryCard.TARGET_TYPE.FANGYU == target then
        return GameConfig.getLanguage("#tid_memory_target_2") 
    elseif FuncMemoryCard.TARGET_TYPE.FUZHU == target then
        return GameConfig.getLanguage("#tid_memory_target_3") 
    end
end
function FuncMemoryCard.getTypeFrame( target )
    local target = tonumber(target) 
    if FuncMemoryCard.TARGET_TYPE.ZHUJUE == target then
        return 4 
    elseif FuncMemoryCard.TARGET_TYPE.GONGJI == target then
        return 1 
    elseif FuncMemoryCard.TARGET_TYPE.FANGYU == target then
        return 2
    elseif FuncMemoryCard.TARGET_TYPE.FUZHU == target then
        return 3
    end
end

-- 情景卡数据
function FuncMemoryCard.getMemoryCardData( )
    return config_memoryCard
end

-- 通过id 获取情景卡数据
function FuncMemoryCard.getMemoryCardDataById(id)
    if not id then
        echoError("FuncMemoryCard 传入的id是 nil")
        return
    end
    local data = config_memoryCard[id]
    if not data then
        echoError("config_memoryCard 表中没有 此id == ",id)
        return
    end
    return data
end

--获取碎片是否点亮
function FuncMemoryCard.getChipLightState(chipId)
    local key = "memoryChip__"..chipId;
    local value = LS:prv():get(key,FuncMemoryCard.CHIP_LIGHT.NO_LIGHT);
    if value == FuncMemoryCard.CHIP_LIGHT.LIGHT then
        return true
    end
    return  false
end
--设置伙伴是否显示小红点
function FuncMemoryCard.setChipLightState(chipId,isShow)
    local key = "memoryChip__"..chipId;
    if isShow == true then
        LS:prv():set(key,FuncMemoryCard.CHIP_LIGHT.LIGHT) 
    else
        LS:prv():set(key,FuncMemoryCard.CHIP_LIGHT.NO_LIGHT) 
    end
end


function FuncMemoryCard.getAttrDes( _attr,_key )
    local str1 = ""
    local str2 = ""
    for i,v in pairs(_attr) do
        if tostring(v.key) == tostring(_key) then
            if v.mode == 3 then
                str1 = v.name .. " +"..v.value
            end
            if v.mode == 2 then
                str2 = v.name .. " +".. (v.value/100) .. "%"
            end
        end
    end
    if str1 == "" then
        local name = FuncBattleBase.getAttributeName(tostring(_key))
        str1 = name .. " +0"
    end
    if str2 ~= "" then
        return str1.."  "..str2
    end
    return str1
end


function FuncMemoryCard.getMethodString( _id )
    local cardData = FuncMemoryCard.getMemoryCardDataById(_id)
    if not cardData.getMethod  then
        echoError("_cardid:" ..tostring(_id),"没有配置getMethod")
        return  _id
    end
    return GameConfig.getLanguage(cardData.getMethod)
end