--
-- Author: gs
-- Date: 2017-03-16 11:48:17
-- 温慧

--[[
Skill配置：
atdId:敌方有阵亡的情况下，提升自身免伤率的buff
Skill_wenhui_3;atkId;

]]
local Skill_wenhui_3 = class("Skill_wenhui_3", SkillAiBasic)

--[[

]]
function Skill_wenhui_3:ctor(skill, id,atkId)
	self._skill = skill
	self._expandId = id
	
	self.atkId = atkId 
	if not atkId then
		echoError("Skill_wenhui_3没有配置atkId")
	end
	self.atkData = ObjectAttack.new(atkId)

end



--[[
温慧攻击完成后
检测是否己方有阵亡。如果有阵亡则增加自身免伤


attacker:sureAttackObj:(target,atkData,skill)


]]
function Skill_wenhui_3:onAfterAttack(attacker,defender,skill,atkData  )
	--最后一次的攻击
	if not skill.isFinal then
		return
	end

	--大招
	if skill.skillIndex ~= Fight.skillIndex_max then
		return
	end

	--检测温慧阵容是否有阵亡
	--如果阵亡了。则需要释放一个攻击包
	local diedCnt = #attacker.controler.levelInfo.campData1 - #attacker.controler.campArr_1
	if diedCnt>0 then
		attacker:sureAttackObj(attacker,self.atkData,self._skill)
	end

end

return Skill_wenhui_3