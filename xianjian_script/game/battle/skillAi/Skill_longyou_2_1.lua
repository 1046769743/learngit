--[[
	Author: lcy
	Date: 2018.03.27
]]

--[[
	龙幽小技能扩充1

	技能描述：
	小技能，如果目标处于中毒、流血状态时，必定附带灼烧效果；

	脚本处理部分：
	当前技能攻击满足条件的角色时，增加伤害

	参数：
	@@buffs 满足触发条件的buff 
	@@buffId 灼烧buff
]]

local Skill_longyou_2_1 = class("Skill_longyou_2_1", SkillAiBasic)

function Skill_longyou_2_1:ctor(skill,id,buffs,buffId)
	Skill_longyou_2_1.super.ctor(self,skill,id)

	self:errorLog(buffs, "buffs")
	self:errorLog(buffId, "buffId")

	self._buffs = string.split(buffs, "_")
	table.map(self._buffs, function(v, k)
		return tonumber(v)
	end)

	self._buffId = buffId or 0
end

-- 检查伤害时
function Skill_longyou_2_1:onCheckAttack(attacker, defender, skill, atkData, dmg)
	-- 检查是否存在buff
	local flag = false
	for _,bt in ipairs(self._buffs) do
		if defender.data:checkHasOneBuffType(bt) then
			flag = true
			break
		end
	end

	if flag then
		self:skillLog("敌人有相关buff,施加buff")
		local buffObj = self:getBuff(self._buffId)
		defender:checkCreateBuffByObj(buffObj, attacker, skill)
	end

	return dmg
end

return Skill_longyou_2_1