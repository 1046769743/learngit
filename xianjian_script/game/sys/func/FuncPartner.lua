--//伙伴系统,所有的配置表
--//2016-12-5 11:22:00 
--//@Author:狄建彬

FuncPartner = FuncPartner or {}
--奇侠能达到的最大等级数
FuncPartner.maxPartnerLevel = 99

FuncPartner.combineType = {
    [1] = "正常", -- 
    [2] = "登录送",
    [3] = "首冲送",
}

FuncPartner.PartnerIndex = {
    PARTNER_QUALILITY = 1, -- 伙伴升品 and 升级
    PARTNER_UPSTAR = 2,-- 伙伴升星
    PARTNER_SKILL = 3,-- 伙伴技能
    PARTNER_JUEJI = 4,-- 伙伴绝技
    PARTNER_EQUIPMENT = 5,-- 伙伴装备
    -- 合成是单独的逻辑
    PARTNER_COMBINE = 6,-- 伙伴合成

    PARTNER_SHENGJI = 7,-- 伙伴升级

}
--伙伴系统UI类型
FuncPartner.PartnerUIType={
     Main = 1,--主页面
     Strength = 2,--强化
     Levelup = 3,--升级
     Skill = 4, -- 技能
     Soul = 5,--仙魂
     Star = 6,--星品
}
--品质与颜色之间的映射
-- 情缘系统用到，用于提示
--Author:      zhuguangyuan
--DateTime:    2017-10-12 16:45:57
FuncPartner.QualityToColor={
    [1]="白色",
    [2]="绿色",
    [3]="绿色+1",
    [4]="蓝色",
    [5]="蓝色+1",
    [6]="蓝色+2",
    [7]="蓝色+3",
    [8]="紫色",
    [9]="紫色+1",
    [10]="紫色+2",
    [11]="紫色+3",
    [12]="橙色",
    [13]="橙色+1",
    [14]="橙色+2",
    [15]="橙色+3",
    [16]="红色",
    [17]="红色+1",
    [18]="红色+2",
    [19]="红色+3",
}
-- --品质与颜色之间的映射
FuncPartner.QualityColorPNG={
    [1]="bai",
    [2]="bai",
    [3]="bai",
    [4]="bai",
    [5]="bai",
    [6]="lv",
    [7]="lv",
    [8]="lv",
    [9]="lv",
    [10]="lv",
    [11]="lan",
    [12]="lan",
    [13]="lan",
    [14]="lan",
    [15]="lan",
    [16]="zi",
    [17]="zi",
    [18]="zi",
    [19]="zi",
    [20]="zi",
    [21]="cheng",
    [22]="cheng",
    [23]="cheng",
    [24]="cheng",
    [25]="cheng",
    [26]="hong",
    [27]="hong",
    [28]="hong",
    [29]="hong",
    [30]="hong",
}

FuncPartner.nameColor = {
    [1] = "白色",
    [2] = "绿色",
    [3] = "蓝色",
    [4] = "紫色",
    [5] = "橙色",
    [6] = "红色", 
}

--伙伴属性 键
FuncPartner.ATTR_KEY = {
    ATTR_KEY_LIFE = 1,--生命
    ATTR_KEY_ATTACK = 10,--攻击
    ATTR_KEY_DEFENCE_PHY = 11,--物理防御
    ATTR_KEY_DEFENCE_MAGIC =12,--法术防御
    ATTR_KEY_CRIT = 13,--暴击
    ATTR_KEY_RESIST =14,--抗暴击
    ATTR_KEY_CRIT_S =15,--暴击强度
    ATTR_KEY_BLOCK = 16,--格挡率
    ATTR_KEY_WRECK =17,--破击率
    ATTR_KEY_WRECK_S = 18,--格挡强度
    ATTR_KEY_INJURY = 19,--伤害率
    ATTR_KEY_AVOID = 20,--免伤率
    ATTR_KEY_LIMIT = 21,--控制率
    ATTR_KEY_GUARD =22,--免控率
    ATTR_KEY_SUCK_S= 23,--吸血率
    ATTR_KEY_THORNS = 24,--反伤率
}

-- 属性对应mc
FuncPartner.ATTR_KEY_MC = {
    ["1"] = 3,--生命
    ["2"] = 3,--最大生命
    ["5"] = 16,--TODO 怒气
    ["10"] = 4,--攻击
    ["11"] = 5,--物理防御
    ["12"] = 6,--法术防御
    ["13"] = 7,--暴击
    ["14"] = 14,--抗暴击
    ["15"] = 8,--暴击强度
    ["16"] = 9,--格挡率
    ["17"] = 15,--破击率
    ["18"] = 10,--格挡强度
    ["19"] = 11,--伤害率
    ["20"] = 13,--免伤率
    ["21"] = 17,--控制率
    ["22"] = 18,--免控率
    ["23"]= 12,--吸血率
    ["24"] = 12,--反伤率
    ["1001"] = 1,--等级
    ["1002"] = 2,--资质
}

FuncPartner.TIPS_TYPE = {
    QUALITY_TIPS = 1,    -- 品质
    PARTNER_TYPE_TIPS = 2, -- 类型
    STAR_TIPS = 3, -- 星级
    POWER_TIPS = 4, -- 战力
    DESCRIBE_TIPS = 5, -- 描述
    LIKABILITY_TIPS = 6, -- 好感度
}

FuncPartner.RedShow = {
    SHOW = "show",
    NO_SHOW = "no_show"
}

FuncPartner.fiveName = {
    [1] = "风系",
    [2] = "雷系",
    [3] = "水系",
    [4] = "火系",
    [5] = "土系",
}

FuncPartner.partnerType = {
    [1] = "攻击型",
    [2] = "防御型",
    [3] = "辅助型"
}
    -- body


FuncPartner.PARTNER_SEX = {
    MALE = 1, -- 男性
    FEMALE = 2, -- 女性
}

--分别为奇侠中的 升级时的爆点特效   强化装备和仙术时文字上的爆点特效   立绘身上的光特效
FuncPartner.ATTENTION_ANIM_NAME = {
    SAMLL_BAO = "UI_tishitexiao_shan01",
    LARGE_BAO = "UI_tishitexiao_shan02",
    LIHUI_GUANG = "UI_tishitexiao_shan03",
    SAOGUANG = "UI_tishitexiao_saoguang",
}

FuncPartner.colorFrame = {
    [1] = "<color = FFFFFF>%s<->",
    [2] = "<color = 35DF35>%s<->",
    [3] = "<color = 31CFFC>%s<->",
    [4] = "<color = F34EF9>%s<->",
    [5] = "<color = FFCD34>%s<->",
    [6] = "<color = FC4040>%s<->",
}
--仙魂升级所需要的道具以及相关的子类型
FuncPartner.SoulItemId = {"9501","9502","9503","9504"}
--万能碎片id
FuncPartner.FullFuncItemId = "4049"
FuncPartner.SoulItemSubType = 309
--表config/partner/equipment.csv
local _equipment_table
--config/partner/partner
local _partner_table
--config/partner/partnerCombine
local _partner_combine_table
--config/partner/partnerExp
local _partner_exp_table
--config/partner/partnerSkill
local _partner_skill_table
--config/partner/partnerStar
local _partner_star_table
--config/partner/partnerStarQuality
local _partner_star_quality
--config/partner/PartnerSkillUpCost
local _partner_skill_cost 
local _partner_dapei_data
--新手期老手期配置
local _partner_skilled_cfg

function FuncPartner.init()

   _equipment_table = require("partner.PartnerEquipment")
   _partner_table = require("partner.Partner")
   _partner_combine_table = require("partner.PartnerCombine")
   _partner_exp_table = require("partner.PartnerExp")
   _partner_skill_table = require("partner.PartnerSkill")
   _partner_star_table = require("partner.PartnerStar")
   _partner_star_quality = require("partner.PartnerQuality")
   _partner_skill_cost = require("partner.PartnerSkillUpCost")
   _partner_dapei_data = require("partner.PartnerInfo")
   _partner_skilled_cfg = require("partner.NewoldPartner")
end

--获取伙伴装备
function FuncPartner.getEquipmentById( id)
  local   _data = _equipment_table[tostring(id)]
  if( not _data )then
    echo("Warning!!,id", id," get null equipment")
  end
  return _data
end

--通过装备id和等级获取对应的装备信息
function FuncPartner.getEquipmentByIdAndLevel(_id, _level)
    local equipmentCfg = FuncPartner.getEquipmentById(_id)
    local data = equipmentCfg[tostring(_level)]
    if not data then
        echoError("Warning!!get null equipment,id, level", _id, _level)
    end
    return data
end

function FuncPartner.getEquipmentShowLevelByIdAndLevel(_id, _level)
    local data = FuncPartner.getEquipmentByIdAndLevel(_id, _level)
    local showLv = data.showLv
    return showLv[1].key
end

-- 通过奇侠id和星级获取升星到下一级需要的碎片数量
function FuncPartner.getNeedDebrisByPartnerId(_id, _curStar, _starPoint)
    local starsInfo = FuncPartner.getStarsByPartnerId(_id)
    local costInfo = starsInfo[tostring(_curStar)].cost
    local count = 0
    if costInfo and table.length(costInfo) > 0 then
        for i = tonumber(_starPoint) + 1, #costInfo do
            count = count + tonumber(costInfo[i]) 
        end
    end
    return count
end

--通过奇侠id获取获得重复整卡时分解得到的碎片数量
function FuncPartner.getSameCardDebrisById(_id)
    local partnerData = FuncPartner.getPartnerById(_id)
    return partnerData.sameCardDebris
end

function FuncPartner.getPartnerDapei( _id )
    if not _id then
        echoError("奇侠搭配的id是nil，暂时用5000")
        _id = "5000"
    end
    local data = {}
    for k,v in pairs(_partner_dapei_data) do
        if tostring(v.belongMainId) == tostring(_id) then
            table.insert(data,v)
        end
    end

    return data
end

--获取所有的伙伴信息
function FuncPartner.getAllPartner()
 return _partner_table
end

--给定伙伴的Id,返回伙伴的相关信息
function FuncPartner.getPartnerById(_id)
    if not FuncPartner.isChar(_id) then
        local _info = _partner_table[tostring(_id)];
        if( not _info )then
            echo("Warning!!, could not find infomation by id",_id," in table partner.partner")
        end
        return _info;
    else
        return FuncChar.getHeroData( tostring(_id) )
    end
end
-- 获取奇侠指定的战斗内气泡id
function FuncPartner.getPartnerTalkById(_id )
    local _info = _partner_table[tostring(_id)];
    if _info and _info.talk then
        return _info.talk
    end
end
-- 奇侠怒气消耗
function FuncPartner.getNuQiCost( _id )
    local data = FuncPartner.getPartnerById(_id)
    local initAttr = data.initAttr
    local dataMap = {}
    for i,v in pairs(initAttr) do
        if tonumber(v.key) == 5 then
            return v.value
        end
    end
    return 4
end

-- 获取id对应奇侠合成时需要的碎片
function FuncPartner.getCombineNeedDebrisById(_id)
    local partnerData = FuncPartner.getPartnerById(_id)
    return partnerData.tity
end
-- 伙伴头像icon
function FuncPartner.getPartnerIconById(_id)
    local _info = _partner_table[tostring(_id)];
    
    return _info.icon;
