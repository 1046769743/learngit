--[[
	Author: lcy
	Date: 2018.03.28
]]

--[[
	李逍遥小技能扩充1

	技能描述：
	如果发生暴击则增加自身一定格挡率

	脚本处理部分：
	检查如果暴击增加格挡率

	参数：
	@@atkId 增加格挡率的攻击包
]]

local Skill_lixiaoyao_2_1 = class("Skill_lixiaoyao_2_1", SkillAiBasic )

function Skill_lixiaoyao_2_1:ctor(skill,id, atkId)
	Skill_lixiaoyao_2_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

function Skill_lixiaoyao_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	-- 如果本次暴击了
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		self:skillLog("李逍遥暴击，作用攻击包")
		attacker:sureAttackObj(attacker, self._atkData, skill)
	end
end

return Skill_lixiaoyao_2_1