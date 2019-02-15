-------------------------------------
-- Desc:战斗相关计算公式
-------------------------------------
	
Formula = Formula or {}



-- 加密字符串，一些常量值===================================================



--[[
	计算技能伤害

--]]           
function Formula:skillDamage(atker,defer,skill,atkData,damageResult)
	-- 攻击
	local atk = atker.data:atk()
	-- 改成灵力
    local def = defer.data:def()
    local magdef = defer.data:magdef()

    local injury = atker.data:injury() --伤害率
    local avoid = defer.data:avoid() 	--免伤率
    local elementDef = 0-- 属性减伤率

    local useDef = skill.atkType == Fight.atkType_wu and def or magdef

    elementDef = elementDef + defer:getEnhanceDef(atker:getHeroElement())

    -- 修改伤害计算公式2017.9.8
    -- Max【（攻击方攻击力-防御方防御力）* 技能系数 * （ 1 + 攻击方伤害率-防守方免伤率） * （1-属性抗性系数），攻击者攻击*0.05+7】+技能提供额外常量
    -- 修改伤害率与免伤率的计算方式2018.1.2 (1+injury/10000 -avoid/10000 ) --> (10000 + injury) / (10000 + avoid)
    local dmg1 = (atk-useDef ) *((10000 + injury) / (10000 + avoid)) * (1 - elementDef / 10000) * skill.damageR / 10000
    local dmg2 = atk * 0.05 + 7

    local damage = math.max(dmg1, dmg2) + skill.damageN
    if damage <= 0 then
        damage = 1
    end

    --计算暴击强度 
    local critR = atker.data:critR()
    local blockR = defer.data:blockR()
    -- 必暴击检查
    local buffs = defer.data:getBuffsByType(Fight.buffType_certainBbaoji)
    if buffs then -- 获取到了必被暴击的buff
        -- 结果置为暴击
        baojiResult = true
        -- 将效果值作用到结果
        for i,v in ipairs(buffs) do
            critR = critR * tonumber(v.value) / 10000
            -- 作用一次
            -- v:useBuff()
        end
        if Fight.isOpenFightLogs and not Fight.isDummy  then
            echo("%d遭到强制暴击，critR:%.2f",defer.data.posIndex,critR/10000)
        end
    end

    --如果暴击了
    if damageResult == Fight.damageResult_baoji  then
        
        damage = damage * ( critR/10000)
    --如果被格挡了
    elseif damageResult == Fight.damageResult_gedang  then
        damage = damage  * ( 1-blockR / 10000)
    --暴击加格挡
    elseif  damageResult == Fight.damageResult_baojigedang  then
        damage = damage  * critR/10000 * ( 1-blockR/10000)
    end

    -- damage = damage * dmgRatio
    -- 计算来自buff的增伤
    damage = Formula:chkBuffExDmg(atker,defer,damage)

    damage = math.round(damage)

    if Fight.isOpenFightLogs   then
        --ios 和android不打印这个
        if not Fight.isDummy then
            if device.platform == "ios" or device.platform == "android"  then
                return damage
            end
        end
        
        local function printHeroInfo( hero )
            local hdata = hero.data
            echo("阵营:%s,%s号位:",hero.camp,hdata.posIndex)
            echo("atk:%s---def:%s---magdef:%s---hp:%s---maxhp:%s",hdata:atk(),hdata:def(),hdata:magdef(),hdata:hp(),hdata:maxhp())
            echo("maxtreahp:%s---crit:%s---resist:%s---critR:%s",hdata:maxtreahp(),hdata:crit(),hdata:resist(),hdata:critR())
            echo("block:%s---blockR:%s---wreck:%s---injury:%s---avoid:%s",hdata:block(),hdata:blockR(),hdata:wreck(),hdata:injury(),hdata:avoid())
        end
        echo("阵营%d %d号打阵营%d %d号, 伤害%s,atk:%d,def:%d,伤害率:%d,免伤率:%d,skill.damageR:%d,damageN:%d,damageResult:%d, randomIndex:%d",
            atker.camp, atker.data.posIndex, defer.camp, defer.data.posIndex, 
            damage,atk,def,injury,avoid,skill.damageR,skill.damageN,damageResult, BattleRandomControl.getCurStep() )
        echo("------------------------------start------------------------------")
        echo("阵营%s,%s号位 攻击 阵营%s,%s号位, 伤害:%s",atker.camp,atker.data.posIndex,defer.camp,defer.data.posIndex,damage)
        printHeroInfo(atker)
        printHeroInfo(defer)
        echo("-------------------------------end-------------------------------")
    end
	return  damage
end

--[[
    计算来自buff的增伤
]]
function Formula:chkBuffExDmg(atker,defer,damage)
    -- 克制buff
    local buffs = atker.data:getBuffsByType(Fight.buffType_kezhi)
    if buffs then
        for _,buffObj in ipairs(buffs) do
            local result = nil
            result,buffObj = Formula:_chkBuffValue(buffObj)
            local expand = buffObj.expandParams
            -- buff值没问题，并且对应的职业没问题
            if result and expand and expand[1] == defer:getHeroProfession() then
                -- 作用值
                local exDmg = 0
                if buffObj.changeType == Fight.valueChangeType_num then
                    exDmg = buffObj.value
                else
                    exDmg = damage * buffObj.value/10000
                end
                if Fight.isOpenFightLogs then
                    echo("阵营%s,%s号触发克制buff,伤害得到增加:%s",atker.camp,atker.data.posIndex,exDmg)
                end
                damage = damage + exDmg
                -- buffObj:useBuff()
            end
        end
    end

    -- 血量增伤buff检查
    local buffs = atker.data:getBuffsByType(Fight.buffType_hpExDmg)
    if buffs then -- 获取到了血量附加伤害的buff
        local hpPer = defer.data:hp() / defer.data:maxhp()
        for _,buff in ipairs(buffs) do
            local expand = buff.expandParams
            if expand then -- 没有扩展参数属于异常情况
                local isHigher = expand[1] == 1
                local border = expand[2] / 10000
                -- 符合条件
                if isHigher == (border < hpPer) then
                    local exDmg = atker.data:atk() * buff.value / 10000
                    if Fight.isOpenFightLogs then
                        echo("阵营%s,%s号触发增伤buff,伤害得到增加:%s",atker.camp,atker.data.posIndex,exDmg)
                    end
                    damage = damage + exDmg
                end
            end
            -- buff:useBuff()
        end
    end

    return damage
