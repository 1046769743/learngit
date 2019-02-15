--[[
	Author:李朝野
	Date: 2017.06.24
	Modify:	2017.10.12
	Modify:	2017.10.14
]]
--[[
	慕容紫英大招

	技能描述：
	如果大招杀死敌人之后，则慕容紫英本回合可以再次使用怒气仙术，并且对自己施加相应攻击包

	脚本处理部分：
	如果大招杀死敌人之后，则慕容紫英本回合可以再次使用怒气仙术，并且对自己施加相应攻击包

	参数：
	atkId 带有不记次buff的攻击包 2017.11.13 pangkangning 修改
]]

local Skill_murongziying_3 = class("Skill_murongziying_3", SkillAiBasic)

function Skill_murongziying_3:ctor(skill,id,atkId)
	Skill_murongziying_3.super.ctor(self, skill, id)

	self._atkData  = ObjectAttack.new(atkId)
	-- 标记是否杀人了
	self._flag = false
end

--[[
	标记杀人了
]]
function Skill_murongziying_3:onKillEnemy( attacker,defender )
	if not self:isSelfHero(attacker) then return end
	self._flag = true

	self:skillLog("慕容紫英大招击杀阵营:%s,%s号位，对自己施加攻击包:%s",defender.camp,defender.data.posIndex,self._atkData.hid)
	attacker:sureAttackObj(attacker,self._atkData,self._skill)

	attacker:resetAttackState("max")
	-- 重置敌人身上关于我本回合的伤害信息
	attacker:resetCurEnemyDmgInfo()
end

--[[
	杀人了
]]
function Skill_murongziying_3:onAfterSkill(selfHero,skill)
	if self._flag then
		self:skillLog("慕容紫英重置大招")
		
		-- 激励动作
		-- 重新检查一下能量状态
		selfHero:checkFullEnergyStyle()
	end

	self._flag = false

	return true
end

return Skill_murongziying_3