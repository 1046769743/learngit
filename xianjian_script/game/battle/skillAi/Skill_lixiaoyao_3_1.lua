--[[
	Author: lcy
	Date: 2018.08.09
]]

--[[
	李逍遥大招扩充1

	技能描述：
	释放天剑时，若己方每存活一个土系奇侠，则有34%几率清除目标增益状态

	参数:
	num 计数最大人数
	rate 每个人带来的加成
	buffIds 受到加成的buffId "xxx_xxx"
	
	ratioEx 每个人带来的概率加成
	ratioBuffIds 受到概率加成的buffId "xxx_xxx"
]]
local Skill_lixiaoyao_3 = require("game.battle.skillAi.Skill_lixiaoyao_3")
local Skill_lixiaoyao_3_1 = class("Skill_lixiaoyao_3_1", Skill_lixiaoyao_3)

function Skill_lixiaoyao_3_1:ctor(skill,id,num,rate,buffIds,ratioEx,ratioBuffIds)
	Skill_lixiaoyao_3_1.super.ctor(self,skill,id,num,rate,buffIds)

	self:errorLog(ratioEx, "ratioEx")
	self:errorLog(ratioBuffIds, "ratioBuffIds")

	self._ratioEx = tonumber(ratioEx or 0)
	self._rbuffIds = {}
	for _,buffId in ipairs(string.split(ratioBuffIds, "_")) do
		self._rbuffIds[buffId] = true
	end
end

function Skill_lixiaoyao_3_1:isUseBuffEx(buffId)
	return self._count > 0 and (self._buffIds[buffId] or self._rbuffIds[buffId])
end

function Skill_lixiaoyao_3_1:getBuffExRatio(buffId)
	local result = 0

	if self._rbuffIds[buffId] then
		result = self._count * self._ratioEx
	end

	return result
end

return Skill_lixiaoyao_3_1