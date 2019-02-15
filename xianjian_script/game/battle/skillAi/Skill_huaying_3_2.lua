--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2018.09.10
]]

--[[
	花楹大招扩充2

	技能描述:
	每驱散一个负面buff，使目标减少1点怒气消耗

	脚本处理部分：
	统计buff数量，减少目标攻击力

	参数：
	@@atkId 恢复生命攻击包
	@@buffId1 加攻击力的buffId
	@@buffId2 减少怒气消耗的buffId
]]
local Skill_huaying_3_1 = require("game.battle.skillAi.Skill_huaying_3_1")

local Skill_huaying_3_2 = class("Skill_huaying_3_2", Skill_huaying_3_1)

function Skill_huaying_3_2:ctor(skill,id, atkId, buffId1, buffId2)
	Skill_huaying_3_2.super.ctor(self, skill,id, atkId, buffId1)
	
	self:errorLog(buffId2, "buffId2")

	self._buffId2 = buffId2 or 0
end

-- 技能结束后做减少怒气消耗的buff
function Skill_huaying_3_2:onAfterSkill(selfHero, skill)
	for defender,num in pairs(self._flag) do
		if num > 0 then
			local buffObj = self:getBuff(self._buffId2)
			buffObj.value = tonumber(buffObj.value) * num

			-- 做buff
			defender:checkCreateBuffByObj(buffObj, selfHero, skill)
		end
	end

	-- 后做父类函数，父类函数里会清除计数
	return Skill_huaying_3_2.super.onAfterSkill(self, selfHero, skill)
end

return Skill_huaying_3_2