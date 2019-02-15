--
-- Author: gs
-- Date: 2017-03-16 11:48:17
-- 温慧
--温慧

--[[


温慧在防守待机状态下，被攻击前，
做施法动作（时间越短越好）
（该角色近战，动作刚猛些）会降低当前攻击者的攻击力，
（独立BUFF特效，做出明显的特出效果，不需要有循环BUFF）


Skill参数配置：
atkId:温慧在北攻击前 做释放动作(这个)，降低攻击者的攻击力
Skill_wenhui_4;atkId;


]]
local Skill_wenhui_4 = class("Skill_wenhui_4", SkillAiBasic)

--[[

]]
function Skill_wenhui_4:ctor(skill, id,atkId)
	self._skill = skill
	self._expandId = id
	
	self.atkId = atkId 
	if not atkId then
		echoError("Skill_wenhui_4 没有配置atkId")
	end
	self.atkData = ObjectAttack.new(atkId)
end




--[[
温慧被攻击前
做释放动作   降低当前攻击者的攻击力
]]
function Skill_wenhui_4:onBeforeHited(selfHero,attacker,skill,atkData,dmg )


	--执行施法动作就可以了   美术资源   可能需要修改配置和Skill_wenhui_4的攻击传入参数
	--然后释放攻击包=就可以了。



	selfHero:sureAttackObj(selfHero,self.atkData,self._skill)

end


return Skill_wenhui_4