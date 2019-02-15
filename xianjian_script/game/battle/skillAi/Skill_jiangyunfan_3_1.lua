--[[
	Author:李朝野
	Date: 2017.08.30
	Modify: 2018.03.12
]]

--[[
	姜云凡大招扩充1

	技能描述:
	释放怒气仙术后，所有攻击，吸血效果提高20%（所有攻击可以吸血20%），持续2回合
	
	脚本处理部分：
	可配置此脚本只做继承用

	参数：
	skillId 给自己和同排加攻击力的技能
	ratio 满足血量（万分）
]]
local Skill_jiangyunfan_3 = require("game.battle.skillAi.Skill_jiangyunfan_3")

local Skill_jiangyunfan_3_1 = class("Skill_jiangyunfan_3_1", Skill_jiangyunfan_3)

function Skill_jiangyunfan_3_1:ctor(...)
	Skill_jiangyunfan_3_1.super.ctor(self, ...)
end

return Skill_jiangyunfan_3_1