--[[
	Author:庞康宁
	Date: 2017.11.14
]]


--[[
	星璇大招扩充2 第二段技能伤害系数
	dmgper 附加提升伤害系数（万分比）
]]

local Skill_xingxuan_3_2_1 = class("Skill_xingxuan_3_2_1", SkillAiBasic)

function Skill_xingxuan_3_2_1:ctor( skill,id,dmgper )
	Skill_xingxuan_3_2_1.super.ctor(self, skill,id)
	self._dmgPer = dmgper
end

--[[
	  星璇大招扩充2 伤害系数
]]
function Skill_xingxuan_3_2_1:onCheckAttack(attacker,defender,skill,atkData, dmg)
	local exDmg = math.round(dmg * self._dmgPer/10000)
	self:skillLog("星璇大招扩充2第二段,原伤害:%s,提升伤害:%s",dmg,exDmg)
	dmg = dmg + exDmg
	return dmg
end

return Skill_xingxuan_3_2_1