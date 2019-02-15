--[[
	Author:李朝野
	Date: 2018.01.13
]]

--[[
	回合前给自己加buff，只加一次

	参数:
	@@atkId 带buff的攻击包
]]

local Skill_common_roundbuff = class("Skill_common_roundbuff", SkillAiBasic)

function Skill_common_roundbuff:ctor(skill,id, atkId)
	Skill_common_roundbuff.super.ctor(self, skill,id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)

	self._first = true -- 标记只加一次
end

--我方回合开始前
function Skill_common_roundbuff:onMyRoundStart(selfHero )
	if not self:isSelfHero(selfHero) or not self._first then return end

	self._first = false

	selfHero:sureAttackObj(selfHero,self._atkData,self._skill)
end

-- 敌方回合开始前
function Skill_common_roundbuff:onEnemyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) or not self._first then return end

	self._first = false

	selfHero:sureAttackObj(selfHero,self._atkData,self._skill)
end


return Skill_common_roundbuff