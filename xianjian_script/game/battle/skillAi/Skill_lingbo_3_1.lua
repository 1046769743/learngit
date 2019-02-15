--[[
	Author:李朝野
	Date: 2017.08.08
]]

--[[
	凌波大招扩充1

	技能描述：
	怒气技能攻击重复目标时，对目标造成流血状态；

	脚本处理部分：
	怒气技能攻击重复目标时，对目标造成流血状态；

	参数：
	rate 额外伤害的攻击力比例（万分）
	atkId 带有流血buff的攻击包id
]]
local Skill_lingbo_3 = require("game.battle.skillAi.Skill_lingbo_3")
local Skill_lingbo_3_1 = class("Skill_lingbo_3_1", Skill_lingbo_3)


function Skill_lingbo_3_1:ctor(skill,id, rate, atkId)
	Skill_lingbo_3_1.super.ctor(self, skill, id, rate)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

--[[
	附加流血buff
]]
function Skill_lingbo_3_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local posIndex = defender.data.posIndex
	-- 攻击过
	if self._record[posIndex] then
		self:skillLog("凌波重复攻击阵营%s，%s号位，附加buff", defender.camp, posIndex)
		-- 附加流血buff
		attacker:sureAttackObj(defender, self._atkData, self._skill)
	end
	-- 后走父类方法，不然会被错误标记为攻击过
	dmg = Skill_lingbo_3_1.super.onCheckAttack(self, attacker, defender, skill, atkData, dmg)

	return dmg
end

return Skill_lingbo_3_1