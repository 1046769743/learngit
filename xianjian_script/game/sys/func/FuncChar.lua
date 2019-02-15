FuncChar= FuncChar or {}


local heroData = nil
local heroBaseData = nil
local attributeData = nil
local charLevelData = nil
local charLevelUpData = nil
local CharCrown = nil

FuncChar.SEX_TYPE = {
    NAN = "a",
    NV = "b"
}

FuncChar.SEX_MAP = {
    a=1,
    b=2,
    MAN=1,
    FEMALE=2,
    MAN_ID = "101",
    FEMALE_ID = "104",
}

FuncChar.MAN_ID = "101"
FuncChar.FEMALE_ID = "104"

-- 每个灵穴节点数量
FuncChar.pulseNodeNumPerLv = 4
FuncChar.fightAttrCritR = "critR"

FuncChar.starDirt = "5000"

function FuncChar.init(  ) 
    heroData = Tool:configRequire("char.CharInitAttr")
    heroBaseData = Tool:configRequire("char.CharInitAttrBase")
    attributeData = Tool:configRequire("common.AttributeConvert")
    charLevelData = Tool:configRequire("char.CharLevel")
    charLevelUpData = Tool:configRequire("char.CharLevelUp")
    CharCrown = Tool:configRequire("char.CharCrown") 
end
-- 通过品质获取品质框
function FuncChar.getBorderFramByQuality(quality,charId)
    local qualityData = FuncChar.getCharQualityDataById(quality,charId)
    return qualityData.border
end

--[[
    TODO:CharQuality删除为最小化修改，用伙伴表数据构造原结构
]]
function FuncChar.getCharQualityDataById(id,charId)
    local qualityData = FuncPartner.getPartnerQualityData()
    local curQualityData = {}

    charId = charId or "101"

    curQualityData.border = qualityData[tostring(charId)][tostring(id)].color
    return curQualityData
end

function FuncChar.checkEquipAwake( userData )
    if userData.equips then
        for i,v in pairs(userData.equips) do
            if not v.awake or tonumber(v.awake) ~= 1 then
                return false
            end
        end
        return true
    else
        return false
    end
end
-- \
-- 通过伙伴信息 获得技能详情
function FuncChar.getPartnerSkillParams(userData,treasureId,exlvl)
    exlvl = exlvl or 0
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
    local data = userData.treasures
    star = data[treasureId].star or 1
    local level = userData.level --math.floor((UserModel:level()-1)/3 + 1)
    if not FuncChar.getSkillLvlByUserdata( userData ) then
        level = 1
    end
    local starSkillMap = FuncTreasureNew.getStarSkillMap(treasureId,userData.avatar)
    local skills = {}
    for i ,v in pairs(starSkillMap) do    
        if star >= v.star then
            local _skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
            if _skillData.order == 3 and _skillData.priority == 1 then
                skills[tostring(v.skill)] = level + exlvl
            else
                skills[tostring(v.skill)] = level 
            end
        end
    end

    -- 主角小技能
    local partnerData = FuncPartner.getPartnerById(userData.avatar);
    local skillId = partnerData.skill[1]
    skills[tostring(skillId)] = level + exlvl

    local charData = FuncChar.changeDataToCommon(userData)
    -- 判断觉醒属性是否已解锁
    local equipAwake = FuncChar.checkEquipAwake( userData )
    if equipAwake and star >= 4 then
        local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
        local _awakSkillId
        if tonumber(charData.id) == 101 then
            _awakSkillId = dataCfg.awakeSkillId[1]
        else
            _awakSkillId = dataCfg.awakeSkillId[2]
        end
        skills[tostring(_awakSkillId)] = level + exlvl
    end
    
    -- 判断武器装备的技能是否解锁
    local equips = charData.equips
    for i,v in pairs(equips) do
        --判断是否是 武器装备
        if FuncChar:checkCharWuqiAwake(i) then
            -- 判断是否觉醒
            if v.awake and v.awake == 1 then
                skills[tostring(partnerData.awakeSkillId)] = level + exlvl
            end
        end
    end

    charData.skills = skills 
    -- dump(skills,"zhujue jies de ji",5)
    return FuncPartner.getPartnerSkillParams(charData,{treaId = treasureId,star = star})
