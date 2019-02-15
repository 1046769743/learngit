
FuncTreasureNew = FuncTreasureNew or {}

local treasurenewData = nil
local treasureUpstarData = nil
local treasureSkillData = nil

FuncTreasureNew.TISHENG_TYPE = {
    QUALITY = 1,
    STAR = 2,
    AWAKEN = 3,
}

function FuncTreasureNew.init(  )
	treasurenewData = Tool:configRequire("treasure.TreasureNew");
	treasureUpstarData = Tool:configRequire("treasure.TreasureUpstar");
	treasureSkillData = Tool:configRequire("treasure.TreasureSkill");
end

-- 法宝表
function FuncTreasureNew.getTreasureData()
    return treasurenewData
end
function FuncTreasureNew.getTreasureDataById(id)
	local data = treasurenewData[tostring(id)]
	if data ~= nil then
		return data
	else
		echoError("FuncTreasureNew.getTreasureDataById id not dound ",id)
        return treasurenewData["404"]
	end
end
-- 根据战斗法宝id获取对应的hid
function FuncTreasureNew.getTreasureIdByBattleTreasureId(bId )
    for k,v in pairs(treasurenewData) do
        for m,n in pairs(v.treasureId) do
            if n == tostring(bId) then
                return v.hid
            end
        end
    end
    echoError ("未找到对应的法宝id，",bId,"使用默认304代替")
    return "304"
end
-- 根据法宝id和法宝星级获取法宝对应的怒气消耗
function FuncTreasureNew.getEnergyCost(id,star )
    if not star or star =="" then star = 1 end
    local data = FuncTreasureNew.getTreasureDataById(id)
    for i,v in ipairs(data["attribute"..star]) do
        if tostring(v.key) == "5" then
            return (v.value - 6000)
        end
    end
    return 0
end

-- 法宝name
function FuncTreasureNew.getTreasureName(id)
    local data = FuncTreasureNew.getTreasureDataById(id)
    return data.name
end

-- 构造法宝初始数据
function FuncTreasureNew.getTreasureInitData(id)
    local initData = FuncTreasureNew.getTreasureDataById(id)
    local data = {}
    data.star = initData.initStar
    data.starPoint = 0
    data.id = id
    return data
end

-- 根据法宝ID和avatar  获取战斗法宝ID
function FuncTreasureNew.getBattleTreasureId(id,avatar)
    local data = FuncTreasureNew.getTreasureDataById(id)
    local treasVec = data.treasureId
    local treasureId = "300030"
    if treasVec then
        if tonumber(avatar) == 101 then
            treasureId = treasVec[1]
        elseif tonumber(avatar) == 104 then
            treasureId = treasVec[2]
        else
            echoError("avatar 传错了",avatar)
        end
    else
        echoError("法宝ID== ",id ,"  未找到战斗法宝ID")
    end
    return treasureId
end

function FuncTreasureNew.getNuqiCost( id,star )
    local attr = FuncTreasureNew.getTreasureDataByKeyID(id, "attribute"..star)
    local x = FuncTreasureNew.getTreasureDataByKeyID(id, "x")
    for i,v in pairs(attr) do
        if tonumber(v.key) == 5 then
            return v.value + x - 10000
        end
    end
    return 4
end

--根据法宝id star 以及属性的key 获取当前的 加成系数
function FuncTreasureNew.getRatioByIdAndStar(id, star, key)
    local attr = FuncTreasureNew.getTreasureDataByKeyID(id, "attribute"..star)
    local x = FuncTreasureNew.getTreasureDataByKeyID(id, "x")
    for i,v in pairs(attr) do
        if tonumber(v.key) == tonumber(key) then
            return v.value + x
        end
    end
end

function FuncTreasureNew.getTreasureDataByKeyID(id, key)
	local t = treasurenewData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasureNew.getTreasureDataByKeyID id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasureNew.getTreasureDataByKeyID key not found " .. key)
		return nil
	end 

	return ret;
end



-- 法宝升星表
function FuncTreasureNew.getTreasureUpstarDataById(id)
	local data = treasureUpstarData[tostring(id)]
	if data ~= nil then
		return data
	else
		echo("FuncTreasureNew.getTreasureUpstarDataById id not dound " .. id)
	end
