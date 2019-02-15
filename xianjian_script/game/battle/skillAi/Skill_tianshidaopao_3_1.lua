--[[
	Author: lcy
	Date: 2018.05.11
]]

--[[
	天师道袍大招扩充1

	技能描述:
	调取太极效果，攻击敌方单体，使用道符为自身添加一个吸收伤害护盾，如果自身气血低于30%，则提升护盾效果50%

	脚本处理部分:
	如果自身气血低于30%，则提升护盾效果50%

	参数:
	buffId 护盾buffId
	hpper 触发血限（万分）
	exRate 数值提升效果
]]
local Skill_tianshidaopao_3 = require("game.battle.skillAi.Skill_tianshidaopao_3")
local Skill_tianshidaopao_3_1 = class("Skill_tianshidaopao_3_1", Skill_tianshidaopao_3)

function Skill_tianshidaopao_3_1:ctor(skill,id, buffId, hpper, exRate)
	Skill_tianshidaopao_3_1.super.ctor(self, skill, id, buffId)

	self:errorLog(hpper, "hpper")
	self:errorLog(exRate, "exRate")

	self._hpper = tonumber(hpper or 0) / 10000
	self._exRate = tonumber(exRate or 0) / 10000
end

function Skill_tianshidaopao_3_1:onAfterSkill(selfHero, skill)
	local selfHero = self:getSelfHero()

	local buffObj = ObjectBuff.new(self._buffId,self._skill)

	if selfHero.data:getAttrPercent(Fight.value_health) <= self._hpper then
		self:skillLog("天师道袍大招扩充1提升效果")
		buffObj.value = math.round(buffObj.value * (1 + self._exRate))
	end
	-- 加护盾
	selfHero:checkCreateBuffByObj(buffObj, selfHero, self._skill)

	return true
end

return Skill_tianshidaopao_3_1