end
-- 处理竞技场机器人取技能忽略无用内容（只在竞技场取机器人信息用其他地方切勿使用）
function FuncChar.getPartnerSkillParamsForRobot(userData,treasureId,exlvl)
    exlvl = exlvl or 0
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureId)
    local data = userData.treasures
    star = data[treasureId].star or 1
    local level = userData.level --math.floor((UserModel:level()-1)/3 + 1)

    local starSkillMap = FuncTreasureNew.getStarSkillMap(treasureId,userData.avatar)
    local skills = {}
    for i ,v in pairs(starSkillMap) do    
        if star >= v.star then
            local _skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
            if _skillData.order == 3 and _skillData.priority == 1 then
                skills[tostring(v.skill)] = level + exlvl
            else
                skills[tostring(v.skill)] = level 
            end
        end
    end
    -- 主角小技能
    local partnerData = FuncPartner.getPartnerById(userData.avatar);
    local skillId = partnerData.skill[1]
    skills[tostring(skillId)] = level + exlvl
    
    local charData = FuncChar.changeDataToCommon(userData)
    charData.skills = skills 
    return FuncPartner.getPartnerSkillParams(charData,{treaId = treasureId,star = star})
end

-- 通过主角信息获取技能level
function FuncChar.getSkillLvlByUserdata( userData )
    local systemOpenData = FuncCommon.getSysOpenData()
    local condition = systemOpenData[FuncCommon.SYSTEM_NAME.PARTNER_SKILL].condition
    if not FuncCommon.checkCondition( userData ,condition ) then
        return true
    else
        return false
    end 
end

function FuncChar:checkCharWuqiAwake(equipId)
    local dataCfg = FuncChar.getCharInitData()
    local equips = dataCfg.equipment
    if equips[1] == tostring(equipId) then
        return true
    end
    return false
end

----------------------------------------------------------------------------
-----------------------主角总战力计算（包括主角和伙伴）---------------------
----------------------------------------------------------------------------
-- 对外接口
-- 阵容战力 不加宝物
function FuncChar.getCharAllPower(userData,formation )
    local power = 0
    -- 主角的战力
    local charData = FuncChar.changeDataToCommon(userData)
    local treasureId = formation.treasureFormation.p1 --
    local treasureData = userData.treasures[treasureId]
    local treasureLevel = userData.level--math.floor((userData.level-1)/3 + 1)
    local titleData = userData.titles
    local garmentIds = {}
    local garments = userData.garments or {}
    garmentIds = FuncGarment.getEnabledGarments(garments,true)

    --local baowuData = userData.cimeliaGroups
    local lovesData = userData.loves
    local params = {
        chard = charData,
        trsd = treasureData,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentIds,
        loved = lovesData,
        userd = userData
    }
    power = power + FuncChar.getCharAbility(params)
    -- echo("角色战力 == ",power)
    -- 伙伴战力
    local partnerT = formation.partnerFormation 
    local partnersInfo = userData.partners
    local handbookPower = FuncHandbook.getAllHandBookAddition( userData )
    local expandMap = {handbooks = handbookPower}
    for k,v in pairs(partnerT) do
        local id = v.partner.partnerId
        if v  then
            local id = v.partner.partnerId
            -- 阵容内不是主角、且不是雇佣兵 才需要计算战力
            if (not v.partner.teamFlag) and (not FuncPartner.isChar(id)) then
                local partnerInfo = partnersInfo[id]
                if partnerInfo and partnerInfo.id  then
                    local partnerPower = FuncPartner.getPartnerAbility( partnerInfo,userData,formation,nil,expandMap)
                    power = power + partnerPower
                end
                
            end
            
        end
    end
    return power
end
-- 通过阵容获取法宝ID
function FuncChar.getTreasureIdByFomation( userData,formation )
    -- 判断阵容是多人还是单人
    local treasureId = "" --
    if formation.treasureFormation.p1 then
        -- 单人
        treasureId = formation.treasureFormation.p1

    else
        local rid = userData.rid or userData._id
        treasureId = formation.treasureFormation[rid]
    end
    if not treasureId then
        echoError("阵容里没有传 法宝ID")
        dump(formation, " 传进来的阵容")
    end
    return treasureId
end