end

--[[

	功能:加血
]]
function Formula:skillTreat(atker,defer,skill,atkData,damageResult)
	-- 攻击
	local atk = atker.data:atk()

    local injury = atker.data:injury() --伤害率
    local avoid = atker.data:avoid() 	--免伤率

    --攻击包的伤害系数 是动态算出来的
    local dmgRatio = atkData.dmgRatio

    local damage = (atk * skill.treaR / 10000 + skill.treaN) * dmgRatio
    if damage <= 0 then
    	damage = 1
    end

	return  math.round(damage)
end


--[[
	功能：被击，计算闪避/暴击
--]]
function Formula:countDamageResult(atker,defer,skill)
    -- 计算最终结果，是闪避还是暴击了 0-1
    local canDoit = skill:sta_canCrit()
    local baojiResult = false
    if canDoit == 1 then
    	local random = BattleRandomControl.getOneRandom()
        local crit = atker.data:crit()
        local resist = defer.data:resist()
        -- 修改暴击的生效方式2018.1.2 (crit/10000 - resist/10000) --> (10000 + crit) / (10000 + resist) - 1
        -- echo("crit:",crit,"resist",resist)
        local ratio = (10000 + crit) / (10000 + resist) - 1
        ratio = ratio < 0 and 0 or ratio
        ratio = ratio > 1 and 1 or ratio
	    if random < ratio then
	        baojiResult = true
	    end

    end

    --判断必被暴击buff
    if defer.data:checkHasOneBuffType(Fight.buffType_certainBbaoji) then
        -- 结果置为暴击
        baojiResult = true
    end

    --判断必定暴击
    if atker.data:checkHasOneBuffType(Fight.buffType_sureBaoji) then
        -- 结果置为暴击
        baojiResult = true
    end

    --判断格挡
    local  gedangResult 
    local randomGedang = BattleRandomControl.getOneRandom()

    --破击
    local wreck = atker.data:wreck()
    local block = defer.data:block()
    -- 修改格挡的生效方式2018.1.2 (block/10000 - wreck/10000) --> (10000 + block) / (10000 + wreck) - 1
    local blockRatio = (10000 + block) / (10000 + wreck) - 1
    blockRatio = blockRatio < 0 and 0 or blockRatio
    blockRatio = blockRatio >1 and 1 or blockRatio

    if randomGedang < blockRatio then
        gedangResult = true 
    end
    -- echo(gedangResult,"poji,",wreck,"block",block)
    if baojiResult  then
        if not gedangResult then
            return Fight.damageResult_baoji 
        else
            return Fight.damageResult_baojigedang 
        end
    else
        if not gedangResult then
            return Fight.damageResult_normal 
        else
            return Fight.damageResult_gedang  
        end
    end
    return Fight.damageResult_normal
end

-- 根据buff获取对应的属性值
function Formula:_getAttrValue( buffObj,arr )
    local hero = nil
    if arr.camp == 1 then -- 释放者
        hero = buffObj.hero
    else -- 被释放者
        hero = buffObj.useHero
    end

    if not hero then
        echoError("这个buff没有找到取值hero",buffObj.hid)
        return nil
    end
    local attrValue = nil
    if hero.data.hid == "artifact" then -- 如果是神器则取当前值
        attrValue = hero.data:getAttrByKey(arr.attr)
    else
       attrValue = hero.data:getInitValue(arr.attr)
    end
    
    -- 如果是hp则意味着应该取当前值
    if arr.attr == Fight.value_health then
        attrValue = hero.data:getAttrByKey(arr.attr)
    end

    local value = math.round( attrValue * tonumber(arr.rate)/10000 + arr.n)

    return value
end

--[[
    处理buffObj的值（主要处理changeType为3的）
    return result,buffObj
    result == false 时buff的值有问题返回
]]
function Formula:_chkBuffValue( buffObj )
    local result = true

    -- 作用一次当前buff的值就固定下来
    if buffObj.changeType == Fight.valueChangeType_attr then
        local calValue = buffObj.calValue
        if not calValue then
            echoError("没有找到calValue 值",buffObj.hid)
            result = false
        else
            local value = self:_getAttrValue(buffObj,calValue)
            if not value then
                result = false
            else
                buffObj.value = value
                buffObj.changeType = Fight.valueChangeType_num -- 值改为数值方式
            end
        end
    end
    return result,buffObj
end
function Formula:getBuffLimitDmg(buffObj,value)
    if buffObj.valueLimit then
        local tmp = value
        if not buffObj.limitValue then
            echoError ("这个buff设置了buff上下限但是没有计算出值",buffObj.hid)
            return tmp
        else
            if buffObj.valueLimit.limit == 0 then --下限
                tmp = math.max(buffObj.limitValue,value)
            elseif buffObj.valueLimit.limit == 1 then --上限
                tmp = math.min(buffObj.limitValue,value)
            end
        end
        return tmp
    else
        return value
    end
end

return Formula