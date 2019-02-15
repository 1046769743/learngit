
-- Author:庞康宁
-- Date: 2017.07.29
-- des: 自爆逻辑、动作结束之后，直接强制调用移除自己的逻辑(不播放死亡动作)

local Skill_trail_zibao = class("Skill_trail_zibao", SkillAiBasic)

function Skill_trail_zibao:ctor(skill,id)
	Skill_trail_zibao.super.ctor(self,skill,id)
end

-- function Skill_trail_zibao:willNextAttack( attacker )
-- 	if not self:isSelfHero(attacker) or self._skill ~= attacker.currentSkill then 
-- 		return 
-- 	end
-- 	attacker:doHeroDie(true)
-- 	echo("eee----自爆")
-- end
function Skill_trail_zibao:onAfterSkill(selfHero,skill)
	-- echo("攻击结束====")
	if BattleControler:checkIsTrail() ~= Fight.not_trail then
		selfHero.controler:updateTrialGoldNum(selfHero)
	end
	selfHero:doHeroDie(true)
	return true
end

return Skill_trail_zibao