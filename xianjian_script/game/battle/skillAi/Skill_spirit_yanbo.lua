--[[
	Author: lcy
	Date: 2018.05.18
]]

--[[
	炎波神力
	
	技能描述:
	点一个目标，受到炎波影响，在其回合开始前损失当前回合受到的30%伤害。紫苑

	脚本处理:
	做选敌

	参数:
	
]]

local Skill_spirit_yanbo = class("Skill_spirit_yanbo", SkillAiBasic)

function Skill_spirit_yanbo:ctor(skill,id)
	Skill_spirit_yanbo.super.ctor(self,skill,id)
end

-- 处理攻击范围
--[[
	params = {
		hero = ,
	}
]]
function Skill_spirit_yanbo:getSpiritSkillArr(params)
	local targetHero = params.hero
	-- 返回目标自己
	return {targetHero}
end

return Skill_spirit_yanbo