end

function FuncTreasureNew.getTreasureUpstarDataByKeyID(id, key)
	local t = treasureUpstarData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasureNew.getTreasureUpstarDataByKeyID id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasureNew.getTreasureUpstarDataByKeyID key not found " .. key)
		return nil
	end 

	return ret;
end

-- 法宝技能表
function FuncTreasureNew.getTreasureSkillDataDataById(id)
	local data = treasureSkillData[tostring(id)]
	if data ~= nil then
		return data
	else
		echo("FuncTreasureNew.getTreasureSkillDataDataById id not dound " .. id)
	end
end

function FuncTreasureNew.isTreasureSkill(treasureId, skillId,avatar)
    local _avatar = avatar or FuncChar.SEX_MAP.MAN_ID
    local skills = FuncTreasureNew.getTreasureSkills(treasureId, _avatar)

    for i,v in ipairs(skills) do
        if tostring(skillId) == tostring(v) then
            return true
        end
    end

    return false
end

function FuncTreasureNew.getTreasureSkillDataByKeyID(id, key)
	local t = treasureSkillData[tostring(id)];
	if id == nil or t == nil then
		echoError("FuncTreasureNew.getTreasureSkillDataByKeyID id not found " .. id .. "_"..key)
		return nil
	end

	local ret = t[tostring(key)];
	if ret == nil then 
		echo("FuncTreasureNew.getTreasureSkillDataByKeyID key not found " .. key)
		return nil
	end 

	return ret;
end

-- 全部装备觉醒+4星法宝
function FuncTreasureNew.getTreasureAwakeSkillId(id,avatar)
    local data = FuncTreasureNew.getTreasureDataById(id)
    local skills = data.awakeSkillId
    if tonumber(avatar) == 101 then
        return skills[1]
    else
        return skills[2]
    end
end
-- 获得法宝技能
function FuncTreasureNew.getTreasureSkills(id,avatar)
    local _avatar = avatar or FuncChar.SEX_MAP.MAN_ID
    local skills = FuncTreasureNew.getTeasureSkillsByIdAndAvatar(id,avatar )
    return skills
end

-- 法宝技能分男女
function FuncTreasureNew.getTeasureSkillsByIdAndAvatar(id,avatar)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local skills = dataCfg.skill
    if FuncChar.MAN_ID == tostring(avatar) then
        
    elseif FuncChar.FEMALE_ID == tostring(avatar) then 
        skills = dataCfg.skillF
    else
        echoError("avatar 错误",avatar," 默认用男主角技能")
    end
    return skills
end


function FuncTreasureNew.getStarSkillMap(id,avatar)
    local starData = FuncTreasureNew.getTreasureUpstarDataById(id)
    local starSkillT = {}
    for i,v in pairs(starData) do
        local unlockSkill = v.unlockSkillId
        if FuncChar.FEMALE_ID == tostring(avatar) then
            unlockSkill = v.unlockSkillIdF
        end
        if unlockSkill then
            local data = {
                star = tonumber(v.star),
                skill = unlockSkill
            }
            starSkillT[unlockSkill] = data
        end
    end
    return starSkillT
end

