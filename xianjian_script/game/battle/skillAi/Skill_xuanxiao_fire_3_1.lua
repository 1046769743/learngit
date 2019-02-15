--[[
	Author: lcy
	Date: 2018.05.15
]]

--[[
	玄霄·火 大招扩充1

	技能描述:
	阳炎状态下如果目标带有xx/xx/xx效果，则吞噬这些效果，造成自身攻击力20%额外伤害

	脚本处理部分:
	同上

	参数:
	@@hprate 灼烧的血量比例(万分)
	@@maxrate 额外伤害上限 (*atk)
	@@buffId 灼烧buffId
	@@buffs 触发效果的buffType _ 间隔 "1_2_3"
	@@exrate 额外伤害率
]]
local Skill_xuanxiao_fire_3 = require("game.battle.skillAi.Skill_xuanxiao_fire_3")
local Skill_xuanxiao_fire_3_1 = class("Skill_xuanxiao_fire_3_1", Skill_xuanxiao_fire_3)

function Skill_xuanxiao_fire_3_1:ctor(skill,id, hprate, maxrate, buffId, buffs, exrate)
	Skill_xuanxiao_fire_3_1.super.ctor(self,skill,id, hprate, maxrate, buffId)

	self:errorLog(buffs, "buffs")
	self:errorLog(exrate, "exrate")

	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function(v,k)
		return tonumber(v)
	end)

	self._exrate = tonumber(exrate or 0)
end

function Skill_xuanxiao_fire_3_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	dmg = Skill_xuanxiao_fire_3_1.super.onCheckAttack(self, attacker, defender, skill, atkData, dmg) or dmg

	local flag = false

	for _,bt in ipairs(self._buffs) do
		if defender.data:checkHasOneBuffType(bt) then
			flag  = true
			-- 清除对应buff
			defender.data:clearBuffByType(bt)
		end
	end

	if flag then
		local exDmg = math.round(attacker.data:atk() * self._exrate / 10000)
		dmg = dmg + exDmg
		self:skillLog("玄霄·火大招扩充1攻击对应状态的人，附加伤害",exDmg)
	end

	return dmg
end

return Skill_xuanxiao_fire_3_1