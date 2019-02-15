--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	阎罗王大招

	技能描述:
	怒气仙术，对低气血目标造成额外伤害。

	脚本处理部分:
	同上

	参数:
	hpper 血量边界值
	atkId 额外伤害攻击包（使用buff做伤害）
]]

local Skill_yanluowang_3 = class("Skill_yanluowang_3", SkillAiBasic)

function Skill_yanluowang_3:ctor(skill,id, hpper, atkId)
	Skill_yanluowang_3.super.ctor(self,skill,id)

	self:errorLog(hpper, "hpper") 
	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
	self._hpper = tonumber(hpper or 0) / 10000
end

-- 攻击时做检查
function Skill_yanluowang_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 判断血量值
	if defender.data:getAttrPercent(Fight.value_health) <= self._hpper then
		self:skillLog("血量满足阎罗王大招需求，做攻击包")
		attacker:sureAttackObj(defender, self._atkData, self._skill)
	end
end

return Skill_yanluowang_3