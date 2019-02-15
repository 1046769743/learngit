--[[
	Author: lcy
	Date: 2018.06.04
]]

--[[
	金蟾鬼母被动

	技能描述:
	受到DOT伤害时，不掉血，恢复应该掉的气血量

	脚本处理部分:
	buff作用时改变实际作用值

	参数:
	@@buffs 会生效的bufftype "xx_xx"
]]
local Skill_jinchanguimu_4 = class("Skill_jinchanguimu_4", SkillAiBasic)

function Skill_jinchanguimu_4:ctor(skill,id, buffs)
	Skill_jinchanguimu_4.super.ctor(self,skill,id)

	self:errorLog(buffs, "buffs")

	local bf = string.split(buffs, "_")
	self._buffs = {}
	
	for _,b in ipairs(bf) do
		if tonumber(b) then
			self._buffs[tonumber(b)] = true
		end
	end
end

-- 金蟾鬼母
function Skill_jinchanguimu_4:onBuffBeDo(value, changeType, buffObj)
	if self._buffs[buffObj.type] and buffObj.runType == Fight.buffRunType_round then
		self:skillLog("金蟾鬼母被动生效，将dot转换为加血",value)
		value = -value
	end

	return value,changeType
end

return Skill_jinchanguimu_4