-- 主角单独的战力   formation与_treasureId必须需要有一个
function FuncChar.getCharPower(userData, formation, _treasureId)
    local power = 0
    -- 主角的战力
    local charData = FuncChar.changeDataToCommon(userData)
    local treasureId 
    if _treasureId then
        treasureId = _treasureId
    elseif formation then
        treasureId = FuncChar.getTreasureIdByFomation(userData,formation)
    end
    
    local treasureData = userData.treasures[treasureId]
    local treasureLevel = userData.level--math.floor((userData.level-1)/3 + 1)
    local titleData = userData.titles
    local memory = userData.memerys
    local garmentIds = {}
    local garments = userData.garments or {}
    garmentIds = FuncGarment.getEnabledGarments(garments,true)
    --local baowuData = userData.cimeliaGroups
    local lovesData = userData.loves
    local params = {
        chard = charData,
        trsd = treasureData,
        trsl = treasureLevel,
        titd = titleData,
        garmid = garmentIds,
        loved = lovesData,
        memory = memory,
        userd = userData
    }


    power = power + FuncChar.getCharAbility(params)
    echo("角色战力 == ",power)
    return power
end
-- 主角战力基础值
function FuncChar.getCharInitChar(userData,treasureId,treasureData)
    local charData = FuncChar.changeDataToCommon(userData)
    -- 初始战力
    local initAbility = tonumber(FuncChar.getCharInitAbility(charData.id))
    -- 品阶战力
    local qualityAbility = tonumber(FuncChar.getCharQualityAbility(charData))
    -- 星级战力
    local starAbility = tonumber(FuncChar.getPartnerStarAbility(charData)) 

    -- 法宝战力
    local treasureData = userData.treasures[treasureId] 
    local treasureLevel = userData.level--math.floor((userData.level-1)/3 + 1)
    local treasureAbility = 1
    if treasureData then
        treasureAbility = FuncTreasureNew.getAbilityPer( treasureData,treasureLevel )
    end

    local initPower = treasureAbility * (initAbility + qualityAbility + starAbility)
    return initPower
end
-----------------------------------------------------------------------------
-------------------------------主角战力--------------------------------------
-----------------------------------------------------------------------------
-- 主角品级增加的战斗力
function FuncChar.getCharQualityAbility(charData)
    return FuncPartner.getPartnerQualityAbility(charData)
end
-- 主角星级增加的战力
function FuncChar.getPartnerStarAbility(charData)
    return FuncPartner.getPartnerStarAbility(charData)
end
-- 主角装备增加战力
function FuncChar.getPartnerEquipAbility(charData)
    return FuncPartner.getPartnerEquipAbility(charData)
end

function FuncChar.getCharSkillId(charId)
    local heroData = FuncChar.getHeroData(charId)
    return heroData.skill[1]
end

function FuncChar.isCharskill(charId, skillId)
    local heroData = FuncChar.getHeroData(charId)
    if tostring(skillId) == tostring(heroData.skill[1]) then
        return true
    end
    return false
end

-- 主角技能战力
function FuncChar.getCharSkill(charData,skilLevel)
    local heroData = FuncChar.getHeroData(charData.id)
    local skillData = FuncPartner.getSkillInfo(heroData.skill[1])
    local level = skilLevel or charData.level --math.floor((charData.level-1)/3 + 1)
    local lvAbility = skillData.lvAbility * level

    return lvAbility
