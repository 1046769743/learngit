--[[
	Author: lcy
	Date: 2018.08.10
]]

--[[
	蜂灵技能扩充1

	技能描述：
	点击后释放，对敌方全体造成伤害，如果造成击杀，则进行追击

	参数:
	@@maxCount 最大触发次数
	@@atk 赋给神器的攻击力
	
	@@maxNum 最大追击次数
]]
local Skill_artifact_fengling = require("game.battle.skillAi.Skill_artifact_fengling")
local Skill_artifact_fengling_1 = class("Skill_artifact_fengling_1", Skill_artifact_fengling)

function Skill_artifact_fengling_1:ctor(skill,id, maxCount, atk, maxNum)
	Skill_artifact_fengling_1.super.ctor(self, skill, id, maxCount, atk)

	self:errorLog(maxNum, "maxNum")

	self._maxNum = tonumber(maxNum or 1)

	-- 记录是否触发
	self._flag = false

	self._chaseTimes = 0 -- 追击次数
end

-- 攻击前处理攻击力
function Skill_artifact_fengling_1:onBeforeCheckSkill(selfHero, skill)
	-- 改变神器的攻击力（攻击力随追击次数衰减）
	selfHero.data:setAttribute(Fight.value_atk, math.round(self._atk/math.pow(2,self._chaseTimes)))
	selfHero.data:setHeroElement(Fight.element_non)

	return skill
end

--[[
	杀敌检测
]]
function Skill_artifact_fengling_1:onKillEnemy(attacker, defender)
	if not self:isSelfHero(attacker) then return end
	self._flag = true
end

--[[
	技能结束之后检查追击
]]
function Skill_artifact_fengling_1:onAfterSkill(selfHero, skill)
	-- 造成击杀进行追击
	local flag = self._flag
	-- 先将标记重置回
	self._flag = false
	-- 造成击杀进行追击
	if flag and self._chaseTimes < self._maxNum and SkillBaseFunc:chkLiveHero(selfHero.toArr) then
		self._chaseTimes = self._chaseTimes + 1
		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 重置攻击数值
			selfHero:resetCurEnemyDmgInfo()
			-- 放技能
			selfHero:checkSkill(skill, false, skill.skillIndex)
		end)
	else
		-- 否则追击次数清零
		self._chaseTimes = 0
	end

	return true
end

return Skill_artifact_fengling_1