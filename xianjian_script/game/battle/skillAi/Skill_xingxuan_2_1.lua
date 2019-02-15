--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	星璇小技能扩充1

	技能描述：
	小技能，如果自身血线高于目标（攻击前），则提升自身攻击万分比的伤害；

	脚本处理部分：
	当前技能攻击满足条件角色时，增加伤害

	参数：
	@@rate 满足条件时附加伤害的比例
]]

local Skill_xingxuan_2_1 = class("Skill_xingxuan_2_1", SkillAiBasic)

function Skill_xingxuan_2_1:ctor(skill,id,rate)
	Skill_xingxuan_2_1.super.ctor(self,skill,id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0)
end

-- 检查伤害时
function Skill_xingxuan_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 如果自身血量高于受击方
	if attacker.data:getAttrPercent(Fight.value_health) >= defender.data:getAttrPercent(Fight.value_health) then
		local exDmg = math.round(attacker.data:atk() * self._rate / 10000)
		self:skillLog("敌人血线低于星璇，伤害增强",exDmg)
		dmg = dmg + exDmg
	end

	return dmg
end

return Skill_xingxuan_2_1