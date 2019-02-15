--[[
	Author: lcy
	Date: 2018.05.14
]]

--[[
	灵泉杖被动
	
	***注:怒气校验问题没解决之前，这个技能时存在隐患的

	技能描述:
	若己方的回合结束时剩余怒气为0,则下个回合额外获得1点怒气

	脚本处理部分:
	同上

	参数:
	给自己加怒气的技能即为当前技能
]]

local Skill_lingquanzhang_4 = class("Skill_lingquanzhang_4", SkillAiBasic)

function Skill_lingquanzhang_4:ctor(skill,id)
	Skill_lingquanzhang_4.super.ctor(self, skill, id)

	self._flag = false -- 标记下回合是否触发
end

-- 回合开始处理技能
function Skill_lingquanzhang_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	if not self._flag then return end
	if not selfHero.data:checkCanAttack() then return end

	self._flag = false

	self:skillLog("灵泉剑被动触发",self._flag)

	selfHero:setRoundReady(Fight.process_myRoundStart, false)
	-- 存触发技能
	selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
		-- 释放当前法宝的被动技能
		selfHero:checkTreasure(1, Fight.skillIndex_passive)
	end)
	-- 执行触发，注册回调
	selfHero.triggerSkillControler:excuteTriggerSkill(function()
		selfHero:checkResumeTreasure()

		selfHero:movetoInitPos(2)
		selfHero:setRoundReady(Fight.process_myRoundStart, true)
	end)
end

-- 回合结束判断怒气
function Skill_lingquanzhang_4:onMyRoundEnd(selfHero)
	if not self:isSelfHero(selfHero) then return end
	-- 不是活人不做判断
	if not SkillBaseFunc:isLiveHero(selfHero) then return end

	-- 判断自身怒气值
	if selfHero.controler.energyControler:getEntire(selfHero.camp) == 0 then
		self._flag = true
	end
end

return Skill_lingquanzhang_4