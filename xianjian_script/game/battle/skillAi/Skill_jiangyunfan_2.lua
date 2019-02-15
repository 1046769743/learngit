--[[
	Author:李朝野
	Date: 2017.08.30
	Modify: 2018.03.12
]]

--[[
	姜云凡小技能

	技能描述:
	攻击敌方单体，并恢复15%伤害量的气血；如果目标处于流血状态，则自身释放额外回血；

	脚本处理部分：
	若攻击的敌人流血则为自己回血

	参数：
	atkId 额外回血攻击包
]]

local Skill_jiangyunfan_2 = class("Skill_jiangyunfan_2", SkillAiBasic)

function Skill_jiangyunfan_2:ctor(skill,id, atkId)
	Skill_jiangyunfan_2.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)

	self._flag = false -- 标记是否触发额外回血
end

-- 攻击时检查敌人是否处于流血状态
function Skill_jiangyunfan_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if defender.data:checkHasOneBuffType(Fight.buffType_liuxue) then
		self:skillLog("姜云凡攻击阵营:%s,%s号位，此人带有流血效果",defender.camp,defender.data.posIndex)
		-- 标记
		self._flag = true
	end
end

-- 攻击结束以后
function Skill_jiangyunfan_2:onAfterSkill(selfHero, skill)
	if self._flag then
		self._flag = false
		selfHero:sureAttackObj(selfHero, self._atkData, skill)
	end

	return true
end

return Skill_jiangyunfan_2