--[[
	Author:李朝野
	Date: 2018.01.08
]]

--[[
	暮菖兰大招扩充2

	技能描述:
	全部继承前面逻辑
	
	脚本处理部分:

	参数:
	@@buffs 目标buff类型 2_3 （脚本里会额外判断是否为持续类型）
	@@exRound 延长回合数
]]
local Skill_muchanglan_3_1 = require("game.battle.skillAi.Skill_muchanglan_3_1")
local Skill_muchanglan_3_2 = class("Skill_muchanglan_3_2", Skill_muchanglan_3_1)

function Skill_muchanglan_3_2:ctor(...)
	Skill_muchanglan_3_2.super.ctor(self,...)
end

return Skill_muchanglan_3_2