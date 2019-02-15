--[[
	Author: lcy
	Date: 2018.08.10
]]

--[[
	蜂灵技能

	技能描述：
	点击后释放，对敌方全体造成伤害

	参数:
	@@maxCount 最大触发次数
	@@atk 赋给神器的攻击力
]]
local Skill_artifact_fengling = class("Skill_artifact_fengling", SkillAiBasic)

function Skill_artifact_fengling:ctor(skill,id, maxCount, atk)
	Skill_artifact_fengling.super.ctor(self, skill,id)

	self:errorLog(maxCount, "maxCount")
	self:errorLog(atk, "atk")

	self._maxCount = tonumber(maxCount or 1)
	self._atk = tonumber(atk or 0)

	self._count = 0
end

-- 攻击前处理攻击力
function Skill_artifact_fengling:onBeforeCheckSkill(selfHero, skill)
	-- 改变神器的攻击力
	selfHero.data:setAttribute(Fight.value_atk, self._atk)
	selfHero.data:setHeroElement(Fight.element_non)

	return skill
end

function Skill_artifact_fengling:onBeforeSkill(selfHero, skill)
	self._count = self._count + 1
end

function Skill_artifact_fengling:manualArtifactCanUse(currentCamp, chance)
	return self._count < self._maxCount
end

-- function Skill_artifact_fengling:autoArtifactCanUse(currentCamp, chance)
-- 	local selfHero = self:getSelfHero()
	
-- 	return chance == Fight.artifact_roundStart and self._count < self._maxCount and selfHero.camp == currentCamp
-- end

return Skill_artifact_fengling