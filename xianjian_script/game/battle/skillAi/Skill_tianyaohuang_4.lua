--[[
	Author: lcy
	Date: 2018.08.04
]]
--[[
	天妖皇被动

	技能描述：
	初始，给自己添加四层妖能buff（靠协助技套），每个回合结束，增加一层，最大不超过四层；
	回合结束给自己增加buff并播放动作，特效；

	参数:
	本脚本所在技能为回合结束时技能
	
	num 妖能层数上限
]]
local Skill_tianyaohuang_4 = class("Skill_tianyaohuang_4", SkillAiBasic)

function Skill_tianyaohuang_4:ctor(skill,id,num)
	Skill_tianyaohuang_4.super.ctor(self, skill, id)

	self:errorLog(num, "num")

	self._num = tonumber(num or 4)
end

-- 回合后给自己恢复一点妖能
function Skill_tianyaohuang_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end

	-- 统计妖能层数
	local num = selfHero.data:getBuffNumsByType(Fight.buffType_tag_yaoneng)
	if num >= self._num then return end

	selfHero:setRoundEndReady(Fight.process_end_myRoundEnd, false)
	selfHero.currentSkill = self._skill

	selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
		-- 重置敌人身上关于我本回合的伤害信息
		selfHero:resetCurEnemyDmgInfo()

		selfHero:checkSkill(self._skill, false, self._skill.skillIndex)	
	end)
	-- 触发技能
	selfHero.triggerSkillControler:excuteTriggerSkill(function()
		selfHero:movetoInitPos(2)
		selfHero:setRoundEndReady(Fight.process_end_myRoundEnd, true)
	end)
end

return Skill_tianyaohuang_4