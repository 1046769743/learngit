--[[
	Author:李朝野
	Date: 2017.09.22
]]

--[[
	法宝琴大招

	技能描述：
	无单独内容，继承大招
	
	脚本处理部分：


	参数：
	atkId1 减怒攻击包
]]
local Skill_treasureqin_3 = require("game.battle.skillAi.Skill_treasureqin_3")
local Skill_treasureqin_3_1 = class("Skill_treasureqin_3_1", Skill_treasureqin_3)

function Skill_treasureqin_3_1:ctor(...)
	Skill_treasureqin_3_1.super.ctor(self,...)
end

return Skill_treasureqin_3_1