--[[
	Author:李朝野
	Date: 2017.09.15
]]


--[[
	星璇大招扩充1
	继承大招没有新内容

	技能描述：
	若目标生命低于50%，播放另一个技能，并造成额外伤害；

	脚本处理部分：
	大招会有两段，第一段之前要判断血量决定第二段放哪个技能；

	参数：
	hpper 血限，万分
	skills 额外技能"xxx_xxx"
	atkId 表现攻击包的Id
]]
local Skill_xingxuan_3 = require("game.battle.skillAi.Skill_xingxuan_3")

local Skill_xingxuan_3_1 = class("Skill_xingxuan_3_1", Skill_xingxuan_3)

function Skill_xingxuan_3_1:ctor(...)
	Skill_xingxuan_3_1.super.ctor(self, ...)
end

return Skill_xingxuan_3_1