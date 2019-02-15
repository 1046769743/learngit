--
-- Author: Cwb
-- Date: 2015-11-17 10:05:47
-- 法宝管理
local globalCfgKey = {
    "hid","source","round","inSkill","dmgE","skill1",
    "dmg1","skill2","dmg2","skill3","dmg3",
    "skill4","dmg4","skill5","dmg5","skill6",
    "dmg6","skill7","dmg7","skill8","dmg8",
    "aura","profession","elements","buffImmune","mass",
    "sex","head","name","des","icon", --这几个是从enemyInfo表移植过来的
}
local Fight = Fight
-- local BattleControler = BattleControler

ObjectTreasure = class("ObjectTreasure")
ObjectCommon.mapFunction(ObjectTreasure,globalCfgKey)

ObjectTreasure.__aura = nil
ObjectTreasure.skills = nil -- 技能
ObjectTreasure.onSkill = nil -- 登场
ObjectTreasure.__maxpower = 0 -- 最大威能
ObjectTreasure.__damagePower = 0 -- 被击消耗的威能 
ObjectTreasure.__charIndex = nil -- 主角的编号

--不备份
ObjectTreasure.objHero = nil
ObjectTreasure.spineName = nil


ObjectTreasure.skill1 = nil       --普通攻击
ObjectTreasure.skill2 = nil       --小技能
ObjectTreasure.skill3 = nil       --大招
ObjectTreasure.skill4 = nil       --特殊技
ObjectTreasure.skill5 = nil       --天赋
ObjectTreasure.skill6 = nil       --小技能
ObjectTreasure.treaType = "base"  --法宝类型 默认是 base

ObjectTreasure.leftRound = 0        --剩余回合数
ObjectTreasure.leftInjury = 0       --剩余伤害抵消
ObjectTreasure.bearRatio = 0        --伤害抵消百分比

ObjectTreasure.treasureLabel = "a"          --法宝标签  a表示a类, b表示b类法宝
ObjectTreasure.isSuyanyan = false
ObjectTreasure.hasAttackSkill = true

-- 技能缓存的key值映射表
local __skillIdx_keyMap = {}
-- 1-8
for i=1,8 do
    __skillIdx_keyMap[i] = "_skillnums_"..i
end

