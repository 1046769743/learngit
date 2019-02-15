--[[
	Author:lcy
	Date: 2018.03.19
]]

--[[
	酒剑仙大招

	技能描述:
	群体技能概率眩晕

	脚本处理部分:
	由于后续技能需要根据条件提高眩晕概率，所以将眩晕操作提出来

	参数:
	@@atkId 眩晕攻击包
	@@ratio 眩晕概率
]]

local Skill_jiujianxian_3 = class("Skill_jiujianxian_3", SkillAiBasic)

function Skill_jiujianxian_3:ctor(skill,id, atkId, ratio)
	Skill_jiujianxian_3.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")
	self:errorLog(ratio, "ratio")

	self._atkData = ObjectAttack.new(atkId)
	self._ratio = tonumber(ratio or 0)
end

-- 判断眩晕
function Skill_jiujianxian_3:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 判断概率
	if self._ratio > BattleRandomControl.getOneRandomInt(10001, 1) then
		self:skillLog("酒剑仙眩晕阵营:%s,%s号位",defender.camp,defender.data.posIndex)

		attacker:sureAttackObj(defender, self._atkData, skill)
	end
end

return Skill_jiujianxian_3