--[[
	Author: lcy
	Date: 2018.05.11
]]
--[[
	谢沧行大招扩充2

	技能描述:
	自身获得罡斩buff，若次回合内有角色阵亡，不论敌我，则己方获得怒气

	脚本处理部分:
	同上

	参数:
	buffId 加怒气的buff
]]
local Skill_xiecangxing_3_2 = class("Skill_xiecangxing_3_2", SkillAiBasic)

function Skill_xiecangxing_3_2:ctor(skill,id, buffId)
	Skill_xiecangxing_3_2.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
end

--[[
	有人死亡时
]]
function Skill_xiecangxing_3_2:onOneHeroDied( attacker, defender )
	local selfHero = self:getSelfHero()

	if selfHero == defender then return end

	-- 没有罡斩buff
	if not selfHero.data:checkHasOneBuffType(Fight.buffType_tag_gangzhan) then return end

	self:skillLog("谢沧行大招扩充2，罡斩给自己加怒气")
	-- 加怒气
	selfHero:checkCreateBuff(self._buffId, selfHero, self._skill)
end

return Skill_xiecangxing_3_2