--[[
	Author:李朝野
	Date: 2017.08.10
]]

--[[
	法宝剑大招

	技能描述：

	
	脚本处理部分：
	
	备注：
	继承自大招扩充1，没有单独处理内容，占坑用，参数与大招扩充1相同。

	参数：
	pro 角色类型
	rate 额外伤害系数（万分）
]]
local Skill_treasurejian_3_1 = require("game.battle.skillAi.Skill_treasurejian_3_1")
local Skill_treasurejian_3_2 = class("Skill_treasurejian_3_2", Skill_treasurejian_3_1)


function Skill_treasurejian_3_2:ctor(...)
	Skill_treasurejian_3_2.super.ctor(self,...)
end

return Skill_treasurejian_3_2