--[[
	Author: lcy
	Date: 2018.05.08
]]

--[[
	陀螺被动

	技能描述:
	受到若干次攻击后，获得反伤效果，待机动作切换为特殊待机

	脚本处理部分:
	记录受击次数，满足条件后给自己加buff，并开启特殊待机

	参数:
	num 满足条件的攻击次数
	buffId 反伤buffId
]]

local Skill_tuoluo_4 = class("Skill_tuoluo_4", SkillAiBasic)

function Skill_tuoluo_4:ctor(skill,id,num,buffId)
	Skill_tuoluo_4.super.ctor(self, skill, id)

	self:errorLog(num, "num")
	self:errorLog(buffId, "buffId")

	self._num = tonumber(num or 10)
	self._buffId = tonumber(buffId or 0)

	self._count = 0 -- 受击次数
end

function Skill_tuoluo_4:onAfterHited(selfHero, attacker, skill, atkData)
	-- 大于0才有效
	if selfHero.data:hp() < 0 then return end
	-- 已经激活过了则不再激活
	if self._count >= self._num then return end
	
	self._count = self._count + 1

	if self._count ~= self._num then return end

	-- 次数满足
	self:skillLog("陀螺被动激活")

	selfHero:checkCreateBuffByObj(self:getBuff(self._buffId), selfHero, self._skill)

	-- 置为特殊状态
	selfHero:setUseSpStand(true)
end

return Skill_tuoluo_4