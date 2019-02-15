--
-- Author: gs
-- Date: 2017-03-16 11:48:17

--[[

攻击增加X点


配置文件中的配置参数
Skill_anu_4,atkId


]]
local Skill_linqinger_4 = class("Skill_linqinger_4", SkillAiBasic)





--[[

]]
function Skill_linqinger_4:ctor(skill,id,atkId)
	self._skill = skill
	self._expandId = id
	self.atkId  = atkId
	if not atkId then
		echoError("Skill_jiangcheng_4 没有配置 atkId")
	end
	self.atkData = ObjectAttack.new(atkId)
end

--[[
返回一个dmg
这个是一个无特效的buff
因此在checkAttack的时候执行。直接增加伤害就可以了
]]
function Skill_linqinger_4:onCheckAttack(attacker,defender,skill,atkData, dmg  )
	return dmg
end





return Skill_linqinger_4