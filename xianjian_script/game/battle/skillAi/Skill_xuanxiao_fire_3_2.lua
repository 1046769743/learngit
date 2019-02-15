--[[
	Author: lcy
	Date: 2018.05.15
]]

--[[
	玄霄·火 大招扩充2

	技能描述:
	在阳炎状态下，如果敌方目标气血比例在80%以上，则暴击概率提高50%。

	脚本处理部分:
	同上

	参数:
	@@hprate 灼烧的血量比例(万分)
	@@maxrate 额外伤害上限 (*atk)
	@@buffId 灼烧buffId
	@@buffs 触发效果的buffType _ 间隔 "1_2_3"
	@@exrate 额外伤害率
	@@hplimit 血线
	@@buffId2 提升暴击率的buff
]]
local Skill_xuanxiao_fire_3_1 = require("game.battle.skillAi.Skill_xuanxiao_fire_3_1")
local Skill_xuanxiao_fire_3_2 = class("Skill_xuanxiao_fire_3_2", Skill_xuanxiao_fire_3_1)

function Skill_xuanxiao_fire_3_2:ctor(skill,id, hprate, maxrate, buffId, buffs, exrate, hplimit, buffId2)
	Skill_xuanxiao_fire_3_2.super.ctor(self, skill,id, hprate, maxrate, buffId, buffs, exrate)

	self:errorLog(hplimit, "hplimit")	
	self:errorLog(buffId2, "buffId2")	

	self._hplimit = tonumber(hplimit or 0)/10000
	self._buffId2 = buffId2 or 0
end

-- 检查伤害类型前加强
function Skill_xuanxiao_fire_3_2:onBeforeDamageResult(attacker, defender, skill, atkData)
	-- 如果受击者血量高于设定值
	if defender.data:getAttrPercent(Fight.value_health) >= self._hplimit then
		self:skillLog("玄霄·火大招扩充2，受击者血量高设定值，提升自身暴击率", self._hplimit)
		attacker:checkCreateBuff(self._buffId2, attacker, self._skill)
	end
end

return Skill_xuanxiao_fire_3_2