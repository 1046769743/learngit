--[[
	Author: lcy
	Date: 2018.08.04
]]
--[[
	苏媚大招

	技能描述：
	攻击一行敌人；如果目标在攻击前已经携带忘魂效果，则眩晕；

	参数：
	buffIds 满足条件时需要施加的所有buffId "xxx_xxx_xxx"

	备注，将技能自带的忘魂buff放在靠后的攻击包上，检查是否携带忘魂的时机是第一个伤害攻击包时
]]
local Skill_sumei_3 = class("Skill_sumei_3", SkillAiBasic)

function Skill_sumei_3:ctor(skill,id, buffIds)
	Skill_sumei_3.super.ctor(self, skill, id)

	self:errorLog(buffIds, "buffIds")

	self._buffIds = string.split(buffIds, "_")
end

function Skill_sumei_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 检查目标身上是否有忘魂
	if defender.data:checkHasOneBuffType(Fight.buffType_wanghun) then
		self:skillLog("苏媚攻击带有忘魂的，阵营:%s,%s号位，对其施加buffId",defender.camp,defender.data.posIndex)
		for _,buffId in ipairs(self._buffIds) do
			self:skillLog("id",buffId)
			defender:checkCreateBuff(buffId, attacker, self._skill)
		end
	end

	return dmg
end

return Skill_sumei_3