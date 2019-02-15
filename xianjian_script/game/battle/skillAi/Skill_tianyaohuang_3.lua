--[[
	Author: lcy
	Date: 2018.08.04
]]
--[[
	天妖皇怒气

	技能描述：
	攻击全体，消耗自身全部妖能，造成额外伤害，每消耗一层，对所有目标额外造成60%攻击力的伤害

	参数:
	rate 每层妖能造成的额外攻击力伤害的万分比
]]
local Skill_tianyaohuang_3 = class("Skill_tianyaohuang_3", SkillAiBasic)

function Skill_tianyaohuang_3:ctor(skill,id,rate)
	Skill_tianyaohuang_3.super.ctor(self, skill, id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0) / 10000

	self._num = 0 -- 记录当前妖能层数
end

function Skill_tianyaohuang_3:onBeforeSkill(selfHero, skill)
	self._num = selfHero.data:getBuffNumsByType(Fight.buffType_tag_yaoneng)
	-- 消掉所有妖能buff
	selfHero.data:clearBuffByType(Fight.buffType_tag_yaoneng, true, false)
	if self._num then
		self:skillLog("天妖皇消耗:%s层妖能",self._num)
	end
end

function Skill_tianyaohuang_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	if self._num > 0 then
		local exDmg = math.round(self._num * attacker.data:getInitValue(Fight.value_atk) * self._rate)
		self:skillLog("天妖皇额外伤害",exDmg)
		-- 增强伤害
		dmg = dmg + exDmg 
	end

	return dmg
end

function Skill_tianyaohuang_3:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 重置一下
	self._num = 0
end

return Skill_tianyaohuang_3