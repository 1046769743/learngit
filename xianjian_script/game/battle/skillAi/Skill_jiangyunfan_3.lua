--[[
	Author:李朝野
	Date: 2017.08.30
]]

--[[
	姜云凡大招

	技能描述:
	飞速冲向对手，犹如划过天空的神龙，连续给对手重创。对单个敌人造成伤害，特效在攻击时请做出吸血效果
	修改版：
	如果自身血量低于35%时，吸血回复量翻倍

	脚本处理部分：
	对敌人造成伤害后进行吸血（根据自身血量决定释放哪个技能）

	参数：
	skillId 满足条件之后放的技能
	ratio 满足血量（万分）
]]
local Skill_jiangyunfan_3 = class("Skill_jiangyunfan_3", SkillAiBasic)

function Skill_jiangyunfan_3:ctor(skill,id, skillId, ratio)
	Skill_jiangyunfan_3.super.ctor(self, skill, id)

	self:errorLog(skillId, "skillId")
	self:errorLog(ratio, "ratio")

	self._exSKill = skillId or skill.hid
	self._ratio = tonumber(ratio) / 10000 or 0
end

-- 注册监听（目前仅有处理动作的作用）
function Skill_jiangyunfan_3:onSetHero(selfHero)
	if Fight.isDummy  then
		return
	end

	-- 监听血量
	selfHero.data:addEventListener(BattleEvent.BATTLEEVENT_CHANGEHEALTH, self.onConditionChange, self)
	-- 监听怒气
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_CHANGE, self.onConditionChange, self)
	-- 监听怒气消耗
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_COST_CHANGE, self.onConditionChange, self)
	-- 监听怒气返还
	FightEvent:addEventListener(BattleEvent.BATTLEEVENT_ENERGY_RETURN, self.onConditionChange, self)
end

-- 监听函数
function Skill_jiangyunfan_3:onConditionChange(event)
	local selfHero = self:getSelfHero()
	-- 血量满足同时怒气满足
	local hprate = selfHero.data:getAttrPercent(Fight.value_health)
	selfHero:setUseSpStand(hprate < self._ratio and true)--selfHero.data:isEnergyEnough())
end

--[[
	根据自己的血量情况选择释放技能
]]
function Skill_jiangyunfan_3:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	local per = selfHero.data:hp() / selfHero.data:maxhp()
	if per <= self._ratio then
		self:skillLog("姜云凡血量比例%s 释放大量回血大招", per)
		result = self:_giveSkill(self._exSKill, true)
	end

	return result
end

--[[
	id 放的技能id
	isExpand 是否继承扩展行为
]]
function Skill_jiangyunfan_3:_giveSkill(skillId, isExpand)
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

return Skill_jiangyunfan_3