end
--给定装备的Id,返回合成该装备需要的各种资源
function FuncPartner.getConbineResById(_equipment_id)
    local   _res_info=_partner_combine_table[tostring(_equipment_id)]
    if not _res_info then 
        echo("Warning,Equipment id ",_equipment_id," is illeagal")
    end
    return _res_info
end

--伙伴升级需要的条件
function FuncPartner.getConditionByLevel(_level)
        local       _condition = _partner_exp_table[tostring(_level)]
        if(not _condition)then
                echo("Warning, level ",_level," is illegal")
        end
        return _condition
end

--[[
根据partnerId lv 获取升级需要的经验
]]
function FuncPartner.getMaxExp( partnerId,lv )
    local condition = FuncPartner.getConditionByLevel(lv)
    if condition == nil then
        echoWarn("伙伴ID = "..partnerId.. "此时伙伴等级有错误 lv = "..lv)
        return nil
    end
    local aptitude = _partner_table[tostring(partnerId)].aptitude
    return condition[tostring(aptitude)].exp
end



--获取所有的伙伴技能
function FuncPartner.getAllPartnerSkills()
    return _partner_skill_table
end

--返回有关某一技能的详情
function FuncPartner.getSkillInfo(_skill_id)
    local _skill_info = _partner_skill_table[tostring(_skill_id)]
    if(not _skill_info)then
        echo("Warning!!!,get skill infomation failed,skill id is ",_skill_id)
    end
    return _skill_info
end
--返回某一个技能的资源消耗情况
function FuncPartner.getSkillCostInfo(_skill_quality)--输入技能的资质id
    local _skill_cost = _partner_skill_cost[tostring(_skill_quality)]
    if not _skill_cost then
        echo("Warning!!!,get Skill Cost infomation failed,input skill quality is :",_skill_quality)
    end
    return _skill_cost
end

--获取伙伴是否显示小红点
function FuncPartner.getPartnerRedPoint(partnerId)
    local key = "redPoind_"..partnerId;
    local value = LS:prv():get(key,FuncPartner.RedShow.SHOW);
    if value == FuncPartner.RedShow.SHOW then
        return true
    end
    return  false
end
--设置伙伴是否显示小红点
function FuncPartner.setPartnerRedPoint(partnerId,isShow)
    local key = "redPoind_"..partnerId;
    if isShow == true then
        LS:prv():set(key,FuncPartner.RedShow.SHOW) 
    else
        LS:prv():set(key,FuncPartner.RedShow.NO_SHOW) 
    end
end

--_partner_id:伙伴的Id,注意,返回的是一个结构体的数组
function FuncPartner.getStarsByPartnerId(_partner_id)
   local _partner_stars=_partner_star_table[tostring(_partner_id)];
   if( not _partner_stars)then
        echo("Warning!!, Partner id ",_partner_id," is illegal")
   end
   return _partner_stars
end

--根据伙伴星级获得能解锁的技能id
function FuncPartner.getUnLockSkillByStar( partnerId,star )
    
    local starInfo = FuncPartner.getStarsByPartnerId(partnerId)
    local arr = {}
    for i=1,star do
        local childInfo = starInfo[tostring(i)].skillId
        if childInfo then
            for ii,vv in ipairs(childInfo) do
                if not table.find(arr,vv) then
                    table.insert(arr, vv)
                end
                
            end
        end
    end
    return arr
end


-- 判断该伙伴是否是主角
function FuncPartner.isChar(_partnerId)
    if tonumber(_partnerId) < 5000 then
        return true
    else
        return false
    end
end
-- 获取伙伴或者主角name
function FuncPartner.getPartnerName(_partnerId)
    if tonumber(_partnerId) > 5000 then
        local partnerData = FuncPartner.getPartnerById(_partnerId);
        return GameConfig.getLanguage(partnerData.name)   
    else
        return UserModel:name()      
    end
    
