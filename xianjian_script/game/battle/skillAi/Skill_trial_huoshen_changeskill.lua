--[[
	Author:李朝野
	Date: 2018.01.15
]]

--[[
	火神根据对面人数决定放哪个技能

	参数:
	@@exSkillId 不足6人时的技能Id
]]
local Skill_trial_huoshen_changeskill = class("Skill_trial_huoshen_changeskill", SkillAiBasic)

function Skill_trial_huoshen_changeskill:ctor(skill,id,exSkillId)
	Skill_trial_huoshen_changeskill.super.ctor(self,skill,id)

	self:errorLog(exSkillId, "exSkillId")

	self._exSkillId = exSkillId
end

-- 根据情况换技能
function Skill_trial_huoshen_changeskill:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	-- 统计人数
	local count = 0
	for _,hero in ipairs(selfHero.toArr) do
		if SkillBaseFunc:isLiveHero(hero) then
			count = count + 1
		end
	end

	-- 判断满足
	if self._exSkillId and count < 6 then
		-- 新获得一个技能（伤害系数走原技能的）
		local exSkill = ObjectSkill.new(self._exSkillId, 1, "A1", skill.skillParams)
		-- 设置hero
		exSkill:setHero(selfHero)
		-- 设置法宝
		exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand

		result = exSkill
	end

	return result
end

return Skill_trial_huoshen_changeskill