end
-- 获取主角战斗力
-- 主角战力= ( x + 法宝定位 ) * 
--{ ( 初始+等级*星级索引出的等级成长+星点+灵材+品质 ) * 
--( 1 + 宝物万分比+情缘万分比+被动技能万分比+套装放大万分比 ) 
--+装备+装备套装+单件宝物固定值+宝物突破阶数补充值+修炼；} 
function FuncChar.getCharAbility(params,isLog)
    -- 对数据进行判断
    local charData = params.chard
    local treasureData = params.trsd
    local treasureLevel = params.trsl
    local titleData = params.titd or {}
    local garmentIds = params.garmid or {}
    local lovesData = params.loved or {}
    local userData = params.userd
    local skillLevel = userData.level 

    local charAbility = 0
    -- 初始战力
    local initAbility = tonumber(FuncChar.getCharInitAbility(charData.id))
    -- 品阶战力
    local qualityAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY,userData) then
        qualityAbility = tonumber(FuncChar.getCharQualityAbility(charData))
    end
    -- 星级战力
    local starAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING,userData) then
        starAbility = tonumber(FuncChar.getPartnerStarAbility(charData))
    end
    -- 装备战力
    local equpAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI,userData) then
        equpAbility = tonumber(FuncChar.getPartnerEquipAbility(charData))
    end

    -- 时装战力
    local garmentAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.GARMENT,userData) then
        garmentAbility = FuncGarment.getEnabledGarmentsAddAbility(garmentIds, charData.id)       
    end
    -- 时装战力万分比
    local garmentAbPer = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.GARMENT,userData) then
        garmentAbPer = FuncGarment.getGarmentRatioAddAbility(garmentId, charData.id) 
    end
    -- 称号战力
    local titleAbility = FuncTitle.byTitleUIdGetsumbattl(titleData)
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.TITLE,userData) then
        titleAbility = FuncTitle.getTitleAbility( titleData )
    end
    -- 称号万分比
    local titleAbPer = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.TITLE,userData) then
        titleAbPer = FuncTitle.byTitleIdgetsumWBbattl(titleData) 
    end

    -- 法宝战力的技能战力
    local fabaoSkillAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.TREASURE_NEW,userData) then
        fabaoSkillAbility = FuncTreasureNew.getFabaoSkillAbility(treasureData,skillLevel) 
    end
    --主角技能
    local skillAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_SKILL,userData) then
        skillAbility = FuncChar.getCharSkill(charData,skillLevel)
    end

    -- 装备觉醒
    local equipAwakeAbility = 0
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.EQUIPAWAKE,userData) then
        equipAwakeAbility = FuncPartner.getEquiAwakeAbility( charData )
    end

    charAbility =  (initAbility + starAbility + qualityAbility ) * ( 1+titleAbPer) + 
                (equpAbility + garmentAbility + titleAbility +
                    skillAbility + fabaoSkillAbility + 
                    equipAwakeAbility)
    if isLog then
        echoError("主角的战力-------")
        echo("treasureAbility  ==== ",treasureAbility)
        echo("initAbility ==== ",initAbility )
        echo("starAbility ==== ",starAbility )
        echo("qualityAbility ==== ",qualityAbility )
        echo("lovelAbPer ==== ",lovelAbPer )
        echo("titleAbPer ==== ",titleAbPer )
        echo("titleAbility ==== ",titleAbility )
        echo("garmentAbPer ==== ",garmentAbPer )
        echo("equpAbility ==== ",equpAbility )
        echo("garmentAbility ==== ",garmentAbility )
        -- echo("lovelAbility ==== ",lovelAbility )
        echo("skillAbility ==== ",skillAbility  )
        echo("fabaoSkillAbility ====",fabaoSkillAbility)
        echo("equipAwakeAbility ====",equipAwakeAbility)

        echo("主角的全部战力 === ",charAbility)
    end
    -- echoError("主角的战力-------")
    -- echo("treasureAbility  ==== ",treasureAbility)
    -- echo("initAbility ==== ",initAbility )
    -- echo("starAbility ==== ",starAbility )
    -- echo("qualityAbility ==== ",qualityAbility )
    -- echo("lovelAbPer ==== ",lovelAbPer )
    -- echo("titleAbPer ==== ",titleAbPer )
    -- echo("garmentAbPer ==== ",garmentAbPer )
    -- echo("equpAbility ==== ",equpAbility )
    -- echo("garmentAbility ==== ",garmentAbility )
    -- echo("lovelAbility ==== ",lovelAbility )
    -- echo("skillAbility ==== ",skillAbility  )
    -- echo("fabaoSkillAbility ====",fabaoSkillAbility)

    -- echo("主角的全部战力 === ",charAbility)
    return math.floor(charAbility)
end

-- 主角战力打印
function FuncChar.charAbilityLog( ... )
    -- body
end

-- 根据等级获取主角初始数据
function FuncChar.getCharInitData()
    return heroBaseData["1"]
end

-- 根据等级获取主角初始战力
function FuncChar.getCharInitAbility()
    local data = heroBaseData["1"]
    local initAbility = data.initAbility
    return initAbility
end

