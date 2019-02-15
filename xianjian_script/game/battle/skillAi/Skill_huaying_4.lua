--[[
	Author:李朝野
	Date: 2017.07.26
]]
--[[
	花楹被动

	技能描述：
	花楹自身不会受到冰冻、眩晕、沉默控制效果限制；

	脚本处理部分：
	花楹不会受到配置的buff类型作用

	参数：
	buffs 花楹免疫的buff效果 2_3
]]
local Skill_huaying_4 = class("Skill_huaying_4", SkillAiBasic)

function Skill_huaying_4:ctor(skill,id,buffs)
	Skill_huaying_4.super.ctor(self, skill, id)

	self:errorLog(buffs, "buffs")

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end

--[[
	花楹对特定类型buff免疫
]]
function Skill_huaying_4:onBeforeUseBuff(selfHero, attacker, skill, buffObj)
	local result = true
	-- 满足条件
	if array.isExistInArray(self._buffs, buffObj.type) then
		self:skillLog("花楹阻止buff%s生效", buffObj.hid)
		result = false
	end

	return result
end

return Skill_huaying_4