--[[
	Author:庞康宁
	Date: 2017.11.13
	Detail: 大招扩充1：当主角释放炫龙拳以前，如果获得了增益类Buff，使用另一个表现的大招

	exSkillId：特殊表表现大招id
]]


local Skill_treasureLongxing_3_1 = class("Skill_treasureLongxing_3_1", SkillAiBasic)


function Skill_treasureLongxing_3_1:ctor(skill,id,exSkillId)
	Skill_treasureLongxing_3_1.super.ctor(self,skill,id)
	self._exSkillId = exSkillId
end


function Skill_treasureLongxing_3_1:onBeforeCheckSkill(selfHero, skill)
	local result = skill
	-- 检查角色身上是否有增益类buff
	if selfHero.data:checkHasKindBuff(Fight.buffKind_hao) then
		local exSkill = ObjectSkill.new(self._exSkillId, 1, "A1", skill.skillParams)
		-- 设置hero
		exSkill:setHero(selfHero)
		-- 设置法宝
		exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
		result = exSkill
	end
	return result
end
return Skill_treasureLongxing_3_1