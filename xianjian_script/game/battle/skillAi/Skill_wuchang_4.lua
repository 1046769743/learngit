--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	黑/白无常合体技能

	技能描述:
	对低血量目标，秒杀

	脚本处理部分:
	同上

	参数:
	hpper 秒杀血限
	atkId 秒杀攻击包(带有掉100%血量buff)
]]

local Skill_wuchang_4 = class("Skill_wuchang_4", SkillAiBasic)

function Skill_wuchang_4:ctor(skill,id,hpper,atkId)
	Skill_wuchang_4.super.ctor(self,skill,id)

	self:errorLog(hpper, "hpper")
	self:errorLog(atkId, "atkId")

	self._hpper = tonumber(hpper or 0)
	self._atkData = ObjectAttack.new(atkId)

	self._light = nil
end
-- 判定秒杀
function Skill_wuchang_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 是被动技，并且满足血量要求
	if self._skill == skill and defender.data:getAttrPercent(Fight.value_health) <= self._hpper / 10000 then
		self:skillLog("无常合体技满足血量要求,触发秒杀")
		attacker:sureAttackObj(defender, self._atkData, self._skill)
	end
end

-- 传递参数
function Skill_wuchang_4:setParams(light)
	self._light = light
end

function Skill_wuchang_4:onBeforeSkill( ... )
	if not Fight.isDummy and self._light then
		local selfHero = self:getSelfHero()
		local controler = selfHero.controler
		if controler and controler.viewPerform then
			for _,hero in pairs(self._light) do
				-- 层级也处理一下
				hero:onSkillBlack()
			end
			
			controler.viewPerform:setHeroLightOrDark(self._light)
		end
		self._light = nil
	end
end

return Skill_wuchang_4