--[[
	Author:李朝野
	Date: 2017.10.09
]]

--[[
	法宝镜大招扩充1

	技能描述：
	继承大招，脚本没有新内容

	脚本处理部分：


	参数：
	rate 获得的反击概率
	round 持续的回合数
	atkrate 获得的额外反击伤害率
]]
local Skill_treasurejing_3 = require("game.battle.skillAi.Skill_treasurejing_3")
local Skill_treasurejing_3_1 = class("Skill_treasurejing_3_1", Skill_treasurejing_3)

function Skill_treasurejing_3_1:ctor(...)
	Skill_treasurejing_3_1.super.ctor(self, ...)
end

return Skill_treasurejing_3_1