--[[
	Author: lcy
	Date: 2018.05.22
]]

--[[
	蛤蟆蓝放毒的逻辑

	技能描述:
	蛤蟆蓝。如果目标身上没有中毒，则造成大量伤害。如果有中毒，则清除所有中毒效果（含自身）

	脚本处理部分:
	如描述中处理buff使用

	参数:
	buffId 造成大量伤害的buffId
]]
local Skill_hamalan_2 = class("Skill_hamalan_2", SkillAiBasic)

function Skill_hamalan_2:ctor(skill,id, buffId)
	Skill_hamalan_2.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
end

-- 攻击时进行毒的检查
function Skill_hamalan_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 检查对方身上是否有中毒
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		self:skillLog("蛤蟆蓝的攻击目标中毒,清除毒")
		defender.data:clearBuffByType(Fight.buffType_DOT)
	else
		self:skillLog("蛤蟆蓝的攻击目标没有中毒,造成大量伤害")
		defender:checkCreateBuff(self._buffId, attacker, self._skill)
	end
end

return Skill_hamalan_2