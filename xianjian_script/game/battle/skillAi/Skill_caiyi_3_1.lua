--[[
	Author:lcy
	Date: 2018.03.08
]]

--[[
	彩依大招扩充1

	技能描述:
	释放怒气仙术时，如果目标血量低于30%，额外恢复100%彩依攻击力的生命值

	脚本处理部分:
	如果满足条件，对目标做攻击包

	参数:
	@@hpPer 满足要求的目标血量
	@@atkId 带有加血buff的攻击包
]]

local Skill_caiyi_3_1 = class("Skill_caiyi_3_1", SkillAiBasic)

function Skill_caiyi_3_1:ctor(skill,id, hpPer, atkId)
	Skill_caiyi_3_1.super.ctor(self, skill, id)

	self:errorLog(hpPer, "hpPer")
	self:errorLog(atkId, "atkId")

	self._hpPer = tonumber(hpPer or 0) / 10000
	self._atkData = ObjectAttack.new(atkId)

	-- 标记将要触发额外恢复
	self._defender = nil
end

-- 检查目标血量
function Skill_caiyi_3_1:onCheckTreat(attacker,defender,skill,atkData, dmg)
	-- 目标血量
	local hpPer = defender.data:getAttrPercent(Fight.value_health)

	if hpPer <= self._hpPer then
		self:skillLog("被治疗者血量比例满足条件",hpPer)
		self._defender = defender
	end

	return dmg
end

-- 技能结束后给目标加一个额外攻击包
function Skill_caiyi_3_1:onAfterSkill(selfHero, skill)
	if self._defender then
		local defender = self._defender
		self._defender = nil
		self:skillLog("彩依对目标做额外恢复",self._atkData.hid)
		selfHero:sureAttackObj(defender,self._atkData,self._skill)
	end

	return true
end

return Skill_caiyi_3_1