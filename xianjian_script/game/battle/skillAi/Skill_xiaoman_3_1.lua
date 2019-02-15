--[[
	Author:李朝野
	Date: 2018.03.15
]]

--[[
	小蛮大招扩充1

	技能描述:
	攻击敌方全体，附带中毒效果；若目标带有中毒效果，则造成额外伤害

	脚本处理部分:
	攻击敌方全体，附带中毒效果；若目标带有中毒效果，则造成额外伤害

	参数:
	@@atkId 额外伤害的攻击包
]]
local Skill_xiaoman_3_1 = class("Skill_xiaoman_3_1", SkillAiBasic)

function Skill_xiaoman_3_1:ctor(skill,id,atkId)
	Skill_xiaoman_3_1.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

function Skill_xiaoman_3_1:onBeforeAttack(attacker, defender, skill, atkData)
	--必须血量大于0
	if defender.data:hp() <= 0 then
		return
	end

	--buff 中毒 效果
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		--那么给额外伤害
		attacker:sureAttackObj(defender, self._atkData,self._skill)		
	end
end

return Skill_xiaoman_3_1