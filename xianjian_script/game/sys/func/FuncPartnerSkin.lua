--//伙伴皮肤系统
-- 2017.5.12 11:00
-- zq


FuncPartnerSkin = FuncPartnerSkin or {}


local partner_Skin_table = nil  
local partnerSkinT = nil
--皮肤状态 1穿戴中 2穿戴 3购买 4限时 5预售 6解锁 7活动获取
FuncPartnerSkin.SKIN_ZT = {
    ON = 1,
    NOT_ON = 2,
    BUY = 3,
    TIME = 4,
    YUSHOU = 5,
    JIESUO = 6,
    HUOQU = 7,
}
function FuncPartnerSkin.init()
   partner_Skin_table = Tool:configRequire("partnerskin.PartnerSkin") -- 

end

--获取伙伴皮肤
function FuncPartnerSkin.getPartnerSkinById( id)
  local   _data = partner_Skin_table[tostring(id)]
  if( not _data )then
    echo("Warning!!,id",_id," get null equipment")
  end
  return _data
end

function FuncPartnerSkin.getValueByKey( id,value)
    local t1 = partner_Skin_table[tostring(id)];
	if t1 == nil then 
		echo("FuncPartnerSkin.getValueByKey id not found " .. id);
		return nil;
	end 

	local t2 = t1[tostring(value)];
	if t2 == nil then 
		echo("FuncPartnerSkin.getValueByKey value not found " .. value);
		return nil;
	end 

	return t2;
end

function FuncPartnerSkin.getAllPartnerSkin( )
  return partner_Skin_table
end

-- 伙伴-皮肤 map
function FuncPartnerSkin.getPartnerSkinTable()
    if partnerSkinT then
        return partnerSkinT
    else
        local partnerSkinTable = {}
        for i,v in pairs(partner_Skin_table) do
            if partnerSkinTable[v.partnerId] then
                table.insert(partnerSkinTable[v.partnerId],v.id)
            else
                local skinT = {}
                table.insert(skinT,v.id)
                partnerSkinTable[v.partnerId] = skinT
            end
        end
        partnerSkinT = partnerSkinTable
        return partnerSkinT
    end
end

function FuncPartnerSkin.getValidPartnerSkins(id)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local validPartnerSkins = {}
    local partnerSkins = partnerSkinT[tostring(id)]
    if partnerSkins and table.length(partnerSkins) then
        for k,v in pairs(partnerSkins) do
            local skin = FuncPartnerSkin.getPartnerSkinById(v)
            if not ((skin.isOpen and skin.isOpen == "0") or (skin.type and skin.type == 1))  then
                table.insert(validPartnerSkins, v)               
            end
        end
    end
    return validPartnerSkins
end
-- 皮肤立绘
function FuncPartnerSkin.getPartnerSkinArtSp(id)
	local spName = FuncPartnerSkin.getValueByKey(id, "gramentImg");
    local sp = FuncRes.getArtSpineAni(spName)
	return sp;
end

function FuncPartnerSkin.getPartnerSkinBg(partnerId, skinId)
    if skinId == "" or not skinId then
        skinId = FuncPartnerSkin.getSuYanSkinId(partnerId)   
    end


    local bg = FuncPartnerSkin.getValueByKey(skinId, "grametBg")
    return bg
end

function FuncPartnerSkin.getPartnerSkinSourceId(id)
    local sourceID = FuncPartnerSkin.getValueByKey( id,"sourceID");
    return sourceID 
end
-- 通过皮肤ID 获得伙伴皮肤的spin 
function FuncPartnerSkin.getHeroSpine(id,iswhole,awakenWeapon)
    local sourceId =  FuncPartnerSkin.getPartnerSkinSourceId(id)
    local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
    local spineName = nil
    local spbName = nil
    if sourceCfg == nil then
        spbName = "30004_zhaolinger"
        echoError("_partnerId".." 此皮肤 伙伴立绘没找到")
    else
        spineName = sourceCfg.spine 
        spbName = spineName
    end
    local spineName = sourceCfg.spine 
    local spbName = spineName
    if not iswhole then
        spbName = spbName .. "Extract";
    end
    local charView = ViewSpine.new(spbName, {}, nil, spineName);
    charView.actionArr = sourceCfg
    charView:playLabel(charView.actionArr.stand, true);
    if awakenWeapon then
        charView:changeAttachmentByFrame(awakenWeapon)
    end
    return charView
end
function FuncPartnerSkin.getPartnerSkinTreasureId(id)
    local treasureId = FuncPartnerSkin.getValueByKey( id,"treasureId");
    return treasureId 
end
function FuncPartnerSkin.getPartnerSkinDonghua(id)
    local donghua = FuncPartnerSkin.getValueByKey( id,"sourceID");
    return donghua 
end

-- 伙伴皮肤战斗形象
function FuncPartnerSkin.getSpineViewByAvatarAndPartnerId( id)
    local soucreId = FuncPartnerSkin.getPartnerSkinDonghua(id);
    local sourceCfg = FuncTreasure.getSourceDataById(soucreId);
    local spineName = sourceCfg.spine;

    local partnerView = ViewSpine.new(spineName, {}, nil, spineName)
    partnerView.actionArr = sourceCfg;
    
    partnerView:playLabel(partnerView.actionArr.stand, true);

    return partnerView;