----------------------------------------------------------------------------
------------主角属性  算其他玩家的属性 自己的属性在charmodel中--------------
----------------------------------------------------------------------------
-- 对外接口  formation和_treasureId必须需要传一个 如果需要计算法宝对阵位的属性加成 必须传formation
function FuncChar.getCharAttr(userData, formation, _treasureId)
    local treasureId = nil
    local siteAttr = nil
    if _treasureId then
        treasureId = _treasureId
    elseif formation then
        treasureId = FuncChar.getTreasureIdByFomation(userData,formation)
        siteAttr = FuncChar.getTreasureSitAttr(userData,formation)
    end
    
    local charData = FuncChar.changeDataToCommon(userData)
    local treasureData = userData.treasures[treasureId]
    local treasureLevel = userData.level--math.floor((userData.level-1)/3 + 1)
    local titleData = userData.titles
    local garments = {}
    if userData.garments then
        for i,v in pairs(userData.garments) do
            table.insert(garments, v.id)
        end
     end 
    local baowuData = userData.cimeliaGroups
    local lovesData = userData.loves
    local memoryData = userData.memorys  
    -- dump(siteAttr, "____________siteAttr ______", 5)
    local params = {
        chard = charData,
        trsd = treasureData,
        trsl = treasureLevel,
        titd = titleData,
        gard = garments,
        bwd = baowuData,
        loved = lovesData,
        userd = userData,
        siteAttr = siteAttr,
        artid = baowuData,
        memory = memoryData,
    }
    local attr = FuncChar.getCharFightAttribute(params)
    return attr
end

-- 获取该伙伴是否要添加 法宝阵位全局养成属性
function FuncChar.getTreasureSitAttr(userData,formation)
    local partnerId = 1
    local attr = {}
    -- 先找到partner的阵位
    for i=1,6 do
        --dump(formation.partnerFormation["p"..i],"asfdssfd",5)
        local _id = formation.partnerFormation["p"..i].partner.partnerId
        if tonumber(_id) == tonumber(partnerId) then
            for ii,vv in pairs(userData.treasures) do
                local treasureId = ii
                local treasureData = userData.treasures[treasureId]
                local trsSite= FuncTreasureNew.getTreasureDataById(treasureId).site
                local siteAttr = FuncTreasureNew.getTreaSiteAttr(treasureData)
                if i == 1 or i == 2 then
                    -- 前排
                    if trsSite == 1 then
                        table.insert(attr, siteAttr)
                    end
                elseif i == 3 or i == 4 then 
                    -- 中排
                    if trsSite == 2 then
                        table.insert(attr, siteAttr)
                    end
                elseif i == 5 or i == 6 then
                    -- 后排
                    if trsSite == 3 then
                        table.insert(attr, siteAttr)
                    end
                end
            end
            
        end
    end
    return attr
end
--[[
    userData：默认为UserModel._data，计算当前玩家的战斗属性
]]

