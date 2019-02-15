--[[
	Author:李朝野
	Date: 2017.08.23
]]

--[[
	林月如小技能（联动被动）

	技能描述:
	打敌方单体；
	如果林月如带有剑，则对目标身后一人造成伤害；
	2017.9.18修改
	当有剑的时候释放打两个角色的技能
	
	脚本处理部分：
	-- 如果林月如带有剑，则对目标身后一人造成伤害；

	参数：
	skillId 满足条件之后放的技能
]]
local Skill_linyueru_2 = class("Skill_linyueru_2", SkillAiBasic)

function Skill_linyueru_2:ctor(skill,id, skillId)
	Skill_linyueru_2.super.ctor(self, skill, id)

	self:errorLog(skillId, "skillId")

	self._exSkill = skillId or skill.hid
end

function Skill_linyueru_2:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return result end

	local count = skill4expand:getRuneNum()
	-- 有剑换技能
	if count > 0 then
		self:skillLog("林月如符文数:%s，换技能", count)
		result = self:_giveSkill(self._exSkill, false)
	end

	return result
end

--[[
	id 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_linyueru_2:_giveSkill(skillId, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillId, 1, "A1", skill.skillParams)
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())

	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	return exSkill
end

return Skill_linyueru_2