--[[
	Author: lcy
	Date: 2018.05.11
]]
--[[
	谢沧行被动

	技能描述:
	谢沧行死亡时，为攻击目标释放增加怒气消耗buff，持续整场战斗，不可被驱散

	脚本处理部分:
	谢沧行死亡时，释放当前技能

	参数:
	当前技能即为给敌方增加怒气消耗buff的技能
]]
local Skill_xiecangxing_4 = class("Skill_xiecangxing_4", SkillAiBasic)

function Skill_xiecangxing_4:ctor(skill,id)
	Skill_xiecangxing_4.super.ctor(self, skill, id)

	self._flag = false
end

--[[
	自己死亡时
]]
function Skill_xiecangxing_4:onOneHeroDied( attacker, defender )
	local selfHero = self:getSelfHero()

	if selfHero ~= defender then return end

	if not self._flag then
		self._flag = true
		selfHero.willDieSkill = true -- 防止对象被删除
		if selfHero.healthBar then
			selfHero.healthBar:opacity(0)
		end

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)
			selfHero.willDieSkill = false
			-- 钦定攻击目标为击杀者
			self._skill:setAppointAtkChooseArr({attacker})
			-- 放技能
			selfHero:checkSkill(self._skill, false, nil)
		end)
	end
end

function Skill_xiecangxing_4:onAfterSkill(selfHero, skill)
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

return Skill_xiecangxing_4