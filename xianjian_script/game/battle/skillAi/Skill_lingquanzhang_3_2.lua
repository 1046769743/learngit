--[[
	Author: lcy
	Date: 208.05.14
]]

--[[
	灵泉杖大招扩充2

	技能描述:
	……如果目标已经处于冰冻状态，提升此次伤害

	脚本处理部分:
	同上

	参数:
	@@rate 额外伤害的系数
]]

local Skill_lingquanzhang_3_2 = class("Skill_lingquanzhang_3_2", SkillAiBasic)

function Skill_lingquanzhang_3_2:ctor(skill,id, rate)
	Skill_lingquanzhang_3_2.super.ctor(self, skill, id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0)
end

-- 处理伤害值
function Skill_lingquanzhang_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 如果已经有冰冻状态
	if defender.data:checkHasOneBuffType(Fight.buffType_bingdong) then
		self:skillLog("灵泉杖大招扩充2触发",self._rate)
		local exDmg = math.round(attacker.data:atk() * self._rate / 10000)
		dmg = dmg + exDmg
	end

	return dmg
end

return Skill_lingquanzhang_3_2