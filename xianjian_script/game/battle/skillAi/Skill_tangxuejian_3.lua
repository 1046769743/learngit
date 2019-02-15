--[[
	Author:李朝野
	Date: 2017.08.07
]]


--[[
	唐雪见大招

	技能描述：
	为己方同排单位增加吸收盾持续两回合；
	该护盾具有一定生命，并在护盾持续期间，己方队友暴击率和破击率均有提升；

	脚本处理部分：
	需求可通过配置实现，这里留一个父类防止扩展

	参数：
]]
local Skill_tangxuejian_3 = class("Skill_tangxuejian_3", SkillAiBasic)


function Skill_tangxuejian_3:ctor(...)
	Skill_tangxuejian_3.super.ctor(self,...)
end

return Skill_tangxuejian_3