-- 法宝框 对应资质颜色
function FuncTreasureNew.getKuangColorFrame(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local zizhi = dataCfg.aptitude
    if zizhi == 1 then
        return 11
    elseif zizhi == 2 then 
        return 16
    elseif zizhi == 3 then 
        return 21
    else
        echoError("法宝 ===此资质对应的颜色 资质 ==  ",zizhi," === fabao ===",id)
        return 1
    end
end

-- 法宝名字 对应资质颜色
function FuncTreasureNew.getNameColorFrame(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local zizhi = dataCfg.aptitude
    if zizhi == 1 then
        return 3
    elseif zizhi == 2 then 
        return 4
    elseif zizhi == 3 then 
        return 5
    else
        echoError("法宝 ===此资质对应的颜色 资质 ==  ",zizhi," === fabao ===",id)
        return 1
    end
end

function FuncTreasureNew.getStarAttrMap( id )
    local starData = FuncTreasureNew.getTreasureUpstarDataById(id)
    local starAttrT = {}
    for i,v in pairs(starData) do
        if v.addAttr7 then
            local data = {
                star = tonumber(v.star),
                attr = v.addAttr7
            }
            starAttrT[v.star] = data
        end
    end
    return starAttrT
end

-- 法宝立绘
function FuncTreasureNew.getTreasLihui(id)
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local lihui = ViewSpine.new(dataCfg.image,{},nil,dataCfg.image)
    lihui:playLabel("stand")
    return lihui
end

function FuncTreasureNew.showAttrEffect(txt1,ctn,addAttr,posX,posY)
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

function FuncTreasureNew.getDescriptionBySkillId(_skillId,level)
    local dataCfg = FuncTreasureNew.getTreasureSkillDataDataById(_skillId)
    return FuncPartner.getCommonSkillDesc(dataCfg,level)
end

function FuncTreasureNew.getMainSkillById(id,avatar)
    local mainSkillList = {}
   local skillList = FuncTreasureNew.getTreasureSkills(id,avatar)
   for k,v in pairs(skillList) do
        local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v)
        if skillData.order == 3 and skillData.priority == 1 then
            table.insert(mainSkillList,v)
        end

        if skillData.order == 4 then
            table.insert(mainSkillList,v)
        end
   end
   return mainSkillList
end

----------------------------------------------------------------------------------
-------------------------------播放法宝音效---------------------------------------
----------------------------------------------------------------------------------
function FuncTreasureNew.playUpstarpointSound()
    AudioModel:playSound(MusicConfig.s_treasure_starpoint)
end
function FuncTreasureNew.playUpstarSound()
    AudioModel:playSound(MusicConfig.s_treasure_star)
end
function FuncTreasureNew.playJiHuoSound()
    AudioModel:playSound(MusicConfig.s_treasure_jihuo)
end

----------------------------------------------------------------------------------
---------------------------------------end----------------------------------------
----------------------------------------------------------------------------------


-----------------------------------------------------------------------------------
------------------------------法宝战力属性相关-------------------------------------
-----------------------------------start-------------------------------------------
-- 法宝佩戴属性计算
function FuncTreasureNew.getTreasurePeidaiAttr(treasureData)
    if not treasureData then
        echoError("treasureData ==== nil")
        return {}
    end
    local dataMap = {}
    local id = treasureData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)

    
    local star = treasureData.star 
    
    -- 初始属性 即佩戴属性
    local _initData = dataCfg["attribute"..star]
    for i,v in pairs(_initData) do
        local _data = {
            key = v.key,
            value = v.value + dataCfg.x - 10000,
            mode = v.mode,
        }
        table.insert(dataMap,{_data}) 
    end
    return dataMap
end
-- 法宝的技能属性加成
function FuncTreasureNew.getTreasureSkillAttr( treasureData,level )
    if not treasureData then
        echoError("treasureData ==== nil")
        return {}
    end
    local dataMap = {}
    local id = treasureData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)
    local star = treasureData.star 
    -- 技能属性加成
    local starSkillMap = FuncTreasureNew.getStarSkillMap(id)
    for i,v in pairs(starSkillMap) do
        if v.star <= star then
            local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
            if skillData.kind ==2 or skillData.kind ==3 then --只有类型为2的表格数据才会被累加
                for i,v in pairs(skillData.initAttr) do
                    table.insert(dataMap, {v})
                end
                for i,v in pairs(skillData.lvAttr) do
                    local data = {}
                    data.key = v.key
                    data.mode = v.mode
                    data.value = v.value * level
                    table.insert(dataMap, {data})
                end
            end
        end
    end
    return dataMap
