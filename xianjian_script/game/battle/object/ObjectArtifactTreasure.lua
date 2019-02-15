--[[
	神器法宝数据

	继承自ObjectTreasure去掉不需要的逻辑

    现在不光承担神器(artifact)法宝数据还承担神力(spirit)考虑是不是改下类名
    2018.05.17
]]

local Fight = Fight
-- local BattleControler = BattleControler

ObjectArtifactTreasure = class("ObjectArtifactTreasure", ObjectTreasure)

-- 存技能的方式改变，神器技能和神力技能分开
ObjectArtifactTreasure.artifactSkill = nil
ObjectArtifactTreasure.spiritSkill = nil

-- 重写构造
function ObjectArtifactTreasure:ctor(hid, datas, sex)
	self.hid = hid
    self.data = datas
	self.hasAttackSkill = true

    self.__charIndex = "A1"
    self.__staticData = ObjectCommon.getPrototypeData( "level.EnemyTreasure",hid)

    self.__buffImmune = {}

    self.allSkill = {} -- 存一份所有技能

    self.artifactSkill = {
        [Fight.atSkill_applyType_auto] = {},
        [Fight.atSkill_applyType_manual] = {},
    }

    -- 反向索引神力技能，方便按Id取技能
    self.RartifactSkill = {
        [Fight.atSkill_applyType_auto] = {},
        [Fight.atSkill_applyType_manual] = {},
    }

    self.spiritSkill = {}
    self.RspiritSkill = {} -- 反向索引神力技能，方便按Id取技能

    -- 储存若干个技能的信息，目前不同法宝的技能会存在同一个法宝里
    if self.data.skillInfo then
        for _,v in ipairs(self.data.skillInfo) do
            local skillId = v.battleSkillId
            if v.locak ~= 1 and skillId then
                local skill = ObjectArtifactSkill.new(skillId, v,self.__charIndex,v.skillParams)
                
                if v.isArtifactSkill then
                    table.insert(self.artifactSkill[v.applyType], skill)
                    self.RartifactSkill[v.applyType][tostring(skillId)] = skill
                elseif v.isSpiritSkill then
                    table.insert(self.spiritSkill, skill)
                    self.RspiritSkill[tostring(skillId)] = skill
                end

                skill:setTreasure(self)

                table.insert(self.allSkill, skill)
            end
        end
        -- 初始化时保证神器技能是按照优先级有序的，减少之后的排序操作
        local function sortFunc(a,b)
            if a.priority == b.priority then
                return tonumber(a.hid) < tonumber(b.hid)
            end

            return a.priority < b.priority
        end

        table.sort(self.artifactSkill[Fight.atSkill_applyType_auto], sortFunc)
        table.sort(self.artifactSkill[Fight.atSkill_applyType_manual], sortFunc)
    end

    self:initData()
end

function ObjectArtifactTreasure:setHero(hero)
    self.heroModel = hero
    for _,skill in ipairs(self.allSkill) do
        skill:setHero(hero)
    end
end

-- 获取所有技能
function ObjectArtifactTreasure:getAllSkills()
    return self.allSkill
end

--[[
    获取所有神器技能
    @@atSkillType artifactSkillApplyType 根据神器作用方式获取神器技能
]]
function ObjectArtifactTreasure:getArtifactSkill(atSkillType)
    if atSkillType then
        return self.artifactSkill[atSkillType]
    else
        local result = {}
        for _,skillArr in pairs(self.artifactSkill) do
            for _,skill in ipairs(skillArr) do 
                result[#result + 1] = skill
            end
        end
        return result
    end
end

--[[
    根据id 获取神器技能
]]
function ObjectArtifactTreasure:getArtifactSkillById(atSkillType, skillId)
    if not atSkillType or not skillId then return end

    return self.RartifactSkill[atSkillType][tostring(skillId)]
end

-- 获取所有神力技能
function ObjectArtifactTreasure:getAllSpiritSkill()
    return self.spiritSkill
end

-- 根据技能Id取神力技能
function ObjectArtifactTreasure:getSpiritSkillById(skillId)
    if not skillId then return end

    return self.RspiritSkill[tostring(skillId)]
end

return ObjectArtifactTreasure