--[[
	Author: lcy
	Date: 2018.05.21
]]

--[[
	魔化罗如烈

	技能描述:
	回合开始前，释放技能，增加自身攻击力，释放技能后，使用特殊待机。

	脚本处理部分:
	同上

	参数:
	被动技能本身即为回合前释放的技能
]]

local Skill_luorulie_4 = class("Skill_luorulie_4", SkillAiBasic)

function Skill_luorulie_4:ctor(skill,id)
	Skill_luorulie_4.super.ctor(self,skill,id)
end

-- 回合开始前做技能
function Skill_luorulie_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 不能攻击则返回
	if not selfHero.data:checkCanAttack() then return end

	selfHero:setRoundReady(Fight.process_myRoundStart, false)
	selfHero.currentSkill = self._skill

	selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		selfHero:checkSkill(self._skill, false, self._skill.skillIndex)	
	end)

	selfHero.triggerSkillControler:excuteTriggerSkill(function()
		-- 切换特殊待机
		selfHero:setUseSpStand(true)
		selfHero:movetoInitPos(2)
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	end)
end

return Skill_luorulie_4