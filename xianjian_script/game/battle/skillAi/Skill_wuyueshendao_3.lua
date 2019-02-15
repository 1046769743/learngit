--[[
	Author:李朝野
	Date: 2018.01.08
]]

--[[
	主角法宝巫月神刀大招

	技能描述:
	连续6次选取敌方一人作为目标进行攻击；
	当目标被击杀后，立刻切换目标执行剩余攻击；

	脚本处理部分:
	记录技能段数，依次执行；

	参数:
	@@skills 分段技能skillId序列 "xxxx_xxx" (第一段除外)
]]
local Skill_wuyueshendao_3 = class("Skill_wuyueshendao_3", SkillAiBasic)

function Skill_wuyueshendao_3:ctor(skill,id, skills)
	Skill_wuyueshendao_3.super.ctor(self,skill,id)

	self:errorLog(skills, "skills")

	self._skills = string.split(skills, "_")
	self._maxcount = #self._skills -- 记录最大段数
	self._count = 0 --  记录当前技能段数
end

-- 在大招攻击结束后做
function Skill_wuyueshendao_3:onAfterSkill(selfHero, skill)
	local result = true

	if self:chkGoOnSkill() then
		local isStitched = false
		if self._count > 1 then isStitched = true end
		-- 继续放下一段技能
		self:_giveSkill(self._skills[self._count], true, isStitched)
		result = false
	end

	return result
end

-- 大招结束之后判断是否继续放
function Skill_wuyueshendao_3:chkGoOnSkill()
	local selfHero = self:getSelfHero()
	local result = false
	
	self._count = self._count + 1

	if self._count <= self._maxcount and SkillBaseFunc:chkLiveHero(selfHero.toArr) then
		result = true
	else
		self._count = 0
	end

	return result
end

return Skill_wuyueshendao_3