end
-- 获取伙伴描述
function FuncPartner.getDescribe(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        local tre = TeamFormationModel:getOnTreasureId()
        return FuncTreasureNew.getTreasureDataByKeyID(tre,"position")
    else
        local partnerData = FuncPartner.getPartnerById(_partnerId);
        return partnerData.charaCteristic
    end
    
end

function FuncPartner.getPartnerQualityData()
    return _partner_star_quality
end

--partner_id:伙伴的Id
--返回伙伴的品质信息
function FuncPartner.getPartnerQuality(_partnerId)
    local _qualityInfo = _partner_star_quality[tostring(_partnerId)]
    if(not _qualityInfo)then
        echo("Warning!!,Partner Quality is null,partner id is ",partner_id)
    end
    return _qualityInfo
end
-- 返回奇侠init品质
function FuncPartner.getPartnerInitQuality( _partnerId )
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getCharInitData()
        return data.initQuality
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.initQuality
    end
end
-- 返回奇侠最大品质
function FuncPartner.getPartnerMaxQuality( _partnerId )
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getCharInitData()
        return data.maxQuality
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.maxQuality
    end
end
-- 返回奇侠最大星级
function FuncPartner.getPartnerMaxStar( _partnerId )
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getCharInitData()
        return data.maxStar
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.maxStar
    end
end
-- 返回奇侠的装备信息
function FuncPartner.getPartnerEquipment( _partnerId )
    _partnerId = tostring(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getCharInitData()
        return data.equipment
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.equipment
    end
end
-- 返回奇侠的装备信息
function FuncPartner.getPartnerAwakeEquipment( _partnerId )
    _partnerId = tostring(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getHeroData( _partnerId ) 
        return data.equipmentAwake
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.equipmentAwake
    end
end

-- 通过伙伴ID和技能 获得技能解锁星级
function FuncPartner.unlockSkillStar(_partnerId,_skillId)
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerId)
    local _killStarT = {}
    -- 1-7星
    for i=1,7 do
        local skillT = _star_table[tostring(i)].skillId
        if skillT then
            for ii,vv in pairs(skillT) do
                _killStarT[vv] = i
            end
        end
    end
    return _killStarT[_skillId]
end
function FuncPartner.unlockSkillByStar(_partnerId,_star)
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerId)
    local _killStarT = {}
    -- 1-7星
    for i=1,7 do
        local skillT = _star_table[tostring(i)].skillId
        if skillT then
            for ii,vv in pairs(skillT) do
                _killStarT[i] = vv
            end
        end
    end
    return _killStarT[_star]
end

-- 取装备id
function FuncPartner.getEquipIdByIndex( partnerId,index )
    local equips = FuncPartner.getPartnerEquipment( partnerId )
    return equips[index]
end
-- 取装备idIndex
function FuncPartner.getEquipIndexById( partnerId,id )
    local equips = FuncPartner.getPartnerEquipment( partnerId )
    local index = 1
    for i,v in pairs(equips) do
        if tostring(v) == tostring(id) then
            index = i
            break
        end
    end
    return index
end
-- 取觉醒的装备id
function FuncPartner.getAwakeEquipIdByIndex( partnerId,index )
    local equips = FuncPartner.getPartnerAwakeEquipment( partnerId )
    return equips[index]
end
-- 取装备id对应的觉醒id
function FuncPartner.getAwakeEquipIdByid( partnerId,id )
    local index = FuncPartner.getEquipIndexById( partnerId,id )
    -- echo("index === ",index,id)
    return FuncPartner.getAwakeEquipIdByIndex( partnerId,index )
end


-- 通过伙伴ID和index 获取装备的icon
function FuncPartner.getEquipmentIcon( partnerId,index )
    local data = FuncPartner.getPartnerById(partnerId)
    if not data.equipmentIcon then
        echoError("partnerid == ",equipmentIcon," 没有equipmentIcon")
    end
    return data.equipmentIcon[index]
end
-- 通过伙伴ID和装备id 获取装备的icon
function FuncPartner.getEquipmentIconById( partnerId,id )
    local data = nil
    if FuncPartner.isChar(partnerId) then
        data = FuncChar.getCharInitData()
    else
        data = FuncPartner.getPartnerById(partnerId)
    end
     
    local index = 1
    for k,v in pairs(data.equipment) do
        if v == id then
            index = k
            break
        end
    end
    local icon = FuncPartner.getEquipmentIcon( partnerId,index )
    return icon
end

-- 通过装备id以及是否觉醒获得装备icon
function FuncPartner.getEquipIconByIdAndAwake(partnerId, index, isAwake)
    local equipId = FuncPartner.getEquipIdByIndex(partnerId, index)
    -- 判断是否已经觉醒
    if isAwake then
        local _equipId = FuncPartner.getAwakeEquipIdByIndex(partnerId, index)
        return FuncPartnerEquipAwake.getEquipAwakeIcon(_equipId)
    else
        return FuncPartner.getEquipmentIcon(partnerId, index)
    end
end

-- 通过装备ID 获得装备name
function FuncPartner.getEquipmentName( equipmentId,partnerId )
    local data = FuncPartner.getPartnerById(partnerId)
    local equips = FuncPartner.getPartnerEquipment( partnerId )
    local equipsName = data.equipmentName
    local T = {}
    for i,v in pairs(equips) do
        T[v] = equipsName[i]
    end

    return T[equipmentId]
end


-- 通过ID获取背景图
function FuncPartner.getPartnerBgById( partnerId, garmentId, avatar )
    local data = FuncPartner.getPartnerById(partnerId)
    local backGround
    if FuncPartner.isChar(partnerId) and avatar then
        backGround = FuncGarment.getCharGarmentBg(garmentId, avatar)
        -- echo("\n\ngarmentId=", garmentId, "avatar=", avatar, "bg=", bg)
    else
        local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
        local skinData = partnerSkinT[tostring(partnerId)]

        if skinData then
            local skin = FuncPartnerSkin.getPartnerSkinBg(partnerId, garmentId)
            if skin then
                backGround = skin
            end
        end 
    end
    
    
    if data.back then
        if backGround == nil then
            backGround = data.back
        end
    end 

    if backGround then
        local path = backGround..".png"
        -- local bg = display.newSprite(path)
        -- bg:setAnchorPoint(cc.p(0.5,0.5))
        return path
    end
    return nil
end
-- 通过ID取伙伴音效
function FuncPartner.getPartnerSound(partnerId)
    local data = FuncPartner.getPartnerById(partnerId)
    if data.music then
        math.randomseed(os.time())
        return data.music[math.random(1,#data.music)]
    end
    -- echoError(partnerId.." 此奇侠表里没有音效")
    return nil
end


--------------------------------------------------------------------------
----------------------伙伴战力和属性计算对外接口--------------------------
--------------------------------------------------------------------------
-- 战力 
--skipMap  跳过算战力的系统 默认空
--[[
    skipMap = {
        quality,
        star = 1,
        skill,
        equip,
        baowu,
        taozhuang,
        love,
        skins,
        handbooks, 
    }


]]
function FuncPartner.getPartnerAbility(_partnerInfo, userData, formation,skipMap,expandMap)
    local lovesData = userData.lovesData
    local skins = userData.skins
    local power = FuncPartner.getPartnerAvatar(_partnerInfo, userData, formation,false,skipMap,expandMap)
    return power
end
-- 属性添加 阵位的属性  专属战斗
function FuncPartner.getPartnerAttribute( _partnerInfo,userData,formation )
    -- dump(userData, "\n\nuserData==FuncPartner.getPartnerAttribute=", 5)
    -- local skins = userData.skins
    -- local baowuData = userData.cimeliaGroups
    -- local lovesData = userData.loves
    -- local globalLoveData = userData.loveGlobal
    -- local guildSkillData = userData.guildSkills
    -- local memory = userData.memorys

    local siteAttr 
    if formation then
        siteAttr = FuncPartner.getTreasureSitAttr(_partnerInfo,userData,formation)
    else
        siteAttr = nil
    end
    local data = FuncPartner.getPartnerAttr(_partnerInfo,userData,siteAttr)

    return data
end

-- 获取该伙伴是否要添加 法宝阵位全局养成属性 
-- 要计算所有已拥有的法宝的全局养成属性
function FuncPartner.getTreasureSitAttr(_partnerInfo,userData,formation)
    local partnerId = _partnerInfo.id
    local attr = {}
    -- 先找到partner的阵位
    for i=1,6 do
        if tonumber(formation.partnerFormation["p"..i].partner.partnerId) == tonumber(partnerId) then
            -- local treasureId = FuncChar.getTreasureIdByFomation(userData,formation)
            local treasures = userData.treasures
            for ii,vv in pairs(treasures) do
                local treasureId = ii
                local treasureData = userData.treasures[treasureId]
                local trsSite= FuncTreasureNew.getTreasureDataById(treasureId).site
                local siteAttr = FuncTreasureNew.getTreaSiteAttr(treasureData)
                if i == 1 or i == 2 then
                    -- 前排
                    if trsSite == 1 then
                        table.insert(attr,siteAttr)
                    end
                elseif i == 3 or i == 4 then
                    -- 中排
                    if trsSite == 2 then
                        table.insert(attr,siteAttr)
                    end
                elseif i == 5 or i == 6 then
                    -- 后排
                    if trsSite == 3 then
                        table.insert(attr,siteAttr)
                    end
                end
            end
        end
    end
    return attr
end
-----------------------------------------------------------------------------------------
---------------------------------伙伴战力计算--------------------------------------------
-----------------------------------------------------------------------------------------
--计算伙伴的战力
--[[

expandMap = {
    handbooks = {
        1= 100,
        2= 100,
    }
}

]]

function FuncPartner.getPartnerAvatar(_partnerInfo,userData, formation, isLog,skipMap,expandMap)
    
    local lovesData = userData.lovesData or {}
    local skins = userData.skins 

    skipMap = skipMap or {}
    --基础数据
    local initAbility = 0
    local _base_data = FuncPartner.getPartnerById(_partnerInfo.id)
    initAbility = initAbility + _base_data.initAbility
    --品质带来的基础数据累加
    local qualityAbility = 0
    if not skipMap.quality then
        qualityAbility = FuncPartner.getPartnerQualityAbility( _partnerInfo )
    end

    --星级加成
    local starAbility = 0
    if not skipMap.star then
        starAbility =FuncPartner.getPartnerStarAbility( _partnerInfo )
    end
    --技能加成
    local skillAbility = 0
    if not skipMap.skill then
        skillAbility =FuncPartner.getPartnerSkillAbility( _partnerInfo )
    end

    -- 装备战力加成
    local equipsAbility = 0
    if not skipMap.equip then
        equipsAbility = FuncPartner.getPartnerEquipAbility( _partnerInfo )
    end


    local skinsAbility = 0
    if skins and table.length(skins) > 0 and (not skipMap.skins) then
        skinsAbility = FuncPartnerSkin.getEnabledSkinsAddAbility(skins, _partnerInfo.id)       
    end
    -- 单件宝物固定值 --宝物突破阶数补充值
    local baowuAbility = 0
    

    -- 装备套装
    local taozhuangAbility = 0

    -- 宝物战力固定值
    local baowuAbility = 0

    -- -- 情缘战力
    local lovePer  = 0
    -- 情缘固定值
    -- zgy 临时 --2017-10-11 16:06:53
    local lovelAbility2 = 0
    if not skipMap.love then
        lovelAbility2 = FuncNewLove.getMainPartnerCurrentLoveAddAbility(_partnerInfo) 
    end
    

    -- 被动技能万分比
    local skillPer = 0
    -- 套装放大万分比
    local taozhuangPer = 0

    -- 装备觉醒带来的战力
    local equipAwakPower = FuncPartner.getEquiAwakeAbility( _partnerInfo )

    -- 名册战力
    local handhookPower= 0
    -- echo(skipMap.handhook ,"___skipMap.handhook ")
    
    if not skipMap.handbooks  then
        -- local dir = FuncHandbook.getPartnerWorkingDir( _partnerInfo.id,userData )
        -- if dir and dir ~= "" then
        --     handhookPower = FuncHandbook.getPowerAdditionOnePartner( _partnerInfo,userData,dir )
        -- end
        local partnerConfigData = FuncPartner.getPartnerById(_partnerInfo.id)
        local dir1,dir2 = partnerConfigData.type,partnerConfigData.elements
        dir1 = FuncHandbook.Attack2DirType[tostring(dir1)]
        dir2 = FuncHandbook.Wuling2DirType[tostring(dir2)]
        local power1 
        local power2
        if expandMap and expandMap.handbooks then

            power1 = expandMap.handbooks[dir1] or 0
            power2 = expandMap.handbooks[dir2] or 0
        else
            power1 = FuncHandbook.getPowerAdditionOneDir( userData,dir1 )
            power2 = FuncHandbook.getPowerAdditionOneDir( userData,dir2 )
        end
        handhookPower = power1 + power2
        
    end
    -- echo("\n情缘战力=====", lovelAbility2, "伙伴战力 ID ==== ", _partnerInfo.id)
    -- echo("handhookPowe=======", handhookPower)

    local _ability = (initAbility + starAbility + qualityAbility ) *
                        (1 + lovePer ) + 
                        equipsAbility + skillAbility + lovelAbility2 + skinsAbility + 
                        equipAwakPower + handhookPower
    if isLog  then
        echo("伙伴战力 ID ==== ",_partnerInfo.id)
        echo("initAbility ===== ",initAbility)
        echo("starAbility ===== ",starAbility)
        echo("qualityAbility ===== ",qualityAbility)
        echo("equipsAbility ===== ",equipsAbility)
        echo("taozhuangPer ===== ",taozhuangPer)
        echo("lovePer ===== ",lovePer)
        echo("skillAbility ===== ",skillAbility)
        echo("skillPer ===== ",skillPer)
        echo("equipAwakPower ==== ",equipAwakPower)
        echo("handhookPowe=======", handhookPower)
        echo("skinsAbility=======", skinsAbility)
        echo("lovelAbility2=======", lovelAbility2)
        echo("总战力  === ",_ability)
    end
    
    -- -- 计算总战力加成
    return math.floor(_ability)
end

-- 计算伙伴星级战力
function FuncPartner.getPartnerStarAbility( _partnerInfo )
    _ability = 0
    local _star = _partnerInfo.star
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerInfo.id) 
    local _star_item = _star_table[tostring(_star)]
    _ability = _ability + _star_item.initLvAbility * (_partnerInfo.level - 1)
    --星级节点的加成
    for i = 1, (_star-1) do
        local _star_item = _star_table[tostring(i)]
        for _index=1,6 do
            if _star_item.initAddAbility then  --wk  传来了104  添加数据initAddAbility不存在的时候
                _ability = _ability + _star_item.initAddAbility[_index]
            else
                _ability = _ability      
            end
        end
    end

    for _index=1,_partnerInfo.starPoint do
        if _star_item.initAddAbility then --wk  传来了104  添加数据initAddAbility不存在的时候
            _ability = _ability + _star_item.initAddAbility[_index]
        else
            _ability = _ability
        end
    end
    -- echo(_partnerInfo.id .."伙伴星级战力 ======".._ability)
    return _ability
end
-- 计算伙伴品质战力
function FuncPartner.getPartnerQualityAbility( _partnerInfo )
    local _ability = 0
    local _quality = _partnerInfo.quality
    local _quality_table = FuncPartner.getPartnerQuality(_partnerInfo.id)
    
    for i=1,_quality do
        local _qualityData = _quality_table[tostring(i)]
        _ability = _ability + _qualityData.initAddAbility
    end
    
    for _index=1,_quality do
       local _quality_item = _quality_table[tostring(_index)]
       local _position = _index < _quality and 0xF or _partnerInfo.position
       --品质的装备位带来的属性加成
       if _position ~=nil and _position >0 then
           for _index=1,4 do
               --获取第_index的二进制位
               -- echo("_position === ",_position) 
               local bit = number.bitat(_position,4 - _index)
               if bit > 0 then
                   local _combine_item = FuncPartner.getConbineResById(_quality_item.pellet[_index])
    --                    echo("属性战力 增加 == ".._combine_item.ability .."id == ".._quality_item.pellet[_index])
                   _ability = _ability + _combine_item.initAddAbility
               end
           end 
       end
    end

    -- echo(_partnerInfo.id .."伙伴品质战力 ======".._ability)
    return _ability
end
-- 计算伙伴技能战力
function FuncPartner.getPartnerSkillAbility(_partnerInfo)
    local _ability = 0
    for _key1,_skillValue in pairs(_partnerInfo.skills)do
        local _skill_item = FuncPartner.getSkillInfo(_key1)
        _ability = _ability + _skill_item.lvAbility * _skillValue --乘以技能的等级
    end
    -- echo(_partnerInfo.id .."伙伴技能战力 ======".._ability)
    return _ability
end
-- 伙伴装备战力
function FuncPartner.getPartnerEquipAbility( _partnerInfo )
    local _ability = 0
    if _partnerInfo.equips then
        for _key1,_value1 in pairs(_partnerInfo.equips) do
            local equCfgData = FuncPartner.getEquipmentById(_value1.id)
            local equCfg = equCfgData[tostring(_value1.level)]
            local subAbility = equCfg.subAbility
            -- 判断此装备是否已觉醒
            if _value1.awake and _value1.awake == 1 then
                _ability = _ability + subAbility[2]
            else
                _ability = _ability + subAbility[1]
            end
        end
    end
    -- echo(_partnerInfo.id .."伙伴装备战力 ======".._ability)
    return _ability
end

-- 装备觉醒带来的战力
function FuncPartner.getEquiAwakeAbility( _partnerInfo )
    local ability = 0
    local equips = _partnerInfo.equips
    for i,v in pairs(equips) do
        if v.awake and v.awake == 1 then
            local awakeEquipId = FuncPartner.getAwakeEquipIdByid( _partnerInfo.id,v.id )
            ability = ability + FuncPartnerEquipAwake.getEquipAwakeAbility( awakeEquipId )
        end
    end

    return ability
end

-----------------------------------------------------------------------
---------------------------伙伴属性计算--------------------------------
-----------------------------------------------------------------------
--获取伙伴升品属性加成
function FuncPartner.getQualityAttr( _partnerInfo)
    local dataMap = {}
    local _quality = _partnerInfo.quality or 1
    local _quality_table = FuncPartner.getPartnerQuality(_partnerInfo.id)
    for _index=1,_quality do
        local _quality_item = _quality_table[tostring(_index)]
        if _quality_item.addAttr then
            for _key,_value in pairs(_quality_item.addAttr)do
                local _data = {
                    key = _value.key,
                    value = _value.value,
                    mode = _value.mode,
                }
                if tonumber( _value.mode) == 2 then
                    echo("品质带来的基础属性累加------------------")
                end
                table.insert(dataMap,{_data})
            end
        end

        --槽位
        local _position = _index < _quality and 0xF or _partnerInfo.position 
        --品质的装备位带来的属性加成
        if _position > 0 then
            for _index2 = 1, 4 do
                -- 获取第_index的二进制位
                local bit = number.bitat(_position, 4 - _index2)
                if bit > 0 then
                    local _combine_item = FuncPartner.getConbineResById(_quality_item.pellet[_index2])
                    for _key, _value in pairs(_combine_item.attr) do
                        local _data = {
                            key = _value.key,
                            value = _value.value,
                            mode = _value.mode,
                        }
                        if tonumber( _value.mode) == 2 then
                            echo("品质的装备位带来的属性加成------------------")
                        end
                        table.insert(dataMap, { _data })
                    end
                end
            end
        end
    end

    return dataMap
end

-- 获取伙伴星级属性加成
function FuncPartner.getStarAttr( _partnerInfo )
    local dataMap = {}
    local _star = _partnerInfo.star
    local _star_table = FuncPartner.getStarsByPartnerId(_partnerInfo.id)
    local _star_item = _star_table[tostring(_star)]
    for _key,_value in pairs(_star_item.subAttr)do
        local _data = {
            key = _value.key,
            value = _value.value * (_partnerInfo.level -  1),
            mode = _value.mode,
        }
        if tonumber( _value.mode) == 2 then
            echo("星级加成------------------")
        end
        table.insert(dataMap,{_data})
    end
    --星级节点的加成
    for i = 1,(_star-1) do
        local _star_item = _star_table[tostring(i)]
        for _index=1,6 do     
            local _attr_star_point = _star_item["addAttr".._index]
            for i,v in pairs(_attr_star_point) do
                local _data = {
                    key = v.key,
                    value = v.value,
                    mode = v.mode,
                }
                if tonumber( v.mode) == 2 then
                    echo("星级节点的加成------------------")
                end
                table.insert(dataMap,{_data})
            end
        end
    end
    if _star_item.addAttr1 then
        -- _star_item.addAttr为空的时候是满星状态
        for _index=1,_partnerInfo.starPoint do
            local _attr_star_point = _star_item["addAttr".._index]
            for i,v in pairs(_attr_star_point) do
                local _data = {
                    key = v.key,
                    value = v.value,
                    mode = v.mode,
                }
                if tonumber( v.mode) == 2 then
                    echo("星级节点的加成------------------")
                end
                table.insert(dataMap,{_data})
            end
        end
    end

    return dataMap
end

-- 获得伙伴技能属性加成
function FuncPartner.getSkillAttr( _partnerInfo )
    local dataMap = {}
    if _partnerInfo.skills then
        for _key1,_skillValue in pairs(_partnerInfo.skills)do
            local _skill_item = FuncPartner.getSkillInfo(_key1)
            if _skill_item.kind ==2 or _skill_item.kind == 3 then --只有类型为2的表格数据才会被累加
                for _key2,_value2 in pairs(_skill_item.lvAttr)do
                    local _value3 = _skill_item.initAttr[_key2]
                    local _data = {
                        key =_value2.key,
                        value =_value3.value + _value2.value * _skillValue,
                        mode = _value2.mode,
                    }
                    if tonumber( _value2.mode) == 2 then
                        echo("技能加成------------------")
                    end
                    table.insert(dataMap,{_data})
                end
            end
        end
    end
    return dataMap
end
-- 获得伙伴装备技能加成
function FuncPartner.getEquipsAttr( _partnerInfo )
    local dataMap = {}
    local aa = {}
    if _partnerInfo.equips then
        for _key1,_value1 in pairs(_partnerInfo.equips) do
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

            -- 装备带来的属性
            if _value1.awake then
                local awakeEquipId = FuncPartner.getAwakeEquipIdByid( _partnerInfo.id,_value1.id )
                local shuxing = FuncPartnerEquipAwake.getEquipAwakeAttr( awakeEquipId )
                for _key2,_value2 in pairs(shuxing)do 
                    local _data = {
                        key = _value2.key,
                        value = _value2.value,
                        mode = _value2.mode,
                    }
                    table.insert(aa,{_data})
                    table.insert(dataMap,{_data}) 
                end
            end
        end
    end
    -- dump(aa, "觉醒加的属性=========", 5)
    return dataMap
end

-- 获得伙伴皮肤属性加成
function FuncPartner.getSkinAttr(skins, partnerId)
    local dataMap = {}
    if skins and table.length(skins) > 0 then
        for k,v in pairs(skins) do
            -- 判定皮肤过没过期  -1表示永久拥有
            if tonumber(v) > 0 or tonumber(v) == -1  then
                local id = FuncPartnerSkin.getValueByKey(k, "partnerId")
                if tostring(id) ==  tostring(partnerId) then
                    local _skinData = FuncPartnerSkin.getPartnerSkinById(k)
                    local _attr = _skinData.attr
                    -- echo("皮肤ID =-=-=== ",v)
                    -- dump(_attr, "皮肤属性--------")
                    for _key2,_value2 in pairs(_attr)do 
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
    return dataMap
end

function FuncPartner.getInitAttr( _partnerInfo )
    local dataMap = {}
    local _base_data = FuncPartner.getPartnerById(_partnerInfo.id)
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

--计算伙伴所需
function FuncPartner.getPartnerAttrByUserData( _partnerInfo,userData )
    local skins = userData.skins
    local baowuData = userData.cimeliaGroups
    local lovesData = userData.loves
end

--获取给定伙伴的所有属性加成
--不允许外部调用--  一定得用FuncPartner.getPartnerAttribute这个方法获取战斗属性
function FuncPartner.getPartnerAttr(_partnerInfo,userData,siteAttr)
    local dataMap = {}
    -- 对传进来的数据进行判断
    local skins = userData.skins or {}
    local baowuData = userData.cimeliaGroups or {}
    local lovesData = userData.loves or {}
    local guildSkillData = userData.guildSkills
    local memory = userData.memorys
    local handbooks = userData.handbooks
    ---------基本属性----------------
    --初始属性
    local initAttr = FuncPartner.getInitAttr( _partnerInfo ) or {}
    for i,v in pairs(initAttr) do
        table.insert(dataMap, v)
    end
    --品质带来的基础属性累加
    local qualityAttr = FuncPartner.getQualityAttr(_partnerInfo) or {}
    for i,v in pairs(qualityAttr) do
        table.insert(dataMap, v)
    end
    --星级加成
    local starAttr = FuncPartner.getStarAttr(_partnerInfo) or {}
    for i,v in pairs(starAttr) do
        table.insert(dataMap, v)
    end

    ----------属性万分比加成----------------
    --情缘万分比
    -- zgy 临时 --2017-10-11 16:06:53
    local loveAttr2 = FuncNewLove.getMainPartnerCurrentLoveProperty(_partnerInfo) or {}
    -- dump(loveAttr2,"xin情缘属性万分比")
    for i,v in pairs(loveAttr2) do
        table.insert(dataMap,{v})
    end

    --无极阁加成万分比
    local guildAttr2 = FuncGuild.getGuildAddProperty(_partnerInfo,guildSkillData) or {}
    dump(guildAttr2,"仙盟无极阁加成====")
    for i,v in pairs(guildAttr2) do
        table.insert(dataMap,{v})
    end

    --宝物万分比
    local baowuAttr = FuncArtifact.getAllArtifactAttr(baowuData,tostring(_partnerInfo.id)) or {}
    for i,v in pairs(baowuAttr) do
        table.insert(dataMap,{v})
    end
    --被动技能万分比
    local bdSkillAttr = {}
    for i,v in pairs(bdSkillAttr) do
        table.insert(dataMap,v)
    end
    --套装放大万分比
    local taozhuangAttr = {}
    for i,v in pairs(taozhuangAttr) do
        table.insert(dataMap,v)
    end
    ------------固定属性加成---------------------

    --技能加成
    local skillAttr = FuncPartner.getSkillAttr( _partnerInfo ) or {}
    for i,v in pairs(skillAttr) do
        table.insert(dataMap, v)
    end
    -- 伙伴装备加成
    local equipsAttr = FuncPartner.getEquipsAttr( _partnerInfo ) or {}
    for i,v in pairs(equipsAttr) do
        table.insert(dataMap, v)
    end

    -- 战斗的专属属性 法宝阵位
    if siteAttr then        
        for i,v in pairs(siteAttr) do
            for ii,vv in pairs(v) do
                table.insert(dataMap, vv)
            end
        end
    end
    
    -- dump(skins, "\n\nskins====")
    --伙伴皮肤属性加成 -- 暂时没有皮肤
    local skinsAttr = FuncPartner.getSkinAttr(skins, _partnerInfo.id) or {}
    -- dump(skinsAttr, "\n\nskinsAttr====")
    for i,v in pairs(skinsAttr) do
        for ii,vv in pairs(v) do
            table.insert(dataMap, {vv})
        end
        -- table.insert(dataMap, v)
    end

    --情景卡加成
    local memoryAttr = FuncMemoryCard.getAttrByPartnerId( _partnerInfo.id ,memory ) or {}
    for i,v in pairs(memoryAttr) do
        table.insert(dataMap, {v})
    end

    -- 名册属性加成
    local handbooksAttr = FuncHandbook.getHandbookAddProperties(userData,_partnerInfo.id)
    for i,v in pairs(handbooksAttr) do
        table.insert(dataMap, {v})
    end

    return FuncBattleBase.countFinalAttr(unpack( dataMap) )
end

-- 合并属性
function FuncPartner.countFinalAttr(attrGroup1,attrGroup2,... )
    local allGroups  = {attrGroup1,attrGroup2,...}
    local attrDataMap = {} 

    for i,v in pairs(allGroups) do
        local isHas = false
        for ii,vv in pairs(attrDataMap) do
            if vv.key == v.key then
                vv.value = vv.value + v.value
                isHas = true
            end
        end
        if not isHas then
            table.insert(attrDataMap,v)
        end
    end
    return attrDataMap
end

------------------------------------------------------------------------------------
---------------------------技能的相关描述-------------------------------------------
---------------------------------start----------------------------------------------
function FuncPartner.getPartnerSkillKind2Attr(_skill_item,_skill_level)
    local level = _skill_level
    local _attrMap = {}
    if _skill_item.lvAttr then
        for _key,_value in pairs(_skill_item.lvAttr)do
            local _attr_item = {
                key = _value.key,
                value = _value.value * level + _skill_item.initAttr[_key].value, --lv * _value.value + _base
                mode = _value.mode,
            }
            table.insert( _attrMap,_attr_item)
        end
    elseif _skill_item.subAttr then
        for _key,_value in pairs(_skill_item.subAttr)do
            local _attr_item = {
                key = _value.key,
                value = _value.value ,
                mode = _value.mode,
            }
            table.insert( _attrMap,_attr_item)
        end
    end
    
    return _attrMap
end

--如果是展示用  isShow需要传true
function FuncPartner.getPartnerSkillKind1Attr(_skill_item,_skill_level,isShow)
    local level = _skill_level
    local _attrMap = {}
    local _shuxingMap = {}
    for i = 1, 12 do
        _shuxingMap[i] = 0
    end
    for _key,_value in pairs(_skill_item.growType) do
        local a = 0
        local b = 0
        if _value == 1 then
            a = _skill_item.growDmg[1] * level + _skill_item.growDmg[2]
            b = _skill_item.growDmg[3] * level + _skill_item.growDmg[4]

            _shuxingMap[1] = a
            _shuxingMap[2] = b
            if isShow then
                _shuxingMap[1] = math.abs(a) / 10000 * 100
                _shuxingMap[2] = math.abs(b)
            end
            
        elseif _value == 2 then
            a = _skill_item.growTreat[1] * level + _skill_item.growTreat[2]
            b = _skill_item.growTreat[3] * level + _skill_item.growTreat[4]

            _shuxingMap[3] = a
            _shuxingMap[4] = b
            if isShow then
                _shuxingMap[3] = math.abs(a) / 10000 * 100
                _shuxingMap[4] = math.abs(b)
            end
        elseif _value == 3 then
            local desIndex = 4
            for _index=1, #_skill_item.growOther, 2 do
                desIndex = desIndex + 1
                local temp = _skill_item.growOther[_index] * level + _skill_item.growOther[_index + 1]

                _shuxingMap[desIndex] = temp
                if isShow then
                    if math.fmod(desIndex, 2) == 0 then
                        _shuxingMap[desIndex] = math.abs(temp)
                    else
                        _shuxingMap[desIndex] = math.abs(temp) / 10000 * 100
                    end
                end                   
            end
        end
    end
    -- 大招扩充
    local dazhaoMap = {}
    if _skill_item.growSupply then 
        for i = 1,#_skill_item.growSupply,2 do 
            local dazhaoB = _skill_item.growSupply[i] *level+_skill_item.growSupply[i+1]
            local a,b = math.modf((i+1)/2)
            if a < 5 then
                table.insert(dazhaoMap, math.abs(dazhaoB))
            else
                local a1,b1 = math.modf(a/2)
                if b1 == 0 then
                    table.insert(dazhaoMap, math.abs(dazhaoB))
                else
                    table.insert(dazhaoMap, math.abs(dazhaoB/100))
                end
            end

        end
    end

    return _shuxingMap,dazhaoMap
end
function FuncPartner.getPartnerSkillKind3Attr(_skill_item,_skill_level,_isShow)
    local _gudingMap = FuncPartner.getPartnerSkillKind2Attr(_skill_item,_skill_level)
    local _shuxingMap,_dazhaoMap = FuncPartner.getPartnerSkillKind1Attr(_skill_item,_skill_level,_isShow)
    return _gudingMap,_shuxingMap,_dazhaoMap
end
--注意  此部分是神器的怒气
--[[
怒气变化增量值，每级替换；“
p1 = 怒气初始值增量； 
p2 = 怒气最大值增量；
p3 = 怒气每回合恢复最大量增值；”
]]
function FuncPartner.getPartnerSkillKind4Attr(_skill_item)
    local _enerMap = {}
    local enerData = _skill_item.growEnergy or {}
    _enerMap[1] = enerData[1] or 0
    _enerMap[2] = enerData[2] or 0
    _enerMap[3] = enerData[3] or 0
    return _enerMap
end
-- 换灵相关数据
function FuncPartner.getPartnerSkillKind5Attr(_skill_item)
    
    local lvl = _skill_item.growFiveSoul or {}

    local fiveSoul = {}
    for i=1,5 do
        local data = FuncWuLing.getWuLingChange(i,lvl)

        fiveSoul[i] = data
    end
    -- dump(fiveSoul, "--------333333333--------", 4)
    return fiveSoul
end
-- 给定伙伴的技能id,以及技能等级,返回技能的属性描述
function FuncPartner.getPartnerSkillDesc(_skillId,_skill_level)
    local _skill_item = FuncPartner.getSkillInfo(_skillId)
    return FuncPartner.getCommonSkillDesc(_skill_item,_skill_level)
end

-- 技能的通用描述 
function FuncPartner.getCommonSkillDesc(_skillCfg,_skill_level,des)
    local _skill_item = _skillCfg
    --关于该技能对角色的属性的提升
    local _final_content
    local level = _skill_level

    local desCfg = des
    if not desCfg  then
        desCfg = _skill_item.describe2
    end

    local percentKeyArr = {
        Fight.value_crit,Fight.value_resist,Fight.value_critR,
        Fight.value_block,Fight.value_wreck,Fight.value_blockR,
        Fight.value_injury,Fight.value_avoid,Fight.value_limitR,
        Fight.value_guard,Fight.value_buffHit,Fight.value_buffResist,
    }
    local shuxingFunc = function (attr)
        local T = {}
        for i,v in pairs(attr) do
            local value = 0;
            -- 已经确认只配一种属性
            local model = attr[i].mode
            local _per = 1
            local attrData = FuncBattleBase.getAttributeData(attr[i].key)
            local attrKeyName = attrData.keyName
            if table.indexof(percentKeyArr,attrKeyName ) then
                _per = 100
            end
            if model == 1 then -- 基础属性
                value = attr[i].value / _per
            elseif model == 2 then -- 万分比
                value = attr[i].value * 100 / 10000
            elseif model == 3 then -- 固定值
                value = attr[i].value / _per
            elseif model == 4 then -- 成长系数
                value = attr[i].value / 10000
            end
            table.insert(T,math.abs(value))
        end
    
        
        return T
    end
    if _skill_item.kind == 2 then--固定属性
        local _attrMap = FuncPartner.getPartnerSkillKind2Attr(_skill_item,level)
        _final_content = GameConfig.getLanguageWithSwap(desCfg,unpack(shuxingFunc(_attrMap)))
        _final_content = GameConfig.getLanguageWithSwapForSkillKind3(_final_content,unpack(shuxingFunc(_attrMap)))
    elseif _skill_item.kind == 1 then
        local _shuxingMap,_dazhaoMap = FuncPartner.getPartnerSkillKind1Attr(_skill_item,_skill_level,true)
        _final_content = GameConfig.getLanguageWithSwap(desCfg,unpack(_shuxingMap))
        _final_content = GameConfig.getLanguageWithSwapForSkillDazhao(_final_content,unpack(_dazhaoMap))
    elseif _skill_item.kind == 3 then -- 固定属性加成长属性
        local _attrMap,_shuxingMap,_dazhaoMap = FuncPartner.getPartnerSkillKind3Attr(_skill_item,_skill_level,true)
        _final_content = GameConfig.getLanguageWithSwap(desCfg,unpack(_shuxingMap))
        _final_content = GameConfig.getLanguageWithSwapForSkillDazhao(_final_content,unpack(_dazhaoMap))
        _final_content = GameConfig.getLanguageWithSwapForSkillKind3(_final_content,unpack(shuxingFunc(_attrMap)))
    elseif _skill_item.kind == 4 then -- 
        local attrT = _skill_item.growEnergy
        if attrT == nil then
            attrT = {}
        end
        _final_content = GameConfig.getLanguageWithSwap(desCfg,unpack(attrT))
        local _shuxingMap = FuncPartner.getPartnerSkillKind2Attr(_skill_item,_skill_level)
        _final_content = GameConfig.getLanguageWithSwapForSkillKind3(_final_content,unpack(shuxingFunc(_shuxingMap)))
    elseif _skill_item.kind == 5 then -- 
        local lvl = _skill_item.growFiveSoul

        _final_content = GameConfig.getLanguageWithSwap(desCfg,lvl)
    end
    return _final_content
end
--------------------------------------------------------------------------------------------
----------------------------------------end-------------------------------------------------
--------------------------------------------------------------------------------------------


--获取sourceid
function FuncPartner.getSourceId( _partnerId )
  local partnerData  = FuncPartner.getPartnerById(_partnerId)
  if not partnerData.sourceld  then
    echoWarn("这个英雄没有配sourceId:",_partnerId)
  end
  return partnerData.sourceld 
end

-- 装备觉醒换装
function FuncPartner.checkAllEquipsAwake( partnerData )
    local equips = partnerData.equips
    local awake = false
    if equips then
        awake = true
        for k,v in pairs(equips) do
            if not v.awake then
                return false
            end
        end
    end
    return awake
end

function FuncPartner.getPartnerAwakenWeapon(_partnerId)
    if FuncPartner.isChar(_partnerId) then
        local data = FuncChar.getHeroData(_partnerId)
        return data.equipmentAwakeWeapon
    else
        local data = FuncPartner.getPartnerById(_partnerId)
        return data.equipmentAwakeWeapon
    end
end

--获取英雄的spine , iswhole是否是整个spine 默认是精简版的spine
function FuncPartner.getHeroSpine(_partnerId,iswhole,awakenWeapon )
    local sourceId =  FuncPartner.getSourceId( _partnerId )
    local sourceCfg = FuncTreasure.getSourceDataById(sourceId)
    local spineName = nil
    local spbName = nil
    if sourceCfg == nil then
        spbName = "30004_zhaolinger"
        echoError("_partnerId".." 此伙伴立绘没找到")
    else
        spineName = sourceCfg.spine 
        spbName = spineName
    end
    local spineName = sourceCfg.spine 
    local spbName = spineName
    if not iswhole then
        spbName = spbName .. "Extract";
    end
    local charView = ViewSpine.new(spbName, {}, nil, spineName,nil,sourceCfg);
    charView.actionArr = sourceCfg
    charView:playLabel(charView.actionArr.stand, true);

    if awakenWeapon then
        charView:changeAttachmentByFrame(awakenWeapon)
    end
    return charView
end

function FuncPartner.isInitProperty(_type) 
    if tonumber(_type) == 2 then
        return true , "hp"
    elseif tonumber(_type) == 10 then
        return true , "act" 
    elseif tonumber(_type) == 11 then
        return true , "def"
    elseif tonumber(_type) == 12 then
        return true , "magicDef"
    else
        return false ,nil
    end
end

------------------------------------------------------------------------------
-------------------------------奇侠的音效-------------------------------------
------------------------------------------------------------------------------
--伙伴音效 
function FuncPartner.playPartnerBtnSound()
--    AudioModel:playSound(MusicConfig.s_partner_outfit)
end
-- 伙伴右侧导航栏
function FuncPartner.playPartnerTopBtnSound()
   AudioModel:playSound(MusicConfig.s_partner_topbtn)
end
-- 伙伴列表
function FuncPartner.playPartnerBtnsSound()
   AudioModel:playSound(MusicConfig.s_partner_btns)
end
 --伙伴升级消耗音效
function FuncPartner.playPartnerLevelUpSound()
    AudioModel:playSound(MusicConfig.s_partner_shengji)
end
--伙伴技能升级音效
function FuncPartner.playPartnerSkillLevelUpSound()
    AudioModel:playSound(MusicConfig.s_partner_jineng)
end
--伙伴升星小阶段
function FuncPartner.playPartnerUpstarPointSound( )
    AudioModel:playSound(MusicConfig.s_partner_upstarpoint)
end
--伙伴升星
function FuncPartner.playPartnerUpstarSound( )
    AudioModel:playSound(MusicConfig.s_partner_upstar)
end
--伙伴合成
function FuncPartner.playPartnerCombineSound( )
    AudioModel:playSound(MusicConfig.s_partner_combine)
end
--升品成功
function FuncPartner.playPartnerShengPinSound( )
    AudioModel:playSound(MusicConfig.s_partner_shengpin)
end
--升品装备位
function FuncPartner.playPartnerShengPinPointSound( )
    AudioModel:playSound(MusicConfig.s_partner_shengpinpoint)
end
--奇侠装备强化进阶
function FuncPartner.playPartnerZhangbeiqianghuaSound( )
    AudioModel:playSound(MusicConfig.s_partner_zhuangbeiqianghua)
end
--奇侠详情音效
function FuncPartner.playPartnerInfoSound( )
    AudioModel:playSound(MusicConfig.s_partner_info)
end
--奇侠红点UI中红点开关音效
function FuncPartner.playPartnerRedBtnSound( )
    AudioModel:playSound(MusicConfig.s_partner_redbtn)
end

-------------------------------------------------------------------------------
-----------------------------------end-----------------------------------------
-------------------------------------------------------------------------------

-- 通过伙伴id和skin 取得sourceid 
function FuncPartner.getPartnerSourceidByIdAndSkin(partnerId,skin)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        if skin == "" or not skin  then
            skin = FuncPartnerSkin.getSuYanSkinId(partnerId)
        end
        return FuncPartnerSkin.getPartnerSkinSourceId(tostring(skin))
    else
        local partnerCfg = FuncPartner.getPartnerById(partnerId)
        return partnerCfg.sourceld
    end
end
-- 通过伙伴id和skin 取得treasureId 
function FuncPartner.getPartnerTreasureIdByIdAndSkin(partnerId,skin)
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(partnerId)]
    if data then
        if skin == "" or not skin  then
            skin = FuncPartnerSkin.getSuYanSkinId(partnerId)
        end
        return FuncPartnerSkin.getPartnerSkinTreasureId(tostring(skin))
    else
        local partnerCfg = FuncPartner.getPartnerById(tostring(partnerId))
        return partnerCfg.treasureId
    end
end

--获取英雄的spine , iswhole是否是整个spine 默认是精简版的spine
function FuncPartner.getHeroSpineByPartnerIdAndSkin(_partnerId,skin,iswhole,partnerData)
    _partnerId = tostring(_partnerId)

    local awakenWeapon = nil
    if partnerData then
        local isAwaken = FuncPartner.checkWuqiAwakeSkill( partnerData )
        if isAwaken then
            awakenWeapon = FuncPartner.getPartnerAwakenWeapon( _partnerId )
        end
    end
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(_partnerId)]
    if data then -- 有皮肤的伙伴
        if skin == "" or not skin  then
            skin = FuncPartnerSkin.getSuYanSkinId(_partnerId)
        end
        return FuncPartnerSkin.getHeroSpine(tostring(skin),iswhole,awakenWeapon)
    else  -- 没有皮肤的伙伴
        local spinView = FuncPartner.getHeroSpine(_partnerId,iswhole,awakenWeapon)
        return spinView
    end