end
-- 故事 描述
function FuncPartnerSkin.getStoryStr(_id)
    local data = FuncPartnerSkin.getPartnerSkinById( _id)
    return GameConfig.getLanguage(data.desTranslate)
end
-- 伙伴名字
function FuncPartnerSkin.getPartnerName(_id)
    local data = FuncPartnerSkin.getPartnerSkinById( _id)
    local partnerData = FuncPartner.getPartnerById(data.partnerId)
    return GameConfig.getLanguage(partnerData.name)
end
-- 皮肤名字
function FuncPartnerSkin.getSkinName(_id)
    local data = FuncPartnerSkin.getPartnerSkinById( _id)
    return GameConfig.getLanguage(data.name)
end
-- 皮肤属性加成
function FuncPartnerSkin.getAttr(_id)
    local data = FuncPartnerSkin.getPartnerSkinById(_id)
    return data.attr;
end

function FuncPartnerSkin.getEnabledSkinAttr(_ownSkins)
    local enabledSkins = _ownSkins
    local enabledAttrs = {}
    if enabledSkins and table.length(enabledSkins) > 0 then
        for k,v in pairs(enabledSkins) do
            local attr = FuncPartnerSkin.getAttr(tostring(v))
            if atrr ~= nil then
                table.insert(enabledAttrs, attr)
            end       
        end
    end
    
    return enabledAttrs
end

function FuncPartnerSkin.getEnabledSkinsAddAbility(_ownSkins, _partnerId)
    -- dump(partner_Skin_table, "\npartner_Skin_table=====")
    local addedAbility = 0
    for k,v in pairs(_ownSkins) do
        if partner_Skin_table[tostring(k)].partnerId == tostring(_partnerId) then
            local ability = FuncPartnerSkin.getValueByKey(k,"addAbility")
            ability = ability or 0
            addedAbility = addedAbility + ability
        end
    end
    return addedAbility
end

--获取加成描述文字 例如：6,10 攻击力+10
function FuncPartnerSkin.getDesStahe(des)
    local buteData = FuncChar.getAttributeData()
    -- local attrName = FuncBattleBase.getAttributeName(v.key)
    local buteName = GameConfig.getLanguage(buteData[tostring(des.key)].name)
    local str = buteName.."+"
    dump(des,"pifu 属性加成")
    if tonumber(des.mode) == 2 then
        local value = tonumber(des.value)/100
        str = str .. value .."%"
    else
        str = str ..des.value
    end
    return str
end

-- 获取伙伴头像
function FuncPartnerSkin.getPartnerIcon(_id)
    local skinCfg = FuncPartnerSkin.getPartnerSkinById(_id);
    local _iconPath = FuncRes.iconHero(skinCfg.icon)
    local _spriteIcon = cc.Sprite:create(_iconPath)
    return _spriteIcon
end

function FuncPartnerSkin.getPartnerHeadIcon(_partnerId, _skinId)
    local skinCfg = FuncPartnerSkin.getPartnerSkinById(_skinId)
    if tostring(skinCfg.partnerId) ~= tostring(_partnerId) and _skinId then
        echoError("_partnerId ".._partnerId.."do not have skin ".._skinId)
    end
    local _icon = FuncPartnerSkin.getValueByKey(_skinId, "iconId")
    local _iconPath = FuncRes.iconHero(_icon)
    local _spriteIcon = cc.Sprite:create(_iconPath)
    return _spriteIcon
end
-- 购买皮肤消耗的皮肤卷
function FuncPartnerSkin.getCostNum(_id)
    local costArray = FuncPartnerSkin.getValueByKey(_id,"cost")
    local str = string.split(costArray[1], ",")
    return tonumber(str[3])
end

function FuncPartnerSkin.getCostInfo(_id)
    local costArray = FuncPartnerSkin.getValueByKey(_id, "cost")
    return costArray
end

-- 取 伙伴素颜皮肤ID
function FuncPartnerSkin.getSuYanSkinId(partnerId)
    partnerId = tostring(partnerId)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local allSkin = partnerSkinT[partnerId]
    for i,v in pairs(allSkin) do
        local skinLihui = FuncPartnerSkin.getValueByKey(v,"type") 
        if skinLihui == 1 then
            return v
        end
    end
        
    echoWarn("没找到素颜皮肤，去对表  partnerid ==== "..partnerId)
    return "1"   
end

-- 获取奇侠的皮肤数据 allSkinsData 是userModel中的skins字段下的数据
-- 用于func中战力计算
function FuncPartnerSkin.getOnePartnerSkins( allSkinsData,partnerId )
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        local skins = {}
        for i,v in pairs(data) do
            if allSkinsData[v] then
                table.insert(skins,v)
            end
        end
        return skins
    else
        return nil
    end
end
function FuncPartnerSkin.getSkinsByPartnerId(id, allSkins)
    if skins then
        local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
        local data = partnerSkinT[tostring(id)]
        if data then
            local skins = {}
            for i,v in pairs(data) do
                if allSkins[v] then
                    table.insert(skins, v)
                end
            end
        
            return skins
        end
    end
    return nil
end

function FuncPartnerSkin.isSuYanSkinById(skinId)
    local skinData = FuncPartnerSkin.getPartnerSkinById(skinId)
    if skinData.type and skinData.type == 1 then
        return true
    end

    return false
end