function FuncChar.getCharFightAttribute(params)
    --判断数据
    local userData = params.userd or {}
    local titleData = params.titd or {}
    local artifactData = params.artid or {}
    local lovesData = params.loved or {}
    local treasureData = params.trsd or {}
    local charData = params.chard or {}
    local garments = params.gard or {}
    local siteAttr = params.siteAttr or {}
    local memory = params.memory or {}

    local dataMap = {}

    -- 法宝提供的属性
    -- 法宝属性加成 -- 要分情况计算了
    --[[
        1.主角显示，只添加佩戴属性
        2.战斗和布阵，还要添加全局和养成属性
        因为布阵还没开发完，目前只添加佩戴属性
    ]]
    local treasureAttrData = {}
    local treasureSkillAttrData = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.TREASURE_NEW,userData) then
        treasureAttrData = FuncTreasureNew.getTreasurePeidaiAttr(treasureData) or {}
        treasureSkillAttrData = FuncTreasureNew.getTreasureSkillAttr( treasureData,userData.level ) or {}
    end
    for i,v in pairs(treasureAttrData) do
        table.insert(dataMap, v)
    end
    for i,v in pairs(treasureSkillAttrData) do
        table.insert(dataMap, v)
    end
    ---------基本属性----------------
    -- 基本属性
    local initAttr = FuncChar.getInitAttr( charData ) or {}
    for i,v in pairs(initAttr) do
        table.insert(dataMap, v)
    end
    -- 品阶属性加成
    local qualityAttrData = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_QUALITY,userData) then
        qualityAttrData = FuncPartner.getQualityAttr( charData) or {}
    end
    for i,v in pairs(qualityAttrData) do
        table.insert(dataMap, v)
    end
    -- 星级属性加成
    local starAttrData = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING,userData) then
        starAttrData = FuncPartner.getStarAttr( charData ) or {}
    end
    for i,v in pairs(starAttrData) do
        table.insert(dataMap, v)
    end
    ----------属性万分比加成----------------
    --宝物属性
    local baowuData = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.CIMELIA,userData) then
        baowuData = FuncArtifact.getAllArtifactAttr(artifactData,tostring(charData.id)) or {}
    end
    for i,v in pairs(baowuData) do
        table.insert(dataMap,{v})
    end
    --情缘万分比
    local loveAttrPer = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.LOVE,userData) then
        loveAttrPer = FuncNewLove.getMainPartnerCurrentLoveProperty(charData) or {}
    end
    for i,v in pairs(loveAttrPer) do
        table.insert(dataMap,{v})
    end
    -- 仙盟无极阁加成
    local guildAttrPer = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.GUILD,userData) then
        guildAttrPer = FuncGuild.getGuildAddProperty(charData,userData.guildSkills) or {}
    end
    for i,v in pairs(guildAttrPer) do
        table.insert(dataMap,{v})
    end

    --被动技能万分比
    local bdSkillAttrPer = {}
    --套装放大万分比
    local taozhuangAttrPer = {}
    -- 称号万分比
    local titleAttrPer = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.TITLE,userData) then
        titleAttrPer = FuncTitle.getInitAttr(titleData) or {}
    end
    for i,v in pairs(titleAttrPer) do
        table.insert(dataMap,{v})
    end
    ------------固定属性加成---------------------
    -- 技能属性加成
    -- 装备属性加成
    local equipsAttrdata = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI,userData) then
        equipsAttrdata = FuncPartner.getEquipsAttr( charData ) or {}
    end
    for i,v in pairs(equipsAttrdata) do
        table.insert(dataMap, v)
    end

    

    -- 主角时装属性加成
    local garmentAttr = {}
    if not FuncCommon.isSystemOpenByUserData(FuncCommon.SYSTEM_NAME.GARMENT,userData) then
        garmentAttr = FuncGarment.getGarmentAttr( charData.id,garments) or {}
    end
    for i,v in pairs(garmentAttr) do
        for ii,vv in pairs(v) do
            table.insert(dataMap, {vv})
        end
    end

    -- 法宝阵位专属 属性添加
    if siteAttr then
        for i,v in pairs(siteAttr) do
            for ii,vv in pairs(v) do
                table.insert(dataMap, vv)
            end
        end
    end

    -- 阵位

    -- 情景卡
    local memoryAttr = FuncMemoryCard.getAttrByPartnerId( charData.id ,memory ) or {}
    for i,v in pairs(memoryAttr) do
        table.insert(dataMap, {v})
    end
    --

    -- dump(dataMap, "主角属性加成")
    
    return FuncBattleBase.countFinalAttr(unpack( dataMap) )
end

-- 转换成统一的主角数据结构
function FuncChar.changeDataToCommon(userData)
    local charData = {
        id = userData.avatar or "101",
        quality = userData.quality or 1,
        position = userData.position or 0,
        star = userData.star  or 1 ,
        starPoint = userData.starPoint or 0,
        level = userData.level,
        equips = userData.equips or {},
        garmentId = userData.userExt.garmentId   
    }
    return charData
end
function FuncChar.getInitAttr( userData )
    local dataMap = {}
    local _base_data = FuncChar.getHeroData( tostring(userData.id) )
    for _key,_value in pairs(_base_data.initAttr) do
        local _data = {
            key = _value.key,
            value = _value.value,
            mode = _value.mode,
        }
        table.insert(dataMap,{_data})
    end
    return dataMap
end

-- 主角最大等级
function FuncChar.getCharMaxLv()
    if FuncChar.charMaxLv then
        return FuncChar.charMaxLv
    else
        FuncChar.charMaxLv = 1

        for k,_ in pairs(charLevelData) do
            if tonumber(k) > FuncChar.charMaxLv then
                FuncChar.charMaxLv = tonumber(k)
            end
        end

        return FuncChar.charMaxLv
    end
