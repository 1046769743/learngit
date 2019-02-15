-- zq


FuncPartnerEquipAwake = FuncPartnerEquipAwake or {}

local partnerEquipAwake = nil

function FuncPartnerEquipAwake.init()
   partnerEquipAwake = Tool:configRequire("partner.PartnerEquipmentAwake") -- 

end

function FuncPartnerEquipAwake.getEquipDataById( id )
    local data = partnerEquipAwake[tostring(id)]
    if not data then
        echoError("PartnerEquipmentAwake 表中没有id === ",id)
        return nil
    end
    return data
end
function FuncPartnerEquipAwake.getEquipDataByIdandKey( id,key )
    local data = FuncPartnerEquipAwake.getEquipDataById( id )
    if not data then
        return nil
    end
    local value = data[key]
    if not value then
        echoError("PartnerEquipmentAwake 表中id === ",id," 没有key == ",key)
        return nil
    end
    return value
end

function FuncPartnerEquipAwake.getEquipAwakeName( id )
    echo("觉醒name====",id)
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"name" )
end
function FuncPartnerEquipAwake.getEquipAwakeIcon( id )
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"icon" )
end

function FuncPartnerEquipAwake.getEquipAwakeUnlockTy( id )
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"unLockType" )
end
-- function FuncPartnerEquipAwake.getEquipAwakeShowLevel( id )
--     local showLevel = FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"showLv" )
--     return showLevel[1].key
-- end
function FuncPartnerEquipAwake.getEquipAwakeCost( id )
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"cost" )
end
function FuncPartnerEquipAwake.getEquipAwakeAttr( id )
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"addAttr" )
end
function FuncPartnerEquipAwake.getEquipAwakeAbility( id )
    return FuncPartnerEquipAwake.getEquipDataByIdandKey( id,"addAbility" )
end

-- 奇侠装备觉醒带来的属性值
function FuncPartnerEquipAwake.getAwakeAttrValue(equipId,key,_attr)
    echo("觉醒id=== ",equipId,key)
    local attrT = FuncPartnerEquipAwake.getEquipAwakeAttr( equipId )
    local T = {}
    for i,v in pairs(attrT) do
        if tonumber(key) == tonumber(v.key) then
            table.insert(T,{v})
        end
    end
    if _attr then
        table.insert(T,{_attr})
    end
    -- dump(T, "----cccccccc-----", 5)
    local sx = FuncBattleBase.countFinalAttr(unpack(T))
    sx = FuncBattleBase.formatAttribute( sx )
    if sx and sx[1] then
        local value = sx[1].value
        if _attr then
            value = value - _attr.value
            if value == 0 then
                return nil
            end
            return value
        else
            return value
        end
        
    end
    return nil

end

-- 获得伙伴装备技能加成
function FuncPartnerEquipAwake.getEquipsAttrById( _partnerInfo,equipId,add )
    local dataMap = {}
    if _partnerInfo.equips then
        for _key1,_value1 in pairs(_partnerInfo.equips) do
            if tostring(_value1.id) == tostring(equipId) then
                local equCfgData = FuncPartner.getEquipmentById(_value1.id)
                equCfgData = equCfgData[tostring(_value1.level)]
                local da = equCfgData.subAttr or equCfgData.subAttrPlus; -- 表中标注是 替换关系
                for _key2,_value2 in pairs(da)do 
                    local _data = {
                        key = _value2.key,
                        value = _value2.value,
                        mode = _value2.mode,
                    }
                    table.insert(dataMap,{_data}) 
                end

                if add then
                    -- 装备带来的属性
                    local awakeEquipId = FuncPartner.getAwakeEquipIdByid( _partnerInfo.id,_value1.id )
                    echo("觉醒的装备id==== ",awakeEquipId)
                    local shuxing = FuncPartnerEquipAwake.getEquipAwakeAttr( awakeEquipId )
                    for _key2,_value2 in pairs(shuxing)do 
                        local _data = {
                            key = _value2.key,
                            value = _value2.value,
                            mode = _value2.mode,
                        }
                        table.insert(dataMap,{_data}) 
                    end
                end
            end
        end
    end
    local attr = FuncBattleBase.countFinalAttr(unpack( dataMap) )
    attr = FuncBattleBase.formatAttribute( attr )
    return attr
end
function FuncPartnerEquipAwake.getAwakeEquipsAttrById(_partnerId,equipId)
    local dataMap = {}
    local awakeEquipId = FuncPartner.getAwakeEquipIdByid(_partnerId, equipId)
    echo("觉醒的装备id==== ",awakeEquipId)
    local shuxing = FuncPartnerEquipAwake.getEquipAwakeAttr( awakeEquipId )
    for _key2,_value2 in pairs(shuxing)do 
        local _data = {
            key = _value2.key,
            value = _value2.value,
            mode = _value2.mode,
        }
        table.insert(dataMap,{_data}) 
    end
    local attr = FuncBattleBase.countFinalAttr(unpack( dataMap) )
    return attr
end
--获取加成描述文字 例如：6,10 攻击力+10
function FuncPartnerEquipAwake.getDesStaheTable(des)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName..": "..des.value
    return str
end

function FuncPartnerEquipAwake.getNameAndValueStaheTable(des)
    if des == nil then
        return ""
    end
    local buteData = FuncChar.getAttributeData()
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    return buteName,des.value
end