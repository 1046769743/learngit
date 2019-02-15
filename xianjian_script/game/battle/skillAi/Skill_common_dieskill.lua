--[[
	Author: lcy
	Date: 2018.05.31
]]
--[[
	通用死亡技

	脚本处理内容:
	主体死亡时，释放当前技能

	参数:
]]

local Skill_common_dieskill = class("Skill_common_dieskill", SkillAiBasic)

function Skill_common_dieskill:ctor(...)
	Skill_common_dieskill.super.ctor(self, ...)

	self._flag = false
end

--[[
	自己死亡时
]]
function Skill_common_dieskill:onOneHeroDied(attacker, defender)
	if not self:isSelfHero(defender) then return end

	local selfHero = self:getSelfHero()

	if not self._flag then
		self._flag = true
		selfHero.willDieSkill = true -- 防止对象被删除
		if selfHero.healthBar then
			selfHero.healthBar:opacity(0)
		end

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
			selfHero.willDieSkill = false
			-- 放技能
			selfHero:checkSkill(self._skill, false, nil)
		end)
	end
end

function Skill_common_dieskill:onAfterSkill(selfHero, skill)
	if skill == self._skill then
		-- 不是复活的
		if not selfHero:checkWillBeRelive() then
			selfHero:doHeroDie(true)
		else
			selfHero:setOpacity(0)
		end
	end

	return true
end

return Skill_common_dieskill