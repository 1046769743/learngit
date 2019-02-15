--[[
	Author:李朝野
	Date: 2017.06.23
]]
--[[
	林月如大招

	技能描述：
	攻击中排两人；在蓄力凝聚时对自身施加Buff：将接下来一回合内受到的伤害转换为一定攻击力；
	修改版：
	斩龙诀，攻击敌方中排单体；如果带有被动的4把剑效果时，消耗全部剑，改为打一排；

	脚本处理部分：
	如果带有被动的4把剑效果时，消耗全部剑，改为打一排；

	参数：
	skillid 攻击一排的技能id（原技能攻击一个）
]]
local Skill_linyueru_3 = class("Skill_linyueru_3", SkillAiBasic)

function Skill_linyueru_3:ctor(skill,id,skillid)
	Skill_linyueru_3.super.ctor(self, skill, id)

	self:errorLog(skillid, "skillid")

	self._exSkill = skillid or 1
end
--[[
	根据剑的个数判断该放哪个技能
]]
function Skill_linyueru_3:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	local selfHero = self:getSelfHero()
	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end

	local count = skill4expand:getRuneNum()

	-- 有4把剑大招放攻击一排的
	if count == 4 then
		self:skillLog("林月如剑数:%s，大招使用技能id %s", count, self._exSkill)
		-- 消耗掉所有剑
		-- skill4expand:useRune(count)
		result = self:_giveSkill(self._exSkill, true)
	end

	return result
end

--[[
	skillId 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_linyueru_3:_giveSkill(skillId, isExpand)
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

return Skill_linyueru_3