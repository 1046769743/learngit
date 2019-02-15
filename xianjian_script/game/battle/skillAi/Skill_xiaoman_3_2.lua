-- 废弃
--
-- Author: gs
-- Date: 2017-03-16 11:48:17



--[[
配置 Skill_xiaoman_3_2;atkId1,atkId2,maxCnt
]]
local Skill_xiaoman_3_2 = class("Skill_xiaoman_3_2", SkillAiBasic)


--[[
	
]]
function Skill_xiaoman_3_2:ctor(skill,id,atkId1,atkId2,maxCnt)
	self._skill = skill
	self._expandId = id
	self.maxCnt = maxCnt or 1
	self.maxCnt = tonumber(self.maxCnt)
	if not atkId1 then
		echoError("__Skill_xiaoman_3_2 没有配置 akdId1",id)
		return
	end
	self.atkData1 = ObjectAttack.new(atkId1)
	if not atkId2 then
		echoError("__Skill_xiaoman_3_2 没有配置 atkId2")
	end
	self.atkData2 = ObjectAttack.new(atkId2)
end



--[[
在攻击之前判定
若目标带有中毒效果 则造成额外伤害
]]
function Skill_xiaoman_3_2:onBeforeAttack(attacker,defender,skill,atkData  )
	
	if skill.skillIndex ~= Fight.skillIndex_max then
		return
	end
	if defender.data:checkHasOneBuffType(Fight.buffType_DOT) then
		attacker:sureAttackObj(defender, self.atkData1,self._skill)	
		--为己方生命值最低的人 回复
		if self.maxCnt>0 then
			attacker:sureAttackObj(defender,self.atkData2,self._skill)
			self.maxCnt = self.maxCnt - 1
		end

	end
	

end


return Skill_xiaoman_3_2