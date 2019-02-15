--[[
	Author:李朝野
	Date: 2018.03.03
]]

--[[
	韩菱纱普攻

	技能描述：
	如果自身处于虚弱状态，则30%概率触发再次攻击；

	脚本处理部分：
	若干概率触发再次攻击

	参数：
	ratio 连击概率
	maxtime 最大连击数
]]
local Skill_hanlingsha_2 = class("Skill_hanlingsha_2", SkillAiBasic)

function Skill_hanlingsha_2:ctor(skill,id, ratio, maxtime)
	Skill_hanlingsha_2.super.ctor(self, skill, id)

	self:errorLog(ratio, "ratio")
	self:errorLog(maxtime, "maxtime")

	self._ratio = tonumber(ratio or 0)
	self._maxtime = tonumber(maxtime or 1)
	self._count = 0 -- 当前连击次数
end

-- 技能结束后判断连击
function Skill_hanlingsha_2:onAfterSkill(selfHero,skill)
	if skill ~= self._skill then return true end

	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if not skill4expand then return true end

	-- 满足状态并且对方还有人
	if self._count < self._maxtime and skill4expand:isSpWeak() and SkillBaseFunc:chkLiveHero( selfHero.toArr ) then
		-- 判断概率
		if self._ratio >= BattleRandomControl.getOneRandomInt(10001,1) then
			self:skillLog("韩菱纱进行连击")
			self._count = self._count + 1
			selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
				-- 重置敌人身上关于我本回合的伤害信息
				selfHero:resetCurEnemyDmgInfo()
				
				selfHero:checkSkill(skill, false, skill.skillIndex)
			end)
		else
			self._count = 0
		end
	else
		self._count = 0
	end

	return true
end

return Skill_hanlingsha_2