--[[
	Author:李朝野
	Date: 2017.09.26
	2018.01.11 废弃
]]

--[[
	火神大招

	技能描述：
	用于火神选敌后清除buff用
]]
local Skill_trail_huoshen_buffclear = class("Skill_trail_huoshen_buffclear", SkillAiBasic)

function Skill_trail_huoshen_buffclear:ctor( ... )
	Skill_trail_huoshen_buffclear.super.ctor(self, ...)
end

function Skill_trail_huoshen_buffclear:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	if defender.data:checkHasOneBuffType(Fight.buffType_sign) then
		self:skillLog("火神清理被击者的标记")
		defender.data:clearBuffByType(Fight.buffType_sign, true)
	end

	return dmg
end

return Skill_trail_huoshen_buffclear