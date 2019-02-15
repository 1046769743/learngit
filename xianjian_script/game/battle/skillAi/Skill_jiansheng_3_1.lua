--[[
	Author:李朝野
	Date: 2017.08.31
	Modify: 2018.03.21
]]
--[[
	剑圣大招扩充1

	技能描述:
	攻击血量最多的敌人受到额外伤害。

	脚本处理部分:
	技能作用前找到气血最多的人（先比百分比，再比值），计算伤害时增加伤害；

	参数：
	@@buffId 减少治疗上限的buff（作用类型为值，具体值由脚本赋值）
	@@rate 减少的治疗上限占伤害量的比率
	@@rateEx 额外伤害的系数
	@@rateEx1 气血最多的人受到的额外伤害系数1
]]

local Skill_jiansheng_3 = require("game.battle.skillAi.Skill_jiansheng_3")
local Skill_jiansheng_3_1 = class("Skill_jiansheng_3_1", Skill_jiansheng_3)

function Skill_jiansheng_3_1:ctor(skill,id, buffId, rate, rateEx, rateEx1)
	Skill_jiansheng_3_1.super.ctor(self,skill,id, buffId, rate, rateEx)

	self:errorLog(rateEx1, "rateEx1")

	self._rateEx1 = tonumber(rateEx1 or 0)

	self._tHero = nil
end

--[[
	找倒霉的血最多的
]]
function Skill_jiansheng_3_1:onBeforeSkill(selfHero, skill)
	-- cutChooseNums
	local campArr = table.copy(selfHero.toArr)
	local function sortF( h1,h2 )
		local hp1 = h1.data:hp()
		local hp2 = h2.data:hp()

		local per1 = hp1/h1.data:maxhp()
		local per2 = hp2/h2.data:maxhp()
		if per1 == per2 then
			if hp1 == hp2 then
				return h1.data.posIndex < h2.data.posIndex
			end

			return hp1 > hp2
		end

		return per1 > per2
	end

	table.sort(campArr, sortF)

	self._tHero = campArr[1]
end

-- 获取两个参数
function Skill_jiansheng_3_1:_get2Params(defender)
	local rate,exRate = self._rate,0

	local selfHero = self:getSelfHero()
	local specialSkill = selfHero.data:getSpecialSkill()
	local skill4expand = specialSkill and specialSkill.skillExpand or nil

	if skill4expand and skill4expand:isSpStatus() then
		exRate = self._rateEx
		self:skillLog("剑圣伏魔状态下,附加额外伤害比例",exRate)
	end

	-- 如果是选中的人
	if self._tHero == defender then
		self._tHero = nil
		exRate = exRate + self._rateEx1
		self:skillLog("阵营%s %s号位气血最多,附加额外伤害比例:%s",defender.camp,defender.data.posIndex,self._rateEx1)
	end

	return rate,exRate
end

return Skill_jiansheng_3_1