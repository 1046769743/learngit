--[[
	Author: lcy
	Date: 2018.05.11
]]

--[[
	天师道袍大招

	技能描述:
	调取太极效果，攻击敌方单体，使用道符为自身添加一个吸收伤害护盾

	脚本处理部分:
	由于后续需要动态改变护盾值，所以护盾buff手动添加

	参数:
	buffId 护盾buffId
]]

local Skill_tianshidaopao_3 = class("Skill_tianshidaopao_3", SkillAiBasic)

function Skill_tianshidaopao_3:ctor(skill,id, buffId)
	Skill_tianshidaopao_3.super.ctor(self, skill, id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
end

function Skill_tianshidaopao_3:onAfterSkill(selfHero, skill)
	local selfHero = self:getSelfHero()

	local buffObj = ObjectBuff.new(self._buffId,self._skill)

	-- 加护盾
	selfHero:checkCreateBuffByObj(buffObj, selfHero, self._skill)

	return true
end

return Skill_tianshidaopao_3