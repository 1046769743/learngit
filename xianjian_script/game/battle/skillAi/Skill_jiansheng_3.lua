--[[
	Author:庞康宁
	Date: 2017.12.18
	Modify: 2018.03.21 lcy
]]
--[[
	剑圣大招

	技能描述：
	攻击群体，减少50%伤害量的治疗上限，如果伏魔状态，造成50%攻击力的额外伤害。

	脚本处理部分：
	根据伤害量减少对应治疗上限，如果特殊状态将伤害加强

	参数：
	@@buffId 减少治疗上限的buff（作用类型为值，具体值由脚本赋值）
	@@rate 减少的治疗上限占伤害量的比率
	@@rateEx 额外伤害的系数
]]
local Skill_jiansheng_3 = class("Skill_jiansheng_3", SkillAiBasic)

function Skill_jiansheng_3:ctor(skill,id, buffId, rate, rateEx)
	Skill_jiansheng_3.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")
	self:errorLog(rate, "rate")
	self:errorLog(rateEx, "rateEx")

	self._buffId = buffId or 0
	self._rate = tonumber(rate or 0)
	self._rateEx = tonumber(rateEx or 0)

	self._value = {} -- 记录伤害值
end

-- 获取两个参数
function Skill_jiansheng_3:_get2Params(defender)
	local rate,exRate = self._rate,0

	local selfHero = self:getSelfHero()
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if skill4expand and skill4expand:isSpStatus() then
		exRate = self._rateEx
		self:skillLog("剑圣伏魔状态下,附加额外伤害比例",exRate)
	end

	return rate,exRate
end

-- 记录伤害值
function Skill_jiansheng_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local rate,exRate = self:_get2Params(defender)

	if exRate > 0 then
		local exDmg = math.round(attacker.data:atk() * exRate / 10000)
		dmg = dmg + exDmg
	end

	self._value[defender] = math.round(rate * dmg / 10000)

	return dmg
end

-- 最后一个攻击包附加buff
function Skill_jiansheng_3:onAfterAttack(attacker, defender, skill, atkData)
	if (self._value[defender] or 0) > 0 then
		local buffObj = self:getBuff(self._buffId)
		buffObj.value = -self._value[defender]

		self:skillLog("剑圣大招附加buff:%s，值:%s",buffObj.hid,buffObj.value)
		defender:checkCreateBuffByObj(buffObj, attacker, skill)
	end
end

return Skill_jiansheng_3