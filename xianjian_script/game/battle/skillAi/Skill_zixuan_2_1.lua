--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	紫萱小技能扩充1

	技能描述：
	小技能，如果被击目标带有傀儡虫buff，则提升自身攻击力额外伤害；

	脚本处理部分：
	当前技能攻击满足条件的角色时，增加伤害

	参数：
	@@buffs 满足触发条件的buff 
	@@rate 满足条件时附加伤害的比例
]]

local Skill_zixuan_2_1 = class("Skill_zixuan_2_1", SkillAiBasic)

function Skill_zixuan_2_1:ctor(skill,id,buffs,rate)
	Skill_zixuan_2_1.super.ctor(self,skill,id)

	self:errorLog(buffs, "buffs")
	self:errorLog(rate, "rate")

	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function(v, k)
		return tonumber(v)
	end)

	self._rate = tonumber(rate or 0)
end

-- 检查伤害时
function Skill_zixuan_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 检查是否存在buff
	local flag = false
	for _,bt in ipairs(self._buffs) do
		if defender.data:checkHasOneBuffType(bt) then
			flag = true
			break
		end
	end

	if flag then
		local exDmg = math.round(attacker.data:atk() * self._rate / 10000)
		self:skillLog("敌人有相关buff,伤害增强",exDmg)
		dmg = dmg + exDmg
	end

	return dmg
end

return Skill_zixuan_2_1