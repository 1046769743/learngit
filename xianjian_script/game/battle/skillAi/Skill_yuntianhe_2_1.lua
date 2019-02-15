--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	云天河小技能扩充1

	技能描述：
	小技能，每有一个目标被暴击，则提升自身暴击效果1份，持续一回合；（最终1个buff，修改值）

	脚本处理部分：
	根据暴击个数给自己添加buff

	参数：
	@@buffId 提升暴击效果的buff
]]
local Skill_yuntianhe_2_1 = class("Skill_yuntianhe_2_1", SkillAiBasic)

function Skill_yuntianhe_2_1:ctor(skill,id, buffId)
	Skill_yuntianhe_2_1.super.ctor(self,skill,id)

	self:errorLog(buffId, "buffId")

	self._buffId = buffId or 0
	self._count = 0 -- 记录暴击个数
end

-- 记录暴击个数
function Skill_yuntianhe_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	local atkResult = defender:getDamageResult(attacker, skill)
	-- 如果本次攻击暴击了
	if atkResult == Fight.damageResult_baoji or atkResult == Fight.damageResult_baojigedang then
		self._count = self._count + 1
	end
end

function Skill_yuntianhe_2_1:onAfterSkill(selfHero, skill)
	if self._count > 0 then
		local num = self._count 
		self._count = 0

		local buffObj = self:getBuff(self._buffId)
		buffObj.value = tonumber(buffObj.value) * num
		if buffObj.calValue then
			buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * num
			buffObj.calValue.n = tonumber(buffObj.calValue.n) * num
		end

		self:skillLog("暴击次数",num)
		-- 加buff
		selfHero:checkCreateBuffByObj(buffObj, selfHero, skill)
	end

	return true
end

return Skill_yuntianhe_2_1