end
-- 获取伙伴或者主角的立绘
function FuncPartner.getPartnerOrCgarLiHui( _partnerId,skin,label)
    if tonumber(_partnerId) > 5000 then
        return FuncPartner.getPartnerLiHuiByIdAndSkin( _partnerId,skin,label )
    else
        local avatarId = tostring(_partnerId);
	    return FuncGarment.getCharGarmentLihui( skin,avatarId ,label)
    end
end
-- 获取伙伴立绘 通过伙伴ID和skin 
function FuncPartner.getPartnerLiHuiByIdAndSkin( _partnerId,skin ,label)
    _partnerId = tostring(_partnerId)
    local bossConfig 
    local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
    local data = partnerSkinT[tostring(_partnerId)]
    if data then -- 有皮肤的伙伴
        if skin == "" or not skin  then
            skin = FuncPartnerSkin.getSuYanSkinId(_partnerId)
        end
        bossConfig = FuncPartnerSkin.getValueByKey( skin,"dynamic")
    else  -- 没有皮肤的伙伴
        local partnerData = FuncPartner.getPartnerById(_partnerId);
        bossConfig = partnerData.dynamic
    end

    local arr = string.split(bossConfig, ",");
   -- local sp = ViewSpine.new(arr[1], {}, arr[1]);
    local sp = FuncRes.getArtSpineAni(arr[1],label)
   -- local sp = FuncPartner.getHeroSpine(_partnerId)
    if label then
        return sp
    end
    if arr[3] == "1" then 
        sp:setRotationSkewY(180);
    end 
    -- if tostring(_partnerId) == "5022" then
    --     dump(arr, "赵灵儿  位置---------")
    -- end
    if arr[4] ~= nil then -- 缩放
        local scaleX = tonumber(arr[4])
        local scaleY = scaleX
        if scaleY < 0 then
            scaleY = 0 - scaleY  
        end
        sp:setScaleX(-scaleX)
        sp:setScaleY(scaleY)
    end
    if arr[5] ~= nil then -- x轴偏移
        sp:setPositionX(sp:getPositionX() + tonumber(arr[5]))
    end
    if arr[6] ~= nil then -- y轴偏移
        sp:setPositionY(sp:getPositionY() + tonumber(arr[6]))
    end
    return sp
