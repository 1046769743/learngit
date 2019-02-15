--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	慕容紫英小技能扩充1

	技能描述：
	小技能，如果攻击时自身气血比例高于70%，则提升自身攻击力一定伤害；

	脚本处理部分：
	满足条件提升伤害量

	参数：
	@@hpper	满足条件的血量比例
	@@rate 满足条件时附加攻击力的伤害比例
]]

local Skill_murongziying_2_1 = class("Skill_murongziying_2_1", SkillAiBasic)

function Skill_murongziying_2_1:ctor(skill,id,hpper,rate)
	Skill_murongziying_2_1.super.ctor(self,skill,id)

	self:errorLog(hpper, "hpper")
	self:errorLog(rate, "rate")

	self._hpper = tonumber(hpper or 0)/10000
	self._rate = tonumber(rate or 0)
end

-- 检查伤害时
function Skill_murongziying_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if attacker.data:getAttrPercent(Fight.value_health) >= self._hpper then
		local exDmg = math.round(attacker.data:atk() * self._rate / 10000)
		self:skillLog("慕容紫英自身血量满足条件,伤害增强",exDmg)
		dmg = dmg + exDmg
	end

	return dmg
end

return Skill_murongziying_2_1