--[[
	Author:李朝野
	Date: 2017.08.30
]]

--[[
	姜云凡大招

	技能描述:
	驱散目标增益，恢复自身15%最大气血

	脚本处理部分：
	当驱散了目标增益时，为自己恢复生命

	参数：
	skillId 给自己和同排加攻击力的技能
	ratio 满足血量（万分）
	atkId 额外恢复生命的攻击包
]]
local Skill_jiangyunfan_3_1 = require("game.battle.skillAi.Skill_jiangyunfan_3_1")

local Skill_jiangyunfan_3_2 = class("Skill_jiangyunfan_3_2", Skill_jiangyunfan_3_1)

function Skill_jiangyunfan_3_2:ctor(skill,id,skillId,ratio,atkId)
	Skill_jiangyunfan_3_2.super.ctor(self, skill,id,skillId,ratio)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)

	self._flag = false
end

-- 攻击前根据敌方可清理的增益buff数量做标记
function Skill_jiangyunfan_3_2:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local num = defender.data:getBuffNumsByKind(buffKind, true)
	self._flag = num > 0
end

-- 技能结束后额外恢复生命
function Skill_jiangyunfan_3_2:onAfterSkill(selfHero, skill)
	if self._flag then
		self._flag = false
		selfHero:sureAttackObj(selfHero, self._atkData, self._skill)
	end

	return true
end

return Skill_jiangyunfan_3_2