end
-- 通过伙伴ID和skin 获得伙伴的头像
function FuncPartner.getPartnerIconByIdAndSkin(_partnerId, skin)
    _partnerId = tostring(_partnerId)
    local iconName 
    local _spriteIcon  
    -- echo("伙伴皮肤 --------_partnerId-",_partnerId)
    if FuncPartner.isChar(_partnerId) then
        _spriteIcon = FuncGarment.getGarmentIcon(skin, _partnerId)
    else
        local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
        local data = partnerSkinT[tostring(_partnerId)]
        if data then -- 有皮肤的伙伴
            if skin == "" or not skin  then
                skin = FuncPartnerSkin.getSuYanSkinId(_partnerId)
            end
            iconName = FuncPartnerSkin.getValueByKey(skin,"iconId")

            -- echoError("伙伴皮肤 --------iconId-",iconName, "skin==", skin)
        else  -- 没有皮肤的伙伴
            local partnerData = FuncPartner.getPartnerById(_partnerId);
            iconName = partnerData.icon
            -- echo("伙伴 --------icon-",iconName)
        end
        local _iconPath = FuncRes.iconHero(iconName)
        _spriteIcon = cc.Sprite:create(_iconPath)
    end
    

    

    return _spriteIcon
end

-- 通过伙伴ID和skin 获得伙伴卡牌立绘 信息
function FuncPartner.gerPartnerCardCfg( _partnerId,skin  )
    _partnerId = tostring(_partnerId)
    local cardCfg 
    if FuncPartner.isChar(_partnerId) then
        local garmentId = FuncGarment.DefaultGarmentId
        if UserExtModel:garmentId() and UserExtModel:garmentId() ~= "" then
            garmentId = UserExtModel:garmentId()
        end
        local avatarId = UserModel:avatar()
        return FuncGarment.getValueByKey(garmentId, avatarId, "art")
    else
        local partnerSkinT = FuncPartnerSkin.getPartnerSkinTable()
        local data = partnerSkinT[tostring(_partnerId)]
        echo("伙伴皮肤 --------_partnerId-",_partnerId)
        if data then -- 有皮肤的伙伴
            if skin == "" or not skin  then
                skin = FuncPartnerSkin.getSuYanSkinId(_partnerId)
            end
            cardCfg = FuncPartnerSkin.getValueByKey( skin,"order")

        else  -- 没有皮肤的伙伴
            local partnerData = FuncPartner.getPartnerById(_partnerId);
            cardCfg = partnerData.order
        end
    end
    

    return cardCfg
