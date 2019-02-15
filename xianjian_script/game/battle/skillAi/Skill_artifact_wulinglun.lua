--[[
	Author: lcy
	Date: 2018.05.29
]]

--[[
	五灵轮技能脚本

	技能描述:
	点击后立刻选择敌方气血值最低的单位（需要排除石头、仙人掌等中立怪），释放一次唤灵攻击（随机五行类型，参与五灵阵法的抗性减免）。

	脚本处理:
	选敌,换技能,给神器赋值攻击力等

	参数:
	@@maxCount 最大触发次数
	@@atk 赋给神器的攻击力
	@@skills 五个五灵技能 "1_2_3_4_5" 顺序 风雷水火土  
]]

local Skill_artifact_wulinglun = class("Skill_artifact_wulinglun", SkillAiBasic)

function Skill_artifact_wulinglun:ctor(skill,id, maxCount, atk, skills)
	Skill_artifact_wulinglun.super.ctor(self, skill, id)

	self:errorLog(maxCount, "maxCount")
	self:errorLog(atk, "atk")
	self:errorLog(skills, "skills")

	self._maxCount = tonumber(maxCount or 0)
	self._atk = tonumber(atk or 0)
	self._skills = string.split(skills, "_")

	self._exSkills = {}

	self._count = 0
end

function Skill_artifact_wulinglun:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	-- 随机一个出来
	local element = BattleRandomControl.getOneRandomInt(#self._skills + 1, 1)
	self:skillLog("五灵轮随机出来的五灵为",element)

	result = self:_getExSkill(self._skills[element], true)

	-- 改变神器的攻击力
	selfHero.data:setAttribute(Fight.value_atk, self._atk)
	selfHero.data:setHeroElement(element)

	return result
end

function Skill_artifact_wulinglun:onBeforeSkill(selfHero, skill)
	self._count = self._count + 1
end

function Skill_artifact_wulinglun:manualArtifactCanUse(currentCamp, chance)
	return self._count < self._maxCount
end

function Skill_artifact_wulinglun:_getExSkill(skillid, isExpand)
	if not self._exSkills[skillid] then
		self._exSkills[skillid] = Skill_artifact_wulinglun.super._getExSkill(self, skillid, isExpand)
	end

	return self._exSkills[skillid]
end

return Skill_artifact_wulinglun