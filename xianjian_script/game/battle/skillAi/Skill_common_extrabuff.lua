--[[
	Author:lcy
	Date: 2018.05.08
]]

--[[
	通用死后给对方加buff脚本

	技能描述:
	同上

	脚本处理部分:
	自己死后，给攻击者加buff

	参数:
	buffId 加的buff的id
]]

local Skill_common_extrabuff = class("Skill_common_extrabuff", SkillAiBasic)

function Skill_common_extrabuff:ctor(skill,id,buffId)
	Skill_common_extrabuff.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = tonumber(buffId or 0)
end

function Skill_common_extrabuff:onOneHeroDied(attacker, defender)
	local selfHero = self:getSelfHero()

	if selfHero ~= defender or not attacker then return end

	self:skillLog("通用脚本Skill_common_extrabuff",self._buffId)
	local buffObj = self:getBuff(self._buffId)
	attacker:checkCreateBuffByObj(buffObj, selfHero, self._skill)
end

return Skill_common_extrabuff