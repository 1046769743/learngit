--[[
	Author:李朝野
	Date: 2017.06.21
	Modify: 2018.09.10
]]

--[[
	花楹大招扩充1
	
	技能描述:
	每驱散一个负面buff增加x攻击力
	

	脚本处理部分：
	统计buff数量，增加目标攻击力

	参数：
	@@atkId 恢复生命攻击包
	@@buffId1 加攻击力的buffId
]]
local Skill_huaying_3 = require("game.battle.skillAi.Skill_huaying_3")

local Skill_huaying_3_1 = class("Skill_huaying_3_1", Skill_huaying_3)

function Skill_huaying_3_1:ctor(skill,id, atkId, buffId1)
	Skill_huaying_3_1.super.ctor(self,skill,id, atkId)

	self:errorLog(buffId1, "buffId1")

	self._buffId1 = buffId1 or 0
end

-- 技能结束后做额外加攻buff
function Skill_huaying_3_1:onAfterSkill(selfHero, skill)
	for defender,num in pairs(self._flag) do
		if num > 0 then
			local buffObj = self:getBuff(self._buffId1)
			buffObj.value = tonumber(buffObj.value) * num
			if buffObj.calValue then
				buffObj.calValue.rate = tonumber(buffObj.calValue.rate) * num
				buffObj.calValue.n = tonumber(buffObj.calValue.n) * num
			end

			-- 做加攻
			defender:checkCreateBuffByObj(buffObj, selfHero, skill)
		end
	end

	-- 后做父类函数，父类函数里会清除计数
	return Skill_huaying_3_1.super.onAfterSkill(self, selfHero, skill)
end

return Skill_huaying_3_1