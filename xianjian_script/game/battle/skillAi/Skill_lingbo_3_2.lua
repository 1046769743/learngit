--[[
	Author:李朝野
	Date: 2017.08.08
]]

--[[
	凌波大招扩充2

	技能描述：
	凌波如果在当前回合内受到任何增益效果，则怒气仙术必定附带减防效果

	脚本处理部分：
	凌波如果在当前回合内受到任何增益效果，则怒气仙术必定附带减防效果

	参数：
	rate 额外伤害的攻击力比例（万分）
	atkId 带有流血buff的攻击包id
	atkId2 带有减防效果的攻击包id
]]
local Skill_lingbo_3_1 = require("game.battle.skillAi.Skill_lingbo_3_1")
local Skill_lingbo_3_2 = class("Skill_lingbo_3_2", Skill_lingbo_3_1)


function Skill_lingbo_3_2:ctor(skill,id, rate, atkId, atkId2)
	Skill_lingbo_3_2.super.ctor(self, skill, id, rate, atkId)

	self:errorLog(atkId2, "atkId2")

	self._atkData2 = ObjectAttack.new(atkId2)
end

--[[
	附加减防buff
]]
function Skill_lingbo_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	dmg = Skill_lingbo_3_2.super.onCheckAttack(self, attacker, defender, skill, atkData, dmg)

	-- 是否有增益buff
	if attacker.data:checkHasKindBuff(Fight.buffKind_hao) then
		attacker:sureAttackObj(defender, self._atkData2, self._skill)
		self:skillLog("凌波大招扩充2有增益buff，对敌方施加buff")
	end

	return dmg
end

return Skill_lingbo_3_2