end

-- 根据lv获取升级数据
function FuncChar.getCharLevelDataByLv( lv )
    local data = charLevelData[tostring(lv)]
    if data ~= nil then
        return data
    else
        echoError("FuncChar.getCharLevelDataByLv lv=" .. lv .. " not found")
    end
end

function FuncChar.getCharMaxExpAtLevel(lv)
    local data = FuncChar.getCharLevelDataByLv(lv)
    if not data then return 0 end
    return data.charExp
end

-- 根据lv及key获取升级数据
function FuncChar.getCharLevelValueByLv(lv,key)
    local data = FuncChar.getCharLevelDataByLv(lv)
    if data ~= nil then
        return data[key]
    end
end

function FuncChar.getCharLevelConfig()
    return charLevelUpData;
end

function FuncChar.getCharLevelNextSysLevel(lv)
    local data = charLevelUpData[tostring(lv)]
    -- dump(data, "--data--");
    if data ~= nil then
        return data["nextSys"];
    else
        return nil;
    end
end

function FuncChar.getCharLevelUpValueByLv(lv, key)
    local data = charLevelUpData[tostring(lv)]
    if data ~= nil then
        return data[key]
    else
        echoError("FuncChar.getCharLevelUpValueByLv lv=" .. lv .. " not found")
    end
end

function FuncChar.getCharLevelUpSp(curLv, lastLv)
    local sp = 0
    for i = tonumber(lastLv), tonumber(curLv) - 1 do
        local data = charLevelData[tostring(i)]
        if data ~= nil then
            sp = sp + data.lvUpAddSp
        else
            echoError("FuncChar.getCharLevelUpValueByLv lv=" .. i .. " not found")
        end        
    end
    return sp
end

function FuncChar.getCharLevelUpValueByLvWithOutError(lv, key)
    local data = charLevelUpData[tostring(lv)]
    echo("data " .. tostring(data));
    if data ~= nil then
        return data[key]
    else
        return nil;
    end
end

function FuncChar.getSysNameByGid(gid)
    for _, v in pairs(charLevelUpData) do
        if tonumber(v.guideId) == tonumber(gid) then 
            return v.sysNameKey;
        end 
    end
    return nil;
end

-- 获取英雄静态数据
function FuncChar.getHeroData( hid )
    local data = heroData[tostring(hid)]
    if data ~= nil then
        return data
    else
        echoError("FuncChar.getHeroData hid " .. hid .. " not found,暂时用101代替")
        return heroData[tostring(101)]
    end
end

--获取英雄的icon图片名
function FuncChar.getHeroAvatar(hid)
    local data = heroData[hid]
    return data.icon
end

function FuncChar.getHeroSex(hid)
    local data = heroData[hid]
    if not data then
        echoWarn("这个hid的数据不存在",hid)
    end
    return data and data.sex or 1
end
-- 获取性别，转换为统一的 1男,2女
function FuncChar.getCharSexByAvatar(avatar)
    local sex = FuncChar.getHeroSex(tostring(avatar))

    if sex == "a" then sex = 1 end
    if sex == "b" then sex = 2 end

    return sex
end

function FuncChar.getAllHerosData()
    return table.deepCopy(heroData)
end

--获取英雄的 动画名字
function FuncChar.armature( hid )
    local data = FuncChar.getHeroData(hid)
    return  data.armature
end


--获取英雄icon
function FuncChar.icon( hid )
    local hid = tostring(hid)
    if heroData[hid] == nil then
        hid = tostring(101)
    end
    local icon = heroData[hid].icon
    return FuncRes.iconHero(icon)
end


--获取对应星级需要的魂石
function FuncChar.getNeedSoul( star )
    return GameVars.starNeedSoul[star]
end

function FuncChar.getAttributeById(id)
    local info = attributeData[tostring(id)]
    return info
end

-- 根据属性Id获取order
function FuncChar.getAttributeOrderById(id)
    local info = attributeData[tostring(id)]
    return info.order
end

-- 根据属性key获取order
function FuncChar.getAttributeOrderByKey(attrKey)
    for k,v in pairs(attributeData) do
        if v.keyName == attrKey then
            return v.order
        end
    end
