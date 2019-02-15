--[[
	Author:李朝野
	Date: 2017.08.23
]]

--[[
	狐妖女大招扩充2

	技能描述:
	将前面技能的魅惑变成混乱
	
	脚本处理部分：
	将前面技能的魅惑变成混乱

	参数：
	ratio 混乱概率
	atkId 必定控制的攻击包id（混乱）
	atkId1 降低攻击力的攻击包id
]]
local Skill_huyaonv_3_1 = require("game.battle.skillAi.Skill_huyaonv_3_1")

local Skill_huyaonv_3_2 = class("Skill_huyaonv_3_2", Skill_huyaonv_3_1)

function Skill_huyaonv_3_2:ctor(...)
	Skill_huyaonv_3_2.super.ctor(self, ...)
end

return Skill_huyaonv_3_2