end
-- 法宝属性计算
function FuncTreasureNew.getTreasureAttr(treasureData)
    if not treasureData then
        echoError("treasureData ==== nil")
        return {}
    end
    local dataMap = {}
    local id = treasureData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)

    
    local star = treasureData.star 
    local starPoint = treasureData.starPoint
    local quality = dataCfg.initQuality
    
    -- 初始属性
    --local _initData = dataCfg["attribute"..star]
    --table.insert(dataMap,_initData)

    for i=1,star do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,i)
        table.insert(dataMap,starData["addAttr"..7])
    end
    for i=1,star-1 do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,i)
        for ii=1,6 do
            table.insert(dataMap,starData["addAttr"..ii])
        end
    end

    for i=1,starPoint do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star)
        table.insert(dataMap,starData["addAttr"..i])
    end

    -- 技能属性加成
    local starSkillMap = FuncTreasureNew.getStarSkillMap(id)
    for i,v in pairs(starSkillMap) do
        if v.star <= star then
            local skillData = FuncTreasureNew.getTreasureSkillDataDataById(v.skill)
            if skillData.kind ==2 then --只有类型为2的表格数据才会被累加
                table.insert(dataMap,skillData.initAttr)
            end
        end
    end
    -- dump(dataMap, "ppppppppppoooooooooo0000-----------------")
    return FuncBattleBase.countFinalAttr(unpack( dataMap) )

end

--法宝阵位全局养成属性
function FuncTreasureNew.getTreaSiteAttr(treasureData)
    if not treasureData then
        echoError("treasureData ==== nil")
        return {}
    end
    local dataMap = {}
    local id = treasureData.id
    local dataCfg = FuncTreasureNew.getTreasureDataById(id)

    local star = treasureData.star 
    local starPoint = treasureData.starPoint
    local quality = dataCfg.initQuality

    for i=1,star do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,i)
        table.insert(dataMap,starData["addAttr"..7])
    end
    for i=1,star-1 do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,i)
        for ii=1,6 do
            table.insert(dataMap,starData["addAttr"..ii])
        end
    end

    for i=1,starPoint do
        local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star)
        table.insert(dataMap,starData["addAttr"..i])
    end

    return dataMap
end

function FuncTreasureNew.getTreaStarAttr( id,star,starPoint )
    local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star)
    local attr = {}
    attr = table.deepCopy(starData["addAttr"..7])
    
    for i=1,starPoint do
        attr[1].value = attr[1].value + starData["addAttr"..i][1].value
    end

    local str = FuncTreasureNew.getAttrDesTable(attr[1])
    return str
end

function FuncTreasureNew.getTreaPermanentAttr(id,star,starPoint)
    local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star)
    local attr = {}
    attr = table.deepCopy(starData["addAttr"..7])
    
    for i=1,starPoint do
        attr[1].value = attr[1].value + starData["addAttr"..i][1].value
    end
    return attr[1]
end

function FuncTreasureNew.getUpStarAddAttr(id,star,starPoint)
    local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star)
    local attr = {}
    if starData then
        if starPoint == 0 then
            if starData["addAttr"..7] then
                table.insert(attr ,table.deepCopy(starData["addAttr"..7]))
                if star > 1 then
                    local starData = FuncTreasureNew.getTreasureUpstarDataByKeyID(id,star-1)
                    table.insert(attr ,table.deepCopy(starData["addAttr"..6]))
                end
            end
        else
            if starData["addAttr"..starPoint] then
                table.insert(attr ,table.deepCopy(starData["addAttr"..starPoint]))
            end
        end
    end
    
    local T = {}
    for i,v in pairs(attr) do
        for ii,vv in pairs(v) do
            table.insert(T, vv)
        end
    end
    -- dump(T, "--------------", 3)
    return T
end

function FuncTreasureNew.getAttrDesTable(des,isvalue)
    if des == nil then
        return ""
    end
    local attrData = FuncChar.getAttributeData()
    local attrName = GameConfig.getLanguage(attrData[tostring(des.key)].name)

    local value = FuncBattleBase.getFormatFightAttrValue(des.key, des.value)
    local str = attrName.."+"..value
    if des.mode == 2 then   
        -- 万分比
        local desValue = des.value * 100 / 10000
        str = attrName.."+"..desValue.."%"
    elseif des.mode == 4 then
        local desValue = des.value * 100 / 10000
        str = attrName.."+"..desValue.."%"
    end
    if isvalue == false then
        return attrName
    end
    return str
end


-- 法宝战力 万分比
function FuncTreasureNew.getAbilityPer( treasureData,level )
    if not treasureData then
        echoError("treasureData ==== nil")
        return 0
    end
    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureData.id)
    local x = dataCfg.x
    local treaRatioAbility = dataCfg.treaRatioAbility[treasureData.star]

    local ability = x + treaRatioAbility
    return ability / 10000