end

function FuncChar.getAttributeData()
    return attributeData
end

-- 判断AttributeConvert中是否有该key值 
function FuncChar.hasAttributeKey(keyName)
    for k,v in pairs(attributeData) do
        if v.keyName == tostring(keyName) then
            return true
        end
    end

    return false
end

function FuncChar.getCharProp(lv,isDecode )
    local data = confg[lv]
    return data
end

--根据avatar 和 等级获取主角的资源名字
function FuncChar.getSpineAniName( avatar )
    local sourceId = FuncChar.getHeroData(avatar).sourceld

    local sex = FuncChar.getHeroSex(avatar)

    local sourceData =FuncTreasure.getSourceDataById(sourceId)
    local armature
    if sex == "a" or sex == 1 then
        armature = sourceData.spine
    else
        armature = sourceData.spineFormale
    end

    return  armature, armature
end

--根据avatar 获取spine动画
--[[
    播放动画示例
    local spine = FuncChar.getSpineAni( 1,20)
    spine:playLabel(spine.actionArr.stand)
]]
function FuncChar.getSpineAni( avatar )
    local sourceId = FuncGarment.getGarmentSource("",avatar)
    return FuncRes.getSpineViewBySourceId(sourceId,nil,isWhole )
end

--[[
    任意玩家穿法宝的形象
]]
function FuncChar.getCharSkinSpine(avatar, tid, isWhole)
    local sourceId = FuncGarment.getGarmentSource("",avatar)
    return FuncRes.getSpineViewBySourceId(sourceId,nil,isWhole )

end




-- 删除对应的角色spine动画资源
function FuncChar.deleteCharOnTreasure( charView )
    local fla = charView.fla
    charView:clear()
    
end

-- 下一个动作
-- 参数说明：charView=展示动作的主角， callback=动作播放完毕的回调函数，params=回调函数可以带回的参数
-- callback， params 参数可以不传
function  FuncChar.playNextAction( charView,callback,params )
    -- 随机动作用。目前不需要随机动作
    -- local actionArrNum = #charView.actionArr
    --local random = RandomControl.getOneRandomInt(actionArrNum+1,1,charView.actionIdx)
    --charView.actionIdx = random

    if charView.playAction then
        return
    end

    local playSkillEff = function( charView )
        if not charView.skillEff then
            return
        end

    end

    local playActionEnd =function ( charView )
        charView.playAction = false
        if callback then
            if params then
                callback(unpack(params))
            else
                callback()
            end
        end
    end

    charView.playAction  = true
    if charView.label1 == 1 then
        local actionArr = { 
            {label = charView.actionArr.atkNear },
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

        -- 特效部分
        playSkillEff(charView)

    elseif charView.label1 == 2 then
        local actionArr = { 
            {label = charView.actionArr.atkFar },
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

        -- 特效部分
        playSkillEff(charView)

    elseif charView.label1 == 3 then
        local singTime = charView.singTime
        local actionArr = { 
            {label = charView.actionArr.giveOutBS },
            {label = charView.actionArr.giveOutBM,loop = true, startCall = c_func(playSkillEff, charView),lastFrame = singTime } ,
            {label = charView.actionArr.giveOutBE} ,
            {label = charView.actionArr.stand,loop = true, startCall = c_func(playActionEnd, charView)} ,
           }
        charView:playActionArr( actionArr )

    end
end



--选角色界面的文字
function FuncChar.getHeroSelectTalk(hid)
    local data = heroData[hid]
    return GameConfig.getLanguage(data.talk)
end
--主角按钮音效
function FuncChar.playCharBtnSound()
    AudioModel:playSound(MusicConfig.s_partner_outfit)
end
----主角头衔
function FuncChar.ByIDgetCharCrowndata(CharCrownID)
    if CharCrownID <= 10 then
        return CharCrown[tostring(CharCrownID)]
    else
        return nil
    end
end

function FuncChar.getCharSex(avatar)
    local    charInfo = FuncChar.getHeroData(avatar);
    return   FuncChar.SEX_MAP[charInfo.sex];
end

function FuncChar.getCharAwakeSkillId(avatar)
    local dataCfg = heroData[tostring(avatar)]
    return dataCfg.awakeSkillId
end
