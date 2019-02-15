--[[
	Author:lcy
	Date: 2018.03.19
]]

--[[
	酒剑仙大招扩充2

	技能描述:
	如果自身处于斩妖咒状态，怒气仙术眩晕概率提高到20%

	脚本处理部分:
	根据状态提升概率

	参数:
	@@atkId 眩晕攻击包
	@@ratio 眩晕概率
	@@ratio1 额外释放斩妖咒的概率
	@@exRatio 斩妖咒状态下提升的额外概率
]]

local Skill_jiujianxian_3_1 = require("game.battle.skillAi.Skill_jiujianxian_3_1")
local Skill_jiujianxian_3_2 = class("Skill_jiujianxian_3_2", Skill_jiujianxian_3_1)

function Skill_jiujianxian_3_2:ctor(skill,id, atkId, ratio, ratio1, exRatio)
	Skill_jiujianxian_3_2.super.ctor(self, skill,id, atkId, ratio, ratio1)

	self:errorLog(exRatio, "exRatio")

	self._exRatio = tonumber(exRatio or 0)
end

-- 判断眩晕
function Skill_jiujianxian_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 被动技能
	local specialSkill = attacker.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	local ratio = self._ratio
	-- 如果是特殊状态
	if skill4expand:isSpStatus() then
		ratio = ratio + self._exRatio
	end

	-- 判断概率
	if ratio > BattleRandomControl.getOneRandomInt(10001, 1) then
		self:skillLog("酒剑仙眩晕阵营:%s,%s号位",defender.camp,defender.data.posIndex)

		attacker:sureAttackObj(defender, self._atkData, skill)
	end
end

return Skill_jiujianxian_3_2