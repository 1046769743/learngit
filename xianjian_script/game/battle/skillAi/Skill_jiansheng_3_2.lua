--[[
	Author:李朝野
	Date: 2017.08.31
	Modify: 2018.03.21
]]
--[[
	剑圣大招扩充2

	技能描述：
	伏魔状态，提升减少治疗上限提高50%

	脚本处理部分：
	特殊状态提升额外比率

	参数：
	@@buffId 减少治疗上限的buff（作用类型为值，具体值由脚本赋值）
	@@rate 减少的治疗上限占伤害量的比率
	@@rateEx 额外伤害的系数
	@@rateEx1 气血最多的人受到的额外伤害系数1
	@@rate1 额外的减少的治疗上限占伤害量的比率
]]

local Skill_jiansheng_3_1 = require("game.battle.skillAi.Skill_jiansheng_3_1")
local Skill_jiansheng_3_2 = class("Skill_jiansheng_3_2", Skill_jiansheng_3_1)

function Skill_jiansheng_3_2:ctor(skill,id, buffId, rate, rateEx, rateEx1, rate1)
	Skill_jiansheng_3_2.super.ctor(self, skill,id, buffId, rate, rateEx, rateEx1)

	self:errorLog(rate1, "rate1")

	self._rate1 = tonumber(rate1 or 0)
end

-- 获取两个参数
function Skill_jiansheng_3_2:_get2Params(defender)
	local rate,exRate = self._rate,0

	local selfHero = self:getSelfHero()
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if skill4expand and skill4expand:isSpStatus() then
		rate = rate + self._rate1
		exRate = self._rateEx
		self:skillLog("剑圣伏魔状态下,附加额外伤害比例:%s,额外减少治疗上限:%s",exRate,self._rate1)
	end

	-- 如果是选中的人
	if self._tHero == defender then
		self._tHero = nil
		exRate = exRate + self._rateEx1
		self:skillLog("阵营%s %s号位气血最多,附加额外伤害比例",defender.camp,defender.data.posIndex,self._rateEx1)
	end

	return rate,exRate
end

return Skill_jiansheng_3_2