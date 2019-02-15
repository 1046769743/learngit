--[[
	Author:李朝野
	Date: 2018.01.19
]]

--[[
	辅助类小技能使用

	技能描述:
	当技能无法选到敌人时，使用另一个技能进行替换，目前仅适用于固定选敌无特殊逻辑的伙伴
	
	脚本处理部分:
	提前选敌替换技能

	参数:
	@@skillId 备选技能的技能Id
]]
local Skill_assistskill_change = class("Skill_assistskill_change", SkillAiBasic)

function Skill_assistskill_change:ctor(skill,id, skillId)
	Skill_assistskill_change.super.ctor(self, skill, id)

	self:errorLog(skillId, "skillId")

	self._exSkillId = skillId
end

-- 回合前遍历检查能打到的人，如果没能选到则换技能
function Skill_assistskill_change:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	local chooseArr = AttackChooseType:getSkillCanAtkEnemy(selfHero,skill,true)

	-- 检查要不要换
	local flag = true
	local tHero = nil
	for _,hero in ipairs(chooseArr) do
		-- 除了替代的人还有其他人就认为找到人了
		if not hero.randomHero then
			flag = false
			tHero = hero
		end
	end

	if flag then
		-- 新获得一个技能（伤害系数走原技能的）
		result = self:_getExSkill(self._exSkillId, false)
	end

	return result,tHero
end

return Skill_assistskill_change