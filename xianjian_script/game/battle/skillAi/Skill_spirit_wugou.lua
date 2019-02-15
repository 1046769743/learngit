--[[
	Author: lcy
	Date: 2018.05.18
]]

--[[
	无垢神力
	
	技能描述:
	点选敌方任意目标，对敌方全体释放技能——有一定几率眩晕持续一回合。

	脚本处理:
	做选敌

	参数:
	
]]

local Skill_spirit_wugou = class("Skill_spirit_wugou", SkillAiBasic)

function Skill_spirit_wugou:ctor(skill,id)
	Skill_spirit_wugou.super.ctor(self,skill,id)
end

-- 处理攻击范围
--[[
	params = {
		hero = ,
	}
]]
function Skill_spirit_wugou:getSpiritSkillArr(params)
	local targetHero = params.hero
	-- 返回目标全体
	return table.copy(targetHero.campArr)
end

return Skill_spirit_wugou