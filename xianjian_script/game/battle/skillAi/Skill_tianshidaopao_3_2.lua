--[[
	Author: lcy
	Date: 2018.05.11
]]

--[[
	天师道袍大招扩充2

	技能描述:
	调取太极效果，攻击敌方单体，使用道符为自身添加一个吸收伤害护盾

	脚本处理部分:
	由于后续需要动态改变护盾值，所以护盾buff手动添加

	参数:
	buffId 护盾buffId
	hpper 触发血限（万分）
	exRate 数值提升效果(万分)
	rate 伤害降低率
]]
local Skill_tianshidaopao_3_1 = require("game.battle.skillAi.Skill_tianshidaopao_3_1")
local Skill_tianshidaopao_3_2 = class("Skill_tianshidaopao_3_2", Skill_tianshidaopao_3_1)

function Skill_tianshidaopao_3_2:ctor(skill,id, buffId, hpper, exRate, rate)
	Skill_tianshidaopao_3_2.super.ctor(self, skill, id, buffId, hpper, exRate)

	self:errorLog(rate, "rate")

	self._rate = tonumber(rate or 0) / 10000
end

-- 放大招的时候激活一次即可
function Skill_tianshidaopao_3_2:onBeforeSkill(selfHero, skill)
	-- 传递参数
	local selfHero = self:getSelfHero()

	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if skill4expand then 
		skill4expand:setExtraParams(self._rate,self._lastRound)
	end
end

return Skill_tianshidaopao_3_2