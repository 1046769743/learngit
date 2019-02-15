--[[
	Author:李朝野
	Date: 2018.01.18
]]

--[[
	女娲雪玉技能脚本
	
	技能描述:
	限定技能，每次战斗触发一次。己方奇侠气血最少并且低于30%，在回合结束时，恢复其一定气血值。

	脚本处理:
	检查条件且只触发一次

	参数:
	@@hpPer 触发血量（万分）
	@@maxCount 触发次数
]]

local Skill_artifact_nvwaxueyu = class("Skill_artifact_nvwaxueyu", SkillAiBasic)

function Skill_artifact_nvwaxueyu:ctor( skill,id, hpPer, maxCount)
	Skill_artifact_nvwaxueyu.super.ctor(self, skill,id)

	self:errorLog(hpPer, "hpPer")
	self:errorLog(maxCount, "maxCount")

	self._hpPer = tonumber(hpPer or 0) / 10000
	self._maxCount = tonumber(maxCount or 1)

	self._count = 1
end

function Skill_artifact_nvwaxueyu:onBeforeSkill( ... )
	self._count = self._count + 1
end

function Skill_artifact_nvwaxueyu:autoArtifactCanUse(currentCamp, chance)
	local selfHero = self:getSelfHero()
	-- 己方回合后
	if chance == Fight.artifact_roundEnd and selfHero.camp == currentCamp then
		if self._count <= self._maxCount then
			-- 检查血量是否有少于目标的
			local selfHero = self:getSelfHero()
			for _,hero in ipairs(selfHero.campArr) do
				if SkillBaseFunc:isLiveHero(hero) then
					if hero.data:hp() / hero.data:maxhp() <= self._hpPer then
						return true
					end
				end
			end
		end
	end

	return false
end

return Skill_artifact_nvwaxueyu