end
--[[
法宝战力计算
单个法宝系统展示战力=法宝技能单级战力*当前技能等级+当前法宝系统全局养成战力；
法宝系统全局养成战力=法宝升星养成战力+完整升星额外战力+每颗星初始战力

====== 参数含义 ======
法宝升星养成战力：由法宝升星提供的累计战力值；【TreasureUpstar】表addAbility前五项；
完整升星额外战力：由法宝升星时带来的战力提升；【TreasureUpstar】表addAbility第六项；
每颗星初始战力：由法宝升星时带来的战力提升【TreasureUpstar】表addAbility第七项；
]] 

function FuncTreasureNew.getTreasureAbility(treasureData,level)
    local ability = 0
    -- 技能的战力计算
    -- echoError("fabao id == ",treasureData.id)
    local skillAbility = FuncTreasureNew.getFabaoSkillAbility(treasureData,level)
    ability = ability + skillAbility
    -- echo("fabao jineng zhanli  == ",skillAbility)
    -- 添加星级战力
    local starAbility = FuncTreasureNew.getTreasureStarAbility(treasureData)
    ability = ability + starAbility
    -- echo("fabao xingji zhanli  == ",starAbility)
    return ability
end
--法宝系统全局养成战力
function FuncTreasureNew.getTreasureStarAbility(treasureData)
    local ability = 0
    -- 添加星级战力
    local star = treasureData.star
    local starPoint = treasureData.starPoint
    --每颗星初始战力
    --完整升星额外战力
    for i=1,star do
        local _star_table = FuncTreasureNew.getTreasureUpstarDataById(treasureData.id) 
        _star_table = _star_table[tostring(i)]
        if _star_table.addAbility[7] then
            ability = ability + _star_table.addAbility[7]
        else
            echoError("法宝ID == ",treasureData.id," 星级 = ",i," 升星表 没有找到addAbility字段 ")
        end
    end
    --法宝升星养成战力
    for i=1,star-1 do
        local _star_table = FuncTreasureNew.getTreasureUpstarDataById(treasureData.id) 
        _star_table = _star_table[tostring(i)]
        for ii=1,6 do
            if _star_table.addAbility[ii] then
                ability = ability + _star_table.addAbility[ii]
            else
                echoError("找策划 数据配的不对  法宝ID == ",treasureData.id,"法宝小阶段星级战力 看一下",ii)
            end
        end
    end
    local _starData = FuncTreasureNew.getTreasureUpstarDataById(treasureData.id)
    _starData = _starData[tostring(star)]
    for i=1,starPoint do
        if _starData.addAbility then
            ability = ability + _starData.addAbility[i]
        end
    end

    -- echo("\n\ngetTreasureStarAbility====", ability, treasureData.id)
    return ability
end

-- 法宝提供的技能战力
function FuncTreasureNew.getFabaoSkillAbility(treasureData,level)
    -- echo("fabao id  == ",treasureData.id)
    if not treasureData then
        -- echoError("treasureData ==== nil")
        return 0
    end
    local ability = 0

    local dataCfg = FuncTreasureNew.getTreasureDataById(treasureData.id)
    -- 技能
    local skillT = dataCfg.skill
    local starSkillMap = FuncTreasureNew.getStarSkillMap(treasureData.id)

    -- 技能的战力计算
    for i,v in pairs(skillT) do
        if treasureData.star >= starSkillMap[v].star then
            local skillDataCfg = FuncTreasureNew.getTreasureSkillDataDataById(v)
            ability = ability + skillDataCfg.lvAddAbility * level
        end
    end
    
    -- echo("法宝战力 计算 == "..ability.."  法宝ID= "..treasureData.id)

    return ability
end
--------------------------------------------------------------------------------------------
------------------------------------end-----------------------------------------------------
--------------------------------------------------------------------------------------------
--判断id是否是法宝  奇侠中区分法宝和奇侠使用
function FuncTreasureNew.isTreasureById(_id)
    if treasurenewData[tostring(_id)] then
        return true
    end
    return false
end