end

-- 武器装备觉醒技能
function FuncPartner.getWuqiAwakeSkill(_partnerInfo)
    local awake,skillInfo = FuncPartner.checkWuqiAwakeSkill(_partnerInfo)
    return awake,skillInfo
end

function FuncPartner.checkPartnerEquipSkill(_partnerInfo,_star,_treasureId)
    _star = _star or _partnerInfo.star
    local equips = _partnerInfo.equips
    if not equips or table.length(equips) == 0 then
        echoWarn("此奇侠信息中没有 装备信息")
        return false
    end
    local jiesuo = true
    if _star >= 4 then
        for i,v in pairs(equips) do
            if not v.awake or v.awake ~= 1 then
                jiesuo = false
                break
            end
        end
    else
        jiesuo = false
    end
    
    local partnerId = nil
    if _partnerInfo.avatar then
        partnerId = _partnerInfo.avatar
    else
        partnerId = _partnerInfo.id
    end
    if FuncPartner.isChar(partnerId) then
        -- 判断男女
        local dataCfg = FuncTreasureNew.getTreasureDataById(_treasureId)
        local _awakSkillId
        if tonumber(partnerId) == 101 then
            _awakSkillId = dataCfg.awakeSkillId[1]
        else
            _awakSkillId = dataCfg.awakeSkillId[2]
        end
        local awakeSkillData = FuncTreasureNew.getTreasureSkillDataDataById(_awakSkillId)
        return jiesuo,awakeSkillData
    else
        local partnerCfg = FuncPartner.getPartnerById(partnerId)
        
        local awakeSkillData = FuncPartner.getSkillInfo(partnerCfg.awakeSkillId)
        return jiesuo,awakeSkillData
    end   
end

-- 判读 武器装备技能 是否解锁
function FuncPartner.checkWuqiAwakeSkill(_partnerInfo)
    -- 登仙台时候这个地方报错，加了兼容
    if not _partnerInfo.id then
        return false
    end
    local equips = _partnerInfo.equips or {}
    if not _partnerInfo.id then
        _partnerInfo.id = _partnerInfo.avatar
    end
    local wuqiId = FuncPartner.getPartnerWuqiId(_partnerInfo.id)
    -- echo("_partnerInfo.id == ",_partnerInfo.id)
    local dataCfg = FuncPartner.getPartnerById(_partnerInfo.id)
    local skillId = dataCfg.weaponAwakeSkillId
    if FuncPartner.isChar(_partnerInfo.id) then
        skillId = dataCfg.awakeSkillId
    end
    echo("wuqi jineng  === ",skillId)
    local skillCfg = FuncPartner.getSkillInfo(skillId)

    for i,v in pairs(equips) do
        if i == wuqiId then
            if v.awake then
                return true,skillCfg
            end
        end
    end


    return false,skillCfg
end
-- 获取奇侠武器装备Id
function FuncPartner.getPartnerWuqiId(partnerId)
    if FuncPartner.isChar(partnerId) then
        local dataCfg = FuncChar.getCharInitData()
        local equips = dataCfg.equipment
        return equips[1]
    end
    local dataCfg = FuncPartner.getPartnerById(partnerId)
    local equips = dataCfg.equipment
    return equips[1]
end 

