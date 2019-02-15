--[[
	Author:李朝野
	Date: 2017.08.07
	Modify: 2018.03.09
]]
--[[
	唐雨柔被动

	技能描述：
	唐雨柔死亡时，增加己方全体一定攻击力和破击率，持续一回合；

	脚本处理部分：
	唐雨柔死亡时，释放当前技能

	参数：
]]
local Skill_tangyurou_4 = class("Skill_tangyurou_4", SkillAiBasic)

function Skill_tangyurou_4:ctor(skill,id)
	Skill_tangyurou_4.super.ctor(self, skill, id)
	
	self._flag = false
end

--[[
	自己死亡时
]]
function Skill_tangyurou_4:onOneHeroDied( attacker, defender )
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
			-- 放技能
			selfHero:checkSkill(self._skill, false, nil)
		end)
	end
end

function Skill_tangyurou_4:onAfterSkill(selfHero, skill)
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

return Skill_tangyurou_4