
-- Author:庞康宁
-- Date: 2017.09.14
-- des: 盗宝者 逃跑

local Skill_trial_daobaozhe_2 = class("Skill_trial_daobaozhe_2", SkillAiBasic)

function Skill_trial_daobaozhe_2:ctor(skill,id)
	Skill_trial_daobaozhe_2.super.ctor(self,skill,id)
end

-- 即将进行 攻击完毕判定时候
function Skill_trial_daobaozhe_2:willNextAttack(attacker )
	if not self:isSelfHero(attacker) or self._skill ~= attacker.currentSkill then 
		return 
	end
	attacker:doHeroDie(true)
end
return Skill_trial_daobaozhe_2