--
-- Author: gs
-- Date: 2017-03-16 11:48:17



--[[


为我方生命最低单位恢复大量生命（通用治疗特效），并给己方单个队友增加攻击力；（文字+通用特效）





]]
local Skill_caiyi_3 = class("Skill_caiyi_3", SkillAiBasic)


function Skill_caiyi_3:ctor(skill,id,atkId  )
	self._skill = skill
	self._expandId = id
	if not atkId then
		echoError("__Skill_caiyi_3 没有配置 akdId",atkId)
		return
	end
	self.atkData = ObjectAttack.new(atkId)
end








return Skill_caiyi_3