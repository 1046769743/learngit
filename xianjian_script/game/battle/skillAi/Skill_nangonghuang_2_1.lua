--[[
	Author: lcy
	Date: 2018.03.28
]]

--[[
	南宫煌小技能扩充1

	技能描述：
	如果南宫煌带有五灵轮状态，则攻击时附带降低敌方攻击力效果

	脚本处理部分：
	根据自身状态判断是否施加减攻buff

	参数:
	@@atkId 减攻攻击包Id
]]
local Skill_nangonghuang_2_1 = class("Skill_nangonghuang_2_1", SkillAiBasic)

function Skill_nangonghuang_2_1:ctor(skill,id, atkId)
	Skill_nangonghuang_2_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end
-- 攻击后判断减攻击力
function Skill_nangonghuang_2_1:onAfterAttack(attacker, defender, skill, atkData)
	-- 讨巧一下使用特殊动作标记是否处于特殊状态
	if attacker:isUseSpStand() then
		self:skillLog("南宫煌处于五灵轮状态，做攻击包")
		attacker:sureAttackObj(defender, self._atkData, skill)
	end
end

return Skill_nangonghuang_2_1