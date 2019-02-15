--[[
	Author:lcy
	Date: 2018.03.19
]]

--[[
	南宫煌大招

	技能描述:
	对单体造成伤害，并获得五灵轮形态

	脚本处理部分:
	在技能结束后通过被动获得五灵轮形态

	参数:
	@@buffId 五灵轮治疗护盾buff（被动技能中添加的buff也来源于此）
]]

local Skill_nangonghuang_3 = class("Skill_nangonghuang_3", SkillAiBasic)

function Skill_nangonghuang_3:ctor(skill,id, buffId)
	Skill_nangonghuang_3.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
end

function Skill_nangonghuang_3:onAfterAttack(attacker, defender, skill, atkData)
	local selfHero = self:getSelfHero()

	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return end

	-- 获取五灵轮
	skill4expand:_getTreatShield()
end

-- 获取五灵轮的buffId
function Skill_nangonghuang_3:_getExBuffId()
	return self._buffId
end

return Skill_nangonghuang_3