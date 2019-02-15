--[[
	Author:李朝野
	Date: 2017.01.19
]]

--[[
	火神绿色小怪

	技能描述:
	挂了这个脚本的小怪，如果处于特定buff状态类型下回合开始前直接死亡

	参数:
	@@buffs 指定buff类型"xxx_xxx_xxx"
]]
local Skill_trial_huoshen_huorenlv = class("Skill_trial_huoshen_huorenlv", SkillAiBasic)

function Skill_trial_huoshen_huorenlv:ctor(skill,id, buffs)
	Skill_trial_huoshen_huorenlv.super.ctor(self, skill, id)

	self:errorLog(buffs, "buffs")

	self._buffs = string.split(buffs, "_")

	table.map(self._buffs, function( v, k )
		return tonumber(v)
	end)
end

-- 回合开始检查
function Skill_trial_huoshen_huorenlv:onMyRoundStart(selfHero )
	-- 不是自己返回
	if not self:isSelfHero(selfHero) then return end

	local flag = false

	for _,bt in ipairs(self._buffs) do
		if selfHero.data:checkHasOneBuffType(bt) then
			flag = true
			break
		end
	end

	if flag then
		selfHero:doHeroDie()
	end
end

return Skill_trial_huoshen_huorenlv