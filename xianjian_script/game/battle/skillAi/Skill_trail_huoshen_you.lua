--[[
	Author:李朝野
	Date: 2018.01.11
]]

--[[
	火神火上浇油

	技能描述:
	攻击带有火上浇油buff的人，每一层伤害加深一次

	脚本处理:
	统计受击者火上浇油buff个数n，dmg * n
]]
local Skill_trail_huoshen_you = class("Skill_trail_huoshen_you", SkillAiBasic)

function Skill_trail_huoshen_you:ctor( ... )
	Skill_trail_huoshen_you.super.ctor(self, ...)
end

function Skill_trail_huoshen_you:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	local num = defender.data:getBuffNumsByType(Fight.buffType_huoshangjiaoyou)

	self:skillLog("当前目标制定buff的层数:%s",num)

	dmg = dmg * (num + 1)

	return dmg
end

return Skill_trail_huoshen_you