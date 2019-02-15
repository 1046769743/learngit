--[[
	Author:李朝野
	Date: 2017.08.03
]]

--[[
	红葵被动
	
	技能描述：
	若行动造成击杀，恢复自身行动，可以再次进行攻击；

	脚本处理部分：
	若行动造成击杀，恢复自身行动，可以再次进行攻击；

	参数：
	action 重置攻击时的攻击动作
]]
local Skill_hongkui_4 = class("Skill_hongkui_4", SkillAiBasic)

function Skill_hongkui_4:ctor(skill, id, action)
	Skill_hongkui_4.super.ctor(self, skill, id)

	self._action = action
	-- 记录是否造成击杀
	self._flag = false
end

function Skill_hongkui_4:onKillEnemy( attacker,defender )
	if not self:isSelfHero(attacker) then return end
	self._flag = true
end

function Skill_hongkui_4:onAfterSkill(selfHero,skill)
	local result = true
	-- 造成击杀重置攻击
	if self._flag then
		if not Fight.isDummy then
			self:skillLog("红葵重置攻击")
			-- 激励动作
			selfHero:justFrame(self._action)
			selfHero:insterEffWord({1, Fight.wenzi_chongzhigongji, Fight.buffKind_hao})

			local totalFrames = selfHero:getTotalFrames(self._action)
			selfHero:pushOneCallFunc(tonumber(totalFrames), "onSkillActionComplete",{})
			
			result = false
		end

		selfHero:resetAttackState("all")
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()
	end

	self._flag = false

	return result
end

return Skill_hongkui_4