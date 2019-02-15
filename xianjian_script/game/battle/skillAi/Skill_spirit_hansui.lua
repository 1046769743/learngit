--[[
	Author: lcy
	Date: 2018.05.18
]]

--[[
	寒髓神力
	
	技能描述:
	点选一个目标，冰冻其所在一排(2人的方向)。

	脚本处理:
	做选敌

	参数:
	
]]

local Skill_spirit_hansui = class("Skill_spirit_hansui", SkillAiBasic)

function Skill_spirit_hansui:ctor(skill,id)
	Skill_spirit_hansui.super.ctor(self,skill,id)
end

-- 处理攻击范围
--[[
	params = {
		hero = ,
	}
]]
function Skill_spirit_hansui:getSpiritSkillArr(params)
	-- 目标所在的一排
	local result = {}

	local targetHero = params.hero

	if targetHero then
		local xIndex = targetHero.data.gridPos.x
		for _,hero in ipairs(targetHero.controler:getCampArr(targetHero.camp)) do
			if xIndex == hero.data.gridPos.x
				and SkillBaseFunc:isLiveHero(hero)
			then
				result[#result + 1] = hero
			end
		end
	end

	return result
end

return Skill_spirit_hansui