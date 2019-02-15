--[[
	Author: lcy
	Date: 2018.05.14
]]

--[[
	玄霄·火 大招

	技能描述:
	阳炎状态下，攻击敌方单体，消耗一枚凤凰羽，并消耗当前生命20%，附加此额外伤害，且附加灼烧效果

	脚本处理部分:
	如上

	参数:
	@@hprate 灼烧的血量比例(万分)
	@@maxrate 额外伤害上限 (*atk)
	@@buffId 灼烧buffId
]]

local Skill_xuanxiao_fire_3 = class("Skill_xuanxiao_fire_3", SkillAiBasic)

function Skill_xuanxiao_fire_3:ctor(skill,id, hprate, maxrate, buffId)
	Skill_xuanxiao_fire_3.super.ctor(self, skill,id)

	self:errorLog(hprate, "hprate")
	self:errorLog(maxrate, "maxrate")
	self:errorLog(buffId, "buffId")

	self._hprate = tonumber(hprate or 0)
	self._maxrate = tonumber(maxrate or 0)
	self._buffId = buffId or 0
end

-- 检查伤害
function Skill_xuanxiao_fire_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
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
		-- 附加灼烧
		defender:checkCreateBuff(self._buffId, selfHero, self._skill)
		
		self:skillLog("玄霄火大招附加伤害和灼烧",exDmg,self._buffId)
	end

	return dmg
end

return Skill_xuanxiao_fire_3