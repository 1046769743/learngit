--[[
	Author: lcy
	Date: 2018.03.21
]]

--[[
	剑圣普攻

	技能描述:
	攻击一行，如果伏魔状态，减少50%伤害量的治疗上限。

	脚本处理部分:
	联动被动技能根据伤害做额外buff

	参数:
	@@buffId 减少治疗上限的buff（作用类型为值，具体值由脚本赋值）
	@@rate 减少的治疗上限占伤害量的比率
]]

local Skill_jiansheng_2 = class("Skill_jiansheng_2", SkillAiBasic)

function Skill_jiansheng_2:ctor(skill,id, buffId, rate)
	Skill_jiansheng_2.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")
	self:errorLog(rate, "rate")

	self._buffId = buffId or 0
	self._rate = tonumber(rate or 0)

	self._value = {} -- 记录伤害值
end

-- 记录伤害
function Skill_jiansheng_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	self._value[defender] = math.round(self._rate * dmg / 10000)

	return dmg
end

-- 最后一个攻击包后附加buff
function Skill_jiansheng_2:onAfterAttack(attacker, defender, skill, atkData)
	local selfHero = self:getSelfHero()

	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end	
	-- 如果是伏魔状态
	if skill4expand:isSpStatus() and (self._value[defender] or 0) > 0 then
		local buffObj = self:getBuff(self._buffId)
		buffObj.value = - self._value[defender]

		self:skillLog("剑圣处于伏魔状态，附加buff:%s，值:%s",buffObj.hid,buffObj.value)
		defender:checkCreateBuffByObj(buffObj, selfHero, skill)
	end
end

return Skill_jiansheng_2