--[[
	Author: lcy
	Date: 2018.08.09
]]

--[[
	蓝葵小技能脚本

	技能描述：
	走通用辅助技能;
	己方单体，增加一定攻击力；若己方目标为火系奇侠，则额外提升10%攻击力
	同排

	参数:
	skillId 备选技能Id

	rate 满足条件提升的值
	buffIds 收到加成的buffIds "xxx_xxx"
]]
local Skill_assistskill_change = require("game.battle.skillAi.Skill_assistskill_change")

local Skill_lankui_2 = class("Skill_lankui_2", Skill_assistskill_change)

function Skill_lankui_2:ctor(skill,id,skillId, rate, buffIds)
	Skill_lankui_2.super.ctor(self, skill,id,skillId)

	self:errorLog(rate, "rate")
	self:errorLog(buffIds, "buffIds")

	self._rate = tonumber(rate or 0)
	self._buffIds = {}
	for _,buffId in ipairs(string.split(buffIds, "_")) do
		self._buffIds[buffId] = true
	end

	self._flag = false -- 是否应用加成
end

function Skill_lankui_2:onBeforeCheckSkill(selfHero, skill)
	local result,hero = Skill_lankui_2.super.onBeforeCheckSkill(self, selfHero, skill)

	if hero and hero:getHeroElement() == Fight.element_fire then
		self._flag = true
	end

	return result,hero
end

function Skill_lankui_2:onAfterSkill(selfHero, skill)
	-- 重置
	self._flag = false

	return true
end

function Skill_lankui_2:isUseBuffEx(buffId)
	return self._flag and self._buffIds[buffId]
end

function Skill_lankui_2:getBuffExCalValue(buffId)
	local rate,n = 0,0

	if self._buffIds[buffId] then
		rate = rate + self._rate
	end

	return rate,n
end

return Skill_lankui_2