-- 通过伙伴信息 获得技能详情
function FuncPartner.getPartnerSkillParams(_partnerInfo,_treasureT)
    -- dump(_partnerInfo, "+++++++++++", 4)

    local data = FuncPartner.getPartnerById(tostring(_partnerInfo.id))
    local skillsCfg = data.skill
    local _star = _partnerInfo.star
    local _treasureId = nil
    if FuncPartner.isChar(_partnerInfo.id) then
        _treasureId = _treasureT.treaId
        _star = _treasureT.star
        local treasureSkill = table.deepCopy(FuncTreasureNew.getTeasureSkillsByIdAndAvatar(_treasureId,_partnerInfo.id))
        table.insert(treasureSkill, data.skill[1])
        -- 全觉醒的技能
        local allAwakeSkillId = FuncTreasureNew.getTreasureAwakeSkillId(_treasureId,tostring(_partnerInfo.id))
        table.insert(treasureSkill, allAwakeSkillId)
        -- 添加武器装备觉醒的skill
        table.insert(treasureSkill, data.awakeSkillId)
        skillsCfg = treasureSkill
    else
        -- 全觉醒的技能
        skillsCfg = table.deepCopy(skillsCfg)
    end

    local skills = table.deepCopy(_partnerInfo.skills)
    -- dump(skills, "\n\nskills=====")
    local _skillParams = {}
    -- dump(skillsCfg,"all skill --- ",5)
    -- 寻找大招 有可能被替换
    local __skills = {}
    local skillDazhao = nil
    local defaultDazhao = nil
    local dazhao = nil
    local dazhao1 = nil
    local dazhao2 = nil
    local xiaoSkill = nil
    local jxSkill = nil
    for i,v in pairs(skillsCfg) do
        local skillCfg = nil
        if FuncPartner.isChar(_partnerInfo.id) then
            -- 主角小技能
            local skillId = data.skill[1]
            local awakeSkillId = data.awakeSkillId
            if skillId == v then
                skillCfg = FuncPartner.getSkillInfo(v)
            elseif awakeSkillId == v then
                skillCfg = FuncPartner.getSkillInfo(v)
                if skills[v] then
                    jxSkill = skillCfg
                end
            else
                skillCfg = FuncTreasureNew.getTreasureSkillDataDataById(v)
                skillCfg.id = tostring(skillCfg.id)
            end
        else
            skillCfg = FuncPartner.getSkillInfo(v)
            if skills[v] and v == data.weaponAwakeSkillId then
                jxSkill = skillCfg
            end
        end
        
        if skillCfg.priority == 1 and skillCfg.order == 3 then
            defaultDazhao = skillCfg
            dazhao = defaultDazhao
        end
        if skillCfg.priority == 1 and skillCfg.order == 2 then
            xiaoSkill = skillCfg
        end
        
        if skillCfg.priority and skillCfg.order == 3 and skills[v] then
            if defaultDazhao.priority < skillCfg.priority then
                defaultDazhao = skillCfg
                if skillCfg.priority == 2 then
                    dazhao1 = skillCfg
                elseif skillCfg.priority == 3 then
                    dazhao2 = skillCfg
                end
            end
        elseif not skillCfg.priority then 
            table.insert(__skills, skillCfg)
        end
    end
    table.insert(__skills, (jxSkill or xiaoSkill))
    table.insert(__skills, defaultDazhao)
    -- dump(defaultDazhao,"defaultDazhao--- ",8)
    -- dump(__skills,"所有的技能--- ",8)
    -- dump(jxSkill, "\n\njxSkill====")
    -- dump(xiaoSkill, "\n\nxiaoSkill-====")
    -- 排序
    function skillSort( a,b )
        if not a.order then
            echoError("伙伴技能 === ".. a.id .. "  没有配order")
        end
        if not a.order then
            echoError("伙伴技能 === ".. b.id .. "  没有配order")
        end
        if a.order < b.order then
            return true
        end
        return false
    end
    table.sort(__skills,skillSort)
    for i,v in pairs(__skills) do
        local _param = {}
        local skillCfg = v
        local skillId = v.id
        _param.hid = v.id;
        _param.battleSkillId = FuncPartner.battleSkillMapSkillId(_partnerInfo,skillCfg,_treasureId,_star)


        if skills[tostring(v.id)] then
            local skillLevel = skills[v.id]
            if (dazhao and skills[dazhao.id]) and
            ((dazhao1 and v.id == dazhao1.id) or (dazhao2 and v.id == dazhao2.id)) then 
                skillLevel = skills[dazhao.id]
            end
            if jxSkill and (skills[xiaoSkill.id] and v.id == jxSkill.id) then
                skillLevel = skills[xiaoSkill.id]
            end
            _param.skillParams  = {};
            -- 判断是否是大招 大招数据用 默认大招加上大招扩充值
            for i=1,4,2 do
                if skillCfg.growDmg then
                    local m1 = skillCfg.growDmg[i] * skillLevel + skillCfg.growDmg[i+1] 
                    if skillCfg.order == 3 and skillCfg.priority and skillCfg.growSupply  then
                        if dazhao1 and skills[dazhao1.id] then 
                            m1 = m1 + dazhao1.growSupply[i] *  skills[dazhao1.id] + dazhao1.growSupply[i+1]
                        end
                        if dazhao2 and skills[dazhao2.id] then 
                            m1 = m1 + dazhao2.growSupply[i] *  skills[dazhao2.id] + dazhao2.growSupply[i+1]
                        end 
                        -- m1 = m1 + skillCfg.growSupply[i] *  skills[v.id] + skillCfg.growSupply[i+1]
                    end
                    if skillCfg.order == 2 and skillCfg.priority and skillCfg.growSupply then
                        if jxSkill and skills[jxSkill.id] then 
                            m1 = m1 + jxSkill.growSupply[i] *  skills[jxSkill.id] + jxSkill.growSupply[i+1]
                        end
                    end
                    table.insert(_param.skillParams, m1)
                else
                    table.insert(_param.skillParams, 0)
                end
            end

            for i=1,4,2 do
                if skillCfg.growTreat then
                    local m2 = skillCfg.growTreat[i] * skillLevel + skillCfg.growTreat[i+1] 
                    if skillCfg.order == 3 and skillCfg.priority and skillCfg.growSupply then
                        if dazhao1 and skills[dazhao1.id] then 
                            local a,b = dazhao1.growSupply[4+i],dazhao1.growSupply[4+i+1]
                            if not a or not b then
                                a,b = 0,0
                                echoError ("找超阳，技能:%s 的growSupply字段参数错误",dazhao1.id,4+i)
                            end
                            m2 = m2 + a *  skills[dazhao1.id] + b
                        end
                        if dazhao2 and skills[dazhao2.id] then 
                            local a,b = dazhao2.growSupply[4+i],dazhao2.growSupply[4+i+1]
                            if not a or not b then
                                a,b = 0,0
                                echoError ("找超阳，技能:%s 的growSupply字段参数错误",dazhao2.id,4+i)
                            end
                            m2 = m2 + a *  skills[dazhao2.id] + b
                        end 
                        -- m2 = m2 + skillCfg.growSupply[4+i] *  skills[v.id] + skillCfg.growSupply[4+i+1]
                    end
                    if skillCfg.order == 2 and skillCfg.priority and skillCfg.growSupply then
                        if jxSkill and skills[jxSkill.id] then 
                            local a,b = jxSkill.growSupply[4+i],jxSkill.growSupply[4+i+1]
                            m2 = m2 + a * skills[jxSkill.id] + b
                        end
                    end
                    table.insert(_param.skillParams, m2)
                else
                    table.insert(_param.skillParams, 0)
                end
            end
            if skillCfg.growOther then
                for i=1,#skillCfg.growOther,2 do
                    if skillCfg.growOther then
                        local m3 = skillCfg.growOther[i] * skillLevel + skillCfg.growOther[i+1] 
                        if skillCfg.order == 3 and skillCfg.priority and skillCfg.growSupply then
                            if dazhao1 and skills[dazhao1.id] then
                                local a,b = dazhao1.growSupply[8+i],dazhao1.growSupply[8+i+1]
                                if not a or not b then
                                    a,b = 0,0
                                    echoError ("找超阳，技能:%s 的growSupply字段参数错误",dazhao1.id,8+i)
                                end
                                -- echo("======",dazhao1.id,i,dazhao1.growSupply[8+i],skills[dazhao1.id],dazhao1.growSupply[8+i+1])
                                m3 = m3 + a *  skills[dazhao1.id] + b
                            end
                            if dazhao2 and skills[dazhao2.id] then
                                local a,b = dazhao2.growSupply[8+i],dazhao2.growSupply[8+i+1]
                                if not a or not b then
                                    a,b = 0,0
                                    echoError ("找超阳，技能:%s 的growSupply字段参数错误",dazhao2.id,8+i)
                                end
                                m3 = m3 + a *  skills[dazhao2.id] + b
                            end
                        end
                        if skillCfg.order == 2 and skillCfg.priority and skillCfg.growSupply then
                            -- dump(jxSkill, "juexingjiengn ----- ", 5)
                            if jxSkill and skills[jxSkill.id] then 
                                local a,b = jxSkill.growSupply[8+i],jxSkill.growSupply[8+i+1]
                                m3 = m3 + a * skills[jxSkill.id] + b
                            end
                        end
                        table.insert(_param.skillParams, m3)
                    end
                end
            else
                for i=1,2 do
                    table.insert(_param.skillParams, 0)
                end
            end
            _param.lvl = skills[v.id]
        else
            _param.lock = 1;
        end

        table.insert(_skillParams, _param )
    end
    -- dump(_skillParams,"查看升星之后各个技能参数是多少_skillParams ------",4)
    return _skillParams
end
-- battleskill的替换技能
function FuncPartner.battleSkillMapSkillId(partnerInfo,skillCfg,_treasureId,_star)
    if FuncPartner.isChar(partnerInfo.id) then
        if skillCfg.order == 1 or skillCfg.order == 2 then -- 当前是主角技能
            if partnerInfo.garmentId and partnerInfo.garmentId ~="" then
                -- 判断是否觉醒
                local equipAwake,awakeSkillData = FuncPartner.checkPartnerEquipSkill(partnerInfo,_star,_treasureId)
                if equipAwake then
                    local mapSkill = FuncGarment.getValueByKey(partnerInfo.garmentId, partnerInfo.id, "eqAwMapSkill")
                    return mapSkill
                else
                    local mapSkill = FuncGarment.getValueByKey(partnerInfo.garmentId, partnerInfo.id, "mapSkill")
                    return mapSkill
                end
            end
        end
        return skillCfg.mapSkill
    else
        return skillCfg.mapSkill
    end
end

function FuncPartner.jinengShuzhi( skillCfg,skillLevel )
    local _param = {}

    for i=1,4,2 do
        if skillCfg.growDmg then
            local m1 = skillCfg.growDmg[i] * skillLevel + skillCfg.growDmg[i+1] 
            table.insert(_param, m1)
        else
            table.insert(_param, 0)
        end
    end
    for i=1,4,2 do
        if skillCfg.growTreat then
            local m2 = skillCfg.growTreat[i] * skillLevel + skillCfg.growTreat[i+1] 
            
            table.insert(_param, m2)
        else
            table.insert(_param, 0)
        end
    end
    if skillCfg.growOther then
        for i=1,#skillCfg.growOther,2 do
            if skillCfg.growOther then
                local m3 = skillCfg.growOther[i] * skillLevel + skillCfg.growOther[i+1] 
                table.insert(_param, m3)
            end
        end
    else
        for i=1,2 do
            table.insert(_param, 0)
        end
    end
    return _param
end


