--[[
	Author: lcy
	Date: 2018.03.28
]]

--[[
	主角小技能扩充1

	技能描述：
	小技能，每有一个手机目标携带增益状态，则提升自身一定攻击力

	脚本处理部分：
	当前技能攻击满足条件的角色时，增加伤害

	参数：
	@@atkId 带有加攻buff的攻击包
]]

local Skill_zhujue_2_1 = class("Skill_zhujue_2_1", SkillAiBasic)

function Skill_zhujue_2_1:ctor(skill,id,atkId)
	Skill_zhujue_2_1.super.ctor(self,skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 攻击目标时
function Skill_zhujue_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 带有增益buff
	if defender.data:checkHasOneBuffKind(Fight.buffKind_hao) then
		self:skillLog("阵营:%s,%s号位带有增益buff,主角对自己施加攻击包",defender.camp,defender.data.posIndex)
		attacker:sureAttackObj(attacker, self._atkData, skill)
	end
end

return Skill_zhujue_2_1