function ObjectTreasure:ctor( hid,datas )
	self.hid = hid
    self.data = datas
    self.__damagePower = 0
    self.hasAttackSkill = true

    self.__charIndex = "A1"
    self.__staticData = ObjectCommon.getPrototypeData( "level.EnemyTreasure",hid)
    -- 法宝的动作
    local sourceId = self:sta_source()
    if IS_CHECK_CONFIG then
        if sourceId == nil then
            echoWarn("self.hid 对应的 sourceId为空")
        end
    end
    -- 1 或者2 表示素颜
    if sourceId == 1 or sourceId == 2 then
        self.isSuyanyan = true
    end

    self.sourceData = ObjectCommon.getPrototypeData( "level.Source",sourceId )
    if IS_CHECK_CONFIG then
        --echo("检查特效文件是否存在，动作是否存在")
        local spine = self.sourceData["spine"]
        --echo("spine",spine)
        if not FuncArmature.getSpineArmatureFrameData(spine) then
            echoWarn("source表"..sourceId.."行中的Spine不存在")
        end
        for k,v in pairs(Fight.actions) do
            local action = self.sourceData[v]
            if not FuncArmature.getSpineArmatureFrameData(spine,action) then
                echoWarn("source表"..sourceId.."行中的"..v.."动作不存在")
            end
        end
    end
    -- 区分男女
    local sex = self:sta_sex()
    if not sex or sex == 1 then
        self.spineName = self.sourceData.spine
    else
        self.spineName = self.sourceData.spineFormale
    end
 
    self.__maxpower = 0

    -- 登场效果
    local inSkill = self:sta_inSkill()
    if inSkill then
        self.onSkill = ObjectSkill.new(inSkill, 1,self.__charIndex,self:sta_dmgE())
        self.onSkill:setTreasure(self,10)
        self.onSkill.showTotalDamage = true
    end

    -- 免疫（免疫的buff type的数组）
    self.__buffImmune = {}
    for _,bt in ipairs(self:sta_buffImmune() or {}) do
        self.__buffImmune[bt] = true
    end

    -- 目前只是一个光环的情况下
    local aura = self:sta_aura()
    if aura then
        self.__aura = aura
    end

    --存储7个技能 ,分别是普攻 小技能 和大招,特殊技,天赋1,天赋2,击杀技 

    --如果是法宝自带技能信息的 表示 是玩家真实技能
    if self.data.skillInfo then
        for i,v in ipairs(self.data.skillInfo) do
            local skillId = v.battleSkillId
            local skillIndex = i+1
            if  v.lock == 1 then
            else
            --[[
            2017.10.13
            修改，从2开始，因为现在已经没有普攻了，
            目前策划普攻的地方会填写小技能的技能，这可能导致技能脚本作用多次
            ]]
                if skillId and skillIndex ~= Fight.skillIndex_normal then
                    local  skill 
                    --如果是被动技
                    if skillIndex == 8 then
                        skill = ObjectSpecialSkill.new(skillId, v,self.__charIndex,v.skillParams)
                    else
                        skill = ObjectSkill.new(skillId, v,self.__charIndex,v.skillParams)
                    end
                    self["skill"..skillIndex] = skill
                    skill:setTreasure(self,skillIndex)
                    -- if i == 3 then
                    -- 技能都显示总伤害2017.7.14
                    if true then
                        --大招显示总伤害
                        skill.showTotalDamage = true
                    end
                end
            end 
       end
    else
        --[[
        2017.10.13
        修改，从2开始，因为现在已经没有普攻了，
        目前策划普攻的地方会填写小技能的技能，这可能导致技能脚本作用多次
        ]]
         for i=2,Fight.maxSkillNums do
         -- for i=1,Fight.maxSkillNums do
            local skillId = self["sta_skill"..i](self)
            if skillId then
                local  skill 
                --如果是被动技
                if i == 8 then
                    skill = ObjectSpecialSkill.new(skillId, {skillParams = self["sta_dmg"..i](self)},self.__charIndex,self["sta_dmg"..i](self))
                else
                    skill = ObjectSkill.new(skillId, {skillParams = self["sta_dmg"..i](self)},self.__charIndex,self["sta_dmg"..i](self))
                end
                self["skill"..i] = skill
                skill:setTreasure(self,i)

                if i == 2 then
                    self.elementEnchanceSKill2 = self.data.elementEnhanceSKill2 or self["sta_dmg"..i](self)
                elseif i == 3 then
                    self.elementEnchanceSKill3 = self.data.elementEnhanceSKill3 or self["sta_dmg"..i](self)
                end
                -- if i == 3 then
                -- 技能都显示总伤害2017.7.14
                if true then
                    --大招显示总伤害
                    skill.showTotalDamage = true
                end
            end
        end
    end

    -- 赋值用于计算技能增强的原始数据
    self._originSkillData = self.data.originSkillData

    --如果没有可以攻击的技能 那么就不让他攻击
    if not self.skill1 and not self.skill2 and not self.skill3 then
        self.hasAttackSkill = false
    end

    self:initData()

    -- if datas.partnerId == "5003" then
    --     dump(datas, "datas =====")

    --     echo("========= 加强之前 ======= ",self.data.partnerId)
    --     local tests = self:getAllSkills()

    --     for i,v in ipairs(tests) do
    --         dump(v.skillParams, "v.skillParams")
    --     end

    --     self:enhanceSkill(5)

    --     echo("========= 加强之后 ======= ",self.data.partnerId)

    --     for i,v in ipairs(tests) do
    --         dump(v.skillParams, "v.skillParams")
    --     end
    -- end
end

--初始化法宝
function ObjectTreasure:initData(  )
    self.leftRound = self:sta_round()or 0

    --判断是否是常驻法宝 
    if not self.leftRound or  self.leftRound == 0 then
        self.leftRound = 9999
    end

    if self.leftRound < 0 then
        self.leftRound = 999
        self.treasureLabel  = Fight.treasureLabel_b
        echo("这是B类法宝",self.hid)
    else
        self.treasureLabel = Fight.treasureLabel_a
    end

    self.leftInjury = 0
    self.bearRatio = 0
end

function ObjectTreasure:setHero( hero )
    self.heroModel = hero
    for i=1,Fight.maxSkillNums do
        if self["skill"..i] then
            self["skill"..i]:setHero(hero)
        end
    end
end
--[[
    增强技能lvl个等级
    更新伙伴技能skillParams
    （在基础等级的基础上，而不是在当前等级的基础上）
]]
function ObjectTreasure:enhanceSkill(exlvl)
    -- lvl = 0 是基础等级 不用重新计算
    local skills = self:getAllSkills()
    if exlvl == 0 then
        for i,skill in ipairs(skills) do
            skill:setSkillParams(exlvl)
        end
        return
    end

    -- echoError("查看技能信息结构")
    -- for i,skill in ipairs(skills) do
    --     echo("skill",skill.hid,skill.skillIndex)
    --     dump(skill.skillParams)
    -- end

    -- 是玩家信息，（这里对于主角的判定比较麻烦）
    local realChar = false -- 真实主角
    if self.data.partnerId and FuncPartner.isChar(self.data.partnerId) and self.data.userData then
        realChar = true
    end

    if self._originSkillData or realChar then
        local tSkillInfos = nil
        -- 主角
        if realChar then
            tSkillInfos = FuncChar.getPartnerSkillParams(self.data.userData,self.data.treasureId,exlvl)
        else
            -- 修改技能等级，传入相关数据
            local tmpInfo = {}
            for id,lvl in pairs(self._originSkillData) do
                -- 是需要加强的技能
                if FuncPartner.isNormalSkill(id) then
                    tmpInfo[id] = lvl + exlvl
                end
            end
            -- 技能
            tSkillInfos = FuncPartner.getPartnerSkillParams({
                id = self.data.partnerId,
                skills = tmpInfo,
            })
        end

        -- 给技能赋值
        for _,skill in ipairs(skills) do
            -- 增强小技能和大招
            if skill.skillIndex == Fight.skillIndex_small 
                or skill.skillIndex == Fight.skillIndex_max
            then
                if tSkillInfos[skill.skillIndex - 1] then
                    skill:setSkillParams(exlvl, tSkillInfos[skill.skillIndex - 1].skillParams)
                end
            end
        end
    else
        -- self.elementEnchanceSKill2
        for i,skill in ipairs(skills) do
            local skillParams = self["elementEnchanceSKill" .. skill.skillIndex]
            if skillParams then
                skill:setSkillParams(exlvl, skillParams)
            end
        end
    end
