--[[
	Author:李朝野
	Date: 2017.08.04
	Modify: 2018.03.10
]]
--[[
	王蓬絮被动

	技能描述：
	王蓬絮死亡时，释放死亡技：领击杀者本场战斗无法获得任何增益效果并且该效果无法被驱散，同时清除敌方全体增益状态

	脚本处理部分：
	王蓬絮死亡时，释放当前脚本技能，额外给击杀者释放免疫增益的攻击包

	参数：
	atkId 带阻止增益buff的攻击包
]]
local Skill_wangpengxu_4 = class("Skill_wangpengxu_4", SkillAiBasic)

function Skill_wangpengxu_4:ctor(skill,id,atkId)
	Skill_wangpengxu_4.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)

	self._flag = false
	self._attacker = nil
end

--[[
	自己死亡时
]]
function Skill_wangpengxu_4:onOneHeroDied(attacker, defender)
	local selfHero = self:getSelfHero()

	if selfHero ~= defender then return end

	if not self._flag then
		self._flag = true
		selfHero.willDieSkill = true
		if selfHero.healthBar then
			selfHero.healthBar:opacity(0)
		end

		-- 记录一下击杀者
		self._attacker = attacker

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			selfHero.data:changeValue(Fight.value_health, 1, Fight.valueChangeType_num)			
			selfHero.willDieSkill = false
			-- 放技能
			selfHero:checkSkill(self._skill, false, nil)
		end)
	end
end

-- 放完技能干掉自己
function Skill_wangpengxu_4:onAfterSkill(selfHero, skill)
	if skill == self._skill then
		-- 对击杀者做判断
		if self._attacker and SkillBaseFunc:isLiveHero(self._attacker) then
			selfHero:sureAttackObj(self._attacker, self._atkData, self._skill)
		end
		-- 不是复活的
		if not selfHero:checkWillBeRelive() then
			selfHero:doHeroDie(true)
		else
			selfHero:setOpacity(0)
		end
	end

	return true
end

return Skill_wangpengxu_4