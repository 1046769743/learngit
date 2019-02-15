--[[
	Author: lcy
	Date: 2018.05.11
]]

--[[
	天师道袍被动

	技能描述:
	回合开始前,若当前气血比例低于30%,则提升自身一定防御力,持续一回合

	脚本处理部分:
	同上

	参数:
	提升自身防御力的技能即为当前技能
	hpper 触发血限（万分）
	skill
]]

local Skill_tianshidaopao_4 = class("Skill_tianshidaopao_4", SkillAiBasic)

function Skill_tianshidaopao_4:ctor(skill,id, hpper)
	Skill_tianshidaopao_4.super.ctor(self, skill, id)

	self:errorLog(hpper, "hpper")

	self._hpper = tonumber(hpper or 0) / 10000

	self._flag = false

	-----------配合大招的方法-----------
	self._rate = nil
end

-- 回合开始前检查
function Skill_tianshidaopao_4:onMyRoundStart(selfHero)
	-- 不是自己
	if not self:isSelfHero(selfHero) then return end
	-- 不能行动
	if not selfHero.data:checkCanAttack() then return end
	-- 自己已死
	if not SkillBaseFunc:isLiveHero(selfHero) then return end
	-- 已经触发过
	if self._flag then return end
	-- 检查血量
	if selfHero.data:getAttrPercent(Fight.value_health) <= self._hpper then
		self._flag = true

		self:skillLog("天师道袍被动触发",self._hpper)
		selfHero:setRoundReady(Fight.process_myRoundStart, false)

		selfHero.triggerSkillControler:pushOneSkillFunc(selfHero, function()
			-- 释放当前法宝的被动技能
			selfHero:checkTreasure(1,self._skill.skillIndex)
		end)

		selfHero.triggerSkillControler:excuteTriggerSkill(function()
			selfHero:checkResumeTreasure()
			
			selfHero:movetoInitPos(2)
			selfHero:setRoundReady(Fight.process_myRoundStart, true)
		end)
	end
end

----------------------------------配合大招的方法----------------------------------
function Skill_tianshidaopao_4:setExtraParams(rate)
	if self._rate then return end

	self._rate = rate
end

function Skill_tianshidaopao_4:onCheckBeAttack(attacker, defender, skill, atkData, dmg)
	-- 如果对方有道符标记
	if attacker.data:checkHasOneBuffType(Fight.buffType_tag_daofu) then
		self:skillLog("天师道袍，道符生效，降低伤害比例",self._rate)
		dmg = math.round(dmg - dmg * self._rate)
		-- 保留一点伤害
		if dmg < 1 then dmg = 1 end
	end

	return dmg
end
----------------------------------配合大招的方法----------------------------------

return Skill_tianshidaopao_4