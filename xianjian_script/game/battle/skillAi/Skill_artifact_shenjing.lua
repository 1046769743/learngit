--[[
	Author:李朝野
	Date: 2018.01.18
]]

--[[
	烟月神镜技能脚本
	
	技能描述:
	登场阶段，在首个回合前，敌我双方带有烟月神镜的，前排奇侠获得伤害吸收盾。

	脚本处理:
	首回合触发一次
]]

local Skill_artifact_shenjing = class("Skill_artifact_shenjing", SkillAiBasic)

function Skill_artifact_shenjing:ctor( skill,id)
	Skill_artifact_shenjing.super.ctor(self, skill,id)

	self._isfirst = true
end

function Skill_artifact_shenjing:onBeforeSkill( ... )
	self._isfirst = false
end

function Skill_artifact_shenjing:autoArtifactCanUse(currentCamp, chance)
	local selfHero = self:getSelfHero()
	-- 在敌方回合开始前
	if chance == Fight.artifact_roundStart and self._isfirst and selfHero.camp ~= currentCamp then
		-- self._isfirst = false
		return true
	end

	return false
end

return Skill_artifact_shenjing