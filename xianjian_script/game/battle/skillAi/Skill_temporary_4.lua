--[[
	Author:lcy
	Date:2018.6.19
]]

--[[
	策划: xx  要展示 李忆如的火药桶，要把时间再拉开点。我给他配了个作假的。李逍遥天剑戳，怪物释放技能自爆~
	
	这个和他商量过，首次遇到的助战奇侠。目的就是展示，稍微有所不同，夸张点，可以接受~	

	以上为记录，特殊需求，除以上请境外，不要随意配置此脚本，
]]

local Skill_temporary_4 = class("Skill_temporary_4", SkillAiBasic)

function Skill_temporary_4:ctor(skill,id,rate)
	Skill_temporary_4.super.ctor(self,skill,id)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0)

	self._skill._isFightBack = true
end
--[[
	有人阵亡时做检查
]]
function Skill_temporary_4:onHeroStartAttck(selfHero, targetHero, skill)
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
				-- 不指定选敌
				-- self._skill:setAppointAtkChooseArr({targetHero})
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

return Skill_temporary_4