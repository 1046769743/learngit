--[[
	Author: lcy
	Date: 2018.05.29
]]

--[[
	神农鼎基础脚本

	技能描述:
	点击增加己方全体攻击力

	参数:
	@@maxCount 最大触发次数
]]
local Skill_artifact_shennongding = class("Skill_artifact_shennongding", SkillAiBasic)

function Skill_artifact_shennongding:ctor(skill,id, maxCount)
	Skill_artifact_shennongding.super.ctor(self, skill,id)

	self:errorLog(maxCount, "maxCount")

	self._maxCount = tonumber(maxCount or 1)

	self._count = 0
end

function Skill_artifact_shennongding:onBeforeSkill(selfHero, skill)
	self._count = self._count + 1
end

function Skill_artifact_shennongding:manualArtifactCanUse(currentCamp, chance)
	return self._count < self._maxCount
end

return Skill_artifact_shennongding