--[[
	Author: lcy
	Date: 2018.08.09
]]

--[[
	李逍遥大招

	技能描述：
	攻击敌方一行奇侠，并提升自身15%暴击率和格挡率；
	在释放时，若己方每存活一个土系奇侠，则额外提升5%；最多提升15%

	参数：
	num 计数最大人数
	rate 每个人带来的加成
	buffIds 受到加成的buffId "xxx_xxx"
]]
local Skill_lixiaoyao_3 = class("Skill_lixiaoyao_3", SkillAiBasic)

function Skill_lixiaoyao_3:ctor(skill,id,num,rate,buffIds)
	Skill_lixiaoyao_3.super.ctor(self, skill, id)

	self:errorLog(num, "num")
	self:errorLog(rate, "rate")
	self:errorLog(buffIds, "buffIds")

	self._num = tonumber(num or 3)
	self._rate = tonumber(rate or 0)
	self._buffIds = {}
	for _,buffId in ipairs(string.split(buffIds, "_")) do
		self._buffIds[buffId] = true
	end

	self._count = 0
end

-- 技能前检查个数
function Skill_lixiaoyao_3:onBeforeSkill(selfHero, skill)
	-- 检查个数
	self._count = 0
	-- 检查土属性奇侠个数
	for _,hero in ipairs(selfHero.campArr) do
		if hero:getHeroElement() == Fight.element_soil then
			self._count = self._count + 1
		end
	end

	if self._count > self._num then self._count = self._num end
end

-- 技能结束后重置标记
function Skill_lixiaoyao_3:onAfterSkill(selfHero, skill)
	self._count = 0

	return true
end

function Skill_lixiaoyao_3:isUseBuffEx(buffId)
	return self._count > 0 and self._buffIds[buffId]
end

function Skill_lixiaoyao_3:getBuffExValue(buffId)
	local result = 0

	if self._buffIds[buffId] then
		result = self._count * self._rate
	end

	return result
end

return Skill_lixiaoyao_3