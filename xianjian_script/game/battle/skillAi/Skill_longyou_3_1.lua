--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2017.11.07 pangkangning
	Modify: 2017.11.19 pangkangning
	Modify: 2017.12.29 lcy
]]


-- 2017.11.07 pangkangning 修改：大招、大招扩充1、大招扩充2，去除掉对控制类角色的额外伤害；删除rate 字段
--[[
	龙幽
	只对大招做继承

	参数：
	buffs 需要检查的buff类型 xx_xx_xx
	skillId 额外释放的技能Id
	failSkillId 判定失败释放的技能Id
]]

local Skill_longyou_3 = require("game.battle.skillAi.Skill_longyou_3")

local Skill_longyou_3_1 = class("Skill_longyou_3_1", Skill_longyou_3)

function Skill_longyou_3_1:ctor(...)
	Skill_longyou_3_1.super.ctor(self, ...)
end

return Skill_longyou_3_1