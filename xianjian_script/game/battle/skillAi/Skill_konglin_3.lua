--[[
	Author:李朝野
	Date: 2017.09.23
]]

--[[
	孔璘大招

	技能描述：


	脚本处理部分：
	孔璘大招会依次攻击三个人，如果分别配攻击包，
	会导致打死一个之后就算没有其他人了也会等到技能结束，
	所以将实现方式改为分别放三个。

	参数：
	@@skills 后两段技能的skillId "xxxxxx_xxxxxx"
]]
local Skill_konglin_3 = class("Skill_konglin_3", SkillAiBasic)


function Skill_konglin_3:ctor(skill,id,skills)
	Skill_konglin_3.super.ctor(self, skill,id)
	
	self:errorLog(skills, "skills")

	self._skills = string.split(skills, "_")

	self._counter = 0 -- 记录当前技能次数
end

--[[
	孔璘在大招之后判断是否还要继续攻击
]]
function Skill_konglin_3:onAfterSkill( selfHero,skill )
	-- 敌方没人了或达到最大次数
	if #selfHero.toArr == 0 or self._counter >= #self._skills then
		-- 检查完毕 次数清零
		self._counter = 0
		return true
	end
	self._counter = self._counter + 1
	-- 进行下一段攻击
	self:skillLog("孔璘进行技能hid:%s",self._skills[self._counter])
	self:_giveskill(self._skills[self._counter], true)

	return false
end

--[[
	skillid 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_konglin_3:_giveskill(skillid, isExpand)
	local selfHero = self:getSelfHero()
	local skill = self._skill
	-- 取技能
	local exSkill = ObjectSkill.new(skillid, 1, "A1", skill.skillParams)
	-- 设置hero
	exSkill:setHero(selfHero)
	-- 设置法宝
	exSkill:setTreasure(skill:getTreasure(), skill:getSkillIndex())
	if isExpand then
		-- 继承扩展行为
		exSkill.skillExpand = skill.skillExpand
	end

	-- 放技能
	selfHero:checkSkill(exSkill, false, skill.skillIndex)
end

return Skill_konglin_3