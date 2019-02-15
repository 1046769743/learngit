--[[
	Author:lcy
	Date: 2018.03.19
]]

--[[
	酒剑仙大招扩充1

	技能描述:
	释放怒气仙术后，有30%概率释放斩妖咒（被动技能）（释放完怒气技能后，立刻释放）

	脚本处理部分:
	释放此技能后，根据概率加一个斩妖咒的技能

	参数:
	@@atkId 眩晕攻击包
	@@ratio 眩晕概率
	@@ratio1 额外释放斩妖咒的概率
]]
local Skill_jiujianxian_3 = require("game.battle.skillAi.Skill_jiujianxian_3")
local Skill_jiujianxian_3_1 = class("Skill_jiujianxian_3_1", Skill_jiujianxian_3)

function Skill_jiujianxian_3_1:ctor(skill,id, atkId, ratio, ratio1)
	Skill_jiujianxian_3_1.super.ctor(self,skill,id, atkId, ratio)

	self:errorLog(ratio1, "ratio1")

	self._ratio1 = tonumber(ratio1 or 0)
end
-- 回合结束后判断额外斩妖咒
function Skill_jiujianxian_3_1:onAfterSkill(selfHero, skill)
	-- 被动技能
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil
	-- 没有被动不做事情
	if not skill4expand then return end

	-- 判断概率释放技能
	if self._ratio1 > BattleRandomControl.getOneRandomInt(10001, 1) then
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		-- 放技能
		specialSkill.isStitched = true

		skill4expand:useExSkill()

		selfHero:checkSkill(specialSkill, false, specialSkill.skillIndex)

		return false
	end

	return true
end

return Skill_jiujianxian_3_1