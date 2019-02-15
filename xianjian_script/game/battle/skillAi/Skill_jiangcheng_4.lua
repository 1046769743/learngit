--[[
	Author: lcy
	Date: 2018.08.04
]]

--[[
	姜承被动

	技能描述：
	义衅，当气血值大于50%时，增加同行队友免伤率30%，降低自己免伤率30%。
	当自身气血低于50%，每回合开始时，恢复10%最大气血。
	每回合开始时，恢复10%最大气血。不超过攻击力的500%。

	参数：
	hpper 触发效果的血限
	buffId1 增加免伤率的buffId
	buffId2 降低自己免伤率的buffId
	buffId3 恢复气血的buffId
]]
local Skill_jiangcheng_4 = class("Skill_jiangcheng_4", SkillAiBasic)

function Skill_jiangcheng_4:ctor(skill,id, hpper, buffId1, buffId2, buffId3)
	Skill_jiangcheng_4.super.ctor(self, skill, id)

	self:errorLog(hpper, "hpper")
	self:errorLog(buffId1, "buffId1")
	self:errorLog(buffId2, "buffId2")
	self:errorLog(buffId3, "buffId3")

	self._hpper = tonumber(hpper or 5000) / 10000
	self._buffId1 = buffId1
	self._buffId2 = buffId2
	self._buffId3 = buffId3
end

function Skill_jiangcheng_4:onMyRoundStart(selfHero)
	if not self:isSelfHero(selfHero) then return end
	if not SkillBaseFunc:isLiveHero(selfHero) then return end
	-- 检查血限
	if selfHero.data:getAttrPercent(Fight.value_health) > self._hpper then
		self:doHigherThanPer()
	else
		self:doLowerThanPer()
	end
end

-- 做高于血线的逻辑
function Skill_jiangcheng_4:doHigherThanPer()
	-- 增加同行免伤率，降低自己30%免伤率
	-- 降低自己免伤率
	local selfHero = self:getSelfHero()
	selfHero:checkCreateBuff(self._buffId2, selfHero, self._skill)
	-- 提升队友免伤率
	local target = selfHero.data.posIndex % 2
	for _,hero in ipairs(selfHero.campArr) do
		local hPos = hero.data.posIndex
		if hero ~= selfHero and hPos % 2 == target then
			self:skillLog("姜承为阵营%s,%s号位加buff:%s",hero.camp,hero.data.posIndex,self._buffId1)
			hero:checkCreateBuff(self._buffId1, selfHero, self._skill)
		end
	end
end

-- 做低于血线的逻辑
function Skill_jiangcheng_4:doLowerThanPer()
	self:skillLog("姜承为自己施加buff:%s",self._buffId3)
	local selfHero = self:getSelfHero()
	selfHero:checkCreateBuff(self._buffId3, selfHero, self._skill)
end

return Skill_jiangcheng_4