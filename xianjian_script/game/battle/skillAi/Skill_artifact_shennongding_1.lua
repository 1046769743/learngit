--[[
	Author: lcy
	Date: 2018.05.29
]]

--[[
	神农鼎1阶效果脚本

	技能描述:
	己方额外获得2点怒气，并在下一回合开始时，减少2点怒气（回合给怒之后结算）

	参数:
	@@maxCount 最大触发次数
	@@energy 额外怒气值
	@@skillId 减怒气时的skillId（用于表现的技能）
]]
local Skill_artifact_shennongding = require("game.battle.skillAi.Skill_artifact_shennongding")
local Skill_artifact_shennongding_1 = class("Skill_artifact_shennongding_1", Skill_artifact_shennongding)

function Skill_artifact_shennongding_1:ctor(skill,id, maxCount, energy, skillId)
	Skill_artifact_shennongding_1.super.ctor(self,skill,id, maxCount)

	self:errorLog(maxCount, "maxCount")
	self:errorLog(energy, "energy")
	self:errorLog(skillId, "skillId")

	self._maxCount = tonumber(maxCount or 1)
	self._energy = tonumber(energy or 0)
	self._exSkillId = skillId

	self._count = 0
	self._flag = false
end

function Skill_artifact_shennongding_1:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	-- 换成减怒的技能
	if self._flag then
		self._flag = false
		result = self:_getExSkill(self._exSkillId, true)
	end

	return result
end

function Skill_artifact_shennongding_1:onBeforeSkill(selfHero, skill)
	self._count = self._count + 1
end

function Skill_artifact_shennongding_1:manualArtifactCanUse()
	-- 没有参数说明是通过点击方式触发的受次数限制
	return self._count < self._maxCount
end

function Skill_artifact_shennongding_1:autoArtifactCanUse(currentCamp, chance)
	local selfHero = self:getSelfHero()
	-- 我方回合前释放
	return self._flag and chance == Fight.artifact_roundStart and selfHero.camp == currentCamp
end

function Skill_artifact_shennongding_1:onAfterSkill(selfHero,skill)
	-- 加怒气
	if tostring(self._skill.hid) == tostring(skill.hid) then
		self._flag = true
		local energyControler = selfHero.controler.energyControler
		-- 通过阵营增长怒气
	    energyControler:addEnergy(Fight.energy_entire , self._energy, nil, selfHero.camp)
	else-- 减怒气
		local energyControler = selfHero.controler.energyControler
		-- 通过阵营增长怒气
	    energyControler:addEnergy(Fight.energy_entire , -self._energy, nil, selfHero.camp)
	end

	return true
end

function Skill_artifact_shennongding_1:_getExSkill(...)
	if not self._exSkill then
		self._exSkill = Skill_artifact_shennongding_1.super._getExSkill(self, ...)
	end

	return self._exSkill
end

return Skill_artifact_shennongding_1