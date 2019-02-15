--[[
	Author:李朝野
	Date: 2018.01.09
	Modify: 2018.03.07 扩充1->扩充2
]]

--[[
	夏侯瑾轩大招扩充2

	技能描述:
	根据己方敌方人数差异，额外获得增减益效果。
	（例如，己方6人，敌方3人，己方额外获得3/6倍的大招攻击加成，新buff；
	若敌方6人，己方3人，则敌方额外获得3/6倍的大招攻击力降低加成，新Buff）

	脚本处理部分:
	技能结束后根据双方人数为己方和敌方添加buff

	参数:
	@@buffIdA 加攻buff（作用类型应该是常量，具体数值由脚本决定）
	@@buffIdR 减攻buff（作用类型应该是常量，具体数值由脚本决定）
	@@rateA 加攻系数（万分）
	@@nA 加攻常数
	@@rateR 减攻系数（万分）
	@@nR 减攻常数
]]
local Skill_xiahoujinxuan_3_2 = class("Skill_xiahoujinxuan_3_2", SkillAiBasic)

function Skill_xiahoujinxuan_3_2:ctor(skill,id, buffIdA, buffIdR, rateA, nA, rateR, nR)
	Skill_xiahoujinxuan_3_2.super.ctor(self, skill, id)

	self:errorLog(buffIdA, "buffIdA")
	self:errorLog(buffIdR, "buffIdR")
	self:errorLog(rateA, "rateA")
	self:errorLog(nA, "nA")
	self:errorLog(rateR, "rateR")
	self:errorLog(nR, "nR")

	self._buffIdA = tonumber(buffIdA or 0)
	self._buffIdR = tonumber(buffIdR or 0)
	self._rateA = self:checkValue(rateA or 0)/10000 -- 获取可变参数
	self._nA = self:checkValue(nA or 0) -- 获取可变参数
	self._rateR = self:checkValue(rateR or 0)/10000 -- 获取可变参数
	self._nR = self:checkValue(nR or 0) -- 获取可变参数
end

-- 技能结束后根据情况检查buff
function Skill_xiahoujinxuan_3_2:onAfterSkill(selfHero,skill)
	-- 统计双方人数
	local eNums = 0
	local hNums = 0
	-- 检查活人（只是非傀儡，不能走通用的）
	local function chkLive(hero)
		return hero.data:hp() > 0 and not hero:hasNotAliveBuff()
	end

	for _,hero in ipairs(selfHero.campArr) do
		if chkLive(hero) then
			hNums = hNums + 1
		end
	end

	for _,hero in ipairs(selfHero.toArr) do
		if chkLive(hero) then
			eNums = eNums + 1
		end
	end

	self:skillLog("夏侯瑾轩大招扩充1,敌方人数:%s,我方人数:%s",eNums,hNums)
	-- 双方都有人
	if eNums ~= 0 and hNums ~= 0 then
		local buffObjA = self:getBuff(self._buffIdA)
		local buffObjR = self:getBuff(self._buffIdR)

		buffObjA.value = math.round(buffObjA.value * self._rateA * eNums / hNums + self._nA)
		buffObjR.value = -math.round(buffObjR.value * self._rateR * hNums / eNums + self._nR)

		self:skillLog("夏侯瑾轩大招扩充1,加攻buff值:%s,减攻buff值:%s",buffObjA.value,buffObjR.value)

		-- 我方加攻buff
		for _,hero in ipairs(selfHero.campArr) do
			if chkLive(hero) then
				hero:checkCreateBuffByObj(buffObjA, selfHero, self._skill)
			end
		end

		-- 敌方减攻buff
		for _,hero in ipairs(selfHero.toArr) do
			if chkLive(hero) then
				hero:checkCreateBuffByObj(buffObjR, selfHero, self._skill)
			end
		end
	end

	return true
end

return Skill_xiahoujinxuan_3_2