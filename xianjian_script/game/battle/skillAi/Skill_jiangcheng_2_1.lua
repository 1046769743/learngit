--[[
	Author: lcy
	Date: 2018.08.04
]]

--[[
	姜承普通仙术觉醒

	技能描述：
	攻击当前目标，如果自身气血低于50%，不再攻击，进入防御形态，格挡率提高30%

	参数：
	hpper 满足条件的血量比例（万分）
	skillId 气血低于标准时释放的技能
]]
local Skill_jiangcheng_2_1 = class("Skill_jiangcheng_2_1", SkillAiBasic)

function Skill_jiangcheng_2_1:ctor(skill,id,hpper,skillId)
	Skill_jiangcheng_2_1.super.ctor(self,skill,id)

	self:errorLog(hpper, "hpper")
	self:errorLog(skillId, "skillId")

	self._hpper = tonumber(hpper or 0) / 10000
	self._skillId = skillId

	self._exSkill = nil
	self._flag = false -- 是否是防御状态
end

-- 回合开始前检查一下状态
function Skill_jiangcheng_2_1:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end

	if self._flag then
		-- 重置状态和动作
		self._flag = false
		selfHero:setUseSpStand(false)
	end
end

-- 攻击前换技能检查
function Skill_jiangcheng_2_1:onBeforeCheckSkill(selfHero, skill)
	local result = skill

	-- 检查换技能
	if SkillBaseFunc:isLiveHero(selfHero) and self._hpper >= selfHero.data:getAttrPercent(Fight.value_health) then
		if not self._exSkill then
			self._exSkill = self:_getExSkill(self._skillId, true)
		end

		result = self._exSkill
		-- 设置特殊动作
		selfHero:setUseSpStand(true)

		self._flag = true
	end

	return result
end

return Skill_jiangcheng_2_1