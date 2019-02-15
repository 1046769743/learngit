-- 废弃2018.03.15
--
-- Author: gs
-- Date: 2017-03-16 11:48:17
--[[
	攻击敌方全体，附带中毒效果；若目标带有中毒效果，则造成额外伤害

]]
--配置 Skill_xiaoman_3;atkId(降低怒气效果);
local Skill_xiaoman_3 = class("Skill_xiaoman_3", SkillAiBasic)



function Skill_xiaoman_3:ctor(skill,id,atkId  )
	self._skill = skill
	self._expandId = id
	if not atkId then
		echoError("__Skill_xiaoman_3 没有配置 akdId",id)
		return
	end
	self.atkData = ObjectAttack.new(atkId)
end



--[[
在攻击目标之前
如果目标带有中毒效果，则造成额外的伤害
]]
function Skill_xiaoman_3:onBeforeAttack(attacker,defender,skill,atkData  )
	-- if not self._isActiveBuff then
	-- 	return
	-- end
	--必须血量大于0
	if defender.data:hp() <= 0 then
		return
	end
	
	--buff 中毒 效果
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		--那么直接攻击对方
		attacker:sureAttackObj(defender, self.atkData,self._skill)		
	end



end


return Skill_xiaoman_3