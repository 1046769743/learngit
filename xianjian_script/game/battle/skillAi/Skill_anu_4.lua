--[[
	Author:李朝野
	Date: 2017.7.31
	Modify: 2018.03.10
]]

--[[
	阿奴被动技能
	
	技能描述：
	敌方单位在释放怒气仙术后，有一定几率被沉默，持续两回合;

	脚本处理部分：
	敌方单位在释放怒气仙术后，有一定几率被沉默，持续两回合;

	参数：
	当前技能即为沉默别人时释放的技能
	rate 沉默概率	
]]

local Skill_anu_4 = class("Skill_anu_4", SkillAiBasic)

function Skill_anu_4:ctor(skill,id,rate)
	Skill_anu_4.super.ctor(self,skill,id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0)

	self._skill._isFightBack = true
end
--[[
	有人阵亡时做检查
]]
function Skill_anu_4:onHeroStartAttck(selfHero, targetHero, skill)
	if selfHero == targetHero then
		return
	end
	-- 必须是敌方阵营
	if selfHero.camp == targetHero.camp then
		return
	end
	-- 必须是自己能行动
	if not selfHero.data:checkCanAttack() then
		return
	end
	-- 必须是大招并且不是拼接技能,并且不是神器技能
	if skill.isStitched or skill.isArtifactSkill or skill.skillIndex ~= Fight.skillIndex_max then
		return
	end

	-- 判断概率
	if self._rate >= BattleRandomControl.getOneRandomInt(10001,1) then
		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 如果当前自己不能行动或对方已经死亡则不会进行攻击
			if SkillBaseFunc:isLiveHero(selfHero) and selfHero.data:checkCanAttack() and SkillBaseFunc:isLiveHero(targetHero) then
				self._skill:setAppointAtkChooseArr({targetHero})
				selfHero:checkSkill(self._skill, false, nil)
			else
				-- 执行下一项
				selfHero.triggerSkillControler:excuteTriggerSkill()
			end
		end)

		-- 打完归位
		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			if SkillBaseFunc:isLiveHero(selfHero) then
				-- 这里只需要等10帧就不做不能行动的判断了
				selfHero:movetoInitPos(2)
			end
		end, 10) -- 强给10帧
	end
end

return Skill_anu_4