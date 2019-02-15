--[[
	Author: lcy
	Date: 2018.08.04
]]
--[[
	邪剑仙被动

	技能描述：
	当收到邪念状态的单位攻击时，增加自身攻击力

	参数:
	buffId 增加攻击力的buffId
]]
local Skill_xiejianxian_4 = class("Skill_xiejianxian_4", SkillAiBasic)

function Skill_xiejianxian_4:ctor(skill,id, buffId)
	Skill_xiejianxian_4.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")

	self._buffId = tonumber(buffId or 0)
end

function Skill_xiejianxian_4:onAfterHited(selfHero, attacker, skill, atkData)
	-- 自己活着才生效
	if not SkillBaseFunc:isLiveHero(selfHero) then return end
	-- 检查buff
	if not attacker.data:checkHasOneBuffType(Fight.buffType_tag_xienian) then return end

	self:skillLog("邪剑仙被有邪念buff的人攻击，对自己施加buff",self._buffId)
	selfHero:checkCreateBuff(self._buffId, selfHero, self._skill)
end

return Skill_xiejianxian_4