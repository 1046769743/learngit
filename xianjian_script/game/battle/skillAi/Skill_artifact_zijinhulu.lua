--[[
	Author: lcy
	Date: 2018.05.25
]]

--[[
	紫金葫芦技能技能脚本

	技能描述:
	第一回合，降低敌方全体攻击力与防御力持续一回合。	

	脚本处理:
	检查条件且只能触发一次

	参数:
	@@maxCount 最大触发次数
]]

local Skill_artifact_zijinhulu = class("Skill_artifact_zijinhulu", SkillAiBasic)

function Skill_artifact_zijinhulu:ctor(skill,id, maxCount)
	Skill_artifact_zijinhulu.super.ctor(self, skill, id)

	self:errorLog(maxCount, "maxCount")

	self._maxCount = tonumber(maxCount or 1)

	self._count = 0
end

function Skill_artifact_zijinhulu:onBeforeSkill(selfHero, skill)
	self._count = self._count + 1
end

function Skill_artifact_zijinhulu:autoArtifactCanUse(currentCamp, chance)
	local selfHero = self:getSelfHero()

	-- 己方回合前
	if chance == Fight.artifact_roundStart and selfHero.camp == currentCamp then
		return self._count < self._maxCount
	end

	return false
end

return Skill_artifact_zijinhulu