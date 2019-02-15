--[[
	Author:李朝野
	Date: 2017.06.23
	Modify: 2018.03.07
]]
--[[
	林月如大招

	技能描述：


	脚本处理部分：

	参数：
	skillid 攻击一排的技能id（原技能攻击一个）
	atkId 加攻击的攻击包Id
]]
local Skill_linyueru_3_1 = require("game.battle.skillAi.Skill_linyueru_3_1")

local Skill_linyueru_3_2 = class("Skill_linyueru_3_2", Skill_linyueru_3_1)

function Skill_linyueru_3_2:ctor(...)
	Skill_linyueru_3_2.super.ctor(self, ...)
end

return Skill_linyueru_3_2