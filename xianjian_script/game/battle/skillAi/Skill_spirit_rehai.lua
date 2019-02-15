--[[
	Author: lcy
	Date: 2018.05.18
]]

--[[
	寒髓神力
	
	技能描述:
	点选一个目标，链接其所在一行（3人的方向）
	同步受伤的问题还需要考虑。

	脚本处理:
	做选敌

	参数:
	
]]

local Skill_spirit_rehai = class("Skill_spirit_rehai", SkillAiBasic)

function Skill_spirit_rehai:ctor(skill,id)
	Skill_spirit_rehai.super.ctor(self,skill,id)
end

-- 处理攻击范围
--[[
	params = {
		hero = ,
	}
]]
function Skill_spirit_rehai:getSpiritSkillArr(params)
	-- 目标所在的一行
	local result = {}

	local targetHero = params.hero

	if targetHero then
		result = AttackChooseType:findHeroByIndex( nil,targetHero.data.gridPos.y,targetHero.controler:getCampArr(targetHero.camp)) or result
	end

	return result
end

return Skill_spirit_rehai