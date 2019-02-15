--[[
	Author: lcy
	Date: 2018.05.14
]]

--[[
	玄霄·火 小技能

	技能描述:
	阳炎状态下，消耗一枚凤凰羽并且每次攻击灼烧自身当前生命20%，附加此额外伤害。（没有则不加）

	脚本处理部分:
	如上

	参数:
	@@hprate 灼烧的血量比例(万分)
	@@maxrate 额外伤害上限 (*atk)
]]

local Skill_xuanxiao_fire_2 = class("Skill_xuanxiao_fire_2", SkillAiBasic)

function Skill_xuanxiao_fire_2:ctor(skill, id, hprate, maxrate)
	Skill_xuanxiao_fire_2.super.ctor(self,skill,id)

	self:errorLog(hprate, "hprate")
	self:errorLog(maxrate, "maxrate")

	self._hprate = tonumber(hprate or 0)
	self._maxrate = tonumber(maxrate or 0)
end

-- 检查伤害
function Skill_xuanxiao_fire_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 死人不检查
	if not SkillBaseFunc:isLiveHero(defender) then return end

	local selfHero = self:getSelfHero()
	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end

	-- 如果有羽毛
	if not skill4expand:isRuneEmpty() then
		-- 消耗一个符文
		skill4expand:useRune(1)
		-- 计算伤害量
		local exDmg = clampf(math.round(selfHero.data:hp() * self._hprate / 10000),0,math.round(selfHero.data:atk() * self._maxrate / 10000))
		-- 自己扣血
		selfHero.data:changeValue(Fight.value_health, -exDmg, Fight.valueChangeType_num)
		-- 加在伤害中
		dmg = dmg + exDmg
		self:skillLog("玄霄火小技能阳炎状态附加伤害",exDmg)
	end

	return dmg
end

return Skill_xuanxiao_fire_2