--[[
	Author: lcy
	Date: 2018.05.31
]]

--[[
	句芒被动技能

	技能描述:
	攻击的目标有增益状态，50%概率重置攻击。（重置怒气仙术/普通仙术）

	脚本处理部分:
	如上

	参数:
	@@ratio 重置攻击的概率
	@@maxtime 单回合最大重置次数
	@@action 重置攻击时的动作
]]
local Skill_goumang_4 = class("Skill_goumang_4", SkillAiBasic)

function Skill_goumang_4:ctor(skill,id,ratio,maxtime,action)
	Skill_goumang_4.super.ctor(self,skill,id)

	self:errorLog(ratio, "ratio")
	self:errorLog(maxtime, "maxtime")
	self:errorLog(action, "action")

	-- 重置攻击概率
	self._ratio = tonumber(ratio or 0)
	self._maxtime = tonumber(maxtime or 999)
	self._action = action
	
	self._reset = false -- 标记是否已经重置过，同一次攻击中如果已经重置则不再判断
	self._count = 0
end

-- 每回合开始重置一下次数
function Skill_goumang_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	self._count = 0
end

-- 检查对方身上的增益情况
function Skill_goumang_4:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 没有重置过
	if not self._reset 
		and self._count < self._maxtime
		and defender.data:checkHasOneBuffKind(Fight.buffKind_hao) 
	then
		self._reset = self._ratio > BattleRandomControl.getOneRandomInt(10001,1)
	end
end

-- 检查重置
function Skill_goumang_4:onAfterSkill(selfHero, skill)
	-- 重置了
	if self._reset and SkillBaseFunc:isLiveHero(selfHero) then
		self._reset = false
		self._count = self._count + 1

		selfHero:resetAttackState("all")
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			self:skillLog("句芒重置攻击")
			selfHero:justFrame(self._action)
			selfHero:insterEffWord({1, Fight.wenzi_chongzhigongji, Fight.buffKind_hao})

		end, selfHero:getTotalFrames(self._action))
	end

	return true
end

return Skill_goumang_4