end
--[[
    做skill的赋值,切记需要使用这个方法
]]
function ObjectTreasure:setSkill(skill, skillIndex)
    -- 低频调用使用字符串拼接
    self["skill"..skillIndex] = skill
    -- 把缓存清掉
    for _,key in ipairs(__skillIdx_keyMap) do
        if self[key] then
            self[key] = nil
        end
    end
end
--[[
    skillIdx 表示要取得skill的最大idx
]]
function ObjectTreasure:getAllSkills(skillIdx)
    local max = skillIdx or Fight.maxSkillNums
    local key = __skillIdx_keyMap[max] -- "_skillnums_"..max
    local tempTb = self[key]
    if tempTb then
        return tempTb
    end
    tempTb = {}
    self[key]  = tempTb

    -- local tempTb = {}
    if max >= 1 and self.skill1 then
        table.insert(tempTb, self.skill1)
    end

    if max >= 2 and self.skill2 then
        table.insert(tempTb, self.skill2)
    end
    if max >= 3 and self.skill3 then
        table.insert(tempTb, self.skill3)
    end
    if max >= 4 and self.skill4 then
        table.insert(tempTb, self.skill4)
    end
    if max >= 5 and self.skill5 then
        table.insert(tempTb, self.skill5)
    end

    if max >= 6 and self.skill6 then
        table.insert(tempTb, self.skill6)
    end
    if max >= 7 and self.skill7 then
        table.insert(tempTb, self.skill7)
    end
    if max >= 8 and self.skill8 then
        table.insert(tempTb, self.skill8)
    end

    return tempTb
end
-- 获取partnerId
function ObjectTreasure:getPartnerId()
    return self.data.partnerId
end

-- 废弃 获取skillInfo
function ObjectTreasure:getSkillInfo()
    return self.data.skillInfo
end

-- 废弃 设置skillInfo（主要处理换法宝用，这里赋值来的skillInfo不一定正确，切不要做数据改动）
function ObjectTreasure:setSkillInfo(skillInfo)
    if not skillInfo then return end
    
    self.data.skillInfo = skillInfo
end

-- 设置技能源数据（主要处理换法宝用，这里赋值来的不一定正确，切不要做数据改动）
function ObjectTreasure:setOriginSkillData( data )
    self._originSkillData = data
end

-- 获取源数据
function ObjectTreasure:getOriginSkillData()
    return self._originSkillData
end

-- 光环buff
function ObjectTreasure:aura( )
    return self.__aura
end
-- 境界
function ObjectTreasure:state( )
    return numEncrypt:getNum(self.data.state)
end
-- 星级
function ObjectTreasure:star( )
    return self.data.star
end
-- 最大威能
function ObjectTreasure:maxpower( )
    return self.__maxpower
end
-- 承受的伤害量
function ObjectTreasure:addDamagePower(dmg)
    self.__damagePower = self.__damagePower + dmg
end
-- debug 信息
function ObjectTreasure:tostring()
    local show = numEncrypt:decodeObject( self.prototypeData )
    dump(show)
end

function ObjectTreasure:getSkill( index )
    if index == 1 then
        return self.skill1
    elseif index == 2 then
        return self.skill2
    elseif index == 3 then
        return self.skill3
    elseif index == 4 then
        return self.skill4
    elseif index == 5 then
        return self.skill5
    elseif index == 6 then
        return self.skill6
    elseif index == 7 then
        return self.skill7
    elseif index == 8 then
        return self.skill8
    end
end

--销毁法宝数据
function ObjectTreasure:deleteMe( )
    self.heroModel = nil
    for i=1,5 do
        local skill = self["skill"..i]
        if skill then
            skill.heroModel = nil
        end
    end
    self._skillnums_5 = nil
    self._skillnums_8 = nil
end


return ObjectTreasure