--[[
	Author:李朝野
	Date: 2017.12.22
]]

--[[
	通用反伤被动脚本

	描述：
	当受击最后一下时，对攻击者施加一个攻击包

	参数:
	atkId 对受击者施加的攻击包
]]
local Skill_common_fanji_4 = class("Skill_common_fanji_4", SkillAiBasic)

function Skill_common_fanji_4:ctor(skill,id, atkId)
	Skill_common_fanji_4.super.ctor(self, skill, id)

	self:errorLog(atkId, "atkId")

	self._atkData = ObjectAttack.new(atkId)
end

-- 做伤害的限制
function Skill_common_fanji_4:onCheckAttack(attacker,defender,skill,atkData, dmg)
	-- 对反击的伤害做出限制
	if dmg >= defender.data:hp() then
		dmg = defender.data:hp() - 1
	end

	return dmg
end

-- 做反伤的事
function Skill_common_fanji_4:onBeforeHited(selfHero,attacker,skill,atkData)
	if selfHero.data:hp()<0 or attacker.data:hp()<= 1 then
		--自己血量和敌人血量大于0才有效
		return
	end

	self:skillLog("通用反击脚本触发,所在技能:%s,对攻击者做攻击包:%s",self._skill.hid,self._atkData.hid)
	-- 重置敌人身上关于我本回合的伤害信息
	selfHero:resetCurEnemyDmgInfo()
	-- 做反击的攻击包
	selfHero:sureAttackObj(attacker,self._atkData,self._skill)
end

return Skill_common_fanji_4