-- 判断是否是普通技能
function FuncPartner.isNormalSkill(_id)
    local data = FuncPartner.getSkillInfo(tostring(_id))
    local isTrue = false
    if data and data.order and data.order < 4 then
        isTrue = true
    end
    return isTrue
end

-- 伙伴的开启条件公用提示
function FuncPartner.getUnLock(name,value,valueType,lockTip)
    -- if tonumber(valueType) == 5 then
    --     WindowControler:showTips(lockTip)
    -- else
        if tonumber(valueType) == 4 or tonumber(valueType) == 5 then
            local strMap = {}
            strMap[1] = name
            local raidData = FuncChapter.getRaidDataByRaidId(value)
            strMap[3] = GameConfig.getLanguage(raidData.name)
            local chapter = FuncChapter.getChapterByStoryId(tostring(raidData.chapter))
            local section = FuncChapter.getSectionByRaidId(value)
            strMap[2] = chapter.."-"..section
            local str = ""
            if tonumber(valueType) == 4 then
                str = GameConfig.getLanguageWithSwap("#tid_partner_21",unpack(strMap))
            else
                str = GameConfig.getLanguageWithSwap("#tid_partner_30",unpack(strMap))
            end
            -- local str = GameConfig.getLanguageWithSwap("#tid_partner_21",unpack(strMap))
            WindowControler:showTips(str)
            --todo
        else
            local strMap = {}
            strMap[1] = name
            strMap[2] = value
            local str = GameConfig.getLanguageWithSwap("#tid_partner_20",unpack(strMap))
            WindowControler:showTips(str)
        end
    -- end 
end

function FuncPartner.getPartnerAddAttr(beforAttr,afterAttr)
    local addAttr = {}
    local isAdd = false
    for i ,v in pairs(afterAttr) do
        for ii,vv in pairs(beforAttr) do
            if v.key == vv.key then
                v.value = v.value - vv.value
                if v.value > 0 then
                    table.insert(addAttr, v)
                    isAdd = true
                end
                break
            end 
        end
        if v.value > 0  and not isAdd then
            table.insert(addAttr, v)
        end
        isAdd = false
    end
    
    return addAttr
end

function FuncPartner.showAttrEffect(txt1,ctn,addAttr,posX,posY)
    if not addAttr then
        echoWarn("此时没有属性加成 需要看一下数据")
        return
    end
    if not posY then
        posY = GameVars.height / 2
    end
    if not posX then
        posX = 0
    end
    addAttr = FuncBattleBase.formatAttribute( addAttr )
    local count = table.length(addAttr)

    for i,v in pairs(addAttr) do
        local txt = UIBaseDef:cloneOneView(txt1);
        ctn:addChild(txt)
        txt:setPositionY(posY)
        txt:setPositionX(posX)
        local str = v.name.."+"..v.value;
        txt:setString(str)
        --txt:scale(1.5)
        txt:setColor(cc.c3b(10,250,41))
        txt:visible(false)
        local callBack = function ()
            txt:removeFromParent()
            txt = nil
        end;
        local visibleCall = function ()
            txt:visible(true)
        end;
        txt:runAction(cc.Sequence:create(
                    act.delaytime(0.3 * (i - 1)),
                    act.spawn(
                            act.callfunc(c_func(visibleCall)),
                            act.moveto(0.3 , posX, posY + 90 - (i - 1) * 30),
                            act.fadeout(0.5 * count + 0.1 * i)
                        ),
                    act.callfunc(c_func(callBack))
                ))
        count = count - 1 
    end
end

function FuncPartner.initQXSP( panel,partnerId )
    local itemFrame = FuncItem.getItemQuality( partnerId )
    panel:showFrame(itemFrame)
    panel = panel.currentView
    local headMaskSprite = display.newSprite(FuncRes.iconOther("partner_bagmask"))
    
    local iconPath = FuncRes.iconHead(FuncItem.getIconPathById( partnerId ))  
    local iconSpr = display.newSprite(iconPath)
    local _spriteIcon = FuncCommUI.getMaskCan(headMaskSprite,iconSpr)
    _spriteIcon:scale(0.41)
    panel.ctn_1:removeAllChildren()
    panel.ctn_1:addChild(_spriteIcon)
end

-- 只在竞技场机器人取技能
function FuncPartner.getSkillByPartnerIdForRobot( _partnerId,lvl )
    local partnerData = FuncPartner.getPartnerById(_partnerId)
    local lvl = tonumber(lvl or 1)
    local skill = nil

    if partnerData then
        skill = {}
        local tempT = {
            [2] = true,
            [3] = true,
            [4] = true,
        }
        local _skill_info = partnerData.skill
        for _,_skill_id in ipairs(_skill_info) do
            local _skill = FuncPartner.getSkillInfo(_skill_id)
            if tempT[_skill.order] then
                -- 扩充技能只取普通的
                if _skill.priority then
                    if _skill.priority == 1 then
                        skill[_skill_id] = lvl
                    end
                else
                    skill[_skill_id] = lvl
                end
            end
        end
    else
        echoError("伙伴:%s没有获得相关伙伴信息",_partnerId)
    end

    return skill
end

--通过tag获得属于该tag的所有奇侠
function FuncPartner.getPartnersByTags(_tag)
    local _type = _tag.key
    local _tagId = _tag.value
    local partners = {}
    for k,v in pairs(_partner_table) do
        local tag = v.tag
        if v.isShow == 1 and tag and tostring(tag[tonumber(_type)]) == tostring(_tagId) then
            table.insert(partners, v.id)
        end
    end
    return partners
end

--获取奇侠对应的武器觉醒仙术
function FuncPartner.getWeaponAwakeSkillIdByPartnerId(_partnerId)
    local weaponAwakeSkillId = nil
    if FuncPartner.isChar(_partnerId) then
        weaponAwakeSkillId = FuncChar.getCharAwakeSkillId(_partnerId)
    else
        local partnerCfg = FuncPartner.getPartnerById(_partnerId)
        weaponAwakeSkillId = partnerCfg.weaponAwakeSkillId
        if not weaponAwakeSkillId then
            echoError("\n\n奇侠未配置武器觉醒仙术  _partnerId== ", _partnerId)
        end
    end

    return weaponAwakeSkillId
end

--获取奇侠对应的全部装备觉醒仙术
function FuncPartner.getAwakeSkillIdByPartnerId(_partnerId, _treasureId)
    local awakeSkillId = nil
    if FuncPartner.isChar(_partnerId) then
        awakeSkillId = FuncTreasureNew.getTreasureAwakeSkillId(_treasureId, _partnerId)
    else
        local partnerCfg = FuncPartner.getPartnerById(_partnerId)
        awakeSkillId = partnerCfg.awakeSkillId
        if not awakeSkillId then
            echoError("\n\n奇侠未配置全部装备觉醒仙术  _partnerId== ", _partnerId)
        end
    end
    
    return awakeSkillId
end

function FuncPartner.getPartnerSystemName(_selectIndex, _partnerId)
    if _selectIndex == 1 then -- 品质
        return FuncCommon.SYSTEM_NAME.PARTNER_QUALITY
    elseif _selectIndex == 2 then -- 升星
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.SYSTEM_NAME.CHARSTAR
        else
            return FuncCommon.SYSTEM_NAME.PARTNER_SHENGXING
        end
        
    elseif _selectIndex == 3 then -- 技能
        if _partnerId and FuncPartner.isChar(_partnerId) then
            return FuncCommon.SYSTEM_NAME.TREASURE_NEW
        else
            return FuncCommon.SYSTEM_NAME.PARTNER_SKILL
        end
    elseif _selectIndex == 4 then -- 情报
        return ""
    elseif _selectIndex == 5 then -- 装备
        return FuncCommon.SYSTEM_NAME.PARTNER_ZHUANGBEI
    end
end

function FuncPartner.getAbilityByAbilityInfo(_abilityInfo)
    local total = 0
    for k,v in pairs(_abilityInfo) do
        total = total + v
    end
    return total
end

--根据技能id判断这个技能是  ,类型 1  是怒气扩展技,2是主动技, 3是被动, 4是怒气主动技
function FuncPartner.getSkillKind( skillId,  isTreasureSkill,isCharSkill )
    if isCharSkill then
        return 2
    end
    local skillCfg 
    if isTreasureSkill then
        skillCfg = FuncTreasureNew.getTreasureSkillDataDataById(skillId)
    else
        skillCfg = FuncPartner.getSkillInfo(skillId)
    end
    --如果顺序是2  那么返回
    if skillCfg.order == 2 or skillCfg.order == 1 then
        return 2
    --大招分
    elseif skillCfg.order == 3 then
        if skillCfg.priority == 1 then
            return 4
        end
        return 1
    else
        return 3
    end
end

--根据装备id以及当前装备等级 计算强化后多少次以及进阶过多少次
function FuncPartner.getEnhanceLevelAndAdvanceLevel(_equipId, _level)
    local equipmentCfg = FuncPartner.getEquipmentById(_equipId)
    local enhanceLevel = 0
    local advanceLevel = 0

    if _level <= 1 then
        return enhanceLevel, advanceLevel
    end

    for i = 1, _level - 1 do
        local currentInfo = equipmentCfg[tostring(i)]
        if currentInfo.qualityCost then
            advanceLevel = advanceLevel + 1
        else
            enhanceLevel = enhanceLevel + 1
        end
    end

    return enhanceLevel, advanceLevel
end

--根据新手期和老手期的 类型获取各自的 条件
function FuncPartner.getSkilledLevelAndValueByKey(_key)
    local skilledCfg = _partner_skilled_cfg[tostring(_key)]
    local limitLevel = 1
    local limitValue = 1
    if not skilledCfg then
        echoError("\n新手期没有这种类型的配置 _key==", _key)
        return limitLevel, limitValue
    end

    local condition = skilledCfg.condition
    if condition then
        for key,value in pairs(condition) do
            if value.t == 1 then
                limitLevel = value.v
            elseif value.t == 2 then
                limitValue = value.v
            end
        end
    end
    
    return limitLevel, limitValue
end

--传入伙伴或者主角数据 格式化转成技能数组
--[[
    {
        skillId = ...
        level = ...
    }

]]
function FuncPartner.formatSkillInfo( partnerInfo,playerInfo,isChar )
    
end

function FuncPartner.getPartnerShowIdByPartnerId(_partnerId)
    local partnerData = FuncPartner.getPartnerById(_partnerId)
    if not partnerData.partnerShow then
        echoWarn("\n\npartner do not found  partnerShow  for partnerId====", _partnerId)
    end
    return partnerData.partnerShow
end

--升级时 根据提升等级 获取增加的属性 字符串 比如：血量+1000  攻击+300
function FuncPartner.getAttrForLevelUp(_partnerId, _level, _star)
    local attr_table = {}
    local attr_str = {}
    local partnerStarCfg = FuncPartner.getStarsByPartnerId(_partnerId)
    local info = partnerStarCfg[tostring(_star)].subAttr
    for i,v in ipairs(info) do
        local temp = {}
        local value = v.value * _level
        temp.key = v.key
        temp.value = value
        temp.mode = v.mode
        
        table.insert(attr_table, temp)
    end

    attr_table = FuncBattleBase.formatAttribute(attr_table)

    for i,v in ipairs(attr_table) do
        local str = v.name.."+"..v.value
        table.insert(attr_str, str)
    end

    return attr_str
end